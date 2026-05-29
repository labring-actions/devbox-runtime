#!/usr/bin/env bash
set -Eeuo pipefail

RUNTIME_PATH=${RUNTIME_PATH:?RUNTIME_PATH is required}
RUNTIME_DOCKERFILE=${RUNTIME_DOCKERFILE:-}
RUNTIME_IMAGE=${RUNTIME_IMAGE:-}
L10N=${L10N:-en_US}
CONFORMANCE_ARCH=${CONFORMANCE_ARCH:-}
REPO_ROOT=${REPO_ROOT:-/repo}
PROJECT_DIR=${PROJECT_DIR:-/home/devbox/project}
WORKSPACE_DIR=${WORKSPACE_DIR:-/home/devbox/workspace}
STARTUP_SECONDS=${CONFORMANCE_STARTUP_SECONDS:-5}
HTTP_TIMEOUT=${CONFORMANCE_HTTP_TIMEOUT:-60}

log() {
  printf '\n>>> %s\n' "$*"
}

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

debug() {
  if [ "${CONFORMANCE_DEBUG:-}" = "1" ]; then
    printf 'debug: %s\n' "$*"
  fi
}

assert_file() {
  local path="$1"
  [ -f "$path" ] || fail "missing file: $path"
}

assert_dir() {
  local path="$1"
  [ -d "$path" ] || fail "missing directory: $path"
}

assert_executable() {
  local path="$1"
  [ -x "$path" ] || fail "missing executable: $path"
}

assert_command() {
  local command_name="$1"
  command -v "$command_name" >/dev/null 2>&1 || fail "missing command: $command_name"
}

print_runtime_context() {
  log "runtime context"
  printf 'runtime_path=%s\n' "$RUNTIME_PATH"
  printf 'runtime_dockerfile=%s\n' "$RUNTIME_DOCKERFILE"
  printf 'runtime_image=%s\n' "$RUNTIME_IMAGE"
  printf 'l10n=%s\n' "$L10N"
  printf 'conformance_arch=%s\n' "$CONFORMANCE_ARCH"
  printf 'user=%s uid=%s gid=%s\n' "$(id -un)" "$(id -u)" "$(id -g)"
  printf 'home=%s\n' "${HOME:-}"
  printf 'path=%s\n' "$PATH"
  if [ -f /etc/os-release ]; then
    sed -n '1,8p' /etc/os-release
  fi
}

normalize_arch() {
  case "$1" in
    amd64 | x86_64)
      printf 'amd64'
      ;;
    arm64 | aarch64)
      printf 'arm64'
      ;;
    *)
      printf '%s' "$1"
      ;;
  esac
}

check_image_arch_contract() {
  [ -n "$CONFORMANCE_ARCH" ] || return 0

  log "check image architecture"
  local expected_arch
  expected_arch="$(normalize_arch "$CONFORMANCE_ARCH")"

  local system_arch
  if command -v dpkg >/dev/null 2>&1; then
    system_arch="$(dpkg --print-architecture 2>/dev/null || true)"
  else
    system_arch="$(uname -m 2>/dev/null || true)"
  fi
  system_arch="$(normalize_arch "$system_arch")"
  [ "$system_arch" = "$expected_arch" ] || fail "system architecture is $system_arch, expected $expected_arch"

  if [ -n "${ARCH:-}" ]; then
    local image_arch
    image_arch="$(normalize_arch "$ARCH")"
    [ "$image_arch" = "$expected_arch" ] || fail "ARCH env is $ARCH, expected $expected_arch"
  fi
}

source_root_profiles() {
  set +u
  # shellcheck disable=SC1091
  [ -f /etc/profile ] && . /etc/profile || true
  if [ -d /etc/profile.d ]; then
    for profile_script in /etc/profile.d/*.sh; do
      # shellcheck disable=SC1090
      [ -r "$profile_script" ] && . "$profile_script" || true
    done
  fi
  # shellcheck disable=SC1091
  [ -f /root/.bashrc ] && . /root/.bashrc || true
  set -u
}

as_devbox() {
  local command_text="$1"
  local wrapped_command
  wrapped_command="$(printf 'bash -lc %q' "$command_text")"

  if command -v su >/dev/null 2>&1; then
    su - devbox -c "$wrapped_command"
    return
  fi

  if command -v runuser >/dev/null 2>&1; then
    runuser -l devbox -c "$wrapped_command"
    return
  fi

  fail "neither su nor runuser is available for devbox checks"
}

compare_file() {
  local expected="$1"
  local actual="$2"
  local label="$3"

  assert_file "$expected"
  assert_file "$actual"

  if ! cmp -s "$expected" "$actual"; then
    printf 'Expected %s to match %s\n' "$actual" "$expected" >&2
    if command -v diff >/dev/null 2>&1; then
      diff -u "$expected" "$actual" >&2 || true
    fi
    fail "$label mismatch"
  fi
}

check_devbox_user() {
  log "check devbox user"
  id devbox >/dev/null 2>&1 || fail "user devbox not found"
}

check_writable_by_devbox() {
  local path="$1"
  assert_dir "$path"
  as_devbox "test -w '$path' && touch '$path/.conformance-write' && rm -f '$path/.conformance-write'"
}

check_localized_readme() {
  local expected_readme="$REPO_ROOT/runtime-images/$RUNTIME_PATH/project-template/README.$L10N.md"
  local actual_readme="$PROJECT_DIR/README.md"

  log "check localized README"
  compare_file "$expected_readme" "$actual_readme" "localized README"

  if [ -e "$PROJECT_DIR/README.en_US.md" ] || [ -e "$PROJECT_DIR/README.zh_CN.md" ]; then
    fail "localized README source files should not remain in $PROJECT_DIR"
  fi

  local expected_guide="$REPO_ROOT/tooling/docs/README.s6-user-guide.$L10N.md"
  local actual_guide="$PROJECT_DIR/README.s6-user-guide.md"
  if [ -f "$expected_guide" ] && [ -f "$actual_guide" ]; then
    compare_file "$expected_guide" "$actual_guide" "localized s6 user guide"
  fi
}

check_common_project_runtime() {
  log "check common project runtime contract"
  assert_dir "$PROJECT_DIR"
  check_writable_by_devbox "$PROJECT_DIR"
  assert_file "$PROJECT_DIR/entrypoint.sh"
  check_localized_readme
}

check_no_root_owned_project_files() {
  local root_owned
  root_owned="$(find "$PROJECT_DIR" -xdev -user root -print -quit 2>/dev/null || true)"
  if [ -n "$root_owned" ]; then
    fail "root-owned file found under project after root entrypoint: $root_owned"
  fi
}

http_port_for_runtime() {
  case "$RUNTIME_PATH" in
    frameworks/nest.js/v11)
      printf '3000'
      ;;
    frameworks/openclaw/latest | frameworks/sandbox/*)
      printf ''
      ;;
    *)
      printf '8080'
      ;;
  esac
}

http_timeout_for_runtime() {
  case "$RUNTIME_PATH" in
    frameworks/nest.js/v11 | languages/net/*)
      printf '120'
      ;;
    languages/rust/*)
      printf '300'
      ;;
    *)
      printf '%s' "$HTTP_TIMEOUT"
      ;;
  esac
}

http_probe() {
  local port="$1"
  if command -v curl >/dev/null 2>&1; then
    curl -fsS --max-time 2 "http://127.0.0.1:$port/" >/tmp/conformance-http-probe.log 2>&1
    return
  fi
  if command -v wget >/dev/null 2>&1; then
    wget -q -T 2 -O /tmp/conformance-http-probe.log "http://127.0.0.1:$port/"
    return
  fi
  timeout 2 bash -c "cat < /dev/null > /dev/tcp/127.0.0.1/$port" >/tmp/conformance-http-probe.log 2>&1
}

wait_for_http() {
  local port="$1"
  local timeout_seconds="$2"
  local deadline=$((SECONDS + timeout_seconds))

  while [ "$SECONDS" -lt "$deadline" ]; do
    if http_probe "$port"; then
      return 0
    fi
    sleep 2
  done

  return 1
}

stop_entrypoint() {
  local pid="$1"
  if kill -0 "$pid" >/dev/null 2>&1; then
    kill -TERM "-$pid" >/dev/null 2>&1 || kill -TERM "$pid" >/dev/null 2>&1 || true
    sleep 2
  fi
  if kill -0 "$pid" >/dev/null 2>&1; then
    kill -KILL "-$pid" >/dev/null 2>&1 || kill -KILL "$pid" >/dev/null 2>&1 || true
  fi
  wait "$pid" >/dev/null 2>&1 || true
}

check_root_entrypoint_order() {
  case "$RUNTIME_PATH" in
    frameworks/sandbox/*)
      return 0
      ;;
  esac

  log "run entrypoint once as root"
  local entrypoint="$PROJECT_DIR/entrypoint.sh"
  local log_file="/tmp/conformance-root-entrypoint.log"
  local port
  port="$(http_port_for_runtime)"

  assert_file "$entrypoint"
  if ! command -v setsid >/dev/null 2>&1; then
    fail "setsid is required for root entrypoint process cleanup"
  fi

  setsid bash -lc "cd '$PROJECT_DIR' && bash '$entrypoint'" >"$log_file" 2>&1 &
  local pid=$!

  sleep "$STARTUP_SECONDS"
  if ! kill -0 "$pid" >/dev/null 2>&1; then
    local rc=0
    wait "$pid" >/dev/null 2>&1 || rc=$?
    printf '%s\n' "---- root entrypoint log ----" >&2
    cat "$log_file" >&2 || true
    fail "root entrypoint exited early with code $rc"
  fi

  if [ -n "$port" ]; then
    local timeout_seconds
    timeout_seconds="$(http_timeout_for_runtime)"
    if ! wait_for_http "$port" "$timeout_seconds"; then
      printf '%s\n' "---- root entrypoint log ----" >&2
      cat "$log_file" >&2 || true
      stop_entrypoint "$pid"
      fail "entrypoint did not serve HTTP on port $port within ${timeout_seconds}s"
    fi
  fi

  stop_entrypoint "$pid"
  check_no_root_owned_project_files
}

run_legacy_smoke_as_devbox() {
  local smoke_script="$REPO_ROOT/tests/runtime-smoke/$RUNTIME_PATH/smoke.sh"
  if [ ! -f "$smoke_script" ]; then
    log "no legacy smoke script for $RUNTIME_PATH"
    return 0
  fi

  log "run legacy smoke as devbox"
  cp "$smoke_script" /tmp/runtime-smoke.sh
  chmod 0755 /tmp/runtime-smoke.sh
  as_devbox "L10N='$L10N' SMOKE_DEBUG=1 bash /tmp/runtime-smoke.sh"
}

require_zh_npm_mirror() {
  [ "$L10N" = "zh_CN" ] || return 0
  log "check zh_CN npm mirror"
  assert_command npm
  npm config get registry | grep 'registry.npmmirror.com' >/dev/null || fail "root npm registry is not npmmirror"
  as_devbox "npm config get registry | grep 'registry.npmmirror.com' >/dev/null" || fail "devbox npm registry is not npmmirror"
}

require_zh_go_mirror() {
  [ "$L10N" = "zh_CN" ] || return 0
  log "check zh_CN Go proxy"
  assert_command go
  go env GOPROXY | grep '^https://goproxy.cn,direct$' >/dev/null || fail "root GOPROXY is not goproxy.cn,direct"
  as_devbox "go env GOPROXY | grep '^https://goproxy.cn,direct$' >/dev/null" || fail "devbox GOPROXY is not goproxy.cn,direct"
}

require_zh_pip_mirror() {
  [ "$L10N" = "zh_CN" ] || return 0
  log "check zh_CN pip mirror"
  assert_command pip3
  pip3 config list 2>/dev/null | grep 'mirrors.tuna.tsinghua.edu.cn/pypi/web/simple' >/dev/null || fail "root pip mirror is not Tsinghua"
  as_devbox "pip3 config list 2>/dev/null | grep 'mirrors.tuna.tsinghua.edu.cn/pypi/web/simple' >/dev/null" || fail "devbox pip mirror is not Tsinghua"
}

require_zh_maven_mirror() {
  [ "$L10N" = "zh_CN" ] || return 0
  log "check zh_CN Maven mirror"
  assert_file /home/devbox/.m2/settings.xml
  grep -q 'maven.aliyun.com/repository/public' /home/devbox/.m2/settings.xml || fail "devbox Maven mirror is not Aliyun"
}

require_zh_nuget_mirror() {
  [ "$L10N" = "zh_CN" ] || return 0
  log "check zh_CN NuGet mirrors"
  for config_file in /root/.nuget/NuGet/NuGet.Config /home/devbox/.nuget/NuGet/NuGet.Config; do
    assert_file "$config_file"
    grep -q 'mirrors.cloud.tencent.com/nuget' "$config_file" || fail "missing Tencent NuGet source in $config_file"
    if grep -q 'nuget.cdn.azure.cn' "$config_file"; then
      fail "unreachable Azure China NuGet source should not be configured in $config_file"
    fi
    if grep -q 'nuget.org' "$config_file"; then
      fail "nuget.org should be removed from $config_file for zh_CN"
    fi
  done
}

require_zh_composer_mirror() {
  [ "$L10N" = "zh_CN" ] || return 0
  log "check zh_CN Composer mirror"
  assert_command composer
  HOME=/root composer config -g repo.packagist | grep 'mirrors.aliyun.com/composer' >/dev/null || fail "root Composer packagist repo is not Aliyun"
  as_devbox "composer config -g repo.packagist | grep 'mirrors.aliyun.com/composer' >/dev/null" || fail "devbox Composer packagist repo is not Aliyun"
}

require_zh_php_apt_mirror() {
  [ "$L10N" = "zh_CN" ] || return 0
  log "check zh_CN PHP APT mirror"
  assert_file /etc/apt/sources.list.d/php.list
  grep -q 'mirrors.ustc.edu.cn/sury/php' /etc/apt/sources.list.d/php.list || fail "PHP APT source is not USTC"
}

require_zh_cargo_mirror() {
  [ "$L10N" = "zh_CN" ] || return 0
  log "check zh_CN Cargo mirror"
  for config_file in /root/.cargo/config.toml /home/devbox/.cargo/config.toml; do
    assert_file "$config_file"
    grep -q 'replace-with = "rsproxy-sparse"' "$config_file" || fail "missing crates.io replacement in $config_file"
    grep -q 'sparse+https://rsproxy.cn/index/' "$config_file" || fail "missing rsproxy sparse registry in $config_file"
  done
}

check_os_runtime() {
  local expected="$1"
  grep -qi "$expected" /etc/os-release || fail "expected $expected in /etc/os-release"
  assert_command busybox
}

check_cuda_runtime() {
  log "check CUDA runtime"
  if command -v nvcc >/dev/null 2>&1; then
    nvcc --version | grep 'release 12.4' >/dev/null || fail "nvcc is not CUDA 12.4"
    return
  fi
  if [ -d /usr/local/cuda ]; then
    return
  fi
  fail "CUDA runtime marker not found"
}

check_node_runtime() {
  local major="$1"
  assert_command node
  assert_command npm
  assert_command yarn
  assert_command pnpm
  node -e "process.exit(process.versions.node.split('.')[0] === '$major' ? 0 : 1)"
  require_zh_npm_mirror
}

check_go_runtime() {
  local version="$1"
  assert_command go
  go version | grep "go$version" >/dev/null || fail "Go version is not $version"
  if [ -n "$CONFORMANCE_ARCH" ]; then
    local expected_arch go_arch
    expected_arch="$(normalize_arch "$CONFORMANCE_ARCH")"
    go_arch="$(normalize_arch "$(go env GOARCH)")"
    [ "$go_arch" = "$expected_arch" ] || fail "Go GOARCH is $go_arch, expected $expected_arch"
  fi
  assert_file "$PROJECT_DIR/main.go"
  assert_executable "$PROJECT_DIR/hello_world"
  require_zh_go_mirror
  as_devbox "mkdir -p /home/devbox/go/cache/go-build && test -w /home/devbox/go/cache/go-build"
}

check_dotnet_runtime() {
  local major="$1"
  assert_command dotnet
  dotnet --version | grep "^$major\\." >/dev/null || fail ".NET version does not start with $major"
  assert_file "$PROJECT_DIR/hello_world.csproj"
  assert_file "$PROJECT_DIR/Program.cs"
  require_zh_nuget_mirror
}

check_php_runtime() {
  local major="$1"
  local minor="$2"
  assert_command php
  assert_command composer
  php -r "exit((PHP_MAJOR_VERSION==$major && PHP_MINOR_VERSION==$minor) ? 0 : 1);"
  assert_file "$PROJECT_DIR/hello_world.php"
  php -m | grep -i '^redis$' >/dev/null || fail "PHP redis extension not loaded"
  php -m | grep -i '^mongodb$' >/dev/null || fail "PHP mongodb extension not loaded"
  require_zh_php_apt_mirror
  require_zh_composer_mirror
}

check_python_runtime() {
  local major="$1"
  local minor="$2"
  assert_command python3
  assert_command pip3
  python3 -c "import sys; sys.exit(0 if sys.version_info[:2] == ($major, $minor) else 1)"
  assert_file "$PROJECT_DIR/hello.py"
  require_zh_pip_mirror
}

check_java_runtime() {
  assert_command java
  assert_command javac
  javac --version | grep 'javac 17' >/dev/null || fail "javac is not 17"
  java -version 2>&1 | grep '17' >/dev/null || fail "java is not 17"
  java -XshowSettings:properties -version 2>&1 | grep 'file.encoding = UTF-8' >/dev/null || fail "Java file.encoding is not UTF-8"
  assert_file "$PROJECT_DIR/HelloWorld.java"
  require_zh_maven_mirror
}

check_c_runtime() {
  assert_command gcc
  gcc --version | grep '12.2.0' >/dev/null || fail "gcc is not 12.2.0"
  assert_file "$PROJECT_DIR/hello_world.c"
}

check_cpp_runtime() {
  assert_command g++
  g++ --version | grep '12.2.0' >/dev/null || fail "g++ is not 12.2.0"
  assert_file "$PROJECT_DIR/hello_world.cpp"
}

check_rust_runtime() {
  assert_command rustc
  assert_command cargo
  rustc --version | grep '1.81.0' >/dev/null || fail "rustc is not 1.81.0"
  cargo --version | grep '1.81.0' >/dev/null || fail "cargo is not 1.81.0"
  assert_file "$PROJECT_DIR/Cargo.toml"
  assert_file "$PROJECT_DIR/src/main.rs"
  assert_executable "$PROJECT_DIR/target/release/hello_world"
  require_zh_cargo_mirror
}

check_nginx_runtime() {
  assert_command nginx
  /usr/sbin/nginx -v 2>&1 | grep '1.22.1' >/dev/null || fail "nginx is not 1.22.1"
  mkdir -p \
    /tmp/nginx-devbox/client-body \
    /tmp/nginx-devbox/proxy \
    /tmp/nginx-devbox/fastcgi \
    /tmp/nginx-devbox/uwsgi \
    /tmp/nginx-devbox/scgi
  rm -f /tmp/nginx-devbox.pid /tmp/nginx-devbox-error.log /tmp/nginx-devbox-access.log
  /usr/sbin/nginx -t -c /etc/nginx/nginx.conf >/dev/null 2>&1 || fail "nginx config test failed"
  rm -f /tmp/nginx-devbox.pid /tmp/nginx-devbox-error.log /tmp/nginx-devbox-access.log
  grep -q '/tmp/nginx-devbox' /etc/nginx/nginx.conf || fail "nginx runtime paths should use /tmp/nginx-devbox"
  if grep -q 'include /etc/nginx/conf.d' /etc/nginx/nginx.conf || grep -q 'include /etc/nginx/sites-enabled' /etc/nginx/nginx.conf; then
    fail "nginx config should not include distro default sites"
  fi
}

check_nest_runtime() {
  check_node_runtime 20
  assert_command nest
  assert_file "$PROJECT_DIR/package.json"
  assert_file "$PROJECT_DIR/dist/main.js"
}

check_openclaw_runtime() {
  check_node_runtime 22
  assert_command openclaw
  assert_command clawhub
  assert_command bun
  assert_file "$PROJECT_DIR/.env.example"
  assert_file "$PROJECT_DIR/openclaw.json"
  assert_file /home/devbox/.openclaw/openclaw.json
  if grep -Eq '<[A-Z0-9_]+>' "$PROJECT_DIR/.env.example"; then
    fail ".env.example should not contain shell-unsafe placeholder values"
  fi
  as_devbox "cd '$PROJECT_DIR' && set -a && . ./.env.example && set +a"
}

check_sandbox_runtime() {
  log "check sandbox runtime contract"
  check_devbox_user
  assert_dir "$WORKSPACE_DIR"
  check_writable_by_devbox "$WORKSPACE_DIR"
  assert_executable /usr/local/bin/codex-gateway
  assert_command codex
  assert_command node
  assert_command npm
  assert_command python3
  assert_command pip3
  assert_command kubectl
  assert_command helm
  assert_command bun
  assert_command rg
  assert_command bwrap
  assert_file /etc/s6-overlay/s6-rc.d/codex-gateway/run
  if [ "$RUNTIME_PATH" = "frameworks/sandbox/fastgpt" ]; then
    assert_executable /usr/local/bin/fastgpt-ide-agent
    assert_file /etc/s6-overlay/s6-rc.d/fastgpt-ide-agent/run
    assert_file /etc/s6-overlay/s6-rc.d/fastgpt-ide-agent/finish
  fi
  require_zh_npm_mirror
  require_zh_pip_mirror
}

check_runtime_specifics() {
  log "check runtime-specific contract"
  case "$RUNTIME_PATH" in
    operating-systems/anolis/23.4)
      check_os_runtime anolis
      ;;
    operating-systems/debian/12.6)
      check_os_runtime debian
      ;;
    operating-systems/ubuntu/22.04)
      check_os_runtime ubuntu
      ;;
    operating-systems/kylin/v10-sp3)
      check_os_runtime kylin
      ;;
    operating-systems/ubuntu-cuda/12.4.1)
      check_os_runtime ubuntu
      check_cuda_runtime
      ;;
    languages/c/gcc-12.2.0)
      check_c_runtime
      ;;
    languages/cpp/gcc-12.2.0)
      check_cpp_runtime
      ;;
    languages/go/1.22.5)
      check_go_runtime 1.22.5
      ;;
    languages/go/1.23.0)
      check_go_runtime 1.23.0
      ;;
    languages/java/openjdk17)
      check_java_runtime
      ;;
    languages/net/8.0)
      check_dotnet_runtime 8
      ;;
    languages/net/10.0)
      check_dotnet_runtime 10
      ;;
    languages/node.js/18)
      check_node_runtime 18
      assert_file "$PROJECT_DIR/hello_world.js"
      ;;
    languages/node.js/20)
      check_node_runtime 20
      assert_file "$PROJECT_DIR/hello_world.js"
      ;;
    languages/node.js/22)
      check_node_runtime 22
      assert_file "$PROJECT_DIR/hello_world.js"
      ;;
    languages/php/7.4)
      check_php_runtime 7 4
      ;;
    languages/php/8.2)
      check_php_runtime 8 2
      ;;
    languages/python/3.10)
      check_python_runtime 3 10
      ;;
    languages/python/3.11)
      check_python_runtime 3 11
      ;;
    languages/python/3.12)
      check_python_runtime 3 12
      ;;
    languages/rust/1.81.0)
      check_rust_runtime
      ;;
    frameworks/nest.js/v11)
      check_nest_runtime
      ;;
    frameworks/nginx/1.22.1)
      check_nginx_runtime
      ;;
    frameworks/openclaw/latest)
      check_openclaw_runtime
      ;;
    frameworks/sandbox/v1 | frameworks/sandbox/fastgpt)
      check_sandbox_runtime
      ;;
    *)
      fail "no conformance checks registered for $RUNTIME_PATH"
      ;;
  esac
}

main() {
  source_root_profiles
  print_runtime_context

  case "$RUNTIME_PATH" in
    frameworks/sandbox/*)
      check_runtime_specifics
      log "conformance ok"
      return 0
      ;;
  esac

  check_image_arch_contract
  check_devbox_user
  check_common_project_runtime
  check_runtime_specifics
  check_root_entrypoint_order
  run_legacy_smoke_as_devbox

  log "conformance ok"
}

main "$@"

#!/bin/bash
chmod +x runtimectl
TMP_FILE=$(mktemp)

kubectl get runtime -n devbox-system > "$TMP_FILE"

mapfile -t runtime_lines < "$TMP_FILE"

for line in "${runtime_lines[@]:1}"; do
  read -r namespace name class version runtime_version state <<< "$line"

    if [[ -z "$class" ]]; then
      continue
    fi

    if [[ -z "$state" ]]; then
      state=$runtime_version
      runtime_version=""
    fi

    if [ "$state" = "active" ];
      read class version image < <(kubectl get runtime $name -n devbox-system -o json | jq -r 'select(.spec.state == "active") | [.spec.classRef, .spec.version, .spec.config.image] | @tsv')
      read kind < <(kubectl get runtimeclass.devbox "$class" -n devbox-system -o json | jq -r '.spec.kind')
      ./runtimectl gen --kind=$kind --name=$class --version=$version --image=$image --path=$1
    fi
done


rm "$TMP_FILE"

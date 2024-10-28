#!/bin/bash
TMP_FILE=$(mktemp)

kubectl get runtime -A > "$TMP_FILE"

mapfile -t runtime_lines < "$TMP_FILE"

declare -A max_versions
declare -A runtime_map

for line in "${runtime_lines[@]:1}"; do
    read -r namespace name class version runtime_version state <<< "$line"

    if [[ -z "$class" ]]; then
        continue
    fi

    if [[ -z "$state" ]]; then
        state=$runtime_version
        runtime_version=""
    fi

    key="$class:$version"

    if [[ -z "${max_versions[$key]}" ]] || [[ "$runtime_version" > "${max_versions[$key]}" ]]; then
        max_versions["$key"]="$runtime_version"
    fi

    runtime_map["$key"]+="$namespace $name $state $runtime_version"$'\n'
done

for key in "${!runtime_map[@]}"; do
    latest_version="${max_versions[$key]}"
    echo "Latest version for $key is $latest_version"
    while IFS= read -r runtime_info; do
        read -r namespace name  state runtime_version  <<< "$runtime_info"
        if [[ -z "$namespace" ]]; then
            continue
        fi
        if [[ -z "$runtime_version" && -n "$latest_version" && "$state" != "deprecated" ]]; then
            echo "Updating state to deprecated for $namespace/$name (runtime version is empty)"
            kubectl patch runtime -n "$namespace" "$name" --type='json' -p='[{"op": "replace", "path": "/spec/state", "value": "deprecated"}]'
        elif [[ "$runtime_version" != "$latest_version" && "$state" != "deprecated" ]]; then
            echo "Updating state to deprecated for $namespace/$name ($runtime_version)"
            kubectl patch runtime -n "$namespace" "$name" --type='json' -p='[{"op": "replace", "path": "/spec/state", "value": "deprecated"}]'
        fi
    done <<< "${runtime_map[$key]}"
done

rm "$TMP_FILE"
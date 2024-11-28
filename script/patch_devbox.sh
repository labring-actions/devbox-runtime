#!/bin/bash
chmod +x runtimectl
TMP_FILE=$(mktemp)

kubectl get devbox -A > "$TMP_FILE"

mapfile -t runtime_lines < "$TMP_FILE"

for line in "${runtime_lines[@]:1}"; do
  read -r  namespce name state class network port phase <<< "$line"

    if [[ -z "$class" ]]; then
      continue
    fi

    if [[ -z "$state" ]]; then
      state=$runtime_version
      runtime_version=""
    fi

    if
    read class version < <(kubectl get runtime $class -n devbox-system -o json | jq -r '[.spec.classRef, .spec.version] | @tsv')
    id =jq '.["$class"-"$version"]' output.json
    read templateID < <(kubectl get devbox $name -n $namespace -o json | jq -r '.spec.templateID')
    kubectl patch devbox $name -n $namespace --type='json' -p='[{"op": "add", "path": "/spec/templateID", "value": "$id"}]'
    fi

done

rm "$TMP_FILE"

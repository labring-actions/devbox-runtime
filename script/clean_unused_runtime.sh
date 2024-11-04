#!/bin/bash

REFERENCED_RUNTIMES="referenced_runtimes.txt"
DEPRECATED_RUNTIMES="deprecated_runtimes.txt"

kubectl get devbox -A -o json | jq -r '.items[].spec.runtimeRef.name' | sort | uniq > "$REFERENCED_RUNTIMES"
kubectl get runtime -A -o json | jq -r '.items[] | select(.spec.state == "deprecated") | .metadata.name' | sort | uniq > "$DEPRECATED_RUNTIMES"

UNREFERENCED_RUNTIMES=$(comm -13 "$REFERENCED_RUNTIMES" "$DEPRECATED_RUNTIMES")

echo "未被引用的 deprecated runtime:"
echo "$UNREFERENCED_RUNTIMES"

if [ ! -z "$UNREFERENCED_RUNTIMES" ]; then
    echo "正在删除未被引用的 deprecated runtime..."
    for runtime in $UNREFERENCED_RUNTIMES; do
        kubectl delete runtime "$runtime" --all-namespaces
    done
else
    echo "没有未被引用的 deprecated runtime 需要删除。"
fi

rm "$REFERENCED_RUNTIMES" "$DEPRECATED_RUNTIMES"
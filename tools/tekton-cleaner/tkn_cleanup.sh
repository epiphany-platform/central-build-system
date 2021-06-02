#!/bin/bash

WEEKS_TO_KEEP=$1
echo "All the tekton pipeline objects older than $WEEKS_TO_KEEP weeks (if any) will be removed from below listed namespaces:"

for nsp in $(/usr/local/bin/tkn pipelinerun list --all-namespaces | awk -v WTK=$WEEKS_TO_KEEP '/weeks/ && $3> WTK {print $1}' | sort | uniq); do
    echo "$nsp: "
    /usr/local/bin/tkn pipelinerun list -n $nsp | awk -v WTK=$WEEKS_TO_KEEP '/weeks/ && $2> WTK {print $1}' |  xargs --no-run-if-empty -I{} /usr/local/bin/tkn pipelinerun delete -n $nsp {}
done

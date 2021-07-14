#!/bin/bash

set -e

mkdir -p backup

if [ -z "${HARBOR_NS}" ]
then
  echo 'env variable $HARBOR_NS was not set so to "harbor"'
  HARBOR_NS=harbor
fi

echo "Dump harbor database"
kubectl exec -n $HARBOR_NS -i harbor-harbor-database-0 -- pg_dump --format=c registry > backup/registry.dump
kubectl exec -n $HARBOR_NS -i harbor-harbor-database-0 -- pg_dump --format=c notarysigner > backup/notarysigner.dump
kubectl exec -n $HARBOR_NS -i harbor-harbor-database-0 -- pg_dump --format=c notaryserver > backup/notaryserver.dump

###ArgoCD part
if [ -z "${ARGO_NS}" ]
then
  echo 'env variable $RGO_NS was not set so to "argocd"'
  ARGO_NS=argocd
fi

echo "Dump argocd config"
ARGO_POD=$(kubectl get pod -n $ARGO_NS -l app.kubernetes.io/name=argocd-server -o jsonpath="{.items[0].metadata.name}")
kubectl exec -i -n $ARGO_NS $ARGO_POD -- argocd-util export > backup/argocd.backup

echo "Dump tekton objects"
NAMESPACES=$(kubectl get -o json namespaces|jq '.items[].metadata.name'|sed "s/\"//g")
RESOURCES="clustertasks.tekton.dev \
           conditions.tekton.dev \
           extensions.dashboard.tekton.dev \
           pipelineresources.tekton.dev \
           pipelines.tekton.dev \
           tasks.tekton.dev \
           triggerbindings.triggers.tekton.dev \
           triggers.triggers.tekton.dev \
           triggertemplates.triggers.tekton.dev \
           eventlisteners.triggers.tekton.dev \
           clustertriggerbindings.triggers.tekton.dev"

for ns in ${NAMESPACES};do
  for resource in ${RESOURCES};do
    rsrcs=$(kubectl -n ${ns} get -o json ${resource}|jq '.items[].metadata.name'|sed "s/\"//g")
    for r in ${rsrcs};do
      dir="backup/${ns}/${resource}"
      mkdir -p "${dir}"
      kubectl -n ${ns} get -o yaml ${resource} ${r} > "${dir}/${r}.yaml"
    done
  done
done

echo "Dump tekton role and rolebinding object definitions"
NAMESPACES="tekton-pipelines"
RESOURCES=$(kubectl api-resources --verbs=list --namespaced -o name | grep role | xargs -n 1 kubectl get --show-kind --ignore-not-found -n  tekton-pipelines | awk '{print $1}' | grep -v NAME)

for ns in ${NAMESPACES};do
  for resource in ${RESOURCES};do
    dir="backup/${ns}"
    mkdir -p "${dir}"
    resource_path=$(echo $resource | sed "s/\//_/g")
    kubectl -n ${ns} get -o yaml ${resource} > "${dir}/${resource_path}.yaml"
  done
done


if [ -z "${STORAGE}" ]  && [ -z "${CONATINER}" ]
then
  echo 'env $STORAGE and $CONATINER are not set so your backup will be kept only locally'
  echo 'If you want to keep your backup in Azure blob please properly set $STORAGE and $CONTAINER env variables'
  echo "Press any key to continue"
  read a
else
  echo "Upload backup to $STORAGE"
  LINK="https://$STORAGE.blob.core.windows.net/$CONTAINER/`date +%F`/$SAS"
  azcopy copy --recursive ./backup/ $LINK
fi

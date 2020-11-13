#!/bin/bash
set -e

rg_name=$(az group list | grep "\"name\": \"MC_$1" | awk -F ':' '{print $2}' | tr -d '"' | tr -d ' ' | tr -d ',')
k8s_host=$(echo $2 | awk -F ':' '{print $2}' | awk -F '.' '{print $2"."$3"."$4"."$5"."$6}')
k8s_ip=$(az network private-dns record-set a list -g $rg_name -z $k8s_host | grep "ipv4Address" | awk -F '"' '{print $4}')
k8s_name=$(az network private-dns record-set a list -g $rg_name -z $k8s_host | grep "name" | awk -F '"' '{print $4}')

echo "sudo sh -c 'echo \"$k8s_ip $k8s_name.$k8s_host\" >> /etc/hosts'"

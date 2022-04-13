#!/bin/bash
set -x -e

if [ "x$1" == "x" ]
then
  name="gandalf"
else
  name=$1
fi
clustername="$name-cluster"

civo kubernetes delete ${clustername} --yes
#civo firewall delete ${clustername} --yes
kubectl ctx k3d-gitops
kubectl config delete-context ${clustername}
kubectl config delete-cluster ${clustername}
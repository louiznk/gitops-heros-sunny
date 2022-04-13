#!/bin/bash
set -e
DIR=$(dirname "$0")
pushd $DIR

set -x
kubectl konfig export $(kubectl config current-context)| sed "s/server:.*/server: https:\/\/kubernetes.default:443/g" > kubeconfig.local
{ set +x; } 2> /dev/null # silently disable xtrace

echo "Create kubeconfig for local runner in kubeconfig.local"
xclip -sel clip < kubeconfig.local

cat kubeconfig.local

popd
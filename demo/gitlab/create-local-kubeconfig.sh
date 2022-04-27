#!/bin/bash
set -e
txtrst=$(tput sgr0) # Text reset
txtred=$(tput setaf 1) # Red
txtblu=$(tput setaf 4) # Blue

DIR=$(dirname "$0")
pushd $DIR

echo "${txtblu}This script create a kubeconfig file for local runner in kubeconfig.local${txtrst}"

set -x
kubectl konfig export $(kubectl config current-context)| sed "s/server:.*/server: https:\/\/kubernetes.default:443/g" > kubeconfig.local
{ set +x; } 2> /dev/null # silently disable xtrace

echo ""
echo "set var ${txtred}KUBECONFIG_FILE${txtrst} with this on gitlab group"
echo "🔗 - https://gitlab.com/groups/gitops-heros/-/settings/ci_cd"
echo ""
xclip -sel clip < kubeconfig.local

cat kubeconfig.local

popd



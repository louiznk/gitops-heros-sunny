#!/bin/bash
# Mettre à jour le token dans le fichier values.yaml (à partir de https://gitlab.com/groups/gitops-heros/-/settings/ci_cd)
# Ou utiliser l'arg
# Installation https://docs.gitlab.com/runner/install/kubernetes.html
. demo-magic.sh
set -e
DIR=$(dirname "$0")
pushd $DIR
clear

if [ -z "$1" ]
then
    echo "⚠️ - Pass the registration token as arg"
    echo "🔗 - https://gitlab.com/groups/gitops-heros/-/runners"
    flatpak run org.chromium.Chromium https://gitlab.com/groups/gitops-heros/-/runners 2> /dev/null &
    exit 1
fi


EXIST=$(helm repo list | grep "gitlab.*https://charts.gitlab.io" | wc -l)
if [ "x$EXIST" = "x1" ]
then
    ps1;pei "helm repo update gitlab"
else
    prompt "Add gitlab helm chart repo"    
    pe "helm repo add gitlab https://charts.gitlab.io"
fi


EXIST=$(helm ls -n gitlab-runner | grep "gitlab-runner" | wc -l)
if [ "x$EXIST" = "x1" ]
then
    echo "Deleting the runner already installed for update"
    helm delete gitlab-runner -n gitlab-runner
fi

prompt "🏗️ - Deploying the GitLab Runner"
pe "helm install --create-namespace --namespace gitlab-runner gitlab-runner -f values.yaml --set \"runnerRegistrationToken=$1\" gitlab/gitlab-runner --wait"

popd

echo "Go gitlab now and set variable KUBECONFIG_FILE"
echo "🔗 - https://gitlab.com/groups/gitops-heros/-/runners"

flatpak run org.chromium.Chromium https://gitlab.com/groups/gitops-heros/-/runners &> /dev/null &

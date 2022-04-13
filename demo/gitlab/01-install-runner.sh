#!/bin/bash
# Mettre à jour le token dans le fichier values.yaml (à partir de https://gitlab.com/groups/gitops-heros/-/settings/ci_cd)
# Ou utiliser l'arg
# Installation https://docs.gitlab.com/runner/install/kubernetes.html
set -e
DIR=$(dirname "$0")
pushd $DIR

if [ -z "$1" ]
then
    echo "⚠️ Pass the registration token as arg"
    echo "🔗 https://gitlab.com/groups/gitops-heros/-/settings/ci_cd"
    chromium https://gitlab.com/groups/gitops-heros/-/settings/ci_cd > /dev/null
    exit 1
fi


EXIST=$(helm repo list | grep "gitlab.*https://charts.gitlab.io" | wc -l)
if [ "x$EXIST" = "x1" ]
then
    helm repo update gitlab
else
    set +x
    helm repo add gitlab https://charts.gitlab.io
    { set +x; } 2> /dev/null # silently disable xtrace
fi


EXIST=$(helm ls -n gitlab-runner | grep "gitlab-runner" | wc -l)
if [ "x$EXIST" = "x1" ]
then
    echo "Deleting the runner already installed for update"
    helm delete gitlab-runner -n gitlab-runner
fi

echo "🏗️ Deploying the GitLab Runner"
set +x
helm install --create-namespace --namespace gitlab-runner gitlab-runner -f values.yaml --set "runnerRegistrationToken=$1" gitlab/gitlab-runner --wait

{ set +x; } 2> /dev/null # silently disable xtrace
popd

echo "Go gitlab now"
echo "🔗 https://gitlab.com/groups/gitops-heros/-/settings/ci_cd"

chromium https://gitlab.com/groups/gitops-heros/-/settings/ci_cd > /dev/null
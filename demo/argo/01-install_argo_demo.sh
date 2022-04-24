#!/bin/bash
# echo "****************************************************************************************************"
# echo "Before you need to manually install argocli"
# echo "First install argocli"
# echo "VERSION=$(curl --silent \"https://api.github.com/repos/argoproj/argo-cd/releases/latest\" | grep '\"tag_name\"' | sed -E 's/.*"([^\"]+)\".*/\1/')"
# echo "curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64"
# echo "chmod +x argocd"
# echo "sudo mv argocd /usr/local/bin/argocd"
# echo "----------------------------------------------------------------------------------------------------"

## 
. demo-magic.sh

set -e

DIR=$(dirname "$0")

pushd $DIR

clear

if [ -z "$IP" ]
then
    ## GET IP
    if [ "x$1" == "x" ]
    then
        context=$(kubectl config current-context)
    else
        context=$1
    fi
    CLUSTER_IP=$(kubectl konfig export -k ~/.kube/config $context | yq eval '.clusters.[0].cluster.server' - | cut -d'/' -f3 | cut -d":" -f1)
    if [ "x0.0.0.0" == "x$CLUSTER_IP" ]
    then
        echo "Local cluster 127.0.0.1"
        export IP="127.0.0.1"
    else
        echo "Remote cluster $CLUSTER_IP"
        export IP=$CLUSTER_IP
    fi
fi
# change ip
echo "Configure the ingress using the ip => argocd.$IP.sslip.io"
cat 1-ingress.tpl | envsubst > 1-ingress.yml

NS_ARGO_EXIST=$(kubectl get ns -o json | jq -r '.items[] | select(.metadata.name == "argocd") | has("kind")')
if [ "true" != "$NS_ARGO_EXIST" ]
then
    prompt "Create namespace for argocd"
    pei "kubectl create namespace argocd"
fi

prompt "🏗️ - Installing Argo CD"
pe "kubectl apply -n argocd -f 0-install-2.1.5.yml"

prompt "🕸️ - Exposing Argo CD dashboard"
pe "kubectl apply -n argocd -f 1-ingress.yml"

echo ""
echo "🔗 - https://argocd.$IP.sslip.io"
echo -n "⏳ - Waiting for argocd to be ready "
# pod
while [ "0" != "$(kubectl get pod -n argocd -o json | jq -r '.items[] | select(.status.phase != "Running") | has("kind")' | wc -l)" ]; do echo -n "."; sleep 1; done
# secret
while [ "" == "$(kubectl get secret -n argocd -o json | jq -r '.items[] | select(.metadata.name == "argocd-initial-admin-secret") | has("kind")')" ]; do echo -n "."; sleep 1; done

# Wait argp realy ok 
x=1
HTTP_STATUS=418
while [[ $x -le 30 && "x$HTTP_STATUS" != "x200" ]]
do
  echo -n "."
  x=$(( $x + 1 ))
  sleep 1
  HTTP_STATUS=$(curl -s -o /dev/null -I -w "%{http_code}" -k https://argocd.$IP.sslip.io)
done
echo " ✅"

echo;echo -e -n "[${Green}${WHO}@${HOST}${Color_Off} ~ ${Blue}$(date +'%T')${Color_Off}]# \$${BWhite} export PASS=\$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d)${Color_Off}"
echo ""

export PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

prompt "🙊 - Login to argocd, the password is $PASS (from argocd-initial-admin-secret)"
# The initial password is set in a kubernetes secret, named argocd-secret, during ArgoCD's initial start up with the name of the pod of argocd-server
# waiting...
pe "argocd login \
--insecure \
--username admin \
--password $PASS \
--grpc-web \
argocd.$IP.sslip.io"

prompt "🤢 - Change echo old password $PASS with demo password : <argodemo>, don't do this it's bad !"
pei "argocd account update-password --current-password $PASS --new-password argodemo"

popd

flatpak run org.chromium.Chromium --incognito https://argocd.$IP.sslip.io 2>/dev/null &
#!/bin/bash
. demo-magic.sh

set -e
txtrst=$(tput sgr0) # Text reset
txtred=$(tput setaf 1) # Red
txtblu=$(tput setaf 4) # Blue

DIR=$(dirname "$0")
pushd $DIR

clear

if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <secret-name> <namespace> <clef> <value>" >&2
  exit 1
fi


if [ ! -f public-cert.pem ]; then
  echo "🪲 You need the public cert first, I do it for you lucky boy"
  ./02-get-public-cert.sh
fi

prompt "👮 - Generate secret $3=$4"
#echo "kubectl create secret generic $1 -n $2 --dry-run=client --from-literal=$3=$4 -o yaml "
mkdir -p generated

pe "kubectl create secret generic $1 -n $2 --dry-run=client --from-literal=$3=\"$4\" -o yaml > ./generated/secret.yaml"
ps1;pei "cat ./generated/secret.yaml"

prompt "🔐 - Generate sealedsecret (Strict)"
pe "kubeseal --format yaml --cert public-cert.pem < ./generated/secret.yaml > ./generated/sealedsecret-strict.yaml"

prompt "🔐 - Generate sealedsecret (Namespace-wide)"
pe "kubeseal --format yaml --scope namespace-wide --cert public-cert.pem < ./generated/secret.yaml > ./generated/sealedsecret-namespace-wide.yaml"

prompt "🔐 - Generate sealedsecret (Cluster-wide)"
pe "kubectl create secret generic $1 --dry-run=client --from-literal=$3=\"$4\" -o yaml | kubeseal --format yaml --scope cluster-wide --cert public-cert.pem  ./generated/sealedsecret-cluster-wide.yaml > ./generated/sealedsecret-cluster-wide.yaml"


echo ""
echo "🔐 ${txtblu}Generate secrets in $(pwd)/generated/${txtrst}"
echo " - Strict         : sealedsecret-strict.yaml"
echo " - Namespace-wide : sealedsecret-namespace-wide.yaml"
echo " - Cluster-wide   : sealedsecret-cluster-wide.yaml"
popd


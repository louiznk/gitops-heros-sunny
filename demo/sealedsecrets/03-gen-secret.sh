#!/bin/bash
set -e
txtrst=$(tput sgr0) # Text reset
txtred=$(tput setaf 1) # Red
txtblu=$(tput setaf 4) # Blue

if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <secret-name> <namespace> <clef> <value>" >&2
  exit 1
fi
DIR=$(dirname "$0")
pushd $DIR

if [ ! -f public-cert.pem ]; then
  echo "🪲 You need the public cert first, I do it for you lucky boy"
  ./02-get-public-cert.sh
fi

echo "👮 Generate secret $3=$4"
#echo "kubectl create secret generic $1 -n $2 --dry-run=client --from-literal=$3=$4 -o yaml "
mkdir -p generated
set -x
kubectl create secret generic $1 -n $2 --dry-run=client --from-literal=$3="$4" -o yaml > ./generated/secret.yaml

kubeseal --format yaml --cert public-cert.pem < ./generated/secret.yaml > ./generated/sealedsecret-strict.yaml

kubeseal --format yaml --scope namespace-wide --cert public-cert.pem < ./generated/secret.yaml > ./generated/sealedsecret-namespace-wide.yaml

kubectl create secret generic $1 --dry-run=client --from-literal=$3="$4" -o yaml | kubeseal --format yaml --scope cluster-wide --cert public-cert.pem  ./generated/sealedsecret-cluster-wide.yaml > ./generated/sealedsecret-cluster-wide.yaml 

{ set +x; } 2> /dev/null # silently disable xtrace

echo "🔐 ${txtblu}Generate secrets in $(pwd)/generated/${txtrst}"
echo " - Strict         : sealedsecret-strict.yaml"
echo " - Namespace-wide : sealedsecret-namespace-wide.yaml"
echo " - Cluster-wide   : sealedsecret-cluster-wide.yaml"
popd


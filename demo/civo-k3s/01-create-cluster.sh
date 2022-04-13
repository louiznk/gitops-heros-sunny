#!/bin/bash
# TODO see size g3.k3s.large"
# --remove-applications=Traefik 
#civo kubernetes create ${clustername} --size "g3.k3s.medium" --nodes 2 --create-firewall "" --wait --save --region LON1
# the --version "1.21.2+k3s1" doesn't work... using the older with Traefik 2.5 (manual)
# -a "Traefik-v2" 
# --version "1.21.2+k3s1"
set -e
DIR=$(dirname "$0")
pushd $DIR

echo "🏗️ Creating the cluster"
set -x

if [ "x$1" == "x" ]
then
  name="gandalf"
else
  name=$1
fi
clustername="$name-cluster"

# using existing firewall
civo k3s create ${clustername} --remove-applications=Traefik --existing-firewall kube-firewall --size "g3.k3s.medium" --nodes 2 --wait --save --yes

#civo kubernetes create ${clustername} --size "g3.k3s.medium" --nodes 2 -r "Traefik" --region "LON1" --wait --save --yes 

#civo k3s create ${clustername} --version "1.21.2+k3s1" --size "g3.k3s.medium" --nodes 1 --region "LON1" -r "Traefik" --remove-applications="Traefik" --remove-applications "Traefik" --wait --save --yes


civo kubernetes config ${clustername} > kube-config-$name.yaml

kubectl konfig merge /home/louis/.k3d/kubeconfig-gitops.yaml $(pwd)/kube-config-$name.yaml -p > ~/.kube/config

chmod 600 ~/.kube/config

kubectl ctx ${clustername}

export KUBECONFIG=$(pwd)/kube-config-$name.yaml

# need krew install ctx
#kubectl ctx ${clustername}

kubectl version
kubectl cluster-info



## Don't use traefik 2.3 -a "Traefik-v2" (missing right for argocd)
# <!> for using custom traefik => uninstall helm traefik before `helm uninstall traefik -n kube-system`
{ set +x; } 2> /dev/null # silently disable xtrace

## wait for coredns
echo "⏳ Waiting for CoreDNS to be ready"
kubectl wait deployment coredns -n kube-system --timeout=-1s --for condition=available
while [ "1" != $(kubectl get deployment coredns -n kube-system -o=custom-columns=READY:.status.readyReplicas --no-headers) ]
do
    printf "."
    sleep 1
done
echo " ✅"
echo "CoreDNS is Ready"


echo "🚦 Install Traefik 2.5"
set -x
kubectl apply -f ./traefik/ --wait

{ set +x; } 2> /dev/null # silently disable xtrace
IP=$(cat kube-config-$name.yaml | yq eval '.clusters.[0].cluster.server' - | cut -d'/' -f3 | cut -d":" -f1)
echo "📮 IP du cluster $IP"

echo "Call ../apps-repos/change-ip.sh $IP"

# Remove this...
helm ls -n kube-system 2>/dev/null
helm uninstall traefik -n kube-system 2>/dev/null

echo "⏳ Waiting for Traefik to be ready"
kubectl wait deployment traefik-ingress-controller -n kube-system --timeout=-1s --for condition=available
while [ "1" != $(kubectl get deployment traefik-ingress-controller -n kube-system -o=custom-columns=READY:.status.readyReplicas --no-headers) ]
do
    printf "."
    sleep 1
done
echo " ✅"
popd

#!/bin/bash
set -
DIR=$(dirname "$0")
pushd $DIR

echo "****************************************************************************************************"
echo "Before you need to manually install k3d, kubectl and helm (we assume you have docker and git)"
echo "First install k3d v4.4.8"
echo "curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | TAG=v3.3.0 bash"
echo "----------------------------------------------------------------------------------------------------"
echo "And then install kubect"
echo "> For linux"
echo "curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
echo "chmod 775 kubectl && sudo mv kubectl /usr/local/bin/kubectl"
echo "> For mac"
echo "brew install kubectl"

unset REGISTRY CNI
while getopts 'rcph' opts
do
  case $opts in
    r) REGISTRY="--volume $(pwd)/registries/k3s-config/registries.yaml:/etc/rancher/k3s/registries.yaml";;
    c) CNI="--k3s-server-arg --flannel-backend=none";;
    p) PRELOAD=1;;
    h) echo "Help:"; echo "[-c] : option for calico as CNI"; echo "[-r] : option for define registries with $(pwd)/registries/k3s-config/registries.yaml"; echo "[-p] : option for preloading docker images (great if network is low)"; echo "and last arg is the cluster name"; exit 2;;
  esac
done


shift $((OPTIND-1))

if [ "x$1" == "x" ]
then
  clustername="gitops"
else
  clustername=$1
fi
# --volume "$(pwd)/registries/k3s-config/registries.yaml:/etc/rancher/k3s/registries.yaml"
echo "****************************************************************************************************"
#--image rancher/k3s:v1.20.10-k3s1
#--image "rancher/k3s:v1.21.11-k3s1" \
mkdir -p "$HOME/srv/k3d/${clustername}"

echo "🏗️ Creating the cluster"
set -x
k3d cluster create "${clustername}" --port "80:80@server[0]" --port "443:443@server[0]" \
--servers 1 \
--agents 1 \
--k3s-server-arg "--no-deploy=traefik" $CNI \
--k3s-server-arg  '--kubelet-arg=eviction-hard=imagefs.available<1%,nodefs.available<1%' --k3s-server-arg  '--kubelet-arg=eviction-minimum-reclaim=imagefs.available=1%,nodefs.available=1%' \
--k3s-agent-arg  '--kubelet-arg=eviction-hard=imagefs.available<1%,nodefs.available<1%' --k3s-agent-arg  '--kubelet-arg=eviction-minimum-reclaim=imagefs.available=1%,nodefs.available=1%' \
--no-lb ${REGISTRY} \
--volume "$HOME/srv/k3d/${clustername}/default:/opt/local-path-provisioner/default" \
--image "rancher/k3s:v1.22.9-k3s1" \
--wait

export KUBECONFIG="$(k3d kubeconfig merge ${clustername})"

kubectl version
kubectl cluster-info

{ set +x; } 2> /dev/null # silently disable xtrace
# Install calico (instead of flannel)
if [ "$CNI" ]; then
    echo "Install Calico as CNI"
    kubectl apply -f calico/calico.yaml
fi


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

echo "****************************************************************************************************"
echo "Set taint and label (if not done)"
kubectl taint nodes "k3d-$clustername-server-0"  node-role.kubernetes.io/master=effect:NoSchedule
kubectl label node "k3d-$clustername-server-0" kubernetes.io/role=master
kubectl label node "k3d-$clustername-agent-0" node-role.kubernetes.io/worker=worker

echo "****************************************************************************************************"
echo "🚦 Install Traefik 2.5"
set -x
kubectl apply -f ./traefik/ --wait
{ set +x; } 2> /dev/null # silently disable xtrace

IP='127.0.0.1'
echo "📮 IP du cluster $IP"

echo "Call ../apps-repos/change-ip.sh $IP"

echo "⏳ Waiting for Traefik to be ready"
kubectl wait deployment traefik-ingress-controller -n kube-system --timeout=-1s --for condition=available
while [ "1" != $(kubectl get deployment traefik-ingress-controller -n kube-system -o=custom-columns=READY:.status.readyReplicas --no-headers) ]
do
    printf "."
    sleep 1
done
echo " ✅"
echo "Traefik is ready, open http://localhost/dashboard/"


if [ "x$PRELOAD" == "x1" ]; then
  echo "⏳ Preload docker images"
  ./offline/import.sh $clustername
  echo " ✅"
fi


popd

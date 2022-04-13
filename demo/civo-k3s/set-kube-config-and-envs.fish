#!/bin/fish
civo kubernetes config merlin-cluster > $HOME/.kubeclusters/merlin.yaml

set -x -g IP (cat $HOME/.kubeclusters/merlin.yaml | yq eval '.clusters.[0].cluster.server' - | cut -d'/' -f3 | cut -d":" -f1)
set -x -g KUBECONFIG $HOME/.kubeclusters/merlin.yaml

export KUBECONFIG=$HOME/.kubeclusters/merlin.yaml
export IP=$IP
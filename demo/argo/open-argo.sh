#!/bin/bash

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
        echo "Local cluster"
        export IP="127.0.0.1"
    else
        echo "Remote cluster $CLUSTER_IP"
        export IP=$CLUSTER_IP
    fi
fi

chromium https://argocd.$IP.sslip.io > /dev/null
#!/bin/sh
SECRET=$(kubectl -n kube-system get secret $(kubectl -n kube-system get secret | grep gitlab | awk '{print $1}') -o jsonpath='{.data.token}' | base64 -d)
echo $SECRET
echo $SECRET | xclip -sel clip


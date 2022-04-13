#!/bin/bash
if [ "x$1" == "x" ]
then
  name="gandalf"
else
  name=$1
fi
clustername="$name-cluster"

IP=$(civo kubernetes config $clustername | yq eval '.clusters.[0].cluster.server' - | cut -d'/' -f3 | cut -d":" -f1)
echo $IP
echo $IP | xclip -sel clip
export IP=$IP

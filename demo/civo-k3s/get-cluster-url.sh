#!/bin/bash
if [ "x$1" == "x" ]
then
  name="gandalf"
else
  name=$1
fi
clustername="$name-cluster"

URL=$(civo kubernetes config $clustername | yq eval '.clusters.[0].cluster.server' -)
echo $URL
echo $URL | xclip -sel clip
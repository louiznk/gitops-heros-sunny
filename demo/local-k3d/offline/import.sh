#!/bin/bash
DIR=$(dirname "$0")
pushd $DIR

clustername=$1
while read -r line
do 
  short="${line##*/}.tar"
  echo "Load $line docker image in k3d $clustername cluster"
  k3d image import -c $clustername "images/$short"
done < images.txt

popd

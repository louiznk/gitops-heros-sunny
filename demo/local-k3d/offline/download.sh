#!/bin/bash
DIR=$(dirname "$0")
pushd $DIR

while read -r line
do 
  short="${line##*/}.tar"
  echo "Download $line docker image as $short"
  docker pull "$line"
  docker save --output "images/$short" "$line"
done < images.txt

popd

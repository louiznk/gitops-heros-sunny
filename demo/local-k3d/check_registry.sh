#!/bin/sh
printf "Test registries in $(pwd)/registries/k3s-config/registries.yaml\n\n"
for REG in `grep http $(pwd)/registries/k3s-config/registries.yaml | awk '{ print $2 }'`
do
    echo "========================================="
    echo "Test $REG"
    curl "$REG/v2/" -i
    echo ""
done

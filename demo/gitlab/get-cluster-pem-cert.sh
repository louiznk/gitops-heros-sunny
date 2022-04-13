#!/bin/sh
kubectl get secret -o go-template='{{index .data "ca.crt" }}' $(kubectl get sa default -o go-template="{{range .secrets}}{{.name}}{{end}}") | base64 -d > tmp
cat tmp
xclip -sel clip < tmp
rm tmp
Install Docker Registry Distribution :https://github.com/docker/distribution

* Install golang
* Build it `go get github.com/docker/distribution/cmd/registry`, see https://github.com/docker/distribution/blob/master/BUILDING.md
* Copy registy, config, systemd services file (for linux)
* Adapt config and services
* Change k3s-config/registry.yaml with the IP or DNS name of the regitry

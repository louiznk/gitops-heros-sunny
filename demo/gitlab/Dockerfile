FROM alpine:3

ARG KUBESEAL_VERSION=v0.16.0

ARG KUBE_VERSION=1.21.5
ARG HELM_VERSION=3.7.1
ARG KUSTOMIZE_VERSION=4.4.0


RUN apk add --no-cache ca-certificates bash git openssh curl gettext jq bind-tools \
    && wget -q https://storage.googleapis.com/kubernetes-release/release/v${KUBE_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl \
    && wget -q https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
    && wget -q https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh && bash install_kustomize.sh ${KUSTOMIZE_VERSION} /usr/local/bin/ && rm install_kustomize.sh \
    && wget -q https://github.com/bitnami-labs/sealed-secrets/releases/download/${KUBESEAL_VERSION}/kubeseal-linux-amd64 -O /usr/local/bin/kubeseal \
    && chmod +x /usr/local/bin/helm /usr/local/bin/kubectl /usr/local/bin/kubeseal \
    && mkdir /config \
    && chmod g+rwx /config /root \
    && helm repo add "stable" "https://charts.helm.sh/stable" --force-update

WORKDIR /config

CMD bash
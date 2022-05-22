FROM debian:bullseye-slim

USER root

RUN apt-get update && apt-get upgrade -y && apt-get install ca-certificates -y && apt-get clean all \
    && groupadd -r argocd -g 999 && useradd -g argocd argocd -u 999 -m -s /bin/bash
COPY ./bin/* /usr/local/bin/

COPY --chown=argocd:argocd ./cache /home/argocd/.cache

# Switch back to non-root user
USER argocd

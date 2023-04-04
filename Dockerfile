ARG HELMFILE_VERSION=0.152.0
ARG YQ_VERSION=v4.33.2
ARG ARGO_VERSION=v2.6.7
FROM docker.io/golang:1.19 as builder
ARG HELMFILE_VERSION
ARG YQ_VERSION
RUN git clone --depth=1 https://github.com/camptocamp/helm-sops && \
    cd helm-sops && \
    go build
RUN wget https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION}_linux_amd64.tar.gz && tar -xf helmfile_${HELMFILE_VERSION}_linux_amd64.tar.gz && chmod + ./helmfile && mv ./helmfile /tmp/helmfile
RUN wget -O /tmp/yq https://github.com/mikefarah/yq/releases/download/$YQ_VERSION/yq_linux_amd64 && chmod +x /tmp/yq

ARG ARGO_VERSION
FROM quay.io/argoproj/argocd:${ARGO_VERSION}
USER root
COPY argocd-repo-server-wrapper /usr/local/bin/
COPY argocd-helmfile /usr/local/bin/
COPY --from=builder /go/helm-sops/helm-sops /usr/local/bin/
COPY --from=builder /tmp/helmfile /usr/local/bin/
COPY --from=builder /tmp/yq /usr/local/bin/
RUN cd /usr/local/bin && \
    mv argocd-repo-server _argocd-repo-server && \
    mv argocd-repo-server-wrapper argocd-repo-server && \
    chmod 755 argocd-repo-server && \
    mv helm _helm && \
    mv helm-sops helm
USER 999

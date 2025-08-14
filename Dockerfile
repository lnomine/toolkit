FROM debian:trixie

ENV download="curl -LO --output-dir /usr/local/bin"
ENV altdownload="curl -L --output-dir /usr/local/bin"
WORKDIR /root/workspace

RUN apt-get update && apt-get install --no-install-recommends curl unzip ca-certificates file openssh-client jq -y

RUN case "$(uname -m)" in \
    x86_64) ARCH_SUFFIX="amd64" ;; \
    aarch64) ARCH_SUFFIX="arm64" ;; \
    *) echo "Unsupported architecture: $(uname -m)" && exit 1 ;; \
  esac && \
  \
  BINARIES_DOWNLOAD=" \
    https://releases.hashicorp.com/terraform/1.12.2/terraform_1.12.2_linux_${ARCH_SUFFIX}.zip \
    https://releases.hashicorp.com/vault/1.20.0/vault_1.20.0_linux_${ARCH_SUFFIX}.zip \
    https://github.com/opentofu/opentofu/releases/download/v1.10.2/tofu_1.10.2_linux_${ARCH_SUFFIX}.zip \
    https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH_SUFFIX}/kubectl \
    https://get.helm.sh/helm-v3.18.4-linux-${ARCH_SUFFIX}.tar.gz \
    https://dl.min.io/client/mc/release/linux-${ARCH_SUFFIX}/mc \
    https://gitlab.com/gitlab-org/cli/-/releases/v1.66.0/downloads/glab_1.66.0_linux_${ARCH_SUFFIX}.tar.gz \
  " && \
  for url in $BINARIES_DOWNLOAD; do $download "$url"; done && \
  \
  BINARIES_ALT=" \
    https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-${ARCH_SUFFIX} argocd \
    https://github.com/siderolabs/talos/releases/latest/download/talosctl-linux-${ARCH_SUFFIX} talosctl \
    https://github.com/gruntwork-io/terragrunt/releases/latest/download/terragrunt_linux_${ARCH_SUFFIX} terragrunt \
    https://github.com/kubernetes-sigs/cluster-api/releases/latest/download/clusterctl-linux-${ARCH_SUFFIX} clusterctl \
  " && \
  set -- $BINARIES_ALT && \
  while [ "$1" ]; do $altdownload "$1" -o "$2"; shift 2; done && \
  \
  find /usr/local/bin -type f \( -name "*.zip" -o -name "*.tar.gz" \) -exec sh -c 'for f; do case "$f" in *.zip) unzip -o -q "$f" -d /usr/local/bin ;; *.tar.gz) tar --overwrite -xzf "$f" -C /usr/local/bin ;; esac; rm -f "$f"; done' sh {} + && \
  chmod +x /usr/local/bin/*

ADD tfmerge /usr/local/bin/
RUN rm -rf /var/lib/apt/lists/*

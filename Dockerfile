FROM debian:trixie
ENV download="curl -LO --output-dir /usr/local/bin"
ENV altdownload="curl -L --output-dir /usr/local/bin"
WORKDIR /root/workspace

RUN apt update ; apt install --no-install-recommends curl unzip ca-certificates file openssh-client jq -y

RUN $download https://releases.hashicorp.com/terraform/1.12.2/terraform_1.12.2_linux_amd64.zip && \
 $download https://releases.hashicorp.com/vault/1.20.0/vault_1.20.0_linux_amd64.zip && \
 $download https://github.com/opentofu/opentofu/releases/download/v1.10.2/tofu_1.10.2_linux_amd64.zip && \
 $download https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl && \
 $download https://get.helm.sh/helm-v3.18.4-linux-amd64.tar.gz && \
 $download https://dl.min.io/client/mc/release/linux-amd64/mc  && \
 $altdownload https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 -o argocd && \
 $altdownload https://github.com/siderolabs/talos/releases/latest/download/talosctl-linux-amd64 -o talosctl && \
 $altdownload https://github.com/gruntwork-io/terragrunt/releases/latest/download/terragrunt_linux_amd64 -o terragrunt && \
 $altdownload https://github.com/kubernetes-sigs/cluster-api/releases/latest/download/clusterctl-linux-amd64 -o clusterctl && \
 find /usr/local/bin -type f \( -name "*.zip" -o -name "*.tar.gz" \) -exec sh -c 'for f; do case "$f" in *.zip) unzip -o -q "$f" -d /usr/local/bin ;; *.tar.gz) tar --overwrite -xzf "$f" -C /usr/local/bin ;; esac; rm -f "$f"; done' sh {} + && \
 chmod +x /usr/local/bin/*

ADD tfmerge /usr/local/bin/
RUN rm -rf /var/lib/apt/lists/*

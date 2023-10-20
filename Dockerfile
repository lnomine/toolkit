FROM debian:bookworm
ENV download="curl -LO --output-dir /usr/local/bin"
ENV altdownload="curl -L --output-dir /usr/local/bin"
WORKDIR /root/workspace

RUN apt update ; apt install --no-install-recommends curl unzip ca-certificates file openssh-client jq -y

RUN $download https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip && \
 $download https://releases.hashicorp.com/consul/1.16.2/consul_1.16.2_linux_amd64.zip && \
 $download https://releases.hashicorp.com/vault/1.15.0/vault_1.15.0_linux_amd64.zip && \
 $download https://releases.hashicorp.com/waypoint/0.11.4/waypoint_0.11.4_linux_amd64.zip && \
 $download https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl && \
 $download https://get.helm.sh/helm-v3.13.0-linux-amd64.tar.gz && \
 $download https://github.com/vmware-tanzu/velero/releases/download/v1.12.0/velero-v1.12.0-linux-amd64.tar.gz && \
 $download https://dl.min.io/client/mc/release/linux-amd64/mc  && \
 $download https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz && \
 $download https://github.com/fluxcd/flux2/releases/download/v2.1.1/flux_2.1.1_linux_amd64.tar.gz && \
 $altdownload https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 -o argocd && \
 $altdownload https://github.com/siderolabs/talos/releases/latest/download/talosctl-linux-amd64 -o talosctl && \
 $altdownload https://github.com/gruntwork-io/terragrunt/releases/latest/download/terragrunt_linux_amd64 -o terragrunt && \
 $altdownload https://github.com/kubernetes-sigs/cluster-api/releases/latest/download/clusterctl-linux-amd64 -o clusterctl && \
 find /usr/local/bin -type f \( -name "*.zip" -o -name "*.tar.gz" \) -exec sh -c 'if echo "{}" | grep -q ".zip$"; then unzip -q "{}" -d /usr/local/bin; elif echo "{}" | grep -q ".tar.gz$"; then tar xzf "{}" -C /usr/local/bin; fi && rm "{}"' \; && \
 find /usr/local/bin -type d -name "*linux-amd64" -exec sh -c 'mv -t "${1%/*}" -- "$1"/*' _ {} \; && \
 chmod +x /usr/local/bin/* && \
 find /usr/local/bin -mindepth 1 -type f ! -exec file {} \; -o -type d ! -exec file {} \; | grep -v "executable" | awk -F: '{print $1}' | xargs rm -rf

ADD tfmerge /usr/local/bin/
RUN rm -rf /var/lib/apt/lists/*

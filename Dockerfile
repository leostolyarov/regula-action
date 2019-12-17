# Container image that runs your code
FROM debian:jessie

# Install a number of dependencies using apt.
RUN apt-get update && apt-get install -y curl jq unzip

# Install OPA.
ARG OPA_VERSION=0.15.1
RUN curl -Lo '/usr/local/bin/opa' \
        "https://github.com/open-policy-agent/opa/releases/download/v${OPA_VERSION}/opa_linux_amd64" &&\
    chmod +x '/usr/local/bin/opa'

# Install terraform.
ARG TERRAFORM_VERSION=0.12.18
ENV TF_IN_AUTOMATION=true
RUN curl -Lo "/tmp/terraform-${TERRAFORM_VERSION}.zip" \
        "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    unzip -d '/usr/local/bin' "/tmp/terraform-${TERRAFORM_VERSION}.zip"

# Pre-install the `aws` terraform provider.
RUN mkdir /tmp/terraform-aws && \
    echo 'provider "aws" {}' >/tmp/terraform-aws/main.tf && \
    terraform get /tmp/terraform-aws && \
    rm -rf /tmp/terraform-aws

# Install regula modules.  TODO: don't use master but a proper tag.
RUN curl -Lo '/tmp/regula1.zip' \
        "https://github.com/jaspervdj-luminal/regula/archive/master.zip" && \
    unzip -d '/opt/regula' '/tmp/regula1.zip'

# Code file to execute when the docker container starts up (`entrypoint.sh`)
COPY entrypoint.sh /entrypoint.sh
ENV HOME=/root
ENTRYPOINT ["/entrypoint.sh"]

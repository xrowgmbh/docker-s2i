FROM centos:7

LABEL maintainer="bjoern@xrow.de" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.name="Builder and management image for cloud native CI / CD pipelines S2I, Docker in Docker, Operators, HELM, ..." \
      org.label-schema.vendor="xrow GmbH" \
      org.label-schema.license="GPLv2"

ENV HOME="/root"
ENV LANG=en_US.UTF-8

ENV KUBECONFIG="$HOME/.kube/config"

ENV KUBEFED_VERSION=0.1.0-rc6
ENV OPERATORSDK_VERSION=0.10.0
ENV HELM_VERSION=3.0.0-beta.3
ENV COMPOSE_VERSION=1.23.2
ENV OC_VERSION=1.23.2
ENV S2I_VERSION=1.1.13

ADD bin/uid_entrypoint /bin/uid_entrypoint

RUN yum install -y epel-release \
 && yum install -y git gettext ansible openssh-clients sshpass yum-utils yamllint \
 && yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo \
 && yum install -y docker-ce-cli \
 && chmod 755 /bin/uid_entrypoint \
 && yum remove -y yum-utils \
 && yum clean all \
 && rm -Rf /var/cache/yum

RUN DOCKER_COMPOSE_DOWNLOAD_URL="https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-Linux-x86_64" \
 && curl -sSfLo /bin/docker-compose $DOCKER_COMPOSE_DOWNLOAD_URL \
 && chmod +x /bin/docker-compose

RUN S2I_DOWNLOAD_URL="https://github.com/openshift/source-to-image/releases/download/v1.1.13/source-to-image-v1.1.13-b54d75d3-linux-amd64.tar.gz" \
 && curl -sSfL $S2I_DOWNLOAD_URL | tar -xzC /bin

COPY digicert.crt /etc/pki/ca-trust/source/anchors/digi.crt

RUN TMP=$(mktemp -d) \
 && curl -sSfL https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar -xz -C $TMP \
 && mv $TMP/linux-amd64/helm /usr/bin \
 && chmod +x /usr/bin/helm

# Archive contains binaries for oc and kubectl
RUN OC_DOWNLOAD_URL="https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz" \
 && TMP=$(mktemp -d) \
 && curl -sSfL $OC_DOWNLOAD_URL | tar -xz --strip-components=1 -C $TMP \
 && mv $TMP/{oc,kubectl} /usr/bin \
 && rm -Rf $TMP \
 && mkdir $(dirname $KUBECONFIG) \
 && update-ca-trust extract
 
RUN curl -o /usr/bin/operator-sdk -OJL https://github.com/operator-framework/operator-sdk/releases/download/v${OPERATORSDK_VERSION}/operator-sdk-v${OPERATORSDK_VERSION}-x86_64-linux-gnu \
 && chmod 755 /usr/bin/operator-sdk

RUN curl -LO https://github.com/kubernetes-sigs/kubefed/releases/download/v${KUBEFED_VERSION}/kubefedctl-${KUBEFED_VERSION}-linux-amd64.tgz \
  && tar -zxvf kubefedctl-*.tgz \
  && chmod u+x kubefedctl \
  && mv kubefedctl /usr/bin

USER 1001

ENTRYPOINT [ "/bin/uid_entrypoint" ]

WORKDIR $HOME
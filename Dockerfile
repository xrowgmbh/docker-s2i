FROM centos:7

LABEL maintainer="bjoern@xrow.de" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.name="S2I Runner Image" \
      org.label-schema.vendor="xrow GmbH" \
      org.label-schema.license="GPLv2"

ENV HOME="/root"
ENV LANG=en_US.UTF-8

ENV KUBECONFIG="$HOME/.kube/config"

RUN yum install -y epel-release \
 && yum install -y git gettext ansible openssh-clients sshpass yum-utils yamllint \
 && yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo \
 && yum install -y docker-ce-cli \
 && alias docker="if [ -z ${DOCKER_HOST+x} ] && [ ! -z ${DOCKER_PORT+x} ]; then export DOCKER_HOST=$DOCKER_PORT; fi;/usr/bin/docker" \
 && yum remove -y yum-utils \
 && yum clean all \
 && rm -Rf /var/cache/yum

RUN DOCKER_COMPOSE_DOWNLOAD_URL="https://github.com/docker/compose/releases/download/1.23.2/docker-compose-Linux-x86_64" \
 && curl -sSfLo /bin/docker-compose $DOCKER_COMPOSE_DOWNLOAD_URL \
 && chmod +x /bin/docker-compose

RUN S2I_DOWNLOAD_URL="https://github.com/openshift/source-to-image/releases/download/v1.1.13/source-to-image-v1.1.13-b54d75d3-linux-amd64.tar.gz" \
 && curl -sSfL $S2I_DOWNLOAD_URL | tar -xzC /bin

COPY digicert.crt /etc/pki/ca-trust/source/anchors/digi.crt

RUN TMP=$(mktemp -d) \
 && curl -sSfL https://get.helm.sh/helm-v2.14.1-linux-amd64.tar.gz | tar -xz -C $TMP \
 && mv $TMP/linux-amd64/helm /usr/local/bin \
 && chmod +x /usr/local/bin/helm

# Archive contains binaries for oc and kubectl
RUN OC_DOWNLOAD_URL="https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz" \
 && TMP=$(mktemp -d) \
 && curl -sSfL $OC_DOWNLOAD_URL | tar -xz --strip-components=1 -C $TMP \
 && mv $TMP/{oc,kubectl} /usr/local/bin \
 && rm -Rf $TMP \
 && mkdir $(dirname $KUBECONFIG) \
 && update-ca-trust extract
 
RUN export RELEASE_VERSION="v0.8.1" \
 && curl -o /usr/local/bin/operator-sdk -OJL https://github.com/operator-framework/operator-sdk/releases/download/${RELEASE_VERSION}/operator-sdk-${RELEASE_VERSION}-x86_64-linux-gnu \
 && chmod 755 /usr/local/bin/operator-sdk

WORKDIR $HOME

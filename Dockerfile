FROM centos:7

LABEL maintainer="bjoern@xrow.de" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.name="S2I Runner Image" \
      org.label-schema.vendor="xrow GmbH" \
      org.label-schema.license="GPLv2"

ENV KUBECONFIG="~/.kube/config"

RUN yum install -y git gettext docker ansible openssh-clients sshpass \
 && yum clean all \
 && rm -Rf /var/cache/yum

RUN DOCKER_COMPOSE_DOWNLOAD_URL="https://github.com/docker/compose/releases/download/1.23.2/docker-compose-Linux-x86_64" \
 && curl -sSfLo /bin/docker-compose $DOCKER_COMPOSE_DOWNLOAD_URL \
 && chmod +x /bin/docker-compose

RUN S2I_DOWNLOAD_URL="https://github.com/openshift/source-to-image/releases/download/v1.1.13/source-to-image-v1.1.13-b54d75d3-linux-amd64.tar.gz" \
 && curl -sSfL $S2I_DOWNLOAD_URL | tar -xzC /bin

# Archive contains binaries for oc and kubectl
RUN OC_DOWNLOAD_URL="https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz" \
 && TMP=$(mktemp -d) \
 && curl -sSfL $OC_DOWNLOAD_URL | tar -xz --strip-components=1 -C $TMP \
 && mv $TMP/{oc,kubectl} /usr/local/bin \
 && rm -Rf $TMP \
 && mkdir ~/.kube

RUN JQ_DOWNLOAD_URL="https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64" \
 && curl -sSfLo /bin/jq $JQ_DOWNLOAD_URL \
 && chmod +x /bin/jq

FROM docker:stable

MAINTAINER Björn Dieding <bjoern@xrow.de>

# There is no centos dind image so i can`t use this
# Install packages necessary to run s2i builder
#RUN yum update -y && \
#    yum install -y centos-release-scl && \
#	yum -y install source-to-image && \
#	yum clean all
RUN apk update && \
    apk add curl tar git ssh && \
    curl -L -o s2i.tgz -O https://github.com/openshift/source-to-image/releases/download/v1.1.10/source-to-image-v1.1.10-27f0729d-linux-amd64.tar.gz && \
    tar -xvf s2i.tgz . && \
    cp s2i /usr/local/bin
LABEL org.label-schema.schema-version = "1.0" \
    org.label-schema.name="S2I Runner Image" \
    org.label-schema.vendor="xrow GmbH" \
    org.label-schema.license="GPLv2" \
    org.label-schema.build-date="20180626"
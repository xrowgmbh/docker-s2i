FROM centos:7

MAINTAINER Björn Dieding <bjoern@xrow.de>

# Install packages necessary to run s2i builder
RUN yum update -y && \
    yum install -y centos-release-scl && \
	yum -y install source-to-image && \
	yum clean all

LABEL org.label-schema.schema-version = "1.0" \
    org.label-schema.name="CentOS S2I Runner Image" \
    org.label-schema.vendor="CentOS" \
    org.label-schema.license="GPLv2" \
    org.label-schema.build-date="20180626"

CMD ["/bin/bash"]

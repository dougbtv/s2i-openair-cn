
# openair-cn
FROM centos:centos7
MAINTAINER @dougbtv
ENV BUILDER_VERSION 1.0
LABEL io.k8s.description="OpenAir-CN" \
      io.k8s.display-name="OpenAir-CN" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="enb,enodeb,wireless,nfv,oai"

# TODO: Install required packages here:
# RUN yum install -y ... && yum clean all -y
RUN yum install -y epel-release && yum install -y \
    git \
    psmisc \
    cmake3 \
    cmake \
    autoconf \
    automake \
    bison \
    doxygen \
    flex \
    gdb \
    subversion \
    gnutls-devel \
    libconfig-devel \
    libgcrypt-devel \
    libidn-devel \
    libidn2-devel \
    libtool \
    lksctp-tools \
    lksctp-tools-devel \
    mariadb-devel \
    nettle-devel \
    openssl-devel \
    gcc-c++ \
    libxml2-devel \
    mercurial \
    swig \
    pexpect \
    phpMyAdmin \
    check \
    check-devel \
    gtk3-devel \
    guile-devel \
    gccxml \
    iperf

# TODO (optional): Copy the builder files into /opt/app-root
# COPY ./<builder_folder>/ /opt/app-root/

# TODO: Copy the S2I scripts to /usr/libexec/s2i, since openshift/base-centos7 image
# sets io.openshift.s2i.scripts-url label that way, or update that label
COPY ./s2i/bin/ /usr/libexec/s2i

# TODO: Drop the root user and make the content of /opt/app-root owned by user 1001
# RUN chown -R 1001:1001 /opt/app-root

# This default user is created in the openshift/base-centos7 image
# (Doug: usually uncommented, below line.)
# USER 1001

# TODO: Set the default port for applications built using this image
# EXPOSE 8080

# TODO: Set the default CMD for the image
# CMD ["/usr/libexec/s2i/usage"]

### Dockerfile for building an Ansible image suitable for automated testing.
# Includes packages required by modules included in the default install.

FROM inhumantsar/ansible:centos7
MAINTAINER Shaun Martin <shaun@samsite.ca>

ADD git-crypt.start.sh /start.sh
ADD start.sh /parent-start.sh

# build arguments, see https://docs.docker.com/engine/reference/builder/#arg
# use with --build-arg to do the thing at build time
ENV GPG_PK ""
ENV GIT_CRYPT_VERSION 0.5.0
ENV GPG_TTY /dev/console

RUN yum -y upgrade \
  && yum -y install \
      gpg \
      libxslt \
      openssl-devel \
      gcc \
      gcc-c++ \
      make \
  && git clone --branch $GIT_CRYPT_VERSION --single-branch \
      https://github.com/AGWA/git-crypt.git /tmp/git-crypt \
  && cd /tmp/git-crypt \
  && make \
  && make install \
  && yum clean all \
  && rm -rf /var/cache/yum \
  && chmod +x /*.sh

CMD ["/start.sh"]

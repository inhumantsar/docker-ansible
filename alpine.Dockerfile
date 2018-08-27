### Dockerfile for building an Ansible image suitable for automated testing.
# Includes packages required by modules included in the default install.

FROM alpine:latest
MAINTAINER Shaun Martin <shaun@samsite.ca>

ENV WORKDIR /workspace
VOLUME $WORKDIR
WORKDIR $WORKDIR
ARG VERSION
ENV PKG_CMD "apk --no-cache add"
ENV GPG_PK ""
ENV GIT_CRYPT_VERSION 0.6.0
ENV GPG_TTY /dev/console

RUN echo "### Installing system packages..." \
  && apk --no-cache add \
    bash \
    curl \
    g++ \
    gcc \
    git \
    gnupg \
    libffi \
    libffi-dev \
    libxslt \
    make \
    musl-dev \
    openssl-dev \
    python \
    python-dev \
    sshpass \
    shadow \
    sudo \
  && echo "### Installing pip and PyPI packages..." \
  && curl https://bootstrap.pypa.io/get-pip.py | python \
  && pip install --upgrade \
    pyyaml \
    jinja2 \
    pycrypto \
    paramiko \
    httplib2 \
    boto \
    boto3 \
    ansible~="$VERSION.0" \
  && echo "### Installing git-crypt..." \
  && git clone --branch $GIT_CRYPT_VERSION --single-branch \
      https://github.com/AGWA/git-crypt.git /tmp/git-crypt \
  && cd /tmp/git-crypt \
  && make \
  && make install \
  && echo "### Disabling 'requiretty' in sudoers..." \
  && sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers \
  && echo "### Adding 'localhost' to /etc/ansible/hosts..." \
  && mkdir -p /etc/ansible \
  && echo 'localhost' > /etc/ansible/hosts

ADD start.sh /
RUN echo "### Making start.sh executable..." \
  && chmod +x /start.sh

ADD VERSION /

CMD ["/start.sh"]

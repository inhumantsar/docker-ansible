### Dockerfile for building an Ansible image suitable for automated testing.
# Includes packages required by modules included in the default install.

FROM ubuntu:bionic
MAINTAINER Shaun Martin <shaun@samsite.ca>

ENV WORKDIR /workspace
VOLUME $WORKDIR
WORKDIR $WORKDIR
ARG VERSION
ENV PKG_CMD "apt update && apt install -y"
ENV GPG_PK ""
ENV GIT_CRYPT_VERSION 0.6.0
ENV GPG_TTY /dev/console

RUN echo "### Installing system packages..." \
  && apt update \
  && apt upgrade -y \
  && apt install -y \
    curl \
    g++ \
    gcc \
    git \
    libffi-dev \
    libxslt1.1 \
    libssl-dev \
    make \
    openssl \
    python-dev \
    sshpass \
    sudo \
  && apt-get clean \
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
  && rm -rf /root/.cache/pip \
  && echo "### Installing git-crypt..." \
  && git clone --branch $GIT_CRYPT_VERSION --single-branch \
      https://github.com/AGWA/git-crypt.git /tmp/git-crypt \
  && cd /tmp/git-crypt \
  && make \
  && make install \
  && echo "### Disabling 'requiretty' in sudoers..." \
  && sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/' /etc/sudoers \
  && echo "### Adding 'localhost' to /etc/ansible/hosts..." \
  && mkdir -p /etc/ansible \
  && echo 'localhost' > /etc/ansible/hosts 

ADD start.sh /
RUN echo "### Making start.sh executable..." \
  && chmod +x /start.sh

ADD VERSION /

CMD ["/start.sh"]

### Dockerfile for building an Ansible image suitable for automated testing.
# Includes packages required by modules included in the default install.

FROM ubuntu:xenial
MAINTAINER Shaun Martin <shaun@samsite.ca>

ENV WORKDIR /workspace
VOLUME $WORKDIR
WORKDIR $WORKDIR
ENV VERSION 2.5
ENV PKG_CMD "apt update && apt install -y"

ADD start.sh /

RUN echo "### Installing system packages..." \
  && apt update \
  && apt upgrade -y \
  && apt install -y \
    gcc \
    make \
    python-dev \
    libffi-dev \
    openssl \
    git \
    sudo \
    curl \
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
  && echo "### Disabling 'requiretty' in sudoers..." \
  && sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/' /etc/sudoers \
  && echo "### Adding 'localhost' to /etc/ansible/hosts..." \
  && mkdir -p /etc/ansible \
  && echo 'localhost' > /etc/ansible/hosts \
  && echo "### Making start.sh executable..." \
  && chmod +x /start.sh

CMD ["/start.sh"]

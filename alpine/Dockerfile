### Dockerfile for building an Ansible image suitable for automated testing.
# Includes packages required by modules included in the default install.

FROM alpine:latest
MAINTAINER Shaun Martin <shaun@samsite.ca>

ENV workdir /workspace
VOLUME [ $workdir ]
WORKDIR [ $workdir ]

RUN echo "### Installing system packages..." && \
  apk --no-cache add \
    python \
    curl \
    gcc \
    make \
    git \
    sudo \
    python-dev \
    musl-dev \
    libffi \
    libffi-dev \
    openssl-dev \
    bash \
    shadow

RUN echo "### Installing pip and PyPI packages..." && \
  curl https://bootstrap.pypa.io/get-pip.py | python && \
  pip install --upgrade \
    pyyaml \
    jinja2 \
    pycrypto \
    paramiko \
    httplib2 \
    boto \
    boto3 \
    ansible

RUN echo "### Disabling 'requiretty' in sudoers..." && \
  sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers

RUN echo "### Adding 'localhost' to /etc/ansible/hosts..." && \
  mkdir -p /etc/ansible && \
  echo 'localhost' > /etc/ansible/hosts

ADD start.sh /
RUN echo "### Making start.sh executable..." && \
  chmod +x /start.sh

CMD ["/start.sh"]

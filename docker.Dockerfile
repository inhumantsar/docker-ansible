### Dockerfile for building an Ansible image suitable for automated testing.
# Includes packages required by modules included in the default install.

# This extension adds the Docker binaries and a volume for the Docker socket.
# For DIND use in testing.

# Automatic basic inventory available with docker-dynamic-inventory
# Advanced inventory needs should get the script in the contrib dir in the Ansible GitHub repo.

FROM inhumantsar/ansible:centos7
MAINTAINER Shaun Martin <shaun@samsite.ca>

ARG VERSION

RUN pip install --force-reinstall ansible~=$VERSION && \
    pip install docker-dynamic-inventory && \
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo && \
    yum install -y docker-ce

CMD ["/start.sh", "-c", "docker"]

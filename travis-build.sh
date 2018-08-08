#!/bin/bash

echo """

#####################################
### Starting build...               #
#####################################

  - Ansible v${VERSION}
  - OS: ${OS}
  - Image Tag: ${TAG}
  
"""

docker build --no-cache --build-arg VERSION="${VERSION}" -t $HUB_USER/ansible:$TAG -f $OS.Dockerfile . || travis_terminate 1

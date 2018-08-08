#!/bin/bash

echo """

#####################################
### Starting tests...               #
#####################################
"""

# check the correct version of ansible is installed
ansible_version="$(docker run -it --rm $HUB_USER/ansible:$TAG /bin/bash -c 'ansible --version' | head -n 1 | sed -e 's/ansible \([0-9]\.[0-9]\)\.[0-9].*/\1/')"
echo "  - Ansible version in image is ${ansible_version}, expecting ${VERSION}."
test "${ansible_version}" == "${VERSION}" || travis_terminate 1

# check that the script/image version is correct
# in case a child tries to build latest from an outdated parent
image_version="$(docker run -it --rm $HUB_USER/ansible:$TAG cat /VERSION)"
latest_git_tag="$(git tag --list --sort=-v:refname | head -n 1 | cut -dv -f2)"
echo "  - Image version is ${image_version}, expecting ${latest_git_tag}"
test "${image_version}" == "${latest_git_tag}" || travis_terminate 1


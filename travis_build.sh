#!/bin/bash

current_ansible_version=2.6
[ "${VERSION}" != "" ] && ansible_versions="${VERSION}" || ansible_versions=(2.6 2.5 2.4 2.3)


if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then
  echo """$0 [-h|--help] OSNAME
  
  Builds docker images. 
  Uses OSNAME to find Dockerfiles and set image tags.
  Optionally set env var VERSION to a specific Ansible major.minor version.

  Latest stable Ansible version available: ${current_ansible_version}
  """
  exit 0
fi


for os in "$@"; do
  for ansible_version in ${ansible_versions[*]}; do

    # tag includes ansible version by default
    tag="${ansible_version}-${os}"
    if [[ "${ansible_version}" == "${current_ansible_version}" ]]; then
      tag="${os}"
    fi

    echo """

#####################################
### Starting build...               #
#####################################

  - Ansible v${ansible_version}
  - os: ${os}
  - Image Tag: ${tag}
  - Image Version: $(cat VERSION)
  
"""

    docker build --no-cache --build-arg VERSION="${ansible_version}" -t $HUB_USER/ansible:$tag -f $os.Dockerfile . || travis_terminate 1 &> /dev/null || exit 1


    echo """

#####################################
### Starting tests...               #
#####################################
    """

    # check the correct version of ansible is installed
    actual_ansible_version="$(docker run -it --rm $HUB_USER/ansible:$tag /bin/bash -c 'ansible --version' | head -n 1 | sed -e 's/ansible \([0-9]\.[0-9]\)\.[0-9].*/\1/')"
    echo "  - Ansible version in image is ${actual_ansible_version}, expecting ${ansible_version}."
    test "${actual_ansible_version}" == "${ansible_version}" || travis_terminate 1 &> /dev/null || exit 1 &> /dev/null || exit 1

    # check that the script/image version is correct
    # in case a child tries to build latest from an outdated parent
    image_version="$(docker run -it --rm $HUB_USER/ansible:$tag cat /VERSION)"
    latest_git_tag="$(git -C $TRAVIS_BUILD_DIR tag --list --sort=-v:refname | head -n 1 | cut -dv -f2)"
    echo "  - [SKIPPED] Image version is ${image_version}, expecting ${latest_git_tag}"
    # test "${image_version}" == "${latest_git_tag}" || travis_terminate 1 &> /dev/null || exit 1


    # determine what actual branch we're working on. see https://graysonkoonce.com/getting-the-current-branch-name-during-a-pull-request-in-travis-ci/
    BRANCH=$(if [ "$TRAVIS_PULL_REQUEST" == "false" ]; then echo $TRAVIS_BRANCH; else echo $TRAVIS_PULL_REQUEST_BRANCH; fi)

    # don't deploy if we're not operating on the master branch
    if [ "${BRANCH}" != "master" ]; then 
    echo """

#####################################
### Skipping deploy!                #
#####################################
    """
      echo "  - Will not deploy images from any branch but master (currently on branch '${BRANCH}')"
      exit 0
    fi


    echo """

#####################################
### Starting deploy...              #
#####################################
    """

    docker login -u $HUB_USER -p $HUB_PASS  || travis_terminate 1 &> /dev/null || exit 1
    docker push $HUB_USER/ansible:$tag

    # set default image tags (eg: ansible, ansible:onbuild, ansible:2.3)
    if [[ "${tag}" == "alpine" ]]; then
      docker tag $HUB_USER/ansible:$tag $HUB_USER/ansible
      docker push $HUB_USER/ansible
    fi
    if [[ "${tag}" == *.*-alpine ]] || [[ "${tag}" == "alpine" ]]; then
      docker tag $HUB_USER/ansible:$tag $HUB_USER/ansible:$VERSION
      docker push $HUB_USER/ansible:$VERSION 
    fi
    if [[ "${tag}" == "onbuild-alpine" ]]; then
      docker tag $HUB_USER/ansible:$tag $HUB_USER/ansible:onbuild
      docker push $HUB_USER/ansible:onbuild
    fi
    if [[ "${tag}" == *.*-onbuild-alpine ]] || [[ "${tag}" == "onbuild-alpine" ]]; then
      docker tag $HUB_USER/ansible:$tag $HUB_USER/ansible:$VERSION-onbuild
      docker push $HUB_USER/ansible:$VERSION-onbuild
    fi
  done
done

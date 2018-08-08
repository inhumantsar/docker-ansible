#!/bin/bash

# determine what actual branch we're working on. see https://graysonkoonce.com/getting-the-current-branch-name-during-a-pull-request-in-travis-ci/
BRANCH=$(if [ "$TRAVIS_PULL_REQUEST" == "false" ]; then echo $TRAVIS_BRANCH; else echo $TRAVIS_PULL_REQUEST_BRANCH; fi)

# don't deploy if we're not operating on the master branch
if [ "${BRANCH}" != "master" ]; then 
  echo "Cowardly refusing to deploy from any branch but master (currently on branch '${BRANCH}')"
  exit 0
fi

echo """

#####################################
### Starting deploy...              #
#####################################
"""

docker login -u $HUB_USER -p $HUB_PASS  || travis_terminate 1
docker push $HUB_USER/ansible:$TAG

# set default image tags (eg: ansible, ansible:onbuild, ansible:2.3)
if [[ "${TAG}" == "alpine" ]]; then
  docker tag $HUB_USER/ansible:$TAG $HUB_USER/ansible
  docker push $HUB_USER/ansible
fi
if [[ "${TAG}" == *.*-alpine ]] || [[ "${TAG}" == "alpine" ]]; then
  docker tag $HUB_USER/ansible:$TAG $HUB_USER/ansible:$VERSION
  docker push $HUB_USER/ansible:$VERSION 
fi
if [[ "${TAG}" == "onbuild-alpine" ]]; then
  docker tag $HUB_USER/ansible:$TAG $HUB_USER/ansible:onbuild
  docker push $HUB_USER/ansible:onbuild
fi
if [[ "${TAG}" == *.*-onbuild-alpine ]] || [[ "${TAG}" == "onbuild-alpine" ]]; then
  docker tag $HUB_USER/ansible:$TAG $HUB_USER/ansible:$VERSION-onbuild
  docker push $HUB_USER/ansible:$VERSION-onbuild
fi


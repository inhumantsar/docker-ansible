#!/bin/bash
### wrapper for the base image start.sh
### starts gpg-agent, imports the private key (unenc only), runs the base img start.sh

eval $(gpg-agent --daemon 2> /dev/null)
echo "${GPG_PK}" > /pk.key
gpg --batch --yes --import /pk.key
git-crypt unlock

/parent-start.sh $@

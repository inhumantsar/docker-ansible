#!/bin/bash

### startup script for Ansible testing
# NOTE: Set working directory with `-w` in the `docker run` command.

verbosity=''
playbook=''
galaxyfile='requirements.yml'
pypifile='requirements.txt'
inventory='localhost,'
cmd="ansible-playbook"

USAGE="""$0 [-p test.yml] [-g requirements.yml] [-r requirements.txt] [-i 'localhost,'] [-v] [-h]
  Installs pre-reqs and runs an Ansible playbook. Looks for / falls back to test.yml,
  local.yml, and playbook.yml by default.

  -p    Path to Ansible playbook
  -g    Path to Ansible Galaxy requirements file (default: requirements.yml)
  -r    Path to PyPI/pip requirements file (default: requirements.txt)
  -i    Inventory string passed directly to Ansible (default: localhost,)
  -v    Enable debug messages
  -h    Show this help message
"""

while getopts 'p:g:r:i:hv' flag; do
  case "${flag}" in
    p) playbook="${OPTARG}" ;;
    g) galaxyfile="${OPTARG}" ;;
    r) pypifile="${OPTARG}" ;;
    i) cmd="${cmd} -i ${OPTARG}" ;;
    v) cmd="${cmd} -vvv" ;;
    h) echo "${USAGE}"; exit 0 ;;
    *) echo -e "\nERROR: Unexpected option ${flag}!\n"; echo "${USAGE}"; exit 1 ;;
  esac
done

# Install ansible-galaxy requirements
if [ -f "${galaxyfile}" ]; then
  echo -e "\n### Installing pre-reqs from Ansible Galaxy..."
  ansible-galaxy install -r "${galaxyfile}"
fi

# Install Python requirements
if [ -f "${pypifile}" ]; then
  echo -e "\n### Installing pre-reqs from PyPI..."
  pip install -r "${pypifile}"
fi

# Look for test.yml, falling back to local.yml and playbook.yml
if [ ! -f "${playbook}" ]; then
  for pb in 'test.yml' 'local.yml' 'playbook.yml'; do
    if [ -f "${pb}" ]; then
      playbook="${pb}"
    fi
  done
fi

# Do the thing.
echo -e "\n### Starting run for playbook ${playbook}..."
$cmd "${playbook}"

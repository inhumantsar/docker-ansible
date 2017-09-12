#!/bin/bash

### startup script for Ansible testing
# NOTE: Set working directory with `-w` in the `docker run` command.

verbosity=''
playbook=''
galaxyfile='requirements.yml'
pypifile='requirements.txt'
pkgfile='system_packages.txt'
skip_all=0
cmd="ansible-playbook"

USAGE="""$0 [-p test.yml] [-g requirements.yml] [-r requirements.txt] [-s system_packages.txt] [-*] [-h] [-x]
  Installs pre-reqs and runs an Ansible playbook.

  -p    Path to Ansible playbook (default: test.yml > local.yml > playbook.yml > site.yml)
  -g    Path to Ansible Galaxy requirements file (default: requirements.yml)
  -r    Path to PyPI/pip requirements file (default: requirements.txt)
  -s    Path to a list of system packages to install, one per line. (default: system_packages.txt)
  -x    Skip all dependency installs.
  -*    Any option supported by ansible-playbook (eg: -e SOMEVAR=someval -i /path/to/inventory)
  -v    Enable debug messages
  -h    Show this help message
"""

# doing this instead of getopts so we can trap "invalid" params and use them as
# part of the ansible-playbook command
while test $# -gt 0; do
    # echo "$1 $2"
    if [ "$1" == "-p" ]; then
      playbook="${2}" #; echo "playbook=${playbook}"
    elif [ "$1" == "-g" ]; then
      galaxyfile="${2}" #; echo "galaxyfile=${galaxyfile}"
    elif [ "$1" == "-r" ]; then
      pypifile="${2}" #; echo "pypifile=${pypifile}"
    elif [ "$1" == "-s" ]; then
      pkgfile="${2}" #; echo "pkgfile=${pkgfile}"
    elif [ "$1" == "-x" ]; then
      skip_all=1
    elif [ "$1" == "-h" ]; then
      echo $USAGE; exit 0
    else
      cmd="${cmd} $1 $2" #; echo $cmd
    fi

    shift; shift
done

# Install ansible-galaxy requirements
if [ -f "${galaxyfile}" ] && [[ $skip_all -eq 0 ]]; then
  echo -e "\n### Installing pre-reqs from Ansible Galaxy..."
  ansible-galaxy install -r "${galaxyfile}"
fi

# Install Python requirements
if [ -f "${pypifile}" ] && [[ $skip_all -eq 0 ]]; then
  echo -e "\n### Installing pre-reqs from PyPI..."
  pip install -r "${pypifile}"
fi

# Install system packages
if [ -f "${pkgfile}" ] && [[ $skip_all -eq 0 ]]; then
  echo -e "\n### Installing system packages..."
  pkgs=""
  cat $pkgfile | while read line; do
    pkgs="${pkgs} ${line}"
  done
  apk --no-cache add $pkgs
fi

# Look for a playbook file
if [ ! -f "${playbook}" ]; then
  for pb in 'test.yml' 'local.yml' 'playbook.yml' 'site.yml'; do
    if [ -f "${pb}" ]; then
      playbook="${pb}"
    fi
  done
fi

# Do the thing.
echo -e "\n### Starting run for playbook ${playbook}..."
$cmd "${playbook}"

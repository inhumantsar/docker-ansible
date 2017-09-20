#!/bin/bash

### startup script for Ansible testing

[ "${PLAYBOOK}" != "" ] && playbook="${PLAYBOOK}" || playbook=''
[ "${WORKDIR}" != "" ] && wd="${WORKDIR}" || wd='/workspace'
[ "${GALAXY}" != "" ] && galaxyfile="${GALAXY}" || galaxyfile="${wd}/requirements.yml"
[ "${PYPI}" != "" ] && pypifile="${PYPI}" || pypifile="${wd}/requirements.txt"
[ "${SYSPKGS}" != "" ] && pkgfile="${SYSPKGS}" || pkgfile="${wd}/system_packages.txt"

verbosity=''
skip_all=0
skip_playbook=0
cmd="ansible-playbook"
pkg_cmd="yum makecache fast; yum install -y"

USAGE="""$0 [-x] [-y] [-h] [-*]\n
  Installs pre-reqs and runs an Ansible playbook.\n
\n
  -x    Skip all dependency installs.\n
  -y    Skip playbook run.\n
  -h    Show this help message\n
  -*    Any option supported by ansible-playbook (eg: -e SOMEVAR=someval -i /path/to/inventory)\n
\n
  ENV vars:\n
    WORKDIR     Path to code location in the image. (default: /workspace)\n
    PLAYBOOK    Path to Ansible playbook (default: WORKDIR/test.yml > local.yml > playbook.yml > site.yml)\n
    GALAXY      Path to Ansible Galaxy requirements file (default: WORKDIR/requirements.yml)\n
    PYPI        Path to PyPI/pip requirements file (default: WORKDIR/requirements.txt)\n
    SYSPKGS     Path to a list of system packages to install, one per line. (default: WORKDIR/system_packages.txt)\n
"""

# doing this instead of getopts so we can trap "invalid" params and use them as
# part of the ansible-playbook command
while test $# -gt 0; do
    if [ "$1" == "-x" ]; then
      skip_all=1
    elif [ "$1" == "-y" ]; then
      skip_playbook=1
    elif [ "$1" == "-h" ]; then
      echo -e $USAGE; exit 0
    else
      cmd="${cmd} $1 $2" #; echo $cmd
    fi

    shift; shift
done


# Install ansible-galaxy requirements
if [ -f "${galaxyfile}" ] && [[ $skip_all -eq 0 ]]; then
  echo -e "\n### Installing pre-reqs from Ansible Galaxy..."
  ansible-galaxy install -r "${galaxyfile}"
else
  echo -e "\n### No Ansible Galaxy pre-reqs found at ${galaxyfile}, moving on."
fi

# Install Python requirements
if [ -f "${pypifile}" ] && [[ $skip_all -eq 0 ]]; then
  echo -e "\n### Installing pre-reqs from PyPI..."
  pip install -r "${pypifile}"
else
  echo -e "\n### No Python pre-reqs found at ${pypifile}, moving on."
fi

# Install system packages
if [ -f "${pkgfile}" ] && [[ $skip_all -eq 0 ]]; then
  echo -e "\n### Installing system packages..."
  pkgs=""
  cat $pkgfile | while read line; do
    pkgs="${pkgs} ${line}"
  done
  $pkg_cmd $pkgs
else
  echo -e "\n### No system package pre-reqs found at ${pkgfile}, moving on."
fi

# Look for a playbook file
if [ ! -f "${wd}/${playbook}" ]; then
  for pb in 'test.yml' 'local.yml' 'playbook.yml' 'site.yml'; do
    if [ -f "${wd}/${pb}" ]; then
      playbook="${wd}/${pb}"
      break
    fi
  done
fi

if [[ $skip_playbook -eq 1 ]]; then
  echo -e "\n### Skipping playbook run."
  exit 0
fi

# Do the thing.
echo -e "\n### Starting run for playbook ${playbook}..."
$cmd "${playbook}"

#!/bin/bash
### startup script for Ansible testing

if [ "${PKG_CMD}" == "" ]; then
  echo "ERROR: No PKG_CMD set! eg: 'yum -y install'"
  exit 1
fi

[ "${PLAYBOOK}" != "" ] && playbook="${PLAYBOOK}" || playbook=''
[ "${WORKDIR}" != "" ] && wd="${WORKDIR}" || wd='/workspace'
[ "${PYPI}" != "" ] && pypifile="${PYPI}" || pypifile="${wd}/requirements.txt"
[ "${SYSPKGS}" != "" ] && pkgfile="${SYSPKGS}" || pkgfile="${wd}/system_packages.txt"
[ "${VAULTFILE}" != "" ] && vaultfile="${VAULTFILE}" || vaultfile="${wd}/vault-password.txt"
if [ "${GALAXY}" != "" ]; then
  galaxyfile="${GALAXY}"
elif [ -f "${wd}/requirements.yml" ]; then
  galaxyfile="${wd}/requirements.yml"
elif [ -f "${wd}/roles/requirements.yml" ]; then
  galaxyfile="${wd}/roles/requirements.yml"
else
  galaxyfile=""
fi

verbosity=''
skip_all=0
skip_playbook=0
cmd="ansible-playbook"

USAGE="""$0 [-x] [-y] [-h] [-*]

Installs pre-reqs and runs an Ansible playbook.
Version $(cat /VERSION)

  -x    Skip all dependency installs.
  -y    Skip playbook run.
  -h    Show this help message
  -*    Any option supported by ansible-playbook (eg: -e SOMEVAR=someval -i /path/to/inventory)


The following environment variables can be used to modify the playbook run:

  WORKDIR   Path to code location in the image. 
            Default: /workspace

  PLAYBOOK  Path to Ansible playbook.
            Default: ${wd}/test.yml > local.yml > playbook.yml > site.yml

  GALAXY    Path to Ansible Galaxy requirements file.
            Default: ${wd}/requirements.yml

  PYPI      Path to PyPI/pip requirements file
            Default: ${wd}/requirements.txt

  SYSPKGS   Path to a list of system packages to install, one per line.
            Default: ${wd}/system_packages.txt

  VAULTFILE Path to a plaintext file containing the Ansible Vault password.
            Default: ${wd}/vault-password.txt

  GPG_PK    Unencrypted GPG secret key to use with git-crypt.
"""

# doing this instead of getopts so we can trap "invalid" params and use them as
# part of the ansible-playbook command
while test $# -gt 0; do
    if [ "$1" == "-x" ]; then
      skip_all=1
    elif [ "$1" == "-y" ]; then
      skip_playbook=1
    elif [ "$1" == "-h" ]; then
      echo -e "${USAGE}"; exit 0
    else
      # this is janky as fuck, but it allows us to use inline json params for ansible
      if [[ "$1" == {* ]]; then
        cmd="${cmd} '${1}'"
      else
        cmd="${cmd} ${1}"
      fi
    fi

    shift
done

# print startup banner
source /etc/os-release
seq -s# 60 | tr -d '[:digit:]'
echo "# Launching Ansible Docker container startup script..."
echo "#  - Image v$(cat /VERSION)"
echo "#  - ${PRETTY_NAME}"
echo "#  - $(ansible --version | head -n 1)"
echo "#  - $(python --version 2>&1)"
seq -s# 60 | tr -d '[:digit:]'


# prep gpg key if necessary
if [ "${GPG_PK}" != "" ]; then
  echo -e "\n### GPG key found, importing..."
  eval $(gpg-agent --daemon 2> /dev/null)
  echo "${GPG_PK}" > /pk.key
  gpg --batch --yes --import /pk.key
  git-crypt unlock
fi

# autodetect vault-password.txt
if [ -f "${vaultfile}" ]; then
  echo -e "\n### Vault password file found at ${vaultfile}, using it in command."
  if [ "${VAULT_FILE_MODE}" != "" ]; then
    chmod "${VAULT_FILE_MODE}" "${vaultfile}"
  fi
  cmd="${cmd} --vault-password-file ${vaultfile}"
else
  echo -e "\n### No vault password file found at ${vaultfile}"
fi

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
  $PKG_CMD $pkgs
else
  echo -e "\n### No system package pre-reqs found at ${pkgfile}, moving on."
fi

# Look for a playbook file
if [ ! -f "${playbook}" ] && [ ! -f "${wd}/${playbook}" ]; then
  for pb in 'test.yml' 'local.yml' 'playbook.yml' 'site.yml'; do
    if [ -f "${wd}/${pb}" ]; then
      playbook="${wd}/${pb}"
      echo -e "\n### Found playbook: ${playbook}"
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
eval "${cmd} ${playbook}"

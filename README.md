# docker-ansible

For running Ansible locally.

### Usage

To test a role or playbook:
```
$ cd /path/to/role_repo
$ sudo docker run --rm -it -w /workspace -v $(pwd):/workspace inhumantsar/ansible
```

To run a playbook against hosts:
```
$ cd /path/to/playbook
$ sudo docker run --rm -it -w /workspace -v $(pwd):/workspace -v $HOME/.ssh:/root/.ssh inhumantsar/ansible
```

To debug:
```
$ cd /path/to/role
$ sudo docker run --rm -it -w /workspace -v $(pwd):/workspace inhumantsar/ansible /bin/bash
/workspace #  ansible-galaxy install -r requirements.yml
/workspace #  ansible-playbook test.yml -vvv
```

### Default Behaviour
* Expects the role or playbook directory to be mounted to `/workspace` 
  * eg: `$HOME/src/ansible-role-moo:/workspace`
* Looks for and runs a playbook named (in order of precendence): 
  1. `test.yml`
  2. `local.yml`
  3. `playbook.yml`
* Installs Python requirements found in `requirements.txt` by default
* Installs Ansible Galaxy requirements found in `requirements.yml` by default
* Defaults to localhost-only inventory. (ie: `'localhost,'`)


#### Overrides
```
./start.sh [-p test.yml] [-g requirements.yml] [-r requirements.txt] [-i 'localhost,'] [-v] [-h]
  Installs pre-reqs and runs an Ansible playbook. Looks for / falls back to test.yml,
  local.yml, and playbook.yml by default.

  -p    Path to Ansible playbook
  -g    Path to Ansible Galaxy requirements file (default: requirements.yml)
  -r    Path to PyPI/pip requirements file (default: requirements.txt)
  -i    Inventory string passed directly to Ansible (default: localhost,)
  -v    Enable debug messages
  -h    Show this help message
```

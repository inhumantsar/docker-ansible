# docker-ansible

For running Ansible locally.

### Usage

To test a role or playbook:
```
$ cd /path/to/repo
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

To test something which uses Docker:
```
$ cd /path/to/repo
$ sudo docker run --rm -it -w /workspace -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd):/workspace inhumantsar/ansible
```

### Default Behaviour
* Expects the role or playbook directory to be mounted to `/workspace`
  * eg: `$HOME/src/ansible-role-moo:/workspace`
* Looks for and runs a playbook named (in order of precendence):
  1. `test.yml`
  2. `local.yml`
  3. `playbook.yml`
  4. `site.yml`
* Installs Python requirements found in `requirements.txt` with `pip`
* Installs Ansible Galaxy requirements found in `requirements.yml` with `ansible-galaxy`
* Installs system packages found in `system_packages.txt` with `yum` or `apk`
* Defaults to localhost-only inventory. (ie: `'localhost,'`)


#### Overrides
```
/start.sh [-p test.yml] [-g requirements.yml] [-r requirements.txt] [-s system_packages.txt] [-x] [-*] [-h]
  Installs pre-reqs and runs an Ansible playbook.

  -p    Path to Ansible playbook (default: test.yml > local.yml > playbook.yml > site.yml)
  -g    Path to Ansible Galaxy requirements file (default: requirements.yml)
  -r    Path to PyPI/pip requirements file (default: requirements.txt)
  -s    Path to a list of system packages to install, one per line. (default: system_packages.txt)
  -x    Skip all dependency installs.
  -*    Any option supported by ansible-playbook (eg: -e SOMEVAR=someval -i /path/to/inventory)
  -v    Enable debug messages
  -h    Show this help message
```

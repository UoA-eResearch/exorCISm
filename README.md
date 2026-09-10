# exorCISm

CIS Benchmark hardening for Centre for eResearch-managed servers

- Packaged as one Ansible role per operating system target
- Running the role with its shipped defaults gives a sensibly hardened host
- It does not implement every CIS control, because some of them break working systems
- Controls that carry that risk are opt-in

## Requirements

- ansible-core

## Installing the collection

Install straight from the repository:

```sh
ansible-galaxy collection install git+https://github.com/UoA-eResearch/exorCISm.git
```

To pin a version in a project, add it to a `requirements.yml` and install from that:

```yaml
collections:
  - name: https://github.com/UoA-eResearch/exorCISm.git
    type: git
    version: main
```

```sh
ansible-galaxy collection install -r requirements.yml
```

## Usage

### Run the shipped playbook

The collection includes a playbook that applies the role with no further setup. Reference it by its full name and pass your inventory on the command line:

```sh
ansible-playbook uoa_eresearch.exorcism.ubuntu2404 -i inventory.yml
```

Target a single group or host from the same inventory with `--limit`:

```sh
ansible-playbook uoa_eresearch.exorcism.ubuntu2404 -i inventory.yml --limit web
```

Target one host with no inventory file at all, using a trailing comma:

```sh
ansible-playbook uoa_eresearch.exorcism.ubuntu2404 -i 'web01.example.org,'
```

Set variables on the command line with `-e`:

```sh
ansible-playbook uoa_eresearch.exorcism.ubuntu2404 -i inventory.yml \
  -e '{"exorcism_ssh_allow_users": ["alice", "bob"]}'
```

### Write your own playbook

Most teams will want their own playbook so the variables live in their repository and get reviewed like any other change:

```yaml
- name: Harden research compute nodes
  hosts: compute
  become: true
  roles:
    - role: uoa_eresearch.exorcism.ubuntu2404
      vars:
        exorcism_ssh_allow_users: [alice, bob]
        exorcism_ipv4_ip_forward: 1
```

### Set variables per host group

For a mixed estate, put the variables in inventory instead so each group gets what it needs and the playbook stays empty:

```yaml
all:
  children:
    docker_hosts:
      vars:
        exorcism_ipv4_ip_forward: 1
      hosts:
        docker01:
    bastions:
      vars:
        exorcism_ssh_disable_forwarding: false
      hosts:
        bastion01:
```

### Apply part of the role

Every CIS section carries a tag, so you can apply or skip sections individually. List them with `--list-tags`:

```sh
ansible-playbook uoa_eresearch.exorcism.ubuntu2404 -i inventory.yml --list-tags
```

Then run only what you want, or skip what you do not:

```sh
ansible-playbook uoa_eresearch.exorcism.ubuntu2404 -i inventory.yml --tags 5.1_ssh
ansible-playbook uoa_eresearch.exorcism.ubuntu2404 -i inventory.yml --skip-tags 4.4_firewall
```

## Connecting to hosts

The role changes SSH configuration, so it is worth being deliberate about how you connect.

| Flag | Purpose |
|---|---|
| `-u alice` | Connect as a specific remote user |
| `--private-key ~/.ssh/id_ed25519` | Use a specific SSH key |
| `-k` | Prompt for the SSH password instead of using a key |
| `-K` | Prompt for the sudo password on the target |
| `--become-user admin` | Escalate to a user other than root |

A typical first run against an unfamiliar host, prompting for both passwords:

```sh
ansible-playbook uoa_eresearch.exorcism.ubuntu2404 -i 'web01.example.org,' -u alice -k -K
```

## Before you run it for real

Do a dry run first. This reports what would change without changing anything, and prints a diff of every file it would write:

```sh
ansible-playbook uoa_eresearch.exorcism.ubuntu2404 -i inventory.yml --check --diff
```

Read the diff for `/etc/ssh/sshd_config.d/90-ssh.conf` in particular. If you have set `exorcism_ssh_allow_users`, confirm your own account is in the list before applying, and keep a second session open while the first real run completes.

## Variables

Every variable is optional. Running the role with none set still hardens the host.

Start from the worked example, which shows the variables most people set and explains when each one matters:

```sh
ansible-galaxy collection install git+https://github.com/UoA-eResearch/exorCISm.git
cat ~/.ansible/collections/ansible_collections/uoa_eresearch/exorcism/playbooks/ubuntu2404_example.yml
```

For the complete reference, with every variable's type, default and permitted values:

```sh
ansible-doc -t role uoa_eresearch.exorcism.ubuntu2404
```

Variables fall into three kinds. Some are values the role cannot guess, such as which accounts may log in over SSH. Some are controls applied by default that you turn off when one breaks something, such as the kernel module blacklist on a container host. The rest are extra hardening left off by default because it can break a working system, such as letting the role own the firewall. The example playbook is grouped in that order.

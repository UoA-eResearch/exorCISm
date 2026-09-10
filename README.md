# exorCISm

CIS Benchmark hardening for Linux, packaged as one Ansible role per operating system target. The collection is `uoa_eresearch.exorcism`, and the role for Ubuntu 24.04 LTS is `ubuntu2404`.

Running the role with its shipped defaults gives a sensibly hardened host. It does not implement every CIS control, because some of them break working systems. Controls that carry that risk are opt-in, and everything the role cannot guess is a variable you supply.

## Requirements

- ansible-core 2.15 or later

## Install

```sh
ansible-galaxy collection install git+https://github.com/UoA-eResearch/exorCISm.git
```

To pin it in a project, add a git entry to your `requirements.yml` and install with `ansible-galaxy collection install -r requirements.yml`.

## Quick start

Always dry run first. This changes nothing and prints a diff of every file the role would write.

```sh
ansible-playbook uoa_eresearch.exorcism.ubuntu2404 -i inventory.yml --check --diff
```

Read the diff for `/etc/ssh/sshd_config.d/90-ssh.conf` before anything else. If you have set `exorcism_ssh_allow_users`, confirm your own account appears in it. Getting that wrong locks everyone out of the host.

When the diff looks right, apply it, and keep a second session open until you have confirmed you can still log in.

```sh
ansible-playbook uoa_eresearch.exorcism.ubuntu2404 -i inventory.yml
```

Add `--limit web01` to target one host or group.

## Variables

Every variable is optional. Running the role with none set still hardens the host. These are the ones most hosts need.

| Variable | Default | Set this when |
|---|---|---|
| `exorcism_ssh_allow_users` | `[]` | Restricting SSH to named accounts. Empty permits all users, and setting it replaces the list rather than adding to it |
| `exorcism_ipv4_ip_forward` | `0` | The host routes traffic, such as Docker, KVM, k3s or NAT |
| `exorcism_blacklist_kernel_modules_exclude` | `[]` | The host runs containers, which need `overlay`, or uses snaps, which need `squashfs` |
| `exorcism_ntp_servers` | `[]` | You have internal time servers |
| `exorcism_password_excluded_users` | `[]` | Service accounts must not have passwords expire or lock |
| `exorcism_ssh_disable_forwarding` | `true` | It is a bastion, or users need port forwarding. Set `false` |

For a worked example covering these in context, see [playbooks/ubuntu2404_example.yml](playbooks/ubuntu2404_example.yml). For the complete reference of all 31 variables with types, defaults and permitted values, run `ansible-doc -t role uoa_eresearch.exorcism.ubuntu2404`.

Variables fall into three kinds. Some are values the role cannot guess. Some are controls applied by default that you turn off when one breaks something. The rest are extra hardening left off by default because it can break a working system.

## Writing your own playbook

Most teams want their own playbook, so the variables live in their repository and get reviewed like any other change.

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

For a mixed estate, put the variables in inventory group vars instead, so each group gets what it needs and the playbook stays empty.

## Connecting to hosts

The role changes SSH configuration, so be deliberate about how you connect.

| Flag | Purpose |
|---|---|
| `-u alice` | Connect as a specific remote user |
| `--private-key ~/.ssh/id_ed25519` | Use a specific SSH key |
| `-k` | Prompt for the SSH password instead of using a key |
| `-K` | Prompt for the sudo password on the target |

## Applying part of the role

Every CIS section carries a tag, so sections can be applied or skipped individually. List them with `--list-tags`, then use `--tags 5.1_ssh` to run one or `--skip-tags 4.4_firewall` to exclude one.

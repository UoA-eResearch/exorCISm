# Changelog

## 0.5.0 - 2026-09-29

### Added

- Remove the nis, rsh and talk clients, and purge every insecure client package
- Add an optional GRUB password that never blocks an unattended boot
- Mask the avahi, web or print server where purging it is not possible, purge the cups daemon too
- Accept IPv6 router advertisements on named interfaces only

### Changed

- Keep AES-GCM and encrypt-then-MAC for SSH clients, validate the SSH configuration first
- Forward journald logs to rsyslog
- Remove message of the day scripts that name the operating system

### Fixed

- Fix the SSH reload on hosts that start sshd from its socket
- Fix log file permissions on append-only files
- Fix crontab access for allowed users, skip the cron controls where cron is absent
- Stop password ageing overwriting values stricter than the benchmark
- Stop ufw overriding the kernel parameters, fix their reload with IPv6 disabled
- Fix switching a host from timesyncd to chrony
- Fix PAM profiles staying disabled, duplicated lockout values and the su prompt order

## 0.4.0 - 2026-09-25

### Added

- Lock the GDM settings so users cannot override them
- Add a variable for the timesyncd fallback time servers
- Validate the sudo configuration before writing it

### Changed

- Keep post-quantum key exchange algorithms available to SSH clients
- Move the default umask into a profile drop-in

### Fixed

- Fix the sudo defaults not being applied, add use_pty to them
- Fix password expiry, inactive locking and history settings not being applied
- Remove the tnftp client as well as ftp
- Reload kernel parameters only when they change

## 0.3.0 - 2026-09-21

### Added

- Configure the process hardening kernel parameters and systemd-coredump
- Disable wireless interfaces, bluetooth and the uncommon network protocol modules
- Remove the avahi, web and print server packages, with a variable for each
- Configure the GDM login screen where GDM is installed
- Add AppArmor and AIDE sections, off by default
- Cover the forwarding parameters, cron.yearly, the ftp client and the message of the day
- Grant SSH access by group, let a host omit sshd keywords another tool owns

### Changed

- Renumber every control reference to the CIS Ubuntu 24.04 Benchmark v2.0.0
- Mask the journal remote socket and service instead of installing the package

### Fixed

- Exclude local reference files and scan exports from collection builds

## 0.2.0 - 2026-09-18

### Added

- Add variables for reverse path filtering, router advertisements, apport and the message of the day

### Changed

- Report cron and log file mode changes as one line per path
- Leave the lastlog, btmp and wtmp files at their shipped modes

### Fixed

- Stop widening log files already tighter than 0640, show the changes in check mode
- Exclude local inventories from collection builds

## 0.1.0 - 2026-09-11

### Added

- Add a CIS Benchmark hardening role for Ubuntu 24.04 LTS
- Add per-section tags to apply or skip controls individually
- Document every variable with its default and permitted values
- Add a worked example playbook

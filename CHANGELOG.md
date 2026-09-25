# Changelog

## 0.4.0 - 2026-09-25

### Added

- Lock the GDM dconf keys, so 1.7.1 to 1.7.5 satisfy their lock check
- Add `exorcism_ntp_fallback_servers` for the timesyncd `FallbackNTP` parameter
- Validate the sudo drop-in with `visudo` before writing it

### Changed

- Write the default umask to `/etc/profile.d`, which is where v2.0.0 audits it
- Make `KexAlgorithms` subtractive, so post-quantum algorithms stay available
- Name the sudo drop-in `90-sudo`, which sudo reads, rather than `90-sudo.conf`

### Fixed

- Remove the `tnftp` package as well as `ftp`
- Reload sysctl through the handler, rather than on every run of section 3.3
- Tag the 5.4.1.1 login.defs task, which `--tags 5.4_password` skipped
- Set the inactive password lock with `chage`, which the user module left unset
- Write the password history remember value to `pwhistory.conf`, not `opasswd`
- Set `use_pty` in the sudo defaults

## 0.3.0 - 2026-09-21

### Added

- Configure the process hardening kernel parameters and systemd-coredump
- Disable wireless interfaces, bluetooth and the uncommon network protocol modules
- Remove the avahi, web and print server packages, with a variable for each
- Configure the GDM login screen where GDM is installed
- Add AppArmor and AIDE sections, off by default
- Cover the forwarding parameters, cron.yearly, the ftp client and the message of the day files
- Grant SSH access by group, let a host omit sshd keywords another tool owns

### Changed

- Renumber every control reference to the CIS Ubuntu 24.04 Benchmark v2.0.0
- Mask the journal remote socket and service instead of installing the package

### Fixed

- Correct the chrony, timesyncd and sshd banner control numbers
- Exclude local reference files and scan exports from collection builds

## 0.2.0 - 2026-09-18

### Added

- Add variables for reverse path filtering, router advertisements, apport and the message of the day

### Changed

- Report cron and log file mode changes as one line per path
- Leave the lastlog, btmp and wtmp files at their shipped modes

### Fixed

- Stop widening log files already tighter than 0640, show the changes in check mode
- Force the collection install in the test make target
- Exclude local inventories from collection builds

## 0.1.0 - 2026-09-11

### Added

- Add a CIS Benchmark hardening role for Ubuntu 24.04 LTS
- Add per-section tags to apply or skip controls individually
- Document every variable with its default and permitted values
- Add a worked example playbook

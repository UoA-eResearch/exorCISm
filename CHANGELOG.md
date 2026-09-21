# Changelog

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

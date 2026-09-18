# Changelog

## 0.2.0 - 2026-09-18

### Added

- Add `exorcism_rp_filter` for multi-homed hosts that need loose reverse path filtering
- Add `exorcism_ipv6_accept_ra` for hosts addressed by SLAAC
- Add `exorcism_remove_apport` to satisfy 1.5.5 without purging apport
- Add `exorcism_motd_text`, so a site keeps its own `/etc/motd` while `/etc/issue` keeps the warning

### Changed

- Report 2.4.1.2 to 2.4.1.7 and 6.1.4.1 permission changes as one line per path, with the old and new mode
- Leave `lastlog`, `btmp` and `wtmp` at their shipped modes

### Fixed

- Stop 6.1.4.1 widening log files already tighter than 0640
- Show the 6.1.4.1 log file changes in check mode, which a shell task had hidden
- Force the collection install in the `test` make target
- Exclude `local/` from collection builds, which were packaging personal inventories

## 0.1.0 - 2026-09-11

### Added

- Add a CIS Benchmark hardening role for Ubuntu 24.04 LTS
- Add per-section tags so controls can be applied or skipped individually
- Add documented argument specs for every variable, with defaults and permitted values
- Add a worked example playbook covering the variables most hosts need

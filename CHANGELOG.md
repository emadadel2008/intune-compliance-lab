# Changelog

All notable changes to this project are documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Fixed

- **RDP blocked when the example IP was left in `terraform.tfvars`.** `allowed_rdp_cidr` now rejects RFC 5737 documentation addresses (`192.0.2.x`, `198.51.100.x`, `203.0.113.x`) instead of deploying a rule that matches no real client.
- `scripts/deploy.ps1` now waits for Notepad to close before running `terraform plan`, so a newly created `terraform.tfvars` is edited before it is used.

### Added

- `allowed_rdp_cidr` is now optional. If unset, Terraform detects the public IPv4 of the machine running it (`data.http.admin_public_ip`, `api.ipify.org`) and allows that `/32`. This uses the previously unused `http` provider.
- Output `rdp_allowed_source` shows the source CIDR in effect.

### Security

- **Fixed RDP exposure in `terraform/security.tf`.** The NSG rule allowed TCP 3389 from any source (`"*"`), so the validated `allowed_rdp_cidr` variable was never used. The rule now uses `source_address_prefix = var.allowed_rdp_cidr`, and it was renamed from `Allow-RDP-From-Internet` to `Allow-RDP-From-Admin-IP`.
  - **Action required:** if you deployed an earlier version, run `terraform apply`. The plan shows the `azurerm_network_security_rule.allow_rdp` resource being **replaced** (destroyed and recreated), because its name changed. The VMs, NICs, and public IPs are not recreated. RDP is briefly unavailable during the replacement.

### Documentation

- Rewrote `README.md` as a landing page with architecture diagram, feature status, quick start, and navigation.
- Added a documentation set under `docs/`: index, prerequisites, setup guide, device enrollment, compliance policies, Conditional Access, lab scenarios, validation and testing, troubleshooting, security considerations, FAQ, and glossary.
- Rewrote `docs/architecture.md`. It previously described the NSG as associated with the subnet; it is associated with each VM NIC.
- Converted `docs/intune-configuration.md` into a linked post-deployment checklist.
- Moved `README 3.md` to `docs/client02-lab-script.md` and added navigation.
- Added `docs/images/README.md` with a screenshot capture list.
- Added `CONTRIBUTING.md` and this changelog.
- Added a numbered step-by-step lab guide: `docs/00-lab-overview.md` through `docs/07-cleanup.md`, linked from `README.md` and `docs/index.md`.
- Restructured `README.md` into seven numbered lab steps, each with why, commands, expected result, and a guide link; added a quick troubleshooting table.

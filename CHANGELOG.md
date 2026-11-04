# Changelog

All notable changes to this project are documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

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

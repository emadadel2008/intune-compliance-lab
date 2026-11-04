# Security considerations

[← Documentation home](index.md)

This lab deliberately creates an **insecure** device state on an Internet-reachable VM, inside a tenant that may hold real identities. This page lists the risks and the controls that reduce them.

## Threat model summary

| Asset | Threat | Control in this repository | Your responsibility |
|---|---|---|---|
| VM RDP endpoint | Brute force / exploitation from the Internet | NSG allows TCP 3389 **only** from `allowed_rdp_cidr` (`/32` enforced by validation) | Keep `allowed_rdp_cidr` current; consider Azure Bastion or JIT VM access |
| Local admin credential | Leak through repo or state | Password is a sensitive variable, never in `tfvars.example`; `*.tfvars` and `*.tfstate*` are git-ignored | Use a unique strong password; protect or delete local state |
| CLIENT-02 during `Apply` | Firewall and RTP disabled | Script backs up and restores; warns when Defender changes are blocked | Keep the window short; don't browse or handle data; `Restore` promptly |
| Entra tenant | CA misconfiguration causing lockout | Docs require Report-only, scoped users, break-glass exclusion | Follow [Conditional Access](conditional-access.md) guidance |
| Tenant-wide settings | Lab changes affect production devices | Docs flag tenant-wide settings | Prefer a dedicated lab or developer tenant |
| Public repository | Leakage of tenant/subscription IDs, IPs, secrets | `.gitignore` for state, tfvars, keys and certs; placeholders in docs | Review diffs before committing |

## RDP exposure

> [!IMPORTANT]
> Earlier versions of `terraform/security.tf` allowed RDP from **any** source (`"*"`). This is fixed: the rule `Allow-RDP-From-Admin-IP` now uses `var.allowed_rdp_cidr`. If you deployed an older version, run `terraform apply` again. See [CHANGELOG.md](../CHANGELOG.md).

- Defense in depth: the NSG is the main control. During `Apply`, the Windows Firewall on CLIENT-02 is **off**, so the NSG is the **only** network control.
- Safer alternatives (not implemented): [Azure Bastion](https://learn.microsoft.com/azure/bastion/bastion-overview), [Just-in-time VM access](https://learn.microsoft.com/azure/defender-for-cloud/just-in-time-access-usage), or a point-to-site VPN without public IPs.
- Never widen `allowed_rdp_cidr`. The `/32` validation exists to prevent that.

## Secrets and Terraform state

- `admin_password` is marked `sensitive = true`, which **only hides it from CLI output**. It is stored in plain text in `terraform.tfstate`.
- Local state is stored in the `terraform\` directory and is git-ignored. For shared use, configure a remote backend with encryption and access control. This is not implemented in the repository.
- Pass the password through `TF_VAR_admin_password` for one session, then remove the variable. See [Setup guide, Step 5](setup-guide.md#step-5-apply).
- Never paste passwords, tokens, or connection strings into issues, PRs, or docs.

## The drift script

[`Set-Client02LabState.ps1`](../Set-Client02LabState.ps1):

- Requires elevation and refuses to run otherwise.
- Changes **only** Windows Firewall profile states and the Defender `DisableRealtimeMonitoring` preference.
- Does **not** stop the Defender service, uninstall AV, change RDP, or bypass Tamper Protection.
- Refuses to `Apply` twice, which protects the original backup.
- Writes a backup containing the computer name and timestamp to `%ProgramData%\IntuneLab\`. It contains no secrets.

**Run it only on the disposable lab VM `CLIENT-02`.** Never run it on a workstation or a production device.

## Identity hygiene

- Use a dedicated, licensed, **non-admin** test user for joining and CA testing. The joining user becomes a local admin on the VM.
- Exclude emergency access accounts from every CA policy.
- Use least-privilege admin roles. See [Prerequisites → roles](prerequisites.md#administrative-roles).
- Delete the lab devices from Intune and Entra ID, and delete the lab groups and policies, when you are done. See [Scenario 6](lab-scenarios.md#scenario-6-cleanup).

## Public repository hygiene

Before you commit, check that the diff contains none of the following:

| Never commit | Use instead |
|---|---|
| Tenant ID, tenant domain | `YOUR_TENANT_ID`, `YOUR_TENANT_DOMAIN` |
| Subscription ID | `YOUR_SUBSCRIPTION_ID` |
| Real public IPs | `YOUR_PUBLIC_IP`, or `203.0.113.0/24` / `198.51.100.0/24` documentation ranges |
| User principal names, emails | `YOUR_TEST_USER`, `YOUR_ADMIN_ACCOUNT` |
| Device IDs, object IDs, correlation IDs | Redact them |
| `terraform.tfvars`, `*.tfstate*`, `*.tfplan` | Already git-ignored |
| Screenshots with identifiers | Redact before adding to `docs/images/` |

A quick local scan before committing:

```powershell
git diff --cached | Select-String -Pattern '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}', '\b(?:\d{1,3}\.){3}\d{1,3}\b', 'password\s*=', '@[A-Za-z0-9.-]+\.(com|net|org|onmicrosoft\.com)'
```

Review any matches. Documentation IP ranges and `10.40.x.x` private addresses are expected.

## Cost as a security concern

Forgotten lab resources keep running and keep an RDP endpoint exposed. Destroy the lab when finished, and consider an Azure budget alert on the subscription.

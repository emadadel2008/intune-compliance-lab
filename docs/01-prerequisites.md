# 01 - Prerequisites

[← 00 - Lab overview](00-lab-overview.md) · Next: [02 - Azure infrastructure](02-azure-infrastructure.md)

Confirm everything on this page before deploying. Details and rationale: [Prerequisites (reference)](prerequisites.md).

## Licensing

| Who | License | Why |
|---|---|---|
| Test user (`YOUR_TEST_USER`) | Microsoft Intune Plan 1 | MDM enrollment and compliance |
| Test user | Microsoft Entra ID P1 | Conditional Access |
| Windows on the VMs | Eligible Windows 11 Enterprise licensing | `license_type = "Windows_Client"` in Terraform |

Microsoft 365 E3/E5 or EMS E3/E5 include Intune Plan 1 and Entra ID P1. See [Microsoft Intune licensing](https://learn.microsoft.com/mem/intune/fundamentals/licenses).

## Roles

| Task | Least-privilege role |
|---|---|
| Deploy Azure resources | Contributor on the subscription or resource group |
| Configure automatic enrollment, compliance policy | Intune Administrator |
| Allow users to join devices (device settings) | Cloud Device Administrator |
| Configure Conditional Access | Conditional Access Administrator |
| Read sign-in logs | Reports Reader or Security Reader |
| Create groups | Groups Administrator |

Full list: [Prerequisites → Administrative roles](prerequisites.md#administrative-roles).

## Accounts

- [ ] A dedicated, licensed, **non-admin** test user: `YOUR_TEST_USER@YOUR_TENANT_DOMAIN`. Do not use a Global Administrator to join devices; the joining user becomes a local administrator on the VM.
- [ ] At least one emergency access (break-glass) account that you will exclude from Conditional Access. See [Manage emergency access accounts](https://learn.microsoft.com/entra/identity/role-based-access-control/security-emergency-access).
- [ ] The test user can complete MFA if your tenant requires it.

## Workstation preparation

- [ ] Windows with PowerShell 5.1 or 7.
- [ ] [Terraform](https://developer.hashicorp.com/terraform/install) 1.6 or later.
- [ ] [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli), signed in with `az login`.
- [ ] A Remote Desktop client.
- [ ] Resource providers `Microsoft.Compute` and `Microsoft.Network` registered on the subscription (Terraform does not register them):

```powershell
az provider register --namespace Microsoft.Compute
az provider register --namespace Microsoft.Network
```

## Cost

Two Windows VMs, managed disks, and two Standard static public IPs incur charges while they exist. Deallocate the VMs between sessions and destroy the lab when finished. See [Cost considerations](prerequisites.md#cost-considerations).

## Done when

- [ ] Licenses assigned to the test user.
- [ ] Roles available to your admin account.
- [ ] Tools installed and `az account show` shows the intended subscription.

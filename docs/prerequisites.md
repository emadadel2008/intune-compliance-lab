# Prerequisites

[← Documentation home](index.md)

Review everything on this page **before** running `terraform apply`. Most lab failures come from a missing license, role, or regional capacity, not from the code.

## Checklist

- [ ] Azure subscription with permission to create resources
- [ ] Terraform CLI `>= 1.6` and Azure CLI installed
- [ ] A Remote Desktop client
- [ ] Your public IPv4 address
- [ ] A Microsoft Entra tenant with Intune and Entra ID P1 licensing
- [ ] An administrator account with the roles listed below
- [ ] A licensed **test user** (not an administrator) for enrollment and Conditional Access testing
- [ ] An emergency access ("break-glass") account to exclude from Conditional Access
- [ ] Budget approval for the Azure resources

## Azure

| Requirement | Detail |
|---|---|
| Subscription | Associated with the same Entra tenant you will enroll the devices into (recommended) |
| Azure RBAC role | **Contributor** (or Owner) on the subscription. Terraform creates a resource group; it creates no role assignments. |
| Resource providers | `Microsoft.Compute` and `Microsoft.Network` must already be registered. [`providers.tf`](../terraform/providers.tf) sets `resource_provider_registrations = "none"`, so Terraform will **not** register them for you. |
| Region | Must offer the Windows 11 image SKU (`win11-24h2-ent` by default), your VM size, Trusted Launch, and available quota |
| Quota | At least 4 vCPUs of the selected family for two `Standard_B2ms` VMs, plus 2 Standard public IPs |

Check provider registration and image availability:

```powershell
az provider show --namespace Microsoft.Compute --query registrationState -o tsv
az provider show --namespace Microsoft.Network --query registrationState -o tsv

# Replace YOUR_REGION, for example uaenorth or westeurope
az vm image list --location YOUR_REGION --publisher MicrosoftWindowsDesktop `
  --offer Windows-11 --sku win11-24h2-ent --all --output table

az vm list-skus --location YOUR_REGION --size Standard_B2ms --output table
```

## Tools

| Tool | Minimum | Used by |
|---|---|---|
| [Terraform CLI](https://developer.hashicorp.com/terraform/install) | 1.6.0 (from `versions.tf`) | All infrastructure |
| [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) | Current | Authentication for the azurerm provider; `scripts/deploy.ps1` checks for it |
| PowerShell | Windows PowerShell 5.1 or PowerShell 7 | `scripts/*.ps1`, `Set-Client02LabState.ps1` |
| Remote Desktop client | `mstsc.exe` or equivalent | Connecting to the VMs |
| Microsoft Graph PowerShell SDK (optional) | Current | Optional validation commands in [Validation and testing](validation-and-testing.md) |

## Microsoft 365 / Entra / Intune licensing

> [!IMPORTANT]
> Licensing is your responsibility. Confirm entitlements with your Microsoft licensing agreement. The table summarizes what the lab's features need.

| Capability | Typical license requirement |
|---|---|
| Windows 11 Enterprise on Azure VMs (`license_type = "Windows_Client"`) | Eligible per-user Windows Enterprise E3/E5 (or Microsoft 365 E3/E5) subscription. See [Deploy Windows 11 on Azure](https://learn.microsoft.com/azure/virtual-machines/windows/windows-desktop-multitenant-hosting-deployment). |
| Intune device management and compliance policies | Microsoft Intune Plan 1 (included in Microsoft 365 E3/E5, EMS E3/E5, Microsoft 365 Business Premium). See [Intune licensing](https://learn.microsoft.com/mem/intune/fundamentals/licenses). |
| Automatic MDM enrollment during Entra join | Microsoft Entra ID P1 or higher |
| Conditional Access | Microsoft Entra ID P1 or higher |

Assign the licenses to the **test user** who will Entra-join and enroll the devices.

## Administrative roles

Use least privilege. Built-in roles that cover each task:

| Task | Suggested role |
|---|---|
| Deploy Azure resources | Azure **Contributor** on the subscription |
| Configure MDM automatic enrollment (MDM user scope) | **Intune Administrator** (or Global Administrator) |
| Allow users to join devices to Entra ID (device settings) | **Cloud Device Administrator** or Global Administrator |
| Create device groups | **Groups Administrator** (or Intune Administrator for security groups) |
| Create and assign compliance policies; view reports | **Intune Administrator**, or the Intune RBAC role **Policy and Profile Manager** |
| Create Conditional Access policies | **Conditional Access Administrator** or **Security Administrator** |
| Read sign-in logs | **Reports Reader**, **Security Reader**, or **Global Reader** |

References: [Intune RBAC](https://learn.microsoft.com/mem/intune/fundamentals/role-based-access-control) · [Entra built-in roles](https://learn.microsoft.com/entra/identity/role-based-access-control/permissions-reference)

## Tenant configuration you will need

These settings are tenant-wide. In a shared or production tenant, coordinate with the tenant owners before changing them.

| Setting | Where (may move) | Requirement |
|---|---|---|
| Users may join devices to Microsoft Entra | Entra admin center → **Identity → Devices → Device settings** | Includes your test user (All, or a group containing the user) |
| MDM user scope | Intune admin center → **Devices → Windows → Enrollment → Automatic Enrollment** | **Some** (a group containing the test user) or **All** |
| Windows enrollment restrictions | Intune admin center → **Devices → Enrollment → Device platform restriction** | Windows (MDM) allowed for the test user |
| Device limit | Intune admin center → **Devices → Enrollment → Device limit restrictions** | Allows at least 2 devices for the test user |

## Cost considerations

The lab creates these billable resources while it exists:

| Resource | Quantity | Billing note |
|---|---|---|
| Windows VMs (`Standard_B2ms` default) | 2 | Compute is billed while running; stops when **deallocated** |
| Managed OS disks (`StandardSSD_LRS`) | 2 | Billed while the disks exist, even when VMs are deallocated |
| Standard static public IPv4 | 2 | Billed while allocated, even when VMs are deallocated |
| Boot diagnostics (managed storage) | 2 | Small storage charge |

Use the [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/) for your region. Deallocate the VMs between sessions (`az vm deallocate`) and run `terraform destroy` when you are finished.

> [!TIP]
> Deallocated VMs cannot check in with Intune. Start them, sign in, and sync **before** reviewing compliance reports.

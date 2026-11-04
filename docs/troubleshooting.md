# Troubleshooting

[← Documentation home](index.md)

Find your symptom and follow the fix. When you open an issue, **redact** tenant IDs, subscription IDs, IP addresses, user names, and device IDs.

## Contents

- [Terraform and Azure deployment](#terraform-and-azure-deployment)
- [Remote Desktop connectivity](#remote-desktop-connectivity)
- [Entra join and Intune enrollment](#entra-join-and-intune-enrollment)
- [Compliance evaluation](#compliance-evaluation)
- [CLIENT-02 drift script](#client-02-drift-script)
- [Conditional Access](#conditional-access)
- [Collecting diagnostics](#collecting-diagnostics)

## Terraform and Azure deployment

| Symptom / error | Cause | Fix |
|---|---|---|
| `Terraform CLI was not found` / `Azure CLI was not found` (from `deploy.ps1`) | Tool not installed or not on `PATH` | Install it, then reopen PowerShell |
| `Azure CLI is not authenticated. Run az login.` | No Azure CLI session | `az login`, then `az account set --subscription "YOUR_SUBSCRIPTION_ID"` |
| `Cannot find path '...\terraform.tfvars.example'` | `deploy.ps1` / `destroy.ps1` run from the wrong directory | `cd terraform`, then `..\scripts\deploy.ps1` |
| Plan used example values / RDP fails after first deploy | `deploy.ps1` created `terraform.tfvars` and continued before you edited it | Edit `terraform.tfvars`, then rerun `terraform plan` / `apply` |
| `allowed_rdp_cidr must be a valid IPv4 /32 CIDR...` | Missing `/32`, IPv6, or a typo | Use `YOUR_PUBLIC_IP/32` |
| `allowed_rdp_cidr is still an example documentation address` | The example value `203.0.113.10/32` was left in `terraform.tfvars` | Set your real IP, or remove the line to auto-detect |
| `Could not detect your public IPv4 address from api.ipify.org` | No outbound access to `api.ipify.org` (proxy, firewall) | Set `allowed_rdp_cidr = "YOUR_PUBLIC_IP/32"` in `terraform.tfvars` |
| `admin_password must be at least 12 characters long.` | Short password | Use a longer password |
| Azure rejects the password (`InvalidParameter` on `adminPassword`) | Azure complexity rules not met | Use upper, lower, digit, and symbol; avoid disallowed values such as `Password1!` |
| `MissingSubscriptionRegistration` | `providers.tf` sets `resource_provider_registrations = "none"` | `az provider register --namespace Microsoft.Compute` (and `Microsoft.Network`), then wait for `Registered` |
| `SkuNotAvailable` | VM size not offered or restricted in the region | Change `vm_size` or `location` |
| `PlatformImageNotFound` / image not found | `windows_sku` not available in the region | List SKUs with `az vm image list-skus -l YOUR_REGION -p MicrosoftWindowsDesktop -f Windows-11 -o table` |
| Trusted Launch / security type error | Size or image doesn't support Trusted Launch (Gen2) | Choose a Trusted Launch–capable size; see [Trusted Launch](https://learn.microsoft.com/azure/virtual-machines/trusted-launch) |
| `OperationNotAllowed` ... quota | Regional vCPU quota exceeded | Request a quota increase or choose a smaller size or another region |
| Resources exist but Terraform wants to create them again | State file lost or a different working directory | Use the original `terraform.tfstate`, or delete the resource group manually: `az group delete -n intune-lab-rg` |

## Remote Desktop connectivity

| Symptom | Cause | Fix |
|---|---|---|
| Connection times out, portal shows `DefaultRule_DenyAllInBound` | Your public IP changed, or your egress IP differs (VPN, proxy, CGNAT) | Compare `terraform output rdp_allowed_source` with the portal's **Source IP**. Run `terraform apply` (auto-detect), or update `allowed_rdp_cidr` and apply |
| Times out right after an upgrade | Old open rule replaced; new rule uses an outdated IP | Same as above |
| Times out; NSG correct | VM deallocated or still booting | `az vm start ...`; check boot diagnostics in the portal |
| "The user name or password is incorrect" after Entra join | Windows tries to resolve the user name against Entra ID | Sign in as `.\labadmin` |
| Cannot RDP as the Entra user | Extra configuration needed | See [optional Entra RDP](device-enrollment.md#signing-in-with-the-entra-account-over-rdp-optional) |
| Lost RDP after an Intune action | **Wipe** or Fresh Start was used | Unsupported for RDP-only VMs. Redeploy the VM. |

## Entra join and Intune enrollment

| Symptom / code | Cause | Fix |
|---|---|---|
| Joined to Entra but not in Intune | User not in MDM user scope, or no Intune license at join time | Fix scope/license. Disconnect the device, delete the Entra device object, and rejoin. |
| `0x801c03ed` | User not allowed to join devices | Entra → Device settings → *Users may join devices* |
| `0x80180014` | Windows (MDM) blocked by platform restrictions | Allow Windows in enrollment restrictions |
| Device limit reached | Too many devices for the user | Delete stale devices or raise the limit |
| `0x8007064c` "machine is already enrolled" | Cloned from an enrolled VM | Not supported. Redeploy from the Marketplace image. |
| "Join this device to Microsoft Entra ID" link missing | Device already joined, or a Windows edition issue | Check `dsregcmd /status`; the image must be Enterprise |
| Device shows the wrong primary user | A different account performed the join | Expected behavior. The joining user becomes the primary user. |

Reference: [Troubleshoot Windows enrollment errors](https://learn.microsoft.com/troubleshoot/mem/intune/device-enrollment/troubleshoot-windows-enrollment-errors).

## Compliance evaluation

| Symptom | Cause | Fix |
|---|---|---|
| State doesn't change after `Apply` | No check-in yet | **Sync** from the device or admin center; wait several minutes; refresh the report |
| Policy not listed on the device | Device not in the assigned group, or group membership not processed | Check membership; wait for dynamic group processing |
| Only *Default Device Compliance Policy* listed | Policy not assigned to the device | Assign to `GRP-IntuneLab-Devices` |
| Firewall = **Error** | Sync happened immediately after reboot or resume | Sync again a few minutes later |
| CLIENT-01 noncompliant at baseline | Outdated security intelligence, strict OS version, or validity period exceeded while deallocated | Run `Update-MpSignature` and Windows Update; relax the rule; start the VM and sync |
| Policy state **Not applicable** | Assigned to users while testing device evaluation, or a platform mismatch | Assign to a device group; check the platform is *Windows 10 and later* |
| Device appears **Compliant** without a policy | Tenant setting *Mark devices with no compliance policy assigned as* = Compliant | Expected default; assign the policy |
| Stale/old status for deallocated VMs | Devices can't check in while stopped | Start, sign in, sync |

## CLIENT-02 drift script

| Message / symptom | Cause | Fix |
|---|---|---|
| `Open PowerShell using Run as administrator...` | Not elevated | Start PowerShell with **Run as administrator** |
| `...cannot be loaded because running scripts is disabled` | Execution policy | `Set-ExecutionPolicy -Scope Process Bypass -Force` |
| Script blocked as downloaded from the Internet | Mark of the Web | `Unblock-File .\Set-Client02LabState.ps1` |
| `A backup already exists at ... Run -Action Restore first.` | `Apply` was already run | Run `-Action Restore` first. This prevents overwriting the original backup. |
| `Backup file not found ... Nothing can be restored.` | `Apply` was never run, or `Restore` already ran | Check `%ProgramData%\IntuneLab\` for `.restored-*` files. Re-enable settings manually if needed. |
| `Backup file is incomplete or invalid.` | JSON edited or corrupted | Restore manually: `Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled True` and `Set-MpPreference -DisableRealtimeMonitoring $false` |
| `Defender change was blocked or failed` | **Tamper Protection**, Group Policy, MDE, or Intune policy | Expected on many builds. Rely on the Firewall rule, or turn off Tamper Protection in Windows Security **on the lab VM only**, and re-enable it afterwards. |
| `Unable to read Defender status` | Defender not active (another AV registered) or a module issue | Check `Get-Service WinDefend`; the lab assumes Defender is the AV |
| RTP shows enabled even though `DisableRealtimeMonitoringPreference` = True | Tamper Protection silently overrides the preference | Trust `RealTimeProtectionEnabled` (actual state) over the preference |

Full script reference: [CLIENT-02 lab script](client02-lab-script.md).

## Conditional Access

| Symptom | Cause | Fix |
|---|---|---|
| Both devices fail *Require compliant device* | Device ID not sent (browser/session not using device identity) | Use Edge with the work profile, or sign in to Windows as the Entra user |
| Sign-in log shows `Compliant: No` but Intune says Compliant | Entra flag not yet updated, or a different device record (duplicate) | Wait/sync; delete stale duplicate device objects |
| Policy *Not applied* | User/app/platform out of scope | Use the **What If** tool |
| Can't create the CA policy | Security defaults on; missing P1 or role | See [Conditional Access prerequisites](conditional-access.md#prerequisites) |
| Locked out after switching to **On** | Policy scoped too broadly | Sign in with the emergency access account and disable the policy |

## Collecting diagnostics

Run these on the VM. Review the output and **redact** identifiers before sharing.

```powershell
# Entra join / PRT state
dsregcmd /status

# MDM diagnostic package (writes a .cab you can inspect)
mdmdiagnosticstool.exe -area "DeviceEnrollment;DeviceProvisioning" -cab "$env:TEMP\mdm-diag.cab"

# Recent MDM admin events
Get-WinEvent -LogName "Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Admin" -MaxEvents 50 |
    Select-Object TimeCreated, Id, LevelDisplayName, Message
```

You can also use **Settings → Accounts → Access work or school → Export your management log files**.

References: [Collect MDM logs](https://learn.microsoft.com/windows/client-management/mdm-collect-logs) · [dsregcmd](https://learn.microsoft.com/entra/identity/devices/troubleshoot-device-dsregcmd)

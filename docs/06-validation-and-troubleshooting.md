# 06 - Validation and troubleshooting

[← 05 - Conditional Access](05-conditional-access.md) · Next: [07 - Cleanup](07-cleanup.md)

Quick commands to confirm each layer of the lab, and the most common issues. Full stage-by-stage validation: [Validation and testing](validation-and-testing.md). Full issue tables: [Troubleshooting](troubleshooting.md).

## Validation commands

| Layer | Where | Command or check | Expected |
|---|---|---|---|
| Azure resources | Workstation, `terraform\` | `terraform output` | Resource group, VM names, public IPs, `rdp_allowed_source` |
| RDP rule | Workstation | `az network nsg rule list -g intune-lab-rg --nsg-name intune-lab-nsg -o table` | Source = your `/32` |
| Entra join | VM | `dsregcmd /status` | `AzureAdJoined : YES` |
| MDM enrollment | VM | **Access work or school → Info** | Recent sync, **Sync** button present |
| Intune record | Intune admin center | **Devices → Windows** | Device present, managed by Intune |
| Compliance | Intune admin center | **(device) → Device compliance** | Per-setting status |
| CLIENT-02 local state | VM (elevated) | `.\Set-Client02LabState.ps1 -Action Status` | Firewall profiles and Defender RTP state |
| Conditional Access | Entra admin center | **Sign-in logs → Report-only** tab | Success / Failure as expected |

Force a sync from the VM: **Settings → Accounts → Access work or school → (connection) → Info → Sync**, or from Intune: **(device) → Sync**. See [Sync a device in Intune](https://learn.microsoft.com/en-us/intune/device-management/actions/sync).

Collect MDM diagnostics on a VM:

```powershell
mdmdiagnosticstool.exe -area "DeviceEnrollment;DeviceProvisioning" -cab "$env:TEMP\mdm-diag.cab"
```

## Common issues

| Symptom | Likely cause | Fix |
|---|---|---|
| Portal **Check access** shows port 3389 blocked by `DefaultRule_DenyAllInBound` | NSG rule source is not your current public IP | Compare `terraform output rdp_allowed_source` with the portal's Source IP; run `terraform apply` |
| `allowed_rdp_cidr is still an example documentation address` | Example `203.0.113.10/32` left in `terraform.tfvars` | Set your real IP, or remove the line to auto-detect |
| Device in Entra ID but not in Intune | Test user not in MDM user scope | Fix scope, then disconnect and re-join |
| Policy shows *Not applicable* or device missing from the report | Device not in `GRP-IntuneLab-Devices` | Add the device; sync |
| `CLIENT-02` still Compliant after `Apply` | Device hasn't checked in yet | Sync, wait several minutes, refresh |
| Real-time protection not disabled | Tamper Protection | Expected; rely on the Firewall setting |
| `Apply` refuses to run | Backup already exists from an earlier run | Run `-Action Restore` first |
| Sign-in log shows no Device ID | Browser didn't present device identity | Use Edge signed in with the work account, or sign in to Windows as the Entra user |
| Unexpected noncompliance on `CLIENT-01` | Defender intelligence out of date, or an extra policy setting | Update Defender, review per-setting status, remove VM-unfriendly settings |

More: [Troubleshooting → Compliance evaluation](troubleshooting.md#compliance-evaluation), [Conditional Access](troubleshooting.md#conditional-access), [CLIENT-02 drift script](troubleshooting.md#client-02-drift-script).

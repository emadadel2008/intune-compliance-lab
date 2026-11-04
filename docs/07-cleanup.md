# 07 - Cleanup

[← 06 - Validation and troubleshooting](06-validation-and-troubleshooting.md) · [Back to overview](00-lab-overview.md)

Restore security on `CLIENT-02` first, then remove tenant objects, then destroy Azure resources. Detailed version: [Lab scenarios → Scenario 6: Cleanup](lab-scenarios.md#scenario-6-cleanup).

## 1. Restore CLIENT-02

In an elevated PowerShell on `CLIENT-02`:

```powershell
.\Set-Client02LabState.ps1 -Action Restore
.\Set-Client02LabState.ps1 -Action Status
```

Confirm all Firewall profiles are back to their original state, then sync the device and confirm it returns to **Compliant** in Intune.

## 2. Remove tenant objects

Clean up the tenant while you still know which objects belong to the lab.

1. **Conditional Access:** delete `CA-IntuneLab-RequireCompliantDevice-ReportOnly`, or set it to **Off**.
2. **Compliance policy:** delete `CP-Win-IntuneLab-Baseline`.
3. **Intune devices:** **Devices → Windows → (device) → Delete** for both VMs. Do **not** use **Wipe**; it can leave an RDP-only VM unreachable.
4. **Entra devices:** **Devices → All devices** → delete `CLIENT-01` and `CLIENT-02`.
5. **Groups:** delete `GRP-IntuneLab-Devices` (and `GRP-IntuneLab-Users` if created).
6. **Tenant settings:** revert any changes made only for the lab (MDM user scope, device join settings).

## 3. Destroy Azure resources

From the `terraform` folder:

```powershell
..\scripts\destroy.ps1      # type DESTROY to confirm
```

or `terraform destroy`. Then verify:

```powershell
az group exists --name intune-lab-rg     # expected: false
```

## 4. Clean up local files

Delete `terraform.tfvars`, `terraform.tfstate*`, `tfplan`, and `.terraform\` when you no longer need them. State contains the admin password in plain text, and `terraform.tfvars` may contain your public IP.

## Done when

- [ ] `CLIENT-02` was restored before deletion.
- [ ] No lab policies, devices, or groups remain in Entra ID or Intune.
- [ ] `az group exists --name intune-lab-rg` returns `false`.
- [ ] Local state and variable files are deleted or secured.

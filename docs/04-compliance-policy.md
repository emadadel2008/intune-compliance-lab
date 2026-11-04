# 04 - Compliance policy

[← 03 - Intune enrollment](03-intune-enrollment.md) · Next: [05 - Conditional Access](05-conditional-access.md)

Create a device group and a Windows compliance policy, confirm both VMs are compliant, then make `CLIENT-02` fail the policy. Background and setting-by-setting expectations: [Compliance policies](compliance-policies.md).

## 1. Create the device group

Entra admin center → **Groups → New group**:

| Field | Value |
|---|---|
| Group type | Security |
| Name | `GRP-IntuneLab-Devices` |
| Membership | Assigned: add `CLIENT-01` and `CLIENT-02` |

A dynamic device group with `(device.displayName -startsWith "CLIENT-0")` also works.

## 2. Create and assign the policy

Intune admin center → **Devices → Compliance → Create policy** → **Windows 10 and later**.

| Step | Value |
|---|---|
| Name | `CP-Win-IntuneLab-Baseline` |
| Device Security → **Firewall** | Require |
| Device Security → **Antivirus** / **Antispyware** | Require |
| Defender → **Real-time protection** | Require |
| Actions for noncompliance | Mark device noncompliant: **Immediately** |
| Assignments | Include `GRP-IntuneLab-Devices` |

Leave all other settings **Not configured**. Avoid BitLocker, Secure Boot / code integrity, TPM, and password settings on Azure VMs. See [Settings to avoid on Azure VMs](compliance-policies.md#settings-to-avoid-on-azure-vms).

## 3. Sync and evaluate the baseline

On each VM: **Settings → Accounts → Access work or school → (connection) → Info → Sync**. Then in Intune: **Devices → Windows → (device) → Device compliance**.

Expected: both `CLIENT-01` and `CLIENT-02` are **Compliant**. Evaluation can take several minutes after sync.

## 4. Make CLIENT-02 noncompliant

Copy [`Set-Client02LabState.ps1`](../Set-Client02LabState.ps1) to `CLIENT-02`, then in an **elevated** PowerShell:

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\Set-Client02LabState.ps1 -Action Status
.\Set-Client02LabState.ps1 -Action Apply
```

`Apply` backs up the current state, disables all Windows Firewall profiles, and attempts to disable Defender real-time protection (Tamper Protection may block that; do not bypass it). Script reference: [CLIENT-02 lab script](client02-lab-script.md).

Sync `CLIENT-02` again and check its per-setting compliance.

| Device | Expected state | Expected failing setting |
|---|---|---|
| `CLIENT-01` | Compliant | None |
| `CLIENT-02` | Not compliant | **Firewall** (and Real-time protection if it was actually disabled) |

The authoritative result is Intune's per-setting status, not the local setting change.

> [!IMPORTANT]
> Keep `CLIENT-02` in this state only as long as needed for [05 - Conditional Access](05-conditional-access.md). Restore it with `-Action Restore` (see [07 - Cleanup](07-cleanup.md)).

## Done when

- [ ] `CP-Win-IntuneLab-Baseline` is assigned to `GRP-IntuneLab-Devices`.
- [ ] `CLIENT-01` is Compliant.
- [ ] `CLIENT-02` is Not compliant on the Firewall setting.

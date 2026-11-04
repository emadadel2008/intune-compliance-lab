# CLIENT-02 Intune Compliance Lab Script

[← Documentation home](index.md) · Related: [Lab scenarios](lab-scenarios.md) · [Troubleshooting → drift script](troubleshooting.md#client-02-drift-script) · [Security considerations](security-considerations.md)

> [!NOTE]
> This page was previously `README 3.md` in the repository root. The script itself is [`Set-Client02LabState.ps1`](../Set-Client02LabState.ps1) in the repository root.


A PowerShell utility for a temporary Windows 11 lab device (`CLIENT-02`) used to demonstrate Microsoft Intune compliance evaluation.

The script can temporarily change selected endpoint security settings, report their current state, and restore the settings captured before the lab change.

> **Warning — training lab only:** `Apply` disables Windows Firewall on all profiles and attempts to disable Microsoft Defender real-time protection. Do not use on production devices or devices containing sensitive data.

## What the script does

| Action | Behavior |
|---|---|
| `Status` | Reports Windows Firewall profile states and Microsoft Defender status |
| `Apply` | Saves the original settings, disables Firewall profiles, and attempts to disable Defender real-time protection |
| `Restore` | Restores the saved Firewall profile states and Defender preference |

The script does **not** disable the Defender service, uninstall antivirus, change RDP settings, or bypass Tamper Protection.

## Requirements

- Windows 10/11.
- Run PowerShell using **Run as Administrator**.
- The Windows `NetSecurity` and Microsoft Defender PowerShell modules must be available.
- A local administrator account with permission to change the relevant settings.

## Usage

Copy `Set-Client02LabState.ps1` to `CLIENT-02`. Open an elevated PowerShell session in the script's folder.

### 1. Check the current state

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\Set-Client02LabState.ps1 -Action Status
```

### 2. Apply the temporary lab state

```powershell
.\Set-Client02LabState.ps1 -Action Apply
```

Before making changes, the script saves the original Firewall profile states and Defender real-time protection preference to:

```text
%ProgramData%\IntuneLab\Client02-protection-state.json
```

It then disables the Domain, Private, and Public Windows Firewall profiles and attempts to disable Defender real-time protection.

### 3. Verify the actual state

```powershell
.\Set-Client02LabState.ps1 -Action Status
```

Do not assume a setting changed just because the script ran. Review the reported state.

### 4. Restore the original state

```powershell
.\Set-Client02LabState.ps1 -Action Restore
```

After restoration, the backup is retained with a `.restored-<timestamp>` suffix.

## Microsoft Defender notes

- Tamper Protection, Group Policy, Microsoft Defender for Endpoint, or another organizational security policy may prevent the real-time protection setting from changing.
- The script does not bypass those controls.
- Verify Defender's actual state after both `Apply` and `Restore`.
- If Defender is controlled by policy, restore the controlling policy as well.

## Intune compliance considerations

This script changes endpoint configuration; it does **not** enroll the device into Intune and does **not** create or assign an Intune compliance policy.

For a demonstration:

1. Enroll `CLIENT-01` and `CLIENT-02` into Intune.
2. Create a Windows 10 and later compliance policy with the relevant Firewall and antivirus requirements.
3. Assign the policy to a test device group containing the lab devices.
4. Sync both devices and review their compliance results.
5. Apply this script to `CLIENT-02`, sync again, and inspect the device's compliance status.
6. Run `Restore` and sync again to observe recovery.

**Important:** The exact compliance result depends on the policy settings, Windows build, Defender configuration, enrollment state, and Intune evaluation timing. Disabling real-time protection does not necessarily make the device fail every antivirus compliance check. Verify the reported state in Intune rather than assuming the outcome.

## Network safety

If Remote Desktop (TCP 3389) is exposed to the public internet, disabling Windows Firewall increases risk. Keep the test brief, avoid sensitive data, do not use the VM for unrelated browsing, and restore protection immediately after the demonstration. Prefer restricting RDP access or using a controlled access method whenever possible.

## Repository hygiene

Do not commit:

- Terraform state files (`*.tfstate`, `*.tfstate.*`).
- Terraform variable files containing secrets (`*.tfvars`).
- Passwords, access tokens, certificates, or tenant/subscription-specific secrets.
- The local backup file created by this script.

## Disclaimer

Provided for educational lab use. Review and test the script in a disposable environment before use. You are responsible for the security and licensing configuration of your Azure and Microsoft 365 environment.

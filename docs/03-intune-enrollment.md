# 03 - Intune enrollment

[← 02 - Azure infrastructure](02-azure-infrastructure.md) · Next: [04 - Compliance policy](04-compliance-policy.md)

Configure automatic MDM enrollment, then Entra join both VMs so they enroll in Intune. Background and sequence diagram: [Device enrollment](device-enrollment.md).

> [!NOTE]
> **Entra join** creates the device identity. **Intune enrollment** makes it managed. With automatic enrollment, both happen in one wizard, but only if the joining user is in the **MDM user scope**.

## 1. Configure the tenant (once)

1. **Allow device join:** Entra admin center → **Identity → Devices → Device settings** → *Users may join devices to Microsoft Entra* → **All**, or **Selected** including `YOUR_TEST_USER`.
2. **Configure automatic enrollment:** Intune admin center → **Devices → Windows → Enrollment → Automatic Enrollment** → *MDM user scope* → **Some** (a group containing `YOUR_TEST_USER`) or **All**. Keep the default MDM URLs.
3. **Check restrictions:** Intune admin center → **Devices → Enrollment** → Windows (MDM) allowed in *Device platform restrictions*; *Device limit* of at least 2.

## 2. Join each VM

Repeat on `CLIENT-01` and `CLIENT-02`:

1. RDP in as `.\labadmin`.
2. **Settings → Accounts → Access work or school → Connect**.
3. Select **Join this device to Microsoft Entra ID** (the link at the bottom of the dialog).
4. Sign in as `YOUR_TEST_USER@YOUR_TENANT_DOMAIN`, complete MFA, verify the organization, and select **Join**.
5. Select **Done** and restart the VM.
6. RDP back in as `.\labadmin`.

## 3. Verify

On each VM:

```powershell
dsregcmd /status | Select-String "AzureAdJoined|DomainJoined|TenantName|MdmUrl"
```

| Field | Expected |
|---|---|
| `AzureAdJoined` | `YES` |
| `DomainJoined` | `NO` |
| `MdmUrl` | A non-empty Intune URL |

In the **Intune admin center → Devices → Windows**, both `CLIENT-01` and `CLIENT-02` should appear with *Managed by: Intune* and a recent *Last check-in*.

If a device is in Entra ID but not in Intune, the user was not in the MDM user scope. See [Troubleshooting → Entra join and Intune enrollment](troubleshooting.md#entra-join-and-intune-enrollment).

## Done when

- [ ] Both VMs show `AzureAdJoined : YES`.
- [ ] Both VMs appear in Intune as managed Windows devices.

# Glossary

[← Documentation home](index.md)

| Term | Definition |
|---|---|
| **Actions for noncompliance** | Steps Intune takes when a device fails a compliance policy, such as marking it noncompliant (immediately or after a grace period) or sending a notification. |
| **Antispyware / Antivirus (compliance setting)** | Compliance checks that read the state of security products registered with Windows Security Center. |
| **App protection policy (MAM)** | Intune policy that protects organization data inside apps, often without device enrollment. Not used in this lab. |
| **Check-in** | When the device's MDM client contacts Intune to receive policy and report state. Compliance is evaluated at check-in. |
| **Compliance policy** | An Intune object that defines rules a device must meet. It **evaluates** device state and does not change settings. |
| **Compliance state** | The result of evaluation: Compliant, Not compliant, In grace period, Not evaluated, Error, Conflict, and others. |
| **Compliance status validity period** | Tenant-wide setting (default 30 days). Devices that don't report within this period are treated as noncompliant. |
| **Conditional Access (CA)** | Microsoft Entra policy engine that grants or blocks sign-ins based on user, app, device, and risk conditions. |
| **Configuration profile** | An Intune object that **configures** device settings through CSPs. Not used in this lab. |
| **CSP (Configuration Service Provider)** | The Windows interface that MDM uses to read and write device settings. |
| **Device configuration** | The act of setting device state, for example turning the firewall on. Separate from compliance. |
| **Device Health Attestation (DHA)** | Windows service that attests boot-time security (BitLocker, Secure Boot, code integrity). Avoided in this lab on VMs. |
| **dsregcmd** | Windows command-line tool that shows a device's Entra join and PRT state. |
| **Emergency access account** | A highly protected "break-glass" admin account excluded from CA to prevent lockout. |
| **Entra joined** | A device whose identity is in Microsoft Entra ID and that allows organizational sign-in to Windows. |
| **Entra registered** | A personal device known to Entra ID without joining. Not used here. |
| **Grace period** | Time allowed after a compliance failure before the device is marked noncompliant. 0 in this lab. |
| **Intune managed device** | The Intune record for an enrolled device. It is linked to, but separate from, the Entra device object. |
| **isCompliant** | Attribute on the Entra device object, written by Intune and read by Conditional Access. |
| **MDM (Mobile Device Management)** | The protocol and service (Intune) that manages enrolled devices. |
| **MDM user scope** | Setting that controls which users' devices are automatically enrolled in Intune during Entra join. |
| **NSG (Network Security Group)** | Azure stateful packet filter. In this lab it is attached to each VM NIC. |
| **PRT (Primary Refresh Token)** | Token that allows single sign-on on Entra-joined devices and carries the device identity to Entra ID. |
| **Report-only mode** | CA mode that evaluates and logs policy results without enforcing them. |
| **Real-time protection (RTP)** | Microsoft Defender Antivirus feature that scans files and processes as they are accessed. |
| **Tamper Protection** | Defender feature that prevents changes to key security settings, including those made by this lab's script. |
| **Trusted Launch** | Azure VM security type that provides Secure Boot and a virtual TPM (vTPM). Required for Windows 11. |
| **Windows Security Center (WSC)** | Windows component that tracks Firewall and AV health. Many compliance checks read from it. |
| **Wipe** | Intune remote action that resets a device. **Do not use** on RDP-only VMs. |

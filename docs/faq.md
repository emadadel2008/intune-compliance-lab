# Frequently asked questions

[← Documentation home](index.md)

### Does Terraform enroll the VMs in Intune or create policies?

No. Terraform creates only Azure resources. Entra join, Intune enrollment, compliance policies, and Conditional Access are manual. See [Device enrollment](device-enrollment.md).

### Why are there two VMs?

`CLIENT-01` is a **control** that should remain compliant. `CLIENT-02` is driven noncompliant with [`Set-Client02LabState.ps1`](../Set-Client02LabState.ps1). Comparing the two shows that a change in Intune reporting is caused by device state, not by the policy or tenant.

### Will CLIENT-02 be noncompliant right after deployment?

No. Both VMs are deployed identically. CLIENT-02 becomes noncompliant only after you enroll it, assign a policy, run `-Action Apply`, and it checks in.

### Does a compliance policy turn the firewall back on?

No. Compliance policies **evaluate**; they do not **configure**. See [Configuration, compliance, reporting, enforcement](compliance-policies.md#configuration-compliance-reporting-enforcement).

### I ran `Apply`, but Intune still shows Compliant. Why?

The device hasn't checked in yet. Sync from **Access work or school → Info → Sync**, wait a few minutes, and refresh the report. Also check whether the setting actually changed (`-Action Status`).

### Why didn't real-time protection turn off?

Tamper Protection, or another policy, probably blocked it. The script does not bypass these controls by design. The Firewall rule is the most reliable signal in this lab.

### Can I use Autopilot with these VMs?

No. Microsoft does not support Autopilot, Commercial OOBE, or the Enrollment Status Page on VMs that are reachable only over RDP. See [Architecture → limitations](architecture.md#intune-on-azure-vms-limitations).

### Can I require BitLocker in the compliance policy?

Not in this lab. Intune does not support TPM-dependent configuration such as BitLocker on VMs, so results would be unreliable.

### Does the Conditional Access policy control RDP to the VMs?

No. RDP with `.\labadmin` is a local logon. The CA policy in this lab controls sign-ins to cloud apps **from** the VMs. See [What CA does and does not control](conditional-access.md#what-ca-does-and-does-not-control-in-this-lab).

### My public IP changed and RDP stopped working.

Update `allowed_rdp_cidr` in `terraform\terraform.tfvars` and run `terraform apply`.

### Do deallocated VMs cost money?

Compute stops, but managed disks and Standard static public IPs continue to incur charges. See [Cost considerations](prerequisites.md#cost-considerations).

### Can I clone CLIENT-01 to make more devices?

Not after enrollment. Cloned images of enrolled devices are unsupported. Add more entries to `local.clients` in [`virtual-machines.tf`](../terraform/virtual-machines.tf) instead.

### Can I use a different region or VM size?

Yes. Set `location` and `vm_size` in `terraform.tfvars`. The size must support Trusted Launch, and the Windows 11 image must be available in the region.

### What is the `http` provider in `versions.tf` used for?

Nothing currently. It is declared but not referenced. See [Known gaps](architecture.md#known-gaps).

### Is this production-ready?

No. It is a training lab. See [Security considerations](security-considerations.md).

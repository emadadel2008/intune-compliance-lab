# Intune Compliance Lab on Azure

Deploy a small, persistent Windows 11 lab on Azure to practice Microsoft Intune device compliance and Microsoft Entra Conditional Access.

The Terraform configuration creates:

- One Azure Resource Group
- One Virtual Network and subnet
- One Network Security Group (NSG)
- Two Windows 11 Enterprise virtual machines with Secure Boot and vTPM enabled
- Two Public IP addresses and network interfaces
- RDP access restricted to one administrator-supplied public IPv4 CIDR

> **Important:** This repository deploys Azure infrastructure only. It does not automatically Entra-join, enroll, or configure devices in Microsoft Intune. Those steps are completed interactively after deployment.

## Architecture

```text
Azure Resource Group
└── Virtual Network
    └── Lab subnet
        ├── NSG: TCP/3389 only from your public IP (/32)
        ├── CLIENT-01: Windows 11 Enterprise
        │   ├── NIC
        │   └── Static Standard Public IP
        └── CLIENT-02: Windows 11 Enterprise
            ├── NIC
            └── Static Standard Public IP
```

Both VMs are persistent, standalone Azure VMs. The intended exercise is to enroll both devices, configure one to meet a selected compliance policy, and make the other fail that policy. A VM is not automatically compliant just because it was deployed.

## Prerequisites

1. An Azure subscription with permission to create resource groups, networking resources, and virtual machines.
2. Azure CLI installed and authenticated (`az login`).
3. Terraform CLI installed.
4. Windows 11 Enterprise virtualization rights for the users/devices involved. Check your Microsoft licensing entitlements before deployment.
5. An Azure region that offers the selected Windows image and VM size, with available capacity.
6. A public IPv4 address from which you will connect using RDP.

The default VM size is `Standard_B2ms` (2 vCPU, 8 GiB RAM). The VMs are configured with Secure Boot and vTPM (Trusted Launch). Trusted Launch supports B-family and D-family sizes, but availability and capacity still vary by region and subscription. If deployment fails with `SkuNotAvailable`, change `vm_size` and/or `location` in your local `terraform.tfvars`.

## Quick start (PowerShell)

Clone your fork:

```powershell
git clone https://github.com/<YOUR-GITHUB-USERNAME>/intune-compliance-lab.git
cd intune-compliance-lab/terraform
```

Authenticate and select your own subscription:

```powershell
az login
az account list --output table
az account set --subscription "<YOUR-SUBSCRIPTION-ID>"
az account show --output table
```

Create your private local variables file:

```powershell
Copy-Item .\terraform.tfvars.example .\terraform.tfvars
notepad .\terraform.tfvars
```

Set at least:
- `location`: a region available to your subscription
- `allowed_rdp_cidr`: your public IPv4 address followed by `/32`

Example: `198.51.100.25/32` is documentation-only and will not work as a real source address.

Initialize and validate:

```powershell
terraform init
terraform fmt -recursive
terraform validate
terraform plan
```

Apply:

```powershell
terraform apply
```

Terraform prompts for `admin_password` if you have not supplied it through the `TF_VAR_admin_password` environment variable. Use a unique strong password and do not put it in source control.

To use an environment variable for the current PowerShell session:

```powershell
$env:TF_VAR_admin_password = Read-Host "Enter a strong local admin password" -AsSecureString |
    ForEach-Object { [System.Net.NetworkCredential]::new("", $_).Password }

terraform apply
Remove-Item Env:TF_VAR_admin_password
```

After deployment, Terraform prints the public IPs and VM names:

```powershell
terraform output
```

Connect with Remote Desktop (`mstsc.exe`) using the VM public IP and the local administrator username configured in `terraform.tfvars`.

## Security notes

- **Never expose RDP to the whole Internet.** `allowed_rdp_cidr` is required and the NSG permits TCP/3389 only from that CIDR.
- If your public IP changes, update `allowed_rdp_cidr` in your local `terraform.tfvars` and run `terraform apply`.
- Do not commit `terraform.tfvars`, state files, plans, credentials, or passwords.
- Terraform's `sensitive = true` hides a password in normal CLI output, but the password is still stored in Terraform state. Protect the state file and your machine. For team use, configure a secured remote backend with access controls and encryption.
- Public IPs, disks, and other resources can continue to incur charges while VMs are stopped/deallocated. Review the resources and current Azure pricing before deploying.
- Use `terraform destroy` when the lab is no longer needed. This deletes all resources managed by this configuration in the selected workspace/state.

## Intune and Conditional Access scope / limitations

This is a **standalone VM lab**, not an Azure Virtual Desktop deployment.

- Use persistent Windows 11 Enterprise VMs. Do not treat these as non-persistent pooled VDI session hosts.
- Intune management of Windows VMs has documented limitations. Review current Microsoft guidance before using VM-specific management features.
- Hardware-dependent controls such as TPM-backed configuration, BitLocker, and DFCI may not behave like they do on physical devices.
- Windows Autopilot/OOBE and Enrollment Status Page scenarios are not a suitable assumption for RDP-only Azure VMs.
- Avoid using Intune **Wipe** on a VM that you can access only through RDP; it can remove the settings needed to reconnect.
- Do not clone a VM after it has been enrolled in Intune.
- Deallocated VMs may stop checking in and can appear stale or noncompliant until they check in again.
- Conditional Access for Microsoft 365 app access based on device compliance is different from Conditional Access governing sign-in to an Azure VM over RDP.
- For the compliance demonstration, use a licensed Entra test user and verify that the Windows device is correctly joined/registered, enrolled, and reporting compliance before enforcing a policy.
- Start Conditional Access in **Report-only** mode, exclude emergency access accounts, and test with dedicated accounts before enabling enforcement.

Official documentation:
- [Using Windows virtual machines with Microsoft Intune](https://learn.microsoft.com/mem/intune/fundamentals/azure-virtual-desktop)
- [Using Azure Virtual Desktop single-session with Microsoft Intune](https://learn.microsoft.com/mem/intune/fundamentals/azure-virtual-desktop-multi-session)
- [Conditional Access: Require compliant devices](https://learn.microsoft.com/entra/identity/conditional-access/policy-all-users-device-compliance)
- [Deploy Windows 11 on Azure](https://learn.microsoft.com/azure/virtual-machines/windows/windows-11)

## Existing resources

This project creates a new, self-contained resource group and resources. It does not import, modify, or delete resources that already exist in your subscription. Do not point it at an existing lab resource group unless you intentionally want Terraform to manage the resources it creates there.

## Cleanup

From the same `terraform` directory and with the same Terraform state:

```powershell
terraform destroy
```

Review the destroy plan and confirm when prompted.

## Contributing

Issues and pull requests are welcome. Keep personal subscription IDs, tenant IDs, public IPs, credentials, passwords, and local Terraform state out of commits. Update `terraform.tfvars.example` only with safe placeholder values.

## Disclaimer

This is a community lab starter, not a production reference architecture. Validate licensing, regional availability, security, and current Microsoft product limitations before use.

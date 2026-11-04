# 02 - Azure infrastructure

[← 01 - Prerequisites](01-prerequisites.md) · Next: [03 - Intune enrollment](03-intune-enrollment.md)

Deploy the two Windows 11 VMs with Terraform and verify the resources and network. Full walkthrough: [Setup guide](setup-guide.md). Resource details: [Architecture](architecture.md).

## What Terraform creates

| Resource | Name |
|---|---|
| Resource group | `intune-lab-rg` |
| Virtual network / subnet | `intune-lab-vnet` (`10.40.0.0/16`) / `intune-lab-clients` (`10.40.1.0/24`) |
| Network security group | `intune-lab-nsg`, associated with each VM NIC |
| NSG rule | `Allow-RDP-From-Admin-IP`: TCP 3389 from one `/32` only |
| Public IPs | One Standard static IP per VM |
| Virtual machines | `CLIENT-01`, `CLIENT-02` (Windows 11 Enterprise, Trusted Launch: Secure Boot + vTPM) |

Terraform does **not** configure Entra ID, Intune, or Conditional Access.

## Deploy

From the repository root:

```powershell
cd terraform
Copy-Item .\terraform.tfvars.example .\terraform.tfvars
notepad .\terraform.tfvars
```

Set `location` and, if needed, `vm_size`. `allowed_rdp_cidr` is optional: leave it unset to auto-detect your public IP, or set `allowed_rdp_cidr = "YOUR_PUBLIC_IP/32"`. Do not put `admin_password` in the file.

```powershell
$env:TF_VAR_admin_password = Read-Host "Admin password"
terraform init
terraform plan -out tfplan
terraform apply tfplan
Remove-Item Env:\TF_VAR_admin_password
```

Alternatively, run `..\scripts\deploy.ps1` from the `terraform` folder for the pre-flight checks and plan.

## Verify

```powershell
terraform output
az vm list -g intune-lab-rg --show-details --query "[].{name:name,size:hardwareProfile.vmSize,power:powerState}" -o table
az network nsg rule list -g intune-lab-rg --nsg-name intune-lab-nsg --query "[].{name:name,src:sourceAddressPrefix,port:destinationPortRange}" -o table
```

| Check | Expected |
|---|---|
| `terraform output rdp_allowed_source` | Your public IP with `/32` |
| VM power state | `VM running` for both |
| NSG rule source | Same `/32` as above, never `*` or `203.0.113.x` |

In the portal, **CLIENT-0x → Connect → Check access** should show port 3389 accessible from your source IP.

## Connect

RDP to each `public_ips` output as `.\labadmin` (or your `admin_username`). See [Setup guide → Step 7](setup-guide.md#step-7-connect-with-rdp).

## Done when

- [ ] Both VMs are running.
- [ ] The NSG rule allows only your `/32`.
- [ ] You can RDP to `CLIENT-01` and `CLIENT-02`.

Problems: [Troubleshooting → Terraform and Azure deployment](troubleshooting.md#terraform-and-azure-deployment).

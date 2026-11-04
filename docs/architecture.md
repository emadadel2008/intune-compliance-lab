# Architecture

The lab deploys two persistent Windows 11 Enterprise VMs into one virtual network and subnet.

## Network security

The subnet is associated with a Network Security Group. The only explicitly allowed inbound rule is TCP/3389 from the required `allowed_rdp_cidr` IPv4 `/32`. Azure's default NSG rules remain in effect; no broad Internet RDP rule is created.

## Device roles for the exercise

- `CLIENT-01`: configure to satisfy the selected Intune compliance policy.
- `CLIENT-02`: configure to fail the selected policy (for example, a deliberately unsupported setting only if the policy and OS support it).

These are teaching roles, not Terraform-enforced compliance states. Compliance is evaluated by Intune after enrollment and check-in.

## Identity and management

Terraform creates the Azure compute and network layer. Entra join, Intune enrollment, compliance policy assignment, and Conditional Access policy configuration are separate post-deployment tasks.


## VM security

The Windows VMs are configured with Secure Boot and vTPM enabled through Trusted Launch. This requires a compatible Generation 2 Windows image and a VM size that supports Trusted Launch. Microsoft lists B-family and D-family sizes among supported general-purpose families: https://learn.microsoft.com/azure/virtual-machines/trusted-launch

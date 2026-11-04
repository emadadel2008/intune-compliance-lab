# Prerequisites and cost

- Azure subscription and sufficient resource permissions.
- Azure CLI and Terraform CLI.
- A supported region, Windows image SKU, and VM size with capacity.
- Eligible Windows virtualization licensing for the users/devices.
- A known public IPv4 address for RDP allowlisting.

Two VMs, managed OS disks, and two Standard Public IPs can incur charges. Deallocating a VM stops compute billing but does not necessarily stop disk or public IP charges. Check the Azure Pricing Calculator for your region and selected SKUs before deploying.

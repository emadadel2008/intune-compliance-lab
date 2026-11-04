data "http" "admin_public_ip" {
  count = var.allowed_rdp_cidr == null ? 1 : 0
  url   = "https://api.ipify.org"

  lifecycle {
    postcondition {
      condition     = self.status_code == 200 && can(regex("^\\d{1,3}(\\.\\d{1,3}){3}$", trimspace(self.response_body)))
      error_message = "Could not detect your public IPv4 address from api.ipify.org. Set allowed_rdp_cidr in terraform.tfvars instead."
    }
  }
}

locals {
  rdp_source_cidr = var.allowed_rdp_cidr != null ? var.allowed_rdp_cidr : "${trimspace(one(data.http.admin_public_ip[*].response_body))}/32"
}

resource "azurerm_network_security_group" "lab" {
  name                = "intune-lab-nsg"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  tags = {
    project     = "intune-compliance-lab"
    environment = "training"
    managed_by  = "terraform"
  }
}

resource "azurerm_network_security_rule" "allow_rdp" {
  name                       = "Allow-RDP-From-Admin-IP"
  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "3389"
  source_address_prefix      = local.rdp_source_cidr
  destination_address_prefix = "*"

  resource_group_name         = azurerm_resource_group.lab.name
  network_security_group_name = azurerm_network_security_group.lab.name
}

resource "azurerm_network_interface_security_group_association" "clients" {
  for_each = azurerm_network_interface.clients

  network_interface_id      = each.value.id
  network_security_group_id = azurerm_network_security_group.lab.id
}
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
  name                       = "Allow-RDP-From-Internet"
  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "3389"
  source_address_prefix      = "*"
  destination_address_prefix = "*"

  resource_group_name         = azurerm_resource_group.lab.name
  network_security_group_name = azurerm_network_security_group.lab.name
}

resource "azurerm_network_interface_security_group_association" "clients" {
  for_each = azurerm_network_interface.clients

  network_interface_id      = each.value.id
  network_security_group_id = azurerm_network_security_group.lab.id
}
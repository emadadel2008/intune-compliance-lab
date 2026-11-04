resource "azurerm_resource_group" "lab" {
  name     = "${var.project_name}-rg"
  location = var.location

  tags = {
    project     = "intune-compliance-lab"
    environment = "training"
    managed_by  = "terraform"
  }
}

resource "azurerm_virtual_network" "lab" {
  name                = "${var.project_name}-vnet"
  address_space       = [var.address_space]
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  tags = azurerm_resource_group.lab.tags
}

resource "azurerm_subnet" "clients" {
  name                 = "${var.project_name}-clients"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = [var.subnet_prefix]
}

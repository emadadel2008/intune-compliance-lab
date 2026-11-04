locals {
  clients = {
    "client-01" = "CLIENT-01"
    "client-02" = "CLIENT-02"
  }
}

resource "azurerm_public_ip" "clients" {
  for_each = local.clients

  name                = "${var.project_name}-${each.key}-pip"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = azurerm_resource_group.lab.tags
}

resource "azurerm_network_interface" "clients" {
  for_each = local.clients

  name                = "${var.project_name}-${each.key}-nic"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.clients.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.clients[each.key].id
  }

  tags = azurerm_resource_group.lab.tags
}

resource "azurerm_windows_virtual_machine" "clients" {
  for_each = local.clients

  name                = each.value
  computer_name       = each.value
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.clients[each.key].id
  ]

  license_type = var.license_type

  # Windows 11 requires a Generation 2 VM with Trusted Launch capabilities.
  secure_boot_enabled = true
  vtpm_enabled        = true

  source_image_reference {
    publisher = var.windows_publisher
    offer     = var.windows_offer
    sku       = var.windows_sku
    version   = var.windows_version
  }

  os_disk {
    name                 = "${var.project_name}-${each.key}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  boot_diagnostics {}

  identity {
    type = "SystemAssigned"
  }

  tags = merge(azurerm_resource_group.lab.tags, {
    lab_device = each.key
  })
}

output "resource_group_name" {
  description = "Name of the resource group created for this lab."
  value       = azurerm_resource_group.lab.name
}

output "vm_names" {
  description = "Windows VM names."
  value       = { for key, vm in azurerm_windows_virtual_machine.clients : key => vm.name }
}

output "public_ips" {
  description = "Public IP addresses for RDP. Access is restricted by the NSG."
  value       = { for key, pip in azurerm_public_ip.clients : key => pip.ip_address }
}

output "rdp_username" {
  description = "Local administrator username."
  value       = var.admin_username
}

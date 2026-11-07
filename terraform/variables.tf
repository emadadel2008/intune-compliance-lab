variable "project_name" {
  description = "Short prefix used to name resources."
  type        = string
  default     = "intune-lab"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,16}$", var.project_name))
    error_message = "project_name must be 3-16 characters, using lowercase letters, numbers, and hyphens."
  }
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "uaenorth"
}

variable "vm_size" {
  description = "Azure VM size. Availability depends on region and subscription capacity."
  type        = string
<<<<<<< HEAD
   default     = "Standard_D2as_v7"
=======
  default     = "Standard_D2as_v7"
>>>>>>> origin/main
}

variable "admin_username" {
  description = "Local Windows administrator username."
  type        = string
  default     = "labadmin"
}

variable "admin_password" {
  description = "Strong local Windows administrator password. Terraform state will contain this value."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.admin_password) >= 12
    error_message = "admin_password must be at least 12 characters long."
  }
}

variable "allowed_rdp_cidr" {
  description = "Unused compatibility input. RDP is allowed from any IP address (lab use only)."
  type        = string
  default     = null
}

variable "address_space" {
  description = "Virtual network address space."
  type        = string
  default     = "10.40.0.0/16"
}

variable "subnet_prefix" {
  description = "Subnet address prefix."
  type        = string
  default     = "10.40.1.0/24"
}

variable "windows_publisher" {
  description = "Marketplace image publisher."
  type        = string
  default     = "MicrosoftWindowsDesktop"
}

variable "windows_offer" {
  description = "Marketplace image offer."
  type        = string
  default     = "Windows-11"
}

variable "windows_sku" {
  description = "Marketplace image SKU. Confirm availability in the selected region."
  type        = string
  default     = "win11-24h2-ent"
}

variable "windows_version" {
  description = "Marketplace image version."
  type        = string
  default     = "latest"
}

variable "license_type" {
  description = "Windows client license benefit. Set only if your user/subscription is eligible."
  type        = string
  default     = "Windows_Client"
}

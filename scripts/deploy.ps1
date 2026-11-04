$ErrorActionPreference = "Stop"

if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    throw "Terraform CLI was not found. Install Terraform and reopen PowerShell."
}

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Azure CLI was not found. Install Azure CLI and reopen PowerShell."
}

Write-Host "Checking Azure CLI authentication..." -ForegroundColor Cyan
az account show --output table
if ($LASTEXITCODE -ne 0) {
    throw "Azure CLI is not authenticated. Run az login."
}

if (-not (Test-Path ".\terraform.tfvars")) {
    Copy-Item ".\terraform.tfvars.example" ".\terraform.tfvars"
    Write-Host "Created terraform.tfvars. Review it in Notepad, save, and close Notepad to continue." -ForegroundColor Yellow
    Start-Process notepad.exe -ArgumentList ".\terraform.tfvars" -Wait
}

terraform init
if ($LASTEXITCODE -ne 0) { throw "terraform init failed." }

terraform fmt -recursive
if ($LASTEXITCODE -ne 0) { throw "terraform fmt failed." }

terraform validate
if ($LASTEXITCODE -ne 0) { throw "terraform validate failed." }

terraform plan
if ($LASTEXITCODE -ne 0) { throw "terraform plan failed." }

Write-Host "Review the plan above. Run 'terraform apply' when ready." -ForegroundColor Green

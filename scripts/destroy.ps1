$ErrorActionPreference = "Stop"

Write-Host "This will delete all resources tracked in the current Terraform state." -ForegroundColor Yellow
terraform plan -destroy
if ($LASTEXITCODE -ne 0) { throw "Destroy plan failed." }

$confirmation = Read-Host "Type DESTROY to continue"
if ($confirmation -cne "DESTROY") {
    Write-Host "Cancelled."
    exit 0
}

terraform destroy
if ($LASTEXITCODE -ne 0) { throw "terraform destroy failed." }

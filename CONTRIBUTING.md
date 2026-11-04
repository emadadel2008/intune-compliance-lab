# Contributing

Thanks for helping improve the Intune Compliance Lab. This is a training lab, so changes should keep it **simple, safe, and accurate**.

## Workflow

1. Fork the repository and create a branch from `main`.
2. Make focused changes. Keep each PR to one topic.
3. Run the validation commands below.
4. Update the documentation and [CHANGELOG.md](CHANGELOG.md) under **Unreleased**.
5. Open a pull request that describes what changed and how you tested it.

## Validation

Terraform (from `terraform\`):

```powershell
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

PowerShell syntax check (from the repository root):

```powershell
foreach ($f in 'Set-Client02LabState.ps1','scripts\deploy.ps1','scripts\destroy.ps1') {
    $errs = $null
    [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path $f), [ref]$null, [ref]$errs) | Out-Null
    if ($errs) { $errs } else { "$f OK" }
}
```

Documentation:

- Relative links and `#anchors` must resolve.
- Mermaid diagrams must render in the GitHub preview.
- Describe only behavior the repository actually implements. Mark manual steps as manual.

## Hygiene rules

- Never commit `terraform.tfvars`, `*.tfstate*`, plans, passwords, tenant or subscription IDs, real IPs, UPNs, or unredacted screenshots. See [Security considerations → Public repository hygiene](docs/security-considerations.md#public-repository-hygiene).
- Use placeholders such as `YOUR_TENANT_DOMAIN`, `YOUR_PUBLIC_IP` (or `203.0.113.x`), and `YOUR_TEST_USER`.
- Do not weaken network controls. The `/32` validation on `allowed_rdp_cidr` is intentional.
- Do not commit `.terraform.lock.hcl` changes unless you are deliberately upgrading providers.

## Suggested improvements

These are known gaps. PRs are welcome:

- Use Azure Bastion or JIT VM access instead of public RDP.
- Parameterize the hard-coded NSG name (`intune-lab-nsg`) using `project_name`.
- Remove or use the unused system-assigned managed identities.
- Make the scripts path-independent with `$PSScriptRoot`.
- Add Intune compliance policy and Conditional Access as code (Microsoft Graph or the `azuread`/`msgraph` providers), in Report-only by default.
- Add a remote state backend example.
- Add CI for `terraform fmt`/`validate` and markdown link checking.

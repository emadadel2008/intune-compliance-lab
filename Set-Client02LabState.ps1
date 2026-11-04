<#
.SYNOPSIS
    Applies, reports, or restores temporary security settings for an Intune
    compliance training lab on CLIENT-02.

.NOTES
    Run in an elevated PowerShell session. Lab use only; not for production.
    Tamper Protection, Group Policy, or other security controls may block
    Defender changes. This script does not bypass those controls.

    Backup: %ProgramData%\IntuneLab\Client02-protection-state.json
#>

[CmdletBinding()]
param(
    [ValidateSet("Apply", "Status", "Restore")]
    [string]$Action = "Status"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$BackupDirectory = Join-Path $env:ProgramData "IntuneLab"
$BackupPath = Join-Path $BackupDirectory "Client02-protection-state.json"

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
}

function Get-LabStatus {
    Write-Host "`n=== Windows Firewall ===" -ForegroundColor Cyan
    Get-NetFirewallProfile |
        Sort-Object Name |
        Select-Object Name, Enabled |
        Format-Table -AutoSize

    Write-Host "`n=== Microsoft Defender Antivirus ===" -ForegroundColor Cyan
    try {
        Get-MpComputerStatus |
            Select-Object AMServiceEnabled, AntivirusEnabled,
                          AntispywareEnabled, RealTimeProtectionEnabled |
            Format-List
    }
    catch {
        Write-Warning "Unable to read Defender status: $($_.Exception.Message)"
    }

    try {
        $preference = Get-MpPreference
        [PSCustomObject]@{
            DisableRealtimeMonitoringPreference = $preference.DisableRealtimeMonitoring
        } | Format-List
    }
    catch {
        Write-Warning "Unable to read Defender preferences: $($_.Exception.Message)"
    }
}

if (-not (Test-IsAdministrator)) {
    throw "Open PowerShell using Run as administrator, then run this script again."
}

switch ($Action) {
    "Status" {
        Get-LabStatus
    }

    "Apply" {
        if (Test-Path -LiteralPath $BackupPath) {
            throw "A backup already exists at $BackupPath. Run -Action Restore first."
        }

        New-Item -Path $BackupDirectory -ItemType Directory -Force | Out-Null

        $firewallState = @(
            Get-NetFirewallProfile |
                Sort-Object Name |
                ForEach-Object {
                    [PSCustomObject]@{
                        Name    = [string]$_.Name
                        Enabled = [bool]$_.Enabled
                    }
                }
        )

        $defenderPreference = Get-MpPreference
        $backup = [PSCustomObject]@{
            ComputerName = $env:COMPUTERNAME
            CreatedAt    = (Get-Date).ToString("o")
            Firewall     = $firewallState
            Defender     = [PSCustomObject]@{
                DisableRealtimeMonitoring = [bool]$defenderPreference.DisableRealtimeMonitoring
            }
        }

        $backup | ConvertTo-Json -Depth 6 |
            Set-Content -LiteralPath $BackupPath -Encoding UTF8

        Write-Host "Original settings saved to: $BackupPath" -ForegroundColor Green

        Write-Host "`nDisabling Windows Firewall profiles..." -ForegroundColor Yellow
        Set-NetFirewallProfile -Profile Domain, Private, Public -Enabled False

        Write-Host "Attempting to disable Microsoft Defender real-time protection..." -ForegroundColor Yellow
        try {
            Set-MpPreference -DisableRealtimeMonitoring $true
        }
        catch {
            Write-Warning "Defender change was blocked or failed: $($_.Exception.Message)"
            Write-Warning "Tamper Protection or organizational policy may prevent this change."
        }

        Write-Host "`nActual state after Apply:" -ForegroundColor Green
        Get-LabStatus
        Write-Host "`nTo restore: .\Set-Client02LabState.ps1 -Action Restore" -ForegroundColor Cyan
    }

    "Restore" {
        if (-not (Test-Path -LiteralPath $BackupPath)) {
            throw "Backup file not found: $BackupPath. Nothing can be restored."
        }

        $backup = Get-Content -LiteralPath $BackupPath -Raw | ConvertFrom-Json
        if (-not $backup.Firewall -or $null -eq $backup.Defender) {
            throw "Backup file is incomplete or invalid. No settings were changed."
        }

        Write-Host "Restoring Windows Firewall profiles..." -ForegroundColor Yellow
        foreach ($profile in $backup.Firewall) {
            Set-NetFirewallProfile `
                -Profile ([string]$profile.Name) `
                -Enabled ([bool]$profile.Enabled)
        }

        Write-Host "Restoring Microsoft Defender real-time protection preference..." -ForegroundColor Yellow
        try {
            Set-MpPreference -DisableRealtimeMonitoring `
                ([bool]$backup.Defender.DisableRealtimeMonitoring)
        }
        catch {
            Write-Warning "Defender restoration was blocked or failed: $($_.Exception.Message)"
            Write-Warning "Check Tamper Protection and organizational policy, then restore Defender manually if needed."
        }

        Write-Host "`nActual state after Restore:" -ForegroundColor Green
        Get-LabStatus

        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $restoredBackupPath = "$BackupPath.restored-$timestamp"
        Move-Item -LiteralPath $BackupPath -Destination $restoredBackupPath

        Write-Host "`nOriginal backup retained at: $restoredBackupPath" -ForegroundColor Cyan
    }
}

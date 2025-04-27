<#
.SYNOPSIS
    Hyper-V VM Backup Script using wbadmin.
    
.DESCRIPTION
    This script backs up specified Hyper-V virtual machines to a network or local target
    using Windows built-in wbadmin tool.

.CREATOR
    ClausDK - https://github.com/clausdk

.VERSION
    1.0
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$BackupTarget,

    [Parameter(Mandatory=$true)]
    [string]$Username,

    [Parameter(Mandatory=$true)]
    [string]$Password,

    [Parameter(Mandatory=$true)]
    [string]$VMNames # Comma-separated string, like "VM1,VM2,VM3"
)

# Timestamp function
function Get-Timestamp {
    return "[{0} {1}]" -f (Get-Date -Format "yyyy-MM-dd"), (Get-Date -Format "HH:mm:ss")
}

Write-Host "$(Get-Timestamp) Checking if backup target is reachable..."

# Test if the backup target is reachable
$TargetHost = ($BackupTarget -replace '\\\\', '') -split '\\' | Select-Object -First 1

if (Test-Connection -ComputerName $TargetHost -Count 2 -Quiet) {
    Write-Host "$(Get-Timestamp) Target is reachable. Starting backup..."
} else {
    Write-Host "$(Get-Timestamp) ERROR: Backup target not reachable. Exiting."
    exit 1
}

# Start the backup
Write-Host "$(Get-Timestamp) Running wbadmin backup..."
wbadmin start backup `
    -backuptarget:$BackupTarget `
    -user:$Username `
    -password:$Password `
    -hyperv:$VMNames `
    -allowDeleteOldBackups `
    -quiet

Write-Host "$(Get-Timestamp) Backup finished."

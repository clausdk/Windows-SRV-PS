# Advanced VM Disk Optimizer for Hyper-V by https://github.com/clausdk/

# Optional: Settings
$PauseInsteadOfShutdown = $true   # If true, will pause the VM instead of stopping
$OptimizeMode = "Full"            # "Full" = deep optimization, "Quick" = faster but less thorough
$SleepSecondsAfterAction = 10     # Wait time between VM actions

# Get all running or paused VMs
$VMs = Get-VM | Where-Object { $_.State -in 'Running', 'Paused' }

foreach ($VM in $VMs) {
    Write-Host "Processing VM: $($VM.Name)" -ForegroundColor Cyan

    # Get all VHD(X) files attached to the VM
    $VHDs = Get-VMHardDiskDrive -VMName $VM.Name | Select-Object -ExpandProperty Path

    if ($VHDs.Count -eq 0) {
        Write-Host "No VHDs found for $($VM.Name), skipping..." -ForegroundColor Yellow
        continue
    }

    # Pause or stop the VM
    if ($PauseInsteadOfShutdown) {
        Write-Host "Pausing VM: $($VM.Name)" -ForegroundColor DarkGray
        Suspend-VM -Name $VM.Name
    } else {
        Write-Host "Stopping VM: $($VM.Name)" -ForegroundColor DarkGray
        Stop-VM -Name $VM.Name -Force
    }

    Start-Sleep -Seconds $SleepSecondsAfterAction

    # Optimize each VHD
    foreach ($VHD in $VHDs) {
        Write-Host "Optimizing VHD: $VHD" -ForegroundColor Green
        try {
            Optimize-VHD -Path $VHD -Mode $OptimizeMode
            Write-Host "Successfully optimized $VHD" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to optimize $VHD: $_" -ForegroundColor Red
        }
    }

    # Resume or start the VM
    if ($PauseInsteadOfShutdown) {
        Write-Host "Resuming VM: $($VM.Name)" -ForegroundColor DarkGray
        Resume-VM -Name $VM.Name
    } else {
        Write-Host "Starting VM: $($VM.Name)" -ForegroundColor DarkGray
        Start-VM -Name $VM.Name
    }

    Start-Sleep -Seconds $SleepSecondsAfterAction

    Write-Host "Finished processing VM: $($VM.Name)`n" -ForegroundColor Cyan
}

Write-Host "All VMs processed!" -ForegroundColor Magenta

### Powershell Script - Mark Messink - 25-11-2022 - Versie 0.0.4 ###

# Scherminstellingen PowerShell
$Host.UI.RawUI.BackgroundColor = ($bckgrnd = 'Black')
$Host.UI.RawUI.ForegroundColor = 'White'
$Host.PrivateData.ErrorForegroundColor = 'Red'
$Host.PrivateData.ErrorBackgroundColor = $bckgrnd
$Host.PrivateData.WarningForegroundColor = 'Yellow'
$Host.PrivateData.WarningBackgroundColor = $bckgrnd
$Host.PrivateData.DebugForegroundColor = 'Yellow'
$Host.PrivateData.DebugBackgroundColor = $bckgrnd
$Host.PrivateData.VerboseForegroundColor = 'Green'
$Host.PrivateData.VerboseBackgroundColor = $bckgrnd
$Host.PrivateData.ProgressForegroundColor = 'Green'
$Host.PrivateData.ProgressBackgroundColor = $bckgrnd
MODE CON COLS=136 LINES=40
Clear-Host
# Info
# Dit script Expand alle drives

# PreRequirements:

# Start Script: 

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Expand alle disks " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host " - Update Diskconfig "
Update-HostStorageCache
Sleep 1
write-host " - Zoek ongeconfigureerde disks... "
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
$disks = get-disk | where PartitionStyle -eq GPT
write-host "----- Lijst Disks, indien van toepassing " -foregroundcolor Yellow
$disks
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host ""
pause

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Configuratie Disks in bovenstaande lijst " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
Write-Host ""

foreach($disk in Get-Disk | where PartitionStyle -eq GPT)

    {
	Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
    Write-Host ""
        $driveLetter = (Get-Partition -DiskNumber $disk.Number | where {$_.DriveLetter}).DriveLetter
        Write-Host " - DriveLetter: $driveLetter :\"

        $currentDiskSize = (Get-Partition -DriveLetter $driveLetter).Size        
        Write-Host " - Partitie Size: $currentDiskSize"

        $partitionNum = (Get-Partition -DriveLetter $driveLetter).PartitionNumber
        Write-Host " - Partitie Nummer: $partitionNum"

        $unallocatedDiskSize = (Get-Disk -Number $disk.number).LargestFreeExtent
        Write-Host " - Niet gebruikte schijfruimte: $unallocatedDiskSize" -foregroundcolor Yellow

        $allowedSize = (Get-PartitionSupportedSize -DiskNumber $disk.Number -PartitionNumber $partitionNum).SizeMax
        Write-Host " - Maximale schijfruimte: $allowedSize"

        if ($unallocatedDiskSize -gt 0 -And $unallocatedDiskSize -le $allowedSize)
        {
            $totalDiskSize = $allowedSize
            
            $resizeOp = Resize-Partition -DriveLetter $driveLetter -Size $totalDiskSize
            Write-Host " - Vergroten schijf Gereed" -foregroundcolor green
			sleep 2
        }
        else {
            Write-Host " - Er is geen ruimte vrij om de schijf te vergroten." -foregroundcolor Green
			Sleep 2
        }
   
} 

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Gereed " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
pause
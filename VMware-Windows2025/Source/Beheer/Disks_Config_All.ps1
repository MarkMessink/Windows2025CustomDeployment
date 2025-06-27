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
write-host "----- Configuratie alle disks " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
Sleep 3
write-host " - Rescan Disks "
Update-HostStorageCache
Sleep 1
write-host " - Zoek ongeconfigureerde disks... "
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
$disks = get-disk | where PartitionStyle -eq RAW
write-host "----- Lijst Disks, indien van toepassing " -foregroundcolor Yellow
$disks
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host ""
pause

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Configuratie Disks in bovenstaande lijst " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
Write-Host ""
Write-Host " - Alle schijven die niet geconfigureerd zijn worden geinventariseerd op basis van schijfgrootte." -foregroundcolor Magenta
Write-Host " - Aan de hand van de schijfgrootte wordt gevraagd wat de driveletter en Label van het volume moet zijn." -foregroundcolor Magenta
Write-Host " - DriveLetter is alleen de Letter zonder verdere toevoegingen " -foregroundcolor Green
Write-Host " - Gebruik voor de DiskLabel alleen hoofdletters " -foregroundcolor Green
Write-Host ""
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
Write-Host "----- Lijst bestaande Volumes: " -foregroundcolor Yellow
get-volume | where DriveType -eq Fixed | Sort Driveletter | FT Driveletter, FileSystemLabel, Size
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
pause

foreach($disk in $disks)

    {
	Clear-Host
	Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
    Write-Host ""
    $RAWDisk = (get-disk $disk.number)
	$RAWDiskSize = ($RAWDisk.Size / 1GB)
	Write-Host " - De te configureren schijf heeft een grootte van $RAWDiskSize GB" -foregroundcolor Green
	Write-Host ""
	$DiskLetter = Read-Host -Prompt ' - Geef de driveletter (Alleen Letter) '
	$DiskLetter = $DiskLetter.Substring(0,1)
	Write-Host ""
	$DiskLabel = Read-Host -Prompt ' - Geef de LABEL naam (Alleen Hoofdletters) '
	Write-Host ""
	Write-Host " - DriveLetter = $DiskLetter" -foregroundcolor Green
	Write-Host " - Label = $DiskLabel" -foregroundcolor Green
	Write-Host ""
	Write-Host " - Controleer gegevens... "
	Write-Host ""
	pause
	Write-Host ""
	Write-Host " - Start Initialiseren, Partitioneren en Formateren..."
	get-disk $RAWDisk.number | Initialize-Disk -PartitionStyle GPT
	get-Disk $RAWDisk.number | New-Partition -UseMaximumSize -DriveLetter $DiskLetter | Format-Volume -FileSystem NTFS -NewFileSystemLabel $DiskLabel -Force -Confirm:$false
	Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
	sleep 2
} 
Write-Host "----- Lijst bestaande Volumes: " -foregroundcolor Yellow
get-volume | where DriveType -eq Fixed | Sort Driveletter | FT Driveletter, FileSystemLabel, Size
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host ""
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Diskconfiguratie Gereed " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
pause
### Powershell Script - Mark Messink - 22-10-2024 - Versie 0.0.1 ###

# Scherminstellingen PowerShell
$Host.UI.RawUI.BackgroundColor = ($bckgrnd = 'Black')
$Host.UI.RawUI.ForegroundColor = 'White'
$Host.PrivateData.ErrorForegroundColor = 'Red'
$Host.PrivateData.ErrorBackgroundColor = $bckgrnd
$Host.PrivateData.WarningForegroundColor = 'Magenta'
$Host.PrivateData.WarningBackgroundColor = $bckgrnd
$Host.PrivateData.DebugForegroundColor = 'Yellow'
$Host.PrivateData.DebugBackgroundColor = $bckgrnd
$Host.PrivateData.VerboseForegroundColor = 'Green'
$Host.PrivateData.VerboseBackgroundColor = $bckgrnd
$Host.PrivateData.ProgressForegroundColor = 'Green'
$Host.PrivateData.ProgressBackgroundColor = $bckgrnd
MODE CON:COLS=170 LINES=50
Clear-Host

#Start script timer
$scripttimer = [system.diagnostics.stopwatch]::StartNew()

# logfile:
$path = "E:\Beheer"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

$logPath = "$PSScriptRoot\IsoWindowsUnattendedPlus.txt"

# Start loggin:
Start-Transcript $logPath -Force

# Start Script:

Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Aanmaken Custom Windows 2025 ISO " -foregroundcolor Yellow
write-host ""
write-host " - Slipstream Windows Patches "
write-host " - Injectie VMware Paravirtual SCSI Drivers "
write-host " - Install VMware Tools "
write-host " - Custom settings Windows2025 - autounattend & Scripts "
write-host " - Klaar zetten Beheer Tooling en Clients "
write-host ""
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- RunPath: $PSScriptRoot " -foregroundcolor green
sleep 2
Write-host "----- Inlezen variabelen " -foregroundcolor Yellow
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue

$RootDir = $PSScriptRoot
write-host " - RootFolder = $RootDir "
$InstallDir = "$RootDir\Source\Install"
$BeheerDir = "$RootDir\Source\Beheer"
$SoftwareDir = "$RootDir\Source\Software"
# Windows ISO
$SourceWindowsISO = Get-ChildItem -name $RootDir\Source\WindowsISO -Filter *.iso
$SourceWindowsISOPath = "$RootDir\Source\WindowsISO\$SourceWindowsIso"
write-host " - Windows ISO Path = $SourceWindowsIsoPath "
# Windows Algemene Patches
$SourceWindowsPatch = Get-ChildItem  -name $RootDir\Source\WindowsPatches -Filter *.msu
$SourceWindowsPatchPath = "$RootDir\Source\WindowsPatches"
write-host " - Windows Patches Path = $SourceWindowsPatchPath"
# Windows Maand Patches
$SourceWindowsMaandPatch = Get-ChildItem  -name $RootDir\Source\WindowsMaandPatch -Filter *.msu
$SourceWindowsMaandPatchPath = "$RootDir\Source\WindowsMaandPatch"
write-host " - Windows Maand Patch Path = $SourceWindowsMaandPatchPath"
# VMware Tools ISO
$VMwareToolsISO = Get-ChildItem -name $RootDir\Source\VMwareToolsISO -Filter *.iso
$VMwareToolsISOPath = "$RootDir\Source\VMwareToolsISO\$VMwareToolsIso"
write-host " - VMware ISO Path = $VMwareToolsISOPath "
# VirtualBox ISO
$VirtualBoxISO = Get-ChildItem -name $RootDir\Source\VirtualBoxISO -Filter *.iso
$VirtualBoxISOPath = "$RootDir\Source\VirtualBoxISO\$VirtualBoxISO"
write-host " - VirtualBox ISO Path = $VirtualBoxISOPath "
# AutoUnattendXML
$AutoUnattendXML = Get-ChildItem -name $RootDir\Source\UnattendXML -Filter *.xml
$AutoUnattendXMLPAth = "$RootDir\Source\UnattendXML\$autounattendXML"
write-host " - Windows Unattend file Path = $AutoUnattendXMLPath "
# Naamgeving Custom Windows2025 ISO
$TimeStamp = "{0:yyyyMMdd-HHmm}" -f (get-date)
write-host " - Build TimeStamp = $TimeStamp "
# $DestinationWindowsIsoPath = "$RootDir\" +  ($SourceWindowsIso -replace ".iso","") + "-" + "$TimeStamp" + ".ISO"
$DestinationWindowsIsoPath = "$RootDir\" +  "Win_Server_2025_64Bit_English" + "-" + "$TimeStamp" + ".ISO"
write-host " - Windows Custom ISO = $DestinationWindowsIsoPath "


Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Controleer de bovenstaande gegevens " -foregroundcolor Yellow
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue

Clear

Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Opschonen omgeving " -foregroundcolor Yellow
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue

write-host "----- Loskoppelen eventueel gekoppelde iso" -foregroundcolor Green
$clearmountpoint = Clear-WindowsCorruptMountPoint

write-host "----- Dismount: $SourceWindowsIsoPath" -foregroundcolor Green
Dismount-DiskImage -imagepath $SourceWindowsIsoPath

write-host "----- Dismount: $VMwareToolsIsoPath" -foregroundcolor Green
Dismount-DiskImage -imagepath $VMwareToolsIsoPath

write-host "----- Dismount: $VirtualBoxIsoPath" -foregroundcolor Green
Dismount-DiskImage -imagepath $VirtualBoxIsoPath

write-host "----- Check mounted Wim images" -foregroundcolor Green
dism /get-mountedwiminfo
write-host ""

write-host "----- Opschonen en opnieuw aanmaken mappenstructuur als deze nog niet bestaat " -foregroundcolor Green
# Opschonen data vorige acties
Remove-Item  -ErrorAction Ignore -Recurse "$RootDir\Parkeerplaats" -Force # Leeg maken tijdelijke bestanden
# Aanmaken folderstructuur (als deze nog niet bestaat, Zie installatiedocument)
$newmap = New-Item -ErrorAction Ignore -ItemType Directory -Path "$RootDir\Source\WindowsISO" -Force # Locatie van de originele Windows ISO
$newmap = New-Item -ErrorAction Ignore -ItemType Directory -Path "$RootDir\Source\WindowsPatches" -Force # Locatie van de Algemene Windows Patches
$newmap = New-Item -ErrorAction Ignore -ItemType Directory -Path "$RootDir\Source\WindowsMaandPatch" -Force # Locatie van de cumulatieve Maand Patch
$newmap = New-Item -ErrorAction Ignore -ItemType Directory -Path "$RootDir\Source\Install" -Force # Locatie van de tools en scripts voor de verdere installatie en configuratie Windows
$newmap = New-Item -ErrorAction Ignore -ItemType Directory -Path "$RootDir\Source\UnattendXML" -Force # Locatie van de autounattend.xml
$newmap = New-Item -ErrorAction Ignore -ItemType Directory -Path "$RootDir\Source\VMwareToolsISO" -Force # Locatie van de VMware Tools ISO
$newmap = New-Item -ErrorAction Ignore -ItemType Directory -Path "$RootDir\Source\VirtualBoxISO" -Force # Locatie van de VirtualBox ISO
$newmap = New-Item -ErrorAction Ignore -ItemType Directory -Path "$RootDir\Source\Software" # Locatie van software
$newmap = New-Item -ErrorAction Ignore -ItemType Directory -Path "$RootDir\Source\Beheer" # Locatie beheerscripts

# Aanmaken folderstructuur voor plaatsen bestanden op de Custom Windows ISO
$newmap = New-Item -ErrorAction Ignore -ItemType Directory -Path "$RootDir\Parkeerplaats\WorkingFolder\VMware" -Force 
$newmap = New-Item -ErrorAction Ignore -ItemType Directory -Path "$RootDir\Parkeerplaats\WorkingFolder\Beheer" -Force
$newmap = New-Item -ErrorAction Ignore -ItemType Directory -Path "$RootDir\Parkeerplaats\WorkingFolder\Software" -Force
$newmap = New-Item -ErrorAction Ignore -ItemType Directory -Path "$RootDir\Parkeerplaats\WorkingFolder\Install" -Force
$newmap = New-Item -ErrorAction Ignore -ItemType Directory -Path "$RootDir\Parkeerplaats\MountWindows" -Force

Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Koppelen Windows ISO en opvragen driveletter " -foregroundcolor Yellow
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
$MountSourceWindowsIso = mount-diskimage -imagepath $SourceWindowsIsoPath -passthru
$DriveSourceWindowsIso = ($MountSourceWindowsIso | get-volume).driveletter + ':'
write-host "----- DiskImage: $SourceWindowsIsoPath" -foregroundcolor Green
write-host "----- Drive $DriveSourceWindowsIso" -foregroundcolor Green

Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Koppelen VMware Tools ISO en opvragen driveletter " -foregroundcolor Yellow
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
$MountVMwareToolsIso = mount-diskimage -imagepath $VMwareToolsIsoPath -passthru
$DriveVMwareToolsIso = ($MountVMwareToolsIso  | get-volume).driveletter + ':'
write-host "----- DiskImage: $VMwareToolsIsoPath" -foregroundcolor Green
write-host "----- Drive $DriveVMwareToolsIso" -foregroundcolor Green
$pvscsiPath = $DriveVMwareToolsIso + "\Program Files\VMware\VMware Tools\Drivers\pvscsi\Win8\amd64\pvscsi.inf" # Locatie paravirtual Driver in ISO

Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Koppelen VirtualBox ISO en opvragen driveletter " -foregroundcolor Yellow
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
$MountVirtualBoxIso = mount-diskimage -imagepath $VirtualBoxIsoPath -passthru
$DriveVirtualBoxIso = ($MountVirtualBoxIso  | get-volume).driveletter + ':'
write-host "----- DiskImage: $VirtualBoxIsoPath" -foregroundcolor Green
write-host "----- Drive $DriveVirtualBoxIso" -foregroundcolor Green
$virtioPath = $DriveVirtualBoxIso + "\amd64\2k22\viostor.inf" # Locatie Windows2025 Driver in ISO

Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Kopieren Windows ISO naar werkdir " -foregroundcolor Yellow
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Copy content: $SourceWindowsISO " -foregroundcolor Green
write-host ""
write-host "----- Bezig met kopieren. Enkele minuten geduld... " -foregroundcolor Green
copy-item $DriveSourceWindowsIso\* -Destination "$RootDir\Parkeerplaats\WorkingFolder" -force -recurse
write-host "----- verwijderen read-only attribute van bestanden " -foregroundcolor Green
get-childitem "$RootDir\Parkeerplaats\WorkingFolder" -recurse | %{ if (! $_.psiscontainer) { $_.isreadonly = $false } }

Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- kopieren VMware-tools exe naar werkdir " -foregroundcolor Yellow
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Copy content: $VMwareToolsIso" -foregroundcolor Green
copy-item "$DriveVMwareToolsIso\setup.exe" -Destination "$RootDir\Parkeerplaats\WorkingFolder\VMware"

Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- kopieren Install naar werkdir " -foregroundcolor Yellow
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Copy content: $InstallDir" -foregroundcolor Green
copy-item $InstallDir\* -Destination "$RootDir\Parkeerplaats\WorkingFolder\Install" -force -recurse

Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- kopieren Beheer naar werkdir " -foregroundcolor Yellow
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Copy content: $InstallDir" -foregroundcolor Green
copy-item $BeheerDir\* -Destination "$RootDir\Parkeerplaats\WorkingFolder\Beheer" -force -recurse

Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- kopieren Software naar werkdir " -foregroundcolor Yellow
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Copy content: $InstallDir" -foregroundcolor Green
copy-item $SoftwareDir\* -Destination "$RootDir\Parkeerplaats\WorkingFolder\Software" -force -recurse

Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Genereren Custom Buildnummer " -foregroundcolor Yellow
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Buildnummer $TimeStamp" -foregroundcolor Green
$TimeStamp | Out-file -filepath "$RootDir\Parkeerplaats\WorkingFolder\Beheer\build.xml"

Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Disable Defender Real Time Monitoring" -foregroundcolor Yellow
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
Set-MpPreference -DisableRealtimeMonitoring $true

sleep 3
clear

Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Start injecteren ParaVirtual SCSI Drivers - boot.wim " -foregroundcolor Yellow
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
Write-Host ""
Write-Host ""
Write-Host "" # banner space
Write-Host ""
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Injecteren ParaVirtual SCSI Drivers in de volgende Images: " -foregroundcolor Green
(Get-WindowsImage -ImagePath "$RootDir\Parkeerplaats\WorkingFolder\sources\boot.wim").ImageName
$BootWIM = Get-WindowsImage -ImagePath "$RootDir\Parkeerplaats\WorkingFolder\sources\boot.wim" | foreach-object {
	$imgtime = (get-date).ToString('T')
	Write-Host " - Mount image... ($imgtime)"
	Mount-WindowsImage -ImagePath "$RootDir\Parkeerplaats\WorkingFolder\sources\boot.wim" -Index ($_.ImageIndex) -Path "$RootDir\Parkeerplaats\MountWindows" -Optimize
	Write-Host " - Add VMware Paravirtual Driver... "
	$BootWIM = Add-WindowsDriver -path "$RootDir\Parkeerplaats\MountWindows" -driver $pvscsiPath -ForceUnsigned
	Write-Host " - Add VirtualBox vio Driver... "
	$BootWIM = Add-WindowsDriver -path "$RootDir\Parkeerplaats\MountWindows" -driver $virtioPath -ForceUnsigned
	Write-Host " - Dismount en Save image... "
	Dismount-WindowsImage -path "$RootDir\Parkeerplaats\MountWindows" -save
	Write-Host " - Image gereed "
}

sleep 1
clear

Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Start injecteren Virtual SCSI Drivers en laatste Windows Updates - install.wim " -foregroundcolor Yellow
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
Write-Host ""
Write-Host ""
Write-Host "" # banner space
Write-Host ""
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
Write-host "----- Afhankelijk van het aantal patches kan deze handeling even duren. Een moment geduld... " -foregroundcolor DarkGreen
Write-Host ""
write-host "----- Reguliere Patches: " -foregroundcolor Green
$SourceWindowsPatch | FT Name
write-host "----- Maand Patches: " -foregroundcolor Green
$SourceWindowsMaandPatch | FT Name
write-host "----- Image Index List: " -foregroundcolor Green
(Get-WindowsImage -ImagePath "$RootDir\Parkeerplaats\WorkingFolder\sources\install.wim").ImageName

##################### SLIPSTREAM #####################
##################### index 1 - Windows Server 2025 Standard (Core)
<#
write-host "----- Running Image: " -foregroundcolor Green
(Get-WindowsImage -ImagePath "$RootDir\Parkeerplaats\WorkingFolder\sources\install.wim" -index 1).ImageName

$imgtime = (get-date).ToString('T')
Write-Host " - Mount image... ($imgtime)"
$InstallWIM = Mount-WindowsImage -ImagePath "$RootDir\Parkeerplaats\WorkingFolder\sources\install.wim" -Index 1 -Path "$RootDir\Parkeerplaats\MountWindows" -Optimize

$imgtime = (get-date).ToString('T')
Write-Host " - Add Microsoft Algemene Patches... ($imgtime)"
$InstallWIM = Add-WindowsPackage -Path "$RootDir\Parkeerplaats\MountWindows" -PackagePath "$SourceWindowsPatchPath" -IgnoreCheck

$imgtime = (get-date).ToString('T')
Write-Host " - Add Microsoft Cumulatieve Maand Patches... ($imgtime)"
$InstallWIM = Add-WindowsPackage -Path "$RootDir\Parkeerplaats\MountWindows" -PackagePath "$SourceWindowsMaandPatchPath" -IgnoreCheck

$imgtime = (get-date).ToString('T')
Write-Host " - Add VMware Paravirtual Driver... ($imgtime)"
$InstallWIM = Add-WindowsDriver -path "$RootDir\Parkeerplaats\MountWindows" -driver $pvscsiPath -ForceUnsigned

$imgtime = (get-date).ToString('T')
Write-Host " - Add VirtualBox vio Driver... ($imgtime)"
$InstallWIM = Add-WindowsDriver -path "$RootDir\Parkeerplaats\MountWindows" -driver $virtioPath -ForceUnsigned

$imgtime = (get-date).ToString('T')
Write-Host " - Dismount en Save image... ($imgtime)"
$InstallWIM = Dismount-WindowsImage -path "$RootDir\Parkeerplaats\MountWindows" -save -CheckIntegrity

Write-Host " - Image gereed "
Write-Host ""
#>

##################### index 2 - Windows Server 2025 Standard (Desktop Experience)
write-host "----- Running Image: " -foregroundcolor Green
(Get-WindowsImage -ImagePath "$RootDir\Parkeerplaats\WorkingFolder\sources\install.wim" -index 2).ImageName

$imgtime = (get-date).ToString('T')
Write-Host " - Mount image... ($imgtime)"
$InstallWIM = Mount-WindowsImage -ImagePath "$RootDir\Parkeerplaats\WorkingFolder\sources\install.wim" -Index 2 -Path "$RootDir\Parkeerplaats\MountWindows" -Optimize

$imgtime = (get-date).ToString('T')
Write-Host " - Add Microsoft Algemene Patches... ($imgtime)"
$InstallWIM = Add-WindowsPackage -Path "$RootDir\Parkeerplaats\MountWindows" -PackagePath "$SourceWindowsPatchPath" -IgnoreCheck

$imgtime = (get-date).ToString('T')
Write-Host " - Add Microsoft Cumulatieve Maand Patches... ($imgtime)"
$InstallWIM = Add-WindowsPackage -Path "$RootDir\Parkeerplaats\MountWindows" -PackagePath "$SourceWindowsMaandPatchPath" -IgnoreCheck

$imgtime = (get-date).ToString('T')
Write-Host " - Add VMware Paravirtual Driver... ($imgtime)"
$InstallWIM = Add-WindowsDriver -path "$RootDir\Parkeerplaats\MountWindows" -driver $pvscsiPath -ForceUnsigned

$imgtime = (get-date).ToString('T')
Write-Host " - Add VirtualBox vio Driver... ($imgtime)"
$InstallWIM = Add-WindowsDriver -path "$RootDir\Parkeerplaats\MountWindows" -driver $virtioPath -ForceUnsigned

$imgtime = (get-date).ToString('T')
Write-Host " - Dismount en Save image... ($imgtime)"
$InstallWIM = Dismount-WindowsImage -path "$RootDir\Parkeerplaats\MountWindows" -save -CheckIntegrity

Write-Host " - Image gereed "
Write-Host ""

##################### index 3 - Windows Server 2025 Datacenter (Core)
<#
write-host "----- Running Image: " -foregroundcolor Green
(Get-WindowsImage -ImagePath "$RootDir\Parkeerplaats\WorkingFolder\sources\install.wim" -index 3).ImageName

$imgtime = (get-date).ToString('T')
Write-Host " - Mount image... ($imgtime)"
$InstallWIM = Mount-WindowsImage -ImagePath "$RootDir\Parkeerplaats\WorkingFolder\sources\install.wim" -Index 2 -Path "$RootDir\Parkeerplaats\MountWindows" -Optimize

$imgtime = (get-date).ToString('T')
Write-Host " - Add Microsoft Algemene Patches... ($imgtime)"
$InstallWIM = Add-WindowsPackage -Path "$RootDir\Parkeerplaats\MountWindows" -PackagePath "$SourceWindowsPatchPath" -IgnoreCheck

$imgtime = (get-date).ToString('T')
Write-Host " - Add Microsoft Cumulatieve Maand Patches... ($imgtime)"
$InstallWIM = Add-WindowsPackage -Path "$RootDir\Parkeerplaats\MountWindows" -PackagePath "$SourceWindowsMaandPatchPath" -IgnoreCheck

$imgtime = (get-date).ToString('T')
Write-Host " - Add VMware Paravirtual Driver... ($imgtime)"
$InstallWIM = Add-WindowsDriver -path "$RootDir\Parkeerplaats\MountWindows" -driver $pvscsiPath -ForceUnsigned

$imgtime = (get-date).ToString('T')
Write-Host " - Add VirtualBox vio Driver... ($imgtime)"
$InstallWIM = Add-WindowsDriver -path "$RootDir\Parkeerplaats\MountWindows" -driver $virtioPath -ForceUnsigned

$imgtime = (get-date).ToString('T')
Write-Host " - Dismount en Save image... ($imgtime)"
$InstallWIM = Dismount-WindowsImage -path "$RootDir\Parkeerplaats\MountWindows" -save -CheckIntegrity

Write-Host " - Image gereed "
Write-Host ""
#>

##################### index 4 - Windows Server 2025 Datacenter (Desktop Experience)
<#
write-host "----- Running Image: " -foregroundcolor Green
(Get-WindowsImage -ImagePath "$RootDir\Parkeerplaats\WorkingFolder\sources\install.wim" -index 4).ImageName

$imgtime = (get-date).ToString('T')
Write-Host " - Mount image... ($imgtime)"
$InstallWIM = Mount-WindowsImage -ImagePath "$RootDir\Parkeerplaats\WorkingFolder\sources\install.wim" -Index 2 -Path "$RootDir\Parkeerplaats\MountWindows" -Optimize

$imgtime = (get-date).ToString('T')
Write-Host " - Add Microsoft Algemene Patches... ($imgtime)"
$InstallWIM = Add-WindowsPackage -Path "$RootDir\Parkeerplaats\MountWindows" -PackagePath "$SourceWindowsPatchPath" -IgnoreCheck

$imgtime = (get-date).ToString('T')
Write-Host " - Add Microsoft Cumulatieve Maand Patches... ($imgtime)"
$InstallWIM = Add-WindowsPackage -Path "$RootDir\Parkeerplaats\MountWindows" -PackagePath "$SourceWindowsMaandPatchPath" -IgnoreCheck

$imgtime = (get-date).ToString('T')
Write-Host " - Add VMware Paravirtual Driver... ($imgtime)"
$InstallWIM = Add-WindowsDriver -path "$RootDir\Parkeerplaats\MountWindows" -driver $pvscsiPath -ForceUnsigned

$imgtime = (get-date).ToString('T')
Write-Host " - Add VirtualBox vio Driver... ($imgtime)"
$InstallWIM = Add-WindowsDriver -path "$RootDir\Parkeerplaats\MountWindows" -driver $virtioPath -ForceUnsigned

$imgtime = (get-date).ToString('T')
Write-Host " - Dismount en Save image... ($imgtime)"
$InstallWIM = Dismount-WindowsImage -path "$RootDir\Parkeerplaats\MountWindows" -save -CheckIntegrity

Write-Host " - Image gereed "
Write-Host ""
#>

sleep 3
clear

Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Remove Images from index - install.wim " -foregroundcolor Yellow
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
Write-Host ""
Write-Host ""
Write-Host "" # banner space
Write-Host ""
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
Write-host "----- Een moment geduld... " -foregroundcolor DarkGreen
Write-Host ""
Write-host "----- Image Index List: " -foregroundcolor Green
(Get-WindowsImage -ImagePath "$RootDir\Parkeerplaats\WorkingFolder\sources\install.wim").ImageName
Write-Host ""

##################### REMOVE FROM INDEX #####################


##################### index 4 - Windows Server 2025 Datacenter (Desktop Experience)
write-host "----- Remove Image from index: " -foregroundcolor Green
(Get-WindowsImage -ImagePath "$RootDir\Parkeerplaats\WorkingFolder\sources\install.wim" -index 4).ImageName
$imgtime = (get-date).ToString('T')
Write-Host " - Remove image from Index... ($imgtime)"
$RemoveWIM = Remove-WindowsImage -ImagePath "$RootDir\Parkeerplaats\WorkingFolder\sources\install.wim" -Index 4 -CheckIntegrity
Write-Host " - Image gereed "
Write-Host ""


##################### index 3 - Windows Server 2025 Datacenter (Core)
write-host "----- Remove Image from index: " -foregroundcolor Green
(Get-WindowsImage -ImagePath "$RootDir\Parkeerplaats\WorkingFolder\sources\install.wim" -index 3).ImageName
$imgtime = (get-date).ToString('T')
Write-Host " - Remove image from Index... ($imgtime)"
$RemoveWIM = Remove-WindowsImage -ImagePath "$RootDir\Parkeerplaats\WorkingFolder\sources\install.wim" -Index 3 -CheckIntegrity
Write-Host " - Image gereed "
Write-Host ""


##################### index 2 - Windows Server 2025 Standard (Desktop Experience)
<#
write-host "----- Remove Image from index: " -foregroundcolor Green
(Get-WindowsImage -ImagePath "$RootDir\Parkeerplaats\WorkingFolder\sources\install.wim" -index 2).ImageName
$imgtime = (get-date).ToString('T')
Write-Host " - Remove image from Index... ($imgtime)"
$RemoveWIM = Remove-WindowsImage -ImagePath "$RootDir\Parkeerplaats\WorkingFolder\sources\install.wim" -Index 3 -CheckIntegrity
Write-Host " - Image gereed "
Write-Host ""
#>

##################### index 1 - Windows Server 2025 Standard (Core)
write-host "----- Remove Image from index: " -foregroundcolor Green
(Get-WindowsImage -ImagePath "$RootDir\Parkeerplaats\WorkingFolder\sources\install.wim" -index 1).ImageName
$imgtime = (get-date).ToString('T')
Write-Host " - Remove image from Index... ($imgtime)"
$RemoveWIM = Remove-WindowsImage -ImagePath "$RootDir\Parkeerplaats\WorkingFolder\sources\install.wim" -Index 1 -CheckIntegrity
Write-Host " - Image gereed "
Write-Host ""

sleep 3
clear

Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Toevoegen autounattend " -foregroundcolor Yellow
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- copy $AutoUnattendXmlPath" -foregroundcolor Green
copy-item $AutoUnattendXmlPath -Destination "$RootDir\Parkeerplaats\WorkingFolder\autounattend.xml"

Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Aanmaken nieuwe custom ISO " -foregroundcolor Yellow
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
# https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/oscdimg-command-line-options
$OcsdimgPath = "$RootDir\Source\Oscdimg"
$oscdimg  = "$OcsdimgPath\oscdimg.exe"
$etfsboot = "$OcsdimgPath\etfsboot.com"
$efisys   = "$OcsdimgPath\efisys.bin"
$data = '2#p0,e,b"{0}"#pEF,e,b"{1}"' -f $etfsboot, $efisys
start-process $oscdimg -args @("-bootdata:$data",'-u2','-udfver102', "$RootDir\Parkeerplaats\WorkingFolder", $DestinationWindowsIsoPath) -wait -nonewwindow

Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- loskoppelen gekoppelde iso " -foregroundcolor Yellow
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Dismount $SourceWindowsIsoPath" -foregroundcolor Green
Dismount-DiskImage -imagepath $SourceWindowsIsoPath
write-host "----- Dismount $VMwareToolsIsoPath" -foregroundcolor Green
Dismount-DiskImage -imagepath $VMwareToolsIsoPath
write-host "----- Dismount $VirtualBoxIsoPath" -foregroundcolor Green
Dismount-DiskImage -imagepath $VirtualBoxIsoPath

Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Enable Defender Real Time Monitoring" -foregroundcolor Yellow
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
Set-MpPreference -DisableRealtimeMonitoring $false

Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Opschonen Temp files " -foregroundcolor Yellow
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
Remove-Item  -ErrorAction Ignore -Recurse "$RootDir\Parkeerplaats" -Force # Leeg maken tijdelijke bestanden

Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Script Gereed " -foregroundcolor Yellow
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue

#Stop and display script timer
$scripttimer.Stop()
Write-Output "-------------------------------------------------------------------"
Write-Output "Script elapsed time:"
$scripttimer.elapsed
Write-Output "-------------------------------------------------------------------"

#Stop Logging
Stop-Transcript

Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- ISO Gereed voor de installatie van de VMware Template " -foregroundcolor Yellow
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
pause
sleep 2
explorer $RootDir
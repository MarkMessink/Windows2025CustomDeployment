### Powershell Script - Mark Messink - 10-04-2025 - Versie 0.1.4 ###

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
# De inhoud van dit script kan overgenomen worden binnen VMware voor de deployment van Windows2025

# PreRequirements:

# pad en naam logfile:
$path = "C:\Install"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

$logPath = "$path\1stBoot_Windows2025.txt"

# Start loggin:
Start-Transcript $logPath -Append -Force


# Start Script:

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- 1st Boot Script t.b.v. Windows 2025 aanpassingen volgens: " -foregroundcolor Yellow
write-host ""
write-host "      LLD Windows2025 Standaard " -foregroundcolor Green
Write-Host ""
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Controle Windows GUI of CORE editie " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
$CHKCore = test-path "$env:windir\explorer.exe" # Contole aanwezigheid bestand. Bij de Core editie bestaat dit bestand niet
IF ($CHKCore -eq $True) {write-host "----- Windows GUI Editie" -foregroundcolor green} ELSE {write-host "----- Windows CORE Editie"  -foregroundcolor green}

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Installatie Software " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue

<# Example Installatie app op GUI Edition
IF ($CHKCore -eq $True) {
write-host "----- Installatie Edge Chromium Browser, Alleen Windows 2025 GUI Editie " -foregroundcolor Yellow
sleep 1
Powershell -Mta -NoLogo -ExecutionPolicy RemoteSigned -File E:\Install\install_edge_browser.ps1
}
clear-host
#>

<# Example Installatie app
write-host "----- Installatie ODBC driver " -foregroundcolor Yellow
sleep 1
Powershell -Mta -NoLogo -ExecutionPolicy RemoteSigned -File E:\Install\install_odbc_driver.ps1
clear-host
#>

<#
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Onboard Server in Microsoft Defender for Endpoint " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
$onboardServer = "E:\Install\WindowsDefenderATPOnboardingScript.cmd"
Start-process $onboardServer -Wait -NoNewWindow
sleep 1
#>

<#
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Connect to Azure ARC and deploy the Azure Connected Machine agent " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
$ArgumentList = '-Mta -NoLogo -ExecutionPolicy RemoteSigned -File E:\Install\Connect-AzureArc.ps1'
Start-Process Powershell -Wait -ArgumentList $ArgumentList 
#>


Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Aanpassen naamgeving Netwerkadapter " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
# Naam niet meer dan 9 tekens. ivm azure monitor vm-insights. 
Get-NetAdapter -Name Ethernet* | Rename-NetAdapter -NewName "Prod-LAN"
sleep 1

<#
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Aanpassen Startmenu " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
# Startmenu naar links
Set-ItemProperty -Path HKCU:\software\microsoft\windows\currentversion\explorer\advanced -Name 'TaskbarAl' -Type 'DWord' -Value 0
# Searchbar to icon
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name 'SearchboxTaskbarMode' -Type 'DWord' -Value 1
sleep 1
<#
REG LOAD HKLM\Default C:\Users\Default\NTUSER.DAT
 
# Removes Task View from the Taskbar
New-itemproperty "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value "0" -PropertyType Dword
 
# Removes Widgets from the Taskbar
New-itemproperty "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value "0" -PropertyType Dword
 
# Removes Chat from the Taskbar
New-itemproperty "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Value "0" -PropertyType Dword
 
# Default StartMenu alignment 0=Left
New-itemproperty "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value "0" -PropertyType Dword
 
# Removes search from the Taskbar
reg.exe add "HKLM\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 0 /f
 
REG UNLOAD HKLM\Default
#>

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Set Windows Boot menu time-out to 5 sec " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
bcdedit /timeout 5
sleep 1

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Install Latest Windows Server 2025 Drivers " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
Install-Module -Name PSWindowsUpdate -Force
Write-Output "----- Install Windows Drivers"
Get-WindowsUpdate -AcceptAll -UpdateType Driver -Download -Install -IgnoreReboot | FT

<#
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Install Latest Windows Server 2025 Patches " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
Write-Output "----- Install Windows Updates"
Get-WindowsUpdate -AcceptAll -Download -Install -IgnoreReboot | FT
#>

# GUI only
IF ($CHKCore -eq $True) {
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Change color settings and Color scheme for Production and Development " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Prerequirements "
New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS

write-host "----- Algemene Settings - Default User"
new-item "HKU:\.DEFAULT\Software\Microsoft\Windows\DWM" -force 
new-itemproperty -path "HKU:\.DEFAULT\Software\Microsoft\Windows\DWM" -name "ColorPrevalence" -value 1 -PropertyType "DWord" -force | out-null
new-item "HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -force 
new-itemproperty -path "HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -name "ColorPrevalence" -value 1 -PropertyType "DWord" -force | out-null
new-itemproperty -path "HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -name "AppsUseLightTheme" -value 0 -PropertyType "DWord" -force | out-null

write-host "----- Algemene Settings - Current User"
new-itemproperty -path "HKCU:\Software\Microsoft\Windows\DWM" -name "ColorPrevalence" -value 1 -PropertyType "DWord" -force | out-null
new-itemproperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -name "ColorPrevalence" -value 1 -PropertyType "DWord" -force | out-null
new-itemproperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -name "AppsUseLightTheme" -value 0 -PropertyType "DWord" -force | out-null
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue

#Kleur Schema - Blauw - Productie omgeving
write-host "----- Kleur Schema Blauw - Default User"
$AccentPaletteInput = "86,ca,ff,00,5f,b2,f2,00,1e,91,ea,00,00,63,b1,00,00,42,75,00,00,2d,4f,00,00,20,38,00,00,cc,6a,00" # Registry Waarde
$AccentPaletteHEX = $AccentPaletteInput.Split(',') | % { "0x$_"} # Omzetten naar HEX waarde

new-itemproperty -path "HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" -name "AccentPalette" -value $AccentPaletteHEX -PropertyType "Binary" -force | out-null
new-item "HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" -force 
new-itemproperty -path "HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" -name "StartColorMenu" -value 0xff754200 -PropertyType "DWord" -force | out-null
new-itemproperty -path "HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" -name "AccentColorMenu" -value 0xffb16300 -PropertyType "DWord" -force | out-null

write-host "----- Kleur Schema Blauw - Current User"
new-itemproperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" -name "AccentPalette" -value $AccentPaletteHEX -PropertyType "Binary" -force | out-null
new-itemproperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" -name "StartColorMenu" -value 0xff754200 -PropertyType "DWord" -force | out-null
new-itemproperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" -name "AccentColorMenu" -value 0xffb16300 -PropertyType "DWord" -force | out-null
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue

#Kleur Schema - Rood - Developer omgeving
<#
write-host "----- Kleur Schema Rood - Default User"
$AccentPaletteInput = "ff,bd,c2,00,ff,99,a1,00,f0,59,65,00,e8,11,23,00,99,00,0d,00,6e,00,09,00,47,00,06,00,69,79,7e,00" # Registry Waarde
$AccentPaletteHEX = $AccentPaletteInput.Split(',') | % { "0x$_"} # Omzetten naar HEX waarde

new-itemproperty -path "HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" -name "AccentPalette" -value $AccentPaletteHEX -PropertyType "Binary" -force | out-null
new-item "HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" -force 
new-itemproperty -path "HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" -name "StartColorMenu" -value 0xff0d0099 -PropertyType "DWord" -force | out-null
new-itemproperty -path "HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" -name "AccentColorMenu" -value 0xff2311e8 -PropertyType "DWord" -force | out-null

write-host "----- Kleur Schema Rood - Current User"
new-itemproperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" -name "AccentPalette" -value $AccentPaletteHEX -PropertyType "Binary" -force | out-null
new-itemproperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" -name "StartColorMenu" -value 0xff0d0099 -PropertyType "DWord" -force | out-null
new-itemproperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" -name "AccentColorMenu" -value 0xff2311e8 -PropertyType "DWord" -force | out-null
#>

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
sleep 1
clear-Host
}# GUI only

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Opschonen Installatie Sources " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
# $RemMap = Remove-Item C:\Install -Force -Recurse
$RemMap = Remove-Item E:\Install -Force -Recurse

# Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
# write-host "----- Opschonen Windows sources " -foregroundcolor Yellow
# Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
# Link: https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/clean-up-the-winsxs-folder
# dism /online /norestart /cleanup-image /startcomponentcleanup
# dism /online /norestart /cleanup-image /startcomponentcleanup /resetbase

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Opschonen Event Logs " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
$logs = Get-EventLog -List | ForEach-Object {$_.Log}
$logs | ForEach-Object {Clear-EventLog -LogName $_ }
Get-EventLog -list
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue

# Herstart server
Shutdown /r /t 10 /c "Na herstart is de server gereed voor gebruik"
Sleep 3

#Stop Logging
Stop-Transcript

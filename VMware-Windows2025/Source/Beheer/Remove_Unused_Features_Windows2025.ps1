### Powershell Script - Mark Messink - 25-11-2022 - Versie 0.0.4 ###

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
MODE CON COLS=136 LINES=40
Clear-Host
# Info

# PreRequirements:

# Start Script:

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Dit Script verwijderd alle sources van Rollen en Faetures die niet geinstalleerd zijn. " -foregroundcolor Yellow
write-host "----- Rollen en Features kunnen na het uitvoeren van dit script alleen nog geinstalleerd worden vanaf de installatiesource (ISO). " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host ""
pause
write-host ""
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Controle Windows GUI of CORE editie " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
$CHKCore = test-path "$env:windir\explorer.exe" # Controle aanwezigheid bestand. Bij de Core editie bestaat dit bestand niet
IF ($CHKCore -eq $True) {write-host "----- Windows GUI Editie" -foregroundcolor green} ELSE {write-host "----- Windows CORE Editie"  -foregroundcolor green}


write-host "----- Verwijderen Source van Rollen en Features die niet geinstalleerd zijn. " -foregroundcolor Green
Get-WindowsFeature | Where-Object {$_.Installed -match "False"} | Uninstall-WindowsFeature -Remove

write-host "----- Verwijderen source gereed. " -foregroundcolor Green
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
sleep 5
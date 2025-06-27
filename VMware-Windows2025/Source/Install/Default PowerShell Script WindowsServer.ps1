<#
.SYNOPSIS
	<wat doet het script in één regel>
	
	FileName:    <scriptnaam>.ps1
    Author:      Mark Messink
    Contact:     
    Created:     2023-01-01
    Updated:     

    Version history:
    1.0.0 - (2023-01-01) Initial Script
	1.0.1 -
	1.1.0 - 

.DESCRIPTION
	<wat doet het script in meerdere regels>

.PARAMETER
	<beschrijf de parameters die eventueel aan het script gekoppeld moeten worden>

.INPUTS


.OUTPUTS
	logfiles:
	PSlog_<naam>	Log gegenereerd door een powershell script
	AIlog_<naam>	Log gegenereerd door de installer van een applicatie bij de installatie van een applicatie
	ADlog_<naam>	Log gegenereerd door de installer van een applicatie bij de de-installatie van een applicatie
	Een datum en tijd wordt automatisch toegevoegd

.EXAMPLE
	./scriptnaam.ps1

.LINK Information

.NOTES
	WindowsBuild:
	Het script wordt uitgevoerd tussen de builds LowestWindowsBuild en HighestWindowsBuild
	LowestWindowsBuild = 14000 = Windows Server 2016
	LowestWindowsBuild = 17000 = Windows Server 2019
	LowestWindowsBuild = 20000 = Windows Server 2022
	LowestWindowsBuild = 26000 = Windows Server 2025
	
	
	Zie: https://learn.microsoft.com/en-us/windows-server/get-started/windows-server-release-info

#>
#################### Scherminstellingen PowerShell ##################
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
#################### Einde Scherminstellingen PowerShell ############


#################### Variabelen #####################################
$logpath = "C:\Install"
$NameLogfile = "PSlog_Logfile-Naam.txt"
$LowestWindowsBuild = 2000 # WindowsServer2022
$HighestWindowsBuild = 30000


#################### Einde Variabelen ###############################


#################### Start base script ##############################
### Niet aanpassen!!!

# Prevent terminating script on error.
$ErrorActionPreference = 'Continue'

# Create logpath (if not exist)
If(!(test-path $logpath))
{
      New-Item -ItemType Directory -Force -Path $logpath
}

# Add date + time to Logfile
$TimeStamp = "{0:yyyyMMdd}" -f (get-date)
$logFile = "$logpath\" + "$TimeStamp" + "_" + "$NameLogfile"

# Start Transcript logging
Start-Transcript $logFile -Append -Force

# Start script timer
$scripttimer = [system.diagnostics.stopwatch]::StartNew()

# Controle Windows Build
$WindowsBuild = [System.Environment]::OSVersion.Version.Build
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Windows Build: $WindowsBuild " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
If ($WindowsBuild -ge $LowestWindowsBuild -And $WindowsBuild -le $HighestWindowsBuild)
{
#################### Start base script ################################

#################### Start uitvoeren script code ####################
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Start uitvoeren script code - tekst tekst tekst " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue

plaats hier code

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue

#################### Einde uitvoeren script code ####################

#################### End base script #######################

# Controle Windows Build
}Else {
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Windows Build versie voldoet niet, de script code is niet uitgevoerd. " -foregroundcolor Red
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
}

#Stop and display script timer
$scripttimer.Stop()
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Script elapsed time in seconds: " -foregroundcolor Yellow
$scripttimer.elapsed.totalseconds
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue

#Stop Logging
Stop-Transcript
#################### End base script ################################

#################### Einde Script ###################################
### Powershell Script - Mark Messink - 15-04-2025 - Versie 0.1.4 ###

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

# pad en naam logfile:
$path = "C:\Install"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

$logPath = "$path\Config_Windows2025.txt"

# Start loggin:
Start-Transcript $logPath -Append -Force

# Start Script:

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Configureren Windows server 2025 installatie " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Controle Windows GUI of CORE editie " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
$CHKCore = test-path "$env:windir\explorer.exe" # Contole aanwezigheid bestand. Bij de Core editie bestaat dit bestand niet
IF ($CHKCore -eq $True) {write-host "----- Windows GUI Editie" -foregroundcolor green} ELSE {write-host "----- Windows CORE Editie"  -foregroundcolor green}

Sleep 5

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Aanpassen Scherm resolutie - 1920 x 1200 " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
# Set-DisplayResolution -Width 1440 -Height 900 -Force
Set-DisplayResolution -Width 1920 -Height 1200 -Force
MODE CON COLS=136 LINES=40

Get-process -Name ServerManage* | stop-process # uitzetten ServerManager

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Set Powershell Execution policy " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
set-executionpolicy RemoteSigned

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Install PowerShell NuGet Package Provider 2.8.5.208 " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
Install-PackageProvider -Name NuGet -Force -RequiredVersion "2.8.5.208" 

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Install Latest Windows Server 2025 Drivers & Patches " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
Install-Module -Name PSWindowsUpdate -Force
Write-Output "----- Install Windows Drivers"
Get-WindowsUpdate -AcceptAll -UpdateType Driver -Download -Install -IgnoreReboot | FT

Write-Output "----- Install Windows Updates"
Get-WindowsUpdate -AcceptAll -Download -Install -IgnoreReboot | FT

# IF GUI
# Disable scheduled task autostart
IF ($CHKCore -eq $True) {
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Disable Autostart Servermanager " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
Get-ScheduledTask -TaskName ServerManage* | Disable-ScheduledTask -Verbose
}

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Set IPv4 als prefered " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
# Aanmaken registry key DisabledComponents en waarde geven
New-ItemProperty “HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters\” -Name “DisabledComponents” -Value 0x20 -PropertyType “DWord”
# Waarde Registry key DisabledComponents aanpassen
# Set-ItemProperty “HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters\” -Name “DisabledComponents” -Value 0x20

# Opties
# 0 = re-enable all IPv6 components (Windows default setting).
# 0xff = disable all IPv6 components except the IPv6 loopback interface. This value also configures Windows to prefer using IPv4 over IPv6 by changing entries in the prefix policy table.
# 0x20 = to prefer IPv4 over IPv6 by changing entries in the prefix policy table.
# 0x10 = disable IPv6 on all nontunnel interfaces (both LAN and Point-to-Point Protocol [PPP] interfaces).
# 0x01 = disable IPv6 on all tunnel interfaces. These include Intra-Site Automatic Tunnel Addressing Protocol (ISATAP), 6to4, and Teredo.
# 0x11 = disable all IPv6 interfaces except for the IPv6 loopback interface.
# Link = https://support.microsoft.com/en-us/kb/929852

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Disable NetBios over TCP/IP " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
# 0: Enable Netbios via DHCP.
# 1: Enable Netbios on the interface.
# 2: Disable Netbios on the interface.
$adapters=(Get-WmiObject "Win32_networkadapterconfiguration" )
Foreach ($adapter in $adapters){
  Write-Host "----- $adapter" -foregroundcolor Green
  $adapter.settcpipnetbios(2)
}

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Configure Transport Encryption " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue

# TLS Info: https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-52r2.pdf
# TLS Info: https://www.forumstandaardisatie.nl/standaard/tls
#  - Disable TLS 1.0
#  - Disable TLS 1.1
#  - Enable TLS 1.2
#  - Enable TLS 1.3
#  - Disable SSL 2.0
#  - Disable SSL 3.0

# CIS Microsoft IIS 10 Benchmark v1.2.0 - 11-15-2022
#  - Disable TLS 1.0
#  - Disable TLS 1.1
#  - Enable TLS 1.2
#  - Disable SSL 2.0
#  - Disable SSL 3.0
#  - Disable NULL Cipher Suites
#  - Disable DES Cipher Suites
#  - Disable RC4 Cipher Suites
#  - Disable AES 128/128 Cipher Suite
#  - Enable AES 256/256 Cipher Suite
#  - Configure TLS Cipher Suite ordering

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Disable TLS 1.0 (CIS 7.4(L1))" -foregroundcolor green
new-item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0" -force 
new-item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -force | out-null
new-item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client" -force | out-null
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -name "Enabled" -value 0 -PropertyType "DWord" -force | out-null
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -name "DisabledByDefault" -value 1 -PropertyType "DWord" -force | out-null
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client" -name "Enabled" -value 0 -PropertyType "DWord" -force | out-null
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client" -name "DisabledByDefault" -value 1 -PropertyType "DWord" -force | out-null


Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Disable TLS 1.1 (CIS 7.5(L1))" -foregroundcolor green
new-item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1" -force 
new-item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" -force | out-null
new-item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client" -force | out-null
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" -name "Enabled" -value 0 -PropertyType "DWord" -force | out-null
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" -name "DisabledByDefault" -value 1 -PropertyType "DWord" -force | out-null
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client" -name "Enabled" -value 0 -PropertyType "DWord" -force | out-null
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client" -name "DisabledByDefault" -value 1 -PropertyType "DWord" -force | out-null


Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Enable TLS 1.2 (CIS 7.6(L1))" -foregroundcolor green
new-item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2" -force 
new-item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" -force | out-null
new-item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" -force | out-null
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" -name "Enabled" -value 1 -PropertyType "DWord" -force | out-null
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" -name "DisabledByDefault" -value 0 -PropertyType "DWord" -force | out-null
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" -name "Enabled" -value 1 -PropertyType "DWord" -force | out-null
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" -name "DisabledByDefault" -value 0 -PropertyType "DWord" -force | out-null

New-Item 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319' -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319' -Name 'SystemDefaultTlsVersions' -Value '1' -PropertyType 'DWord' -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -PropertyType 'DWord' -Force | Out-Null

New-Item 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -Name 'SystemDefaultTlsVersions' -Value '1' -PropertyType 'DWord' -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -PropertyType 'DWord' -Force | Out-Null
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Enable TLS 1.3 " -foregroundcolor green
new-item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3" -force 
new-item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Server" -force | out-null
new-item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Client" -force | out-null
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Server" -name "Enabled" -value 1 -PropertyType "DWord" -force | out-null
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Server" -name "DisabledByDefault" -value 0 -PropertyType "DWord" -force | out-null
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Client" -name "Enabled" -value 1 -PropertyType "DWord" -force | out-null
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Client" -name "DisabledByDefault" -value 0 -PropertyType "DWord" -force | out-null


Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Disable SSLv2 (CIS 7.2(L1))" -foregroundcolor green
new-item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0" -force 
new-item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server" -force | out-null
new-item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client" -force | out-null
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server" -name "Enabled" -value 0 -PropertyType "DWord" -force | out-null
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server" -name "DisabledByDefault" -value 1 -PropertyType "DWord" -force | out-null
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client" -name "Enabled" -value 0 -PropertyType "DWord" -force | out-null
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client" -name "DisabledByDefault" -value 1 -PropertyType "DWord" -force | out-null


Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Disable SSLv3 (CIS 7.3(L1))" -foregroundcolor green
new-item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0" -force 
new-item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server" -force | out-null
new-item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client" -force | out-null
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server" -name "Enabled" -value 0 -PropertyType "DWord" -force | out-null
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server" -name "DisabledByDefault" -value 1 -PropertyType "DWord" -force | out-null
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client" -name "Enabled" -value 0 -PropertyType "DWord" -force | out-null
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client" -name "DisabledByDefault" -value 1 -PropertyType "DWord" -force | out-null
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue


Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Disable NULL Cipher (CIS 7.7(L1))" -foregroundcolor green
new-item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\NULL" -force
new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\NULL" -name "Enabled" -value 0 -PropertyType "DWord" -force | out-null


Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Disable DES Cipher (CIS 7.8(L1))" -foregroundcolor green
(Get-Item 'HKLM:\').OpenSubKey('SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers', $true).CreateSubKey('DES 56/56')
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\DES 56/56' -name 'Enabled' -value '0' -PropertyType 'DWord' -Force | out-null


Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Disable RC4 Cipher Suites (CIS 7.9(L1))" -foregroundcolor green
(Get-Item 'HKLM:\').OpenSubKey('SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers', $true).CreateSubKey('RC4 40/128')
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 40/128' -name 'Enabled' -value '0' -PropertyType 'DWord' -Force | Out-Null
(Get-Item 'HKLM:\').OpenSubKey('SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers', $true).CreateSubKey('RC4 56/128') 
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 56/128' -name 'Enabled' -value '0' -PropertyType 'DWord' -Force | Out-Null 
(Get-Item 'HKLM:\').OpenSubKey('SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers', $true).CreateSubKey('RC4 64/128') 
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 64/128' -name 'Enabled' -value '0' -PropertyType 'DWord' -Force | Out-Null 
(Get-Item 'HKLM:\').OpenSubKey('SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers', $true).CreateSubKey('RC4 128/128') 
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 128/128' -name 'Enabled' -value '0' -PropertyType 'DWord' -Force | Out-Null
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Disable AES 128/128 Cipher Suite (CIS 7.10(L1))" -foregroundcolor green
(Get-Item 'HKLM:\').OpenSubKey('SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers', $true).CreateSubKey('AES 128/128') 
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\AES 128/128' -name 'Enabled' -value '0' -PropertyType 'DWord' -Force | Out-Null


Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Enable AES 256/256 Cipher Suite (CIS 7.11(L1))" -foregroundcolor green
(Get-Item 'HKLM:\').OpenSubKey('SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers', $true).CreateSubKey('AES 256/256') 
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\AES 256/256' -name 'Enabled' -value '1' -PropertyType 'DWord' -Force | Out-Null


Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Configure TLS Cipher Suite (CIS 7.12(L2))" -foregroundcolor green
New-Item 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002' -Force | Out-Null 
New-ItemProperty -path 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002' -name 'Functions' -value 'TLS_AES_256_GCM_SHA384,TLS_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256' -PropertyType 'MultiString' -Force | Out-Null
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue


Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Remove Last Login Name " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DontDisplayLastUsername" –Value 1

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Set Memory Dumps " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
# 0=Geen 
# 1=Complete dump
# 2=Kernel dump
# 3=Small-memory dump
Get-WmiObject -Class Win32_OSRecoveryConfiguration -EnableAllPrivileges | Set-WmiInstance -Arguments @{ DebugInfoType=3 }
$MemDump = (Get-WmiObject -Class Win32_OSRecoveryConfiguration).DebugInfoType
write-host "----- Memory Dump is ingesteld op: $MemDump " -foregroundcolor Green

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Aanpassen Power Plan " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Set High Performance " -foregroundcolor Green
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
write-host "----- Set monitor timeout naar Never " -foregroundcolor Green
powercfg -change -monitor-timeout-ac 0
write-host "----- Disable Hibernation " -foregroundcolor Green
Powercfg -hibernate off

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Disable AutoPlay " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Explorer' -Name NoDriveTypeAutorun -Type DWord -Value 0xFF

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Disable AutoMount " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\MountMgr' -Name NoAutoMount -Value 1

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Set Telemetry to Security(0) " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\DataCollection -Name AllowTelemetry -Type DWord -Value 0
# 0 = Security
# 1 = Basic
# 2 = Enhanced (default)
# 3 = Full

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Set Storagesetting New Disk Policy --> Online " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
# Deze instelling zorgt er voor dat er geen schijven Offline gaan staan na een herstart van de server. 
Set-StorageSetting -NewDiskPolicy OnlineAll
Get-StorageSetting #Display setting

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Disable Windows Error Reporting " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
Disable-WindowsErrorReporting
Get-WindowsErrorReporting

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Aanpassen driveletter CD-ROM naar Z: " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
$CDDrive = Get-WMIObject –Class Win32_volume –Filter “DriveType=5” | Set-WMIInstance –Arguments @{Driveletter=”Z:”}
sleep 1

<#
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Aanmaken Disk D:  " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
# Disk D aanmaken kan pas als CD-ROM een andere driveletter heeft gekregen
get-disk -Number 1 | Initialize-Disk -PartitionStyle GPT
get-Disk -Number 1 | New-Partition -UseMaximumSize -DriveLetter D | Format-Volume -FileSystem NTFS -NewFileSystemLabel APPS -Force -Confirm:$false
sleep 1
#>

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Aanmaken en configureren Disk E:  " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
# Disk E aanmaken op RAW device van 20GB
get-disk | Where-Object partitionstyle -eq ‘RAW’ | Where-Object {$_.Size /1GB -match '20'} | Initialize-Disk -PartitionStyle GPT -PassThru | New-Partition -UseMaximumSize -DriveLetter E | Format-Volume -FileSystem NTFS -NewFileSystemLabel APPS -Force -Confirm:$false
sleep 1

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Aanmaken en configureren anders Disks  " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue

$newdisk = get-disk | where partitionstyle -eq 'RAW'
foreach ($d in $newdisk){
$disknum = $d.Number
$dl = get-Disk $d.Number | Initialize-Disk -PartitionStyle GPT -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize
Format-Volume -driveletter $dl.Driveletter -FileSystem NTFS -NewFileSystemLabel "Disk $disknum" -Confirm:$false
}


# Aanmaken standaard folders op de E-schijf.
$DiskDmap = mkdir E:\Beheer
$DiskDmap = mkdir E:\Install
$DiskDmap = mkdir E:\Software

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Kopie Installatie content van DVD-ROM naar E:\Beheer " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
copy-item Z:\Beheer\* -Destination "E:\Beheer\" -force -recurse

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Kopie Installatie content van DVD-ROM naar E:\Install " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
copy-item Z:\Install\* -Destination "E:\Install\" -force -recurse

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Kopie Installatie content van DVD-ROM naar E:\Software " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
copy-item Z:\Software\* -Destination "E:\Software\" -force -recurse

# Check if GUI
IF ($CHKCore -eq $True) {
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Change Logon Background " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
# Rename origineel bestand
Rename-Item -Path "C:\Windows\Web\Screen\img100.jpg" -NewName "img100jpg.origineel" -Force
# Check if GUI dan copy nieuw bestand
copy-item E:\Install\img100.jpg -Destination "C:\Windows\Web\Screen" -force
}

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Enable Remote Desktop " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Enable RDP " -foregroundcolor Green
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" –Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop" #Firewall Remote Desktop
<#
write-host "----- Settings RDP " -foregroundcolor Green
write-host "----- Set MaxDisconnectionTime 15min " -foregroundcolor Green
# MaxDisconnectionTime = 15min = 15 x 60.000msec = 900.000msec
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "MaxDisconnectionTime" –Value 900000
write-host "----- Set MaxIdleTime 6uur " -foregroundcolor Green
# MaxIdleTime = 6uur = 6 x 3.600.000 = 21.600.000msec
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "MaxIdleTime" –Value 21600000
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
#>

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Enable Remote Powershell " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
# Infor: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/enable-psremoting
Enable-PSRemoting -SkipNetworkProfileCheck -Force

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Enable Remote Management " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
# Info: https://docs.microsoft.com/en-us/windows-server/administration/server-manager/configure-remote-management-in-server-manager#to-enable-server-manager-remote-management-by-using-windows-powershell
Configure-SMremoting.exe -enable

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Firewall aanpassingen voor remote beheer " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
# Info: https://docs.microsoft.com/en-us/windows-server/administration/server-core/server-core-manage#to-configure-windows-firewall-to-allow-mmc-snap-ins-to-connect 
# Uitzetten Firewall voor remotebeheerservices
Enable-NetFirewallRule -DisplayGroup "Windows Remote Management" #Remote MMC Access
Enable-NetFirewallRule -DisplayGroup "Remote Event Log Management" #Event Viewer
Enable-NetFirewallRule -DisplayGroup "Remote Service Management" #Services
Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing" #Shared Folders
Enable-NetFirewallRule -DisplayGroup "Performance Logs and Alerts" #Task Scheduler
Enable-NetFirewallRule -DisplayGroup "Remote Volume Management" #Disk Management

# Uitzetten Firewall voor alle profielen
<#
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Disable Firewall " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
netsh advfirewall set allprofiles state off
#>

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Aanpassen Startmenu Default User" -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
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

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Set time zone to W. Europe Standard Time " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
Set-TimeZone -ID "W. Europe Standard Time"

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Set Country or Region to the Netherlands " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
Set-WinHomeLocation -GeoID 176
Set-WinSystemLocale -SystemLocale nl-NL
Set-Culture nl-NL

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Toevoegen ServerType en Buildnummer " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
$Build = get-content -path E:\Beheer\Build.xml
write-host "----- Buildnummer: $Build " -foregroundcolor Green
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name BuildNumber -Value $Build
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name ServerType -Value Server

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Enable BGInfo " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
# Check if GUI
IF ($CHKCore -eq $True) {
# Copy link naar all-users start menu
copy-item E:\beheer\bginfo\bginfo64.lnk "C:\Users\All Users\Microsoft\Windows\Start Menu\Programs\StartUp" -force
}

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- verwijderen read-only attribute van bestanden E-schijf " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
get-childitem "E:\" -recurse | %{ if (! $_.psiscontainer) { $_.isreadonly = $false } }
sleep 3

#Stop Logging
Stop-Transcript
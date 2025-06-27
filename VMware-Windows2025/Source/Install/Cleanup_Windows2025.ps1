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

$logPath = "$path\Cleanup_Windows2025.txt"

# Start loggin:
Start-Transcript $logPath -Append -Force

# Start Script:

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Minimaliseren footprint Windows server 2025 installatie " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Controle Windows GUI of CORE editie " -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
$CHKCore = test-path "$env:windir\explorer.exe" # Contole aanwezigheid bestand. Bij de Core editie bestaat dit bestand niet
IF ($CHKCore -eq $True) {write-host "----- Windows GUI Editie" -foregroundcolor green} ELSE {write-host "----- Windows CORE Editie"  -foregroundcolor green}

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Disable ongebruikte Windows Services" -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
# Info: https://docs.microsoft.com/en-us/windows-server/security/windows-services/security-guidelines-for-disabling-system-services-in-windows-server
# Recommendation: OK to disabled: This service provides functionality that is useful to some but not all enterprises, and security-focused enterprises that don't use it can safely disable it.

# ActiveX Installer (AxInstSV)
# OK to disable if feature not needed

Get-Service "AxInstSV*" | set-service -startuptype disabled
# Bluetooth Support Service
# OK to disable if not used
Get-Service "bthserv*" | set-service -startuptype disabled
# CDPUserSvc
# Get-Service "CDPUserSvc" | set-service -startuptype disabled # geeft problemen met uitloggen
# Contact Data
Get-Service "PimIndexMaintenanceSvc" | set-service -startuptype disabled
# dmwappushsvc
Get-Service "dmwappushservice*" | set-service -startuptype disabled
# Downloaded Maps Manager
# OK to disable if apps not relying on it
Get-Service "MapsBroker*" | set-service -startuptype disabled
# Geolocation Service
# OK to disable if apps not relying on it
Get-Service "lfsvc*" | set-service -startuptype disabled
# Internet Connection Sharing (ICS)
Get-Service "SharedAccess*" | set-service -startuptype disabled
# Link-Layer Topology Discovery Mapper
# OK to disable if no dependencies on Network Map
Get-Service "lltdsvc*" | set-service -startuptype disabled
# Microsoft Account Sign-in Assistant
Get-Service "wlidsvc*" | set-service -startuptype disabled
# Microsoft Passport
# Get-Service "NgcSvc" | set-service -startuptype disabled #Permission denied
# Microsoft Passport Container
# Get-Service "NgcCtnrSvc" | set-service -startuptype disabled #Permission denied
# Network Connection Broker
Get-Service "NcbService*" | set-service -startuptype disabled
# Phone Service
Get-Service "PhoneSvc*" | set-service -startuptype disabled
# Print Spooler
# OK to disable if not a print server or a DC
Get-Service "Spooler*" | set-service -startuptype disabled
# Printer Extensions and Notifications
# OK to disable if not a print server
Get-Service "PrintNotify*" | set-service -startuptype disabled
# Quality Windows Audio Video Experience
Get-Service "QWAVE*" | set-service -startuptype disabled
# Radio Management Service
Get-Service "RmSvc*" | set-service -startuptype disabled
# Sensor Data Service
Get-Service "SensorDataService*" | set-service -startuptype disabled
# Sensor Monitoring Service
Get-Service "SensrSvc*" | set-service -startuptype disabled
# Shell Hardware Detection
Get-Service "ShellHWDetection*" | set-service -startuptype disabled
# Smart Card Device Enumeration Service
Get-Service "ScDeviceEnum*" | set-service -startuptype disabled
# SSDP Discovery
Get-Service "SSDPSRV*" | set-service -startuptype disabled
# Still Image Acquisition Events
Get-Service "WiaRpc*" | set-service -startuptype disabled
# Sync Host
# Get-Service "OneSyncSvc*" | set-service -startuptype disabled #Permission denied
# Touch Keyboard and Handwriting Panel Service
Get-Service "TabletInputService*" | set-service -startuptype disabled
# UPnP Device Host
Get-Service "upnphost*" | set-service -startuptype disabled
# User Data Access
Get-Service "UserDataSvc" | set-service -startuptype disabled
# User Data Storage
Get-Service "UnistoreSvc" | set-service -startuptype disabled
# WalletService
Get-Service "WalletService*" | set-service -startuptype disabled
# Windows Audio
Get-Service "Audiosrv*" | set-service -startuptype disabled
# Windows Audio Endpoint Builder
Get-Service "AudioEndpointBuilder*" | set-service -startuptype disabled
# Windows Image Acquisition (WIA)
Get-Service "stisvc*" | set-service -startuptype disabled
# Windows Insider Service
Get-Service "wisvc*" | set-service -startuptype disabled
# Windows Mobile Hotspot Service
Get-Service "icssvc*" | set-service -startuptype disabled
# Windows Push Notifications System Service
Get-Service "WpnService" | set-service -startuptype disabled
# Windows Push Notifications User Service
Get-Service "WpnUserService" | set-service -startuptype disabled

sleep 3
clear

#### Remove Source Windows Features (volgens LLD)
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Verwijderen Source Windows Features" -foregroundcolor Yellow
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
Write-Host ""
Write-Host ""
Write-Host "" # banner space
Write-Host ""
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
write-host "----- Een moment geduld... " -foregroundcolor Green
write-host ""
#Create WhiteList Array
$WhiteListedWindowsFeature = New-Object -TypeName System.Collections.ArrayList

<##### Windows Features that shouldn't be removed (Whitelist) #####>  			
	$WhiteListedWindowsFeature.AddRange(@(
#	"AzureArcSetup"
    "AD-Certificate",
    "ADCS-Cert-Authority",
    "ADCS-Enroll-Web-Pol",
    "ADCS-Enroll-Web-Svc",
    "ADCS-Web-Enrollment",
    "ADCS-Device-Enrollment",
    "ADCS-Online-Cert",
    "AD-Domain-Services",
    "ADFS-Federation",
    "ADLDS",
    "ADRMS",
    "ADRMS-Server",
    "ADRMS-Identity",
    "DeviceHealthAttestationService",
    "DHCP",
    "DNS",
#    "Fax",
    "FileAndStorage-Services",
    "File-Services",
    "FS-FileServer",
    "FS-BranchCache",
    "FS-Data-Deduplication",
    "FS-DFS-Namespace",
    "FS-DFS-Replication",
    "FS-Resource-Manager",
    "FS-VSS-Agent",
    "FS-iSCSITarget-Server",
    "iSCSITarget-VSS-VDS",
    "FS-NFS-Service",
    "FS-SyncShareService",
    "Storage-Services",
    "HostGuardianServiceRole",
    "Hyper-V",
    "NPAS",
    "Print-Services",
    "Print-Server",
    "Print-Internet",
    "Print-LPD-Service",
    "RemoteAccess",
    "DirectAccess-VPN",
    "Routing",
    "Web-Application-Proxy",
    "Remote-Desktop-Services",
    "RDS-Connection-Broker",
    "RDS-Gateway",
    "RDS-Licensing",
    "RDS-RD-Server",
    "RDS-Virtualization",
    "RDS-Web-Access",
    "VolumeActivation",
    "Web-Server",
    "Web-WebServer",
    "Web-Common-Http",
    "Web-Default-Doc",
    "Web-Dir-Browsing",
    "Web-Http-Errors",
    "Web-Static-Content",
    "Web-Http-Redirect",
    "Web-DAV-Publishing",
    "Web-Health",
    "Web-Http-Logging",
    "Web-Custom-Logging",
    "Web-Log-Libraries",
    "Web-ODBC-Logging",
    "Web-Request-Monitor",
    "Web-Http-Tracing",
    "Web-Performance",
    "Web-Stat-Compression",
    "Web-Dyn-Compression",
    "Web-Security",
    "Web-Filtering",
    "Web-Basic-Auth",
    "Web-CertProvider",
    "Web-Client-Auth",
    "Web-Digest-Auth",
    "Web-Cert-Auth",
    "Web-IP-Security",
    "Web-Url-Auth",
    "Web-Windows-Auth",
    "Web-App-Dev",
    "Web-Net-Ext",
    "Web-Net-Ext45",
    "Web-AppInit",
    "Web-ASP",
    "Web-Asp-Net",
    "Web-Asp-Net45",
    "Web-CGI",
    "Web-ISAPI-Ext",
    "Web-ISAPI-Filter",
    "Web-Includes",
    "Web-WebSockets",
    "Web-Ftp-Server",
    "Web-Ftp-Service",
    "Web-Ftp-Ext",
    "Web-Mgmt-Tools",
    "Web-Mgmt-Console",
    "Web-Mgmt-Compat",
    "Web-Metabase",
    "Web-Lgcy-Scripting",
    "Web-WMI",
    "Web-Scripting-Tools",
    "Web-Mgmt-Service",
#    "WDS",
#    "WDS-Deployment",
#    "WDS-Transport",
#    "UpdateServices",
#    "UpdateServices-WidDB",
#    "UpdateServices-Services",
#    "UpdateServices-DB",
    "NET-Framework-Features",
    "NET-Framework-Core",
    "NET-HTTP-Activation",
    "NET-Non-HTTP-Activ",
    "NET-Framework-45-Features",
    "NET-Framework-45-Core",
    "NET-Framework-45-ASPNET",
    "NET-WCF-Services45",
    "NET-WCF-HTTP-Activation45",
    "NET-WCF-MSMQ-Activation45",
    "NET-WCF-Pipe-Activation45",
    "NET-WCF-TCP-Activation45",
    "NET-WCF-TCP-PortSharing45",
    "BITS",
    "BITS-IIS-Ext",
    "BITS-Compact-Server",
    "BitLocker",
    "BitLocker-NetworkUnlock",
    "BranchCache",
    "NFS-Client",
    "Containers",
    "Data-Center-Bridging",
    "Direct-Play",
    "EnhancedStorage",
    "Failover-Clustering",
    "GPMC",
    "HostGuardian",
    "DiskIo-QoS",
    "Web-WHC",
    "Internet-Print-Client",
    "IPAM",
    "LPR-Port-Monitor",
    "ManagementOdata",
    "Server-Media-Foundation",
#    "MSMQ",
#    "MSMQ-Services",
#    "MSMQ-Server",
#    "MSMQ-Directory",
#    "MSMQ-HTTP-Support",
#    "MSMQ-Triggers",
#    "MSMQ-Multicasting",
#    "MSMQ-Routing",
#    "MSMQ-DCOM",
    "Windows-Defender",
    "Multipath-IO",
    "MultiPoint-Connector",
    "MultiPoint-Connector-Services",
    "MultiPoint-Tools",
    "NetworkATC",
#    "NLB",
    "NetworkVirtualization",
    "qWave",
    "CMAK",
#    "Remote-Assistance",
    "RDC",
    "RSAT",
    "RSAT-Feature-Tools",
    "RSAT-Feature-Tools-BitLocker",
    "RSAT-Feature-Tools-BitLocker-RemoteAdminTool",
    "RSAT-Feature-Tools-BitLocker-BdeAducExt",
    "RSAT-Bits-Server",
    "RSAT-DataCenterBridging-LLDP-Tools",
    "RSAT-Clustering",
    "RSAT-Clustering-Mgmt",
    "RSAT-Clustering-PowerShell",
    "RSAT-Clustering-AutomationServer",
    "RSAT-Clustering-CmdInterface",
    "IPAM-Client-Feature",
#    "RSAT-NLB",
    "RSAT-Shielded-VM-Tools",
    "RSAT-SNMP",
    "RSAT-SMS",
    "RSAT-Storage-Replica",
    "RSAT-System-Insights",
    "RSAT-WINS",
    "RSAT-Role-Tools",
    "RSAT-AD-Tools",
    "RSAT-AD-PowerShell",
    "RSAT-ADDS",
    "RSAT-AD-AdminCenter",
    "RSAT-ADDS-Tools",
    "RSAT-ADLDS",
    "RSAT-Hyper-V-Tools",
    "Hyper-V-Tools",
    "Hyper-V-PowerShell",
    "RSAT-RDS-Tools",
    "RSAT-RDS-Gateway",
    "RSAT-RDS-Licensing-Diagnosis-UI",
    "RDS-Licensing-UI",
    "UpdateServices-RSAT",
    "UpdateServices-API",
    "UpdateServices-UI",
    "RSAT-ADCS",
    "RSAT-ADCS-Mgmt",
    "RSAT-Online-Responder",
    "RSAT-ADRMS",
    "RSAT-DHCP",
    "RSAT-DNS-Server",
    "RSAT-Fax",
    "RSAT-File-Services",
    "RSAT-DFS-Mgmt-Con",
    "RSAT-FSRM-Mgmt",
    "RSAT-NFS-Admin",
    "RSAT-NetworkController",
    "RSAT-NPAS",
    "RSAT-Print-Services",
    "RSAT-RemoteAccess",
    "RSAT-RemoteAccess-Mgmt",
    "RSAT-RemoteAccess-PowerShell",
    "RSAT-VA-Tools",
#    "WDS-AdminPack",
    "RPC-over-HTTP-Proxy",
    "Setup-and-Boot-Event-Collection",
    "Simple-TCPIP",
#    "FS-SMB1",
#    "FS-SMB1-CLIENT",
#    "FS-SMB1-SERVER",
    "FS-SMBBW",
    "SNMP-Service",
    "SNMP-WMI-Provider",
#    "SMS",
#    "SMS-Proxy",
    "Storage-Replica",
    "System-DataArchiver",
    "System-Insights",
    "Telnet-Client",
    "TFTP-Client",
    "FabricShieldedTools",
    "WebDAV-Redirector",
    "Biometric-Framework",
    "Windows-Identity-Foundation",
    "Windows-Internal-Database",
    "PowerShellRoot",
    "PowerShell",
    "PowerShell-V2",
    "DSC-Service",
    "WindowsPowerShellWebAccess",
    "WAS",
    "WAS-Process-Model",
    "WAS-NET-Environment",
    "WAS-Config-APIs",
    "Search-Service",
    "Windows-Server-Backup",
#    "Migration",
    "WindowsStorageManagementService",
    "Microsoft-Windows-Subsystem-Linux",
    "Windows-TIFF-IFilter",
    "WinRM-IIS-Ext",
#    "WINS",
#    "Wireless-Networking",
    "WoW64-Support"
#    "XPS-Viewer"
	))
  
	Write-Output "-------------------------------------------------------------------------------"
    Write-Output "Starting WindowsFeatures removal process"	
	Write-Output "-------------------------------------------------------------------------------"
	
	# Determine packagenames from $WhiteListedWindowsFeature
	# $WhiteListedWindowsFeature = foreach ($WindowsFeature in $WhiteListedWindowsFeature) {Get-WindowsCapability -Online -Name $WindowsFeature* | where state -eq installed | Select-Object -ExpandProperty Name}
	
	# determine installed Packagenames
	$InstalledWindowsFeature = Get-WindowsFeature | Select-Object -ExpandProperty Name
			
	# Loop through the list of WindowsFeature
	foreach ($WindowsFeature in $InstalledWindowsFeature) {
		Write-Output "-------------------------------------------------------------------------------"
        Write-Output "Processing WindowsFeature package: $($WindowsFeature)"
		
        # If WindowsFeature name not in WindowsFeature white list, remove WindowsFeature
        if (($WindowsFeature -in $WhiteListedWindowsFeature)) {
            Write-Output "--- Skipping excluded application package"
        }
		else {
		
		    try {
                Write-Output ">>> Removing Windows Feature"
				Get-WindowsFeature | Where-Object { $_.Name -like $WindowsFeature } | Remove-WindowsFeature | Out-Null
                }
				
			catch [System.Exception] {
                Write-Output "!!! Removing Windows Feature failed: $($_.Exception.Message)"
				}
			}
	}
    # Complete
	

Write-Output "-------------------------------------------------------------------------------"
Write-Output "Completed Windows Feature removal process"
Write-Output "-------------------------------------------------------------------------------"
sleep 2
Clear-Host

Write-Output "-------------------------------------------------------------------------------"
Write-Output "Starting Windows Optional Feature removal process"	
Write-Output "-------------------------------------------------------------------------------"
<# list
App.StepsRecorder~~~~0.0.1.0
AzureArcSetup~~~~
Browser.InternetExplorer~~~~0.0.11.0
DirectX.Configuration.Database~~~~0.0.1.0
Downlevel.NLS.Sorting.Versions.Server~~~~0.0.1.0
Language.Basic~~~en-US~0.0.1.0
Language.Basic~~~nl-NL~0.0.1.0
Language.Handwriting~~~en-US~0.0.1.0
Language.Handwriting~~~nl-NL~0.0.1.0
Language.OCR~~~en-US~0.0.1.0
Language.OCR~~~nl-NL~0.0.1.0
Language.Speech~~~en-US~0.0.1.0
Language.TextToSpeech~~~en-US~0.0.1.0
MathRecognizer~~~~0.0.1.0
Media.WindowsMediaPlayer~~~~0.0.12.0
Microsoft.Windows.MSPaint~~~~0.0.1.0
Microsoft.Windows.Notepad~~~~0.0.1.0
Microsoft.Windows.PowerShell.ISE~~~~0.0.1.0
Microsoft.Windows.Sense.Client~~~~
Microsoft.Windows.SnippingTool~~~~0.0.1.0
OneCoreUAP.OneSync~~~~0.0.1.0
OpenSSH.Client~~~~0.0.1.0
OpenSSH.Server~~~~0.0.1.0
VBSCRIPT~~~~
Windows.Kernel.LA57~~~~0.0.1.0
#>

Get-WindowsCapability -Online -LimitAccess -ErrorAction Stop | Where-Object { $_.Name -like "App.StepsRecorder~*" } | Remove-WindowsCapability -Online -ErrorAction Stop | Out-Null
Get-WindowsCapability -Online -LimitAccess -ErrorAction Stop | Where-Object { $_.Name -like "AzureArcSetup~*" } | Remove-WindowsCapability -Online -ErrorAction Stop | Out-Null
Get-WindowsCapability -Online -LimitAccess -ErrorAction Stop | Where-Object { $_.Name -like "MathRecognizer~*" } | Remove-WindowsCapability -Online -ErrorAction Stop | Out-Null
Get-WindowsCapability -Online -LimitAccess -ErrorAction Stop | Where-Object { $_.Name -like "Media.WindowsMediaPlayer~*" } | Remove-WindowsCapability -Online -ErrorAction Stop | Out-Null
Get-WindowsCapability -Online -LimitAccess -ErrorAction Stop | Where-Object { $_.Name -like "Microsoft.Windows.MSPaint~*" } | Remove-WindowsCapability -Online -ErrorAction Stop | Out-Null
# Get-WindowsCapability -Online -LimitAccess -ErrorAction Stop | Where-Object { $_.Name -like "Microsoft.Windows.Notepad~*" } | Remove-WindowsCapability -Online -ErrorAction Stop | Out-Null
Get-WindowsCapability -Online -LimitAccess -ErrorAction Stop | Where-Object { $_.Name -like "Microsoft.Windows.SnippingTool~*" } | Remove-WindowsCapability -Online -ErrorAction Stop | Out-Null
Get-WindowsCapability -Online -LimitAccess -ErrorAction Stop | Where-Object { $_.Name -like "OpenSSH.Client~*" } | Remove-WindowsCapability -Online -ErrorAction Stop | Out-Null
Get-WindowsCapability -Online -LimitAccess -ErrorAction Stop | Where-Object { $_.Name -like "OpenSSH.Server~*" } | Remove-WindowsCapability -Online -ErrorAction Stop | Out-Null
Get-WindowsCapability -Online -LimitAccess -ErrorAction Stop | Where-Object { $_.Name -like "VBSCRIPT~*" } | Remove-WindowsCapability -Online -ErrorAction Stop | Out-Null
# Get-WindowsCapability -Online -LimitAccess -ErrorAction Stop | Where-Object { $_.Name -like "###" } | Remove-WindowsCapability -Online -ErrorAction Stop | Out-Null

Write-Output "-------------------------------------------------------------------------------"
Write-Output "Completed Windows Optional Feature removal process"
Write-Output "-------------------------------------------------------------------------------"
sleep 2
Clear-Host

Write-Output "-------------------------------------------------------------------------------"
Write-Output "Starting Windows APPX removal process"	
Write-Output "-------------------------------------------------------------------------------"
<# list
Microsoft.DesktopAppInstaller_2025.228.315.0_neutral_~_8wekyb3d8bbwe
Microsoft.SecHealthUI_1000.27703.1006.0_x64__8wekyb3d8bbwe
Microsoft.WindowsFeedbackHub_2024.1118.608.0_neutral_~_8wekyb3d8bbwe
Microsoft.WindowsTerminal_3001.21.10351.0_neutral_~_8wekyb3d8bbwe
#>

# Microsoft.WindowsFeedbackHub
Get-AppxPackage | ? {$_.Name -like 'Microsoft.WindowsFeedbackHub*'} | Remove-AppxPackage -AllUsers
Get-AppxProvisionedPackage -Online | ? {$_.DisplayName -Like 'Microsoft.WindowsFeedbackHub'} | Remove-AppxProvisionedPackage -Online

# ###
# Get-AppxPackage | ? {$_.Name -like "###*"} | Remove-AppxPackage -AllUsers
# Get-AppxProvisionedPackage -Online | ? {$_.DisplayName -Like "###"} | Remove-AppxProvisionedPackage -Online

Write-Output "-------------------------------------------------------------------------------"
Write-Output "Completed Windows APPX removal process"
Write-Output "-------------------------------------------------------------------------------"
sleep 2

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------" -foregroundcolor blue
sleep 3

#Stop Logging
Stop-Transcript
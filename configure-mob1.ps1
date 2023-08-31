<#
    .SCRIPT:        configure-mob.ps1
    .DESCRIPTION:   Configure new MOB server using PowerShell
    .AUTHOR:        Zach.Weir
    .UPDATED:       08.25.23
    .CHANGES:
        - 08.20.23 - added coloring for visualization
        - 08.22.23 - added new disk configuration
        - 08.23.23 - added logging
        - 08.25.23 - added error handling
        - 08.28.23 - updated logic for SMB access and folder creation
        - 08.29.23 - added DTOs to SMB access

    PRE-REQ: 
    - Run commands listed on: https://confluence.target.com/display/MobilityEng/VM+server+migration#VMservermigration-ConfigureVM

    !!! THIS SCRIPT MUST BE RUN AS AN ADMINISTRATOR !!!
#> 

Function Write-Log {
    Param(
        [switch] $log,
        [switch] $err,
        [String] $message
        )

    if ($log) {
        $logfile = "Z:\server-migration\mobconfig-log.txt"
        $log_entry = (Get-Date).toString("MM.dd.yy HH:mm:ss")
        $log_entry += " - ${message}"
    }
    if ($error) {
        $logfile = "Z:\server-migration\mobconfig-errs.txt"
        $log_entry += $message
    }

    $log_entry | Add-Content -Path $logfile
}

# GET DTO LIST OF USER IDS
# PUT IN JSON DOC
# CALL JSON DOC PER DC LOCATION

$serverType = "mob"
$siteNumber = Read-Host "Enter site number (####): "

# import DTO LAN IDs into script to grant SMB access
#$csv = Import-CSV c:\temp\users.csv
#$dto_users = @{}
#$csv | % { $dto_users.Add($_.site,$_.lanID) } 

$userIDs = "DHC\Z0018YF", "DHC\Z028710", "DHC\Z0036PM", "DHC\Z042685", "DHC\Z042303", "DHC\CSKEM0", "DHC\Z00C65C", "DHC\Z008L2N", "DHC\Z028710"
#$dto_users."$siteNumber
$folderPaths = "C:\Mobility", "C:\Temp", "D:\awrelay"
$serverName = "t${siteNumber}${serverType}001p"
$serverIP = (Resolve-DnsName -Name $serverName -Type A).IPAddress 

# BEGIN SCRIPT

Write-Host "##########  D${siteNumber} - STARTING MOB SERVER CONFIGURATION  ##########" -BackgroundColor Yellow -ForegroundColor Black
Write-Log -err -message "D${siteNumber}`n"
Write-Log -err -message "----------`n"
Write-Log -log -message "----- D${siteNumber} - STARTING MOB SERVER CONFIGURATION -----"
Write-Host "WARNING: Do NOT run script until the additional disk for D: drive has been created." -BackgroundColor Red -ForegroundColor White

# requires user to select Y or N in order to proceed
do {
    $disk_created = $(Write-Host "Confirm additional disk has been created [y/n]: " -ForegroundColor Red -NoNewline; Read-Host)
} until (($disk_created).ToUpper() -eq "Y" -or ($disk_created).ToUpper() -eq "N")

# exits the script if EXIT KEY is entered
if (($disk_created).ToUpper() -eq "N") {
    Exit
} else {
    # confirm new drive doesn't already show up
    $disks = Get-Volume | Select-Object -ExpandProperty DriveLetter

    # initialize disk and set to D drive
    if ($disks -notcontains "D") {
        Try {
            Get-Disk | Where-Object PartitionStyle -eq "RAW" | Initialize-Disk -errAction Stop | Out-Null  # initialize disk
            Get-Disk | Where-Object IsOffline -eq $true | Set-Disk -IsOffline $false -errAction Stop | Out-Null   # bring disk online
            New-Partition -DiskNumber 1 -DriveLetter D -UseMaximumSize -errAction Stop | Out-Null   # map disk to D drive
            Write-Host "Initalized and mapped D drive"
            Write-Log -log -message "DISK-MAP - Initalized and mapped D drive"
        }
        Catch {
            Write-Host "ERROR - Unable to initalize and map D drive"
            Write-Log -err -message "DISK-MAP - Unable to initalize and map D drive"
            $errorCount++
        }

        # format disk as NTFS
        Try {
            Format-Volume -DriveLetter D -FileSystem NTFS -errAction Stop | Out-Null   # format disk to NTFS
            Write-Host "Formatted new disk as NTFS"
            Write-Log -log -message "DISK-FORMAT - Formatted new disk as NTFS"
        }
        Catch {
            Write-Host "ERROR - Unable to format disk"
            Write-Log -err -message "DISK-FORMAT - Unable to format disk"
            $errorCount++
        }

        # validate disk is online and formatted
        $disk_status = Get-Disk | Where-Object { $_.Number -eq 1 } | Select-Object -ExpandProperty OperationalStatus -errAction Stop | Out-Null  # check if online
        $disk_format = Get-Volume | Where-Object { $_.DriveLetter -eq "D" } | Select-Object -ExpandProperty FileSystem -errAction Stop | Out-Null  # check if NTFS
        if ($disk_status -eq "Online" -and $disk_format -eq "NTFS") {
            Write-Host "Completed D DISK configuration"
        } else {
            Write-Log -err -message "DISK - Unable to validate D drive is configured"
        }
    } elseif ($disks -contains "D") {
        <# NEED TO FIGURE OUT HOW TO DO SOMETHING HERE #>
        Write-Host "D drive already exists"
        Write-Log -log -message "DISK - D drive already exists"
        Write-Log -err -message "DISK - D drive already present -- verify formatting and mapping"
    }
}

# create required folders
foreach ($folder in $folderPaths) {
    if (-not (Test-Path $folder)) {
        Try {
            New-Item -Path $folder -ItemType Directory -errAction Stop | Out-Null 
        }
        Catch {
            Write-Host "DIRECTORY - Unable to create $folder folder"
            Write-Log -err -message "DIRECTORY - Unable to create $folder folder"
        }
        Write-Host "Created $folder folder"
        Write-Log -log -message "DIRECTORY - Created $folder folder"
    
    } elseif (Test-Path $folder) {
        Write-Host "$folder folder already exists"
        Write-Log -log -message "DIRECTORY - $folder folder already exists"
    }
}

Start-Sleep -Seconds 1

# create network drive map script and create file on server
Try {
    $psScript = "New-PSDrive -Name 'Z' -PSProvider 'FileSystem' -Root '\\ifiler-app01\mobility' -Persist -Scope 'Global'"
    $psScript | Set-Content -Path "C:\Mobility\map-drive.ps1" 
    Write-Host "Created map-drive.ps1 in C:\Mobility folder"
    Write-Log -log -message "DIRECTORY-NEWFILE - Created map-drive.ps1 in C:\Mobility folder"
}
Catch {
    Write-Host "Unable to create map-drive.ps1"
    Write-Log -err -message "DIRECTORY-NEWFILE - Unable to create map-drive.ps1"
}

Start-Sleep -Seconds 1

<# CREATE TASK SCHEDULER SCRIPT 
Try {
    $argument = "C:\map-drive.ps1"
    $action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument $argument
    $principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    $task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger
    Register-ScheduledTask "Map Mobility drive" -InputObject $task -Force 
    Write-Host "Created task to map \\ifiler-app01\mobility at logon"
    Write-Log -log -message "TASK SCHEDULER - Created Task Scheduler task to map \\ifiler-app01\mobility at logon"
}
Catch {
    Write-Host "Unable to create task to map \\ifiler-app01\mobility at logon"
    Write-Log -err -message "TASK SCHEDULER - Unable to create task to map \\ifiler-app01\mobility at logon"
}
#>

Start-Sleep -Seconds 1

# create and share Mobility folder as SMB share
Try {
    New-SmbShare -Name "Mobility" -Path $folderPaths[0] -errAction Stop | Out-Null
    Write-Host "Created Mobility SMB share"
    Write-Log -log -message "SMB SHARE - Created Mobility share"

    foreach ($userID in $userIDs) {
        Try {
            Grant-SmbShareAccess -Name "Mobility" -AccountName $userID -AccessRight Full -Force -errAction Stop | Out-Null
            Write-Log -log -message "SMB ACCESS - Granted access for $userID"
        }
        Catch {
            Write-Host "ERROR - Unable to grant access for $userID" -ForegroundColor Red
            Write-Log -err -message "SMB ACCESS - Unable to grant access for $userID"
            $errorCount++
        }
    }     
    Write-Host "Granted SMB share access for all users"
}
Catch {
    Write-Host "ERROR - Unable to create Mobility SMB share" -ForegroundColor Red
    Write-Log -err -message "SMB SHARE - Unable to create Mobility SMB share"
    $errorCount++
}

Start-Sleep -Seconds 1

# enable IIS
Try {
    Install-WindowsFeature -name Web-Server -IncludeManagementTools -errAction Stop | Out-Null 
    Write-Host "IIS - Enabled IIS"
    Write-Log -log -message "Enabled IIS"
}
Catch {
    Write-Host "ERROR - Unable to enable IIS"
    Write-Log -err -message "IIS - Unable to enable IIS"
    $errorCount++
}

Start-Sleep -Seconds 1

# enable FTP
Try {
    Install-WindowsFeature -name Web-FTP-Server -IncludeAllSubFeature -errAction Stop | Out-Null 
    Write-Host "FTP - Enabled FTP"
    Write-Log -log -message "Enabled FTP"
}
Catch {
    Write-Host "ERROR - Unable to enable FTP"
    Write-Log -err -message "FTP - Unable to enable FTP"
    $errorCount++ 
}

Start-Sleep -Seconds 1

# import module for performing IIS configuration
Import-Module WebAdministration

# create FTP site "AirWatch_Relay_Server"
# allow FTP connections from all IPs on port 21 (FTP) 
# 443 (HTTPS/SSL) commented out in case we need it afterall
Try {
    New-WebFtpSite -Name "AirWatch_Relay_Server" -IPAddress "*" -Port 21 -PhysicalPath "C:\Mobility" -errAction Stop | Out-Null 
    #New-WebBinding -Name "AirWatch_Relay_Server" -IPAddress "*" -Port 443 -Protocol "https" -SslFlags 3 -HostHeader $serverIP -errAction Stop | Out-Null 
    Write-Host "Configured FTP site connections for FTP 21" #and HTTPS 443 with Allow SSL turned on
    Write-Log -log -message "FTP-CREATE - Configured FTP site connections for FTP 21" #and HTTPS 443 with Allow SSL turned on
}
Catch {
    Write-Host "ERROR - Unable to create AirWatch_Relay_Server FTP site"
    Write-Log -err -message "FTP-CREATE - Unable to create AirWatch_Relay_Server FTP site"
    $errorCount++
}

Start-Sleep -Seconds 1

# configure FTP site
# set basic auth for dhc\ftawrelay user
Try {
    Set-ItemProperty "IIS:\Sites\AirWatch_Relay_Server" -Name ftpServer.security.authentication.basicAuthentication.enabled -value $true -errAction Stop | Out-Null 
    Add-WebConfiguration "/system.ftpServer/security/authorization" -value @{accessType="Allow";permissions="Read,Write";users="dhc\ftawrelay"} -PSPath IIS:\ -location "AirWatch_Relay_Server" -errAction Stop | Out-Null 
    
    # set port ranges for firewall
    Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter "system.ftpServer/firewallSupport" -name "lowDataChannelPort" -value 5001 -errAction Stop | Out-Null 
    Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter "system.ftpServer/firewallSupport" -name "highDataChannelPort" -value 5001 -errAction Stop | Out-Null 
    
    # set external firewall support
    Set-WebConfigurationProperty -pspath 'IIS:\' -filter "system.applicationHost/sites/siteDefaults/ftpServer/firewallSupport" -name "externalIp4Address" -value $serverIP -errAction Stop | Out-Null 
    Write-Host "Configured FTP authorization for dhc\ftawrelay"
    Write-Log -log -message "FTP-CONFIG - Configured FTP firewall config and user authorization for dhc\ftawrelay"
}
Catch {
    Write-Host "ERROR - Unable to configure firewall config and FTP auth for dhc\ftawrelay"
    Write-Log -err -message "FTP-CONFIG - Unable to configure firewall config and FTP auth for dhc\ftawrelay"
    $errorCount++
}

Start-Sleep -Seconds 1

# restart IIS and FTP services
Try {
    Restart-WebItem "IIS:\Sites\AirWatch_Relay_Server" -errAction Stop | Out-Null 
    Restart-Service -Name "W3SVC" -Force -errAction Stop | Out-Null 
    Write-Host "Restarted IIS and FTP services"
    Write-Log -log -message "SERVICES - Restarted IIS and FTP services"
}
Catch {
    Write-Host "ERROR - Unable to restart IIS or FTP service"
    Write-Log -err -message "SERVICES - Unable to restart IIS or FTP service"
    $errorCount++
}

# FINISH SCRIPT

Write-Host "##############  FINISHED MOB SERVER CONFIGURATION  ##############" -BackgroundColor Green -ForegroundColor Black
Write-Log -log -message "----- COMPLETED D${siteNumber} MOB SERVER CONFIGURATION -----`n"

if ($errorCount -gt 0) {
    Write-Log -err -message "----------`n"
    Write-Log -err "Errors: ${errorCount}`n"
} else {
    Write-Log -err -message "No errors reported`n"
}
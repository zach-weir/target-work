<#
    .SCRIPT:        configure-voc.ps1
    .DESCRIPTION:   Configure new VOC server using PowerShell
    .AUTHOR:        Zach.Weir
    .UPDATED:       08.25.23
    .CHANGES:
        - 08.25.23 - added coloring for visualization, logging, error handling
        - 08.28.23 - updated logic for SMB access and folder creation

    PRE-REQ: 
    - Open Powershell (not as admin)
    - Run this command
    - Close window
    New-PSDrive -Name "Z" -PSProvider FileSystem -Root "\\ifiler-app01\mobility" -Persist

    RUN SCRIPT:
    - Open Powershell as admin
    - Run these commands and select Y when prompted
    Set-ExecutionPolicy Bypass
    CD Z:
    .\server-migration\configure-voc.ps1

    !!! THIS SCRIPT MUST BE RUN AS AN ADMINISTRATOR !!!
#> 

Function Write-Log {
    Param(
        [switch] $log,
        [switch] $err,
        [String] $message
        )

    if ($log) {
        $logfile = "Z:\server-migration\vocconfig-log.txt"
        $log_entry = (Get-Date).toString("MM.dd.yy HH:mm:ss")
        $log_entry += " - ${message}"
    }
    if ($error) {
        $logfile = "Z:\server-migration\vocconfig-errs.txt"
        $log_entry += $message
    }

    $log_entry | Add-Content -Path $logfile
}

$userIDs = "DHC\Z0018YF", "DHC\Z028710", "DHC\Z0036PM", "DHC\Z042685", "DHC\Z042303", "DHC\CSKEM0", "DHC\Z00C65C", "DHC\Z008L2N", "DHC\Z028710" 
$folderPaths = "C:\Mobility", "C:\Temp"
$siteNumber = Read-Host "Enter site number (####): "

# START SCRIPT

Write-Host "##########  D${siteNumber} - STARTING VOC SERVER CONFIGURATION  ##########" -BackgroundColor Yellow -ForegroundColor Black
Write-Log -err -message "D${siteNumber}`n"
Write-Log -err -message "----------`n"
Write-Log -log -message "----- D${siteNumber} - STARTING VOC SERVER CONFIGURATION -----"

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
    $psScript = (
        "New-PSDrive -Name 'Z' -PSProvider 'FileSystem' -Root '\\ifiler-app01\mobility' -Persist -Scope 'Global'" +
        "New-PSDrive -Name 'Z' -PSProvider 'FileSystem' -Root '\\ifiler-app01\mobility' -Persist -Scope 'Global'"
    )
    $psScript | Set-Content -Path "C:\Mobility\map-drive.ps1" 
    Write-Host "Created map-drive.ps1 in C:\Mobility folder"
    Write-Log -log -message "DIRECTORY-NEWFILE - Created map-drive.ps1 in C:\Mobility folder"
}
Catch {
    Write-Host "Unable to create map-drive.ps1"
    Write-Log -err -message "DIRECTORY-NEWFILE - Unable to create map-drive.ps1"
}

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

# create firewall rules - inbound
Try {
    New-NetFirewallRule -DisplayName "Vocollect - Inbound - 9090, 9091, 9443" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 9090, 9091, 9443 -errAction Stop | Out-Null
    New-NetFirewallRule -DisplayName "Vocollect - Terminal - 21050" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 21050 -errAction Stop | Out-Null
    New-NetFirewallRule -DisplayName "Vocollect - UDP - 20155" -Direction Inbound -Action Allow -Protocol UDP -LocalPort 21055 -errAction Stop | Out-Null
    Write-Host "Created inbound firewall rules"
    Write-Log -log -message "Created inbound firewall rules"
}
Catch {
    Write-Host "ERROR - Unable to create inbound firewall rules" -ForegroundColor Red
    Write-Log -err -message "FIREWALL-IN - Unable to create inbound firewall rules"
    $errorCount++
}

Start-Sleep -Seconds 1

# create firewall rules - outbound
Try {
    New-NetFirewallRule -DisplayName "Vocollect - Outbound - 9091" -Direction Outbound -Action Allow -Protocol TCP -LocalPort 9091 -errAction Stop | Out-Null
    New-NetFirewallRule -DisplayName "Vocollect - Terminal - 21050" -Direction Outbound -Action Allow -Protocol TCP -LocalPort 21050 -errAction Stop | Out-Null
    New-NetFirewallRule -DisplayName "Vocollect - UDP - 21055" -Direction Outbound -Action Allow -Protocol UDP -LocalPort 21055 -errAction Stop | Out-Null
    Write-Host "Created outbound firewall rules"
    Write-Log -log -message "Created outbound firewall rules"
}
Catch {
    Write-Host "ERROR - Unable to create outbound firewall rules" -ForegroundColor Red
    Write-Log -err -message "FIREWALL-OUT - Unable to create outbound firewall rules"
    $errorCount++
}

# FINISH SCRIPT

Write-Host "##############  FINISHED VOC SERVER CONFIGURATION  ##############" -BackgroundColor Green -ForegroundColor Black
Write-Log -log -message "----- COMPLETED D${siteNumber} VOC SERVER CONFIGURATION -----`n"

if ($errorCount -gt 0) {
    Write-Log -err -message "----------`n"
    Write-Log -err -message "Errors: ${errorCount}`n"
} else {
    Write-Log -err -message "No errors reported`n"
}
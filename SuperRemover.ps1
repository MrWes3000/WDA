function Show-Menu {
    Clear-Host
    Write-Host "===================================="
    Write-Host "        Main Menu"
    Write-Host "===================================="
    Write-Host "1: Disable Sleep Settings"
    Write-Host "2: Remove Office 365 Bloatware"
    Write-Host "3: Remove Dell Bloatware 1"
    Write-Host "4: Remove Dell Bloatware 2"
    Write-Host "5: Deploy Adobe Reader"
    Write-Host "6: Deploy Microsoft Remote Desktop Client"
    Write-Host "7: Deploy Zoom"
    Write-Host "8: Deploy Chrome"
    Write-Host "9: Deploy 7-Zip"
    Write-Host "100: Exit"
    Write-Host "===================================="
}

#Functions

#Install Microsoft Remote Desktop Client
function Install-RDC {

$msiUrl = "https://go.microsoft.com/fwlink/?linkid=2139369"
$deploymentFolder = "C:\Deployment"
$installerPath = "C:\Deployment\RemoteDesktopClient.msi"
$exePath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Remote Desktop.lnk"
$shortcutPath = "C:\Users\Public\Desktop\Remote Desktop.lnk"

# Create folder if it doesn't exist
    if (-Not (Test-Path $deploymentFolder)) {
        New-Item -Path $deploymentFolder -ItemType Directory -Force
    }

    Write-Output "Downloading Remote Desktop Client..."
    try {
        Invoke-WebRequest -Uri $msiUrl -OutFile $installerPath -UseBasicParsing
    } catch {
        Write-Error "Failed to download the installer. $_"
        return
    }

    if (-Not (Test-Path $installerPath)) {
        Write-Error "Download failed or file not found."
        return
    }

# Create directory if it doesn't exist
if (-not (Test-Path "C:\Deployment")) {
    New-Item -Path "C:\Deployment" -ItemType Directory | Out-Null
}

# Download the installer if not already downloaded
if (-not (Test-Path $installerPath)) {
    Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath
}

# Install for all users
Write-Output "Installing Remote Desktop Client..."
start-process "msiexec.exe" -ArgumentList "/i C:\Deployment\RemoteDesktopClient.msi /qn ALLUSERS=1" -Wait

if (Test-Path $exePath) {
        Write-Output "Creating shortcut..."
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $exePath
        $shortcut.IconLocation = $exePath
        $shortcut.Save()
        Write-Output "Shortcut created successfully."
    } else {
        Write-Warning "Installation might have failed. Executable not found at $exePath"
    }

}
#Remove all version of Office and OneNote Bloatware
function Remove-Office {
    #Write-Host "Removing Office 365 Bloatware..."
    # Example command to remove Office bloatware
    # You can replace this with the actual removal script or commands.
    # Example: Uninstall-OfficeApp (if you have a function or cmdlet for this).
    #Start-Sleep -Seconds 3
    #Write-Host "Office 365 Bloatware Removed!"
    $AppList = "Microsoft OneNote","Microsoft 365"
    $LanguageList = "en-us","es-es","fr-fr","pt-br"

    ForEach ($App in $AppList) {

	    ForEach ($Language in $LanguageList) {
		    $AppName = "$App - $Language"
		    $OneNote = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty | Where-Object {$_.DisplayName -eq $AppName } | Select-Object -Property DisplayName,UninstallString
	    $uninst = $OneNote.uninstallstring + " displaylevel=false"

	    start-process -WindowStyle Hidden cmd.exe -ArgumentList '/c', $uninst -Wait -PassThru
	    }
}
}
#Remove All Dell Bloatware Version 1
function Remove-Dellv1 {
    Write-Host "`nStarting Dell Bloatware Removal..."

    $dellApps = @(
        "Dell SupportAssist",
        "Dell SupportAssist OS Recovery Plugin for Dell Update",
        "Dell SupportAssist Remediation",
        "Dell Optimizer",
        "Dell Core Services",
        "Dell Trusted Device",
        "Dell Watchdog Timer",
        "Dell Support",
        "Dell Digital Delivery"
    )

    foreach ($app in $dellApps) {
        $installed = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*$app*" }

        if ($installed) {
            foreach ($item in $installed) {
                Write-Host "Uninstalling: $($item.Name)..."
                $item.Uninstall() | Out-Null
                Write-Host "$($item.Name) removed."
            }
        } else {
            Write-Host "$app not found."
        }
    }

    Write-Host "`nDell Bloatware Removal Completed!"
}
#Disable Sleep Settings
function Disable-SleepSettings {
    Write-Host "`nDisabling all sleep and hibernate settings..."

    # Disable sleep on AC and DC
    powercfg /change standby-timeout-ac 0
    powercfg /change standby-timeout-dc 0

    # Disable display off on AC and DC
    powercfg /change monitor-timeout-ac 0
    powercfg /change monitor-timeout-dc 0

    # Optional: Disable hibernate
    powercfg /hibernate off

    Write-Host "All sleep, display timeout, and hibernation settings have been disabled."
}
#Install Adobe Acrobat Reader
function Install-Adobe {
    
    $process = Start-Process -FilePath "C:\Deployment\AcroRdrDC2500120467_en_US.exe" -ArgumentList "/sAll /rs /rps /norestart /quiet" -PassThru

    $spinner = @(
@'
       _..._     
     .+++++++.    
    +++++++++++
    +++++++++++ 
    `+++++++++'  
      `'+++'' 
'@,
@'
       _..._     
     .++++. `.    
    +++++++.  + 
    ++++++++  +  
    `++++++' .'  
      `'++'-' 
'@,
@'
       _..._     
     .++++  `.    
    ++++++    +   
    ++++++    +  
    `+++++   .'  
      `'++.-' 
'@,
@'
       _..._     
     .++'   `.    
    +++       +    
    +++       +  
    `++.     .'  
      `'+..-'    
'@,
@'
       _..._     
     .'     `.    
    +         +    
    +         +  
    `.       .'  
      `-...-'  
'@,
@'
       _..._     
     .'   `++.    
    +       +++    
    +       +++  
    `.     .++'  
      `-..+'' 
'@,
@'
       _..._     
     .'  ++++.    
    +    ++++++    
    +    ++++++  
    `.   +++++'  
      `-.++''   
'@,
@'
       _..._     
     .' .++++.    
    +  ++++++++    
    +  ++++++++  
    `. '++++++'  
      `-.++'' 
'@,
@'
       _..._     
     .+++++++.    
    +++++++++++    
    +++++++++++  
    `+++++++++'  
      `'+++'' 
'@
)
$i = 0
    
    # Install for all users silently
    Write-Host "Installing Adobe Reader...`n" -NoNewline
    while (-not $process.HasExited) {
    $char = $spinner[$i % $spinner.Length]
    Clear-Host
    Write-Host -NoNewline "Installing Adobe Reader...`n`b$char"
    Start-Sleep -Milliseconds 100
    $i++
    }
    
    $porcess
    
}
#Remove All Dell Bloatware Version 2
function Remove-Dellv2 {
    Write-Host "`nStarting Dell Bloatware Removal..."

    $dellApps = @(
        "Dell SupportAssist",
        "Dell SupportAssist OS Recovery Plugin for Dell Update",
        "Dell SupportAssist Remediation",
        "Dell Optimizer",
        "Dell Core Services",
        "Dell Trusted Device",
        "Dell Watchdog Timer",
        "Dell Update",
        "Dell Digital Delivery"
    )

    # First try uninstall via Win32_Product (MSI)
    foreach ($app in $dellApps) {
        $msiApp = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*$app*" }
        if ($msiApp) {
            foreach ($item in $msiApp) {
                Write-Host "Attempting to uninstall MSI: $($item.Name)..."
                try {
                    $item.Uninstall() | Out-Null
                    Write-Host "$($item.Name) removed."
                } catch {
                    Write-Warning "Failed to remove $($item.Name) via MSI: $_"
                }
            }
        }
    }

    # Then try via Get-Package for other installer types
    foreach ($app in $dellApps) {
        $pkgApp = Get-Package -Name *$app* -ErrorAction SilentlyContinue
        if ($pkgApp) {
            foreach ($item in $pkgApp) {
                Write-Host "Attempting to uninstall package: $($item.Name)..."
                try {
                    $uninstallString = $item.Meta.Attributes['UninstallString']
                    if ($uninstallString) {
                        Start-Process -FilePath "cmd.exe" -ArgumentList "/c $uninstallString /quiet /norestart" -Wait
                        Write-Host "$($item.Name) uninstalled via UninstallString."
                    } else {
                        Write-Warning "Uninstall string not found for $($item.Name)"
                    }
                } catch {
                    Write-Warning "Failed to uninstall $($item.Name) via Get-Package: $_"
                }
            }
        }
    }

    # Lastly, try using the registry uninstall keys (backup strategy)
    $registryPaths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    foreach ($app in $dellApps) {
        foreach ($path in $registryPaths) {
            $uninstallKeys = Get-ItemProperty $path -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*$app*" }
            foreach ($key in $uninstallKeys) {
                if ($key.UninstallString) {
                    Write-Host "Uninstalling from registry: $($key.DisplayName)..."
                    try {
                        Start-Process -FilePath "cmd.exe" -ArgumentList "/c $($key.UninstallString) /quiet /norestart" -Wait
                        Write-Host "$($key.DisplayName) uninstalled successfully."
                    } catch {
                        Write-Warning "Error uninstalling $($key.DisplayName): $_"
                    }
                }
            }
        }
    }

    Write-Host "`nDell Bloatware Removal Completed!"
}
function Install-Zoom {
    $zoomUrl = "https://zoom.us/client/latest/ZoomInstallerFull.msi"
    $zoomInstaller = "$env:TEMP\ZoomInstallerFull.msi"
    Invoke-WebRequest -Uri $zoomUrl -OutFile $zoomInstaller
    Start-Process "msiexec.exe" -ArgumentList "/i `"$zoomInstaller`" /quiet /norestart" -Wait
    Remove-Item $zoomInstaller -Force
    Write-Host "Zoom installed successfully."
}
function Install-Chrome {
    $chromeUrl = "https://dl.google.com/chrome/install/latest/chrome_installer.exe"
    $chromeInstaller = "$env:TEMP\chrome_installer.exe"
    Invoke-WebRequest -Uri $chromeUrl -OutFile $chromeInstaller
    Start-Process -FilePath $chromeInstaller -ArgumentList "/silent /install" -Wait
    Remove-Item $chromeInstaller -Force
    Write-Host "Google Chrome installed successfully."
}
function Install-7Zip {
    $sevenZipUrl = "https://www.7-zip.org/a/7z2301-x64.exe"
    $sevenZipInstaller = "$env:TEMP\7zip_installer.exe"
    Invoke-WebRequest -Uri $sevenZipUrl -OutFile $sevenZipInstaller
    Start-Process -FilePath $sevenZipInstaller -ArgumentList "/S" -Wait
    Remove-Item $sevenZipInstaller -Force
    Write-Host "7-Zip installed successfully."
}


# Main script loop
do {
    Show-Menu
    $choice = Read-Host "Please enter an option"

    switch ($choice) {
        1{Disable-SleepSettings}
        2{Remove-Office}
        3{Remove-Dellv2}
        4{Remove-Dellv1}
        5{Install-Adobe}
        6{Install-RDC}
        7{Install-Zoom}
        8{Install-Chrome}
        9{Install-7zip}
        100{
            Write-Host "Exiting... Goodbye!"
            break
        }
        default{
            Write-Host "Invalid choice. Please select a valid option."
        }
    }
    if ($choice -ne 100) {
        Write-Host "Press any key to return to the main menu..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }

} while ($choice -ne 100)

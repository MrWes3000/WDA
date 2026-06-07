Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# =========================
# FORM
# =========================
$form = New-Object System.Windows.Forms.Form
$form.Text = "Deployment Runbook"
$form.Size = New-Object System.Drawing.Size(500,600)
$form.StartPosition = "CenterScreen"

# =========================
# TITLE
# =========================
$title = New-Object System.Windows.Forms.Label
$title.Text = "Main Deployment Menu"
$title.AutoSize = $true
$title.Font = New-Object System.Drawing.Font("Arial",14,[System.Drawing.FontStyle]::Bold)
$title.Location = New-Object System.Drawing.Point(140,20)
$form.Controls.Add($title)

# =========================
# BUTTON HELPER
# =========================
function New-Button($text, $y, $action) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $text
    $btn.Size = New-Object System.Drawing.Size(420,35)
    $btn.Location = New-Object System.Drawing.Point(30,$y)
    $btn.Add_Click($action)
    $form.Controls.Add($btn)
}

# =========================
# BUTTONS (mapped to your functions)
# =========================

New-Button "Disable Sleep Settings" 70  { Disable-SleepSettings }
New-Button "Remove Office Bloatware" 110 { Remove-Office }
New-Button "Remove Dell Bloatware V2" 150 { Remove-Dellv2 }
New-Button "Remove Dell Bloatware V1" 190 { Remove-Dellv1 }

New-Button "Install Adobe Reader (Testing)" 230 { Install-Adobe }
New-Button "Install Remote Desktop (Testing)" 270 { Install-RDC }
New-Button "Install Zoom (Testing)" 310 { Install-Zoom }
New-Button "Install Chrome (Testing)" 350 { Install-Chrome }
New-Button "Install 7-Zip (Testing)" 390 { Install-7Zip }

# Exit button
$exitBtn = New-Object System.Windows.Forms.Button
$exitBtn.Text = "Exit"
$exitBtn.Size = New-Object System.Drawing.Size(420,35)
$exitBtn.Location = New-Object System.Drawing.Point(30,440)
$exitBtn.BackColor = "LightCoral"
$exitBtn.Add_Click({ $form.Close() })
$form.Controls.Add($exitBtn)

# =========================
# SHOW FORM
# =========================
[void]$form.ShowDialog()

# =========================
# Function
# =========================
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

#Remove Office
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

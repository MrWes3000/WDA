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

New-Button "Install Adobe Reader" 230 { Install-Adobe }
New-Button "Install Remote Desktop" 270 { Install-RDC }
New-Button "Install Zoom" 310 { Install-Zoom }
New-Button "Install Chrome" 350 { Install-Chrome }
New-Button "Install 7-Zip" 390 { Install-7Zip }

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

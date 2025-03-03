# DLSS Indicator Toggle Script
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Path to the registry key
$regPath = "HKLM:\SOFTWARE\NVIDIA Corporation\Global\NGXCore"
$valueName = "ShowDlssIndicator"
$valueData = 1024 # Decimal value

function Show-Notification {
    param (
        [string]$Message
    )

    # Create a form for the notification
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "DLSS Indicator Toggle"
    $form.Size = New-Object System.Drawing.Size(300, 100)
    $form.StartPosition = "CenterScreen"
    $form.TopMost = $true
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $form.ControlBox = $false

    # Create a label for the message
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10, 20)
    $label.Size = New-Object System.Drawing.Size(280, 40)
    $label.Text = $Message
    $label.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $label.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)

    # Add the label to the form
    $form.Controls.Add($label)

    # Create a timer to close the form after 2 seconds
    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 2000
    $timer.Add_Tick({
        $form.Close()
        $timer.Stop()
    })

    # Start the timer
    $timer.Start()

    # Show the form
    $form.ShowDialog() | Out-Null
}

# Check for admin rights
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    # Not running as admin, try to restart with elevated privileges
    try {
        $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`""
        Start-Process powershell -Verb RunAs -ArgumentList $arguments
    }
    catch {
        Show-Notification "This script requires administrator privileges to run."
    }
    exit
}

# Toggle DLSS indicator
try {
    # Check if the registry key exists
    if (Test-Path $regPath) {
        # Check if the value exists
        if (Get-ItemProperty -Path $regPath -Name $valueName -ErrorAction SilentlyContinue) {
            # Value exists, remove it
            Remove-ItemProperty -Path $regPath -Name $valueName
            Show-Notification "DLSS Indicator has been DISABLED"
        }
        else {
            # Value doesn't exist, add it
            New-ItemProperty -Path $regPath -Name $valueName -PropertyType DWORD -Value $valueData -Force | Out-Null
            Show-Notification "DLSS Indicator has been ENABLED"
        }
    }
    else {
        # Registry key doesn't exist, create it and add the value
        New-Item -Path $regPath -Force | Out-Null
        New-ItemProperty -Path $regPath -Name $valueName -PropertyType DWORD -Value $valueData -Force | Out-Null
        Show-Notification "DLSS Indicator has been ENABLED"
    }
}
catch {
    Show-Notification "Error: $($_.Exception.Message)"
}

# DLSS Indicator Toggle Script
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Constants
$regPath = "HKLM:\SOFTWARE\NVIDIA Corporation\Global\NGXCore"
$valueName = "ShowDlssIndicator"
$valueData = 1024 # Decimal value

function Show-WindowsToast {
    param ([string]$Message)
    
    try {
        # Load Windows.UI.Notifications assembly more explicitly
        $null = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
        $null = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]
        
        # Use "Windows PowerShell" as the AppId for a cleaner header
        $AppId = "Windows PowerShell"

        # Create the toast content
        $template = @"
<toast>
    <visual>
        <binding template="ToastText01">
            <text id="1">$Message</text>
        </binding>
    </visual>
</toast>
"@

        # Create and show the toast notification
        $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
        $xml.LoadXml($template)
        $toast = New-Object Windows.UI.Notifications.ToastNotification($xml)
        [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($AppId).Show($toast)
        return $true
    }
    catch {
        return $false
    }
}

function Show-FormNotification {
    param ([string]$Message)
    
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "DLSS Indicator Toggle"
    $form.Size = New-Object System.Drawing.Size(300, 120)
    $form.StartPosition = "CenterScreen"
    $form.TopMost = $true
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $form.ControlBox = $false

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10, 20)
    $label.Size = New-Object System.Drawing.Size(280, 40)
    $label.Text = $Message
    $label.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $label.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)

    $closeButton = New-Object System.Windows.Forms.Button
    $closeButton.Location = New-Object System.Drawing.Point(110, 70)
    $closeButton.Size = New-Object System.Drawing.Size(80, 25)
    $closeButton.Text = "Close"
    $closeButton.Add_Click({ $form.Close() })

    $form.Controls.AddRange(@($label, $closeButton))

    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 2000
    $timer.Add_Tick({
        $form.Close()
        $timer.Stop()
    })
    $timer.Start()

    $form.ShowDialog() | Out-Null
}

function Show-Notification {
    param ([string]$Message)
    
    # Try Windows Toast notification first, fallback to form if not available
    if (-not (Show-WindowsToast $Message)) {
        Show-FormNotification $Message
    }
}

# Check for admin rights
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    try {
        Start-Process -FilePath $MyInvocation.MyCommand.Path -Verb RunAs
    }
    catch {
        Show-Notification "This script requires administrator privileges to run."
    }
    exit
}

# Toggle DLSS indicator
try {
    if (Test-Path $regPath) {
        if (Get-ItemProperty -Path $regPath -Name $valueName -ErrorAction SilentlyContinue) {
            Remove-ItemProperty -Path $regPath -Name $valueName
            Show-Notification "DLSS Indicator has been DISABLED"
        }
        else {
            New-ItemProperty -Path $regPath -Name $valueName -PropertyType DWORD -Value $valueData -Force | Out-Null
            Show-Notification "DLSS Indicator has been ENABLED"
        }
    }
    else {
        New-Item -Path $regPath -Force | Out-Null
        New-ItemProperty -Path $regPath -Name $valueName -PropertyType DWORD -Value $valueData -Force | Out-Null
        Show-Notification "DLSS Indicator has been ENABLED"
    }
}
catch {
    Show-Notification "Error: $($_.Exception.Message)"
}

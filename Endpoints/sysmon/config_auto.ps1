# 0. Automatyczne podniesienie uprawnień do Administratora (UAC)
$CzyAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $CzyAdmin) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Download Sysmon
$DownloadUrlSysmon = "https://download.sysinternals.com/files/Sysmon.zip"
$DownloadPathSysmon = "$env:TEMP\Sysmon.zip"
$ExtractPathSysmon = "C:\Tools\Sysmon"

# Download Configuration
$DownloadUrlConfig = "https://raw.githubusercontent.com/putrequest/AzureLab/refs/heads/main/Endpoints/sysmon/sysmonconfig-custom.xml"
$ConfigPath = "C:\Tools\Sysmon\Config"
$DownloadPathConfig = "$ConfigPath\configuration.xml"

# Create destination folders
New-Item -ItemType Directory -Path $ExtractPathSysmon -Force | Out-Null
New-Item -ItemType Directory -Path $ConfigPath -Force | Out-Null

# Download Sysmon
Write-Host "Downloading Sysmon..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $DownloadUrlSysmon -OutFile $DownloadPathSysmon -ErrorAction Stop


$ProgressPreference = 'SilentlyContinue'

Invoke-WebRequest -Uri $DownloadUrlSysmon -OutFile $DownloadPathSysmon -ErrorAction Stop

# Extract Sysmon
Write-Host "Extracting Sysmon..." -ForegroundColor Cyan
Expand-Archive -Path $DownloadPathSysmon -DestinationPath $ExtractPathSysmon -Force

Remove-Item -Path $DownloadPathSysmon -Force -ErrorAction SilentlyContinue


Write-Host "Sysmon downloaded successfully!" -ForegroundColor Green
Write-Host "Location: $ExtractPathSysmon"

# Download XML configuration
Write-Host "Downloading configuration file..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $DownloadUrlConfig -OutFile $DownloadPathConfig -ErrorAction Stop

Write-Host "Configuration downloaded successfully!" -ForegroundColor Green
Write-Host "Location: $DownloadPathConfig"

# Install or update Sysmon with custom configuration
Write-Host "Installing Sysmon..." -ForegroundColor Cyan
$SysmonExe = "$ExtractPathSysmon\Sysmon64.exe"


if (Test-Path $SysmonExe) {
    if (Get-Service -Name "Sysmon64" -ErrorAction SilentlyContinue) {
        # Jeśli usługa już istnieje, zaktualizuj samą konfigurację
        Start-Process -FilePath $SysmonExe -ArgumentList "-c `"$DownloadPathConfig`"" -Wait -NoNewWindow
    }
    else {
        # Świeża instalacja (automatycznie tworzy usługę startującą przed logowaniem jako SYSTEM)
        Start-Process -FilePath $SysmonExe -ArgumentList "-accepteula -i `"$DownloadPathConfig`"" -Wait -NoNewWindow
    }
}
else {
    Write-Host "Sysmon executable not found!" -ForegroundColor Red
    exit 1
}

Write-Host "Sysmon installation completed!" -ForegroundColor Green

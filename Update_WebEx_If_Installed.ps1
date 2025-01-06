# Cisco WebEx program updater
# by Jonathan Thomas
# Version 1.0
# 10-18-2024
# Method to get file version from WebEx app if it is on the endpoint
function Get-WebExVersionFromFile {
    param ($path)
    if (Test-Path $path) {
        (Get-Item $path).VersionInfo.ProductVersion
    } else {
        "Not found"
    }
}

# method to run the installer silently
function Install-WebExSilently {
    $installerPath = "C:\IT\WebexInstaller.msi"
    
    if (Test-Path $installerPath) {
        Start-Process msiexec.exe -ArgumentList "/i `"$installerPath`" /quiet /norestart" -Wait
        Write-Output "WebEx installation initiated silently."
    } else {
        Write-Output "Installer not found at $installerPath."
    }
}

# Method to download the latest Webex installer
function Download-WebExInstaller {
    # Use the provided direct link to the 64-bit Webex installer
    $url = "https://binaries.webex.com/WebexOfclDesktop-Win-64-Gold/Webex.msi?_gl=1*kcbu68*_gcl_au*OTY3ODYzODI0LjE3MjkyNjQwODU."
    $installerPath = "C:\IT\WebexInstaller.msi"  # Specify the save location
    
    try {
        $headers = @{"User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"}
        Invoke-WebRequest -Uri $url -OutFile $installerPath -Headers $headers
        "Downloaded Webex installer to $installerPath"
    } catch {
        "Failed to download Webex installer: $_"
    }
}

# Check if WebEx is installed locally on the endpoint via Get-Package
# this was needed because webex is weird and doesn't have the expected entry in the registry hive
$webexPackage = Get-Package -Name "*webex*" -ErrorAction SilentlyContinue

# Check standard installation directories for WebEx folders
$webexFolder1 = Get-ChildItem "C:\Program Files" -Directory -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -like "*webex*" }
$webexFolder2 = Get-ChildItem "C:\Program Files (x86)" -Directory -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -like "*webex*" }

# Attempt to find the webex executable
$webexExecutablePath1 = "C:\Program Files\Cisco Webex\Webex\Webex.exe"
$webexExecutablePath2 = "C:\Program Files (x86)\Cisco Webex\Webex\Webex.exe"

# Get version from executable, if it exists
# this part doesn't really matter but it's ok. Might use later, but for now it's just cosmetic.
$webexVersion = Get-WebExVersionFromFile $webexExecutablePath1
if ($webexVersion -eq "Not found") {
    $webexVersion = Get-WebExVersionFromFile $webexExecutablePath2
}

# Determine the result and only download if installed
# Regardless of what version is installed, this will just silently install the latest version of the app
if ($webexPackage) {
    Write-Output "WebEx is installed on this endpoint (found via package list)."
    Write-Output "Version: $($webexPackage.Version)"
    Download-WebExInstaller
    Install-WebExSilently
} elseif ($webexFolder1 -or $webexFolder2) {
    Write-Output "WebEx is installed on this endpoint (found in program files)."
    if ($webexVersion -ne "Not found") {
        Write-Output "Version: $webexVersion"
    } else {
        Write-Output "Version: Unable to determine"
    }
    Download-WebExInstaller
} else {
    Write-Output "WebEx is not installed on this endpoint."
}




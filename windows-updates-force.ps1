usoclient.exe StartScan
Start-Sleep -Seconds 600  # Wait for 10 minutes (600 seconds)

usoclient.exe StartDownload
Start-Sleep -Seconds 10800  # Wait for 3 hours (10800 seconds)

usoclient.exe StartInstall
Start-Sleep -Seconds 600  # Wait for 10 minutes (600 seconds)

usoclient.exe ResumeUpdate

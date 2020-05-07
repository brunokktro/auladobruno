# <powershell>
Set-ExecutionPolicy Unrestricted -Force
New-Item -ItemType directory -Path 'C:\temp'

# Install IIS and Web Management Tools.
Import-Module ServerManager
install-windowsfeature web-server, web-webserver -IncludeAllSubFeature
install-windowsfeature web-mgmt-tools

# Download the files for our web application.
Set-Location -Path C:\inetpub\wwwroot

$shell_app = new-object -com shell.application
(New-Object System.Net.WebClient).DownloadFile("https://us-west-2-tcprod.s3.amazonaws.com/courses/ILT-TF-100-SYSOPS/v3.3.10/lab-3-scaling-windows/scripts/stressapp.zip", (Get-Location).Path + "\stressapp.zip")

$zipfile = $shell_app.Namespace((Get-Location).Path + "\stressapp.zip")
$destination = $shell_app.Namespace((Get-Location).Path)
$destination.copyHere($zipfile.items())

# Create the web app in IIS8.
New-WebApplication -Name stressapp -PhysicalPath c:\inetpub\wwwroot -Site "Default Web Site" -force

# Download consume.exe for emulating load generation.
(new-object net.webclient).DownloadFile('https://us-west-2-tcprod.s3.amazonaws.com/courses/ILT-TF-100-SYSOPS/v3.3.10/lab-3-scaling-windows/scripts/consume.exe', 'c:\temp\consume.exe')
# </powershell>

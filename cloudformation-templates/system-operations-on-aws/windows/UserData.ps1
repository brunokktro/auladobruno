<powershell>
Set-ExecutionPolicy Unrestricted -Force
New-Item -ItemType directory -Path 'C:\temp', 'C:\temp\aws'
$webclient = New-Object System.Net.WebClient
$webclient.DownloadFile('https://s3.amazonaws.com/aws-cli/AWSCLI64.msi', 'C:\temp\aws\AWSCLI64.msi')
Start-Process 'C:\temp\aws\AWSCLI64.msi' -ArgumentList /qn -Wait
</powershell>
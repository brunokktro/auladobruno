#Instalação AWS Tools for PowerShell
https://sdk-for-net.amazonwebservices.com/latest/AWSToolsAndSDKForNet.msi

#Instalação AWS CLI v1
https://s3.amazonaws.com/aws-cli/AWSCLISetup.exe

#Setup Inicial para AWS CLI (irá solicitar Access Key, Secret Key, Região e Output)
aws configure

#Setup Inicial para PowerShell (lembre-se de alterar as informações entre <> e removê-los) 
Import-Module AWSPowerShell
Set-AWSCredentials -AccessKey <AKIA***********> -SecretKey <********************************> -StoreAs <profile-name>
Set-DefaultAWSRegion -Region sa-east-1
Initialize-AWSDefaultConfiguration -ProfileName <profile-name> -Region sa-east-1

# Usar se quiser recomeçar todo o processo para o PowerShell
Clear-AWSCredentials 

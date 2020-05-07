############################################

#Comando simples para retornar as regiões e AZs disponíveis na CLI:
aws ec2 describe-regions
aws ec2 describe-availability-zones --region sa-east-1

#>>>>Em PowerShell:
Get-EC2Region
Get-EC2AvailabilityZone | ft -AutoSize

############################################

#Comando simples para retornar todas as instâncias EC2:
aws ec2 describe-instances

#Comando completo para retornar atributos específicos das instâncias EC2:
aws ec2 describe-instances --filter "Name=instance-type,Values=t2.micro,t2.small" --query "Reservations[*].Instances[*].InstanceId" --output table --region sa-east-1

aws ec2 describe-instances --query 'Reservations[*].Instances[*].[LaunchTime,InstanceId,PrivateIpAddress,Tags[?Key==`Name`] | [0].Value][] | sort_by(@, &[3])'

#>>>>Em PowerShell:
Get-EC2Instance | ft Instances

Get-EC2InstanceAttribute -InstanceId i-0e587b74ce414afff -Attribute instanceType

(Get-EC2InstanceAttribute -InstanceId i-0e587b74ce414afff -Attribute groupSet).Groups

############################################

#Tab separated output:
aws iam list-groups-for-user --user-name lab-glacier  --output text --query "Groups[].GroupName"

#Each value on its own line:
aws iam list-groups-for-user --user-name lab-glacier  --output text --query "Groups[].[GroupName]"

############################################

#Comando para criar novas instâncias EC2:
aws ec2 run-instances --image-id ami-04bfee437f38a691e --count 1 --instance-type t3.nano --key-name "Amazon Linux 2" --security-group-ids sg-01baab8c8e2041a06 --subnet-id subnet-91fcccdb

#>>>>Em PowerShell
New-EC2Instance -ImageId ami-04bfee437f38a691e -MinCount 1 -MaxCount 1 -KeyName "Amazon Linux 2" -SecurityGroupId sg-01baab8c8e2041a06 -InstanceType t3.nano -SubnetId subnet-91fcccdb


############################################

#Comando para listar AMIs específicas disponíveis na AWS
aws ec2 describe-images --owners self amazon --filters "Name=platform,Values=windows" "Name=Name,Values=WindowsServer*" "Name=root-device-type,Values=ebs"

#>>>>Em PowerShell
Get-EC2Image -Owners amazon -Filters @{Name = "name"; Values = "Windows_Server-2012-R2*English*"} | Select Name, ImageID | ft -auto


############################################

#Comando simples para listar Repositórios do Amazon Glacier
aws glacier list-vaults --account-id 774223929296 

#>>>>Em PowerShell
Get-GLCVaultList
####### REGION #############################
# Comando simples para retornar as regiões e AZs disponíveis na CLI:
aws ec2 describe-regions
aws ec2 describe-availability-zones --region sa-east-1

# Em PowerShell:
Get-EC2Region
Get-EC2AvailabilityZone | ft -AutoSize
############################################


####### EC2 ###############################
# Comando simples para retornar todas as instâncias EC2:
aws ec2 describe-instances

# Comando completo para retornar atributos específicos das instâncias EC2:
aws ec2 describe-instances --filter "Name=instance-type,Values=t2.micro,t2.small" --query "Reservations[*].Instances[*].InstanceId" --output table --region sa-east-1
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[LaunchTime,InstanceId,PrivateIpAddress,Tags[?Key==`Name`] | [0].Value][] | sort_by(@, &[3])'

# Em PowerShell:
Get-EC2Instance | ft Instances
Get-EC2InstanceAttribute -InstanceId i-0e587b74ce414afff -Attribute instanceType
(Get-EC2InstanceAttribute -InstanceId i-0e587b74ce414afff -Attribute groupSet).Groups
############################################

############################################
# Comando para criar novas instâncias EC2:
aws ec2 run-instances --image-id ami-04bfee437f38a691e --count 1 --instance-type t3.nano --key-name "Amazon Linux 2" --security-group-ids sg-01baab8c8e2041a06 --subnet-id subnet-91fcccdb

# Em PowerShell
New-EC2Instance -ImageId ami-04bfee437f38a691e -MinCount 1 -MaxCount 1 -KeyName "Amazon Linux 2" -SecurityGroupId sg-01baab8c8e2041a06 -InstanceType t3.nano -SubnetId subnet-91fcccdb
############################################


####### IAM ################################
# Tab separated output:
aws iam list-groups-for-user --user-name lab-glacier  --output text --query "Groups[].GroupName"

# Each value on its own line:
aws iam list-groups-for-user --user-name lab-glacier  --output text --query "Groups[].[GroupName]"
############################################

##### SPOT ##################################
# Comando para retornar o histórico de preço de Spot Instances a partir de uma data específica, em uma AZ determinada
aws ec2 describe-spot-price-history --instance-types "c4.large" --product-descriptions "Linux/UNIX" --availability-zone us-east-1a --start-time "2020-01-01T00:00:00.000" --output table

# Em PowerShell
Get-EC2SpotPriceHistory -InstanceType c4.large -AvailabilityZone sa-east-1a | Select-Object -First 10 | ft
############################################


#### POLLY ################################
# Comando para ativar o serviço Amazon Translate para um texto simples
aws translate translate-text --text "Hello, welcome to TechDay with Bruno Lopes" --source-language-code=en --target-language=pt --output json

# Comando para ativar o serviço Amazon Polly para converter texto em áudio
aws polly synthesize-speech --output-format mp3 --voice-id Joanna --text 'Hello, welcome to AWS session with Bruno Lopes' C:\Temp\hello-demo.mp3
############################################


#### AMI ##################################
# Comando para listar AMIs específicas disponíveis na AWS
aws ec2 describe-images --owners self amazon --filters "Name=platform,Values=windows" "Name=Name,Values=WindowsServer*" "Name=root-device-type,Values=ebs"

# Em PowerShell
Get-EC2Image -Owners amazon -Filters @{Name = "name"; Values = "Windows_Server-2012-R2*English*"} | Select Name, ImageID | ft -auto
############################################


#### GLACIER ###############################
# Comando simples para listar Repositórios do Amazon Glacier
aws glacier list-vaults --account-id 774223929296 

# Em PowerShell
Get-GLCVaultList
############################################

### STS ####################################
# Comando para retornar o token da sessão usado em uma IAM Role
aws sts assume-role --role-arn arn:aws:iam::518028969861:role/lopez-aws-switch-role --role-session-name "RoleSessionDemo" --profile lopez-aws > assume-role-output.txt
############################################

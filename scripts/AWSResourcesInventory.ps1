<#
.Synopsis
    Lists some of the commonly used resources via AWSPowerShell 

.DESCRIPTION
    The Script will ask for the CSV path where credentials for the user is stored. The credentials file would look like this:
    
    User name,Password,Access key ID,Secret access key,Console login link
    myAPIUser,[*0s5F5Yds9N,AKIdJaJ3BTK242HGBJ,kW9)H5VtESj&CqXO#bKdmj#Q9y877Vs0Ij0sZRuejBw,https://myaws-babysteps.signin.aws.amazon.com/console
    
    It will display below resources, assuming user provided has access, for the region selected (where applicable):
    1.  EC2 Instances 
    2.  EC2 Security Groups
    3.  EC2 KeyPairs
    4.  EC2 Volumes
    5.  EFS FileSystem
    6.  ELB2:  Elastic Load Balancer (Application / HTTP/s)
    7.  ELB :  Elastic Load Balancer Classic
    8.  IAM Roles
    9.  S3 Buckets and S3 Objects
    10. DynamoDB Tables
    11. Lambda Functions
    12. API Gateways
    13. RDS Instances
    14. CloudFront Distribution List
    15. CloudFront Origin Access Identities

.EXAMPLE
   .\AWSResources.ps1 E:\myAPIUser_credentials.csv

.INPUTS
    CSV file that is saved while creating User for API access

.OUTPUTS
    List of resources mentined above on the host.
    Function Get-MyCostDetails

.NOTES
    Get-MyCostDetails will ustilize Cost Explorer APIs which are chargeable
    That's why we are not using right away. Please use if needed. 
    Source: https://blogs.msdn.microsoft.com/neo/2018/04/21/aws-obtain-blendedcost-billing-data/

.FUNCTIONALITY
    List of common resources AWS
   
    Script by         : Ketan Thakkar (KetanBhut@live.com)
    Script version    : v1.0
    Release date      : 11-May-2018
#>
param(
            [System.IO.FileInfo] 
            [Parameter(Mandatory=$true)]
            $csvPath
            
    )


Import-Module AWSPowerShell
$awsRegions = Get-AWSRegion


function Load-AWSProfile
{

    $userCreds = Import-Csv $csvPath

    
    Write-Host "------- Select Region: "
    for($i = 0; $i -lt $awsRegions.Count; $i++)
    {
        if($i -lt 10){$regNumber = $i.ToString() + " ---> "}else{$regNumber = $i.ToString() +" --> "}
        Write-Host "$regNumber $($awsRegions[$i].Region) `t<> $($awsRegions[$i].Name)"
        #if($i % 2) {Write-Host}
    }
    Write-Host

    while(($currRegion = Read-Host "Please enter the region number only :" ) -notmatch "^\d+$"){}


    if ([int]$currRegion -lt $awsRegions.Count)
    {
        Initialize-AWSDefaults -Region $awsRegions[$currRegion] -AccessKey $userCreds.'Access key ID' -SecretKey $userCreds.'Secret access key'
        return $awsRegions[$currRegion]

    }
    else
    {
        Write-Warning "Wrong Region!! Please select a number from the list"
        return $false
        exit
    }
}

#################
# Call the Profile
# Load the context of authorized user
#################

$region = Load-AWSProfile 
if($region -eq $false) {exit}





#Print EC2 instance details
Write-Host
'*'*44
Write-Host "Printing EC2 Instances : $($region.Region) <> $($region.Name)" -BackgroundColor White -ForegroundColor DarkBlue
'*'*44
$ec2Instances = Get-EC2Instance -Region $region.Region
foreach ($instance in $ec2Instances.Instances)
{
    '*'*44
    write-host "Instance Type    : $($instance.InstanceType)"
    write-host "PublicDnsName    : $($instance.PublicDnsName)"
    write-host "PublicIpAddress  : $($instance.PublicIpAddress)"
    write-host "KeyName          : $($instance.KeyName)"
    write-host "InstanceId       : $($instance.InstanceId)"
    write-host "VpcId            : $($instance.VpcId)"
    $nameValue = ($instance.tags|?{$_.key -ceq "Name"}).Value
    write-host "Name             : $nameValue"
    $state = $instance.state.name.value
    if($state -eq "terminated")
    {
        Write-Host "State            : " -NoNewline
        Write-Host "$state" -ForegroundColor red
    }
    else
    {
        Write-Host "State            : " -NoNewline
        Write-Host "$state" -ForegroundColor green
    }


}





#Print EC2 Security Groups
Write-Host
'*'*44
Write-Host "Printing details of EC2 Security Groups : $($region.Region) <> $($region.Name)" -BackgroundColor White -ForegroundColor DarkBlue
'*'*44
$securityGroups =Get-EC2SecurityGroup -Region $region.Region
$Groups = New-Object System.Collections.ArrayList
foreach ($group in $securityGroups)
{
    $groups.Add('-'*44)|out-null
    $Groups.Add("Region`t`t:`t" + $region.Region)|out-null
    $Groups.Add("Description`t:`t" +$group.GroupDescription)|out-null
    $Groups.Add("GroupId`t`t:`t" + $group.GroupId)|out-null
    $Groups.Add("GroupName`t:`t" + $group.GroupName)    |out-null
}

$Groups





#Print EC2 Keypair details for the account
Write-Host
'*'*44
Write-Host "Printing EC2 KeyPairs : $($region.Region) <> $($region.Name)" -BackgroundColor White -ForegroundColor DarkBlue
'*'*44
Get-EC2KeyPair -Region $region.Region |fl

function Get-MyCostDetails
{
    #Print cost details for the Account for current month 
    '*'*44
    Write-Host "Printing cost details for the Account for current month" -BackgroundColor White -ForegroundColor DarkBlue
    '*'*44


    $currDate = Get-Date
    $firstDay = Get-Date $currDate -Day 1 -Hour 0 -Minute 0 -Second 0
    $lastDay = Get-Date $firstDay.AddMonths(1).AddSeconds(-1)
    $firstDayFormat = Get-Date $firstDay -Format 'yyyy-MM-dd'
    $lastDayFormat = Get-Date $lastDay -Format 'yyyy-MM-dd'



    $interval = New-Object Amazon.CostExplorer.Model.DateInterval
    $interval.Start = $firstDayFormat
    $interval.End = $lastDayFormat

    $costUsage = Get-CECostAndUsage -TimePeriod $interval -Granularity MONTHLY -Metric BlendedCost

    $costUsage.ResultsByTime.Total["BlendedCost"]

    # Valid Dimension values are: AZ, INSTANCE_TYPE, LINKED_ACCOUNT,OPERATION, PURCHASE_TYPE, 
    # SERVICE, USAGE_TYPE, USAGE_TYPE_GROUP, PLATFORM, TENANCY, RECORD_TYPE,LEGAL_ENTITY_NAME, 
    # DEPLOYMENT_OPTION, DATABASE_ENGINE, CACHE_ENGINE, INSTANCE_TYPE_FAMILY, REGION

    #$serviceDimention = Get-CEDimensionValue -TimePeriod $interval -Dimension SERVICE
}





#Print EC2 Volumes details for the account
Write-Host
'*'*44
Write-Host "Printing EC2 Volumes : $($region.Region) <> $($region.Name)" -BackgroundColor White -ForegroundColor DarkBlue
'*'*44

Get-EC2Volume -Region $region.Region |ft volumeid, size, volumetype, snapshotid, state, Attachments -auto





#Print EFS details for the account
Write-Host
'*'*44
Write-Host "Printing EFSFileSystem details : $($region.Region) <> $($region.Name)" -BackgroundColor White -ForegroundColor DarkBlue
'*'*44

# Limiting regions for EFS query to only regions with this service
# as per below document as on 24APR2018
# https://docs.aws.amazon.com/general/latest/gr/rande.html

$efsRegions = ('us-east-2','us-east-1','us-west-1','us-west-2','eu-central-1','eu-west-1','ap-southeast-2')

if($region.Region -in $efsRegions)
{

    $myEFSs = Get-EFSFileSystem -Region $region.Region 

    foreach ($efs in $myEFSs)
    {
        '*'*44
        Write-Host "Printing details of FileSystemId: $($efs.FileSystemId)"
        '*'*44
    
        $props = @{
            CreationTime    = $efs.CreationTime
            Encrypted       = $efs.Encrypted
            FileSystemId    = $efs.FileSystemId
            LifeCycleState  = $efs.LifeCycleState
            Name            = $efs.Name
            PerformanceMode = $efs.PerformanceMode
            SizeInMBs       = [math]::Round($efs.SizeInBytes.Value/1mb, 3)
        }
    
        Write-Host($props | Out-String)
    
        '*'*44
        Write-Host "Printing EFSMountTargets of FileSystemId: $($efs.FileSystemId)"
        '*'*44
        Get-EFSMountTarget -FileSystemId $efs.FileSystemId -Region $region.Region 
    }
}






#Print ELB2 Load Balancer details for the account
Write-Host
'*'*44
Write-Host "Printing ELB2 (Application / HTTP/s)  Load Balancer details : $($region.Region) <> $($region.Name)" -BackgroundColor White -ForegroundColor DarkBlue
'*'*44

$elb2LBs = Get-ELB2LoadBalancer -Region $region.Region 
foreach($lb in $elb2LBs)
{
    '*'*44
    Write-Host "Printing details of LoadBalancerName: $($lb.LoadBalancerName)"
    '*'*44
    
    $props = @{
    CreationTime      = $lb.CreatedTime
    DNSName           = $lb.DNSName
    LoadBalancerArn   = $lb.LoadBalancerArn
    LoadBalancerName  = $lb.LoadBalancerName
    State             = $lb.state.code.value
    AvailabilityZones = $lb.AvailabilityZones
    
    }
    
    Write-Host($props | Out-String)
    
    #$tgGroup = Get-ELB2TargetGroup $lb.LoadBalancerArn
    #$tgHealth = Get-ELB2TargetHealth -TargetGroupArn $tgGroup.TargetGroupArn

    '*'*44
    Write-Host "Printing Targets in Target Group $($tgGroup.TargetGroupName)"
    '*'*44
    #$tgGroup
}





#Print ELB Classic Load Balancer details for the account
Write-Host
'*'*44
Write-Host "Printing ELB classic Load Balancer details : $($region.Region) <> $($region.Name)" -BackgroundColor White -ForegroundColor DarkBlue
'*'*44

$elbLBs = Get-ELBLoadBalancer -Region $region.Region 
foreach($lb in $elbLBs)
{
    '*'*44
    Write-Host "Printing details of LoadBalancerName: $($lb.LoadBalancerName)"
    '*'*44
    
    $props = @{
    CreationTime      = $lb.CreatedTime
    DNSName           = $lb.DNSName
    LoadBalancerArn   = $lb.LoadBalancerArn
    LoadBalancerName  = $lb.LoadBalancerName
    AvailabilityZones = $lb.AvailabilityZones
    
    }
    
    Write-Host($props | Out-String)
}





#Printing IAM Role details for the account
Write-Host
'*'*44
Write-Host "Printing IAM Role details for the account" -BackgroundColor White -ForegroundColor DarkBlue
'*'*44

$roleList = Get-IAMRoleList
$roleList | ft





#Printing S3 Bucket details for the account

function DisplayInBytes($num) 
{
    ##########
    # Using code from https://stackoverflow.com/users/11421/mladen-mihajlovic
    # As per the stakeoverflow query https://stackoverflow.com/questions/24616806/powershell-display-files-size-as-kb-mb-or-gb/24617034#24617034: 
    # in order to display size in mb, gb etc.
    ##########

    $suffix = "B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"
    $index = 0
    while ($num -gt 1kb) 
    {
        $num = $num / 1kb
        $index++
    } 

    "{0:N1} {1}" -f $num, $suffix[$index]
}

Write-Host
'*'*44
Write-Host "Printing S3 Bucket details for the account" -BackgroundColor White -ForegroundColor DarkBlue
'*'*44

$myBuckets = Get-S3Bucket -Region $region

foreach ($bucket in $myBuckets)
{
    '-'*21
    write-host "Displaying objects of $($bucket.BucketName): " 
    '-'*21
    try
    {
        Get-S3Object -BucketName $bucket.BucketName -Region $region| ft Key, StorageClass, @{L='Size';E={DisplayInBytes $_.size}}  -AutoSize
    }
    catch
    {
        Write-Host "Below error is returned. It is generally returned due to bucket is not in $($region.Region)"
        Write-Host $_.Exception.Message
        
    }
    
}
# Remove-S3Bucket $myBuckets[0].BucketName -DeleteBucketContent # empties the bucket including contents
# Get-S3Bucket | foreach {Remove-S3Bucket $_.BucketName -DeleteBucketContent} # Removes all buckets with all its contents. 





#Printing DynamoDB Table list
Write-Host
'*'*44
Write-Host "Printing DynamoDB Table list : $($region.Region) <> $($region.Name)" -BackgroundColor White -ForegroundColor DarkBlue
'*'*44

Get-DDBTableList -Region $region.Region





#Printing Lambda functions
Write-Host
'*'*44
Write-Host "Printing Lambda functions : $($region.Region) <> $($region.Name)" -BackgroundColor White -ForegroundColor DarkBlue
'*'*44

Get-LMFunctions | ft





#Printing Api list
Write-Host
'*'*44
Write-Host "Printing API (Gateway) list : $($region.Region) <> $($region.Name)" -BackgroundColor White -ForegroundColor DarkBlue
'*'*44

Get-AGRestApiList -Region $region.Region |ft





#Printing RDS Instances
Write-Host
'*'*44
Write-Host "Printing RDS Instances : $($region.Region) <> $($region.Name)" -BackgroundColor White -ForegroundColor DarkBlue
'*'*44

Get-RDSDBInstance -Region $region.Region | ft





#Printing CloudFront Distribution List
Write-Host
'*'*44
Write-Host "Printing CloudFront Distribution List : $($region.Region) <> $($region.Name)" -BackgroundColor White -ForegroundColor DarkBlue
'*'*44

Get-CFDistributionList|ft id, domainname, status, enabled





#Printing CloudFront Origin Access Identities
Write-Host
'*'*44
Write-Host "#Printing CloudFront Origin Access Identities : $($region.Region) <> $($region.Name)" -BackgroundColor White -ForegroundColor DarkBlue
'*'*44

Get-CFCloudFrontOriginAccessIdentities | ft


# SIG # Begin signature block
# MIIFhQYJKoZIhvcNAQcCoIIFdjCCBXICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUmSQ6OOskWUBYeTDMlhackbfa
# gSCgggMYMIIDFDCCAfygAwIBAgIQYu6swUI/nIdGAnIJXdOVyTANBgkqhkiG9w0B
# AQsFADAiMSAwHgYDVQQDDBdQb3dlclNoZWxsIENvZGUgU2lnbmluZzAeFw0xODAz
# MTQxMDMxMzBaFw0xOTAzMTQxMDUxMzBaMCIxIDAeBgNVBAMMF1Bvd2VyU2hlbGwg
# Q29kZSBTaWduaW5nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAkR/J
# O5/EyeqlMLltRyErXM9vKo8umdGa0mlHfzHgRFotcqm5ZM748ogUgjkH9qErzG2O
# bAbeNynlWVlIRspsI1tyGDCB4v+r1Gy7uIIG6aGa4pHdXF886mZEWwKEeBARK4QU
# OkHQ8tafOVfnFNkp5bn4jNmQrMQJU07T2lnCHQEy7WWEmz0kO3tv4Vi9bR2ISAqq
# 8Q7ol7+quqM/N0aqxF4/V07FVBVrYU7KPspCKhtrQo/ej1bYfonIdadFztjrtk5B
# 8pg+pCBd0Dju7/ugpQaq/8PtplqfPl496goDOYHXAjfRr/eRsMYplbvWSbffKadW
# fU0W4vO/4NDzVLPMLQIDAQABo0YwRDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAww
# CgYIKwYBBQUHAwMwHQYDVR0OBBYEFHaqP4ikQiVZoPMQoW9DCmzNjV6cMA0GCSqG
# SIb3DQEBCwUAA4IBAQAbtCf20D93BEr36dNbPAhRUCPGCKrv2leDTpzOePQCdgOe
# 3vUyMWkZv0mt6cAh9bnkbckapPnYYiI1OW4x/c+732tCoQ2wRaDKoYxddKwbBbY4
# WY+6sxp7XjAfARia5xqo9flZ7922Qo3XCvi3jJFLtsSuN0MQpH5Cqrl1EuLBCDDn
# s9u+NTqXPyrQVdF2noaVdkkTNBGgDoo3azCd17mxeqCi3D528r6KZ0AdrkwtWtK+
# d/RhhCH7XZeFZh9Ih54iXnm+viOXEll8hXkg+lDVbpZEpIHLZawFvLUfq3ayLb+R
# MTdrbcwjJztZsNIB2r2s6bTrfPPSuf5FXsNMxlUQMYIB1zCCAdMCAQEwNjAiMSAw
# HgYDVQQDDBdQb3dlclNoZWxsIENvZGUgU2lnbmluZwIQYu6swUI/nIdGAnIJXdOV
# yTAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG
# 9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIB
# FTAjBgkqhkiG9w0BCQQxFgQUGuoKW2MSbr+/24y8lWvJx/iyNBgwDQYJKoZIhvcN
# AQEBBQAEggEAf7ztL4cNmwm37Qi2VUOT3L5NQ6A3pK6lg8TcR9BJN83lnP8z39oR
# uKBVOrW1DjFGrBkQ0TJrxYYXRaNmvRI/8iafo/H7AJXboHlXDd7OEjxJ59PWPYUN
# tb1yzf/2wfhSvcN0P+QFc6SDyun1YX/YZDP4eWzJ4noHePtZBSCHYx1b+Nbnyy/X
# Jnqj81wnuWN8a+7TE9syzk2EqPSZ5tEtQzLPI+tkTa/ctonnItUAc+wZS69Vi4pd
# B5nSQiPjRRuRenM0Owm6YTo1FYv0HHEzBNZR4RHRZX5S0y5chmZSNgU6AXjcSC/5
# tlzR6Jxb4zb8JayNGdY0fu4/QCVmVusAsQ==
# SIG # End signature block

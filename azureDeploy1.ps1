$Prompt01 = 'What do you want to name the Management Group?'
$Prompt02 = 'What is the desired display name?'
#$Prompt03 = 'What is the parent Management group name?'
$Prompt04 = 'What is the - Prod Guid?'
$Prompt05 = 'What is the - Dev Guid?'
$Prompt06 = 'What is the MyAccess group name?'


$Response = 'N'
$DeploymentName = $Null
$DeploymentList = @()
$WriteOutList = $Null

Do
{
 $DeploymentName = Read-Host $Prompt01
 $DeploymentList += $DeploymentName

 $DeploymentName = Read-Host $Prompt02
 $DeploymentList += $DeploymentName

 $DeploymentName = Read-Host $Prompt04
 $DeploymentList += $DeploymentName

 $DeploymentName = Read-Host $Prompt05
 $DeploymentList += $DeploymentName

 $DeploymentName = Read-Host $Prompt06
 $DeploymentList += $DeploymentName

 Write-Output $DeploymentList
 $Response = Read-Host 'Are you sure this info is correct? (y/n)'
 }
 Until ($Response -eq 'y')



Foreach ($DeploymentName in $DeploymentList)
 {
$DeploymentName = $DeploymentName.Insert(0,'"')
$DeploymentName += '"'
#Write-Output $DeploymentName
}

#Generates management-group in the deisred directory
az account management-group create --name $DeploymentList[0] --display-name $DeploymentList[1] --parent OfficeEngineeringSandbox;

#Adds - Prod / - Dev to the management-group
az account management-group subscription add --name $DeploymentList[0] --subscription $DeploymentList[2];

az account management-group subscription add --name $DeploymentList[0] --subscription $DeploymentList[3];

#Queries azure for the unique MyAccessID/s and stores as a variable (tsv to remove commas and quotes if multiple Ids)
$objId = az ad group list --display-name $DeploymentList[4] --query "[?securityEnabled].objectId" --output tsv;

#Grants MyAccess group Reader for - Prod and Contributor for - Dev
$objId | ForEach-object {az role assignment create --role Reader --assignee-object $_ --scope /subscriptions/$DeploymentList[2]};

$objId | ForEach-object {az role assignment create --role Contributor --assignee-object $_ --scope /subscriptions/$DeploymentList[3]};

#Scopes to -Dev
Select-AzureRmSubscription -SubscriptionId $DeploymentList[3];

#Queries for registered resource providers and stores them as a variable
$providers = Get-AzureRmResourceProvider | ? { $_.RegistrationState -eq "Registered" };

#Scopes to - Prod
Select-AzureRmSubscription -SubscriptionId $DeploymentList[2];

#Queries for and registers resource providers to match - Dev's
$providers | % { Register-AzureRmResourceProvider -ProviderNamespace $_.ProviderNamespace }
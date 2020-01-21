Select-AzureRmSubscription -SubscriptionId <Dev Sub ID>
$providers = Get-AzureRmResourceProvider | ? { $_.RegistrationState -eq "Registered" }
Select-AzureRmSubscription -SubscriptionId <Prod Sub ID>
$providers | % { Register-AzureRmResourceProvider -ProviderNamespace $_.ProviderNamespace }

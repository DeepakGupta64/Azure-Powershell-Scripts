Connect-AzAccount

$subscriptions = Import-Csv -Path "C:\subscriptionlist.csv"

foreach ($sub in $subscriptions) {
    $subscriptionId = $sub.SubscriptionId
$roles = Get-AzRoleDefinition -Scope "/subscriptions/$subscriptionId" | Select-Object Name, Id, description
    
    $roles | Export-Csv -Path "c:\roles_$subscriptionId.csv" -NoTypeInformation
    
    Write-Output "Roles for subscription $subscriptionId exported to roles_$subscriptionId.csv"
}
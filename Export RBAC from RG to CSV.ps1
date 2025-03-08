Get-AzResourceGroup| foreach-object { $ResourceGroupName = $_.ResourceGroupName Get-AzRoleAssignment | ` 
    Select-Object DisplayName,RoleAssignmentID,@{Name = "ResourceGroup Name";`
     Expression = { (Get-AzResourceGroup $ResourceGroupName).ResourceGroupName}} ,Scope,RoleDefinitionName,@{name="SubscriptionName";expression = {$Name}},ObjectType |`
     Sort-Object DisplayName }-OutVariable azusers $azusers | Export-CSV UserList.csv -NoTypeInformation -Encoding UTF8
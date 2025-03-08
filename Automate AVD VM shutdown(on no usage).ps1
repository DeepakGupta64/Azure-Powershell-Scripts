$subscriptionId = "your_subscription_id"
$resourceGroupName = "your_resource_group_name"
$vmName = "your_vm_name"

# Authenticate to Azure
Connect-AzAccount

# Get the VM object
$vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName

# Get the current CPU usage and connected user count
$cpuUsage = Get-AzMetric -ResourceId $vm.Id `
    -TimeGrain 00:01:00 `
    -MetricName Percentage CPU `
    -StartTime (Get-Date).AddMinutes(-5) `
    -EndTime (Get-Date) `
    | Select-Object -ExpandProperty Data |
    Select-Object -ExpandProperty Average |
    Measure-Object -Average |
    Select-Object -ExpandProperty Average
$connectedUserCount = Get-AzWvdSessionHost -ResourceGroupName $resourceGroupName `
    -WorkspaceName "your_workspace_name" `
    -HostPoolName "your_host_pool_name" `
    -Name $vmName `
    | Select-Object -ExpandProperty UserSession |
    Measure-Object |
    Select-Object -ExpandProperty Count

# Check if the conditions are met
if ($connectedUserCount -eq 0 -and $cpuUsage -lt 7) {
    # If both conditions are true, deallocate the VM
    Stop-AzVM -ResourceGroupName $resourceGroupName -Name $vmName -Force
}

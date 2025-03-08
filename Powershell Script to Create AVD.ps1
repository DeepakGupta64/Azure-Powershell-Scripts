#PowerShell script that automates the deployment of Azure Virtual Desktop (AVD)
#
# 1 Creates a Host Pool
# 2 Creates a Workspace
# 3 Creates an Application Group
# 4 Assigns Users to the Application Group

# Install the required PowerShell module
# Install-Module -Name Az.DesktopVirtualization -Force

# Connect to Azure
Connect-AzAccount

# Define parameters
$resourceGroup = "<ResourceGroupName>"
$location = "<AzureRegion>"
$hostPoolName = "<HostPoolName>"
$workspaceName = "<WorkspaceName>"
$appGroupName = "<ApplicationGroupName>"
$userPrincipalName = "<UserPrincipalName>"

# Create a Host Pool (Pooled)
$hostPoolParams = @{
    Name                 = $hostPoolName
    ResourceGroupName    = $resourceGroup
    HostPoolType         = "Pooled"
    LoadBalancerType     = "BreadthFirst"
    PreferredAppGroupType = "Desktop"
    MaxSessionLimit      = 10
    Location             = $location
}

New-AzWvdHostPool @hostPoolParams

# Create a Workspace
$workspaceParams = @{
    Name              = $workspaceName
    ResourceGroupName = $resourceGroup
    Location          = $location
}

New-AzWvdWorkspace @workspaceParams

# Get Host Pool Resource ID
$hostPoolArmPath = (Get-AzWvdHostPool -Name $hostPoolName -ResourceGroupName $resourceGroup).Id

# Create an Application Group
$appGroupParams = @{
    Name                  = $appGroupName
    ResourceGroupName     = $resourceGroup
    ApplicationGroupType  = "Desktop"
    HostPoolArmPath       = $hostPoolArmPath
    Location              = $location
}

New-AzWvdApplicationGroup @appGroupParams

# Get Application Group Resource ID
$appGroupPath = (Get-AzWvdApplicationGroup -Name $appGroupName -ResourceGroupName $resourceGroup).Id

# Add Application Group to Workspace
$workspaceUpdateParams = @{
    Name                    = $workspaceName
    ResourceGroupName       = $resourceGroup
    ApplicationGroupReference = $appGroupPath
}

Update-AzWvdWorkspace @workspaceUpdateParams

# Assign User to Application Group
$userAssignmentParams = @{
    SignInName          = $userPrincipalName
    ResourceName        = $appGroupName
    ResourceGroupName   = $resourceGroup
    RoleDefinitionName  = "Desktop Virtualization User"
    ResourceType        = "Microsoft.DesktopVirtualization/applicationGroups"
}

New-AzRoleAssignment @userAssignmentParams

Write-Host "Azure Virtual Desktop Deployment Completed!"

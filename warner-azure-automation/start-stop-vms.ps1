Workflow start-stop-vms
{ 
    Param 
    (    
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()] 
        [String] 
        $AzureSubscriptionId = 'your-subscription-id', 

        [Parameter(Mandatory)][ValidateNotNullOrEmpty()] 
        [String] 
        $AzureVMList = 'warner-vm1, warner-vm2, warnervm3', 

        [Parameter]
        [Switch]
        $All,

        [Parameter(Mandatory)][ValidateSet('Start','Stop')] 
        [String] 
        $Action 
    ) 
     
$connectionName = 'AzureRunAsConnection'

try
{
    # Get the connection 'AzureRunAsConnection'
    $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName         

    'Logging in to Azure...'
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    }
    else {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}
 
    if ($AzureVMList -ne 'All') 
    { 
        $AzureVMs = $AzureVMList.Split(',') 
        [System.Collections.ArrayList]$AzureVMsToHandle = $AzureVMs 
    } 
    else 
    { 
        $AzureVMs = (Get-AzureRmVM).Name 
        [System.Collections.ArrayList]$AzureVMsToHandle = $AzureVMs 
    } 
 
    foreach ($AzureVM in $AzureVMsToHandle) 
    { 
        if (!(Get-AzureRmVM | Where-Object {$_.Name -eq $AzureVM})) 
        { 
            throw "AzureVM : [$AzureVM] - Does not exist! - Check your inputs." 
        } 
    } 
 
    if ($Action -eq 'Stop') 
    { 
        Write-Output 'Stopping VMs'; 
        foreach -parallel ($AzureVM in $AzureVMsToHandle) 
        { 
            Get-AzureRmVM | Where-Object {$_.Name -eq $AzureVM} | Stop-AzureRmVM -Force 
        } 
    } 
    else 
    { 
        Write-Output 'Starting VMs'; 
        foreach -parallel ($AzureVM in $AzureVMsToHandle) 
        { 
            Get-AzureRmVM | Where-Object {$_.Name -eq $AzureVM} | Start-AzureRmVM 
        } 
    } 
}
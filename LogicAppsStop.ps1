#importante informar a variavel que foi guardada no automation para a subscription desejada
param (
    [Parameter(Mandatory=$true)]
    [String] $VarSubscription
)
#get na variável
$SubscriptionId = Get-AutomationVariable -Name $VarSubscription

# login via identity
Connect-AzAccount -Identity

# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process

# configurar a subs desejada
Set-AzContext –SubscriptionId $SubscriptionId

# pegar todos logic da subscription que estão ativos.
$logicApps = Get-AzLogicApp | Where-Object { $_.State -eq 'Enabled' }

# loop para executar o disabled
$logicApps | ForEach-Object {
    $logicAppName = $_.Name
    $resourceId = $_.Id
    $resourceGroupName = ($resourceId -split '/')[4]
    
    Write-Host "Desativando o Logic App: $logicAppName"
    Set-AzLogicApp -ResourceGroupName $resourceGroupName -Name $logicAppName -State 'Disabled' -Force
}

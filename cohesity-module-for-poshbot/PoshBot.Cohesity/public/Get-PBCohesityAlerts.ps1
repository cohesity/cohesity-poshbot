<#
.SYNOPSIS
function to call Cohesity API
.DESCRIPTION
Get open alerts
.EXAMPLE
get cohesity max alerts 10
Description
-----------
outputs all open alerts on Cohesity cluster
#>
function Get-PBCohesityAlerts {
    [PoshBot.BotCommand(
        Command = $false,
        TriggerType = 'regex',
        Regex = '(?i)get\scohesity\smax\salerts\s(.*)'
    )]
    [CmdletBinding()]
    param(
        [PoshBot.FromConfig()]
        [Parameter(Mandatory)]
        [hashtable]$Connection,
        [Parameter(ValueFromRemainingArguments = $true)]
        [object[]]$Arguments
    )
    $path = $Connection.Path + "/Cluster-Config.json"
    $py_path = $Connection.Path + "/change_cluster.py"
    $cluster_num = python $py_path
    $cluster_num = [int]$cluster_num
    $JSON = Get-Content -Raw -Path $path | ConvertFrom-Json
    try {
        $server = $JSON."Cluster-ip"[$cluster_num]
    }
    catch {
        New-PoshBotCardResponse -Type Normal -Text ("❗" | Format-List | Out-String)
        New-PoshBotCardResponse -Title "Invalid range of ip address; try 'change cohesity cluster to _'"
        $string_error = $_ | Out-String
        $string_error = $string_error.Split([Environment]::NewLine) | Select-Object -First 1
        New-PoshBotCardResponse -Text $string_error
        break

    }
    try {
        $creds = [pscredential]::new($Connection.Username, ($Connection.Password | ConvertTo-SecureString -AsPlainText -Force))
        $null = Connect-CohesityCluster -Server $server -Credential $creds
    } 
    catch {
        New-PoshBotCardResponse -Type Normal -Text ("❗" | Format-List | Out-String)
        New-PoshBotCardResponse -Title "Cohesity cluster connection error"
        $string_error = $_ | Out-String
        $string_error = $string_error.Split([Environment]::NewLine) | Select-Object -First 1
        New-PoshBotCardResponse -Text $string_error
        break

    }
    $alerts = $Arguments[1]
    $alerts = [int]$alerts
    New-PoshBotCardResponse -Title "Cohesity Alerts"
    try {
        $objects = Get-CohesityAlert -MaxAlerts $alerts -AlertStates kOpen
    } 
    catch {
        New-PoshBotCardResponse -Type Normal -Text ("❗" | Format-List | Out-String)
        New-PoshBotCardResponse -Title "Cohesity 'Get-CohesityAlert' API call error "
        $string_error = $_ | Out-String
        $string_error = $string_error.Split([Environment]::NewLine) | Select-Object -First 1
        New-PoshBotCardResponse -Text $string_error
        break

    }
    $critical = 0
    $warning = 0
    Get-CohesityAlert -MaxAlerts $alerts -AlertStates kOpen | Select-Object Severity | ForEach-Object {
        $key, $value = "$_".Split('=') | ForEach-Object { "$_".Trim() }
        if ($value -eq "KCritical}") { $critical = $critical + 1 }
        if ($value -eq "KWarning}") { $warning = $warning + 1 } }

    foreach ($i in $objects) {
        $temp = $i.latestTimestampUsecs
        $format_time = Convert-CohesityUsecsToDateTime -Usecs $temp
        $description = $i.alertDocument.alertDescription
        $i | Add-Member -MemberType ScriptProperty -Name "Description" -Value { $description }
        $format_time = Convert-CohesityUsecsToDateTime -Usecs $temp
        $i | Add-Member -MemberType ScriptProperty -Name "LatestTime" -Value { $format_time }
        $obj = $i | Select-Object -Property Description, Id, AlertCategory, Severity, LatestTime, AlertDocument
        New-PoshBotCardResponse -Text ($obj | Format-List | Out-String)
    }
    if ($critical -gt 0) {
        New-PoshBotCardResponse -Type Normal -Text ("❌" | Format-List | Out-String)
    }
    if ($warning -gt 0) {
        New-PoshBotCardResponse -Type Normal -Text ("❗" | Format-List | Out-String)
    }
    if ($critical -eq 0) {
        if ($warning -eq 0) {
            New-PoshBotCardResponse -Type Normal -Text ("✅" | Format-List | Out-String)

        }

    }
 
}

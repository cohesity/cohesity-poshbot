<#
.SYNOPSIS
function to call Cohesity API
.DESCRIPTION
get latest alerts in the past day
.EXAMPLE
get cohesity latest alerts       
Description
-----------
outputs latest alerts  
#>

function Get-PBCohesityLatestAlert {
    [PoshBot.BotCommand(
        Command = $false,
        TriggerType = 'regex',
        Regex = '(?i)get\scohesity\slatest\salerts'
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
        $path = $Connection.Path
    }
    catch {
        New-PoshBotCardResponse -Type Normal -Text ("❗" | Format-List | Out-String)
        New-PoshBotCardResponse -Title "Cohesity cluster connection error"
        $string_error = $_ | Out-String
        $string_error = $string_error.Split([Environment]::NewLine) | Select-Object -First 1
        New-PoshBotCardResponse -Text $string_error
        break

    }
    try {
        $current_time = Get-CohesityClusterConfiguration | Select-Object -ExpandProperty CurrentTimeMsecs
    }
    catch {
        New-PoshBotCardResponse -Type Normal -Text ("❗" | Format-List | Out-String)
        New-PoshBotCardResponse -Title "Cohesity powershell command error: Get-CohesityClusterConfiguration"
        $string_error = $_ | Out-String
        $string_error = $string_error.Split([Environment]::NewLine) | Select-Object -First 1
        New-PoshBotCardResponse -Text $string_error
        break

    }
    $current_time = $current_time * 1000
    $past_day = $current_time - 86400000000
    New-PoshBotCardResponse -Title "Latest Alerts"
    try {
        $objects = Get-CohesityAlert -MaxAlerts 50
    }
    catch {
        New-PoshBotCardResponse -Type Normal -Text ("❗" | Format-List | Out-String)
        New-PoshBotCardResponse -Title "Cohesity powershell command error: Get-CohesityProtectionJobRun"
        $string_error = $_ | Out-String
        $string_error = $string_error.Split([Environment]::NewLine) | Select-Object -First 1
        New-PoshBotCardResponse -Text $string_error
        break

    }
    foreach ($i in $objects) {
        $temp =  $i.latestTimestampUsecs
        if ($i.latestTimestampUsecs -gt $past_day) {
            $format_time = Convert-CohesityUsecsToDateTime -Usecs $temp
            $description =  $i.alertDocument.alertDescription
            $i | Add-Member -MemberType ScriptProperty -Name "Description" -Value { $description } 
            $format_time = Convert-CohesityUsecsToDateTime -Usecs $temp
            $i | Add-Member -MemberType ScriptProperty -Name "LatestTime" -Value { $format_time }
           $obj = $i | Select-Object -Property Description, Id, AlertCategory, Severity, LatestTime, AlertDocument
        New-PoshBotCardResponse -Text ($obj | Format-List | Out-String)
        }
    }

}



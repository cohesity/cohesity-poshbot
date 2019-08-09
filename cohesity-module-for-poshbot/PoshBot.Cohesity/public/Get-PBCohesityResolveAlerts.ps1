<#
.SYNOPSIS
function to call Cohesity API
.DESCRIPTION
resolve an alert
.EXAMPLE
resolve cohesity alert id 123 with message: resolve
Description
-----------
resolves an alert
#>
function Get-PBCohesityResolveAlerts {
    [PoshBot.BotCommand(
        Command = $false,
        TriggerType = 'regex',
        Regex = '(?i)resolve\scohesity\salert\sid\s(.*)\swith\smessage:\s(.*)'
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
    $id_alert = $Arguments[1]
    $message = $Arguments[2]
    $api_path = $Connection.Path + "/cohesity-api.ps1"
    . powershell $api_path
    apiauth  $Connection.Password  $Connection.Username  $Connection.Domain $server
    $body = "@{ 'alertIdList': [ '" + $id_alert + "' ],'resolutionDetails': {'resolutionDetails': '','resolutionSummary': '" + $message + "'  }}"
    $body -replace "^@", ""
    $body = $body -replace "=", ":"
    $body = $body -replace ";", ","
    $body = $body -replace "@", ""
    $body = $body | ConvertFrom-Json
    api post alertResolutions $body


}

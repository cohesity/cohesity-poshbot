<#
.SYNOPSIS
function to get all configured Cohesity clusters ip address
.DESCRIPTION
Get all ip addresses
.EXAMPLE
get Cohesity ip
Description
-----------
outputs all configured ip addresses
#>

function Get-PBCohesityClusters {
    [PoshBot.BotCommand(
        Command = $false,
        TriggerType = 'regex',
        Regex = '(?i)get\sCohesity\sip'
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
    $JSON = Get-Content -Raw -Path $path | ConvertFrom-Json
    $count = 0
    $JSON."Cluster-ip" | ForEach-Object {
        $num = $count + 1
        $out = [string]$num + ". " + $JSON."Cluster-ip"[$count]
        New-PoshBotCardResponse -Text $out
        $count = $count + 1
    }

}

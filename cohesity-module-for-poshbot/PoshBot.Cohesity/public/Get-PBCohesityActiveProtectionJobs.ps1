<#
.SYNOPSIS
function to call Cohesity API
.DESCRIPTION
Get active protection jobs
.EXAMPLE
get cohesity active protection jobs
Description
-----------
outputs all active protection jobs on Cohesity cluster
#>

function Get-PBCohesityActiveProtectionJobs {
    [PoshBot.BotCommand(
        Command = $false,
        TriggerType = 'regex',
        Regex = '(?i)get\scohesity\sactive\sprotection\sjobs'
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
    try {
        $objects = Get-CohesityProtectionJob -OnlyActive
    }
    catch {
        New-PoshBotCardResponse -Type Normal -Text ("❗" | Format-List | Out-String)
        New-PoshBotCardResponse -Title "Cohesity 'Get-CohesityProtectionJob' API call error "
        $string_error = $_ | Out-String
        $string_error = $string_error.Split([Environment]::NewLine) | Select-Object -First 1
        New-PoshBotCardResponse -Text $string_error
        break

    }
    $string_objects = $objects | Out-String
    New-PoshBotCardResponse -Text $string_objects

}

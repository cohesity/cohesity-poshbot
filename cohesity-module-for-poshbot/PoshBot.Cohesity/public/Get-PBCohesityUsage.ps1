<#
.SYNOPSIS
function to call Cohesity API
.DESCRIPTION
Create a usage graph
.EXAMPLE
get cohesity usage
Description
-----------
outputs new created graph
#>

function Get-PBCohesityUsage {
    [PoshBot.BotCommand(
        Command = $false,
        TriggerType = 'regex',
        Regex = '(?i)get\scohesity\susage'
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
        $stats = Get-CohesityClusterConfiguration -FetchStats | Select-Object -ExpandProperty Stats
        $usage = $stats | Select-Object -ExpandProperty UsagePerfStats
        $used = $usage | Select-Object -ExpandProperty TotalPhysicalUsageBytes
        $available = $usage | Select-Object -ExpandProperty PhysicalCapacityBytes
        $available = [float]$available - [float]$used
    }
    catch {
        New-PoshBotCardResponse -Type Normal -Text ("❗" | Format-List | Out-String)
        New-PoshBotCardResponse -Title "Cohesity powershell command error: Get-CohesityClusterConfiguration"
        $string_error = $_ | Out-String
        $string_error = $string_error.Split([Environment]::NewLine) | Select-Object -First 1
        New-PoshBotCardResponse -Text $string_error
        break

    }

    $path_py = $path + '/pie_chart.py'
    $path_png = $path + '/pie_chart.png'
    $used = [string]$used
    $available = [string]$available
    New-PoshBotCardResponse -Title "Cohesity Cluster Usage"
    python $path_py $used $available $path
    New-PoshBotFileUpload -Path $path_png
}

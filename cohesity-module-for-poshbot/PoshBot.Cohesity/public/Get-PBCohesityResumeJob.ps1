<#
.SYNOPSIS
function to call Cohesity API
.DESCRIPTION
Resume protection job
.EXAMPLE
resume cohesity protection job named ptortect
Description
-----------
outputs if protection job has been resumed
#>
function Get-PBCohesityResumeJob {
    [PoshBot.BotCommand(
        Command = $false,
        TriggerType = 'regex',
        Regex = '(?i)resume\scohesity\sprotection\sjob\snamed\s(.*)'
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
    $job = $Arguments[1]
    try {
        $objects = Resume-CohesityProtectionJob -Name $job
    }
    catch {
        New-PoshBotCardResponse -Type Normal -Text ("❗" | Format-List | Out-String)
        New-PoshBotCardResponse -Title "Cohesity 'Resume-CohesityProtectionJob' API call error "
        $string_error = $_ | Out-String
        $string_error = $string_error.Split([Environment]::NewLine) | Select-Object -First 1
        New-PoshBotCardResponse -Text $string_error
        break

    }
    $ResponseSplat = @{
        Text   = Format-PBCohesityObject -Object $objects -FunctionName $MyInvocation.MyCommand.Name
        AsCode = $true
    }

    New-PoshBotTextResponse @ResponseSplat
 
}

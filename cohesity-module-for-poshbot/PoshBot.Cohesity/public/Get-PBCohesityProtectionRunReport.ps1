<#
.SYNOPSIS
function to call Cohesity API
.DESCRIPTION
Create a protection run graph
.EXAMPLE
get cohesity protection run report
Description
-----------
outputs new created graph
#>

function Get-PBCohesityProtectionRunReport {
    [PoshBot.BotCommand(
        Command = $false,
        TriggerType = 'regex',
        Regex = '(?i)get\scohesity\sprotection\sruns\sreport'
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
    try {
        $current_hour = Convert-CohesityUsecsToDateTime -Usecs $current_time
    }
    catch {
        New-PoshBotCardResponse -Type Normal -Text ("❗" | Format-List | Out-String)
        New-PoshBotCardResponse -Title "Cohesity powershell command error: Convert-CohesityUsecsToDateTime"
        $string_error = $_ | Out-String
        $string_error = $string_error.Split([Environment]::NewLine) | Select-Object -First 1
        New-PoshBotCardResponse -Text $string_error
        break

    }
    $current_hour = $current_hour.ToString("HH.mm")
    try {
        $current_h = Convert-CohesityUsecsToDateTime -Usecs $current_time
    }
    catch {
        New-PoshBotCardResponse -Type Normal -Text ("❗" | Format-List | Out-String)
        New-PoshBotCardResponse -Title "Cohesity powershell command error: Convert-CohesityUsecsToDateTime"
        $string_error = $_ | Out-String
        $string_error = $string_error.Split([Environment]::NewLine) | Select-Object -First 1
        New-PoshBotCardResponse -Text $string_error
        break

    }
    $current_standard = $current_h.ToString("HHtt")
    $current_hour = [int]$current_hour
    $current_hour = [string]$current_hour
    # protection runs in the past 23 hours
    $past_day = $current_time - 80964000000
    $compare_day = $past_day - 3600

    try {
        $objects = Get-CohesityProtectionJobRun -StartedTime $past_day
    }
    catch {
        New-PoshBotCardResponse -Type Normal -Text ("❗" | Format-List | Out-String)
        New-PoshBotCardResponse -Title "Cohesity powershell command error: Get-CohesityProtectionJobRun"
        $string_error = $_ | Out-String
        $string_error = $string_error.Split([Environment]::NewLine) | Select-Object -First 1
        New-PoshBotCardResponse -Text $string_error
        break

    }
    $status = @()
    $end_time = @()
    foreach ($i in $objects) {
        if ($i.copyRun.runStartTimeUsecs -gt $compare_day) {

            $status += [String]$i.backupRun.status + ','
            try {
                $hours = Convert-CohesityUsecsToDateTime -Usecs $i.copyRun.runStartTimeUsecs
            }
            catch {
                New-PoshBotCardResponse -Type Normal -Text ("❗" | Format-List | Out-String)
                New-PoshBotCardResponse -Title "Cohesity powershell command error: Convert-CohesityUsecsToDateTime"
                $string_error = $_ | Out-String
                $string_error = $string_error.Split([Environment]::NewLine) | Select-Object -First 1
                New-PoshBotCardResponse -Text $string_error
                break

            }
            $hour = $hours.ToString("HH")
            $decimal = $hours.ToString("mm")
            $decimal = [float]$decimal
            $hour = [int]$hour
            if ($decimal -gt 30) {
                $hour = $hour + 1
            }
            $hour = [string]$hour
            $end_time += $hour + ','
        }
    }

    $path_py = $path + '/graph.py'
    $path_png = $path + '/graph.png'
    $status = [String]::Join('', $status)
    $status = $status -replace ".$"
    $end_time = [String]::Join('', $end_time)
    $end_time = $end_time -replace ".$"
    New-PoshBotCardResponse -Title "Cohesity Protection Runs"
    python $path_py $status $end_time $current_standard $path
    New-PoshBotFileUpload -Path $path_png
}

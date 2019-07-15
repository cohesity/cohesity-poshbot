<#
.SYNOPSIS
function to change configured Cohesity cluster using ip address
.DESCRIPTION
Change ip addresses
.EXAMPLE
change Cohesity cluster to 1
Description
-----------
changes configured Cohesity cluster
#>

function Get-PBCohesityChangeCluster {
    [PoshBot.BotCommand(
        Command = $false,
        TriggerType = 'regex',
        Regex = '(?i)change\sCohesity\scluster\sto\s(.*)'
    )]
    [CmdletBinding()]
    param(
        [PoshBot.FromConfig()]
        [Parameter(Mandatory)]
        [hashtable]$Connection,
        [Parameter(ValueFromRemainingArguments = $true)]
        [object[]]$Arguments
    )
    $cluster = $Arguments[1]
    $cluster = [int]$cluster - 1
    $path = $Connection.Path
    $filename = $path + "/change_cluster.py"
    Remove-Item $filename -ErrorAction Ignore
    $cluster_number = [string]$cluster
    $python_txt = "def main(): print(" + $cluster_number + ")" + "
if __name__== '__main__': main()"

    New-Item -path $path -Name "change_cluster.py" -ItemType "file" -Value $python_txt | Out-Null

    $path = $Connection.Path + "/Cluster-Config.json"
    $cluster_number = [int]$cluster
    $JSON = Get-Content -Raw -path $path | ConvertFrom-Json
    try {
        $output = "Cluster changed to " + $JSON."Cluster-ip"[$cluster_number] 
    }
    catch {
        New-PoshBotCardResponse -Type Normal -Text ("❗" | Format-List | Out-String)
        New-PoshBotCardResponse -Title "Invalid range of ip address; try 'get cohesity clusters'"
        $string_error = $_ | Out-String
        $string_error = $string_error.Split([Environment]::NewLine) | Select-Object -First 1
        New-PoshBotCardResponse -Text $string_error
        break

    }
    New-PoshBotCardResponse -Text $output

}


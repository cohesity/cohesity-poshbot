<#
.SYNOPSIS
function to call Cohesity API
.DESCRIPTION
Create a protection run graph
.EXAMPLE
get Cohesity protection run graph
Description
-----------
outputs new created graph
#>

function Get-PBCohesityProtectionRunGraph {
  [PoshBot.BotCommand(
    Command = $false,
    TriggerType = 'regex',
    Regex = '(?i)get\sCohesity\sprotection\sruns\sgraph'
  )]
  [CmdletBinding()]
  param(
    [PoshBot.FromConfig()]
    [Parameter(Mandatory)]
    [hashtable]$Connection,
    [Parameter(ValueFromRemainingArguments = $true)]
    [object[]]$Arguments
  )
  try {
    $creds = [pscredential]::new($Connection.Username,($Connection.Password | ConvertTo-SecureString -AsPlainText -Force))
    $null = Connect-CohesityCluster -Server $Connection.Server -Credential $creds
  }
  catch {
    New-PoshBotCardResponse -Type Normal -Text ("❗" | Format-List | Out-String)
    New-PoshBotCardResponse -Title "Cohesity cluster connection error"
    $string_err = $_ | Out-String
    $string_err = $string_err.Split([Environment]::NewLine) | Select -First 1
    New-PoshBotCardResponse -Text $string_err
    break

  }
  $current_time = Get-CohesityClusterConfiguration | Select-Object -ExpandProperty CurrentTimeMsecs
  $current_time = $current_time * 1000
  $current_hour = Convert-CohesityUsecsToDateTime -Usecs $current_time
  $current_hour = $current_hour.ToString("HH.mm")
  $current_h = Convert-CohesityUsecsToDateTime -Usecs $current_time
  $current_standard = $current_h.ToString("HHtt")
  $current_hour = [int]$current_hour
  $current_hour = [string]$current_hour
  $past_day = $current_time - 86400000000
  $objects = Get-CohesityProtectionJobRun -StartedTime $past_day
  $status = @()
  $end_time = @()
  foreach ($i in $objects) {
    $status += [String]$i.backupRun.status + ','
    $hour = Convert-CohesityUsecsToDateTime -Usecs $i.copyRun.expiryTimeUsecs
    $hour = $hour.ToString("HH.mm")
    $hour = [int]$hour
    $hour = [string]$hour
    $end_time += $hour + ','

  }

 $status = [String]::Join('', $status)
 $status = $status -replace ".$"
 $end_time = [String]::Join('', $end_time)
 $end_time = $end_time -replace ".$"
New-PoshBotCardResponse -Title "Cohesity Protection Runs"
 python /home/cohesity/.local/share/powershell/Modules/cohesity-module-for-poshbot/PoshBot.Cohesity/public/graph.py $status $end_time $current_standard
 New-PoshBotFileUpload -Path /home/cohesity/.local/share/powershell/Modules/cohesity-module-for-poshbot/PoshBot.Cohesity/public/graph.png
}




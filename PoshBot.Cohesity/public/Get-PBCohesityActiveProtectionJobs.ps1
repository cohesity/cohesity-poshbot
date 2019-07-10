<#
.SYNOPSIS
function to call Cohesity API
.DESCRIPTION
Get active protection jobs
.EXAMPLE
get Cohesity active protection jobs
Description
-----------
outputs all active protection jobs on Cohesity cluster
#>

function Get-PBCohesityActiveProtectionJobs {
  [PoshBot.BotCommand(
    Command = $false,
    TriggerType = 'regex',
    Regex = '(?i)get\sCohesity\sactive\sprotection\sjobs'
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
  try {
    $objects = Get-CohesityProtectionJob -OnlyActive
  }
  catch {
    New-PoshBotCardResponse -Type Normal -Text ("❗" | Format-List | Out-String)
    New-PoshBotCardResponse -Title "Cohesity 'Get-CohesityProtectionJob' API call error "
    $string_err = $_ | Out-String
    $string_err = $string_err.Split([Environment]::NewLine) | Select -First 1
    New-PoshBotCardResponse -Text $string_err
    break

  }
  $string_objects = $objects | Out-String
  New-PoshBotCardResponse -Text $string_objects

}

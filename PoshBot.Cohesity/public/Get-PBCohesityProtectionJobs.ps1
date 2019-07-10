<#
.SYNOPSIS
function to call Cohesity API
.DESCRIPTION
Get info on Cohesity protection job
.EXAMPLE
get Cohesity protection job named protect
Description
-----------
outputs stats on job
#>

function Get-PBCohesityProtectionJobs {
  [PoshBot.BotCommand(
    Command = $false,
    TriggerType = 'regex',
    Regex = '(?i)get\sCohesity\sprotection\sjob\s(named|id)\s(.*)'
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
    $typeJob = $Arguments[1]
    $job = $Arguments[2]
    try {
    if ($typeJob -eq "named") {
      $objects = Get-CohesityProtectionJob -Names $job | Out-String
    }
    if ($typeJob -eq "id") {
      $number = [int]$job
      $objects = Get-CohesityProtectionJob -Ids $number | Out-String
    }
  }
  catch {
    New-PoshBotCardResponse -Type Normal -Text ("❗" | Format-List | Out-String)
    New-PoshBotCardResponse -Title "Cohesity 'Get-CohesityProtectionJob' API call error "
    $string_err = $_ | Out-String
    $string_err = $string_err.Split([Environment]::NewLine) | Select -First 1
    New-PoshBotCardResponse -Text $string_err
    break

  }
  New-PoshBotCardResponse -Text $objects
}


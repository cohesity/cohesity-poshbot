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
    Regex = 'get Cohesity protection job\s(named|id)\s(.*)'
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
    $typeJob = $Arguments[1]
    $job = $Arguments[2]

    if ($typeJob -eq "named") {
      $objects = Get-CohesityProtectionJob -Names $job }
    if ($typeJob -eq "id") {
      $number = [int]$job
      $objects = Get-CohesityProtectionJob -Ids $number
    }
    $ResponseSplat = @{
      Text = Format-PBCohesityObject -Object $objects -FunctionName $MyInvocation.MyCommand.Name
      AsCode = $true
    }

    New-PoshBotTextResponse @ResponseSplat
  }
  catch {
    New-PoshBotCardResponse -Type Normal -Text ("❗" | Format-List | Out-String)

    $string_err = $_ | Out-String
    New-PoshBotCardResponse -Text $string_err

  }
}


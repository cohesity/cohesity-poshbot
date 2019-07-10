<#
.SYNOPSIS
function to call Cohesity API
.DESCRIPTION
Get open alerts
.EXAMPLE
get Cohesity alerts -max 10
Description
-----------
outputs all open alerts on Cohesity cluster
#>
function Get-PBCohesityAlerts {
  [PoshBot.BotCommand(
    Command = $false,
    TriggerType = 'regex',
    Regex = '(?i)get\sCohesity\salerts\s-max\s(.*)'
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
    $alerts = $Arguments[1]
    $alerts = [int]$alerts
    try {
    $objects = Get-CohesityAlert -MaxAlerts $alerts -AlertStates kOpen | Select-Object -Property Id, AlertCategory, Severity, LatestTimestampUsecs, AlertDocument
  } 
  catch {
    New-PoshBotCardResponse -Type Normal -Text ("❗" | Format-List | Out-String)
    New-PoshBotCardResponse -Title "Cohesity 'Get-CohesityAlert' API call error "
    $string_err = $_ | Out-String
    $string_err = $string_err.Split([Environment]::NewLine) | Select -First 1
    New-PoshBotCardResponse -Text $string_err
    break

  }
    $critical = 0
    $warning = 0
    Get-CohesityAlert -MaxAlerts $alerts -AlertStates kOpen | Select-Object Severity | ForEach-Object {
      $key,$value = "$_".Split('=') | ForEach-Object { "$_".Trim() }
      if ($value -eq "KCritical}") { $critical = $critical + 1 }
      if ($value -eq "KWarning}") { $warning = $warning + 1 } }

    $ResponseSplat = @{
      Text = Format-PBCohesityObject -Object $objects -FunctionName $MyInvocation.MyCommand.Name
      AsCode = $true
    }
    New-PoshBotTextResponse @ResponseSplat
    if ($critical -gt 0) {
      New-PoshBotCardResponse -Type Normal -Text ("❌" | Format-List | Out-String)
    }
    if ($warning -gt 0) {
      New-PoshBotCardResponse -Type Normal -Text ("❗" | Format-List | Out-String)
    }
    if ($critical -eq 0) {
      if ($warning -eq 0) {
        New-PoshBotCardResponse -Type Normal -Text ("✅" | Format-List | Out-String)

      }

    }
 
}

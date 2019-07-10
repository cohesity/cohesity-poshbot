<#
.SYNOPSIS
function to call Cohesity API
.DESCRIPTION
Get all resolved alerts
.EXAMPLE
get Cohesity resloved alerts -max 10
Description
-----------
outputs resloved alerts from Cohesity cluster
#>
function Get-PBCohesityResolvedAlerts {
  [PoshBot.BotCommand(
    Command = $false,
    TriggerType = 'regex',
    Regex = '(?i)get\sCohesity\sresolved\salerts\s-max\s(.*)'
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
    $objects = Get-CohesityAlertResolution -MaxAlerts $alerts
  }
  catch {
    New-PoshBotCardResponse -Type Normal -Text ("❗" | Format-List | Out-String)
    New-PoshBotCardResponse -Title "Cohesity 'Get-CohesityAlertResolution' API call error "
    $string_err = $_ | Out-String
    $string_err = $string_err.Split([Environment]::NewLine) | Select -First 1
    New-PoshBotCardResponse -Text $string_err
    break

  }
    $ResponseSplat = @{
      Text = Format-PBCohesityObject -Object $objects -FunctionName $MyInvocation.MyCommand.Name
      AsCode = $true
    }

    New-PoshBotTextResponse @ResponseSplat
  
}

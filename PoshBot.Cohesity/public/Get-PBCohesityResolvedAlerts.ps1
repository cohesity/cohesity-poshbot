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
    Regex = 'get Cohesity resolved alerts -max\s(.*)'
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
    $alerts = $Arguments[1]
    $alerts = [int]$alerts
    $objects = Get-CohesityAlertResolution -MaxAlerts $alerts
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

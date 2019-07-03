<#
.SYNOPSIS
function to call Cohesity API
.DESCRIPTION
Get info on Cohesity cluster
.EXAMPLE
get Cohesity cluster
Description
-----------
outputs stats on Cohesity cluster
#>
function Get-PBCohesityCluster {
  [PoshBot.BotCommand(
    Command = $false,
    TriggerType = 'regex',
    Regex = 'get Cohesity cluster'
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
    $objects = Get-CohesityCluster

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

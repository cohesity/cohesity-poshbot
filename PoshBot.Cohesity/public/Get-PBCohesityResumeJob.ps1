<#
.SYNOPSIS
function to call Cohesity API
.DESCRIPTION
Resume protection job
.EXAMPLE
resume Cohesity protection job -Name ptortect
Description
-----------
outputs if protection job has been resumed
#>
function Get-PBCohesityResumeJob {
  [PoshBot.BotCommand(
    Command = $false,
    TriggerType = 'regex',
    Regex = '(?i)resume\sCohesity\sprotection\sjob\s-Name\s(.*)'
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
    $job = $Arguments[1]
    try {
    $objects = Resume-CohesityProtectionJob -Name $job
  }
  catch {
    New-PoshBotCardResponse -Type Normal -Text ("❗" | Format-List | Out-String)
    New-PoshBotCardResponse -Title "Cohesity 'Resume-CohesityProtectionJob' API call error "
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

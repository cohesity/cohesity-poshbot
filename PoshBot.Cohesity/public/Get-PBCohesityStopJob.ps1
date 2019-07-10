<#
.SYNOPSIS
function to call Cohesity API
.DESCRIPTION
Stop portection job
.EXAMPLE
stop Cohesity protection job -Name protect -JobRunId na
Description
-----------
outputs if portection job was stopped
#>
function Get-PBCohesityStopJob {
  [PoshBot.BotCommand(
    Command = $false,
    TriggerType = 'regex',
    Regex = '(?i)stop\sCohesity\sprotection\sjob\s-Name\s(.*)\s-JobRunId\s(.*)'
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
    $run = $Arguments[2]
    try {
    if ($run -eq "na") {
      $objects = Stop-CohesityProtectionJob -Name $job
    }
    else {
      $objects = Stop-CohesityProtectionJob -Name $job -JobRunId [int]$run
    }
  }
  catch {
    New-PoshBotCardResponse -Type Normal -Text ("❗" | Format-List | Out-String)
    New-PoshBotCardResponse -Title "Cohesity 'Stop-CohesityProtectionJob' API call error "
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

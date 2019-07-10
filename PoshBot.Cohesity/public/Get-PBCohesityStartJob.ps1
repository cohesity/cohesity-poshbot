<#
.SYNOPSIS
function to call Cohesity API
.DESCRIPTION
Start protection job
.EXAMPLE
start Cohesity protection job -Name protect -CopyRunTargets na -Runtype na -SourceIds na
Description
-----------
outputs if protection job has started
#>
function Get-PBCohesityStartJob {
  [PoshBot.BotCommand(
    Command = $false,
    TriggerType = 'regex',
    Regex = '(?i)start\sCohesity\sprotection\sjob\s-Name\s(.*)\s-CopyRunTargets\s(.*)\s-RunType\s(.*)\s-SourceIds\s(.*)'
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
    $copyRun = $Arguments[2]
    $runType = $Arguments[3]
    $Source = $Arguments[4]
    try {
    if ($copyRun -eq "na") {
      if ($runType -eq "na") {
        if ($Source -eq "na") {
          $objects = Start-CohesityProtectionJob -Name $job
        }
        else { $objects = Start-CohesityProtectionJob -Name $job -SourceIds $Source.Replace("`"","")
        } }
      else {

        if ($Source -eq "na") {
          $objects = Start-CohesityProtectionJob -Name $job -RunType $runType.Replace("`"","")
        }
        else { $objects = Start-CohesityProtectionJob -Name $job -SourceIds $Source.Replace("`"","") -RunType $runType.Replace("`"","")
        }

      } }

    else {

      if ($runType -eq "na") {
        if ($Source -eq "na") {
          $objects = Start-CohesityProtectionJob -Name $job -CopyRunTargets $copyRun.Replace("`"","")
        }
        else { $objects = Start-CohesityProtectionJob -Name $job -SourceIds $Source.Replace("`"","") -CopyRunTargets $copyRun.Replace("`"","")
        } }
      else {

        if ($Source -eq "na") {
          $objects = Start-CohesityProtectionJob -Name $job -RunType $runType.Replace("`"","") -CopyRunTargets $copyRun.Replace("`"","")
        }
        else { $objects = Start-CohesityProtectionJob -Name $job -SourceIds $Source.Replace("`"","") -RunType $runType.Replace("`"","") -CopyRunTargets $copyRun.Replace("`"","")
        }

      }


    }
  }
  catch {
    New-PoshBotCardResponse -Type Normal -Text ("❗" | Format-List | Out-String)
    New-PoshBotCardResponse -Title "Cohesity 'Start-CohesityProtectionJob' API call error "
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

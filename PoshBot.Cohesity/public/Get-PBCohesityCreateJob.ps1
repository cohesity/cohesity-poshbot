<#
.SYNOPSIS
function to call Cohesity API
.DESCRIPTION
Create new protection job
.EXAMPLE
create Cohesity protection job Name=[iitworks] Policy Name=[Bronze] Storage Domain Name=[DefaultStorageDomain] Environment=[kVMware] Parent Source Id=[1] Source Ids=[47] View Name=[na]
Description
-----------
outputs new created protection job
#>

function Get-PBCohesityCreateJob {
  [PoshBot.BotCommand(
    Command = $false,
    TriggerType = 'regex',
    Regex = 'create\sCohesity\sprotection\sjob\sName=\[(.*)\]\sPolicy\sName=\[(.*)\]\sStorage\sDomain\sName=\[(.*)\]\sEnvironment=\[(.*)\]\sParent\sSource\sId=\[(.*)\]\sSource\sIds=\[(.*)\]\sView\sName=\[(.*)\]'
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

    $Name = $Arguments[1]
    $PolicyName = $Arguments[2]
    $Storage = $Arguments[3]
    $Environment = $Arguments[4]
    $ParentSource = $Arguments[5]
    $Source = $Arguments[6]
    $ViewName = $Arguments[7]
    if ($ParentSource -eq 'na') {
      $objects = New-CohesityProtectionJob -Name $Name -PolicyName $PolicyName -StorageDomainName $Storage -Environment $Environment.Replace("`"","") -ViewName $ViewName | ConvertFrom-Json | Select-Object Name,Environment,Id
    }

    if ($ViewName -eq 'na') {
      $ParentSource = [int]$ParentSource
      $objects = New-CohesityProtectionJob -Name $Name -PolicyName $PolicyName -StorageDomainName $Storage -Environment $Environment.Replace("`"","") -ParentSourceId $ParentSource -SourceIds $Source.Replace("`"","") | ConvertFrom-Json | Select-Object Name,Environment,Id
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


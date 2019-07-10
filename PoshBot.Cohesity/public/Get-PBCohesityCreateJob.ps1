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
    Regex = '(?i)create\sCohesity\sprotection\sjob\sName=\[(.*)\]\sPolicy\sName=\[(.*)\]\sStorage\sDomain\sName=\[(.*)\]\sEnvironment=\[(.*)\]\sVMware\sVM\sname=\[(.*)\]\sView\sName=\[(.*)\]'
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
    $Name = $Arguments[1]
    $PolicyName = $Arguments[2]
    $Storage = $Arguments[3]
    $Environment = $Arguments[4]
    $VM = $Arguments[5]
    $ViewName = $Arguments[6]
    try {
    if ($VM -eq 'na') {
      $objects = New-CohesityProtectionJob -Name $Name -PolicyName $PolicyName -StorageDomainName $Storage -Environment $Environment.Replace("`"","") -ViewName $ViewName | ConvertFrom-Json | Select-Object Name,Environment,Id
    }

    if ($ViewName -eq 'na') {
      try {
        $VM_ids = Get-CohesityVMwareVM -Name $VM 
      }
      catch {
    New-PoshBotCardResponse -Type Normal -Text ("❗" | Format-List | Out-String)
    New-PoshBotCardResponse -Title "Cohesity 'Get-CohesityVMwareVM' API call error"
    $string_err = $_ | Out-String
    $string_err = $string_err.Split([Environment]::NewLine) | Select -First 1
    New-PoshBotCardResponse -Text $string_err
    break

  }
  $source_ids = @()
    $parent_id = $VM_ids.ParentId | Out-String
    $num_parent_id = $parent_id.Split([Environment]::NewLine) | Select -First 1 
    $num_parent_id = $num_parent_id.replace(".","") 
    $source_lst = $VM_ids.Id | Out-String
    $num_source_ids = $source_lst.Split([Environment]::NewLine)
    for ($i=0; $i -lt $num_source_ids.length; $i++) {
    if ($num_source_ids[$i] -ne '') {
      $source_ids += $num_source_ids[$i].replace(".","")
    }
   }
      $objects = New-CohesityProtectionJob -Name $Name -PolicyName $PolicyName -StorageDomainName $Storage -Environment $Environment.Replace("`"","") -ParentSourceId $num_parent_id -SourceIds $source_ids | ConvertFrom-Json | Select-Object Name,Environment,Id
    }
  } 
  catch {
    New-PoshBotCardResponse -Type Normal -Text ("❗" | Format-List | Out-String)
    New-PoshBotCardResponse -Title "Cohesity 'New-CohesityProtectionJob' API call error "
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


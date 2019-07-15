<#
.SYNOPSIS
function to call Cohesity API
.DESCRIPTION
Create new protection job
.EXAMPLE
create Cohesity protection job Name=[iitworks] Policy Name=[Bronze] Storage Domain Name=[DefaultStorageDomain] Environment=[kVMware] VMware VM name=[name] View Name=[na]
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
    $path = $Connection.Path + "/Cluster-Config.json"
    $py_path = $Connection.Path + "/change_cluster.py"
    $cluster_num = python $py_path
    $cluster_num = [int]$cluster_num
    $JSON = Get-Content -Raw -Path $path | ConvertFrom-Json
    try {
        $server = $JSON."Cluster-ip"[$cluster_num]
    }
    catch {
        New-PoshBotCardResponse -Type Normal -Text ("❗" | Format-List | Out-String)
        New-PoshBotCardResponse -Title "Invalid range of ip address; try 'change cohesity cluster to _'"
        $string_error = $_ | Out-String
        $string_error = $string_error.Split([Environment]::NewLine) | Select-Object -First 1
        New-PoshBotCardResponse -Text $string_error
        break

    }
    try {
        $creds = [pscredential]::new($Connection.Username, ($Connection.Password | ConvertTo-SecureString -AsPlainText -Force))
        $null = Connect-CohesityCluster -Server $server -Credential $creds
    } 
    catch {
        New-PoshBotCardResponse -Type Normal -Text ("❗" | Format-List | Out-String)
        New-PoshBotCardResponse -Title "Cohesity cluster connection error"
        $string_error = $_ | Out-String
        $string_error = $string_error.Split([Environment]::NewLine) | Select-Object -First 1
        New-PoshBotCardResponse -Text $string_error
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
            $objects = New-CohesityProtectionJob -Name $Name -PolicyName $PolicyName -StorageDomainName $Storage -Environment $Environment.Replace("`"", "") -ViewName $ViewName | ConvertFrom-Json | Select-Object Name, Environment, Id
        }

        if ($ViewName -eq 'na') {
            try {
                $VM_ids = Get-CohesityVMwareVM -Name $VM 
            }
            catch {
                New-PoshBotCardResponse -Type Normal -Text ("❗" | Format-List | Out-String)
                New-PoshBotCardResponse -Title "Cohesity 'Get-CohesityVMwareVM' API call error"
                $string_error = $_ | Out-String
                $string_error = $string_error.Split([Environment]::NewLine) | Select-Object -First 1
                New-PoshBotCardResponse -Text $string_error
                break

            }
            $source_ids = @()
            $parent_id = $VM_ids.ParentId | Out-String
            $num_parent_id = $parent_id.Split([Environment]::NewLine) | Select-Object -First 1 
            $num_parent_id = $num_parent_id.replace(".", "") 
            $source_lst = $VM_ids.Id | Out-String
            $num_source_ids = $source_lst.Split([Environment]::NewLine)
            for ($i = 0; $i -lt $num_source_ids.length; $i++) {
                if ($num_source_ids[$i] -ne '') {
                    $source_ids += $num_source_ids[$i].replace(".", "")
                }
            }
            $objects = New-CohesityProtectionJob -Name $Name -PolicyName $PolicyName -StorageDomainName $Storage -Environment $Environment.Replace("`"", "") -ParentSourceId $num_parent_id -SourceIds $source_ids | ConvertFrom-Json | Select-Object Name, Environment, Id
        }
    } 
    catch {
        New-PoshBotCardResponse -Type Normal -Text ("❗" | Format-List | Out-String)
        New-PoshBotCardResponse -Title "Cohesity 'New-CohesityProtectionJob' API call error "
        $string_error = $_ | Out-String
        $string_error = $string_error.Split([Environment]::NewLine) | Select-Object -First 1
        New-PoshBotCardResponse -Text $string_error
        break

    }
    $ResponseSplat = @{
        Text   = Format-PBCohesityObject -Object $objects -FunctionName $MyInvocation.MyCommand.Name
        AsCode = $true
    }
    New-PoshBotTextResponse @ResponseSplat
  
}


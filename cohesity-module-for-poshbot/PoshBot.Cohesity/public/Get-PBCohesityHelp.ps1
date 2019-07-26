<#
.SYNOPSIS
Function to output the slack commands
.DESCRIPTION
Output slack commands
.EXAMPLE
cohesity command help
Description
-----------
outputs new created protection job
#>

function Get-PBCohesityHelp {
    [PoshBot.BotCommand(
        Command = $false,
        TriggerType = 'regex',
        Regex = '(?i)get\sCohesity\shelp'
    )]
    [CmdletBinding()]
    param(
        [PoshBot.FromConfig()]
        [Parameter(Mandatory)]
        [hashtable]$Connection,
        [Parameter(ValueFromRemainingArguments = $true)]
        [object[]]$Arguments
    )
    $yourData = @(
        @{ Output = "all active protection jobs"; Command = "get cohesity active protection jobs"}) | % { New-Object object | Add-Member -NotePropertyMembers $_ -PassThru }
    New-PoshBotCardResponse -Text ($yourData | Format-List -Property * | Out-String -Width 120)

    $yourData = @(
        @{ Output = "returns max number of alerts, if ✅ all in non critical, if ❌ alerts in critical, if ❗alerts in warning status";Command = "get cohesity max alerts $"}) | % { New-Object object | Add-Member -NotePropertyMembers $_ -PassThru }
    New-PoshBotCardResponse -Text ($yourData | Format-List -Property * | Out-String -Width 120)
    $yourData = @(
        @{ Output = "get latest alerts in past 24 hours";Command = "get cohesity latest alerts"}) | % { New-Object object | Add-Member -NotePropertyMembers $_ -PassThru }
    New-PoshBotCardResponse -Text ($yourData | Format-List -Property * | Out-String -Width 120)

    $yourData = @(
        @{ Output = "change cluster being monitored indicated by numbers from 1 >";Command = "change cohesity cluster to $"}) | % { New-Object object | Add-Member -NotePropertyMembers $_ -PassThru }
    New-PoshBotCardResponse -Text ($yourData | Format-List -Property * | Out-String -Width 120)

    $yourData = @(
        @{ Output = "list Cohesity clusters available indicated by numbers from 1 >"; Command = "get cohesity ip"}) | % { New-Object object | Add-Member -NotePropertyMembers $_ -PassThru }
    New-PoshBotCardResponse -Text ($yourData | Format-List -Property * | Out-String -Width 120)

    $yourData = @(
        @{ Output = "create protection job if no View Name input na, if no VMware VM name input na"; Command = "create cohesity protection job named $, policy name $, storage domain name $, environment $, vmware vm name $, view name $"}) | % { New-Object object | Add-Member -NotePropertyMembers $_ -PassThru }
    New-PoshBotCardResponse -Text ($yourData | Format-List -Property * | Out-String -Width 120)

    $yourData = @(
        @{ Output = "get info on protection job indicated by name"; Command = "get cohesity protection job named $"}) | % { New-Object object | Add-Member -NotePropertyMembers $_ -PassThru }
    New-PoshBotCardResponse -Text ($yourData | Format-List -Property * | Out-String -Width 120)

    $yourData = @(
        @{Output = "outputs a graph indicating passed and failed runs";Command = "get cohesity protection runs report" }) | % { New-Object object | Add-Member -NotePropertyMembers $_ -PassThru }
    New-PoshBotCardResponse -Text ($yourData | Format-List -Property * | Out-String -Width 120)

    $yourData = @(
        @{ Output = "get resolved alerts with max number inputed"; Command = "get cohesity max resolved alerts $"}) | % { New-Object object | Add-Member -NotePropertyMembers $_ -PassThru }
    New-PoshBotCardResponse -Text ($yourData | Format-List -Property * | Out-String -Width 120)
    $yourData = @(
        @{Output = "resume a protection job"; Command = "resume cohesity protection job named $" }) | % { New-Object object | Add-Member -NotePropertyMembers $_ -PassThru }
    New-PoshBotCardResponse -Text ($yourData | Format-List -Property * | Out-String -Width 120)

    $yourData = @(
        @{ Output = "start a protection job"; Command = "start cohesity protection job named $" }) | % { New-Object object | Add-Member -NotePropertyMembers $_ -PassThru }
     New-PoshBotCardResponse -Text ($yourData | Format-List -Property * | Out-String -Width 120)

    $yourData = @(
        @{ Output = "stop protection job";Command = "stop cohesity protection job named $" }) | % { New-Object object | Add-Member -NotePropertyMembers $_ -PassThru }
    New-PoshBotCardResponse -Text ($yourData | Format-List -Property * | Out-String -Width 120)

    $yourData = @(
        @{ Output = "get info on Cohesity user"; Command = "get cohesity user" }) | % { New-Object object | Add-Member -NotePropertyMembers $_ -PassThru }
    New-PoshBotCardResponse -Text ($yourData | Format-List -Property * | Out-String -Width 120)
    $yourData = @(
        @{ Output = "resolve Cohesity alert"; Command = "resolve cohesity alert id $ with message: $" }) | % { New-Object object | Add-Member -NotePropertyMembers $_ -PassThru }
    New-PoshBotCardResponse -Text ($yourData | Format-List -Property * | Out-String -Width 120)

    $yourData = @(
        @{ Output = "get information on Cohesity cluster"; Command = "get cohesity cluster" }) | % { New-Object object | Add-Member -NotePropertyMembers $_ -PassThru }

        New-PoshBotCardResponse -Text ($yourData | Format-List -Property * | Out-String -Width 120)
}

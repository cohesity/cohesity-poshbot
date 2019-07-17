function Get-PBCohesityHelp {
    [PoshBot.BotCommand(
        Command = $false,
        TriggerType = 'regex',
        Regex = '(?i)Cohesity\scommand\shelp'
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
    @{Command="get Cohesity active protection jobs";Output="all active protection jobs"},
    @{Command="get Cohesity alerts -max $";Output="returns max number of alerts, if ✅ all in non critical, if ❌ alerts in critical, if ❗alerts in warning status"},
    @{Command="change Cohesity cluster to $";Output="change cluster being monitored indicated by numbers from 1 >"},
    @{Command="get Cohesity ip";Output="list Cohesity clusters available indicated by numbers from 1 >"},
    @{Command="create Cohesity protection job Name=[$] Policy Name=[$] Storage Domain Name=[$] Environment=[$] VMware VM name=[$] View Name=[$]";Output="create protection job if no View Name input [na], if no VMware VM name input [na]"},
    @{Command="get Cohesity protection job named $";Output="get info on protection job indicated by name"},
    @{Command="get Cohesity protection runs graph";Output="outputs a graph indicating passed and failed runs"},
    @{Command="get Cohesity resolved alerts -max $";Output="get resolved alerts with max number inputed"},
    @{Command="resume Cohesity protection job -Name $";Output="resume a protection job"},
    @{Command="start Cohesity protection job -Name $ -CopyRunTargets $ -Runtype $ -SourceIds $";Output="start a protection job; only name is required rest can be na"},
    @{Command="stop Cohesity protection job -Name $ -JobRunId $";Output="stop protection job; if no -JobRunId input na if no -Name input na"},
    @{Command="get Cohesity user";Output="get info on Cohesity user"},
    @{Command="get Cohesity cluster";Output="get information on Cohesity cluster"}) | % { New-Object object | Add-Member -NotePropertyMembers $_ -PassThru }
$objects = $yourData

New-PoshBotCardResponse -Text ($objects |  Format-List -Property * |Out-String -Width 120)
}


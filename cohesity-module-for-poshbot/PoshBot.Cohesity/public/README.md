# PoshBot-Cohesity
How to run Poshbot Cohesity commands
# Quick Start Guide

* [Prerequisites](#prerequisites)
* [Configuration in Poshbot](#configuration-in-poshbot)
* [Configuration in Config json](#configuration-in-config-json)
* [Configure on Slack](#configure-on-slack)
* [Commands](#commands)

# Prerequisites 
* [Cohesity Powershell Module](https://cohesity.github.io/cohesity-powershell-module/)

If Poshbot is not already installed and running on Slack reffer to documentation: 
  * [PoshBot Project](https://github.com/poshbotio/PoshBot)
  * [PoshBot Documentation](https://poshbot.readthedocs.io/en/latest/)

# Configuration in Poshbot
1. Clone the `cohesity-module-for-poshbot` directory in the `$env:PSModulePath` directory on your Linux server (it should be the path starting from the home directory) 

2. Next configure Poshbot with credentials (i.e password, username, and full path) 
  * To do this visit [http://docs.poshbot.io/en/latest/guides/configuration/] and create a default configuration in [/cohesity-module-for-poshbot/PoshBot.Cohesity/public] 
  * Path is path to repo to find this type `pwd`
  * In the newly created `PoshBotConfig.psd1` file under `PluginConfiguration` create a new section called `PoshBot.Cohesity`, using the following format: 
  ```
  @{
   'PoshBot.Cohesity' = @{
      Connection = @{
        Server   = 'ip'
        Username = 'username'
        Path = 'path'
      }
    }
}
  ```
# Configuration in Config json
In Cluster-Config.json file simple enter the clusters you want to monitor in this format: 
```
{
        "Cluster-ip" : [
                "ip address 1",
                "ip address 2"
        ]

}
```

 # Configure on Slack 
 
  1. To run Poshbot with configuration use the following commands: 
  ```
  $pbc = Get-PoshBotConfiguration -Path .\PoshBotConfig.psd1 
  $backend = New-PoshBotSlackBackend -Configuration $pbc.BackendConfiguration
  $bot = New-PoshBotInstance -Configuration $pbc -Backend $backend 
  $bot.Start() 
  ```
  Once in slack use the command `!install-plugin PoshBot.Cohesity` to install commands 
  
  2. The last step is to configure the cluster to get info on, use `get cohesity clusters` and `change cohesity cluster to _` to do this. 
  * Whenever needed you can switch clusters in order to monitor different clusters 
  
  # Commands 
  
  To get information on commands use `!help` to get info or `!help command -Full` (e.g `!help Get-PBCohesityAlerts -Full`) for full info on use.
  
  For more details:
  * $ indicates user input
  * commands are case insensitive
  
  | Command | Output |
| --------- | ----------- |
| `get Cohesity active protection jobs` | all active protection jobs|
| `get Cohesity alerts -max $` | returns max number of alerts, if green check all in non critical, if red x alerts in critical, if yellow warning alerts in warning status|
| `change Cohesity cluster to $` | change cluster being monitored indicated by numbers from 1 > |
| `get Cohesity cluster` | get information on Cohesity cluster|
| `get Cohesity ip` | list Cohesity clusters available indicated by numbers from 1 >|
| `create Cohesity protection job Name=[name] Policy Name=[name] Storage Domain Name=[name] Environment=[name] VMware VM name=[name] View Name=[na]` | create protection job if no `View Name` input `[na]`, if no `VMware VM name` input `[na]`|
| `get Cohesity protection job named $` | get info on protection job indicated by name|
| `get Cohesity protection runs graph` | outputs a graph indicating passed and failed runs|
| `get Cohesity resolved alerts -max $` | get resolved alerts with max number inputed|
| `resume Cohesity protection job -Name $` | resume a protection job|
| `start Cohesity protection job -Name $ -CopyRunTargets $ -Runtype $ -SourceIds $
` | start a protection job; only name is required rest can be `na`|
| `stop Cohesity protection job -Name $ -JobRunId $` | stop protection job; if no `-JobRunId` input `na` if no `-Name` input `na` |
| `get Cohesity user` | get info on Cohesity user|


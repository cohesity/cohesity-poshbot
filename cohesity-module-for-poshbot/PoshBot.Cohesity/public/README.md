# PoshBot-Cohesity
How to run Poshbot Cohesity commands
# Quick Start Guide

* [Prerequisites](#prerequisites)
* [Configuration in Poshbot](#configuration-in-poshbot)
* [Configuration in Config json](#3.-configuration-in-config-json)
* [Configure on Slack](#4.-configure-on-slack)
* [Configuration on Teams](#5.-configuration-on-teams)
* [Commands](#6.-commands)

# 1. Prerequisites 
* [Cohesity Powershell Module](https://cohesity.github.io/cohesity-powershell-module/)

If Poshbot is not already installed and running on Slack reffer to documentation: 
  * [PoshBot Project](https://github.com/poshbotio/PoshBot)
  * [PoshBot Documentation](https://poshbot.readthedocs.io/en/latest/)

# 2. Configuration in Poshbot
1. Clone the `cohesity-module-for-poshbot` directory in the `$env:PSModulePath` directory on your Linux server (it should be the path starting from the home directory) 

2. Next configure Poshbot with credentials (i.e password, username, and full path). To do this visit [link](http://docs.poshbot.io/en/latest/guides/configuration/) and create a default configuration in `/cohesity-module-for-poshbot/PoshBot.Cohesity/public` path
  * `Path` is path to repo, to find this type `pwd`
  * In the newly created `PoshBotConfig.psd1` file under `PluginConfiguration` create a new section called `PoshBot.Cohesity`, using the following format: 
  ```
  @{
   'PoshBot.Cohesity' = @{
      Connection = @{
        Password = 'password'
        Username = 'username'
        Path = 'path'
        Domain = 'domain'
      }
    }
}
  ```
# 3. Configuration in Config json
In Cluster-Config.json file simply enter the clusters you want to monitor in this format: 
```
{
        "Cluster-ip" : [
                "ip address 1",
                "ip address 2"
        ]

}
```

 # 4. Configuration on Slack 
 
  1. To run Poshbot with configuration use the following commands: 
  ```
  $pbc = Get-PoshBotConfiguration -Path .\PoshBotConfig.psd1 
  $backend = New-PoshBotSlackBackend -Configuration $pbc.BackendConfiguration
  $bot = New-PoshBotInstance -Configuration $pbc -Backend $backend 
  $bot.Start() 
  ```
  Once in slack use the command `!install-plugin PoshBot.Cohesity` to install commands 
  
  2. The last step is to configure the cluster to get info, use `get cohesity clusters` and `change cohesity cluster to _` commands to do this. 
  * Whenever needed you can switch clusters in order to monitor different clusters 
  
# 5. Configuration on Teams
1. Follow instruction on [link](https://poshbot.readthedocs.io/en/latest/guides/backends/setup-teams-backend/)

  # 6. Commands 
  
  To get information on commands use `get cohesity help` to get info or `!help command -Full` (e.g `!help Get-PBCohesityAlerts -Full`) for full info on use.
  
  For more details:
  * $ indicates user input
  * commands are case insensitive
  
  | Command | Output |
| --------- | ----------- |
| `get cohesity active protection jobs` | all active protection jobs|
| `get cohesity max alerts $` | returns max number of alerts, if :white_check_mark: all in non critical, if :x: alerts in critical, if ❗ alerts in warning status|
| `change cohesity cluster to $` | change cluster being monitored indicated by numbers from 1 > |
| `get cohesity cluster` | get information on Cohesity cluster|
| `get cohesity ip` | list Cohesity clusters available indicated by numbers from 1 >|
| `create cohesity protection job named $, policy name $, storage domain name $, environment $, vmware vm name $, view name $` | create protection job if no `view name` input `na`, if no `vmware vm name` input `na`|
| `get cohesity protection job named $` | get info on protection job indicated by name|
| `get cohesity protection runs report` | outputs a graph indicating passed and failed runs|
| `get cohesity max resolved alerts $` | get resolved alerts with max number inputed|
| `resume cohesity protection job $` | resume a protection job with name|
| `start cohesity protection job $` | start a protection job with name|
| `stop cohesity protection job $` | stop protection job with name |
| `resolve cohesity alert id $ with message: $` | resolve alert |
| `get cohesity user` | get info on Cohesity user|
| `get cohesity usage` | get cluster usage |
| `get cohesity latest alerts` | get latest alerts including resolved and unresolved alerts during the past day|


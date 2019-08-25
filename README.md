# Cohesity Poshbot - Beta
# 1. Overview
Cohesity chatbot uses the Poshbot framework to perform Cohesity actions in Slack or Microsoft Teams

# 2. Use Cases 
## Slack 
![](slack1.gif)

## Microsoft Teams 

![](teams1.gif)

# 3. Features 
Cohesity Poshbot can be used for: 
* Get commands
* Create a Cohesity protection job 
* Get Cohesity protection runs graph
* Resume/ Stop/ Start a Cohesity protection job 
* Resolve Cohesity alerts 

# 4. Process Overview
![Cohesity Poshbot Diagram](Diagram.png)

1. Set up configuration of Poshbot on Windows environment 
2. Commands get sent to Poshbot from slack
3. Commands are excecuted in Powershell 
4. REST API calls made through Cohesity Powershell module
5. Powershell output recieved by using Cohesity Powershell module 
6. Output is created in Poshbot as a custom response
7. Output is formatted and is displayed in Slack through Poshbot call

# 5. Get Started with Poshbot
Link to how to setup and get Poshbot running 
* [Quick Start Guide](/cohesity-module-for-poshbot/PoshBot.Cohesity/public/README.md)


#
# Module manifest for module 'PoshBot.Cohesity'
#


@{


RootModule = 'PoshBot.Cohesity.psm1'

ModuleVersion = '0.1.0'


CompanyName = 'Cohesity Inc.'


Description = 'This module is a plugin for PoshBot that uses Cohesity powershell commands'

RequiredModules = @('Cohesity.PowerShell.Core', 'PoshBot')


FunctionsToExport = '*'

CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = @()

AliasesToExport = @()


}


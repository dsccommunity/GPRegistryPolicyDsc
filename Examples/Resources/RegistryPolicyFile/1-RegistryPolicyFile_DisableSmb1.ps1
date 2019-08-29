<#PSScriptInfo
.VERSION 1.0.0
.GUID a1c9ad68-76e8-479b-a043-0af0887d7701
.AUTHOR Microsoft Corporation
.COMPANYNAME Microsoft Corporation
.COPYRIGHT
.TAGS DSCConfiguration GPRegistryPolicy GPO
.LICENSEURI https://github.com/dsccommunity/GPRegistryPolicyDsc/blob/master/LICENSE
.PROJECTURI https://github.com/dsccommunity/GPRegistryPolicyDsc
.ICONURI
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES First version.
.PRIVATEDATA 2016-Datacenter,2016-Datacenter-Server-Core
#>

#Requires -module 'GPRegistryPolicyDsc'

<#
    .SYNOPSIS
        Configuration that will disabled SMB1.

    .DESCRIPTION
        Configuration that will disabled SMB1.

    .PARAMETER Key
        Indicates the path of the registry key for which you want to ensure a specific state. This path must include the hive.

    .PARAMETER ValueName
        Indicates the name of the registry value.

    .PARAMETER ValueData
        The data for the registry value.

    .PARAMETER ValueType
        Indicates the type of the value.

    .PARAMETER TargetType
        Indicates the target type. This is needed to determine the .pol file path. Supported values are LocalMachine, User, Administrators, NonAdministrators, Account.

    .EXAMPLE
        $configurationParameters = @{
            Key        = 'SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
            TargetType = 'ComputerConfiguration'
            ValueName  = 'SMB1'
            ValueData  = 0
            ValueType  = 'DWORD'
        }

        RegistryPolicyFile_DisableSmb1Config @configurationParameters

        Compiles a configuration that disables SMB1.

    .EXAMPLE
        $configurationParameters = @{
            Key        = 'SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
            TargetType = 'ComputerConfiguration'
            ValueName  = 'SMB1'
            ValueData  = 0
            ValueType  = 'DWORD'
        }
        Start-AzureRmAutomationDscCompilationJob -ResourceGroupName '<resource-group>' -AutomationAccountName '<automation-account>' -ConfigurationName 'DscResourceTemplate_CreateFolderAsSystemConfig' -Parameters $configurationParameters

        Compiles a configuration in Azure Automation disables SMB1
        Replace the <resource-group> and <automation-account> with correct values.
#>
Configuration RegistryPolicyFile_DisableSmb1Config
{
    param
    (
        [Parameter()]
        [System.String[]]
        $NodeName = 'localhost',

        [Parameter(Mandatory = $true)]
        [System.String]
        $Key,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ValueName,

        [Parameter(Mandatory=$true)]
        [ValidateSet('ComputerConfiguration','UserConfiguration','Administrators','NonAdministrators','Account')]
        [System.String]
        $TargetType,

        [Parameter()]
        [System.String]
        $ValueData,

        [Parameter()]
        [ValidateSet('Binary','Dword','ExpandString','MultiString','Qword','String','None')]
        [System.String]
        $ValueType
    )

    Import-DscResource -ModuleName GPRegistryPolicyDsc -Name RegistryPolicyFile

    node $NodeName
    {
        RegistryPolicyFile TurnOffSmb1
        {
            Key        = $Key
            TargetType = $TargetType
            ValueName  = $ValueName
            ValueData  = $ValueData
            ValueType  = $ValueType
        }
    }
}

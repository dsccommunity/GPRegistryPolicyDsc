<#PSScriptInfo
.VERSION 1.0.0
.GUID 3c8e475f-50f1-4936-b3fd-0d6cf95e714e
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
        Configuration that will remove the registry policy that disables SMBv1.

    .DESCRIPTION
        Configuration that will remove the registry policy that disables SMBv1.
        This will cause the policy to show 'Not Configured' in gpedit.

    .PARAMETER NodeName
        The names of one or more nodes to compile a configuration for.
        Defaults to 'localhost'.

    .PARAMETER Key
        Indicates the path of the registry key for which you want to ensure a specific state. This path must include the hive.

    .PARAMETER ValueName
        Indicates the name of the registry value.

    .PARAMETER Ensure
        Specifies the desired state of the registry policy. When set to 'Present', the registry policy will be created. When set to 'Absent', the registry policy will be removed. Default value is 'Present'.

    .EXAMPLE
        $configurationParameters = @{
            Key        = 'SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
            TargetType = 'ComputerConfiguration'
            ValueName  = 'SMB1'
            Ensure = 'Absent'
        }

        RegistryPolicy_SMB1NotConfiguredConfig @configurationParameters

        Compiles a configuration that removes the policy to manage SMBv1 server.
#>
Configuration RegistryPolicy_SMB1NotConfiguredConfig
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
        $Ensure
    )

    Import-DscResource -ModuleName GPRegistryPolicyDsc -Name RegistryPolicyFile

    node $NodeName
    {
        RegistryPolicyFile TurnOffSmb1
        {
            Key        = $Key
            TargetType = $TargetType
            ValueName  = $ValueName
            Ensure     = $Ensure
        }
    }
}

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

#Requires -module GPRegistryPolicyDsc

<#
    .DESCRIPTION
        Configuration that will remove the registry policy that disables SMBv1.
        This will cause the policy to show 'Not Configured' in gpedit.
#>
Configuration RegistryPolicy_SMB1NotConfigured_Config
{
    Import-DscResource -ModuleName GPRegistryPolicyDsc

    node localhost
    {
        RegistryPolicyFile SMB1NotConfigured
        {
            Key        = 'SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
            TargetType = 'ComputerConfiguration'
            ValueName  = 'SMB1'
            Ensure     = 'Absent'
        }

        RefreshRegistryPolicy RefreashPolicyAfterSMB1
        {
            Name = 'RefreashPolicyAfterSMB1'
        }
    }
}

<#PSScriptInfo

.VERSION 1.0.1

.GUID 3c8e475f-50f1-4936-b3fd-0d6cf95e714e

.AUTHOR DSC Community

.COMPANYNAME DSC Community

.COPYRIGHT DSC Community contributors. All rights reserved.

.TAGS DSCConfiguration GPRegistryPolicy GPO

.LICENSEURI https://github.com/dsccommunity/GPRegistryPolicyDsc/blob/master/LICENSE

.PROJECTURI https://github.com/dsccommunity/GPRegistryPolicyDsc

.ICONURI https://dsccommunity.org/images/DSC_Logo_300p.png

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Updated author, copyright notice, and URLs.

.PRIVATEDATA 2016-Datacenter,2016-Datacenter-Server-Core

#> 

#Requires -Module GPRegistryPolicyDsc


<#
    .DESCRIPTION
        Configuration that will remove the registry policy that disables SMBv1.
        This will cause the policy to show 'Not Configured' in gpedit.
#>
Configuration RegistryPolicy_SMB1NotConfigured_Config
{
    Import-DscResource -ModuleName 'GPRegistryPolicyDsc'

    node localhost
    {
        RegistryPolicyFile 'SMB1NotConfigured'
        {
            Key        = 'SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
            TargetType = 'ComputerConfiguration'
            ValueName  = 'SMB1'
            Ensure     = 'Absent'
        }

        RefreshRegistryPolicy 'RefreshPolicyAfterSMB1'
        {
            IsSingleInstance = 'Yes'
            DependsOn        = '[RegistryPolicyFile]SMB1NotConfigured'
        }
    }
}

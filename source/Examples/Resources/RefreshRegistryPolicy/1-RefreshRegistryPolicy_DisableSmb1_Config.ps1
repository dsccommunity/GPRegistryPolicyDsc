<#PSScriptInfo

.VERSION 1.0.1

.GUID 44876c41-6843-41b7-a1e4-01c57ec7408c

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
        Configuration that will disabled SMB1.
        The configuration then uses the RefreshRegistryPolicy resource to
        invoke gpupdate.exe to refresh group policy and enforce the policy
        that has been recently configured. The corresponding policy in gpedit
        will not reflect the policy is being enforce until the RefreshRegistryPolicy
        resource has successfully ran.
#>
Configuration RefreshRegistryPolicy_DisableSmb1_Config
{
    Import-DscResource -ModuleName 'GPRegistryPolicyDsc'

    node localhost
    {
        RegistryPolicyFile 'TurnOffSmb1'
        {
            Key        = 'SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
            TargetType = 'ComputerConfiguration'
            ValueName  = 'SMB1'
            ValueData  = 0
            ValueType  = 'DWORD'
        }

        RefreshRegistryPolicy 'RefreshPolicyAfterSMB1'
        {
            IsSingleInstance = 'Yes'
            DependsOn        = '[RegistryPolicyFile]TurnOffSmb1'
        }
    }
}

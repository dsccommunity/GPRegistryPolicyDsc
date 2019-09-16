<#PSScriptInfo
.VERSION 1.0.0
.GUID 44876c41-6843-41b7-a1e4-01c57ec7408c
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
        Configuration that will disabled SMB1.
        The configuration then uses the RefreshRegistryPolicy resource to
        invoke gpupdate.exe to refresh group policy and enforce the policy 
        that has been recently configured. The corresponding policy in gpedit
        will not reflect the policy is being enforce until the RefreshRegistryPolicy
        resource has succesfully ran.
#>
Configuration RefreshRegistryPolicy_DisableSmb1_Config
{
    Import-DscResource -ModuleName GPRegistryPolicyDsc

    node localhost
    {
        RegistryPolicyFile TurnOffSmb1
        {
            Key        = 'SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
            TargetType = 'ComputerConfiguration'
            ValueName  = 'SMB1'
            ValueData  = 0
            ValueType  = 'DWORD'
        }

        RefreshRegistryPolicy RefreashPolicyAfterSMB1
        {
            Name             = 'RefreashPolicyAfterSMB1'
            IsSingleInstance = 'Yes'
            DependsOn        = '[RegistryPolicyFile]TurnOffSmb1'
        }
    }
}

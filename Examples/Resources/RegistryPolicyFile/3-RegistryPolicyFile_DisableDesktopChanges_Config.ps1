<#PSScriptInfo
.VERSION 1.0.0
.GUID 041272b8-6ac6-4a23-90f9-428d2823502d
.AUTHOR Microsoft Corporation
.COMPANYNAME Microsoft Corporation
.COPYRIGHT
.TAGS DSCConfiguration
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
        Configuration that will enable the the policy the prohibits changes to the desktop only
        for the Users group (Non-administrators) account.
#>
Configuration RegistryPolicyFile_DisableDesktopChanges_Config
{
    Import-DscResource -ModuleName 'GPRegistryPolicyDsc'

    node localhost
    {
        RegistryPolicyFile DisableDesktopChanges
        {
            Key         = 'Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'
            TargetType  = 'Account'
            ValueName   = 'NoActiveDesktopChanges'
            AccountName = 'Users'
            ValueData   = 1
            ValueType   = 'DWORD'
            Ensure      = 'Present'
        }

        RefreshRegistryPolicy RefreashPolicyAfterDisableDesktopChanges
        {
            IsSingleInstance = 'Yes'
            DependsOn        = '[RegistryPolicyFile]DisableDesktopChanges'
        }
    }
}

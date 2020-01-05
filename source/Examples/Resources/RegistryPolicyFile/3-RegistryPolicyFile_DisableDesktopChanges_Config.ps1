<#PSScriptInfo

.VERSION 1.0.1

.GUID 041272b8-6ac6-4a23-90f9-428d2823502d

.AUTHOR DSC Community

.COMPANYNAME DSC Community

.COPYRIGHT DSC Community contributors. All rights reserved.

.TAGS DSCConfiguration

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
        Configuration that will enable the the policy the prohibits changes to the desktop only
        for the Users group (Non-administrators) account.
#>
Configuration RegistryPolicyFile_DisableDesktopChanges_Config
{
    Import-DscResource -ModuleName 'GPRegistryPolicyDsc'

    node localhost
    {
        RegistryPolicyFile 'DisableDesktopChanges'
        {
            Key         = 'Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'
            TargetType  = 'Account'
            ValueName   = 'NoActiveDesktopChanges'
            AccountName = 'Users'
            ValueData   = 1
            ValueType   = 'DWORD'
            Ensure      = 'Present'
        }

        RefreshRegistryPolicy 'RefreshPolicyAfterDisableDesktopChanges'
        {
            IsSingleInstance = 'Yes'
            DependsOn        = '[RegistryPolicyFile]DisableDesktopChanges'
        }
    }
}

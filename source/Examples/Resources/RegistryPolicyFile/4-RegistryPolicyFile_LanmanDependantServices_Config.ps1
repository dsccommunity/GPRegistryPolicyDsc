<#PSScriptInfo

.VERSION 1.0.1

.GUID 53371052-3c19-4cc0-a2fb-7ccf94c24d50

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
        Configuration that will configure the LanmanWorkstation DependOnService property.
        This example demonstrates passing an array (MultiString) to ValueData.
#>
Configuration RegistryPolicyFile_LanmanDependantServices_Config
{
    Import-DscResource -ModuleName 'GPRegistryPolicyDsc'

    node localhost
    {
        RegistryPolicyFile 'LanmanDependantServices'
        {
            Key         = 'SYSTEM\CurrentControlSet\Services\LanmanWorkstation'
            TargetType  = 'ComputerConfiguration'
            ValueName   = 'DependOnService'
            ValueData   = 'Bowser','MRxSmb20','NSI'
            ValueType   = 'MultiString'
            Ensure      = 'Present'
        }

        RefreshRegistryPolicy 'RefreshPolicyAfterLanmanDependantServices'
        {
            IsSingleInstance = 'Yes'
            DependsOn        = '[RegistryPolicyFile]LanmanDependantServices'
        }
    }
}

<#PSScriptInfo
.VERSION 1.0.0
.GUID 53371052-3c19-4cc0-a2fb-7ccf94c24d50
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
        Configuration that will configure the lanmanWorkstation DependOnService property.
        This example demonstrates passing an array (MultiString) to ValueData.
#>
Configuration RegistryPolicyFile_LanmanDependantServices_Config
{
    Import-DscResource -ModuleName 'GPRegistryPolicyDsc'

    node localhost
    {
        RegistryPolicyFile LanmanDependantServices
        {
            Key         = 'SYSTEM\CurrentControlSet\Services\LanmanWorkstation'
            TargetType  = 'ComputerConfiguration'
            ValueName   = 'DependOnService'
            ValueData   = 'Bowser','MRxSmb20','NSI'
            ValueType   = 'MultiString'
            Ensure      = 'Present'
        }

        RefreshRegistryPolicy RefreashPolicyAfterLanmanDependantServices
        {
            IsSingleInstance = 'Yes'
            DependsOn        = '[RegistryPolicyFile]LanmanDependantServices'
        }
    }
}

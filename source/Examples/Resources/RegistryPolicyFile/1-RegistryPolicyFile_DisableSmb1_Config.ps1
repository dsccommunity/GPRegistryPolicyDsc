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

#Requires -module GPRegistryPolicyDsc

<#
    .DESCRIPTION
        Configuration that will disabled SMB1.
#>
Configuration RegistryPolicyFile_DisableSmb1_Config
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
            IsSingleInstance = 'Yes'
            DependsOn        = '[RegistryPolicyFile]TurnOffSmb1'
        }
    }
}

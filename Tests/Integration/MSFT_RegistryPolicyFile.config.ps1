#region HEADER
# Integration Test Config Template Version: 1.2.1
#endregion

$configFile = [System.IO.Path]::ChangeExtension($MyInvocation.MyCommand.Path, 'json')
if (Test-Path -Path $configFile)
{

    $ConfigurationData = Get-Content -Path $configFile | ConvertFrom-Json
}
else
{
    $ConfigurationData = @{
        AllNodes = @(
            @{
                NodeName   = 'localhost'
                Key        = 'SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
                TargetType = 'ComputerConfiguration'
                ValueName  = 'SMB1'
                ValueData  = 1
                ValueType  = 'DWORD'
            
                # data for  MSFT_RegistryPolicyFile_DisableSMB1_Config
                DtModKey         = 'Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'
                DtModTargetType  = 'Account'
                DtModValueName   = 'NoActiveDesktopChanges'
                DtModAccountName = 'builtin\Users'
                DtModValueData   = 1
                DtModValueType   = 'DWORD'

                SmbKey = 'SYSTEM\CurrentControlSet\Services\LanmanWorkstation'
                SmbTargetType = 'ComputerConfiguration'
                SmbValueName  = 'DependOnService'
                SmbValueData  = 'Browser','MRxSmb20','NSI'
                SmbValueType  = 'MultiString'
            }
        )
    }
}

<#
    .SYNOPSIS
        Disabled SMBv1 by adding the following administrative tempalte key:
        SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters
        SMB1 = 1
#>
Configuration MSFT_RegistryPolicyFile_DisableSMB1_Config
{
    Import-DscResource -ModuleName 'GPRegistryPolicyDsc'

    node $AllNodes.NodeName
    {
        RegistryPolicyFile 'Integration_Test_Disable_SMB1'
        {
            Key = $node.Key
            TargetType = $node.TargetType
            ValueName  = $node.ValueName
            ValueData  = $node.ValueData
            ValueType  = $node.ValueType
        }

        RefreshRegistryPolicy 'Integration_Test_RefreshAfter_SMB1'
        {
            Name = 'RefreshPolicyAfterDisableSMB1'
        }
    }
}

<#
    .SYNOPSIS
        Enfores the policy the prohibits changes to desktop for non-administrators
#>
Configuration MSFT_RegistryPolicyFile_Disable_DesktopModification_Config
{
    Import-DscResource -ModuleName 'GPRegistryPolicyDsc'

    node $AllNodes.NodeName
    {
        RegistryPolicyFile 'Integration_Test_Disable_DesktopModification'
        {
            Key         = $node.DtModKey
            TargetType  = $node.DtModTargetType
            ValueName   = $node.DtModValueName
            ValueData   = $node.DtModValueData
            ValueType   = $node.DtModValueType
            AccountName = $node.DtModAccountName
        }

        RefreshRegistryPolicy 'Integration_Test_RefreshAfter_Disable_DesktopModification'
        {
            Name = 'RefreshPolicyAfterDisableDesktopModification'
        }
    }
}

<#
    .SYNOPSIS
        Enfores the policy the configures Lanman dependent services.
#>
Configuration MSFT_RegistryPolicyFile_LanmanServices_Config
{
    Import-DscResource -ModuleName 'GPRegistryPolicyDsc'

    node $AllNodes.NodeName
    {
        RegistryPolicyFile 'Integration_Test_LanmanServices'
        {
            Key         = $node.SmbKey
            TargetType  = $node.SmbTargetType
            ValueName   = $node.SmbValueName
            ValueData   = $node.SmbValueData
            ValueType   = $node.SmbValueType
        }

        RefreshRegistryPolicy 'Integration_Test_RefreshAfter_LanmanServices'
        {
            Name = 'RefreshPolicyAfterLanmanServices'
        }
    }
}

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
                # policy with a dword datatype
                NodeName   = 'localhost'
                Key        = 'SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
                TargetType = 'ComputerConfiguration'
                ValueName  = 'SMB1'
                ValueData  = 1
                ValueType  = 'DWORD'
            
                # policy target at a user account
                DtModKey         = 'Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'
                DtModTargetType  = 'Account'
                DtModValueName   = 'NoActiveDesktopChanges'
                DtModAccountName = 'builtin\Users'
                DtModValueData   = 1
                DtModValueType   = 'DWORD'

                # policy with a multi-string datatype
                SmbKey = 'SYSTEM\CurrentControlSet\Services\LanmanWorkstation'
                SmbTargetType = 'ComputerConfiguration'
                SmbValueName  = 'DependOnService'
                SmbValueData  = 'Browser','MRxSmb20','NSI'
                SmbValueType  = 'MultiString'

                # policy with a string datatype
                FtKey = 'Software\Policies\Microsoft\Windows\TCPIP\v6Transition'
                FtTargetType = 'ComputerConfiguration'
                FtValueName  = 'Force_Tunneling'
                FtValueData  = 'Enabled'
                FtValueType  = 'String'
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
        Enfores the policy the prohibits changes to desktop for non-administrators.
        Tests the scenario where the targetType is a user account.
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
        Enfores the policy that configures Lanman dependent services.
        Tests the scenario when the dataType is muti-string.
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

<#
    .SYNOPSIS
        Enfores the policy the enables IPv6 forced tunneling.
        Tests the scenario when dataType is a string.
#>
Configuration MSFT_RegistryPolicyFile_ForcedTunneling_Config
{
    Import-DscResource -ModuleName 'GPRegistryPolicyDsc'

    node $AllNodes.NodeName
    {
        RegistryPolicyFile 'Integration_Test_ForcedTunneling'
        {
            Key         = $node.FtKey
            TargetType  = $node.FtTargetType
            ValueName   = $node.FtValueName
            ValueData   = $node.FtValueData
            ValueType   = $node.FtValueType
        }

        RefreshRegistryPolicy 'Integration_Test_RefreshAfter_ForcedTunneling'
        {
            Name = 'RefreshPolicyAfterForcedTunneling'
        }
    }
}
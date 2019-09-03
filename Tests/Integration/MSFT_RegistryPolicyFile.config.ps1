<#
    .SYNOPSIS
        DSC Configuration Template for DSC Resource Integration tests.

    .DESCRIPTION
        To Use:
            1. Copy to \Tests\Integration\ folder and rename <ResourceName>.config.ps1
               (e.g. MSFT_Firewall.config.ps1).
            2. Customize TODO sections.
            3. Remove TODO comments and TODO comment-blocks.
            4. Remove this comment-based help.

    .NOTES
        Comment in HEADER region are standard and should not be altered.
#>

#region HEADER
# Integration Test Config Template Version: 1.2.1
#endregion

$configFile = [System.IO.Path]::ChangeExtension($MyInvocation.MyCommand.Path, 'json')
if (Test-Path -Path $configFile)
{
    <#
        TODO: Allows reading the configuration data from a JSON file,
        e.g. integration_template.config.json for real testing
        scenarios outside of the CI.
    #>
    $ConfigurationData = Get-Content -Path $configFile | ConvertFrom-Json
}
else
{
    <#
        TODO: (Optional) If appropriate, this configuration hash table
        can be moved from here and into the integration test file.
        For example, if there are several configurations which all
        need different configuration properties, it might be easier
        to have one ConfigurationData-block per configuration test
        than one big ConfigurationData-block here.
        It may also be moved if it is easier to read the tests when
        the ConfigurationData-block is in the integration test file.
        The reason for it being here is that it is easier to read
        the configuration when the ConfigurationData-block is in this
        file.
    #>
    $ConfigurationData = @{
        AllNodes = @(
            @{
                NodeName   = 'localhost'
                Key        = 'SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
                TargetType = 'ComputerConfiguration'
                ValueName  = 'SMB1'
                ValueData  = 1
                ValueType  = 'DWORD'
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
# TODO: Modify ResourceName and ShortDescriptiveName (e.g. MSFT_Firewall_EnableRemoteDesktopConnection_Config).
Configuration MSFT_RegistryPolicyFile_DisableSMB1_Config
{
    Import-DscResource -ModuleName 'GPRegistryPolicyDsc'

    node $AllNodes.NodeName
    {
        # TODO: Modify ResourceFriendlyName (e.g. Firewall).
        RegistryPolicyFile 'Integration_Test_Disable_SMB1'
        {
            # TODO: Add resource parameters here.
            Key = $node.Key
            TargetType = $node.TargetType
            ValueName = $node.ValueName
            ValueData = $node.ValueData
            ValueType = $node.ValueType
        }

        RefreshRegistryPolicy 'Integration_Test_RefreshAfter_SMB1'
        {
            Name = 'RefreshPolicyAfterDisableSMB1'
        }
    }
}

# TODO: (Optional) Add More Configuration Templates as needed.

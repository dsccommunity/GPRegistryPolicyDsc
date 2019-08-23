#region HEADER
# Integration Test Config Template Version: 1.2.0
#endregion

$configFile = [System.IO.Path]::ChangeExtension($MyInvocation.MyCommand.Path, 'json')
if (Test-Path -Path $configFile)
{
    <#
        Allows reading the configuration data from a JSON file, for real testing
        scenarios outside of the CI.
    #>
    $ConfigurationData = Get-Content -Path $configFile | ConvertFrom-Json
}
else
{
    $ConfigurationData = @{
        AllNodes = @(
            @{
                NodeName = 'localhost'
                CertificateFile = $env:DscPublicCertificatePath

                Path     = 'C:\DscTemp'
                ReadOnly = $false
            }
        )
    }
}


Configuration MSFT_Folder_Create_Config
{
    Import-DscResource -ModuleName 'DscResource.Template'

    node $AllNodes.NodeName
    {
        Folder 'Integration_Test'
        {

            Path     = $Node.Path
            ReadOnly = $Node.ReadOnly
        }
    }
}

Configuration MSFT_Folder_Remove_Config
{
    Import-DscResource -ModuleName 'DscResource.Template'

    node $AllNodes.NodeName
    {
        Folder 'Integration_Test'
        {
            Ensure   = 'Absent'
            Path     = $Node.Path
            ReadOnly = $Node.ReadOnly
        }
    }
}

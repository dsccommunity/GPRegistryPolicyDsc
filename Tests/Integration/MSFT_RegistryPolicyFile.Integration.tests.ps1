<#
    .SYNOPSIS
       Template for creating DSC Resource Integration Tests

    .DESCRIPTION
        To Use:
            1. Copy to \Tests\Integration\ folder and rename <ResourceName>.Integration.tests.ps1
               (e.g. MSFT_Firewall.Integration.tests.ps1).
            2. Customize TODO sections.
            3. Remove TODO comments.
            4. Create test DSC Configuration file <ResourceName>.config.ps1
               (e.g. MSFT_Firewall.config.ps1) from integration_template.config.ps1 file.
            5. Remove this comment-based help.

    .NOTES
        Code in HEADER and FOOTER regions are standard and should not be altered
        if possible.
#>

# TODO: Customize these parameters...
$script:dscModuleName = 'GPRegistryPolicyDsc' # TODO: Example 'NetworkingDsc'
$script:dscResourceFriendlyName = 'RegistryPolicyFile' # TODO: Example 'Firewall'
$script:dscResourceName = "MSFT_$($script:dscResourceFriendlyName)" # TODO: Update prefix

#region HEADER
# Integration Test Template Version: 1.3.3
[String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
    (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone', 'https://github.com/PowerShell/DscResource.Tests.git', (Join-Path -Path $script:moduleRoot -ChildPath 'DscResource.Tests'))
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResource.Tests' -ChildPath 'TestHelper.psm1')) -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:dscModuleName `
    -DSCResourceName $script:dscResourceName `
    -TestType Integration
#endregion

# TODO: (Optional) Other init code goes here.

# Using try/finally to always cleanup.
try
{
    #region Integration Tests
    $configurationFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:dscResourceName).config.ps1"
    . $configurationFile

    Describe "$($script:dscResourceName)_Integration" {
        Context ('When using configuration {0}' -f $configurationName) {
            BeforeEach {
                $configurationName = "$($script:dscResourceName)_DisableSMB1_Config"
                $resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test_Disable_SMB1"
            }
            It 'Should compile and apply the MOF without throwing' {
                {
                    $configurationParameters = @{
                        OutputPath           = $TestDrive
                        ConfigurationData    = $ConfigurationData
                    }

                    & $configurationName @configurationParameters

                    $startDscConfigurationParameters = @{
                        Path         = $TestDrive
                        ComputerName = 'localhost'
                        Wait         = $true
                        Verbose      = $true
                        Force        = $true
                        ErrorAction  = 'Stop'
                    }

                    Start-DscConfiguration @startDscConfigurationParameters
                } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                {
                    $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
                } | Should -Not -Throw
            }

            It 'Should have set the resource and all the parameters should match' {
                $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
                    $_.ConfigurationName -eq $configurationName `
                    -and $_.ResourceId -eq $resourceId
                }

                # TODO: Validate the Config was Set Correctly Here...
                $resourceCurrentState.Ensure     | Should -Be 'Present'
                $resourceCurrentState.Key        | Should -Be $ConfigurationData.AllNodes.Key
                $resourceCurrentState.ValueType  | Should -Be $ConfigurationData.AllNodes.ValueType
                $resourceCurrentState.ValueData  | Should -Be $ConfigurationData.AllNodes.ValueData
                $resourceCurrentState.TargetType | Should -Be $ConfigurationData.AllNodes.TargetType
                $resourceCurrentState.ValueName  | Should -Be $ConfigurationData.AllNodes.ValueName
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be 'True'
            }
        }

        Context ('When using configuration {0}' -f $configurationName) {
            BeforeEach {
                $configurationName = "$($script:dscResourceName)_Disable_DesktopModification_Config"
                $resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test_Disable_DesktopModification"
            }
            It 'Should compile and apply the MOF without throwing' {
                {
                    $configurationParameters = @{
                        OutputPath           = $TestDrive
                        ConfigurationData    = $ConfigurationData
                    }

                    & $configurationName @configurationParameters

                    $startDscConfigurationParameters = @{
                        Path         = $TestDrive
                        ComputerName = 'localhost'
                        Wait         = $true
                        Verbose      = $true
                        Force        = $true
                        ErrorAction  = 'Stop'
                    }

                    Start-DscConfiguration @startDscConfigurationParameters
                } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                {
                    $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
                } | Should -Not -Throw
            }

            It 'Should have set the resource and all the parameters should match' {
                $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
                    $_.ConfigurationName -eq $configurationName `
                    -and $_.ResourceId -eq $resourceId
                }

                $resourceCurrentState.Ensure      | Should -Be 'Present'
                $resourceCurrentState.Key         | Should -Be $ConfigurationData.AllNodes.DtModKey
                $resourceCurrentState.ValueType   | Should -Be $ConfigurationData.AllNodes.DtModValueType
                $resourceCurrentState.ValueData   | Should -Be $ConfigurationData.AllNodes.DtModValueData
                $resourceCurrentState.TargetType  | Should -Be $ConfigurationData.AllNodes.DtModTargetType
                $resourceCurrentState.AccountName | Should -Be $ConfigurationData.AllNodes.DtModAccountName
                $resourceCurrentState.ValueName   | Should -Be $ConfigurationData.AllNodes.DtModValueName
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be 'True'
            }
        }

        Context ('When using configuration {0}' -f $configurationName) {
            BeforeEach {
                $configurationName = "$($script:dscResourceName)_LanmanServices_Config"
                $resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test_LanmanServices"
            }
            It 'Should compile and apply the MOF without throwing' {
                {
                    $configurationParameters = @{
                        OutputPath           = $TestDrive
                        ConfigurationData    = $ConfigurationData
                    }

                    & $configurationName @configurationParameters

                    $startDscConfigurationParameters = @{
                        Path         = $TestDrive
                        ComputerName = 'localhost'
                        Wait         = $true
                        Verbose      = $true
                        Force        = $true
                        ErrorAction  = 'Stop'
                    }

                    Start-DscConfiguration @startDscConfigurationParameters
                } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                {
                    $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
                } | Should -Not -Throw
            }

            It 'Should have set the resource and all the parameters should match' {
                $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
                    $_.ConfigurationName -eq $configurationName `
                    -and $_.ResourceId -eq $resourceId
                }

                $resourceCurrentState.Ensure      | Should -Be 'Present'
                $resourceCurrentState.Key         | Should -Be $ConfigurationData.AllNodes.SmbKey
                $resourceCurrentState.ValueType   | Should -Be $ConfigurationData.AllNodes.SmbValueType
                $resourceCurrentState.ValueData   | Should -Be $ConfigurationData.AllNodes.SmbValueData
                $resourceCurrentState.TargetType  | Should -Be $ConfigurationData.AllNodes.SmbTargetType
                $resourceCurrentState.ValueName   | Should -Be $ConfigurationData.AllNodes.SmbValueName
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be 'True'
            }
        }

    }
    #endregion

}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion

    # TODO: (Optional) Other cleanup code goes here.
}

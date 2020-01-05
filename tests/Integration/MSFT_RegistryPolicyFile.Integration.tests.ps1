
$script:dscModuleName = 'GPRegistryPolicyDsc'
$script:dscResourceFriendlyName = 'RegistryPolicyFile'
$script:dscResourceName = "MSFT_$($script:dscResourceFriendlyName)"

try
{
    Import-Module -Name DscResource.Test -Force
}
catch [System.IO.FileNotFoundException]
{
    throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
}

$script:testEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:dscModuleName `
    -DSCResourceName $script:dscResourceName `
    -ResourceType 'Mof' `
    -TestType 'Integration'

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

        Context ('When using configuration {0}' -f $configurationName) {
            BeforeEach {
                $configurationName = "$($script:dscResourceName)_ForcedTunneling_Config"
                $resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test_ForcedTunneling"
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
                $resourceCurrentState.Key         | Should -Be $ConfigurationData.AllNodes.FtKey
                $resourceCurrentState.ValueType   | Should -Be $ConfigurationData.AllNodes.FtValueType
                $resourceCurrentState.ValueData   | Should -Be $ConfigurationData.AllNodes.FtValueData
                $resourceCurrentState.TargetType  | Should -Be $ConfigurationData.AllNodes.FtTargetType
                $resourceCurrentState.ValueName   | Should -Be $ConfigurationData.AllNodes.FtValueName
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
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}

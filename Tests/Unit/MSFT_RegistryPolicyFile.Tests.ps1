#region HEADER
$script:dscModuleName = 'GPRegistryPolicyDsc'
$script:dscResourceName = 'MSFT_RegistryPolicyFile'

# Unit Test Template Version: 1.2.4
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
    (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone', 'https://github.com/PowerShell/DscResource.Tests.git', (Join-Path -Path $script:moduleRoot -ChildPath 'DscResource.Tests'))
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResource.Tests' -ChildPath 'TestHelper.psm1')) -Force

$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:dscModuleName `
    -DSCResourceName $script:dscResourceName `
    -ResourceType 'Mof' `
    -TestType Unit

#endregion HEADER

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}

# Begin Testing
try
{
    InModuleScope $script:dscResourceName {
        $mockFolderObject = $null

        Describe 'MSFT_RegistryPolicyFile\Get-TargetResource' -Tag 'Get' {
            BeforeAll {
                $defaultParameters = @{
                    Key        = 'SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
                    ValueName  = 'SMB1'
                    TargetType = 'ComputerConfiguration'
                }
            }

            BeforeEach {
                $getTargetResourceParameters = $defaultParameters.Clone()
            }

            Context 'When the configuration is absent' {
                BeforeEach {
                    Mock -CommandName Get-RegistryPolicyFilePath -MockWith {
                        'C:\Windows\System32\GroupPolicy\Machine\registry.pol'
                    } -Verifiable

                    Mock -CommandName Test-Path -MockWith {
                        $true
                    } -Verifiable

                    $registryPolicyParameters = @{
                        Key       = 'SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
                        ValueName = 'SMB1NotPresent'
                        ValueType = 'REG_DWORD'
                        ValueData = 1
                    }
                    $mockReadPolicyFile = New-GPRegistryPolicy @registryPolicyParameters

                    Mock -CommandName Read-GPRegistryPolicyFile -MockWith {
                        $mockReadPolicyFile
                    }
                }

                It 'Should return the state as absent' {
                    $getTargetResourceResult = Get-TargetResource @getTargetResourceParameters
                    $getTargetResourceResult.Ensure | Should -Be 'Absent'

                    Assert-MockCalled Test-Path -Exactly -Times 1 -Scope It
                    Assert-MockCalled Get-RegistryPolicyFilePath -Exactly -Times 1 -Scope It
                    Assert-MockCalled Read-GPRegistryPolicyFile -Exactly -Times 1 -Scope It
                }

                It 'Should return the same values as passed as parameters' {
                    $getTargetResourceResult = Get-TargetResource @getTargetResourceParameters
                    $getTargetResourceResult.Path | Should -Be 'C:\Windows\System32\GroupPolicy\Machine\registry.pol'
                    $getTargetResourceResult.TargetType | Should -Be $getTargetResourceParameters.TargetType
                }

                It 'Should return $false or $null respectively for the rest of the properties' {
                    $getTargetResourceResult = Get-TargetResource @getTargetResourceParameters

                    $getTargetResourceResult.Key | Should -BeNullOrEmpty
                    $getTargetResourceResult.ValueData | Should -BeNullOrEmpty
                    $getTargetResourceResult.ValueType | Should -BeNullOrEmpty
                    $getTargetResourceResult.ValueName | Should -BeNullOrEmpty
                }
            }

            Context 'When the configuration is present' {
                BeforeAll {
                    $defaultParameters = @{
                        Key        = 'SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
                        ValueName  = 'SMB1'
                        TargetType = 'Account'
                        AccountName = 'User1'
                    }
                }
    
                BeforeEach {
                    Mock -CommandName Get-RegistryPolicyFilePath -MockWith {
                        'C:\Windows\System32\GroupPolicyUsers\S-1-5-21-3318452954-581252911-2334442305-1001\User\Registry.pol'
                    } -Verifiable

                    Mock -CommandName Test-Path -MockWith {
                        $true
                    } -Verifiable

                    $registryPolicyParameters = @{
                        Key       = 'SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
                        ValueName = 'SMB1'
                        ValueType = 'REG_DWORD'
                        ValueData = 1
                    }
                    $mockReadPolicyFile = New-GPRegistryPolicy @registryPolicyParameters
                    Mock -CommandName Read-GPRegistryPolicyFile -MockWith {
                        $mockReadPolicyFile
                    }

                    Mock -CommandName ConvertTo-NTAccountName -MockWith {
                        'User1'
                    } -Verifiable
                }

                It 'Should return the state as present' {
                    $getTargetResourceResult = Get-TargetResource @getTargetResourceParameters
                    $getTargetResourceResult.Ensure | Should -Be 'Present'

                    Assert-MockCalled Test-Path -Exactly -Times 1 -Scope It
                    Assert-MockCalled Get-RegistryPolicyFilePath -Exactly -Times 1 -Scope It
                    Assert-MockCalled Read-GPRegistryPolicyFile -Exactly -Times 1 -Scope It
                    Assert-MockCalled ConvertTo-NTAccountName -Exactly -Times 1 -Scope It
                }

                It 'Should return the same values as passed as parameters' {
                    $getTargetResourceResult = Get-TargetResource @getTargetResourceParameters
                    $getTargetResourceResult.Key | Should -Be $getTargetResourceParameters.Key
                    $getTargetResourceResult.ValueName | Should -Be $getTargetResourceParameters.ValueName
                    $getTargetResourceResult.ValueData | Should -Be 1
                    $getTargetResourceResult.AccountName | Should -Be 'User1'
                }
            }
        }

        Describe 'MSFT_RegistryPolicyFile\Test-TargetResource' -Tag 'Test' {
            BeforeAll {
                $defaultParameters = @{
                    Key        = 'SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
                    TargetType = 'ComputerConfiguration'
                    ValueName  = 'SMB1'
                    ValueData  = 1
                    ValueType  = 'DWORD'
                    Ensure     = 'Absent'
                }

                $getTargetResourceDefaultReadResults = @{
                    Path        = '"C:\Windows\System32\GroupPolicy\Machine\registry.pol"'
                    AccountName = 'Machine'
                }

            }

            BeforeEach {
                $testTargetResourceParameters = $defaultParameters.Clone()
                
            }

            Context 'When the system is in the desired state' {
                Context 'When the configuration are absent' {
                    BeforeAll {
                        Mock -CommandName Get-TargetResource -MockWith {
                            $getTargetResourceResults
                        } -Verifiable
                    }

                    BeforeEach {
                        $testTargetResourceParameters['Ensure'] = 'Absent'
                        $getTargetResourceResults = $getTargetResourceDefaultReadResults + $testTargetResourceParameters
                        
                    }

                    It 'Should return the $true' {
                        $testTargetResourceResult = Test-TargetResource @testTargetResourceParameters
                        $testTargetResourceResult | Should -Be $true

                        Assert-MockCalled Get-TargetResource -Exactly -Times 1 -Scope It
                    }
                }

                Context 'When the configuration are present' {
                    BeforeEach {
                        $testTargetResourceParameters['Ensure'] = 'Present'
                        $getTargetResourceResults = $getTargetResourceDefaultReadResults + $testTargetResourceParameters

                        Mock -CommandName Get-TargetResource -MockWith {
                            return $getTargetResourceResults
                        } -Verifiable
                    }

                    It 'Should return the $true' {
                        $testTargetResourceResult = Test-TargetResource @testTargetResourceParameters
                        $testTargetResourceResult | Should -Be $true

                        Assert-MockCalled Get-TargetResource -Exactly -Times 1 -Scope It
                    }
                }

                Assert-VerifiableMock
            }

            Context 'When the system is not in the desired state' {
                Context 'When the configuration should be absent' {
                    BeforeEach {
                        $testTargetResourceParameters['Ensure'] = 'Absent'
                        $getTargetResourceResults = $getTargetResourceDefaultReadResults + $testTargetResourceParameters
                        $getTargetResourceResults['Ensure'] = 'Present'
                    }

                    It 'Should return the $false' {
                        Mock -CommandName Get-TargetResource -MockWith {
                            $getTargetResourceResults
                        } -Verifiable

                        $testTargetResourceResult = Test-TargetResource @testTargetResourceParameters
                        $testTargetResourceResult | Should -Be $false
                    }
                }

                Context 'When the configuration should be present' {
                    BeforeEach {
                        $testTargetResourceParameters['Ensure'] = 'Present'
                        $getTargetResourceResults = $getTargetResourceDefaultReadResults + $testTargetResourceParameters
                        $getTargetResourceResults['ValueData'] = 0
                    }

                    It 'Should return the $false' {
                        Mock -CommandName Get-TargetResource -MockWith {
                            $getTargetResourceResults
                        } -Verifiable

                        $testTargetResourceResult = Test-TargetResource @testTargetResourceParameters
                        $testTargetResourceResult | Should -Be $false
                    }
                }

                Assert-VerifiableMock
            }
        }

        Describe 'MSFT_RegistryPolicyFile\Set-TargetResource' -Tag 'Set' {
            BeforeAll {
                $defaultParameters = @{
                    Key        = 'SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
                    TargetType = 'ComputerConfiguration'
                    ValueName  = 'SMB1'
                    ValueData  = 1
                    ValueType  = 'DWORD'
                    Ensure     = 'Present'
                }

                Mock -CommandName New-GPRegistryPolicy -ParameterFilter {
                    $Key -eq $setTargsetTargetResourceParameters.Key -and
                    $ValueName -eq $setTargsetTargetResourceParameters.ValueName -and
                    $ValueData -eq $setTargsetTargetResourceParameters.ValueData -and
                    $ValueType -eq 'REG_DWORD'
                } -Verifiable

                Mock -CommandName New-GPRegistryPolicyFile -ParameterFilter {
                    $Path -eq $polFilePath
                } -Verifiable

                Mock -CommandName Set-GPRegistryPolicyFileEntry -Verifiable

                $polFilePath = "C:\Windows\System32\GroupPolicy\Machine\registry.pol"
                Mock -CommandName Set-RefreshRegistryKey
            }

            BeforeEach {
                $setTargetResourceParameters = $defaultParameters.Clone()
            } 

            Context 'When the configuration should be absent' {
                BeforeAll {
                    Mock -CommandName Get-TargetResource -MockWith {
                        return @{
                            Ensure = 'Present'
                        }
                    } -Verifiable

                    Mock -CommandName Remove-GPRegistryPolicyFileEntry -Verifiable

                    Mock -CommandName Get-RegistryPolicyFilePath -ParameterFilter {
                        $TargetType -eq $setTargetResourceParameters.TargetType -and
                        $null -eq $AccountName
                    } -Verifiable
                }

                BeforeEach {
                    $setTargetResourceParameters['Ensure'] = 'Absent'
                }

                It 'Should call the correct mocks' {
                    { Set-TargetResource @setTargetResourceParameters } | Should -Not -Throw

                    Assert-MockCalled -CommandName Remove-GPRegistryPolicyFileEntry -Exactly -Times 1 -Scope 'It'
                    Assert-MockCalled -CommandName Set-RefreshRegistryKey -Exactly -Times 1 -Scope 'It'
                }
            }

            Context 'When the configuration should be present' {
                BeforeAll {
                    Mock -CommandName Get-TargetResource -MockWith {
                        return @{
                            Ensure = 'Absent'
                        }
                    } -Verifiable

                    Mock -CommandName Test-Path -MockWith {$false} -Verifiable
                }

                BeforeEach {
                    $setTargetResourceParameters['Ensure'] = 'Present'
                }

                It 'Should call the correct mocks' {
                    { Set-TargetResource @setTargetResourceParameters } | Should -Not -Throw

                    Assert-MockCalled -CommandName New-GPRegistryPolicyFile -Exactly -Times 1 -Scope 'It'
                    Assert-MockCalled -CommandName Set-GPRegistryPolicyFileEntry -Exactly -Times 1 -Scope 'It'
                    Assert-MockCalled -CommandName Set-RefreshRegistryKey -Exactly -Times 1 -Scope 'It'
                }
            }

            Context 'When the configuration is present but has the wrong properties' {
                BeforeAll {
                    Mock -CommandName Get-TargetResource -MockWith {
                        return @{
                            Ensure = 'Absent'
                        }
                    } -Verifiable

                    Mock -CommandName Test-Path -MockWith {$true} -Verifiable
                }

                It 'Should call the correct mocks' {
                    { Set-TargetResource @setTargetResourceParameters } | Should -Not -Throw

                    Assert-MockCalled -CommandName New-GPRegistryPolicyFile -Exactly -Times 0 -Scope 'It'
                    Assert-MockCalled -CommandName Set-GPRegistryPolicyFileEntry -Exactly -Times 1 -Scope 'It'
                    Assert-MockCalled -CommandName Set-RefreshRegistryKey -Exactly -Times 1 -Scope 'It'
                }
            }
        }

        Describe 'MSFT_RegistryPolicyFile\Get-RegistryPolicyFilePath' -Tag 'Helper' {
            BeforeAll {
                Mock -CommandName ConvertTo-SecurityIdentifier -ParameterFilter {$AccountName -ne 'administrators'}
                
                $filePathMap  = @{
                    ComputerConfiguration = 'System32\GroupPolicy\Machine\registry.pol'
                    UserConfiguration     = 'System32\GroupPolicy\User\registry.pol'
                    Administrators = 'System32\GroupPolicyUsers\S-1-5-32-544\User\registry.pol'
                    NonAdministrators = 'System32\GroupPolicyUsers\S-1-5-32-545\User\registry.pol'
                    Account = 'System32\GroupPolicyUsers\S-1-5-32-544\User\registry.pol'
                }

                $testCases = @(
                    @{TargetType = 'ComputerConfiguration'}
                    @{TargetType = 'UserConfiguration'}
                    @{TargetType = 'Administrators'}
                    @{TargetType = 'NonAdministrators'}
                    @{TargetType = 'Account';AccountName = 'administrators'}
                )
            }

            Context 'Asserting correct path' {
                It 'Should return the correct path for <TargetType>' -TestCases $testCases {
                    param ($TargetType, $AccountName)
                    $result = Get-RegistryPolicyFilePath -TargetType $TargetType -AccountName $AccountName
                    $desiredResult = Join-Path -Path $env:SystemRoot -ChildPath $filePathMap[$TargetType]
                    
                    $result | Should -Be $desiredResult
                }
            }
        }

        Describe 'MSFT_RegistryPolicyFile\ConvertTo-SecurityIdentifer' -Tag 'Helper' {
            Context 'Assert correct SID is returned' {
                It 'Should return the correct SID' {
                    $result = ConvertTo-SecurityIdentifier -AccountName Administrators
                    $result | Should -Be 'S-1-5-32-544'
                }
            }
        }

        Describe 'MSFT_RegistryPolicyFile\ConvertTo-NTAccountName' -Tag 'Helper' {
            Context 'Assert correct NTAccountName is returned' {
                It 'Return the correct NTAccountName' {
                    $result = ConvertTo-NTAccountName -SecurityIdentifier 'S-1-5-32-544'
                    $result | Should -Be 'BUILTIN\Administrators'
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}


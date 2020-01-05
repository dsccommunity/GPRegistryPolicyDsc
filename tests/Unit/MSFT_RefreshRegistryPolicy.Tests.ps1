
#region HEADER
$script:dscModuleName = 'GPRegistryPolicyDsc'
$script:dscResourceName = 'MSFT_RefreshRegistryPolicy'

function Invoke-TestSetup
{
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
        -TestType 'Unit'
}

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}

Invoke-TestSetup

try
{
    InModuleScope $script:dscResourceName {
        Describe 'MSFT_RefreshRegistryPolicy\Get-TargetResource' -Tag 'Get' {
            BeforeAll {
                $mockReadRefreshKey = @{
                    Path = 'HKLM:\SOFTWARE\Microsoft\GPRegistryPolicy'
                    Value = 1
                }

                $defaultParameters = @{
                    IsSingleInstance = 'Yes'
                }
            }

            Context 'When the system is in the desired state' {
                BeforeEach {
                    Mock -CommandName Read-GPRefreshRegistryKey
                }

                It 'Should return the proper registry key property values' {
                    $getTargetResourceResult = Get-TargetResource @defaultParameters
                    $getTargetResourceResult.Path | Should -BeNullOrEmpty
                    $getTargetResourceResult.RefreshRequiredKey | Should -BeNullOrEmpty

                    Assert-MockCalled -CommandName Read-GPRefreshRegistryKey -Exactly -Times 1 -Scope It
                }

            }

            Context 'When the system is not in the desired state' {
                BeforeEach {
                    Mock -CommandName Read-GPRefreshRegistryKey -MockWith {$mockGetItem}
                }

                It 'Should return a RefreshRequired value of 1' {
                    $getTargetResourceResult = Get-TargetResource @defaultParameters
                    $getTargetResourceResult.Path | Should -Be $mockGetItem.Name
                    $getTargetResourceResult.RefreshRequiredKey | Should -Be $mockGetItem.RefreshRequired

                    Assert-MockCalled -CommandName Read-GPRefreshRegistryKey -Exactly -Times 1 -Scope It
                }
            }
        }

        Describe 'MSFT_RefreshRegistryPolicy\Set-TargetResource' -Tag 'Set' {
            BeforeEach {
                Mock -CommandName Invoke-Command -MockWith {
                    "For synchronous foreground user policy application, a relogon is required.
                     For synchronous foreground computer policy application, a restart is required.
                     OK to restart? (Y/N)
                     OK to log off? (Y/N)"
                }
                Mock -CommandName Remove-Item
                Mock -CommandName Write-Warning
            }

            Context 'When the system is not in the desired state' {
                It 'Should should call Invoke-Command' {
                    { Set-TargetResource @defaultParameters } | Should -Not -Throw
                    Assert-MockCalled -CommandName Invoke-Command -Exactly -Times 1 -Scope It
                    Assert-MockCalled -CommandName Remove-Item -Exactly -Times 1 -Scope It
                    Assert-MockCalled -CommandName Write-Warning -Exactly -Times 1 -Scope It
                }
            }
        }

        Describe 'MSFT_RefreshRegistryPolicy\Test-TargetResource' -Tag 'Test' {
            BeforeAll {
                $mockGetTargetResource = @{
                        Name                = 'Test'
                        Path                = 'HKLM:\SOFTWARE\Microsoft\GPRegistryPolicy'
                        RefreshRequiredKey  = 0
                }
            }
            Context 'When the system is in the desired state' {
                BeforeEach {
                    Mock -CommandName Get-TargetResource -MockWith {$mockGetTargetResource}
                }

                It 'Should return $true' {
                    $testTargetResourceResult = Test-TargetResource @defaultParameters
                    $testTargetResourceResult | Should -BeTrue
                }
            }

            Context 'When the system is not in the desired state' {
                BeforeEach {
                    $mockGetTargetResourceFalse = $mockGetTargetResource.Clone()
                    $mockGetTargetResourceFalse.RefreshRequiredKey = 1
                    Mock -CommandName Get-TargetResource -MockWith {$mockGetTargetResourceFalse}
                }

                It 'Should return $false' {
                    $testTargetResourceResult = Test-TargetResource @defaultParameters
                    $testTargetResourceResult | Should -BeFalse
                }
            }
        }

        Describe 'MSFT_RefreshRegistryPolicy\Read-GPRefreshRegistryKey' -Tag 'ReadGPRefreshRegistryKey' {
            Context 'When the registry key is Present' {
                Mock -CommandName Get-Item -MockWith {
                    return @{
                        Name = 'RefreshRequired'
                    }
                }
                Mock -CommandName Get-ItemProperty -MockWith {
                    return @{
                        RefreshRequired = 1
                    }
                }

                It 'Should return the correct values' {
                    $results = Read-GPRefreshRegistryKey
                    $results.Path | Should -Be 'RefreshRequired'
                    $results.Value | Should -Be 1
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}


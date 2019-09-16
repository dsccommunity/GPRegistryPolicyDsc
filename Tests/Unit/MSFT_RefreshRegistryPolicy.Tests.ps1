
#region HEADER
$script:dscModuleName = 'GPRegistryPolicyDsc'
$script:dscResourceName = 'MSFT_RefreshRegistryPolicy'

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
        Describe 'MSFT_RefreshRegistryPolicy\Get-TargetResource' -Tag 'Get' {
            BeforeAll {
                $mockReadRefreshKey = @{
                    Path = 'HKLM:\SOFTWARE\Microsoft\GPRegistryPolicy'
                    Value = 1
                }
            }

            Context 'When the system is in the desired state' {
                BeforeEach {
                    Mock -CommandName Read-GPRefreshRegistryKey
                }

                It 'Should return the proper registry key property values' {
                    $getTargetResourceResult = Get-TargetResource -Name 'Test'
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
                    $getTargetResourceResult = Get-TargetResource -Name 'Test'
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
                    { Set-TargetResource -Name 'Test' } | Should -Not -Throw
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
                    $testTargetResourceResult = Test-TargetResource -Name 'Test'
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
                    $testTargetResourceResult = Test-TargetResource -Name 'Test'
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
                        Value = 1
                    }
                }

                It 'Should return the correct values' {
                    $results = Read-GPRefreshRegistryKey
                    $results.Name | Should -Be 'RefreshRequired'
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


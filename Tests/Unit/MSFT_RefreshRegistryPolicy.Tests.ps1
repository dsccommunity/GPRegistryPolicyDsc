
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
                $mockGetItem = @{
                    Name = 'HKLM:\SOFTWARE\Microsoft\GPRegistryPolicy'
                    RefreshRequired = 1
                }
            }

            Context 'When the system is in the desired state' {
                BeforeEach {
                    Mock -CommandName Get-Item -MockWith {}
                }

                It 'Should return the proper registry key property values' {
                    $getTargetResourceResult = Get-TargetResource -Name 'Test'
                    $getTargetResourceResult.Path | Should -Be $null
                    $getTargetResourceResult.RefreshRequiredKey | Should -Be $null

                    Assert-MockCalled -CommandName Get-Item -Exactly -Times 1 -Scope It
                }

            }

            Context 'When the system is not in the desired state' {
                BeforeEach {
                    Mock -CommandName Get-Item -MockWith {$mockGetItem}
                    Mock -CommandName Get-ItemProperty -MockWith {$mockGetItem}
                }

                It 'Should return a RefreshRequired value of 1' {
                    $getTargetResourceResult = Get-TargetResource -Name 'Test'
                    $getTargetResourceResult.Path | Should -Be $mockGetItem.Name
                    $getTargetResourceResult.RefreshRequiredKey | Should -Be $mockGetItem.RefreshRequired

                    Assert-MockCalled -CommandName Get-Item -Exactly -Times 1 -Scope It
                    Assert-MockCalled -CommandName Get-ItemProperty -Exactly -Times 1 -Scope It
                }
            }
        }

        Describe 'MSFT_RefreshRegistryPolicy\Set-TargetResource' -Tag 'Set' {
            BeforeEach {
                Mock -CommandName Invoke-Command
                Mock -CommandName Remove-Item
            }

            Context 'When the system is not in the desired state' {
                It 'Should should call Invoke-Command' {
                    Set-TargetResource -Name 'Test'
                    Assert-MockCalled -CommandName Invoke-Command -Exactly -Times 1 -Scope It
                    Assert-MockCalled -CommandName Remove-Item -Exactly -Times 1 -Scope It
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
                    $testTargetResourceResult | Should -Be $true
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
                    $testTargetResourceResult | Should -Be $false
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}


# Import the GPRegistryPolicyFileParser module to test
$script:resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$script:modulesFolderPath = Join-Path -Path $script:resourceModulePath -ChildPath 'Modules\GPRegistryPolicyFileParser'

Import-Module -Name (Join-Path -Path $script:modulesFolderPath -ChildPath 'GPRegistryPolicyFileParser.psm1') -Force


InModuleScope 'GPRegistryPolicyFileParser' {
    Describe 'Format-MultiStringValue' -Tag 'FormatMultiStringValue' {
        BeforeAll {
            $predictedResult = @(
                'First'
                'Second'
                'Third'
            )
        }

        Context 'When input contains null terminators' {
            BeforeEach {
                $stringInput = "First`0Second`0Third`0`0"
            }

            It 'Should return the proper registry key property values' {
                
                $result = Format-MultiStringValue -MultiStringValue $stringInput
                $result | Should -Be $predictedResult
            }
        }

        Context 'When input does not contain null terminators' {
            BeforeEach {
                $stringInput = "First Second Third"
            }

            It 'Should return the proper registry key property values' {
                $result = Format-MultiStringValue -MultiStringValue $stringInput
                $result | Should -Be $predictedResult
            }
        }
    }

    Describe 'Get-ByteStreamParameter' -Tag 'GetByteStreamParameter' {
        Context 'When on Windows PowerShell' {
            BeforeEach {
                $predictedResult = @{
                    Encoding = 'Byte'
                }

                $PSVersionTable.PSEdition = 'Desktop'
                $key = $predictedResult.Keys
            }

            It 'Should return Encoding equals Byte' {
                $result = Get-ByteStreamParameter

                $result.$key | Should -Be $predictedResult.$key
            }
        }

        Context 'When on PowerShell Core' {
            BeforeEach {
                $predictedResult = @{
                    AsByteStream = $true
                }

                $PSVersionTable.PSEdition = 'Core'
                $key = $predictedResult.Keys
            }

            It 'Should return Encoding equals Byte' {
                $result = Get-ByteStreamParameter

                $result.$key | Should -Be $predictedResult.$key
            }
        }
    }

    Describe 'Convert-StringToInt' -Tag 'ConvertStringToInt' {
        BeforeEach {
            $predictedResult = ([int][char]'s') + ([int][char]'t' -shl 8)
            $shouldBeInt32 = '1234'
            $shouldBeInt64 = '12345'
        }

        It 'Should return the correct value' {
            $result = Convert-StringToInt -ValueString 'st'
            $result | Should -Be $predictedResult
        }

        It ' Should return the correct int32' {
            $result = Convert-StringToInt -ValueString $shouldBeInt32
            $result | Should -BeOfType [int32]
        }

        It ' Should return the correct int32' {
            $result = Convert-StringToInt -ValueString $shouldBeInt64
            $result | Should -BeOfType [int64]
        }
    }

    Describe 'Remove-GPRegistryPolicyFileEntry' -Tag 'RemoveGPRegistryPolicyFileEntry' {
        BeforeEach {
            $polFilePath = 'TestDrive:\Registry.pol'
            $newRegistryPolicyParameters = @{
                Key        = 'SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
                ValueName  = 'ValueName1'
                ValueData  = 0
                ValueType  = 'REG_DWORD'
            }

            $entryToRemoveParameters = $newRegistryPolicyParameters.Clone()
            $entryToRemoveParameters.ValueName = 'ValueName2'
            # create a pol file and add entries to test against
            New-GPRegistryPolicyFile -Path $polFilePath
            $predictedResult = New-GPRegistryPolicy @newRegistryPolicyParameters
            $entryToRemove = New-GPRegistryPolicy @entryToRemoveParameters

            Set-GPRegistryPolicyFileEntry -Path $polFilePath -RegistryPolicy $predictedResult
            Set-GPRegistryPolicyFileEntry -Path $polFilePath -RegistryPolicy $entryToRemove
        }

        It 'Should contain the policy to be removed' {
            $result = Read-GPRegistryPolicyFile -Path $polFilePath |
                Where-Object -FilterScript {$PSItem.ValueName -eq $entryToRemoveParameters.ValueName}

            $result.ValueName | Should -Be $entryToRemoveParameters.ValueName
        }

        It 'Should remove the entryToRemove' {
            Remove-GPRegistryPolicyFileEntry -Path $polFilePath -RegistryPolicy $entryToRemove
            $result = Read-GPRegistryPolicyFile -Path $polFilePath

            $result.ValueName | Should -Be $newRegistryPolicyParameters.ValueName
        }
    }

    Describe 'Read-GPRegistryPolicyFile' -Tag 'ReadGPRegistryPolicyFile' {
        BeforeAll {
            $registryEntryParameters = @{
                Key        = 'SYSTEM\CurrentControlSet\PesterTest'
                ValueName  = 'ValueName1'
                ValueData  = 'Value1','Value2','Value3'
                ValueType  = 'REG_MULTI_SZ'
            }

            $polFilePath = 'TestDrive:\Registry.pol'
            New-GPRegistryPolicyFile -Path $polFilePath
        }

        Context 'When ValueType is mutiString' {
            BeforeEach {
                $registryPolicyEntry = New-GPRegistryPolicy @registryEntryParameters
                Set-GPRegistryPolicyFileEntry -Path $polFilePath -RegistryPolicy $registryPolicyEntry
            }

            It 'Should return the correct mutiString results' {
                $results = Read-GPRegistryPolicyFile -Path $polFilePath

                $results.Key       | Should -Be $registryPolicyEntry.Key
                $results.ValueName | Should -Be $registryPolicyEntry.ValueName
                $results.ValueData | Should -Be $registryPolicyEntry.ValueData
                $results.ValueType | Should -Be $registryPolicyEntry.ValueType
            }
        }

        Context 'When ValueType is Binary' {
            BeforeEach {
                $registryEntryParameters = $registryEntryParameters.Clone()
                $registryEntryParameters.ValueType = 'REG_BINARY'
                $registryEntryParameters.ValueData = '0010100010'
                $registryPolicyEntry = New-GPRegistryPolicy @registryEntryParameters
                Set-GPRegistryPolicyFileEntry -Path $polFilePath -RegistryPolicy $registryPolicyEntry
            }

            It 'Should return the correct Binary results' {
                $results = Read-GPRegistryPolicyFile -Path $polFilePath
                $binaryReference = [System.Text.Encoding]::UTF8.GetBytes($registryEntryParameters.ValueData)
                $binaryResults = $results.ValueData | Where-Object -FilterScript {$PSItem -ne 0}

                $results.Key       | Should -Be $registryPolicyEntry.Key
                $results.ValueName | Should -Be $registryPolicyEntry.ValueName
                $binaryReference | Should -Be $binaryResults
                $results.ValueType | Should -Be $registryPolicyEntry.ValueType
            }
        }

        Context 'When ValueType is Dword' {
            BeforeEach {
                $registryPolicyEntry = New-GPRegistryPolicy @registryEntryParameters
                Set-GPRegistryPolicyFileEntry -Path $polFilePath -RegistryPolicy $registryPolicyEntry
            }

            It 'Should return the correct Dword results' {
                $results = Read-GPRegistryPolicyFile -Path $polFilePath

                $results.Key       | Should -Be $registryPolicyEntry.Key
                $results.ValueName | Should -Be $registryPolicyEntry.ValueName
                $results.ValueData | Should -Be $registryPolicyEntry.ValueData
                $results.ValueType | Should -Be $registryPolicyEntry.ValueType
            }
        }

        Context 'When ValueType is ExpandString' {
            BeforeEach {
                $registryPolicyEntry = New-GPRegistryPolicy @registryEntryParameters
                Set-GPRegistryPolicyFileEntry -Path $polFilePath -RegistryPolicy $registryPolicyEntry
            }

            It 'Should return the correct ExpandString results' {
                $results = Read-GPRegistryPolicyFile -Path $polFilePath

                $results.Key       | Should -Be $registryPolicyEntry.Key
                $results.ValueName | Should -Be $registryPolicyEntry.ValueName
                $results.ValueData | Should -Be $registryPolicyEntry.ValueData
                $results.ValueType | Should -Be $registryPolicyEntry.ValueType
            }
        }

        Context 'When ValueType is Qword' {
            BeforeEach {
                $registryPolicyEntry = New-GPRegistryPolicy @registryEntryParameters
                Set-GPRegistryPolicyFileEntry -Path $polFilePath -RegistryPolicy $registryPolicyEntry
            }

            It 'Should return the correct Qword results' {
                $results = Read-GPRegistryPolicyFile -Path $polFilePath

                $results.Key       | Should -Be $registryPolicyEntry.Key
                $results.ValueName | Should -Be $registryPolicyEntry.ValueName
                $results.ValueData | Should -Be $registryPolicyEntry.ValueData
                $results.ValueType | Should -Be $registryPolicyEntry.ValueType
            }
        }

        Context 'When ValueType is String' {
            BeforeEach {
                $registryPolicyEntry = New-GPRegistryPolicy @registryEntryParameters
                Set-GPRegistryPolicyFileEntry -Path $polFilePath -RegistryPolicy $registryPolicyEntry
            }

            It 'Should return the correct String results' {
                $results = Read-GPRegistryPolicyFile -Path $polFilePath

                $results.Key       | Should -Be $registryPolicyEntry.Key
                $results.ValueName | Should -Be $registryPolicyEntry.ValueName
                $results.ValueData | Should -Be $registryPolicyEntry.ValueData
                $results.ValueType | Should -Be $registryPolicyEntry.ValueType
            }
        }
    }
}

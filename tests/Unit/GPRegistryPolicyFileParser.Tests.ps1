#region HEADER
$script:projectPath = "$PSScriptRoot\..\.." | Convert-Path
$script:projectName = (Get-ChildItem -Path "$script:projectPath\*\*.psd1" | Where-Object -FilterScript {
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest -Path $_.FullName -ErrorAction Stop } catch { $false })
    }).BaseName

$script:parentModule = Get-Module -Name $script:projectName -ListAvailable | Select-Object -First 1
$script:subModulesFolder = Join-Path -Path $script:parentModule.ModuleBase -ChildPath 'Modules'
Remove-Module -Name $script:parentModule -Force -ErrorAction 'SilentlyContinue'

$script:subModuleName = (Split-Path -Path $PSCommandPath -Leaf) -replace '\.Tests.ps1'
$script:subModuleFile = Join-Path -Path $script:subModulesFolder -ChildPath "$($script:subModuleName)"

Import-Module $script:subModuleFile -Force -ErrorAction 'Stop'
#endregion HEADER

InModuleScope $script:subModuleName {
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
        BeforeAll {
            $powerShellEdition = $PSVersionTable.PSEdition
        }
        AfterEach {
            $PSVersionTable.PSEdition = $powerShellEdition
        }
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

        It 'Should return the correct type int32' {
            $result = Convert-StringToInt -ValueString $shouldBeInt32
            $result | Should -BeOfType [int32]
        }

        It 'Should return the correct type int64' {
            $result = Convert-StringToInt -ValueString $shouldBeInt64
            $result | Should -BeOfType [int64]
        }
    }

    Describe 'Remove-GPRegistryPolicyFileEntry' -Tag 'RemoveGPRegistryPolicyFileEntry' {
        BeforeAll {
            $polFilePath = 'TestDrive:\Registry.pol'
            $newRegistryPolicyParameters = @{
                Key        = 'SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
                ValueName  = 'ValueName1'
                ValueData  = 0
                ValueType  = 'REG_DWORD'
            }
        }

        Context 'Removing a policy from a pol file' {
            BeforeAll {
                $entryToRemoveParameters = $newRegistryPolicyParameters.Clone()
                $entryToRemoveParameters.ValueName = 'ValueName2'
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

        Context 'When ValueType is multiString' {
            BeforeEach {
                $registryPolicyEntry = New-GPRegistryPolicy @registryEntryParameters
                Set-GPRegistryPolicyFileEntry -Path $polFilePath -RegistryPolicy $registryPolicyEntry
            }

            It 'Should return the correct multiString results' {
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
                $registryEntryParameters = $registryEntryParameters.Clone()
                $registryEntryParameters.ValueType = 'REG_DWORD'
                $registryEntryParameters.ValueData = '1024'
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
                $registryEntryParameters = $registryEntryParameters.Clone()
                $registryEntryParameters.ValueType = 'REG_EXPAND_SZ'
                $registryEntryParameters.ValueData = 'ThisIsAnExpandString'
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
                $registryEntryParameters = $registryEntryParameters.Clone()
                $registryEntryParameters.ValueType = 'REG_QWORD'
                $registryEntryParameters.ValueData = '1024'
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
                $registryEntryParameters = $registryEntryParameters.Clone()
                $registryEntryParameters.ValueType = 'REG_SZ'
                $registryEntryParameters.ValueData = 'ThisIsAString'
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

    Describe 'New-GPRegistryPolicy' -Tag 'NewGPRegistryPolicy' {
        BeforeAll {
            $registryEntryParameters = @{
                Key        = 'SYSTEM\CurrentControlSet\PesterTest'
                ValueName  = 'ValueName1'
                ValueData  = 'Value1'
                ValueType  = 'REG_SZ'
            }
        }

        Context 'Validate proper type is returned' {
            BeforeEach {
                $registryPolicyEntry = New-GPRegistryPolicy @registryEntryParameters
            }

            It 'Should return type of GPRegistryPolicy' {
                $registryPolicyEntry -is [GPRegistryPolicy] | Should -BeTrue
                $registryPolicyEntry.Key | Should -Be $registryEntryParameters.Key
                $registryPolicyEntry.ValueName | Should -Be $registryEntryParameters.ValueName
                $registryPolicyEntry.ValueData | Should -Be $registryEntryParameters.ValueData
                $registryPolicyEntry.ValueType | Should -Be $registryEntryParameters.ValueType
            }
        }
    }

    Describe 'New-GPRegistryPolicyFile' -Tag 'NewGPRegistryPolicyFile' {
        BeforeAll {
            $polFilePath = 'TestDrive:\Registry.pol'
        }

        Context 'Creating a new pol file' {
            BeforeEach {
                New-GPRegistryPolicyFile -Path $polFilePath
            }

            It 'Should have the correct file heading' {
                $fileHeader = Format-Hex -Path $polFilePath | Select-Object -First 1
                $fileHeader -cmatch 'PReg' | Should -BeTrue
            }
        }
    }

    Describe 'Set-GPRegistryPolicyFileEntry' -Tag 'SetGPRegistryPolicyFileEntry' {
        BeforeAll {
            $polFilePath = 'TestDrive:\Registry.pol'

            $newRegistryPolicyParameters = @{
                Key        = 'SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
                ValueName  = 'ValueName1'
                ValueData  = 0
                ValueType  = 'REG_DWORD'
            }
        }

        Context 'Adding an entry to a pol file' {
            BeforeEach {
                New-GPRegistryPolicyFile -Path $polFilePath
                $registryPolicyToAdd = New-GPRegistryPolicy @newRegistryPolicyParameters
            }

            It 'Should add the registry policy to the pol file' {
                Set-GPRegistryPolicyFileEntry -Path $polFilePath -RegistryPolicy $registryPolicyToAdd
                $result = Read-GPRegistryPolicyFile -Path $polFilePath

                $result.Key       | Should -Be $registryPolicyToAdd.Key
                $result.ValueName | Should -Be $registryPolicyToAdd.ValueName
                $result.ValueData | Should -Be $registryPolicyToAdd.ValueData
                $result.ValueType | Should -Be $registryPolicyToAdd.ValueType
            }
        }
    }

    Describe 'New-GPRegistrySettingsEntry' -Tag 'NewGPRegistrySettingsEntry' {
        BeforeAll {
            $registryPolicyDefaultParameters = @{
                Key        = 'SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
                ValueName  = 'ValueName1'
                ValueData  = ''
                ValueType  = ''
            }
        }

        Context 'When dataType is a string' {
            BeforeEach {
                $newRegistryPolicyParameters = $registryPolicyDefaultParameters.Clone()
            }

            It 'Should return the correct STRING valueData result' {
                $newRegistryPolicyParameters.ValueData = 'String'
                $newRegistryPolicyParameters.ValueType = 'REG_SZ'
                $newRegistryPolicy = New-GPRegistryPolicy @newRegistryPolicyParameters
                $result = New-GPRegistrySettingsEntry -RegistryPolicy $newRegistryPolicy
                $resultString = (([System.Text.Encoding]::unicode.GetString($result) -replace '\[|\]') -split ';')[-1]
                $resultString | Should -Be $newRegistryPolicyParameters.ValueData
            }

            It 'Should return the correct BINARY valueData result' {
                $newRegistryPolicyParameters.ValueData = '0'
                $newRegistryPolicyParameters.ValueType = 'REG_BINARY'
                $newRegistryPolicy = New-GPRegistryPolicy @newRegistryPolicyParameters
                $result = New-GPRegistrySettingsEntry -RegistryPolicy $newRegistryPolicy
                $resultString = (([System.Text.Encoding]::unicode.GetString($result) -replace '\[|\]') -split ';')[-1]
                $resultString | Should -Be $newRegistryPolicyParameters.ValueData
            }

            It 'Should return the correct DWORD valueData result' {
                $newRegistryPolicyParameters.ValueData = '1024'
                $newRegistryPolicyParameters.ValueType = 'REG_DWORD'
                $newRegistryPolicy = New-GPRegistryPolicy @newRegistryPolicyParameters
                $result = New-GPRegistrySettingsEntry -RegistryPolicy $newRegistryPolicy
                $resultString = (([System.Text.Encoding]::unicode.GetString($result) -replace '\[|\]') -split ';')[-1]
                Convert-StringToInt -ValueString $resultString | Should -Be $newRegistryPolicyParameters.ValueData
            }

            It 'Should return the correct QWORD valueData result' {
                $newRegistryPolicyParameters.ValueData = '10245'
                $newRegistryPolicyParameters.ValueType = 'REG_QWORD'
                $newRegistryPolicy = New-GPRegistryPolicy @newRegistryPolicyParameters
                $result = New-GPRegistrySettingsEntry -RegistryPolicy $newRegistryPolicy
                $resultString = (([System.Text.Encoding]::unicode.GetString($result) -replace '\[|\]') -split ';')[-1]
                Convert-StringToInt -ValueString $resultString | Should -Be $newRegistryPolicyParameters.ValueData
            }
        }
    }

    Describe 'Assert-Condition' -Tag 'AssertCondition' {
        BeforeAll {
                $message   = 'ErrorOccured'
        }

        Context 'When condition is TRUE' {
            It 'Should not throw' {
                {Assert-Condition -Condition $true -ErrorMessage $message} | Should -Not -Throw
            }
        }

        Context 'When condition is FALSE' {
            It 'Should not throw' {
                {Assert-Condition -Condition $false -ErrorMessage $message} | Should -Throw
            }
        }
    }
}

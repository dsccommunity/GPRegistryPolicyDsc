Import-LocalizedData -BindingVariable localizedData -FileName GPRegistryPolicyFileParser.strings.psd1

$script:REGFILE_SIGNATURE = 0x67655250 # PRef
$script:REGISTRY_FILE_VERSION = 0x00000001 #Initially defined as 1, then incremented each time the file format is changed.

<#
    .SYNOPSIS
        Reads and parses a .pol file.

    .DESCRIPTION
        Reads a .pol file, parses it and returns an array of Group Policy registry settings.

    .PARAMETER Path
        Specifies the path to the .pol file.

    .EXAMPLE
        C:\PS> Parse-PolFile -Path "C:\Registry.pol"
#>
function Read-GPRegistryPolicyFile
{
    [OutputType([array])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true,Position=0)]
        [System.String]
        $Path
    )

    [Array] $registryPolicies = @()
    $index = 0

    if ($PSVersionTable.Edition -eq 'Core')
    {
        [string] $policyContents = Get-Content $Path -Raw
        [byte[]] $policyContentInBytes = Get-Content $Path -Raw -AsByteStream
    }
    else
    {
        [string] $policyContents = Get-Content $Path -Raw
        [byte[]] $policyContentInBytes = Get-Content $Path -Raw -Encoding Byte
    }

    # 4 bytes are the signature PReg
    $signature = [System.Text.Encoding]::ASCII.GetString($policyContents[0..3])
    $index += 4
    Assert-Condition -Condition ($signature -eq 'PReg') -ErrorMessage ($script:localizedData.InvalidHeader -f $Path)

    # 4 bytes are the version
    $version = [System.BitConverter]::ToInt32($policyContentInBytes, 4)
    $index += 4
    Assert-Condition -Condition ($version -eq 1) -ErrorMessage ($script:localizedData.InvalidVersion -f $Path)

    # Start processing at byte 8
    while($index -lt $policyContents.Length - 2)
    {
        [string]$key = $null
        [string]$valueName = $null
        [int]$valueType = $null
        [int]$valueLength = $null

        [object]$value = $null

        # Next UNICODE character should be a [
        $leftbracket = [System.BitConverter]::ToChar($policyContentInBytes, $index)
        Assert-Condition -Condition ($leftbracket -eq '[') -ErrorMessage $script:localizedData.MissingOpeningBracket
        $index += 2

        # Next UNICODE string will continue until the ; less the null terminator
        $semicolon = $policyContents.IndexOf(";", $index)
        Assert-Condition -Condition ($semicolon -ge 0) -ErrorMessage $script:localizedData.MissingTrailingSemicolonAfterKey
        $Key = [System.Text.Encoding]::UNICODE.GetString($policyContents[($index)..($semicolon-3)]) # -3 to exclude the null termination and ';' characters
        $index = $semicolon + 2

        # Next UNICODE string will continue until the ; less the null terminator
        $semicolon = $policyContents.IndexOf(";", $index)
        Assert-Condition -Condition ($semicolon -ge 0) -ErrorMessage $script:localizedData.MissingTrailingSemicolonAfterName
        $valueName = [System.Text.Encoding]::UNICODE.GetString($policyContents[($index)..($semicolon-3)]) # -3 to exclude the null termination and ';' characters
        $index = $semicolon + 2

        # Next DWORD will continue until the ;
        $semicolon = $index + 4 # DWORD Size
        Assert-Condition -Condition ([System.BitConverter]::ToChar($policyContentInBytes, $semicolon) -eq ';') -ErrorMessage $script:localizedData.MissingTrailingSemicolonAfterType
        $valueType = [System.BitConverter]::ToInt32($policyContentInBytes, $index)
        $index = $semicolon + 2 # Skip ';'

        # Next DWORD will continue until the ;
        $semicolon = $index + 4 # DWORD Size
        Assert-Condition -Condition ([System.BitConverter]::ToChar($policyContentInBytes, $semicolon) -eq ';') -ErrorMessage $script:localizedData.MissingTrailingSemicolonAfterLength
        $valueLength = Convert-StringToInt -ValueString $policyContentInBytes[$index..($index+3)]
        $index = $semicolon + 2 # Skip ';'

        if ($valueLength -gt 0)
        {
            <#
                String types less the null terminator for REG_SZ and REG_EXPAND_SZ
                REG_SZ: string type (ASCII)
            #>
            if ($valueType -eq [RegType]::REG_SZ)
            {
                # -3 to exclude the null termination and ']' characters
                [string] $value = [System.Text.Encoding]::UNICODE.GetString($policyContents[($index)..($index+$valueLength-3)])
                $index += $valueLength
            }

            # REG_EXPAND_SZ: string, includes %ENVVAR% (expanded by caller) (ASCII)
            if ($valueType -eq [RegType]::REG_EXPAND_SZ)
            {
                # -3 to exclude the null termination and ']' characters
                [string] $value = [System.Text.Encoding]::UNICODE.GetString($policyContents[($index)..($index+$valueLength-3)])
                $index += $valueLength
            }

            <#
                For REG_MULTI_SZ leave the last null terminator
                REG_MULTI_SZ: multiple strings, delimited by \0, terminated by \0\0 (ASCII)
            #>
            if ($valueType -eq [RegType]::REG_MULTI_SZ)
            {
                [string] $value = [System.Text.Encoding]::UNICODE.GetString($policyContents[($index)..($index+$valueLength-3)])
                $index += $valueLength
            }

            # REG_BINARY: binary values
            if ($valueType -eq [RegType]::REG_BINARY)
            {
                [byte[]] $value = $policyContentInBytes[($index)..($index+$valueLength-1)]
                $index += $valueLength
            }
        }

        # DWORD: (4 bytes) in little endian format
        if ($valueType -eq [RegType]::REG_DWORD)
        {
            $value = Convert-StringToInt -ValueString $policyContentInBytes[$index..($index+3)]
            $index += 4
        }

        # QWORD: (8 bytes) in little endian format
        if ($valueType -eq [RegType]::REG_QWORD)
        {
            $value = Convert-StringToInt -ValueString $policyContentInBytes[$index..($index+7)]
            $index += 8
        }

        # Next UNICODE character should be a ] Skip over null data value if one exists
        $rightbracket = $policyContents.IndexOf("]", $index)
        Assert-Condition -Condition ($rightbracket -ge 0) -ErrorMessage $script:localizedData.MissingClosingBracket
        $index = $rightbracket + 2

        $entry = New-GPRegistryPolicy -Key $Key -ValueName $valueName -ValueType $valueType -ValueLength $valueLength -ValueData $value

        $registryPolicies += $entry
    }

    return $registryPolicies
}

<#
    .SYNOPSIS
        Asserts a condition and throws error if condition fails.
    
    .PARAMETER Condition
        Specifies the condition to test.

    .PARAMETER ErrorMessage
        Specifies the error message to throw if the assertion fails.
#>
function Assert-Condition
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [System.Boolean]
        $Condition,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ErrorMessage
    )

    if ($Condition -eq $false)
    {
        throw $ErrorMessage
    }
}

<#
    .SYNOPSIS
        Create a GPRegistryPolicy Object

    .PARAMETER Key
        Indicates the path of the registry key for which you want to ensure a specific state. This path must include the hive.

    .PARAMETER ValueName
        Indicates the name of the registry value.

    .PARAMETER ValueData
        The data for the registry value.

    .PARAMETER ValueType
        Indicates the type of the value.

    .PARAMETER ValueLength
        Specifies the size of the policy.
#>
function New-GPRegistryPolicy
{
    [CmdletBinding()]
    [OutputType([GPRegistryPolicy])]
    param
    (
        [Parameter(Mandatory=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Key,
        
        [Parameter(Position=1)]
        [string]
        $ValueName = $null,
        
        [Parameter(Position=2)]
        [RegType]
        $ValueType = [RegType]::REG_NONE,
        
        [Parameter(Position=3)]
        [string]
        $ValueLength = $null,
        
        [Parameter(Position=4)]
        [object]
        $ValueData = $null
    )

    $Policy = [GPRegistryPolicy]::new($Key, $ValueName, $ValueType, $ValueLength, $ValueData)

    return $Policy
}

<# 
    .SYNOPSIS
        Creates a file and initializes it with Group Policy Registry file format signature.

    .DESCRIPTION
        Creates a file and initializes it with Group Policy Registry file format signature.

    .PARAMETER Path
        Path to a file (.pol extension).
#>
function New-GPRegistryPolicyFile
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $Path
    )

    $null = Remove-Item -Path $Path -Force -ErrorAction SilentlyContinue

    Write-Verbose -Message ($script:localizedData.CreateNewPolFile -f $polFilePath)

    $null = New-Item -Path $Path -Force -ErrorAction Stop

    $encodingParameter = Get-ByteStreamParameter
    [System.BitConverter]::GetBytes($script:REGFILE_SIGNATURE) | Add-Content -Path $Path @encodingParameter
    [System.BitConverter]::GetBytes($script:REGISTRY_FILE_VERSION) | Add-Content -Path $Path @encodingParameter
}

<#
.SYNOPSIS
    Creates a .pol file entry byte array from a GPRegistryPolicy instance.

.DESCRIPTION
    Creates a .pol file entry byte array from a GPRegistryPolicy instance. This entry can be written in a .pol file later.

.PARAMETER RegistryPolicy
    Specifies the registry policy entry.
#>
function New-GPRegistrySettingsEntry
{
    [CmdletBinding()]
    [OutputType([byte[]])]
    param
    (
        [Parameter(Mandatory=$true)]
        [GPRegistryPolicy[]]
        $RegistryPolicy
    )

    [byte[]] $entry = @()
    foreach ($policy in $RegistryPolicy)
    {
        # openning bracket
        $entry += [System.Text.Encoding]::Unicode.GetBytes('[')
        $entry += [System.Text.Encoding]::Unicode.GetBytes($policy.Key + "`0")

        # semicolon as delimiter
        $entry += [System.Text.Encoding]::Unicode.GetBytes(';')
        $entry += [System.Text.Encoding]::Unicode.GetBytes($policy.ValueName + "`0")

        # semicolon as delimiter
        $entry += [System.Text.Encoding]::Unicode.GetBytes(';')
        $entry += [System.BitConverter]::GetBytes([Int32]$policy.ValueType)

        # semicolon as delimiter
        $entry += [System.Text.Encoding]::Unicode.GetBytes(';')

        # get data bytes then compute byte size based on data and type
        switch ($policy.ValueType)
        {
            {@([RegType]::REG_SZ, [RegType]::REG_EXPAND_SZ, [RegType]::REG_MULTI_SZ) -contains $_}
            {
                $dataBytes = [System.Text.Encoding]::Unicode.GetBytes($policy.ValueData + "`0")
                $dataSize = $dataBytes.Count
            }

            ([RegType]::REG_BINARY)
            {
                $dataBytes = [System.Text.Encoding]::Unicode.GetBytes($policy.ValueData)
                $dataSize = $dataBytes.Count
            }

            ([RegType]::REG_DWORD)
            {
                $dataBytes = [System.BitConverter]::GetBytes([Int32]$policy.ValueData)
                $dataSize = 4
            }

            ([RegType]::REG_QWORD)
            {
                $dataBytes = [System.BitConverter]::GetBytes([Int64]$policy.ValueData)
                $dataSize = 8
            }

            default
            {
                $dataBytes = [System.Text.Encoding]::Unicode.GetBytes("")
                $dataSize = 0
            }
        }

        $entry += [System.BitConverter]::GetBytes($dataSize)

        # semicolon as delimiter
        $entry += [System.Text.Encoding]::Unicode.GetBytes(';')
        $entry += $dataBytes

        # closing bracket
        $entry += [System.Text.Encoding]::Unicode.GetBytes(']')
    }
    return $entry
}

<#
    .SYNOPSIS
        Replaces or adds a registry policy to a .pol file.

    .PARAMETER Path
        Path to a file (.pol extension).

    .PARAMETER RegistryPolicy
        Specifies the GPRegistryPolicy object to add to the .pol file.
#>
function Set-GPRegistryPolicyFileEntry
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $Path,

        [Parameter(Mandatory=$true)]
        [GPRegistryPolicy]
        $RegistryPolicy
    )

    $desiredEntries = @()
    $currentPolicies = Read-GPRegistryPolicyFile -Path $Path

    # first check if a entry exists with same key
    $matchingEntries = $currentPolicies | Where-Object -FilterScript {$PSItem.Key -eq $RegistryPolicy.Key -and $PSItem.ValueName -eq $RegistryPolicy.ValueName}

    # if found compare it current policies to validate no duplicate entries
    if ($matchingEntries)
    {
        # compare value data
        foreach ($policy in $matchingEntries)
        {
            if ($policy.ValueData -eq $RegistryPolicy.ValueData)
            {
                Write-Verbose -Message ($script:localizedData.GPRegistryPolicyExists -f $policy.Key, $policy.ValeName, $policy.ValueData)
                return
            }
        }
    }

    # at this point we have validated the desired entry doesn't match any of the current entries so we can add it to existing entries
    $desiredEntries += $currentPolicies | Where-Object -FilterScript {$PSItem.Key -ne $RegistryPolicy.Key -or $PSItem.ValueName -ne $RegistryPolicy.ValueName}
    $desiredEntries += $RegistryPolicy

    # convert entries to byte array
    $desiredEntriesCollection = New-GPRegistrySettingsEntry -RegistryPolicy $desiredEntries

    New-GPRegistryPolicyFile -Path $Path

    $encodingParameter = Get-ByteStreamParameter
    $desiredEntriesCollection | Add-Content -Path $Path -Force @encodingParameter
}

<#
    .SYNOPSIS
        Removes a registry policy from a .pol file.

    .PARAMETER Path
        Path to a file (.pol extension).

    .PARAMETER RegistryPolicy
        Specifies the GPRegistryPolicy object to remove from the .pol file.
#>
function Remove-GPRegistryPolicyFileEntry
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $Path,

        [Parameter(Mandatory=$true)]
        [GPRegistryPolicy]
        $RegistryPolicy
    )

    # read pol file
    $currentPolicies = Read-GPRegistryPolicyFile -Path $Path

    # first check if a entry exists with same key
    $matchingEntries = $currentPolicies | Where-Object -FilterScript {$PSItem.Key -eq $RegistryPolicy.Key -and $PSItem.ValueName -eq $RegistryPolicy.ValueName}

    # validate entry exists before removing it.
    if ($null -eq $matchingEntries)
    {
        Write-Verbose -Message ($script:localizedData.NoMatchingPolicies)
        return
    }

    $desiredEntries = $currentPolicies | Where-Object -FilterScript {$PSItem.Key -ne $RegistryPolicy.Key -or $PSItem.ValueName -ne $RegistryPolicy.ValueName}

    # write entries to file
    New-GPRegistryPolicyFile -Path $Path

    if ($null -ne $desiredEntries)
    {
        $desiredEntriesCollection = New-GPRegistrySettingsEntry -RegistryPolicy $desiredEntries
        $encodingParameter = Get-ByteStreamParameter
        $desiredEntriesCollection | Add-Content -Path $Path -Force @encodingParameter
    }
}

<#
    .SYNOPSIS
        Converts a sting to it's unicode characters.

    .PARAMETER ValueString
        Specifies the string to convert.
#>
function Convert-StringToInt
{
    [CmdletBinding()]
    [OutputType([int[]])]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.Object[]]
        $ValueString
    )
  
    if ($ValueString.Length -le 4)
    {
        [int32] $result = 0
    }
    elseif ($ValueString.Length -le 8)
    {
        [int64] $result = 0
    }
    else
    {
        throw $script:localizedData.InvalidIntegerSize
    }

    for ($i = $ValueString.Length - 1 ; $i -ge 0 ; $i -= 1)
    {
        $result = $result -shl 8
        $result = $result + ([int][char]$ValueString[$i])
    }

    return $result
}

<#
    .SYNOPSIS
        Retrieves the correct parameter to add a byte stream to a file that will be used by the Add-Content cmdlet.

    .DESCRIPTION
        Retrieves the correct parameter to add a byte stream to a file that will be used by the Add-Content cmdlet.
        Add-Content in PS Core uses AsByteStream switch
        Add-Content in PS 5.1 uses -Encoding Byte
#>
function Get-ByteStreamParameter
{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param ()

    if ($PSVersionTable.PSEdition -eq 'Core')
    {
        return @{AsByteStream = $true}
    }

    return @{Encoding = 'Byte'}
}

Enum RegType
{
    REG_NONE                       = 0 # No value type
    REG_SZ                         = 1 # Unicode null terminated string
    REG_EXPAND_SZ                  = 2 # Unicode null terminated string (with environmental variable references)
    REG_BINARY                     = 3 # Free form binary
    REG_DWORD                      = 4 # 32-bit number
    REG_DWORD_LITTLE_ENDIAN        = 4 # 32-bit number (same as REG_DWORD)
    REG_DWORD_BIG_ENDIAN           = 5 # 32-bit number
    REG_LINK                       = 6 # Symbolic link (Unicode)
    REG_MULTI_SZ                   = 7 # Multiple Unicode strings, delimited by \0, terminated by \0\0
    REG_RESOURCE_LIST              = 8 # Resource list in resource map
    REG_FULL_RESOURCE_DESCRIPTOR   = 9 # Resource list in hardware description
    REG_RESOURCE_REQUIREMENTS_LIST = 10
    REG_QWORD                      = 11 # 64-bit number
    REG_QWORD_LITTLE_ENDIAN        = 11 # 64-bit number (same as REG_QWORD)
}

<#
    .SYNOPSIS
        Class to create and manage registry policy objects
#>
Class GPRegistryPolicy
{
    [string]  $Key
    [string]  $ValueName
    [RegType] $ValueType
    [string]  $ValueLength
    [object]  $ValueData

    GPRegistryPolicy()
    {
        $this.Key         = $Null
        $this.ValueName   = $null
        $this.ValueType   = [RegType]::REG_NONE
        $this.ValueLength = 0
        $this.ValueData   = $Null
    }

    GPRegistryPolicy(
            [string]  $Key,
            [string]  $ValueName,
            [RegType] $ValueType,
            [string]  $ValueLength,
            [object]  $ValueData
        )
    {
        $this.Key         = $Key
        $this.ValueName   = $ValueName
        $this.ValueType   = $ValueType
        $this.ValueLength = $ValueLength
        $this.ValueData   = $ValueData
    }

    [string] GetRegTypeString()
    {
        [string] $result = ""

        switch ($this.ValueType)
        {
            ([RegType]::REG_SZ)        { $Result = "String" }
            ([RegType]::REG_EXPAND_SZ) { $Result = "ExpandString" }
            ([RegType]::REG_BINARY)    { $Result = "Binary" }
            ([RegType]::REG_DWORD)     { $Result = "DWord" }
            ([RegType]::REG_MULTI_SZ)  { $Result = "MultiString" }
            ([RegType]::REG_QWORD)     { $Result = "QWord" }
            default                    { $Result = "" }
        }

        return $result
    }

    static [RegType] GetRegTypeFromString([string] $Type)
    {
        $result = [RegType]::REG_NONE

        switch ($Type)
        {
            "String"       { $result = [RegType]::REG_SZ }
            "ExpandString" { $result = [RegType]::REG_EXPAND_SZ }
            "Binary"       { $result = [RegType]::REG_BINARY }
            "DWord"        { $result = [RegType]::REG_DWORD }
            "MultiString"  { $result = [RegType]::REG_MULTI_SZ }
            "QWord"        { $result = [RegType]::REG_QWORD }
            default        { $result = [RegType]::REG_NONE }
        }

        return $result
    }
}

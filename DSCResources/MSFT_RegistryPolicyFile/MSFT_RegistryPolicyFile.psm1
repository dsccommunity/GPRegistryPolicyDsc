$script:resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$script:modulesFolderPath = Join-Path -Path $script:resourceModulePath -ChildPath 'Modules'

$script:resourceHelperModulePath = Join-Path -Path $script:modulesFolderPath -ChildPath 'DscResource.Common'
Import-Module -Name (Join-Path -Path $script:resourceHelperModulePath -ChildPath 'DscResource.Common.psm1')

$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_Folder'

<#
    .SYNOPSIS
        Returns the current state of the registry policy file.

    .PARAMETER Key
        Indicates the path of the registry key for which you want to ensure a specific state. This path must include the hive.

    .PARAMETER ValueName
        Indicates the name of the registry value.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Key,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ValueName,

        [Parameter(Mandatory=$true)]
        [ValidateSet("ComputerConfiguration","UserConfiguration","Administrators","NonAdministrators","CustomPath","Account")]
        [System.String]
        $TargetType
    )

    # determine pol file path
    $polFilePath = Get-PolFilePath -TargetType $TargetType
    # read the pol file

    $polFileContents = Read-PolFile -Path $polFilePath

    # determine if the key is present or not

    # return the results

    return $getTargetResourceResult
}

<#
    .SYNOPSIS
        Adds or removes the policy key in the pol file.

    .PARAMETER Key
        Indicates the path of the registry key for which you want to ensure a specific state. This path must include the hive.

    .PARAMETER ValueName
        Indicates the name of the registry value.

    .PARAMETER ValueData
        The data for the registry value.

    .PARAMETER ValueType
        Indicates the type of the value.

    .PARAMETER TargetType
        Indicates the target type. This is needed to determine the .pol file path. Supported values are LocalMachine, User, Administrators, NonAdministrators, CustomPath, Account.

    .PARAMETER Ensure
        Specifies the desired state of the registry policy. When set to 'Present', the registry policy will be created. When set to 'Absent', the registry policy will be removed. Default value is 'Present'.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Key,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ValueName,

        [Parameter(Mandatory=$true)]
        [ValidateSet("ComputerConfiguration","UserConfiguration","Administrators","NonAdministrators","CustomPath","Account")]
        [System.String]
        $TargetType,

        [Parameter()]
        [System.String]
        $ValueData,

        [Parameter()]
        [ValidateSet("Binary","Dword","ExpandString","MultiString","Qword","String","None")]
        [System.String]
        $ValueType,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $getTargetResourceParameters = @{
        Path     = $Path
        ReadOnly = $ReadOnly
    }

    $getTargetResourceResult = Get-TargetResource @getTargetResourceParameters

    if ($Ensure -eq 'Present')
    {
        if ($getTargetResourceResult.Ensure -eq 'Absent')
        {
            Write-Verbose -Message (
                $script:localizedData.CreateFolder `
                    -f $Path
            )

            $folder = New-Item -Path $Path -ItemType 'Directory' -Force
        }
        else
        {
            $folder = Get-Item -Path $Path -Force
        }

        Write-Verbose -Message (
            $script:localizedData.SettingProperties `
                -f $Path
        )

        Set-FileAttribute -Folder $folder -Attribute 'ReadOnly' -Enabled $ReadOnly
        Set-FileAttribute -Folder $folder -Attribute 'Hidden' -Enabled $Hidden
    }
    else
    {
        if ($getTargetResourceResult.Ensure -eq 'Present')
        {
            Write-Verbose -Message (
                $script:localizedData.RemoveFolder `
                    -f $Path
            )

            Remove-Item -Path $Path -Force -ErrorAction Stop
        }
    }
}

<#
    .SYNOPSIS
        Tests for the desired state of the policy key in the pol file.

    .PARAMETER Key
        Indicates the path of the registry key for which you want to ensure a specific state. This path must include the hive.

    .PARAMETER ValueName
        Indicates the name of the registry value.

    .PARAMETER ValueData
        The data for the registry value.

    .PARAMETER ValueType
        Indicates the type of the value.

    .PARAMETER TargetType
        Indicates the target type. This is needed to determine the .pol file path. Supported values are LocalMachine, User, Administrators, NonAdministrators.

    .PARAMETER Ensure
        Specifies the desired state of the registry policy. When set to 'Present', the registry policy will be created. When set to 'Absent', the registry policy will be removed. Default value is 'Present'.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Key,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ValueName,

        [Parameter(Mandatory=$true)]
        [ValidateSet("ComputerConfiguration","UserConfiguration","Administrators","NonAdministrators","CustomPath","Account")]
        [System.String]
        $TargetType,

        [Parameter()]
        [System.String]
        $ValueData,

        [Parameter()]
        [System.String]
        $CustomPath,

        [Parameter()]
        [ValidateSet("Binary","Dword","ExpandString","MultiString","Qword","String","None")]
        [System.String]
        $ValueType,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $getTargetResourceParameters = @{
        Path     = $Path
        ReadOnly = $ReadOnly
    }

    $testTargetResourceResult = $false

    $getTargetResourceResult = Get-TargetResource @getTargetResourceParameters

    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message $script:localizedData.EvaluateProperties

        $valuesToCheck = @(
            'Ensure'
            'ReadOnly'
            'Hidden'
        )

        $testTargetResourceResult = Test-DscParameterState `
            -CurrentValues $getTargetResourceResult `
            -DesiredValues $PSBoundParameters `
            -ValuesToCheck $valuesToCheck
    }
    else
    {
        if ($Ensure -eq $getTargetResourceResult.Ensure)
        {
            $testTargetResourceResult = $true
        }
    }

    return $testTargetResourceResult
}

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
function Read-PolFile
{
    [OutputType([Array])]
    param (
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        $Path
    )

    [Array] $RegistryPolicies = @()
    $index = 0

    [string] $policyContents = Get-Content $Path -Raw
    [byte[]] $policyContentInBytes = Get-Content $Path -Raw -Encoding Byte

    # 4 bytes are the signature PReg
    $signature = [System.Text.Encoding]::ASCII.GetString($policyContents[0..3])
    $index += 4
    Assert ($signature -eq 'PReg') ($LocalizedData.InvalidHeader -f $Path)

    # 4 bytes are the version
    $version = [System.BitConverter]::ToInt32($policyContentInBytes, 4)
    $index += 4
    Assert ($version -eq 1) ($LocalizedData.InvalidVersion -f $Path)

    # Start processing at byte 8
    while($index -lt $policyContents.Length - 2)
    {
        [string]$keyName = $null
        [string]$valueName = $null
        [int]$valueType = $null
        [int]$valueLength = $null

        [object]$value = $null

        # Next UNICODE character should be a [
        $leftbracket = [System.BitConverter]::ToChar($policyContentInBytes, $index)
        Assert ($leftbracket -eq '[') "Missing the openning bracket"
        $index+=2

        # Next UNICODE string will continue until the ; less the null terminator
        $semicolon = $policyContents.IndexOf(";", $index)
        Assert ($semicolon -ge 0) "Failed to locate the semicolon after key name."
        $keyName = [System.Text.Encoding]::UNICODE.GetString($policyContents[($index)..($semicolon-3)]) # -3 to exclude the null termination and ';' characters
        $index = $semicolon + 2

        # Next UNICODE string will continue until the ; less the null terminator
        $semicolon = $policyContents.IndexOf(";", $index)
        Assert ($semicolon -ge 0) "Failed to locate the semicolon after value name."
        $valueName = [System.Text.Encoding]::UNICODE.GetString($policyContents[($index)..($semicolon-3)]) # -3 to exclude the null termination and ';' characters
        $index = $semicolon + 2

        # Next DWORD will continue until the ;
        $semicolon = $index + 4 # DWORD Size
        Assert ([System.BitConverter]::ToChar($policyContentInBytes, $semicolon) -eq ';') "Failed to locate the semicolon after value type."
        $valueType = [System.BitConverter]::ToInt32($policyContentInBytes, $index)
        $index=$semicolon + 2 # Skip ';'

        # Next DWORD will continue until the ;
        $semicolon = $index + 4 # DWORD Size
        Assert ([System.BitConverter]::ToChar($policyContentInBytes, $semicolon) -eq ';') "Failed to locate the semicolon after value length."
        $valueLength = Convert-StringToInt -ValueString $policyContentInBytes[$index..($index+3)]
        $index=$semicolon + 2 # Skip ';'

        if ($valueLength -gt 0)
        {
            # String types less the null terminator for REG_SZ and REG_EXPAND_SZ
            # REG_SZ: string type (ASCII)
            if($valueType -eq [RegType]::REG_SZ)
            {
                [string] $value = [System.Text.Encoding]::UNICODE.GetString($policyContents[($index)..($index+$valueLength-3)]) # -3 to exclude the null termination and ']' characters
                $index += $valueLength
            }

            # REG_EXPAND_SZ: string, includes %ENVVAR% (expanded by caller) (ASCII)
            if($valueType -eq [RegType]::REG_EXPAND_SZ)
            {
                [string] $value = [System.Text.Encoding]::UNICODE.GetString($policyContents[($index)..($index+$valueLength-3)]) # -3 to exclude the null termination and ']' characters
                $index += $valueLength
            }

            # For REG_MULTI_SZ leave the last null terminator
            # REG_MULTI_SZ: multiple strings, delimited by \0, terminated by \0\0 (ASCII)
            if($valueType -eq [RegType]::REG_MULTI_SZ)
            {
                [string] $value = [System.Text.Encoding]::UNICODE.GetString($policyContents[($index)..($index+$valueLength-3)])
                $index += $valueLength
            }

            # REG_BINARY: binary values
            if($valueType -eq [RegType]::REG_BINARY)
            {
                [byte[]] $value = $policyContentInBytes[($index)..($index+$valueLength-1)]
                $index += $valueLength
            }
        }

        # DWORD: (4 bytes) in little endian format
        if($valueType -eq [RegType]::REG_DWORD)
        {
            $value = Convert-StringToInt -ValueString $policyContentInBytes[$index..($index+3)]
            $index += 4
        }

        # QWORD: (8 bytes) in little endian format
        if($valueType -eq [RegType]::REG_QWORD)
        {
            $value = Convert-StringToInt -ValueString $policyContentInBytes[$index..($index+7)]
            $index += 8
        }

        # Next UNICODE character should be a ]
        $rightbracket = $policyContents.IndexOf("]", $index) # Skip over null data value if one exists
        Assert ($rightbracket -ge 0) "Missing the closing bracket."
        $index = $rightbracket + 2

        $entry = New-GPRegistryPolicy $keyName $valueName $valueType $valueLength $value

        $RegistryPolicies += $entry
    }

    return $RegistryPolicies
}

<#
    .SYNOPSIS
        Retrieves the path to the pol file.

    .PARAMETER TargetType
        Indicates the target type. This is needed to determine the .pol file path. Supported values are LocalMachine, User, Administrators, NonAdministrators, CustomPath, Account.

#>
function Get-PolFilePath
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateSet("ComputerConfiguration","UserConfiguration","Administrators","NonAdministrators","CustomPath","Account")]
        [System.String]
        $TargetType
    )

    # "LocalMachine","UserConfiguration","Administrators","NonAdministrators","CustomPath"

    switch ($TargetType)
    {
        'ComputerConfiguration'
        {
            $childPath = 'System32\GroupPolicy\Machine\registry.pol'
        }
        'UserConfiguration'
        {
            $childPath = 'System32\GroupPolicy\User\registry.pol'
        }
        'Administrators'
        {
            $childPath = 'System32\GroupPolicyUsers\S-1-5-32-544\User\registry.pol'
        }
        'NonAdministrators'
        {
            $childPath = 'System32\GroupPolicyUsers\S-1-5-32-545\User\registry.pol'
        }
        'Account'
        {
            $sid = ConvertTo-SecurityIdentifer -AccountName $AccountName
            $childPath = "System32\GroupPolicyUsers\$sid\User\registry.pol"
        }
    }

    return (Join-Path -Path $env:SystemRoot -ChildPath $childPath)
}

<#
    .SYNOPSIS
        Converts an identity to a SID to verify it's a valid account

    .PARAMETER Identity
        Specifies the identity to convert
#>function ConvertTo-SecurityIdentifer
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.String]
        $AccountName
    )

    $id = [System.Security.Principal.NTAccount]$AccountName

    try
    {
        $result = $id.Translate([System.Security.Principal.SecurityIdentifier]).Value
    }
    catch
    {
       # Write-Verbose -Message ($script:localizedData.ErrorIdToSid -f $Identity)

        throw $_ #"$($script:localizedData.ErrorIdToSid -f $Identity)"

    }

    return $result
}

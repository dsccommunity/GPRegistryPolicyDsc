using module ..\..\Modules\GPRegistryPolicyFileParser
$script:resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$script:modulesFolderPath = Join-Path -Path $script:resourceModulePath -ChildPath 'Modules'
$script:resourceHelperModulePath = Join-Path -Path $script:modulesFolderPath -ChildPath 'GPRegistryPolicyDsc.Common'
$script:GPRegistryPolicyFileParserModulePath = Join-Path -Path $script:modulesFolderPath -ChildPath 'GPRegistryPolicyFileParser'
Import-Module -Name (Join-Path -Path $script:resourceHelperModulePath -ChildPath 'GPRegistryPolicyDsc.Common.psm1')
Import-Module -Name (Join-Path -Path $script:GPRegistryPolicyFileParserModulePath -ChildPath 'GPRegistryPolicyFileParser.psm1')

$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_RegistryPolicyFile'

<#
    .SYNOPSIS
        Returns the current state of the registry policy file.

    .PARAMETER Key
        Indicates the path of the registry key for which you want to ensure a specific state. This path must include the hive.

    .PARAMETER ValueName
        Indicates the name of the registry value.

    .PARAMETER TargetType
        Indicates the target type. This is needed to determine the .pol file path. Supported values are LocalMachine, User, Administrators, NonAdministrators, Account.

    .PARAMETER AccountName
        Specifies the name of the account for an user specific pol file to be managed.
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

        [Parameter(Mandatory = $true)]
        [ValidateSet('ComputerConfiguration','UserConfiguration','Administrators','NonAdministrators','Account')]
        [System.String]
        $TargetType,

        [Parameter()]
        [AllowNull()]
        [System.String]
        $AccountName
    )

    Write-Verbose -Message ($script:localizedData.RetrievingCurrentState -f $Key, $ValueName)
    # determine pol file path
    $polFilePath = Get-RegistryPolicyFilePath -TargetType $TargetType -AccountName $AccountName
    $assertPolFile = Test-Path -Path $polFilePath

    # read the pol file
    if ($assertPolFile -eq $true)
    {
        $polFileContents = Read-GPRegistryPolicyFile -Path $polFilePath
        $currentResults  = $polFileContents | Where-Object -FilterScript {$PSItem.Key -eq $Key -and $PSItem.ValueName -eq $ValueName}
    }

    # determine if the key is present or not
    if ($null -eq $currentResults.ValueName)
    {
        $ensureResult = 'Absent'
    }
    else
    {
        $ensureResult = 'Present'
        $valueTypeResult = $currentResults.GetRegTypeString()
    }

    # resolve account name
    $polFilePathArray = $polFilePath -split '\\'
    $system32Index = $polFilePathArray.IndexOf('System32')
    $accountNameFromPath = $polFilePathArray[$system32Index+2]

    if ($accountNameFromPath -match '^S-1-')
    {
        $accountNameResult = ConvertTo-NTAccountName -SecurityIdentifier $accountNameFromPath
    }
    else
    {
        $accountNameResult = $accountNameFromPath
    }

    # return the results
    $getTargetResourceResult = @{
        Key         = $Key
        ValueName   = $ValueName
        ValueData   = [System.String[]] $currentResults.ValueData
        ValueType   = $valueTypeResult
        TargetType  = $TargetType
        Ensure      = $ensureResult
        Path        = $polFilePath
        AccountName = $accountNameResult
    }

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
        Indicates the target type. This is needed to determine the .pol file path. Supported values are LocalMachine, User, Administrators, NonAdministrators, Account.
    
    .PARAMETER AccountName
        Specifies the name of the account for an user specific pol file to be managed.

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

        [Parameter(Mandatory = $true)]
        [ValidateSet('ComputerConfiguration','UserConfiguration','Administrators','NonAdministrators','Account')]
        [System.String]
        $TargetType,

        [Parameter()]
        [System.String[]]
        $ValueData,

        [Parameter()]
        [ValidateSet('Binary','Dword','ExpandString','MultiString','Qword','String','None')]
        [System.String]
        $ValueType,

        [Parameter()]
        [System.String]
        $AccountName,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $getTargetResourceParameters = @{
        Key         = $Key
        TargetType  = $TargetType
        ValueName   = $ValueName
        AccountName = $AccountName
    }

    $getTargetResourceResult = Get-TargetResource @getTargetResourceParameters
    $polFilePath = Get-RegistryPolicyFilePath -TargetType $TargetType -AccountName $AccountName
    $gpRegistryEntry = New-GPRegistryPolicy -Key $Key -ValueName $ValueName -ValueData $ValueData -ValueType ([GPRegistryPolicy]::GetRegTypeFromString($ValueType))

    if ($Ensure -eq 'Present')
    {
        if ($getTargetResourceResult.Ensure -eq 'Absent')
        {
            $assertPolFile = Test-Path -Path $polFilePath

            if ($assertPolFile -eq $false)
            {
                # create the pol file
                New-GPRegistryPolicyFile -Path $polFilePath
            }
        }
        # write the desired value
        Write-Verbose -Message ($script:localizedData.AddPolicyToFile -f $Key, $ValueName, $ValueData, $ValueType)
        Set-GPRegistryPolicyFileEntry -Path $polFilePath -RegistryPolicy $gpRegistryEntry
    }
    else
    {
        if ($getTargetResourceResult.Ensure -eq 'Present')
        {
            Write-Verbose -Message ($script:localizedData.RemovePolicyFromFile -f $Key, $ValueName)
            Remove-GPRegistryPolicyFileEntry -Path $polFilePath -RegistryPolicy $gpRegistryEntry
        }
    }

    Set-RefreshRegistryKey
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
        Indicates the target type. This is needed to determine the .pol file path. Supported values are LocalMachine, User, Administrators, NonAdministrators, Account.
    
    .PARAMETER AccountName
        Specifies the name of the account for an user specific pol file to be managed.

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

        [Parameter(Mandatory = $true)]
        [ValidateSet('ComputerConfiguration','UserConfiguration','Administrators','NonAdministrators','Account')]
        [System.String]
        $TargetType,

        [Parameter()]
        [System.String[]]
        $ValueData,

        [Parameter()]
        [ValidateSet('Binary','Dword','ExpandString','MultiString','Qword','String','None')]
        [System.String]
        $ValueType,

        [Parameter()]
        [System.String]
        $AccountName,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $getTargetResourceParameters = @{
        Key         = $Key
        TargetType  = $TargetType
        ValueName   = $ValueName
        AccountName = $AccountName
    }

    $testTargetResourceResult = $false

    $getTargetResourceResult = Get-TargetResource @getTargetResourceParameters

    if ($Ensure -eq 'Present')
    {
        $valuesToCheck = @(
            'Key'
            'ValueName'
            'TargetType'
            'ValueData'
            'ValueType'
            'Ensure'
        )

        $testTargetResourceResult = Test-DscParameterState -CurrentValues $getTargetResourceResult -DesiredValues $PSBoundParameters -ValuesToCheck $valuesToCheck
    }
    else
    {
        if ($Ensure -eq $getTargetResourceResult.Ensure)
        {
            Write-Verbose -Message ($script:localizedData.InDesiredState)
            $testTargetResourceResult = $true
        }
    }

    return $testTargetResourceResult
}

<#
    .SYNOPSIS
        Retrieves the path to the pol file.

    .PARAMETER TargetType
        Indicates the target type. This is needed to determine the .pol file path. Supported values are LocalMachine, User, Administrators, NonAdministrators, Account.

    .PARAMETER AccountName
        Specifies the name of the account for an user specific pol file to be managed.
#>
function Get-RegistryPolicyFilePath
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet("ComputerConfiguration","UserConfiguration","Administrators","NonAdministrators","Account")]
        [System.String]
        $TargetType,

        [Parameter()]
        [System.String]
        $AccountName
    )

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
            if ([System.String]::IsNullOrEmpty($AccountName))
            {
                throw $script:localizedData.AccountNameNull
            }

            $sid = ConvertTo-SecurityIdentifier -AccountName $AccountName
            $childPath = "System32\GroupPolicyUsers\$sid\User\registry.pol"
        }
    }

    return (Join-Path -Path $env:SystemRoot -ChildPath $childPath)
}

<#
    .SYNOPSIS
        Converts an identity to a SID to verify it's a valid account.

    .PARAMETER AccountName
        Specifies the identity to convert.
#>
function ConvertTo-SecurityIdentifier
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $AccountName
    )

    Write-Verbose -Message ($script:localizedData.TranslatingNameToSid -f $AccountName)
    $id = [System.Security.Principal.NTAccount] $AccountName

    return $id.Translate([System.Security.Principal.SecurityIdentifier]).Value
}

<#
    .SYNOPSIS
        Converts a SID to an NTAccount name.
    
    .PARAMETER SecurityIdentifier
        Specifies SID of the identity to convert.
#>
function ConvertTo-NTAccountName
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Security.Principal.SecurityIdentifier]
        $SecurityIdentifier
    )

    $identiy = [System.Security.Principal.SecurityIdentifier] $SecurityIdentifier

    return $identiy.Translate([System.Security.Principal.NTAccount]).Value
}

<#
    .SYNOPSIS
        Writes a registry key indicating a group policy refresh is required.

    .PARAMETER Path
        Specifies the value of the registry path that will contain the properties pertaining to requiring a refresh.

    .PARAMETER PropertyName
        Specifies a name for the new property.

    .PARAMETER Value
        Specifies the property value.
#>
function Set-RefreshRegistryKey
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String]
        $Path = 'HKLM:\SOFTWARE\Microsoft\GPRegistryPolicy',

        [Parameter()]
        [System.String]
        $PropertyName = 'RefreshRequired',

        [Parameter()]
        [System.Object]
        $Value = 1
    )

    New-Item -Path $Path -Force
    New-ItemProperty -Path $Path -Name $PropertyName -Value $Value -Force
}

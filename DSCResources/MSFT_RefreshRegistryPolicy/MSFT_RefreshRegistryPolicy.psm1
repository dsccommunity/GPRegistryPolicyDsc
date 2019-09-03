$script:resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$script:modulesFolderPath = Join-Path -Path $script:resourceModulePath -ChildPath 'Modules'

$script:resourceHelperModulePath = Join-Path -Path $script:modulesFolderPath -ChildPath 'GPRegistryPolicyDsc.Common'
Import-Module -Name (Join-Path -Path $script:resourceHelperModulePath -ChildPath 'GPRegistryPolicyDsc.Common.psm1')

$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_RefreshRegistryPolicy'

<#
    .SYNOPSIS
        Returns the current state if a machine requires a group policy refresh.

    .PARAMETER Name
        A name to serve as the key property. It is not used during configuration.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    $path = 'HKLM:\SOFTWARE\Microsoft\GPRegistryPolicy'
    $key = 'RefreshRequired'

    $registryKey = Get-Item -Path $path -ErrorAction SilentlyContinue
    $refreshKeyValue = ($registryKey | Get-ItemProperty).$key

    # TODO: Code that returns the current state.
    Write-Verbose -Message ($script:localizedData.RefreshRequiredValue -f $refreshKeyValue)

    return @{
        Name                = $Name
        Path                = $registryKey.Name
        RefreshRequiredKey  = $refreshKeyValue
    }
}

<#
    .SYNOPSIS
        Invokes gpupdate.exe /force to update group policy.

    .PARAMETER Name
        A name to serve as the key property. It is not used during configuration.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    Write-Verbose -Message $script:localizedData.RefreshingGroupPolicy

    Invoke-Command -ScriptBlock {gpupdate.exe /force}

    Remove-Item -Path HKLM:\SOFTWARE\Microsoft\GPRegistryPolicy -Force
}

<#
    .SYNOPSIS
        Reads the value of HKLM:\SOFTWARE\Microsoft\GPRegistryPolicy\RefreshRequired to determine if a group policy refresh is required.

    .PARAMETER Name
        A name to serve as the key property. It is not used during configuration.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    $testTargetResourceResult = $false

    $getTargetResourceResult = Get-TargetResource -Name $Name

    if ($getTargetResourceResult.RefreshRequiredKey -ne 1)
    {
        Write-Verbose -Message $script:localizedData.NotRefreshRequired
        $testTargetResourceResult = $true
    }

    Write-Verbose -Message $script:localizedData.RefreshRequired

    return $testTargetResourceResult
}

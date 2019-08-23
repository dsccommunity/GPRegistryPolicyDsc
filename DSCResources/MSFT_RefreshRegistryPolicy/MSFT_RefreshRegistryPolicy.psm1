$script:resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$script:modulesFolderPath = Join-Path -Path $script:resourceModulePath -ChildPath 'Modules'

$script:resourceHelperModulePath = Join-Path -Path $script:modulesFolderPath -ChildPath 'DscResource.Common'
Import-Module -Name (Join-Path -Path $script:resourceHelperModulePath -ChildPath 'DscResource.Common.psm1')

$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_ResourceName'

<#
    .SYNOPSIS
        Returns ...

    .PARAMETER MandatoryParameter
        This ...
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $MandatoryParameter
    )

    # TODO: Code that returns the current state.
    Write-Verbose -Message $script:localizedData.GetConfiguration

    return @{
        Ensure                = $ensure
        MandatoryParameter    = $value1
        NonMandatoryParameter = $value2
    }
}

<#
    .SYNOPSIS
        Sets ...

    .PARAMETER MandatoryParameter
        This ...

    .PARAMETER NonMandatoryParameter
        This ...
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $MandatoryParameter,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.String]
        $NonMandatoryParameter
    )

    # Code that sets the desired state if evaluated to not in desired state.
    Write-Verbose -Message $script:localizedData.SetConfiguration
}

<#
    .SYNOPSIS
        Determines if ...

    .PARAMETER MandatoryParameter
        This ...

    .PARAMETER NonMandatoryParameter
        This ...
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $MandatoryParameter,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.String]
        $NonMandatoryParameter
    )

    Write-Verbose -Message $script:localizedData.TestConfiguration

    $testTargetResourceResult = $false

    $getTargetResourceParameters = @{
        MandatoryParameter = $MandatoryParameter
    }

    $getTargetResourceResult = Get-TargetResource @getTargetResourceParameters

    # Code that tests the desired state.

    return $testTargetResourceResult
}

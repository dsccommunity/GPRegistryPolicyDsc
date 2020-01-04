# GPRegistryPolicyDsc

[![Build Status](https://dev.azure.com/dsccommunity/GPRegistryPolicyDsc/_apis/build/status/dsccommunity.GPRegistryPolicyDsc?branchName=master)](https://dev.azure.com/dsccommunity/GPRegistryPolicyDsc/_build/latest?definitionId=12&branchName=master)
![Azure DevOps coverage (branch)](https://img.shields.io/azure-devops/coverage/dsccommunity/GPRegistryPolicyDsc/12/master)
[![Azure DevOps tests](https://img.shields.io/azure-devops/tests/dsccommunity/GPRegistryPolicyDsc/12/master)](https://dsccommunity.visualstudio.com/GPRegistryPolicyDsc/_test/analytics?definitionId=12&contextType=build)
[![PowerShell Gallery (with prereleases)](https://img.shields.io/powershellgallery/vpre/GPRegistryPolicyDsc?label=GPRegistryPolicyDsc%20Preview)](https://www.powershellgallery.com/packages/GPRegistryPolicyDsc/)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/GPRegistryPolicyDsc?label=GPRegistryPolicyDsc)](https://www.powershellgallery.com/packages/GPRegistryPolicyDsc/)

This resource module contains resources used to apply and manage local group policies
by modifying the respective .pol file.

This module is an adaptation from [GPRegistryPolicy](https://github.com/PowerShell/GPRegistryPolicy).

## Code of Conduct

This project has adopted this [Code of Conduct](CODE_OF_CONDUCT.md).

## Releases

For each merge to the branch `master` a preview release will be
deployed to [PowerShell Gallery](https://www.powershellgallery.com/).
Periodically a release version tag will be pushed which will deploy a
full release to [PowerShell Gallery](https://www.powershellgallery.com/).

## Contributing

Please check out common DSC Community [contributing guidelines](https://dsccommunity.org/guidelines/contributing).

## Installation

### GitHub

To manually install the module,
download the source code and unzip the contents to the directory
'$env:ProgramFiles\WindowsPowerShell\Modules' folder.

### PowerShell Gallery

To install from the PowerShell gallery using PowerShellGet (in PowerShell 5.0)
run the following command:

```powershell
Find-Module -Name GPRegistryPolicyDsc -Repository PSGallery | Install-Module
```

To confirm installation, run the below command and ensure you see the
DSC resources available:

```powershell
Get-DscResource -Module GPRegistryPolicyDsc
```

## Requirements

The minimum Windows Management Framework (PowerShell) version required is 5.0
or higher.

## Examples

You can review the [Examples](/source/Examples) directory for some general use
scenarios for all of the resources that are in the module.

## Change log

A full list of changes in each version can be found in the [change log](CHANGELOG.md).

## Resources

* [**RefreshRegistryPolicy**](#RefreshRegistryPolicy) A resource to detect
   and invoke a group policy refresh.
* [**RegistryPolicyFile**](#RegistryPolicyFile) A resource to manage registry policy
   entries in a policy (.pol) file.

### RefreshRegistryPolicy

A resource to detect and invoke a group policy refresh.

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.

#### Parameters

* **`[String]` IsSingleInstance** _(Key)_: Specifies the resource is a single
      instance, the value must be 'Yes'

#### Read-Only Properties from Get-TargetResource

* **`[String]` RefreshRequiredKey** _(Read)_: Returns the value of the
      GPRegistryPolicy key indicating a group policy refresh is needed.
* **`[String]` Path** _(Read)_: Returns the path of the RefreshRequired
       property indicating a group policy refresh is needed.

## Known issues

All issues are not listed here, see [here for all open issues](https://github.com/dsccommunity/GPRegistryPolicyDsc/issues?utf8=✓&q=is%3Aissue+is%3Aopen+RefreshRegistryPolicy).

### RegistryPolicyFile

A resource to manage registry policy entries in a policy (.pol) file.

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.

#### Parameters

* **`[String]` Key** _(Key)_: Indicates the path of the registry key
      for which you want to ensure a specific state.
* **`[String]` ValueName** _(Key)_: Indicates the name of the registry value.
* **`[String]` TargetType** _(Required)_: Indicates the target type.
      This is needed to determine the .pol file path.
      Supported values are ComputerConfiguration, UserConfiguration,
      Administrators, NonAdministrators, and Account.
* **`[String]` AccountName** _(Write)_: Specifies the name of the account
      for an user specific pol file to be managed.
* **`[String[]]` ValueData** _(Write)_: The data for the registry value.
* **`[String]` ValueType** _(Write)_: Indicates the type of the value.
      Possible values are:"Binary","Dword","ExpandString","MultiString","Qword","String","None"
* **`[String]` Ensure** _(Write)_: Specifies the desired state of the registry policy.
      When set to `'Present'`, the registry policy will be created. When set to `'Absent'`,
      the registry policy will be removed. Default value is `'Present'`.

#### Read-Only Properties from Get-TargetResource

* **`[String]` Path** _(Read)_: Returns the path to the pol file being managed.

#### Examples

* [Disable SMB1](/source/Examples/Resources/RegistryPolicyFile/1-RegistryPolicyFile_DisableSmb1_Config.ps1)
* [Disable SMB1 not configured](/source/Examples/Resources/RegistryPolicyFile/2-RegistryPolicy_SMB1NotConfigured_Config.ps1)
* [Disable desktop changes, Target type is Account](/source/Examples/Resources/RegistryPolicyFile/3-RegistryPolicyFile_DisableDesktopChanges_Config.ps1)
* [Configure lanman dependant services, MutiString datatype example](/source/Examples/Resources/RegistryPolicyFile/4-RegistryPolicyFile_LanmanDependantServices_Config.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/dsccommunity/GPRegistryPolicyDsc/issues?utf8=✓&q=is%3Aissue+is%3Aopen+RegistryPolicyFile).

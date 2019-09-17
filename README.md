# GPRegistryPolicyDsc

This resource module contains resources used to apply and manage local group policies
by modifying the respective .pol file.

This module is an adaptation from [GPRegistryPolicy](https://github.com/PowerShell/GPRegistryPolicy).

This project has adopted [this code of conduct](CODE_OF_CONDUCT.md).

## Branches

### master

[![Build status](https://ci.appveyor.com/api/projects/status/3w6ohuqnmxin63kf/branch/master?svg=true)](https://ci.appveyor.com/project/dsccommunity/GPRegistryPolicyDsc/branch/master)
[![codecov](https://codecov.io/gh/dsccommunity/GPRegistryPolicyDsc/branch/master/graph/badge.svg)](https://codecov.io/gh/dsccommunity/GPRegistryPolicyDsc/branch/master)

This is the branch containing the latest release -
no contributions should be made directly to this branch.

### dev

[![Build status](https://ci.appveyor.com/api/projects/status/3w6ohuqnmxin63kf/branch/dev?svg=true)](https://ci.appveyor.com/project/dsccommunity/GPRegistryPolicyDsc/branch/dev)
[![codecov](https://codecov.io/gh/dsccommunity/GPRegistryPolicyDsc/branch/dev/graph/badge.svg)](https://codecov.io/gh/dsccommunity/GPRegistryPolicyDsc/branch/dev)

This is the development branch to which contributions should be proposed
by contributors as pull requests.
This development branch will periodically be merged to the master branch,
and be released to [PowerShell Gallery](https://www.powershellgallery.com/).

## Contributing

Please see our [contributing guidelines](/CONTRIBUTING.md).

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

You can review the [Examples](/Examples) directory for some general use
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

* [Disable SMB1](/Examples/Resources/RegistryPolicyFile/1-RegistryPolicyFile_DisableSmb1_Config.ps1)
* [Disable SMB1 not configured](/Examples/Resources/RegistryPolicyFile/2-RegistryPolicy_SMB1NotConfigured_Config.ps1)
* [Disable desktop changes, Target type is Account](/Examples/Resources/RegistryPolicyFile/3-RegistryPolicyFile_DisableDesktopChanges_Config.ps1)
* [Configure lanman dependant services, MutiString datatype example](/Examples/Resources/RegistryPolicyFile/4-RegistryPolicyFile_LanmanDependantServices_Config.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/dsccommunity/GPRegistryPolicyDsc/issues?utf8=✓&q=is%3Aissue+is%3Aopen+RegistryPolicyFile).

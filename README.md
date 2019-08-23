# DscResource.Template

The **DscResource.Template** module contains a template with example code and
best practices for DSC resource modules in
[DSC Resource Kit](https://github.com/PowerShell/DscResources).

>**NOTE!** This is not meant to be a fully functioning resource module.
>The resource in this repository is just to make sure common code works,
>and used as a practical example.

This project has adopted [this code of conduct](CODE_OF_CONDUCT.md).

## Branches

### master

[![Build status](https://ci.appveyor.com/api/projects/status/vqviwd2mmclxeopb/branch/master?svg=true)](https://ci.appveyor.com/project/PowerShell/DscResource-Template/branch/master)
[![codecov](https://codecov.io/gh/PowerShell/DscResource.Template/branch/master/graph/badge.svg)](https://codecov.io/gh/PowerShell/DscResource.Template/branch/master)

This is the branch containing the latest release -
no contributions should be made directly to this branch.

### dev

[![Build status](https://ci.appveyor.com/api/projects/status/vqviwd2mmclxeopb/branch/dev?svg=true)](https://ci.appveyor.com/project/PowerShell/DscResource-Template/branch/dev)
[![codecov](https://codecov.io/gh/PowerShell/DscResource.Template/branch/dev/graph/badge.svg)](https://codecov.io/gh/PowerShell/DscResource.Template/branch/dev)

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
Find-Module -Name DscResource.Template -Repository PSGallery | Install-Module
```

To confirm installation, run the below command and ensure you see the
DSC resources available:

```powershell
Get-DscResource -Module DscResource.Template
```

## Requirements

The minimum Windows Management Framework (PowerShell) version required is 4.0
or higher.

## Examples

You can review the [Examples](/Examples) directory for some general use
scenarios for all of the resources that are in the module.

## Change log

A full list of changes in each version can be found in the [change log](CHANGELOG.md).

## Resources

* [**Folder**](#folder) example resource
  to manage a folder on Windows.
* {**Resource2** One line description of resource 1}

### Folder

Example resource to manage a folder on Windows.

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.

#### Parameters

* **`[String]` Path** _(Key)_: The path to the folder to create.
* **`[Boolean]` ReadOnly** _(Required)_: If the files in the folder should be
  read only.
* **`[Boolean]` Hidden** _(Write)_: If the folder should be hidden.
  Default value is `$false`.
* **`[String]` Ensure** _(Write)_: Specifies the desired state of the folder.
     When set to `'Present'`, the folder will be created. When set to `'Absent'`,
    the folder will be removed. Default value is `'Present'`.

#### Read-Only Properties from Get-TargetResource

* **`[Boolean]` Shared** _(Write)_: If sharing is be enabled or disabled.
* **`[String]` ShareName** _(Read)_: The name of the shared resource.

#### Examples

* [Create folder as SYSTEM](/Examples/Resources/Folder/1-DscResourceTemplate_CreateFolderAsSystemConfig.ps1)
* [Create folder as user](/Examples/Resources/Folder/2-DscResourceTemplate_CreateFolderAsUserConfig.ps1)
* [Remove folder](/Examples/Resources/Folder/3-DscResourceTemplate_RemoveFolderConfig.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/DscResource.Template/issues?utf8=%E2%9C%93&q=is%3Aissue+is%3Aopen+Folder).

### {ResourceName}

{ Detailed description of ResourceName. }

#### Requirements

{ Please include any requirements for running this resource (e.g. Must
run on Windows Server OS, must have Exchange already installed). }

* Target machine must be running Windows Server 2008 R2 or later.

#### Parameters

* {**`[String]` Property1** _(Key)_: Description of ResourceName property 1}
* {**`[Boolean]` Property2** _(Required)_: Description of ResourceName property 2}

#### Read-Only Properties from Get-TargetResource

* {**`[Boolean]` Property3** _(Write)_: Description of ResourceName property 2}

#### Examples

* { Add links to the examples for the resource ResourceName }

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/DscResource.Template/issues?utf8=%E2%9C%93&q=is%3Aissue+is%3Aopen+ResourceName).

# Welcome to the GPRegistryPolicyDsc wiki

<sup>*GPRegistryPolicyDsc v#.#.#*</sup>

Here you will find all the information you need to make use of the GPRegistryPolicyDsc
DSC resources in the latest release. This includes details of the resources
that are available, current capabilities, known issues, and information to
help plan a DSC based implementation of GPRegistryPolicyDsc.

Please leave comments, feature requests, and bug reports for this module in
the [issues section](https://github.com/dsccommunity/GPRegistryPolicyDsc/issues)
for this repository.

## Deprecated resources

The documentation, examples, unit test, and integration tests have been removed
for these deprecated resources. These resources will be removed
in a future release.

*No resources are currently deprecated.*

## Getting started

To get started either:

- Install from the PowerShell Gallery using PowerShellGet by running the
  following command:

```powershell
Install-Module -Name GPRegistryPolicyDsc -Repository PSGallery
```

- Download GPRegistryPolicyDsc from the [PowerShell Gallery](https://www.powershellgallery.com/packages/GPRegistryPolicyDsc)
  and then unzip it to one of your PowerShell modules folders (such as
  `$env:ProgramFiles\WindowsPowerShell\Modules`).

To confirm installation, run the below command and ensure you see the GPRegistryPolicyDsc
DSC resources available:

```powershell
Get-DscResource -Module GPRegistryPolicyDsc
```

### Powershell

It is recommended to use Windows Management Framework (PowerShell) version 5.1.

The minimum Windows Management Framework (PowerShell) version required is 5.0,
which ships with Windows 10 or Windows Server 2016, but can also be installed
on Windows 7 SP1, Windows 8.1, Windows Server 2012, and Windows Server 2012 R2.

These DSC resources might not work with PowerShell 7.x.

## Change log

A full list of changes in each version can be found in the [change log](https://github.com/dsccommunity/SqlServerDsc/blob/main/CHANGELOG.md).

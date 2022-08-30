# Contributing

Thank you for considering contributing to this resource module. Every little
change helps make the DSC resources even better for everyone to use.

## Common contribution guidelines

This resource module follow all of the common DSC Community [contributing guidelines](https://dsccommunity.org/guidelines/contributing),
so please review these as a baseline for contributing.

## Specific guidelines for this resource module

### Automatic formatting with VS Code

There is a VS Code workspace settings file within this project with formatting
settings matching the style guideline. That will make it possible inside VS Code
to press SHIFT+ALT+F, or press F1 and choose 'Format document' in the list. The
PowerShell code will then be formatted according to the Style Guideline
(although maybe not complete, but would help a long way).

### Naming convention

#### mof-based resource

All mof-based resource (with Get/Set/Test-TargetResource) should be prefixed
with 'DSC'. I.e. DSC\_Folder.

>**Note:** If the resource module is not part of the DSC Resource Kit the
>prefix can be any abbreviation, for example your name or company name.
>For the example below, the 'DSC' prefix is used.

##### Folder and file structure

```Text
DSCResources/DSC_Folder/DSC_Folder.psm1
DSCResources/DSC_Folder/DSC_Folder.schema.mof
DSCResources/DSC_Folder/en-US/DSC_Folder.strings.psd1

Tests/Unit/DSC_Folder.Tests.ps1

Examples/Resources/Folder/1-AddConfigurationOption.ps1
Examples/Resources/Folder/2-RemoveConfigurationOption.ps1
```

>**Note:** For the examples folder we don't use the 'DSC\_' prefix on the
>resource folders. This is to make those folders resemble the name the user
>would use in the configuration file.

##### Schema mof file

Please note that the `FriendlyName` in the schema mof file should not
contain the prefix `DSC\_`.

```powershell
[ClassVersion("1.0.0.0"), FriendlyName("Folder")]
class DSC_Folder : OMI_BaseResource
{
    # Properties removed for readability.
};
```

#### Composite or class-based resource

Any composite (with a Configuration) or class-based resources should be
prefixed with just 'Sql'

### Helper functions

Helper functions that are only used by one resource
so preferably be put in the same script file as the resource.
Helper function that can used by more than one resource can preferably
be placed in the resource module file GPRegistryPolicyDsc.Common.

### Documentation with Markdown

If using Visual Studio Code to edit Markdown files it can be a good idea to install
the markdownlint extension. It will help to find lint errors and style checking.
The file [.markdownlint.json](/.markdownlint.json) is prepared with a default set
of rules which will automatically be used by the extension.

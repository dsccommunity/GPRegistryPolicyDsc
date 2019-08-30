<#
    .SYNOPSIS
        The localized resource strings in English (en-US) for the
        resource MSFT_RegistryPolicyFile.
#>

ConvertFrom-StringData -StringData @'
    AddPolicyToFile = Adding policy with Key: {0} ValueName: {1} ValueData: {2} ValueType: {3}.
    RemovePolicyFromFile = Removing policy with Key: {0} ValueName: {1}.
    TranslatingNameToSid = Translating {0} to SID.




    InvalidFormatBracket = File '{0}' has an invalid format. A [ or ] was expected at location {1}.
    InvalidFormatSemicolon = File '{0}' has an invalid format. A ; was expected at location {1}.
    OnlyCreatingKey = Some values are null. Only the registry key is created.
    InvalidPath = Path {0} doesn't point to an existing registry key/property.
    InternalError = Internal error while creating a registry entry for {0}.
'@

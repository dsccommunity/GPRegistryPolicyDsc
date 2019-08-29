<#
    .SYNOPSIS
        The localized resource strings in English (en-US) for the
        resource MSFT_RegistryPolicyFile.
#>

ConvertFrom-StringData -StringData @'
    InvalidHeader = File '{0}' has an invalid header.
    InvalidVersion = File '{0}' has an invalid version. It should be 1.
    InvalidFormatBracket = File '{0}' has an invalid format. A [ or ] was expected at location {1}.
    InvalidFormatSemicolon = File '{0}' has an invalid format. A ; was expected at location {1}.
    OnlyCreatingKey = Some values are null. Only the registry key is created.
    InvalidPath = Path {0} doesn't point to an existing registry key/property.
    InternalError = Internal error while creating a registry entry for {0}.
    InvalidIntegerSize = Invalid size for an integer. Must be less than or equal to 8.
    MissingOpeningBracket = Missing the openning bracket.
    MissingTrailingSemicolonAfterKey = Failed to locate the semicolon after key name.
    MissingTrailingSemicolonAfterName = Failed to locate the semicolon after value name.
    MissingTrailingSemicolonAfterType = Failed to locate the semicolon after value type.
    MissingTrailingSemicolonAfterLength = Failed to locate the semicolon after value length.
    MissingClosingBracket = Missing the closing bracket.
    CreateNewPolFile = Creating new pol file at {0}.
    AddPolicyToFile = Adding policy with Key: {0} ValueName: {1} ValueData: {2} ValueType: {3}.
    RemovePolicyFromFile = Removing policy with Key: {0} ValueName: {1}.
    TranslatingNameToSid = Translating {0} to SID.
    GPRegistryPolicyExists = Registry policy already exists with Key: {0} ValueName: {1} ValueData: {0}.
    NoMatchingPolicies = No matching registry policies found.
'@

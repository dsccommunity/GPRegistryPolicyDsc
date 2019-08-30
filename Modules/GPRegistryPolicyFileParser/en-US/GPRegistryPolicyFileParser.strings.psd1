<#
    .SYNOPSIS
        The localized resource strings in English (en-US) for the
        GPRegistryPolicyFileParser module.
#>

ConvertFrom-StringData -StringData @'
    InvalidHeader = File '{0}' has an invalid header.
    InvalidVersion = File '{0}' has an invalid version. It should be 1.
    InvalidIntegerSize = Invalid size for an integer. Must be less than or equal to 8.
    MissingOpeningBracket = Missing the openning bracket.
    MissingTrailingSemicolonAfterKey = Failed to locate the semicolon after key name.
    MissingTrailingSemicolonAfterName = Failed to locate the semicolon after value name.
    MissingTrailingSemicolonAfterType = Failed to locate the semicolon after value type.
    MissingTrailingSemicolonAfterLength = Failed to locate the semicolon after value length.
    MissingClosingBracket = Missing the closing bracket.
    CreateNewPolFile = Creating new pol file at {0}.
    GPRegistryPolicyExists = Registry policy already exists with Key: {0} ValueName: {1} ValueData: {0}.
    NoMatchingPolicies = No matching registry policies found.
'@

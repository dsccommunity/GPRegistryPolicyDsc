<#
    .SYNOPSIS
        The localized resource strings in English (en-US) for the
        resource MSFT_RegistryPolicyFile.
#>
ConvertFrom-StringData -StringData @'
    AddPolicyToFile = Adding policy with Key: {0} ValueName: {1} ValueData: {2} ValueType: {3}. (RPF001)
    RemovePolicyFromFile = Removing policy with Key: {0} ValueName: {1}. (RPF002)
    TranslatingNameToSid = Translating {0} to SID. (RPF003)
    RetrievingCurrentState = Retrieving current for Key {0} ValueName {1}. (RPF04)
'@

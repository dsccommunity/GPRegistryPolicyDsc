$profileStringSignature = @'
    [DllImport("kernel32.dll")]
    public static extern uint GetPrivateProfileString(
        string lpAppName,
        string lpKeyName,
        string lpDefault,
        StringBuilder lpReturnedString,
        uint nSize,
        string lpFileName
    );

    [DllImport("kernel32.dll")]
    public static extern bool WritePrivateProfileString(
        string lpAppName,
        string lpKeyName,
        string lpString,
        string lpFileName
    );
'@

Add-Type -MemberDefinition $profileStringSignature -Name GPRegistryPolicyDscIniUtility -Namespace GPRegistryPolicyDscTools -Using System.Text

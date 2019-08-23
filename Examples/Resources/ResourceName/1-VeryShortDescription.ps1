<#
    .DESCRIPTION
        This example shows how to ...
#>
Configuration Example
{
    # TODO: Change 'DscResource.Template' to the correct module name.
    Import-DscResource -ModuleName 'DscResource.Template'

    Node $AllNodes.NodeName
    {
        ResourceName ShortNameForResource
        {
            Ensure                = 'Present'
            MandatoryParameter    = 'MyValue'
            NonMandatoryParameter = 'OtherValue'
        }
    }
}

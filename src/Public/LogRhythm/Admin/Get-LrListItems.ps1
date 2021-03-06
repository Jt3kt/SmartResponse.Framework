using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Get-LrListItems {
    <#
    .SYNOPSIS
        Retrieve the specified list items from LogRhythm.
    .DESCRIPTION
        Get-LrListItems returns a full LogRhythm List Items object, including it's details.
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
    .PARAMETER Name
        [System.String] (Name or Guid) or [System.Guid]
        Specifies a LogRhythm list object by providing one of the following property values:
          + List Name (as System.String), e.g. "LogRhythm: Suspicious Hosts"
          + List Guid (as System.String or System.Guid), e.g. D378A76F-1D83-4714-9A7C-FC04F9A2EB13
    .PARAMETER MaxItemsThreshold
        The maximum number of list items to retrieve from LogRhythm.
        The default value for this parameter is set to 1000.
    .PARAMETER Exact
        Switch to force PARAMETER Name to be matched explicitly.
    .INPUTS
        The Name parameter can be provided via the PowerShell pipeline.
    .OUTPUTS
        PSCustomObject representing the specified LogRhythm List contents.
    .EXAMPLE
        PS C:\> Get-LrListItems -Name "edea82e3-8d0b-4370-86f0-d96bcd4b6c19" -Credential $MyKey
    .NOTES
        LogRhythm-API        
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [pscredential] $Credential = $SrfPreferences.LrDeployment.LrApiToken,

        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=1)]
        [ValidateNotNull()]
        [object] $Name,

        [Parameter(Mandatory=$false, Position=2)]
        [ValidateRange(1,1000)]
        [int] $MaxItemsThreshold,

        [Parameter(Mandatory=$false, Position=3)]
        [switch] $Exact = $true
    )

    Begin {
        # Process Identity Object
        if (($Name.GetType() -eq [System.Guid]) -Or (Test-Guid $Name)) {
            $Guid = $Name.ToString()
        } else {
            try {
                if ($Exact) {
                    $Guid = Get-LRListGuidByName -Name $Name.ToString() -Exact
                } else {
                    $Guid = Get-LRListGuidByName -Name $Name.ToString()
                }
            }
            catch {
                $Err = Get-RestErrorMessage $_
                throw [Exception] "Exception invoking Rest Method: [$($Err.statusCode)]: $($Err.message)"
            }
        }
    }

    Process {
        # Update Default maxItemsThreshold
        if (!$MaxItemsThreshold) {
            $MaxItemsThreshold = 1000
        }


        # Send Request
        $Response = Get-LrList -Name $Guid | Select-Object items
        

        # Process Results
        $ReturnList = $Response.items
        return $ReturnList
    }

    End { }

}
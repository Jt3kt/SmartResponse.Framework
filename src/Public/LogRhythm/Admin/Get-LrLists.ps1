using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Get-LrLists {
    <#
    .SYNOPSIS
        Retrieve a list of lists from LogRhythm.
    .DESCRIPTION
        Get-LrList returns a full LogRhythm List object, including it's details and list items.

        [NOTE]: Due to the way LogRhythm REST API is built, if the specified MaxItemsThreshold
        is less than the number of actual items in the list, this cmdlet will return an http 400 error.
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
    .PARAMETER Name
        [System.String] (Name or Guid) or [System.Guid]
        Specifies a LogRhythm list object by providing one of the following property values:
          + List Name (as System.String), e.g. "LogRhythm: Suspicious Hosts"
          + List Guid (as System.String or System.Guid), e.g. D378A76F-1D83-4714-9A7C-FC04F9A2EB13
    .PARAMETER MaxItemsThreshold
        The maximum number of list items to retrieve from LogRhythm.
        The default value for this parameter is set to 1001.
    .PARAMETER Exact
        Switch to force PARAMETER Name to be matched explicitly.
    .INPUTS
        The Name parameter can be provided via the PowerShell pipeline.
    .OUTPUTS
        PSCustomObject representing the specified LogRhythm List and its contents.

        If parameter ListItemsOnly is specified, a string collection is returned containing the
        list's item values.
    .EXAMPLE
        PS C:\> Get-LrList -Identity "edea82e3-8d0b-4370-86f0-d96bcd4b6c19" -Credential $MyKey
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
        
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, Position=1)]
        [ValidateNotNull()]
        [string] $Name,

        [Parameter(Mandatory=$false, Position=2)]
        [ValidateNotNull()]
        [string] $ListType,

        [Parameter(Mandatory=$false, Position=3)]
        [ValidateRange(1,1000)]
        [int] $PageSize,

        [Parameter(Mandatory = $false, Position=4)]
        [switch] $Exact
    )

    #region: BEGIN                                                                       
    Begin {
        $Me = $MyInvocation.MyCommand.Name
        
        $BaseUrl = $SrfPreferences.LRDeployment.AdminApiBaseUrl
        $Token = $Credential.GetNetworkCredential().Password

        # Enable self-signed certificates and Tls1.2
        Enable-TrustAllCertsPolicy
    }
    #endregion

    Process {      
        # Validate ListType
        if ($ListType) {
            $ListTypeInfo = Test-LrListType -Id $ListType
            if ($ListTypeInfo.IsValid -eq $true) {
                $ListTypeValid = $ListTypeInfo.Value
            } else {
                throw [ArgumentException] "Parameter [ListType] must be a valid LogRhythm List type."
            }
        }

        # Update default PageSize if not defined
        if (!$PageSize) {
            $PageSize = 1000
        }


        # General Setup
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Bearer $Token")


        # Request Setup
        $Method = $HttpMethod.Get
        if ($pageSize) {
            $Headers.Add("pageSize", $PageSize)
        }
        if ($ListTypeValid) { 
            $Headers.Add("listType", $ListTypeValid)
        }
        if ($Name) {
            $Headers.Add("name", $Name)
        }
        $Headers.Add("maxItemsThreshold", $MaxItemsThreshold)
        $RequestUrl = $BaseUrl + "/lists/"
        Write-Verbose "[$Me]: Request Header: `n$($Headers.name)"

        # Send Request
        try {
            $Response = Invoke-RestMethod $RequestUrl -Headers $Headers -Method $Method
        }
        catch [System.Net.WebException] {
            $Err = Get-RestErrorMessage $_
            throw [Exception] "[$Me] [$($Err.statusCode)]: $($Err.message) - $($Err.details) - $($Err.validationErrors)"
        }

        # [Exact] Parameter
        # Search "Malware" normally returns both "Malware" and "Malware Options"
        # This would only return "Malware"
        if ($Exact) {
            $Pattern = "^$Name$"
            $Response | ForEach-Object {
                if(($_.name -match $Pattern) -or ($_.name -eq $Name)) {
                    Write-Verbose "[$Me]: Exact list name match found."
                    $List = $_
                    return $List
                }
            }
        } else {
            return $Response
        }
    }

    End { }
}
using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Get-LrTags {
    <#
    .SYNOPSIS
        Return a list of tags.
    .DESCRIPTION
        The Get-LrTags cmdlet returns a list of all existing case tags, 
        and can optionally be filtered for tag names containing the specified
        string. Results will be sorted alphabetically ascending, unless
        the OrderBy parameter is set to "desc".

        Note: This cmdlet does not support pagination.
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
        Note: You can bypass the need to provide a Credential by setting
        the preference variable $SrfPreferences.LrDeployment.LrApiToken
        with a valid Api Token.
    .PARAMETER Name
        Filter results that have a tag name that contain the specified string value.
        Use the -Exact switch for an explicit filter.
    .PARAMETER Sort
        Sort the results in ascending (asc) or descending (desc) order.
    .PARAMETER Exact
        Only return tags that match the provided tag name exactly.
    .INPUTS
        System.String value to Name parameter.
    .OUTPUTS
        System.Object
        
        Returns one or more LogRhythm (case) tag objects.

        [LogRhythm.Tag]
        ---------------------------------------------------
        FieldName       Type                Description
        ---------------------------------------------------
        number          [System.Int32]    Tag ID
        text            [System.String]     Tag Name
        dateCreated     [System.DateTime]   Date tag created
        createdBy       [Object]            Created by [LogRhythm.User]
    .EXAMPLE
        PS C:\> @("Testing","Malware") | Get-LrTags -Credential $Token
            number   text          dateCreated                   createdBy
            ------   ----          -----------                   ---------
            120      API Testing   2019-10-05T10:38:05.7133333Z  @{number=35; name=Smith, Bob; disabled=False}
            112      Testing       2019-09-20T21:36:59.34Z       @{number=35; name=Smith, Bob; disabled=False}
              5      Malware       2019-03-13T15:11:21.467Z      @{number=35; name=Smith, Bob; disabled=False}
    .EXAMPLE
        PS C:\> @("Testing","Malware") | Get-LrTags -Credential $Token | Select-Object -ExpandProperty text
            API Testing
            Testing
            Malware
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


        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            Position = 1
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        
        [Parameter(
            Mandatory = $false,
            Position = 2
        )]
        [ValidateSet('asc','desc')]
        [string] $Sort = "asc",

        
        [Parameter(
            Mandatory = $false,
            Position = 3
        )]
        [switch] $Exact
    )

    Begin {
        $Me = $MyInvocation.MyCommand.Name
        
        $BaseUrl = $SrfPreferences.LRDeployment.CaseApiBaseUrl
        $Token = $Credential.GetNetworkCredential().Password

        # Enable self-signed certificates and Tls1.2
        Enable-TrustAllCertsPolicy
    }


    Process {
        # Request Headers
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Bearer $Token")
        $Headers.Add("count", 500)
        $Headers.Add("direction", $Sort)
        

        # Request URI
        $Method = $HttpMethod.Get
        $RequestUri = $BaseUrl + "/tags/?tag=$Name"


        # REQUEST
        try {
            $Response = Invoke-RestMethod `
                -Uri $RequestUri `
                -Headers $Headers `
                -Method $Method `
        }
        catch [System.Net.WebException] {
            $Err = Get-RestErrorMessage $_
            throw [Exception] "[$Me] [$($Err.statusCode)]: $($Err.message) $($Err.details)`n$($Err.validationErrors)`n"
        }

        
        # [Exact] Parameter
        # Search "Malware" normally returns both "Malware" and "Malware 2"
        if ($Exact) {
            $Pattern = "^$Name$"
            $Response | ForEach-Object {
                if($_.text -match $Pattern) {
                    return $_
                }
            }
            # No exact matches found
            return $null
        }

        # Return all responses.
        return $Response
    }


    End { }
}
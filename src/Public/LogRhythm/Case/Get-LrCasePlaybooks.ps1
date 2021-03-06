using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Get-LrCasePlaybooks {
    <#
    .SYNOPSIS
        Return a list of playbooks attached to a case.
    .DESCRIPTION
        The Get-LrCasePlaybooks cmdlet returns an object containing all the playbooks
        that has been assigned to a specific case.

        If a match is not found, this cmdlet will return null.
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
        Note: You can bypass the need to provide a Credential by setting
        the preference variable $SrfPreferences.LrDeployment.LrApiToken
        with a valid Api Token.
    .PARAMETER Id
        Unique identifier for the case, either as an RFC 4122 formatted string, or as a number.
    .INPUTS
        [System.Object]   ->  Id
    .OUTPUTS
        System.Object representing the returned LogRhythm playbooks on the applicable case.

        If a match is not found, this cmdlet will throw exception
        [System.Collections.Generic.KeyNotFoundException]
    .EXAMPLE
        PS C:\> Get-LrCasePlaybooks -Credential $Token -Id 8703
        ---
        id                 : E560822B-3685-48DE-AC25-0314B1C4124F
        name               : Phishing
        description        : Use this Playbook when someone has received a malicious phishing email that contains malicious code, a link to malicious code, or is employing social engineering to
                            obtain user credentials.

        originalPlaybookId : 510C7D5B-F058-4748-A948-233FAECB8348
        dateAdded          : 2019-12-23T13:31:26.0410191Z
        dateUpdated        : 2019-12-23T13:37:08.0763176Z
        lastUpdatedBy      : @{number=227; name=Domo, Derby; disabled=False}
        pinned             : False
        datePinned         :
        procedures         : @{total=7; notCompleted=7; completed=0; skipped=0; pastDue=0}

        id                 : 4CAB940D-CFF7-442E-A54A-5D4949FA783D
        name               : Compromised Account
        description        : This playbook assists analysts in handling expected cases of a compromised account.
        originalPlaybookId : 5CD58351-503E-41E4-B36C-F9C29BDD1508
        dateAdded          : 2019-12-23T13:36:04.3544575Z
        dateUpdated        : 2019-12-23T13:37:12.0184697Z
        lastUpdatedBy      : @{number=227; name=Domo, Derby; disabled=False}
        pinned             : False
        datePinned         :
        procedures         : @{total=6; notCompleted=6; completed=0; skipped=0; pastDue=0}
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
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 1
        )]
        [ValidateNotNullOrEmpty()]
        [object] $Id
    )

    Begin {
        $Me = $MyInvocation.MyCommand.Name
        
        $BaseUrl = $SrfPreferences.LRDeployment.CaseApiBaseUrl
        $Token = $Credential.GetNetworkCredential().Password

        # Enable self-signed certificates and Tls1.2
        Enable-TrustAllCertsPolicy        
    }


    Process {
        # Get Case Id
        $IdInfo = Test-LrCaseIdFormat $Id
        if (! $IdInfo.IsValid) {
            throw [ArgumentException] "Parameter [Id] should be an RFC 4122 formatted string or an integer."
        } else {
            # Convert CaseID Into to Guid
            if ($IdInfo.IsGuid -eq $false) {
                # Retrieve Case Guid
                $CaseGuid = (Get-LrCaseById -Id $Id).id
            } else {
                $CaseGuid = $Id
            }
        }

        
        # Request Headers
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Bearer $Token")
        

        # Request URI
        $Method = $HttpMethod.Get
        $RequestUri = $BaseUrl + "/cases/$CaseGuid/playbooks/"
        Write-Verbose "[$Me]: RequestUri: $RequestUri"

        # REQUEST
        try {
            $Response = Invoke-RestMethod `
                -Uri $RequestUri `
                -Headers $Headers `
                -Method $Method
        }
        catch [System.Net.WebException] {
            $Err = Get-RestErrorMessage $_

            switch ($Err.statusCode) {
                "404" {
                    throw [KeyNotFoundException] `
                        "[404]: Playbook Id $Id not found, or you do not have permission to view it."
                 }
                 "401" {
                     throw [UnauthorizedAccessException] `
                        "[401]: Credential '$($Credential.UserName)' is unauthorized to access 'lr-case-api'"
                 }
                Default {
                    throw [Exception] "[$Me] [$($Err.statusCode)]: $($Err.message) $($Err.details)`n$($Err.validationErrors)`n"
                }
            }
        }

        # Return all responses.
        return $Response
    }


    End { }
}
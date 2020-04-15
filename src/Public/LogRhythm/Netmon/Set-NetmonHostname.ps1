using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Set-NetmonHostname {
    <#
    .SYNOPSIS
        Retrieve the Host Details from the LogRhythm Entity structure.
    .DESCRIPTION
        Get-LrHostDetails returns a full LogRhythm Host object, including details..
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
    .PARAMETER Id
        [System.String] (Name or Int)
        Specifies a LogRhythm host object by providing one of the following property values:
          + List Name (as System.String), e.g. "MYSECRETHOST"
          + List Int (as System.Int), e.g. 2657

        Can be passed as ValueFromPipeline but does not support Arrays.
    .OUTPUTS
        PSCustomObject representing LogRhythm Entity Host record and its contents.
    .EXAMPLE
        PS C:\> Put-NetmonHostname

        hostname
        --------
        mynetmon
    .NOTES
        LogRhythm-API        
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [pscredential] $Credential = $SrfPreferences.LrNetmon.NmApiCredential,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNull()]
        [string] $Hostname
    )

    Begin {
        Enable-TrustAllCertsPolicy
        $BaseUrl = $SrfPreferences.LrNetmon.NmApiBaseUrl
        $NetmonAPI = $($Credential.GetNetworkCredential().UserName)+":"+$($Credential.GetNetworkCredential().Password)
        $Token = New-SrfBase64String -String $NetmonAPI
        
        # Request Headers
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Content-Type", "application/json")
        $Headers.Add("Authorization", "Basic $Token")

        # Request Method
        $Method = $HttpMethod.Put

        Write-Verbose ($Headers | Out-String) 

        # Request URL
        $RequestUri = $BaseUrl + "network/hostname"
    }

    Process {
        # Request Setup
        $Body = [PSCustomObject]@{ hostname = $Hostname } | ConvertTo-Json

        # Submit Request
        try {
            $Response = Invoke-RestMethod $RequestUri -Headers $Headers -Method $Method -Body $Body
        }
        catch [System.Net.WebException] {
            Write-Host $_
        }
        
    }

    End { 
        return $Response
    }
}
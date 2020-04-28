using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Get-NmNtp {
    <#
    .SYNOPSIS
        Retrieve the Netmon NTP server configuration.
    .DESCRIPTION
        Get-NetmonNtp returns the NTP configuration for the requested Netmon server.
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
    .OUTPUTS
        PSCustomObject representing LogRhythm Netmon NTP record and its contents.
    .EXAMPLE
        PS C:\> Get-NetmonNtp

        hostname
        --------
        netmon
    .NOTES
        LogRhythm-API        
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [pscredential] $Credential = $SrfPreferences.LrNetmon.n1.NmApiCredential
    )

    Begin {
        Enable-TrustAllCertsPolicy
        $BaseUrl = $SrfPreferences.LrNetmon.n1.NmApiBaseUrl
        $NetmonAPI = $($Credential.GetNetworkCredential().UserName)+":"+$($Credential.GetNetworkCredential().Password)
        $Token = New-SrfBase64String -String $NetmonAPI
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Basic $Token")
        $Method = $HttpMethod.Get

        Write-Verbose ($Headers | Out-String) 
    }

    Process {


        # Request Setup
        
        $RequestUri = $BaseUrl + "configuration/ntp"
        try {
            $Response = Invoke-RestMethod $RequestUri -Headers $Headers -Method $Method
        }
        catch [System.Net.WebException] {
            Write-Host $_
        }
        
    }

    End { 
        return $Response
    }
}
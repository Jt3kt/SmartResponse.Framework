using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Set-NetmonNtp {
    <#
    .SYNOPSIS
        Set the NTP Server property for a LogRhythm Netmon server.
    .DESCRIPTION
        Set-NetmonHtp sets the primary and secondary NTP server properties for a Netmon server.
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
    .PARAMETER Primary
        [System.String] (Name or IP)
        Specifies a NTP server IP Address or hostname for the primary NTP server.
    .PARAMETER Secondary
        [System.String] (Name or IP)
        Specifies a NTP server IP Address or hostname for the primary NTP server.
    .OUTPUTS
        PSCustomObject representing LogRhythm NTP configuration.
    .EXAMPLE
        PS C:\> Put-NetmonNtp


    .NOTES
        LogRhythm-API        
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [pscredential] $Credential = $SrfPreferences.LrNetmon.n1.NmApiCredential,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNull()]
        [string] $Primary,

        [Parameter(Mandatory = $false, Position = 1)]
        [ValidateNotNull()]
        [string] $Secondary = ""
    )

    Begin {
        Enable-TrustAllCertsPolicy
        $BaseUrl = $SrfPreferences.LrNetmon.n1.NmApiBaseUrl
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
        $RequestUri = $BaseUrl + "configuration/ntp"
    }

    Process {
        # Request Setup
        $Body = [PSCustomObject]@{ primary = $Primary
                                   secondary = $Secondary } | ConvertTo-Json

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
using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Get-NetmonSystemInfo {
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
        PS C:\> Get-NetmonSystemInfo
        ----
        name                  : Network Monitor
        licensedName          : Network Monitor Freemium
        versions              : {4.0.2.1093}
        ipAddress             : 192.168.5.180
        macAddress            : 00:05:55:55:55:55
        licenseExpirationDate : unlimited
        masterLicenseId       : None
        machineID             : 15555555555555555555555495
    .NOTES
        LogRhythm-API        
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [pscredential] $Credential = $SrfPreferences.LrNetmon.NmApiCredential
    )

    Begin {
        Enable-TrustAllCertsPolicy
        $BaseUrl = $SrfPreferences.LrNetmon.NmApiBaseUrl
        $NetmonAPI = $($Credential.GetNetworkCredential().UserName)+":"+$($Credential.GetNetworkCredential().Password)
        $Token = New-SrfBase64String -String $NetmonAPI
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Basic $Token")
        $Method = $HttpMethod.Get

        Write-Verbose ($Headers | Out-String) 
    }

    Process {


        # Request Setup
        
        $RequestUri = $BaseUrl + "systemInfo"
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
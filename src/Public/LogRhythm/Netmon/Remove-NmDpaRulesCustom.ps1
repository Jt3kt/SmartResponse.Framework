using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Remove-NmDpaRulesCustom {
    <#
    .SYNOPSIS
        Remove all Custom DPA Rules.
    .DESCRIPTION
        Remove-NmDpaRulesCustom removes all Custom DPA Rules.
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
    .OUTPUTS
        An empty response.
    .EXAMPLE
        PS C:\> Remove-NetmonApplications
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

        # Request Headers
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Content-Type", "application/json")
        $Headers.Add("Authorization", "Basic $Token")

        # Request Method
        $Method = $HttpMethod.Delete

        Write-Verbose ($Headers | Out-String) 

        # Request URL
        $RequestUri = $BaseUrl + "dpaRules/custom"
    }

    Process {
        # Submit Request
        try {
            $Response = Invoke-RestMethod $RequestUri -Headers $Headers -Method $Method
        }
        catch [System.Net.WebException] {
            Write-Host $_
        }

        return $Response
        
    }

    End { }
}
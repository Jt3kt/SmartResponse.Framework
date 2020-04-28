using assembly System.Net.Http
using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Add-NmDpaRulesCustom {
    <#
    .SYNOPSIS
        Upload a .lrl DPA Rule to Netmon.
    .DESCRIPTION
        Upload-NmDpaRulesCustom removes all Custom DPA Rules.
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
        $Headers.Add("Content-Type", "multipart/form-data")
        $Headers.Add("Authorization", "Basic $Token")

        # Request Method
        $Method = $HttpMethod.Post

        Write-Verbose ($Headers | Out-String) 

        # Request URL
        $RequestUri = $BaseUrl + "dpaRules/actions/upload"
    }

    Process {
        # Submit Request
        $client = New-Object System.Net.Http.HttpClient
        $client.DefaultRequestHeaders.add("Authorization", "Basic $Token")

        $file = 'N:\Projects\git\SmartResponse.Framework\Flow_ChatFileTransfer3.lrl'
        $mimeType = [System.Web.MimeMapping]::GetMimeMapping($file)
        $multipartContent = [System.Net.Http.MultipartFormDataContent]::new()
        $FileStream = [System.IO.FileStream]::new($file, [System.IO.FileMode]::Open)
        $fileHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
        $fileHeader.Name = "file"
        $fileHeader.FileName = (Split-Path $file -leaf)
        $fileContent = [System.Net.Http.StreamContent]::new($FileStream)
        $multipartContent.Add($fileContent, $fileHeader.FileName, $fileHeader.Name)
        #$fileContent.Headers.ContentDisposition = $fileHeader
        #$fileContent.Headers.ContentType = $mimeType

        
        try {
            $Response = $client.PostAsync($RequestUri, $content).Result
        }
        catch [System.Net.WebException] {
            Write-Host $_
            Write-Host "woops"
        }
        #$FileStream.Close()
        #$FileStream.Dispose()

        return $Response
        
    }

    End { }
}
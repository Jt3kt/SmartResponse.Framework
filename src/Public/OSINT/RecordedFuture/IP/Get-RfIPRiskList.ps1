using namespace System
using namespace System.Collections.Generic

Function Get-RfIPRiskList {
    <#
    .SYNOPSIS
        Get RecordedFuture IP threat list.
    .DESCRIPTION
        Get   
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
        
        Note: You can bypass the need to provide a Credential by setting
        the preference variable $SrfPreferences.VirusTotal.VtApiToken
        with a valid Api Token.
    .PARAMETER Domain
        Domain
    .INPUTS
        System.String -> Domain
    .OUTPUTS
        PSCustomObject representing the report results.
    .EXAMPLE
        PS C:\> Get-VtDomainReport -Credential $token -Url "logrhythm.com"
        ---
    .NOTES
        VirusTotal-API
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [string] $Token = $SrfPreferences.OSINT.RecordedFuture.APIKey,

        [string] $List,
        [string] $Format,
        [bool] $Compressed = $false,
        [int] $MinimumRisk = 65,
        [int] $MaximumRisk = 99,
        [switch] $ValuesOnly
    )

    Begin {
        $Token = ""
        $BaseUrl = $SrfPreferences.OSINT.RecordedFuture.BaseUrl
        #$Token = $Credential.GetNetworkCredential().Password

        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("X-RFToken", $Token)

        Write-Verbose "$($Headers | Out-String)"

        # Request Setup
        $Method = $HttpMethod.Get

    }

    Process {
        $ResultsList = [list[psobject]]::new()
        #$Gzip = "false"
        #$Format = 'csv/splunk'
        $QueryParams = [Dictionary[string,string]]::new()

        # Format
        $QueryParams.Add("format", $Format)

        # Compression
        $QueryParams.Add("gzip", $Gzip)

        # List
        $QueryParams.Add("list", $List)


        if ($QueryParams.Count -gt 0) {
            $QueryString = $QueryParams | ConvertTo-QueryString
            Write-Verbose "[$Me]: QueryString is [$QueryString]"
        }



        # Define Search URL
        $RequestUrl = $BaseUrl + "ip/risklist" + $QueryString
        Write-Verbose "[$Me]: RequestUri: $RequestUrl"

        Try {
            $Results = Invoke-RestMethod $RequestUrl -Method $Method -Headers $Headers | ConvertFrom-Csv
        }
        catch [System.Net.WebException] {
            If ($_.Exception.Response.StatusCode.value__) {
                $HTTPCode = ($_.Exception.Response.StatusCode.value__ ).ToString().Trim()
                Write-Verbose "HTTP Code: $HTTPCode"
            }
            If  ($_.Exception.Message) {
                $ExceptionMessage = ($_.Exception.Message).ToString().Trim()
                Write-Verbose "Exception Message: $ExceptionMessage"
                return $ExceptionMessage
            }
        }
        foreach ($Value in $Results) {
            Write-Verbose "Value: $Value"
            if ($MinimumRisk -and $MaximumRisk) {
                if ($Value.Risk -le $MaximumRisk -and $Value.Risk -ge $MinimumRisk) {
                    $ResultsList += $Value
                }
            } elseif ($MinimumRisk) {
                if ($($Value.Risk) -ge $MinimumRisk) {
                    $ResultsList += $Value
                }
            } elseif ($MaximumRisk) {
                if ($Value.Risk -le $MaximumRisk) {
                    $ResultsList += $Value
                }
            }
        }
        if ($MaximumRisk -or $MinimumRisk) {
            if ($ValuesOnly) {
                Return $ResultsList.Name
            } else {
                Return $ResultsList
            }
        } else {
            if ($ValuesOnly) {
                Return $Result.Name
            } else {
                Return $Result
            }
        }
    }
 

    End { 
    }
}
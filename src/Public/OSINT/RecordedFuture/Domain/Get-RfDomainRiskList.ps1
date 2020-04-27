using namespace System
using namespace System.Collections.Generic

Function Get-RfDomainRiskList {
    <#
    .SYNOPSIS
        Get RecordedFuture Domain threat list.
    .DESCRIPTION
        Get RecordedFuture Domain threat list results.  
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
        
        Note: You can bypass the need to provide a Credential by setting
        the preference variable $SrfPreferences.VirusTotal.VtApiToken
        with a valid Api Token.
    .PARAMETER MinimumRisk
        Minimum risk level of result values returned.
    .PARAMETER MaximumRisk
        Maximum risk level of result values returned.
    .PARAMETER ValuesOnly
        Switch to return Name values only.
    .INPUTS
        int32  -> MinimumRisk
        int32  -> MaxiumumRisk
        switch -> ValuesOnly
    .OUTPUTS
        PSCustomObject representing the report results.
    .EXAMPLE
        PS C:\> Get-VtDomainReport -Credential $token -Url "logrhythm.com"
        ---
        Name                                                               Risk RiskString EvidenceDetails
        ----                                                               ---- ---------- ---------------
        account-update.amazon.co.jp.u0005426m0200jp.u033jp5420.info        67   3/40       {"EvidenceDetails": [{... 
        www.appleid.com-4pple-santekpellasisesesis-communitys-updateds.net 67   3/40       {"EvidenceDetails": [{... 
        amazon.co.jp.account-update.gocheckjpid.mixh.jp                    67   3/40       {"EvidenceDetails": [{... 
        webmail.amazon-info.duckdns.org                                    66   2/40       {"EvidenceDetails": [{...
    .NOTES
        Recorded Future - API
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

        # Valid Entries
        $ValidFormats = @("csv/splunk", "xml/stix/1.1.1", "xml/stix/1.2")
        $ValidLists = @("analystNote", "cncNameserver", "cncSite", "cncUrl", "compromisedUrl", "ddns", "defanged", "dhsAis", "historicalThreatListMembership", "large", "linkedToCyberAttack", "malwareAnalysis", "multiBlacklist", "phishingUrl", "predictionModelVerdict", "punycode", "ransomwareDistribution", "ransomwarePayment", "recentAnalystNote", "recentCovidLure", "recentCovidSpam", "recentDefanged", "recentDhsAis", "recentLinkedToCyberAttack", "recentMalwareAnalysis", "recentPhishingLureMalicious", "recentPunycode", "recentRelatedNote", "recentThreatResearcher", "recentWeaponizedDomain", "recentlyDefaced", "relatedNote", "resolvedMaliciousIp", "resolvedSuspiciousIp", "resolvedUnusualIp", "resolvedVeryMaliciousIp", "rfTrending", "threatResearcher", "weaponizedDomain")
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
        $RequestUrl = $BaseUrl + "domain/risklist" + $QueryString
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

    End { }
}
using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Add-LrAlarmToCase {
    <#
    .SYNOPSIS
        Add one or more alarms to a LogRhythm case.
    .DESCRIPTION
        The Add-LrAlarm to case cmdlet adds one or more alarms to
        a LogRhythm case.
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
        Note: You can bypass the need to provide a Credential by setting
        the preference variable $SrfPreferences.LrDeployment.LrApiToken
        with a valid Api Token.
    .PARAMETER Id
        The Id of the case for which to add alarms.
    .PARAMETER AlarmNumbers
        The Id of the alarms to add to the provided Case Id.
    .INPUTS
        System.Int32[] -> AlarmNumbers
    .OUTPUTS
        The updated [LrCase] object.
    .EXAMPLE
        PS C:\> AddLrAlarmToCase -Id 1780 -AlarmNumbers @(21202, 21203, 21204)
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


        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNull()]
        [object] $Id,


        [Parameter(Mandatory = $true, Position = 2)]
        [ValidateNotNull()]
        [int[]] $AlarmNumbers
    )


    #region: BEGIN                                                                       
    Begin {
        $Me = $MyInvocation.MyCommand.Name
        
        $BaseUrl = $SrfPreferences.LRDeployment.CaseApiBaseUrl
        $Token = $Credential.GetNetworkCredential().Password

        # Enable self-signed certificates and Tls1.2
        Enable-TrustAllCertsPolicy
    }
    #endregion



    Process {
        # Get Case Id
        $IdInfo = Test-LrCaseIdFormat $Id
        if (! $IdInfo.IsValid) {
            throw [ArgumentException] "Parameter [Id] should be an RFC 4122 formatted string or an integer."
        }

        #region: Request Headers                                                         
        # Request Headers
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Bearer $Token")
        $Headers.Add("Content-Type","application/json")


        # Request URI
        $Method = $HttpMethod.Post
        $RequestUri = $BaseUrl + "/cases/$Id/evidence/alarms/"
        #endregion



        #region: Request Body                                                            
        # Request Body - ensure we always pass an array per API spec
        if (! ($AlarmNumbers -Is [System.Array])) {
            $AlarmNumbers = @($AlarmNumbers)
        }
        # Convert to Json
        $Body = [PSCustomObject]@{
            alarmNumbers = $AlarmNumbers
        } | ConvertTo-Json
        Write-Verbose "[$Me] Request Body:`n$Body"
        #endregion



        #region: Send Request                                                            
        try {
            $Response = Invoke-RestMethod `
                -Uri $RequestUri `
                -Headers $Headers `
                -Method $Method `
                -Body $Body
        }
        catch [System.Net.WebException] {
            $Err = Get-RestErrorMessage $_
            throw [Exception] "[$Me] [$($Err.statusCode)]: $($Err.message) $($Err.details)`n$($Err.validationErrors)`n"
        }

        # The response is an array of alarms added to the case
        $AddedAlarms = $Response
        Write-Verbose "Added $($AddedAlarms.Count) alarms to case."        
        #endregion



        #region: Get Updated Case                                                        
        Write-Verbose "[$Me] Getting Updated Case"
        try {
            $UpdatedCase = Get-LrCaseById -Credential $Credential -Id $Id    
        }
        catch {
            Write-Verbose "Encountered error while retrieving updated case $Id."
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }

        # Done!
        return $UpdatedCase
    }
        #endregion


    End { }
}
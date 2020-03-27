using namespace System
using namespace System.IO
using namespace System.Collections.Generic
function Get-SrfValkaryieUrl {
    Param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        $Credential = $SrfPreferences.ComodoValkarie.ValkarieApiToken,

        [Parameter(Mandatory = $true, ValueFromPipeline=$true, Position = 1)]
        [string]$FileHash,

        [switch]$UseCache = $false
    )
    Begin {
        $RequestUrl =  $SrfPreferences.ComodoValkarie.ValkarieBaseUrl+"file/query/$FileHash?use_cache=$UseCache"
        $RequestUrl = "https://verdict.valkyrie.comodo.com/api/v1/url/query?url=$Uri&analyze=true"

        #$Token = $Credential.GetNetworkCredential().Password
        $Token = ""
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("X-Api-Key", "$Token")
        #$Headers.Add("Content-Type","application/json")
        $Method = $HttpMethod.Get

        $cmdVerdict = ""
        $cmdResultID = ""
        $cmdResultMessage = ""
        $cmdReturnCode = ""
        $cmdLastAnalysis = ""
    }

    Process {
        # Send Request
        try {
            write-Host "$($Headers | Out-String)"
            $Response = Invoke-RestMethod $RequestUrl -Headers $Headers -Method POST
        }
        catch [System.Net.WebException] {
            $Err = Get-RestErrorMessage $_
            Write-Host "Exception invoking Rest Method: [$($Err.statusCode)]: $($Err.message)" -ForegroundColor Yellow
            $PSCmdlet.ThrowTerminatingError($PSItem)
            return $false
        }
    }

    End {
        return $Response
    }

}
Get-SrfValkarieUrl
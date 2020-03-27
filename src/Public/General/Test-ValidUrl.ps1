using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Test-ValidUrl {
    <#
    .SYNOPSIS
        Validates if value submitted is a valid URL Address.
    .DESCRIPTION
        The Test-ValidUrl cmdlet displays information about a given variable.
    .PARAMETER Id
        The parameter to be tested.
    .INPUTS
        [System.String] -> Url
    .OUTPUTS
        System.Object with IsValid, Value, Domain, Uri
    .EXAMPLE
        C:\PS> Test-ValidUrl https://community.logrhythm.com/
           IsValid   Value         IsPrivate
           -----     -----         -----
           True      192.168.5.1   True
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework        
    #>

    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position=0
        )]
        [ValidateNotNull()]
        [string] $Url
    )

    $OutObject = [PSCustomObject]@{
        IsValid     =   $false
        Value       =   $IP
        Domain      =   $null
        Protocol    =   $null
        Subdomain   =   $null
        SLD         =   $null
        TLD         =   $null
        Path        =   $null
    }

    # Check if ID value is an integer
    if ($IP -as [ipaddress]) {
        $OutObject.Value = $IP.ToString()
        $OutObject.IsValid = $true
        if ($IP -Match '(^127\.)|(^192\.168\.)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)') {
            $OutObject.IsPrivate =$true
        }
        else {
            $OutObject.IsPrivate = $false
        }
    } else {
        $OutObject.IsValid = $false
    }

    return $OutObject
}

Test-ValidIPv4Address
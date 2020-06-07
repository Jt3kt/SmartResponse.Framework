using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function New-LrPlaybook {
    <#
    .SYNOPSIS
        Create a new playbook to a LogRhythm playbook.
    .DESCRIPTION
        The New-LrPlaybookToCase cmdlet adds a playbook to LogRhythm.
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
        Note: You can bypass the need to provide a Credential by setting
        the preference variable $SrfPreferences.LrDeployment.LrApiToken
        with a valid Api Token.
    .PARAMETER Name
        Name of the new Playbook.  Limited to 150 characters.
    .PARAMETER Description
        Summary of the playbook.  Limited to 1000 characters.
    .PARAMETER Permissions
        Roles and entities that can read/write to this playbook.
    .PARAMETER Entities
        List of entity numbers that can access this playbook.  An empty list will assign the playbook to the user's default entity.
    .PARAMETER Tags
        List of tag (identifiers or names).
    .INPUTS
        [System.Object] "Id" ==> [Id] : The ID of the Case to modify.
    .OUTPUTS
        PSCustomObject representing the added playbook.
    .EXAMPLE
        PS C:\> New-LrPlaybook -Name "This ones better 9." -Description "Just a bit different." -Tags @("Boxers", "Sticker") -Force

        id            : E10111E4-DDC7-4D98-A619-5B80CA55BABF
        name          : This ones better 9.
        description   : Just a bit different.
        permissions   : @{read=privateOwnerOnly; write=privateOwnerOnly}
        owner         : @{number=-100; name=LogRhythm Administrator; disabled=False}
        retired       : False
        entities      : {@{number=1; name=Primary Site; fullName=Primary Site}}
        dateCreated   : 2020-06-06T19:31:24.6916651Z
        dateUpdated   : 2020-06-06T19:31:24.6916651Z
        lastUpdatedBy : @{number=-100; name=LogRhythm Administrator; disabled=False}
        tags          : {@{number=8; text=Boxers}, @{number=7; text=Sticker}}
    .NOTES
        LogRhythm-API
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework        
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [pscredential] $Credential = $SrfPreferences.LrDeployment.LrApiCredential,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)]
        [string] $Name,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 2)]
        [string] $Description,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 3)]
        [string] $Permissions,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 4)]
        [string] $Entities,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 5)]
        [object[]] $Tags,

        [Parameter(Mandatory = $false, Position = 6)]
        [switch] $Force
    )


    Begin {
        $Me = $MyInvocation.MyCommand.Name
        $BaseUrl = $SrfPreferences.LRDeployment.CaseApiBaseUrl
        $Token = $Credential.GetNetworkCredential().Password

        # Request Headers
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Bearer $Token")
        $Headers.Add("Content-Type","application/json")

        # Request URI
        $Method = $HttpMethod.Post

        # Int reference
        $_int = 1
    }


    Process {
        # Establish General Error object Output
        $ErrorObject = [PSCustomObject]@{
            Code                  =   $null
            Error                 =   $false
            Type                  =   $null
            Note                  =   $null
            ResponseUri           =   $null
            Value              =   $Name
        }

        # Validate Playbook Ref
        $Pb = Get-LrPlaybooks -Name $Name -Credential $Credential -Exact
        if ($Pb.Name -eq $Name) {
            $ErrorObject.Code = $Pb.id
            $ErrorObject.Error = $true
            $ErrorObject.Type = "Duplicate"
            $ErrorObject.Note = "Playbook with same name exists."
            $ErrorObject.ResponseUri = "$BaseUrl/playbooks/$($Pb.id)/"
            return $ErrorObject
        }

        if($Tags) {
            $_tags = @()
            # multiple values, create an object
            ForEach ($Tag in $Tags) {
                Write-Verbose "$(Get-TimeStamp) Processing Tag: $Tag"
                $TagResults = Get-LrTagNumber $Tag
                if (($TagResults.Error -eq $True) -or ($null -eq $TagResults)) {
                    Write-Verbose "$(Get-TimeStamp) Non-existant tag: $Tag"
                    # If force is enabled, create the tag
                    if ($Force) {
                        Write-Verbose "$(Get-TimeStamp) Force Set - Creating Tag"
                        if (!([int]::TryParse($Tag, [ref]$_int))) {
                            $NewTagResults = New-LrTag -Tag $Tag
                            if (($null -eq $NewTagResults.Error) -or ($NewTagResults.Error -eq "")) {
                                Write-Verbose "$(Get-TimeStamp) Adding new tag number: $($NewTagResults.number) to variable: _tags"
                                $_tags += $NewTagResults.number
                            }
                        } else {
                            $ErrorObject.Code = "Value"
                            $ErrorObject.Error = $true
                            $ErrorObject.Type = "Type mismatch"
                            $ErrorObject.Note = "Request tag is integer.  New tags must be type String."
                            $ErrorObject.ResponseUri = "Reference: New-LrTag"
                            $ErrorObject.Value = $Tag
                            return $ErrorObject
                        }
                    } else {
                        $ErrorObject.Code = "Value"
                        $ErrorObject.Error = $true
                        $ErrorObject.Type = "Missing tag"
                        $ErrorObject.Note = "Request tag does not exist.  Create tag or re-run with -force."
                        $ErrorObject.ResponseUri = "get-lrtags -name $tag -exact"
                        $ErrorObject.Value = $Tag
                        return $ErrorObject
                    }
                # Tag exists, set _tags to TagResults
                } else {
                    Write-Verbose "$(Get-TimeStamp) Adding existing tag number: $TagResults to variable: _tags"
                    $_tags += $TagResults
                }
            }
        # No tags requested, set tags to no value.
        } else {
            $_tags = $null
        }

        if($Entities) {
            $_Entities = Get-LrEntities -Name $Entities
        } else {
            $_Entities = 1
        }

        $RequestUri = $BaseUrl + "/playbooks/"
        Write-Verbose "[$Me]: RequestUri: $RequestUri"

        # Request Body
        $Body = [PSCustomObject]@{
            name = $Name
            description = $Description
            permissions = [PSCustomObject]@{
                read = "privateOwnerOnly"
                write = "privateOwnerOnly"
            }
            entities = @(
                $_Entities
        
            )
            tags = @(
                $_tags
            )
        }
        $Body = $Body | ConvertTo-Json
        Write-Verbose "[$Me]: Body: $Body"


        # Request
        try {
            $Response = Invoke-RestMethod `
                -Uri $RequestUri `
                -Headers $Headers `
                -Method $Method `
                -Body $Body
        }
        catch [System.Net.WebException] {
            $Err = Get-RestErrorMessage $_
            $ErrorObject.Code = $Err.statusCode
            $ErrorObject.Type = "WebException"
            $ErrorObject.Note = $Err
            $ErrorObject.ResponseUri = $RequestUri
            $ErrorObject.Error = $true
            return $ErrorObject
        }

        return $Response
    }


    End { }
}
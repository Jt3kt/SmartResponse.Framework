function pluginSpearIns {
    Param (
        [string]$MessageBody,
        [string]$SpammerDisplayName
    )

    Begin {
        [string[]]$keyFNames = $null
        [string[]]$keyLNames = $null
        # Populate list of monitored users
        [string[]]$keyNames = Get-ListItems -List 'MyList'

        # Split list into First and Last names
        $keyNames | ForEach-Object {
            [string[]]$keyFNames += $_.Split(" ")[0]
            [string[]]$keyLNames += $_.Split(" ")[1] 
        }
    }

    Process {

        $SpearMatches = @()

        # Inspect Message Body for Full and Partial Matches
        If([string]$MessageBody -match ($keyNames -join "|")) {
            $SpearMatches += @{
                Type = "Full"
                Location = "Message Body"
                Name = "null"
            } 
        } elseif ([string]$sprMessageBody -match ($keyFNames -join "|") -or ([string]$sprMessageBody -match ($keyLNames -join "|"))) {
            $SpearMatches += @{
                Type = "Partial"
                Location = "Message Body"
                Name = "null"
            }
        } else {
            Logger -logSev "i" -Message "No key names identified in messageBody"
        }

        If([string]$sprDisplayName -match ($keyNames -join "|")) {
            $SpearMatches += @{
                Type = "Full"
                Location = "Display Name"
                Name = "null"
            }
        } elseif ([string]$sprDisplayName -match ($keyFNames -join "|") -or ([string]$sprDisplayName -match ($keyLNames -join "|"))) {
            $SpearMatches += @{
                Type = "Partial"
                Location = "Display Name"
                Name = "null"
            }
        } else {
            Logger -logSev "i" -Message "No key names identified in Display Name"
        }

        if ($MatchResults) {
            $MatchResults = Add-Member -NotePropertyName SpearMatches -NotePropertyValue $SpearMatches
            $Response = [PSCustomObject]@{
                Match    =   $True
                Results   =   @(
                    $MatchResults
                )
            }
        } else {
            $Response = [PSCustomObject]@{
                Match   =   $false
                Results   =   @()
            }
        }
    }


    End {
        Return $Response
    }
}
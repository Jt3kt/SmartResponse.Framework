function New-SrfBase64String(
    [string] $String
    )
{
    Begin {

    }

    Process {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($String)
        $EncodedString = [Convert]::ToBase64String($bytes)
        Return $EncodedString
    }

    End { } 
}
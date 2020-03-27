function New-PieHashString(
    [string] $inputString, 
    [String] $hashType = 'sha256')
{
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($inputString)
    $hashAlgorithm = [System.Security.Cryptography.HashAlgorithm]::Create($hashType)
    $stringBuild = New-Object System.Text.StringBuilder

    $hashAlgorithm.ComputeHash($bytes) | ForEach-Object { $null = $StringBuild.Append($_.ToString("x2")) } 

    
    $stringBuild.ToString() 
}
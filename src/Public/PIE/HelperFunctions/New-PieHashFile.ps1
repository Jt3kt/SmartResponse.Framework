function New-PieHashFile(
    [System.IO.FileInfo] $file = $(Throw 'Usage: Get-Hash [System.IO.FileInfo]'), 
    [String] $hashType = 'sha256')
{
    $stream = $null;  
    [string] $result = $null;
    $hashAlgorithm = [System.Security.Cryptography.HashAlgorithm]::Create($hashType )
    $stream = $file.OpenRead();
    $hashByteArray = $hashAlgorithm.ComputeHash($stream);
    $stream.Close();

    trap {
        if ($null -ne $stream) { $stream.Close(); }
        break;
    }

    # Convert the hash to Hex
    $hashByteArray | ForEach-Object { $result += $_.ToString("X2") }
    return $result
}
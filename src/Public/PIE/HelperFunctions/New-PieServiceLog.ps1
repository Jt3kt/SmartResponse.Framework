function New-PieSvcLog {
    Param(
        $logLevel = $pieLogLevel,
        $logSev,
        $Message,
        $Verbose = $pieLogVerbose
    )
    $cTime = "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
    #Create phishLog if file does not exist.
    if ( $(Test-Path $runLog -PathType Leaf) -eq $false ) {
        Set-Content $runLog -Value "PIE Powershell Runlog for $date"
        Write-Output "$cTime ALERT - No runLog detected.  Created new $runLog" | Out-File $runLog
    }
    if ($LogLevel -like "info" -Or $LogLevel -like "debug") {
        if ($logSev -like "s") {
            Write-Output "$cTime STATUS - $Message" | Out-File $runLog -Append
        } elseif ($logSev -like "a") {
            Write-Output "$cTime ALERT - $Message" | Out-File $runLog -Append
        } elseif ($logSev -like "e") {
            Write-Output "$cTime ERROR - $Message" | Out-File $runLog -Append
        }
    }
    if ($LogSev -like "i") {
        Write-Output "$cTime INFO - $Message" | Out-File $runLog -Append
    }
    if ($LogSev -like "d") {
        Write-Output "$cTime DEBUG - $Message" | Out-File $runLog -Append
    }
    Switch ($logSev) {
        e {$logSev = "ERROR"}
        s {$logSev = "STATUS"}
        a {$logSev = "ALERT"}
        i {$logSev = "INFO"}
        d {$logSev = "DEBUG"}
        default {$logSev = "LOGGER ERROR"}
    }
    if ( $Verbose -eq "True" ) {
        Write-Host "$cTime - $logSev - $Message"
    }
}
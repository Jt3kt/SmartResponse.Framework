function New-PieAnalysisLog {
    Param(
    $logMessageBody = $messageBody,
    $logSender = $spammer,
    $logRecipient = $reportedBy,
    $logThreatScore = $threatScore,
    $logCaseNum = $caseNumber
    )
    $cTime = "{0:MM/dd/yy} {0:HH:mm:ss}" -f (Get-Date)
    #Create phishLog if file does not exist.
    if ( $(Test-Path $pieLog -PathType Leaf) -eq $false ) {
        Set-Content $pieLog -Value "PIE Powershell pielog for $date"
        Write-Output "$cTime ALERT - No pieLog detected.  Created new $pieLog" | Out-File $pieLog
    }

    Try {
        $logHash = Create-Hash -inputString $logMessageBody
    } Catch {
        Logger -logSev "e" -Message "Unable to create logMessageBody hash"
    }
    Try {
        Write-Output "$cTime; $logCaseNum; $logThreatScore; $logHash; $logSender; $logRecipient" | Out-File $pieLog -Append
    } Catch {
        Logger -logSev -e -Message "Unable to append entry to pielog.  Case: $logCaseNum Hash: $logHash"
    }
}
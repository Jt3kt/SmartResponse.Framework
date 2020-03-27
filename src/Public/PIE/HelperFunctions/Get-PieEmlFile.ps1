#Enable support for .eml format
#From https://gallery.technet.microsoft.com/office/Blukload-EML-files-to-e1b83f7f
Function Get-PieEmlFile
{
    Param
    (
        $EmlFileName
    )
    Begin{
        $EMLStream = New-Object -ComObject ADODB.Stream
        $EML = New-Object -ComObject CDO.Message
    }

    Process{
        Try{
            $EMLStream.Open()
            $EMLStream.LoadFromFIle($EmlFileName)
            $EML.DataSource.OpenObject($EMLStream,"_Stream")
        }
        Catch
        {
        }
    }
    End{
        return $EML
    }
}
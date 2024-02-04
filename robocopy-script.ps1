# Script developed by David Fernandes | Terabyte in 2024
$hostname = hostname
$mac = Get-WmiObject win32_networkadapterconfiguration | Where-Object { $_.IPEnabled -eq "TRUE" } | Select-Object macaddress
$mac = $mac.macaddress -replace ":", ""
$timestampStart = Get-Date -Format "dd-MM-yyyy_HH:mm"
$url = "http://localhost:8080/api/log"
$bckpOrigin = "C:\Users\david\Documents\backup\origin"
$bckpDest = "C:\Users\david\Documents\backup\destiny"
$logFile = "C:\Users\david\Documents\backup\log\backup_$timestampStart.txt"

$dataObject = New-Object PSObject
Add-Member -inputObject $dataObject -memberType NoteProperty -name "hostname" -value $hostname
Add-Member -inputObject $dataObject -memberType NoteProperty -name "mac" -value $mac
Add-Member -inputObject $dataObject -memberType NoteProperty -name "timestampStart" -value $timestampStart
Add-Member -inputObject $dataObject -memberType NoteProperty -name "timestampEnd" -value $null
Add-Member -inputObject $dataObject -memberType NoteProperty -name "totalDirs" -value $null
Add-Member -inputObject $dataObject -memberType NoteProperty -name "totalFiles" -value $null
Add-Member -inputObject $dataObject -memberType NoteProperty -name "totalMBytes" -value $null
Add-Member -inputObject $dataObject -memberType NoteProperty -name "copiedDirs" -value $null
Add-Member -inputObject $dataObject -memberType NoteProperty -name "copiedFiles" -value $null
Add-Member -inputObject $dataObject -memberType NoteProperty -name "copiedMBytes" -value $null
Add-Member -inputObject $dataObject -memberType NoteProperty -name "failedDirs" -value $null
Add-Member -inputObject $dataObject -memberType NoteProperty -name "failedFiles" -value $null
Add-Member -inputObject $dataObject -memberType NoteProperty -name "failedMBytes" -value $null

robocopy $bckpOrigin $bckpDest /mir /e /log:$logFile
$timestampEnd = Get-Date -Format "dd-MM-yyyy_HH:mm"
$dataObject.timestampEnd = $timestampEnd

$logReport = Get-Content $logFile

foreach ($line in $logReport) {
  $line = $line -replace ('[^a-zA-Z\d\s:]', '')
  switch -Regex ($line) {
    'Diretrios' {
      Write-Output  "òóôÒÓÔ: $line"
      $dirs = $_.Replace('Diretrios:', '').Trim()
      $dirs = $dirs -split '\s+'

      $dataObject.totalDirs = $dirs[0]
      $dataObject.copiedDirs = $dirs[1]
      $dataObject.failedDirs = $dirs[4]
    }

    '^\s+Arquivos:\s[^*]' {
      $files = $_.Replace('Arquivos:', '').Trim()
      $files = $files -split '\s+'

      $dataObject.totalFiles = $files[0]
      $dataObject.copiedFiles = $files[1]
      $dataObject.failedFiles = $files[4]
    }

    '^\s+Bytes:\s*' {
      $bytes = $_.Replace('Bytes:', '').Trim()
      $bytes = $bytes -split '\s+'
      #The raw text from the log file contains a k,m,or g after the non zero numers.
      #This will be used as a multiplier to determin the size in MB.
      $counter = 0
      $tempByteArray = 0, 0, 0, 0, 0, 0
      $tempByteArrayCounter = 0
      foreach ($column in $bytes) {
        if ($column -eq 'k') {
          $tempByteArray[$tempByteArrayCounter - 1] = "{0:N2}" -f ([single]($bytes[$counter - 1]) / 1024)
          $counter += 1
        }
        elseif ($column -eq 'm') {
          $tempByteArray[$tempByteArrayCounter - 1] = "{0:N2}" -f $bytes[$counter - 1]
          $counter += 1
        }
        elseif ($column -eq 'g') {
          $tempByteArray[$tempByteArrayCounter - 1] = "{0:N2}" -f ([single]($bytes[$counter - 1]) * 1024)
          $counter += 1
        }
        else {
          $tempByteArray[$tempByteArrayCounter] = $column
          $counter += 1
          $tempByteArrayCounter += 1
        }
      }
      $dataObject.totalMBytes = $tempByteArray[0]
      $dataObject.copiedMBytes = $tempByteArray[1]
      $dataObject.failedMBytes = $tempByteArray[4]
    }
  }
}

Write-Output $dataObject
$jsonBody = $dataObject | ConvertTo-Json
$resp = Invoke-RestMethod -Uri $url -Method Post -Body $jsonBody -ContentType "application/json; charset=utf-16"
Add-Content $logFile "`n$resp"
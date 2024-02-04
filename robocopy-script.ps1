# Script developed by David Fernandes | Terabyte in 2024
$hostname = hostname
$mac = Get-WmiObject win32_networkadapterconfiguration | Where-Object { $_.IPEnabled -eq "TRUE" } | Select-Object macaddress
$mac = $mac.macaddress -replace ":", ""
$timestampStart = Get-Date -Format "yyyyMMdd_HHmmss"
$url = "http://localhost:8080/api/log"

$bckpOrigin = "C:\Users\david\Documents\backup\origin"
$bckpDest = "C:\Users\david\Documents\backup\destiny"
$log_file = "C:\Users\david\Documents\backup\log\backup_$timestampStart.txt"

$res = robocopy $bckpOrigin $bckpDest /mir /e /log:$log_file
$timestampEnd = Get-Date -Format "yyyyMMdd_HHmmss"

$logReport = Get-Content $log_file -Tail 10

$body = @{
  hostname       = "$hostname"
  mac            = "$mac"
  log            = "$logReport"
  timestampStart = "$timestampStart"
  timestampEnd   = "$timestampEnd"
}

Write-Output "Resp: $res"
$jsonBody = $body | ConvertTo-Json

$response = Invoke-RestMethod -Uri $url -Method Post -Body $jsonBody -ContentType "application/json; charset=utf-16"

Add-Content $log_file "`n$response"

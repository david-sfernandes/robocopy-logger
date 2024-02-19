$logFile = "C:\LogRobo\RoboKobata_%date:~0,2%-%date:~3,2%-%date:~6,4%.log"
mountvol F: \\?\Volume{a1056467-0000-0000-0000-100000000000}\

ping -n 15 -w 1000 0.0.0.1 > nul

# Faz o backup apenas das pastas necessárias.
robocopy "C:\Carne Leao 2018" "F:\Carne Leao 2018" /mir /v /r:0 /w:0 /NFL /NDL /log+:$logFile 
robocopy "C:\Carne Leao 2019" "F:\Carne Leao 2019" /mir /v /r:0 /w:0 /NFL /NDL /log+:$logFile 
robocopy C:\Alerta24h F:\Alerta24h /mir /v /r:0 /w:0 /NFL /NDL /log+:$logFile 
robocopy C:\Ferramentas F:\Ferramentas /mir /v /r:0 /w:0 /NFL /NDL /log+:$logFile 
robocopy C:\Help F:\Help /mir /v /r:0 /w:0 /NFL /NDL /log+:$logFile 
robocopy C:\Hidoctor F:\Hidoctor /mir /v /r:0 /w:0 /NFL /NDL /log+:$logFile 
robocopy C:\LogRobo F:\LogRobo /mir /v /r:0 /w:0 /NFL /NDL /log+:$logFile 
robocopy C:\Resource F:\Resource /mir /v /r:0 /w:0 /NFL /NDL /log+:$logFile 
robocopy C:\SMS_PC_Remoto F:\SMS_PC_Remoto /mir /v /r:0 /w:0 /NFL /NDL /log+:$logFile 
robocopy C:\System.sav F:\System.sav /mir /v /r:0 /w:0 /NFL /NDL /log+:$logFile 
robocopy C:\ZSCAN7 F:\ZSCAN7 /mir /v /r:0 /w:0 /NFL /NDL /log+:$logFile 
robocopy C:\ZscanData.backup F:\ZscanData.backup /mir /v /r:0 /w:0 /NFL /NDL /log+:$logFile 

mountvol F:\ /P

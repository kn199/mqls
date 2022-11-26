@echo off

rem ターミナルのクローズ
taskkill /F /T /IM "terminal.exe"

rem 再起動
shutdown.exe /r /t 0

exit /B 0
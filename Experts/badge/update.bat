@echo off

rem 更新のスキャン及びダウンロード
usoclient ScanInstallWait

rem 更新プログラムのインストール
usoclient StartInstall

rem コマンドプロンプトを終了
exit /B 0
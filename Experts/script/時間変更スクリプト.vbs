Option Explicit

'----------------------------------------------------------------------------
' UTC+0のヒストリカルデータ(.hst)を、日本時間(UTC+9)に変換するVBScript
' スクリプトファイルに.hstファイルをドラッグアンドドロップして使用する
' 出力先はスクリプト実行フォルダに作成される work フォルダの中
' 
' ※作成された.hstで上書きする前にオリジナルの.hstをバックアップしましょう。
'----------------------------------------------------------------------------

Const adTypeBinary = 1
Const adTypeText = 2
Const adSaveCreateOverWrite = 2
Const adReadAll = -1

Dim lngDatetime, binDatetime    ' bar start timeの整数値とバイナリ配列
Dim dteDatetime                 ' bar start timeの日付型変換後
Dim workFolder, workFile        ' 出力フォルダ、出力ファイル
Dim objFs                       ' ファイル操作(FileSystemObject)
Dim objStBin, objStIn, objStOut ' バイナリ操作(ADODB.Stream)
Dim lngStPos                    ' ファイル操作位置
Dim intVersion                  ' Version番号
Dim intBarsStructSize           ' Bars構造体のサイズ
Dim intStructPosition           ' 構造体のデータ位置
Dim i

' 引数が無いなら終了
If WScript.Arguments.Count < 1 Then WScript.Quit

Set objFs = CreateObject("Scripting.FileSystemObject")
Set objStBin = CreateObject("ADODB.Stream")
Set objStIn = CreateObject("ADODB.Stream")
Set objStOut = CreateObject("ADODB.Stream")

' 出力フォルダ作成
workFolder = objFs.BuildPath(objFs.GetFile(WScript.ScriptFullName).ParentFolder.Path, "work")
If Not objFs.FolderExists(workFolder) Then objFs.CreateFolder (workFolder)

' hstファイル書き換え
For i = 0 To WScript.Arguments.Count - 1
  If Right(WScript.Arguments(i), 4) = ".hst" Then
    If objFs.FileExists(WScript.Arguments(i)) Then
      
      ' .hstファイルを開く
      objStIn.Type = adTypeBinary
      objStIn.Open
      objStIn.LoadFromFile WScript.Arguments(i)
      
      ' 出力側のストリームを開く
      objStOut.Type = adTypeBinary
      objStOut.Open
      
      ' 出力ファイル名を指定
      workFile = objFs.GetFileName(WScript.Arguments(i))
      workFile = objFs.BuildPath(workFolder, workFile)
      
      ' 出力側ストリームへコピー
      objStIn.Position = 0
      objStOut.Write objStIn.Read(adReadAll)
      
      ' バージョン取得(400 or 401)
      objStIn.Position = 0
      intVersion = CLng("&H" & Hex(AscW(objStIn.Read(2))))
      If intVersion = 400 Then
          intBarsStructSize = 44  ' 構造体サイズ
          intStructPosition = 0   ' 書込位置
      Else
          intBarsStructSize = 60  ' 構造体サイズ
          intStructPosition = 0   ' 書込位置
      End If
      
      ' バー配列のbar start timeを書き換える
      ' ※ヘッダー部148bytes、バー構造体は44 or 60bytes
      For lngStPos = (148 + intStructPosition) To objStIn.Size - 1 Step intBarsStructSize
        
        ' 時間の読み取り
        objStIn.Position = lngStPos
        lngDatetime = CLng("&H" & Hex(AscW(objStIn.Read(2))))
        lngDatetime = lngDatetime + CLng("&H" & Hex(AscW(objStIn.Read(2)))) * &H10000
        dteDatetime = 25569 + lngDatetime / 86400
        
        ' 9時間進める (UTC+0 → UTC+9)
        dteDatetime = dteDatetime + TimeSerial(9, 0, 0)
        lngDatetime = CLng((dteDatetime - 25569) * 86400)
        
        ' 時間のバイナリ配列作成
        objStBin.Type = adTypeText
        objStBin.Charset = "unicode"
        objStBin.Open
        objStBin.WriteText ChrW(lngDatetime Mod &H10000)
        objStBin.WriteText ChrW(lngDatetime \ &H10000)
        objStBin.Position = 0
        objStBin.Type = adTypeBinary
        objStBin.Position = 2               ' 先頭2bytesはBOMなので読まない
        binDatetime = objStBin.Read(4)
        objStBin.Close
        
        ' 時間を更新
        objStOut.Position = lngStPos
        objStOut.Write binDatetime
        
      Next
      
      ' 出力ファイル保存
      objStOut.SaveToFile workFile, adSaveCreateOverWrite
      objStOut.Close
      objStIn.Close
      
    End If
  End If
Next

Set objStBin = Nothing
Set objStOut = Nothing
Set objStIn = Nothing
Set objFs = Nothing

MsgBox "出力しました。workフォルダを確認して下さい", vbInformation
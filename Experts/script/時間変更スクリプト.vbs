Option Explicit

'----------------------------------------------------------------------------
' UTC+0�̃q�X�g���J���f�[�^(.hst)���A���{����(UTC+9)�ɕϊ�����VBScript
' �X�N���v�g�t�@�C����.hst�t�@�C�����h���b�O�A���h�h���b�v���Ďg�p����
' �o�͐�̓X�N���v�g���s�t�H���_�ɍ쐬����� work �t�H���_�̒�
' 
' ���쐬���ꂽ.hst�ŏ㏑������O�ɃI���W�i����.hst���o�b�N�A�b�v���܂��傤�B
'----------------------------------------------------------------------------

Const adTypeBinary = 1
Const adTypeText = 2
Const adSaveCreateOverWrite = 2
Const adReadAll = -1

Dim lngDatetime, binDatetime    ' bar start time�̐����l�ƃo�C�i���z��
Dim dteDatetime                 ' bar start time�̓��t�^�ϊ���
Dim workFolder, workFile        ' �o�̓t�H���_�A�o�̓t�@�C��
Dim objFs                       ' �t�@�C������(FileSystemObject)
Dim objStBin, objStIn, objStOut ' �o�C�i������(ADODB.Stream)
Dim lngStPos                    ' �t�@�C������ʒu
Dim intVersion                  ' Version�ԍ�
Dim intBarsStructSize           ' Bars�\���̂̃T�C�Y
Dim intStructPosition           ' �\���̂̃f�[�^�ʒu
Dim i

' �����������Ȃ�I��
If WScript.Arguments.Count < 1 Then WScript.Quit

Set objFs = CreateObject("Scripting.FileSystemObject")
Set objStBin = CreateObject("ADODB.Stream")
Set objStIn = CreateObject("ADODB.Stream")
Set objStOut = CreateObject("ADODB.Stream")

' �o�̓t�H���_�쐬
workFolder = objFs.BuildPath(objFs.GetFile(WScript.ScriptFullName).ParentFolder.Path, "work")
If Not objFs.FolderExists(workFolder) Then objFs.CreateFolder (workFolder)

' hst�t�@�C����������
For i = 0 To WScript.Arguments.Count - 1
  If Right(WScript.Arguments(i), 4) = ".hst" Then
    If objFs.FileExists(WScript.Arguments(i)) Then
      
      ' .hst�t�@�C�����J��
      objStIn.Type = adTypeBinary
      objStIn.Open
      objStIn.LoadFromFile WScript.Arguments(i)
      
      ' �o�͑��̃X�g���[�����J��
      objStOut.Type = adTypeBinary
      objStOut.Open
      
      ' �o�̓t�@�C�������w��
      workFile = objFs.GetFileName(WScript.Arguments(i))
      workFile = objFs.BuildPath(workFolder, workFile)
      
      ' �o�͑��X�g���[���փR�s�[
      objStIn.Position = 0
      objStOut.Write objStIn.Read(adReadAll)
      
      ' �o�[�W�����擾(400 or 401)
      objStIn.Position = 0
      intVersion = CLng("&H" & Hex(AscW(objStIn.Read(2))))
      If intVersion = 400 Then
          intBarsStructSize = 44  ' �\���̃T�C�Y
          intStructPosition = 0   ' �����ʒu
      Else
          intBarsStructSize = 60  ' �\���̃T�C�Y
          intStructPosition = 0   ' �����ʒu
      End If
      
      ' �o�[�z���bar start time������������
      ' ���w�b�_�[��148bytes�A�o�[�\���̂�44 or 60bytes
      For lngStPos = (148 + intStructPosition) To objStIn.Size - 1 Step intBarsStructSize
        
        ' ���Ԃ̓ǂݎ��
        objStIn.Position = lngStPos
        lngDatetime = CLng("&H" & Hex(AscW(objStIn.Read(2))))
        lngDatetime = lngDatetime + CLng("&H" & Hex(AscW(objStIn.Read(2)))) * &H10000
        dteDatetime = 25569 + lngDatetime / 86400
        
        ' 9���Ԑi�߂� (UTC+0 �� UTC+9)
        dteDatetime = dteDatetime + TimeSerial(9, 0, 0)
        lngDatetime = CLng((dteDatetime - 25569) * 86400)
        
        ' ���Ԃ̃o�C�i���z��쐬
        objStBin.Type = adTypeText
        objStBin.Charset = "unicode"
        objStBin.Open
        objStBin.WriteText ChrW(lngDatetime Mod &H10000)
        objStBin.WriteText ChrW(lngDatetime \ &H10000)
        objStBin.Position = 0
        objStBin.Type = adTypeBinary
        objStBin.Position = 2               ' �擪2bytes��BOM�Ȃ̂œǂ܂Ȃ�
        binDatetime = objStBin.Read(4)
        objStBin.Close
        
        ' ���Ԃ��X�V
        objStOut.Position = lngStPos
        objStOut.Write binDatetime
        
      Next
      
      ' �o�̓t�@�C���ۑ�
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

MsgBox "�o�͂��܂����Bwork�t�H���_���m�F���ĉ�����", vbInformation
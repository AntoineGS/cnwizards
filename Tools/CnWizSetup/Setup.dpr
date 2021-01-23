{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2021 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��http://www.cnpack.org                                   }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

program Setup;
{* |<PRE>
================================================================================
* ������ƣ�CnWizards IDE ר�ҹ��߰�
* ��Ԫ���ƣ��򵥵İ�װ����
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע��������������ʱ�Զ��жϰ�װ״̬������װ/����װר��
*           ������ Setup [/i|/u] [/n] [/?|/h]
*           �� /i ��������ʱ��װר��
*           �� /u ��������ʱ����װר��
*           �� /n ��������ʱ����ʾ�Ի��򣨿���ǰ�����ϣ�
*           �� /? ��ʾ֧�ֵĲ����б�
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6
* �� �� �����õ�Ԫ�е��ַ����ɴ���Ϊ���ϱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id: Setup.dpr,v 1.19 2009/04/18 13:42:17 zjy Exp $
* �޸ļ�¼��2002.10.01 V1.1
*               ��������֧��
*           2002.09.28 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

{$I CnPack.inc}

uses
  Windows,
  SysUtils,
  Registry,
  FileCtrl,
  CnCommon,
  CnLangTranslator,
  CnLangStorage,
  CnHashLangStorage,
  CnLangMgr,
  CnWizCompilerConst,
  CnWizLangID;

{$R *.RES}
{$R SetupRes.RES}

{$IFDEF COMPILER7_UP}
{$R WindowsXP.res}
{$ENDIF}

type
  TCompilerName = (cvD5, cvD6, cvD7, cvD8, cbD2005, cbD2006, cbD2007, cbD2009,
    cbD2010, cbDXE, cbDXE2, cbDXE3, cbDXE4, cbDXE5, cbDXE6, cbDXE7, cbXE8, cb10S,
    cb101B, cb102T, cb103R, cb104S, cvCB5, cvCB6);

const
  csCompilerNames: array[TCompilerName] of string = (
    'Delphi 5',
    'Delphi 6',
    'Delphi 7',
    'Delphi 8',
    'BDS 2005',
    'BDS 2006',
    'RAD Studio 2007',
    'RAD Studio 2009',
    'RAD Studio 2010',
    'RAD Studio XE',
    'RAD Studio XE2',
    'RAD Studio XE3',
    'RAD Studio XE4',
    'RAD Studio XE5',
    'RAD Studio XE6',
    'RAD Studio XE7',
    'RAD Studio XE8',
    'RAD Studio 10 Seattle',
    'RAD Studio 10.1 Berlin',
    'RAD Studio 10.2 Tokyo',
    'RAD Studio 10.3 Rio',
    'RAD Studio 10.4 Sydney',
    'C++Builder 5',
    'C++Builder 6');

  csIDERegPaths: array[TCompilerName] of string = (
    '\Software\Borland\Delphi\5.0',
    '\Software\Borland\Delphi\6.0',
    '\Software\Borland\Delphi\7.0',
    '\Software\Borland\BDS\2.0',
    '\Software\Borland\BDS\3.0',
    '\Software\Borland\BDS\4.0',
    '\Software\Borland\BDS\5.0',
    '\Software\CodeGear\BDS\6.0',
    '\Software\CodeGear\BDS\7.0',
    '\Software\Embarcadero\BDS\8.0',
    '\Software\Embarcadero\BDS\9.0',
    '\Software\Embarcadero\BDS\10.0',
    '\Software\Embarcadero\BDS\11.0',
    '\Software\Embarcadero\BDS\12.0',
    '\Software\Embarcadero\BDS\14.0',
    '\Software\Embarcadero\BDS\15.0',
    '\Software\Embarcadero\BDS\16.0',
    '\Software\Embarcadero\BDS\17.0',
    '\Software\Embarcadero\BDS\18.0',
    '\Software\Embarcadero\BDS\19.0',
    '\Software\Embarcadero\BDS\20.0',
    '\Software\Embarcadero\BDS\21.0',
    '\Software\Borland\C++Builder\5.0',
    '\Software\Borland\C++Builder\6.0');

  csDllNames: array[TCompilerName] of string = (
    'CnWizards_D5.DLL',
    'CnWizards_D6.DLL',
    'CnWizards_D7.DLL',
    'CnWizards_D8.DLL',
    'CnWizards_D2005.DLL',
    'CnWizards_D2006.DLL',
    'CnWizards_D2007.DLL',
    'CnWizards_D2009.DLL',
    'CnWizards_D2010.DLL',
    'CnWizards_DXE.DLL',
    'CnWizards_DXE2.DLL',
    'CnWizards_DXE3.DLL',
    'CnWizards_DXE4.DLL',
    'CnWizards_DXE5.DLL',
    'CnWizards_DXE6.DLL',
    'CnWizards_DXE7.DLL',
    'CnWizards_DXE8.DLL',
    'CnWizards_D10S.DLL',
    'CnWizards_D101B.DLL',
    'CnWizards_D102T.DLL',
    'CnWizards_D103R.DLL',
    'CnWizards_D104S.DLL',
    'CnWizards_CB5.DLL',
    'CnWizards_CB6.DLL');

  csDllLoaderName = 'CnWizLoader.DLL';
  csDllLoaderKey = 'CnWizards_Loader';

  csLangDir = 'Lang\';
  csExperts = '\Experts';
  csLangFile = 'Setup.txt';

var
  csHintStr: string = 'Hint';
  csInstallSucc: string = 'CnPack IDE Wizards have been Installed in:' + #13#10 + '';
  csInstallSuccEnd: string = 'Run Setup again to Uninstall.';
  csUnInstallSucc: string = 'CnPack IDE Wizards have been Uninstalled From:' + #13#10 + '';
  csUnInstallSuccEnd: string = 'Run Setup again to Install.';
  csInstallFail: string = 'Can''t Find Delphi or C++Builder to Install CnPack IDE Wizards.';
  csUnInstallFail: string = 'CnPack IDE Wizards have already Disabled.';

  csSetupCmdHelp: string =
    'This Tool Supports Command Line Mode without Showing the Main Form.' + #13#10#13#10 +
    'Command Line Switch Help:' + #13#10#13#10 +
    '         -i or /i or -install or /install Install to IDE' + #13#10 +
    '         -u or /u or -uninstall or /uninstall UnInstall from IDE' + #13#10 +
    '         -n or /n or -NoMsg or /NoMsg Do NOT Show the Success Message after Setup run.' + #13#10 +
    '         -? or /? or -h or /h Show the Command Line Help.';

//==============================================================================
// ע������
//==============================================================================

// ���ע�����Ƿ����
function RegKeyExists(const RegPath: string): Boolean;
var
  Reg: TRegistry;
begin
  try
    Reg := TRegistry.Create;
    try
      Result := Reg.KeyExists(RegPath);
    finally
      Reg.Free;
    end;
  except
    Result := False;
  end;
end;

// ���ע����ֵ�Ƿ����
function RegValueExists(const RegPath, RegValue: string): Boolean;
var
  Reg: TRegistry;
begin
  try
    Reg := TRegistry.Create;
    try
      Result := Reg.OpenKey(RegPath, False) and Reg.ValueExists(RegValue);
    finally
      Reg.Free;
    end;
  except
    Result := False;
  end;
end;

// ɾ��ע����ֵ
function RegDeleteValue(const RegPath, RegValue: string): Boolean;
var
  Reg: TRegistry;
begin
  try
    Reg := TRegistry.Create;
    try
      Result := Reg.OpenKey(RegPath, False);
      if Result then
        Reg.DeleteValue(RegValue);
    finally
      Reg.Free;
    end;
  except
    Result := False;
  end;
end;

// дע����ַ���
function RegWriteStr(const RegPath, RegValue, Str: string): Boolean;
var
  Reg: TRegistry;
begin
  try
    Reg := TRegistry.Create;
    try
      Result := Reg.OpenKey(RegPath, True);
      if Result then Reg.WriteString(RegValue, Str);
    finally
      Reg.Free;
    end;
  except
    Result := False;
  end;
end;

//==============================================================================
// ר�Ҵ���
//==============================================================================

var
  ParamInstall: Boolean;
  ParamUnInstall: Boolean;
  ParamNoMsg: Boolean;
  ParamCmdHelp :Boolean;

// ȡר�� DLL �����ļ���
function GetDllFullPathName(Compiler: TCompilerName): string;
const
  RIO_10_3_2: TVersionNumber =
    (Major: 26; Minor: 0; Release: 34749; Build: 6593); // 10.3.2
var
  IDE: string;
  Reg: TRegistry;
  Version: TVersionNumber;
begin
  Result := _CnExtractFilePath(ParamStr(0)) + csDllLoaderName;
  // 10.3 �¶�̬�ж��ļ����İ汾ȷ���������ĸ� DLL
  if Compiler = cb103R then
  begin
    // 10.3.2 ʹ������ DLL���� 10.3.1 �����°汾ʹ����һ�� DLL
    // �� HKEY_CURRENT_USER\Software\Embarcadero\BDS\20.0 �µ� RootDir �õ���װĿ¼
    IDE := 'C:\Program Files\Embarcadero\Studio\20.0\';
    Reg := nil;

    try
      Reg := TRegistry.Create;
      if Reg.OpenKey('\Software\Embarcadero\BDS\20.0', False) then
        IDE := Reg.ReadString('RootDir');
    finally
      Reg.Free;
    end;

    if not DirectoryExists(IDE) then
      Exit;

    IDE := IncludeTrailingPathDelimiter(IDE) + 'bin\bds.exe';
    if not FileExists(IDE) then
      Exit;

    // �� bds.exe �İ汾��
    Version := GetFileVersionNumber(IDE);
    if (Version.Major <> 26) or (Version.Minor <> 0) then
      Exit;

    if Version.Release < RIO_10_3_2.Release then
      Result := _CnExtractFilePath(ParamStr(0)) + 'CnWizards_D103R1.DLL';
  end;
end;

// ȡ�ɵ�ר������Ϊ�� Key
function GetDllOldKeyName(Compiler: TCompilerName): string;
begin
  Result := _CnChangeFileExt(csDllNames[Compiler], '');
end;

// �ж�ר�� DLL �Ƿ����
function WizardExists(Compiler: TCompilerName): Boolean;
begin
  Result := FileExists(GetDllFullPathName(Compiler));
end;

// �ж��Ƿ�װ�ɰ�ר�� DLL
function IsOldInstalled: Boolean;
var
  Compiler: TCompilerName;
begin
  Result := True;
  for Compiler := Low(Compiler) to High(Compiler) do
    if WizardExists(Compiler) and RegKeyExists(csIDERegPaths[Compiler]) and
      not RegValueExists(csIDERegPaths[Compiler] + csExperts, GetDllOldKeyName(Compiler)) then
    begin
      Result := False;
      Exit;
    end;
end;

// �ж��Ƿ�װ�� Loader
function IsInstalled: Boolean;
var
  Compiler: TCompilerName;
begin
  Result := True;
  for Compiler := Low(Compiler) to High(Compiler) do
    if WizardExists(Compiler) and RegKeyExists(csIDERegPaths[Compiler]) and
      not RegValueExists(csIDERegPaths[Compiler] + csExperts, csDllLoaderKey) then
    begin
      Result := False;
      Exit;
    end;
end;

// ��װר��
procedure InstallWizards;
var
  S: string;
  Compiler: TCompilerName;
  Key: HKEY;
begin
  S := csInstallSucc;
  for Compiler := Low(Compiler) to High(Compiler) do
  begin
    if Compiler = cvD8 then // ����װ D8 ��
      Continue;

    if WizardExists(Compiler) and RegKeyExists(csIDERegPaths[Compiler]) then
    begin
      if not RegKeyExists(csIDERegPaths[Compiler] + csExperts) then
      begin
        RegCreateKey(HKEY_CURRENT_USER, PChar(csIDERegPaths[Compiler] + csExperts), Key);
        RegCloseKey(Key);
      end;

      // ɾ���ɸ�ʽ
      if RegValueExists(csIDERegPaths[Compiler] + csExperts, GetDllOldKeyName(Compiler)) then
        RegDeleteValue(csIDERegPaths[Compiler] + csExperts, GetDllOldKeyName(Compiler));

      // д�¸�ʽ
      if RegWriteStr(csIDERegPaths[Compiler] + csExperts, csDllLoaderKey,
        GetDllFullPathName(Compiler)) then
        S := S + #13#10 + ' - ' + csCompilerNames[Compiler];
    end;
  end;

  if not ParamNoMsg then
  begin
    if S <> csInstallSucc then
    begin
      if not ParamInstall then
        S := S + #13#10#13#10 + csInstallSuccEnd;
    end
    else
      S := csInstallFail;
    MessageBox(0, PChar(S), PChar(csHintStr), MB_OK + MB_ICONINFORMATION);
  end;
end;

// ����װר��
procedure UnInstallWizards;
var
  S: string;
  Compiler: TCompilerName;
begin
  S := csUnInstallSucc;
  for Compiler := Low(Compiler) to High(Compiler) do
  begin
    // ɾ���ɵ�
    if RegValueExists(csIDERegPaths[Compiler] + csExperts, GetDllOldKeyName(Compiler)) then
      RegDeleteValue(csIDERegPaths[Compiler] + csExperts, GetDllOldKeyName(Compiler));

    // ɾ���µ�
    if RegValueExists(csIDERegPaths[Compiler] + csExperts, csDllLoaderKey) and
      RegDeleteValue(csIDERegPaths[Compiler] + csExperts, csDllLoaderKey) then
      S := S + #13#10 + ' - ' + csCompilerNames[Compiler];
  end;

  if not ParamNoMsg then
  begin
    if S <> csUnInstallSucc then
    begin
      if not ParamUnInstall then
        S := S + #13#10#13#10 + csUnInstallSuccEnd;
    end
    else
      S := csUnInstallFail;
    MessageBox(0, PChar(S), PChar(csHintStr), MB_OK + MB_ICONWARNING);
  end;
end;

// �����ַ���
procedure TranslateStrings;
begin
  TranslateStr(csHintStr, 'csHintStr');
  TranslateStr(csInstallSucc, 'csInstallSucc');
  TranslateStr(csInstallSuccEnd, 'csInstallSuccEnd');
  TranslateStr(csUnInstallSucc, 'csUnInstallSucc');
  TranslateStr(csUnInstallSuccEnd, 'csUnInstallSuccEnd');
  TranslateStr(csInstallFail, 'csInstallFail');
  TranslateStr(csUnInstallFail, 'csUnInstallFail');
  TranslateStr(csSetupCmdHelp, 'csSetupCmdHelp');
end;

// ��ʼ������
procedure InitLanguageManager;
var
  LangID: DWORD;
  I: Integer;
begin
  CreateLanguageManager;
  with CnLanguageManager do
  begin
    LanguageStorage := TCnHashLangFileStorage.Create(CnLanguageManager);
    with TCnHashLangFileStorage(LanguageStorage) do
    begin
      StorageMode := smByDirectory;
      FileName := csLangFile;
      LanguagePath := _CnExtractFilePath(ParamStr(0)) + csLangDir;
    end;
  end;

  LangID := GetWizardsLanguageID;
  
  for I := 0 to CnLanguageManager.LanguageStorage.LanguageCount - 1 do
  begin
    if CnLanguageManager.LanguageStorage.Languages[I].LanguageID = LangID then
    begin
      CnLanguageManager.CurrentLanguageIndex := I;
      TranslateStrings;
      Break;
    end;
  end;
end;

begin
  InitLanguageManager;

  ParamInstall := FindCmdLineSwitch('Install', ['-', '/'], True) or
    FindCmdLineSwitch('i', ['-', '/'], True);
  ParamUnInstall := FindCmdLineSwitch('Uninstall', ['-', '/'], True) or
    FindCmdLineSwitch('u', ['-', '/'], True);
  ParamNoMsg := FindCmdLineSwitch('NoMsg', ['-', '/'], True) or
    FindCmdLineSwitch('n', ['-', '/'], True);
  ParamCmdHelp :=  FindCmdLineSwitch('?', ['-', '/'], True)
    or FindCmdLineSwitch('h', ['-', '/'], True)
    or FindCmdLineSwitch('help', ['-', '/'], True) ;

  if ParamCmdHelp then
    InfoDlg(csSetupCmdHelp)
  else if IsInstalled and not ParamInstall or ParamUnInstall then
    UnInstallWizards
  else
    InstallWizards;
end.

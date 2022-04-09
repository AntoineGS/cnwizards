{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2022 CnPack ������                       }
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

unit CnEditorDuplicateUnit;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����Ƶ�ǰ��Ԫ
* ��Ԫ���ߣ���Х (liuxiao@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2022.04.08 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNEDITORTOOLSETWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus,
  StdCtrls, IniFiles, ToolsAPI, CnConsts, CnWizUtils, CnEditorToolsetWizard, CnWizConsts,
  CnCommon, CnWizOptions;

type

//==============================================================================
// ���Ƶ�Ԫ������
//==============================================================================

{ TCnEditorDuplicateUnit }

  TCnEditorDuplicateUnit = class(TCnBaseCodingToolset)
  private

  protected

  public
    destructor Destroy; override;

    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
    procedure GetEditorInfo(var Name, Author, Email: string); override;
  end;

{$ENDIF CNWIZARDS_CNEDITORTOOLSETWIZARD}

implementation

{$IFDEF CNWIZARDS_CNEDITORTOOLSETWIZARD}

uses
  CnWizIdeUtils, CnOTACreators, CnWizEditFiler {$IFDEF DEBUG}, CnDebug {$ENDIF};

type
  TCnDuplicateCreator = class(TCnRawCreator, IOTAModuleCreator)
  private
    FCreatorType: string;
    FIntf: TCnOTAFile;
    FImpl: TCnOTAFile;
    FForm: TCnOTAFile;
    FIntfSource: string;
    FFormSource: string;
    FImplSource: string;
    procedure SetFormSource(const Value: string);
    procedure SetImplSource(const Value: string);
    procedure SetIntfSource(const Value: string);
  public
    // IOTACreator �ӿڲ���ʵ��
    function GetCreatorType: string; override;

    // IOTAModuleCreator �ӿ�ʵ��
    function GetAncestorName: string;
    function GetImplFileName: string;
    function GetIntfFileName: string;
    function GetFormName: string;
    function GetMainForm: Boolean;
    function GetShowForm: Boolean;
    function GetShowSource: Boolean;
    function NewFormFile(const FormIdent, AncestorIdent: string): IOTAFile;
    function NewImplSource(const ModuleIdent, FormIdent, AncestorIdent: string): IOTAFile;
    function NewIntfSource(const ModuleIdent, FormIdent, AncestorIdent: string): IOTAFile;
    procedure FormCreated(const FormEditor: IOTAFormEditor);

    // �������Է���
    property CreatorType: string read FCreatorType write FCreatorType;
    {* ������ģ������}
    property FormSource: string read FFormSource write SetFormSource;
    {* �����ļ�����}
    property IntfSource: string read FIntfSource write SetIntfSource;
    {* h �ļ����ݣ�C++Builder �У�}
    property ImplSource: string read FImplSource write SetImplSource;
    {* Pas �� Cpp �ļ�����}
  end;

//==============================================================================
// ���Ƶ�Ԫ������
//==============================================================================

{ TCnEditorDuplicateUnit }

procedure TCnEditorDuplicateUnit.Execute;
var
  Module: IOTAModule;
  Editor: IOTAEditor;
  I: Integer;
  Creator: TCnDuplicateCreator;
  IntfFile, ImplFile, FormFile: string;
  Stream, TS: TMemoryStream;
  FormEditor: IOTAFormEditor;
  Root: IOTAComponent;
  Comp: TComponent;
  C: Char;
begin
  // ��ȡ��ǰ��Ԫ��Ϣ���������� Creator ������
  Module := CnOtaGetCurrentModule;
  if (Module = nil) or (Module.GetModuleFileCount <= 0) then
    Exit;

  IntfFile := '';
  ImplFile := '';
  FormFile := '';

  Stream := nil;
  Creator := nil;
  try
    Creator := TCnDuplicateCreator.Create;

    // Module.FileName ���� pas ���� cpp
    for I := 0 to Module.GetModuleFileCount - 1 do
    begin
      // �� Editor �� pas��dfm ��
      Editor := Module.GetModuleFileEditor(I);
      if Editor = nil then
        Continue;

      if IsDelphiSourceModule(Editor.FileName) then
        ImplFile := Editor.FileName
      else if IsCpp(Editor.FileName) then
        ImplFile := Editor.FileName
      else if IsH(Editor.FileName) or IsHpp(Editor.FileName) then
        IntfFile := Editor.FileName
      else if IsForm(Editor.FileName) then
        FormFile := Editor.FileName;
    end;

    if (FormFile <> '') and (ImplFile <> '') then
      Creator.CreatorType := sForm
    else if ImplFile <> '' then
      Creator.CreatorType := sUnit;

{$IFDEF DEBUG}
    CnDebugger.LogMsg('Impl: ' + ImplFile);
    CnDebugger.LogMsg('Intf: ' + IntfFile);
    CnDebugger.LogMsg('Form: ' + FormFile);
{$ENDIF}

    Stream := TMemoryStream.Create;
    // ��Ҫ Ansi/Ansi/Utf16

    if IntfFile <> '' then
    begin
      Stream.Clear;
      EditFilerSaveFileToStream(IntfFile, Stream, True);
      Creator.IntfSource := PChar(Stream.Memory);
    end;
    if ImplFile <> '' then
    begin
      Stream.Clear;
      EditFilerSaveFileToStream(ImplFile, Stream, True);
      Creator.ImplSource := PChar(Stream.Memory);
    end;

    FormEditor := CnOtaGetFormEditorFromModule(Module);
    if FormEditor <> nil then
    begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('FormEditor: ' + FormEditor.FileName);
{$ENDIF}

      if FormEditor.FileName <> FormFile then
        raise Exception.Create('Form File Mismatch: ' + FormEditor.FileName);

      Root := FormEditor.GetRootComponent;
      if Root <> nil then
      begin
        Comp := TComponent(Root.GetComponentHandle);
        if Comp <> nil then
        begin
          Stream.Clear;
          TS := TMemoryStream.Create;
          try
            TS.WriteComponent(Comp);
            TS.Position := 0;
            ObjectBinaryToText(TS, Stream);
            C := #0;
            Stream.Write(C, SizeOf(Char));
          finally
            TS.Free;
          end;
          Creator.FormSource := PChar(Stream.Memory);
        end;
      end;
    end;

{$IFDEF DEBUG}
    CnDebugger.LogRawString(Creator.IntfSource);
    CnDebugger.LogRawString(Creator.ImplSource);
    CnDebugger.LogRawString(Creator.FormSource);
{$ENDIF}

    // (BorlandIDEServices as IOTAModuleServices).CreateModule(Creator);
  finally
    Stream.Free;
    Creator.Free;
  end;
end;

function TCnEditorDuplicateUnit.GetCaption: string;
begin
  Result := SCnEditorDuplicateUnitMenuCaption;
end;

function TCnEditorDuplicateUnit.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnEditorDuplicateUnit.GetHint: string;
begin
  Result := SCnEditorDuplicateUnitMenuHint;
end;

procedure TCnEditorDuplicateUnit.GetEditorInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorDuplicateUnitName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

destructor TCnEditorDuplicateUnit.Destroy;
begin

  inherited;
end;

{ TCnDuplicateCreator }

procedure TCnDuplicateCreator.FormCreated(
  const FormEditor: IOTAFormEditor);
begin

end;

function TCnDuplicateCreator.GetAncestorName: string;
begin

end;

function TCnDuplicateCreator.GetCreatorType: string;
begin
  Result := FCreatorType;
end;

function TCnDuplicateCreator.GetFormName: string;
begin

end;

function TCnDuplicateCreator.GetImplFileName: string;
begin

end;

function TCnDuplicateCreator.GetIntfFileName: string;
begin

end;

function TCnDuplicateCreator.GetMainForm: Boolean;
begin

end;

function TCnDuplicateCreator.GetShowForm: Boolean;
begin

end;

function TCnDuplicateCreator.GetShowSource: Boolean;
begin

end;

function TCnDuplicateCreator.NewFormFile(const FormIdent,
  AncestorIdent: string): IOTAFile;
begin

end;

function TCnDuplicateCreator.NewImplSource(const ModuleIdent, FormIdent,
  AncestorIdent: string): IOTAFile;
begin

end;

function TCnDuplicateCreator.NewIntfSource(const ModuleIdent, FormIdent,
  AncestorIdent: string): IOTAFile;
begin

end;

procedure TCnDuplicateCreator.SetFormSource(const Value: string);
begin
  FFormSource := Value;
end;

procedure TCnDuplicateCreator.SetImplSource(const Value: string);
begin
  FImplSource := Value;
end;

procedure TCnDuplicateCreator.SetIntfSource(const Value: string);
begin
  FIntfSource := Value;
end;

initialization
  RegisterCnCodingToolset(TCnEditorDuplicateUnit); // ע����빤��

{$ENDIF CNWIZARDS_CNEDITORTOOLSETWIZARD}
end.

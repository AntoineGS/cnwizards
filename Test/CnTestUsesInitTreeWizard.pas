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

unit CnTestUsesInitTreeWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ�CnTestUsesInitTreeWizard
* ��Ԫ���ߣ�CnPack ������
* ��    ע��
* ����ƽ̨��Windows 7 + Delphi 5
* ���ݲ��ԣ�XP/7 + Delphi 5/6/7
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2021.08.20 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnWizIdeUtils,
  CnPasCodeParser, CnWizEditFiler, CnTree;

type

//==============================================================================
// CnTestUsesInitTreeWizard �˵�ר��
//==============================================================================

{ TCnTestUsesInitTreeWizard }

  TCnTestUsesInitTreeWizard = class(TCnMenuWizard)
  private
    FTree: TCnTree;
    FFileNames: TStringList;

    procedure SearchAUnit(const AFullUnitName: string; ProcessedFiles: TStrings;
      UnitLeaf: TCnLeaf; Tree: TCnTree; AProject: IOTAProject = nil);
    {* �ݹ���ã����������� AUnitName ��ӦԴ��� Uses �б����뵽���е� UnitLeaf ���ӽڵ���}
  protected
    function GetHasConfig: Boolean; override;
  public
    constructor Create; override;
    destructor Destroy; override;

    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

implementation

uses
  CnDebug;

//==============================================================================
// CnTestUsesInitTreeWizard �˵�ר��
//==============================================================================

{ TCnTestUsesInitTreeWizard }

procedure TCnTestUsesInitTreeWizard.Config;
begin
  ShowMessage('No Option for this Test Case.');
end;

constructor TCnTestUsesInitTreeWizard.Create;
begin
  inherited;
  FFileNames := TStringList.Create;
  FTree := TCnTree.Create;
end;

destructor TCnTestUsesInitTreeWizard.Destroy;
begin
  FTree.Free;
  FFileNames.Free;
  inherited;
end;

procedure TCnTestUsesInitTreeWizard.Execute;
var
  Proj: IOTAProject;
  I: Integer;
begin
  Proj := CnOtaGetCurrentProject;
  if (Proj = nil) or not IsDelphiProject(Proj) then
    Exit;

  FTree.Clear;
  FFileNames.Clear;

  CnDebugger.Active := False;
  FTree.Root.Text := CnOtaGetProjectSourceFileName(Proj);
  SearchAUnit(FTree.Root.Text, FFileNames, FTree.Root, FTree, Proj);
  CnDebugger.Active := True;

  // ��ӡ��������
  for I := 0 to FTree.Count - 1 do
  begin
    CnDebugger.LogFmt('%s%s | %d', [StringOfChar('-', FTree.Items[I].Level),
      FTree.Items[I].Text, FTree.Items[I].Data]);
  end;
end;

function TCnTestUsesInitTreeWizard.GetCaption: string;
begin
  Result := 'Test Uses Init Tree';
end;

function TCnTestUsesInitTreeWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestUsesInitTreeWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestUsesInitTreeWizard.GetHint: string;
begin
  Result := 'Test Hint';
end;

function TCnTestUsesInitTreeWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestUsesInitTreeWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Uses Init Tree Menu Wizard';
  Author := 'CnPack IDE Wizards';
  Email := 'master@cnpack.org';
  Comment := '';
end;

procedure TCnTestUsesInitTreeWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestUsesInitTreeWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestUsesInitTreeWizard.SearchAUnit(const AFullUnitName: string;
  ProcessedFiles: TStrings; UnitLeaf: TCnLeaf; Tree: TCnTree; AProject: IOTAProject);
var
  St: TCnModuleSearchType;
  AFileName: string;
  UsesList: TStringList;
  I: Integer;
  Leaf: TCnLeaf;
  Stream: TMemoryStream;
begin
  // ���� AUnitName �ѵ�����Դ��·����
  // ����Դ��õ� intf �� impl �������б��������� UnitLeaf ��ֱ���ӽڵ�
  // �ݹ���ø÷���������ÿ�������б��е����õ�Ԫ��

  if AFullUnitName = '' then
    Exit;

  UsesList := TStringList.Create;
  try
    Stream := TMemoryStream.Create;
    try
      EditFilerSaveFileToStream(AFullUnitName, Stream);
      ParseUnitUses(PAnsiChar(Stream.Memory), UsesList);
    finally
      Stream.Free;
    end;

    // UsesList ���õ�������������·��
    for I := 0 to UsesList.Count - 1 do
    begin
      AFileName := GetFileNameSearchTypeFromModuleName(UsesList[I], St, AProject);
      if (AFileName = '') or (ProcessedFiles.IndexOf(AFileName) >= 0) then
        Continue;

      // AFileName ������δ��������½�һ�� Leaf���ҵ�ǰ Leaf ����
      Leaf := Tree.AddChild(UnitLeaf);
      Leaf.Text := AFileName;
      Leaf.Data := Ord(St) shl 8 + Ord(Boolean(UsesList.Objects[I]));
      ProcessedFiles.Add(AFileName);

      SearchAUnit(AFileName, ProcessedFiles, Leaf, Tree, AProject);
    end;
  finally
    UsesList.Free;
  end;
end;

initialization
  RegisterCnWizard(TCnTestUsesInitTreeWizard); // ע��˲���ר��

end.

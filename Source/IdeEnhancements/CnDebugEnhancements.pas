{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2024 CnPack ������                       }
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

unit CnDebugEnhancements;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����Թ�����չ��Ԫ
* ��Ԫ���ߣ���Х (liuxiao@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin7Pro + Delphi 10.3
* ���ݲ��ԣ�����
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2023.09.05 V1.0
*               ʵ�ֵ�Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNDEBUGENHANCEWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, ToolWin,
  Dialogs, IniFiles, ComCtrls, StdCtrls, ToolsAPI, Contnrs, ActnList, CnConsts,
  CnHashMap, CnWizConsts, CnWizClasses, CnWizOptions, CnWizDebuggerNotifier,
  CnDataSetVisualizer, CnWizShareImages, CnWizMultiLang, CnWizUtils, CnWizNotifier;

type
  TCnDebugEnhanceWizard = class(TCnSubMenuWizard)
  private
    FIdEvalObj: Integer;
    FIdEvalAsDataSet: Integer;
    FIdConfig: Integer;
    FAutoClose: Boolean;
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
    FReplaceManager: IOTADebuggerVisualizerValueReplacer;
    FDataSetViewer: IOTADebuggerVisualizer;
    FDataSetRegistered: Boolean;
    FEnableDataSet: Boolean;
    procedure SetEnableDataSet(const Value: Boolean);
    procedure CheckDataSetViewerRegistration;
{$ENDIF}
    procedure BeforeCompile(const Project: IOTAProject; IsCodeInsight: Boolean;
      var Cancel: Boolean);
  protected
    procedure SetActive(Value: Boolean); override;
    function GetHasConfig: Boolean; override;

    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
  public
    constructor Create; override;
    destructor Destroy; override;

    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;

    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure ResetSettings(Ini: TCustomIniFile); override;

    function GetCaption: string; override;
    function GetHint: string; override;
    procedure Config; override;

    procedure AcquireSubActions; override;

{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
    property EnableDataSet: Boolean read FEnableDataSet write SetEnableDataSet;
    {* �Ƿ����� DataSet Viewer}
 {$ENDIF}
    procedure DebugComand(Cmds: TStrings; Results: TStrings); override;

    property AutoClose: Boolean read FAutoClose write FAutoClose;
    {* ����ǰ�Ƿ��Զ�ɱ�������е�Ŀ����̣����Ƕ������е� Exe}
  end;

{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}

  TCnDebuggerBaseValueReplacer = class(TObject)
  {* ��װ�� ValueReplacer �������滻�ͻ��࣬����һЩ�ڲ�����}
  private
    FActive: Boolean;
  protected
    function GetEvalType: string; virtual; abstract;
    {* ����֧�ֵ����������� T ǰ׺}
    function GetNewExpression(const Expression, TypeName,
      OldEvalResult: string): string; virtual; abstract;
    {* ������ֵǰ���ã�����������±��ʽ��������ֵ}
    function GetFinalResult(const OldExpression, TypeName, OldEvalResult,
      NewEvalResult: string): string; virtual;
    {* ������ֵ�ɹ�����ã�������һ��������ʾ�Ļ��ᡣĬ��ʵ���ǡ���: �¡�}
  public
    property Active: Boolean read FActive write FActive;
    {* �Ƿ�����}
  end;

  TCnDebuggerBaseValueReplacerClass = class of TCnDebuggerBaseValueReplacer;

  TCnDebuggerValueReplaceManager = class(TInterfacedObject, IOTADebuggerVisualizerValueReplacer)
  {* ���е����͵���ֵ�滻��Ĺ����࣬����ۺϳɵ�����ע���� Delphi}
  private
    FWizard: TCnDebugEnhanceWizard;
    FReplaceItems: TStringList;
    FReplacers: TObjectList;
    FMap: TCnStrToPtrHashMap;
    FEvaluator: TCnRemoteProcessEvaluator;
  protected
    procedure CreateVisualizers;
  public
    constructor Create(AWizard: TCnDebugEnhanceWizard);
    destructor Destroy; override;

    procedure LoadSettings;
    {* װ������}
    procedure SaveSettings;
    {* ��������}
    procedure ResetSettings;
    {* ��������}

    // IOTADebuggerVisualizer
    function GetSupportedTypeCount: Integer;
    procedure GetSupportedType(Index: Integer; var TypeName: string;
      var AllDescendants: Boolean); overload;
    function GetVisualizerIdentifier: string;
    function GetVisualizerName: string;
    function GetVisualizerDescription: string;

    // IOTADebuggerVisualizerValueReplacer
    function GetReplacementValue(const Expression, TypeName, EvalResult: string): string;

    property ReplaceItems: TStringList read FReplaceItems;
  end;

{$ENDIF}

  TCnDebugEnhanceForm = class(TCnTranslateForm)
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    pgc1: TPageControl;
    tsDebugHint: TTabSheet;
    lblEnhanceHint: TLabel;
    lvReplacers: TListView;
    actlstDebug: TActionList;
    actAddHint: TAction;
    actRemoveHint: TAction;
    tlbHint: TToolBar;
    btnAddHint: TToolButton;
    btnRemoveHint: TToolButton;
    tsViewer: TTabSheet;
    grpExternalViewer: TGroupBox;
    chkDataSetViewer: TCheckBox;
    procedure actRemoveHintExecute(Sender: TObject);
    procedure actlstDebugUpdate(Action: TBasicAction;
      var Handled: Boolean);
    procedure actAddHintExecute(Sender: TObject);
    procedure lvReplacersDblClick(Sender: TObject);
  private

  public
    procedure LoadReplacersFromStrings(List: TStringList);
    procedure SaveReplacersToStrings(List: TStringList);
  end;

{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}

procedure RegisterCnDebuggerValueReplacer(ReplacerClass: TCnDebuggerBaseValueReplacerClass);
{* ������ TCnDebuggerBaseValueReplacer ����ע�ᣬʵ������ض����͵ĵ�������ʾ���ݵ�ֵ���滻}

{$ENDIF}

{$ENDIF CNWIZARDS_CNDEBUGENHANCEWIZARD}

implementation

{$IFDEF CNWIZARDS_CNDEBUGENHANCEWIZARD}

{$R *.DFM}

uses
  CnCommon, CnRemoteInspector {$IFDEF DEBUG}, CnDebug {$ENDIF};


const
  csAutoClose = 'AutoClose';
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  csEnableDataSet = 'EnableDataSet';

var
  FDebuggerValueReplacerClass: TList = nil;

procedure RegisterCnDebuggerValueReplacer(ReplacerClass: TCnDebuggerBaseValueReplacerClass);
begin
  if FDebuggerValueReplacerClass.IndexOf(ReplacerClass) < 0 then
    FDebuggerValueReplacerClass.Add(ReplacerClass);
end;

{$ENDIF}

{ TCnDebugEnhanceWizard }

{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}

procedure TCnDebugEnhanceWizard.SetEnableDataSet(const Value: Boolean);
begin
  FEnableDataSet := Value;
  CheckDataSetViewerRegistration;
end;

procedure TCnDebugEnhanceWizard.CheckDataSetViewerRegistration;
var
  ID: IOTADebuggerServices;
begin
  if not Supports(BorlandIDEServices, IOTADebuggerServices, ID) then
    Exit;

  if Active and FEnableDataSet then
  begin
    if not FDataSetRegistered then
    begin
      ID.RegisterDebugVisualizer(FDataSetViewer);
      FDataSetRegistered := True;
    end;
  end
  else
  begin
    if FDataSetRegistered then
    begin
      ID.UnregisterDebugVisualizer(FDataSetViewer);
      FDataSetRegistered := False;
    end;
  end;
end;

{$ENDIF}

procedure TCnDebugEnhanceWizard.Config;
begin
  with TCnDebugEnhanceForm.Create(nil) do
  begin
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
    LoadReplacersFromStrings((FReplaceManager as TCnDebuggerValueReplaceManager).ReplaceItems);
    chkDataSetViewer.Checked := FEnableDataSet;
{$ELSE}
    chkDataSetViewer.Enabled := False;
{$ENDIF}
    if ShowModal = mrOK then
    begin
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
      EnableDataSet := chkDataSetViewer.Checked;
      SaveReplacersToStrings((FReplaceManager as TCnDebuggerValueReplaceManager).ReplaceItems);
{$ENDIF}
      DoSaveSettings;
    end;
    Free;
  end;
end;

constructor TCnDebugEnhanceWizard.Create;
begin
  inherited;
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  FReplaceManager := TCnDebuggerValueReplaceManager.Create(Self);
  FDataSetViewer := TCnDebuggerDataSetVisualizer.Create;
{$ENDIF}

  CnWizNotifierServices.AddBeforeCompileNotifier(BeforeCompile);
end;

procedure TCnDebugEnhanceWizard.DebugComand(Cmds, Results: TStrings);
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
var
  Mgr: TCnDebuggerValueReplaceManager;
{$ENDIF}
begin
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  Mgr := FReplaceManager as TCnDebuggerValueReplaceManager;
  Results.Add('Replace Item Count: ' + IntToStr(Mgr.FReplaceItems.Count));
  Results.AddStrings(Mgr.FReplaceItems);
{$ENDIF}
end;

destructor TCnDebugEnhanceWizard.Destroy;
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
var
  ID: IOTADebuggerServices;
{$ENDIF}
begin
  CnWizNotifierServices.RemoveBeforeCompileNotifier(BeforeCompile);
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  if Active then
  begin
    if not Supports(BorlandIDEServices, IOTADebuggerServices, ID) then
      Exit;

    ID.UnregisterDebugVisualizer(FReplaceManager);
    if FDataSetRegistered then
      ID.UnregisterDebugVisualizer(FDataSetViewer);
  end;

  FReplaceManager := nil;
  FDataSetViewer := nil;
{$ENDIF}
  inherited;
end;

function TCnDebugEnhanceWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

class procedure TCnDebugEnhanceWizard.GetWizardInfo(var Name, Author,
  Email, Comment: string);
begin
  Name := SCnDebugEnhanceWizardName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
  Comment := SCnDebugEnhanceWizardComment;
end;

procedure TCnDebugEnhanceWizard.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  (FReplaceManager as TCnDebuggerValueReplaceManager).LoadSettings;
  EnableDataSet := Ini.ReadBool('', csEnableDataSet, True);
{$ENDIF}
  AutoClose := Ini.ReadBool('', csAutoClose, False);
end;

procedure TCnDebugEnhanceWizard.ResetSettings(Ini: TCustomIniFile);
begin
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  (FReplaceManager as TCnDebuggerValueReplaceManager).ResetSettings;
{$ENDIF}
end;

procedure TCnDebugEnhanceWizard.SaveSettings(Ini: TCustomIniFile);
begin
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  (FReplaceManager as TCnDebuggerValueReplaceManager).SaveSettings;
  Ini.WriteBool('', csEnableDataSet, FEnableDataSet);
{$ENDIF}
  Ini.WriteBool('', csAutoClose, AutoClose);
end;

procedure TCnDebugEnhanceWizard.SetActive(Value: Boolean);
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
var
  ID: IOTADebuggerServices;
{$ENDIF}
begin
  inherited;
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  if not Supports(BorlandIDEServices, IOTADebuggerServices, ID) then
    Exit;

  CheckDataSetViewerRegistration;
  if Active then
  begin
    ID.RegisterDebugVisualizer(FReplaceManager);
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnDebugEnhanceWizard Register Viewers');
{$ENDIF}
  end
  else
  begin
    ID.UnregisterDebugVisualizer(FReplaceManager);
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnDebugEnhanceWizard Unregister Viewers');
{$ENDIF}
  end;
{$ENDIF}
end;

{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}

{ TCnDebuggerValueReplaceManager }

constructor TCnDebuggerValueReplaceManager.Create(AWizard: TCnDebugEnhanceWizard);
begin
  inherited Create;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnDebuggerValueReplaceManager Create');
{$ENDIF}
  FWizard := AWizard;
  FReplaceItems := TStringList.Create;
  FReplacers := TObjectList.Create(True);
  FEvaluator := TCnRemoteProcessEvaluator.Create;
  CreateVisualizers;
end;

destructor TCnDebuggerValueReplaceManager.Destroy;
begin
  FEvaluator.Free;
  FMap.Free;
  FReplaceItems.Free;
  FReplacers.Free;
  inherited;
end;

function TCnDebuggerValueReplaceManager.GetReplacementValue(const Expression,
  TypeName, EvalResult: string): string;
var
  ID: IOTADebuggerServices;
  CP: IOTAProcess;
  CT: IOTAThread;
  S, NewExpr: string;
  P: Pointer;
  Replacer: TCnDebuggerBaseValueReplacer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnDebuggerValueReplacer get %s: %s, Display %s',
    [Expression, TypeName, EvalResult]);
{$ENDIF}
  Result := EvalResult;

  if not Supports(BorlandIDEServices, IOTADebuggerServices, ID) then
    Exit;

  CP := ID.CurrentProcess;
  if CP = nil then
    Exit;

  CT := CP.CurrentThread;
  if CT = nil then
    Exit;

  Replacer := nil;
  S := FReplaceItems.Values[TypeName];
  if Length(S) > 0 then
  begin
    // �滻��ʽ�ַ�����Ч���� TypeName �ڼ��滻���б���
    if Pos('%s', S) > 0 then
      NewExpr := Format(S, [Expression])
    else
      NewExpr := S;
  end
  else if FMap.Find(TypeName, P) then
  begin
    Replacer := TCnDebuggerBaseValueReplacer(P);
    if Replacer.Active then
      NewExpr := Replacer.GetNewExpression(Expression, TypeName, EvalResult)
    else
      Exit;
  end
  else
    Exit;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnDebuggerValueReplaceManager to Evaluate: ' + NewExpr);
{$ENDIF}

  S := FEvaluator.EvaluateExpression(NewExpr);

  if Replacer <> nil then
    Result := Replacer.GetFinalResult(Expression, TypeName, EvalResult, S)
  else
    Result := EvalResult + ': ' + S;
end;

procedure TCnDebuggerValueReplaceManager.GetSupportedType(Index: Integer;
  var TypeName: string; var AllDescendants: Boolean);
begin
  if Index < FReplaceItems.Count then
    TypeName := FReplaceItems.Names[Index]
  else if Index < FReplaceItems.Count + FReplacers.Count then
    TypeName := (FReplacers[Index] as TCnDebuggerBaseValueReplacer).GetEvalType;

  AllDescendants := False; // �ۺ��˵���û��֧�����࣬��֪����ηַ�
end;

function TCnDebuggerValueReplaceManager.GetSupportedTypeCount: Integer;
begin
  Result := FReplaceItems.Count + FReplacers.Count;
end;

function TCnDebuggerValueReplaceManager.GetVisualizerDescription: string;
begin
  Result := SCnDebugVisualizerDescription;
end;

function TCnDebuggerValueReplaceManager.GetVisualizerIdentifier: string;
begin
  Result := SCnDebugVisualizerIdentifier;
end;

function TCnDebuggerValueReplaceManager.GetVisualizerName: string;
begin
  Result := SCnDebugVisualizerName;
end;

procedure TCnDebuggerValueReplaceManager.CreateVisualizers;
var
  I: Integer;
  Clz: TCnDebuggerBaseValueReplacerClass;
  Obj: TCnDebuggerBaseValueReplacer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnDebuggerValueReplaceManager CreateVisualizers');
{$ENDIF}
  for I := 0 to FDebuggerValueReplacerClass.Count - 1 do
  begin
    Clz := TCnDebuggerBaseValueReplacerClass(FDebuggerValueReplacerClass[I]);
    Obj := TCnDebuggerBaseValueReplacer(Clz.NewInstance);
    Obj.Create;
    FReplacers.Add(Obj);
  end;

  FMap := TCnStrToPtrHashMap.Create;
  for I := 0 to FReplacers.Count - 1 do
    FMap.Add((FReplacers[I] as TCnDebuggerBaseValueReplacer).GetEvalType, FReplacers[I]);
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnDebuggerValueReplaceManager CreateVisualizers OK');
{$ENDIF}
end;

procedure TCnDebuggerValueReplaceManager.LoadSettings;
var
  F: string;
begin
  F := WizOptions.GetUserFileName(SCnDebugReplacerDataName, True);
  if FileExists(F) then
    FReplaceItems.LoadFromFile(F);
end;

procedure TCnDebuggerValueReplaceManager.ResetSettings;
var
  F: string;
begin
  F := WizOptions.GetUserFileName(SCnDebugReplacerDataName, False);
  if FileExists(F) then
    DeleteFile(F);
end;

procedure TCnDebuggerValueReplaceManager.SaveSettings;
var
  F: string;
begin
  F := WizOptions.GetUserFileName(SCnDebugReplacerDataName, False);
  FReplaceItems.SaveToFile(F);
  WizOptions.CheckUserFile(SCnDebugReplacerDataName);
end;

{$ENDIF}

{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}

{ TCnDebuggerBaseValueReplacer }

function TCnDebuggerBaseValueReplacer.GetFinalResult(const OldExpression,
  TypeName, OldEvalResult, NewEvalResult: string): string;
begin
  Result := OldEvalResult + ': ' + NewEvalResult;
end;

{$ENDIF}

{ TCnDebugEnhanceForm }

procedure TCnDebugEnhanceForm.LoadReplacersFromStrings(List: TStringList);
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
var
  I: Integer;
  Item: TListItem;
{$ENDIF}
begin
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  lvReplacers.Items.Clear;
  for I := 0 to List.Count - 1 do
  begin
    Item := lvReplacers.Items.Add;
    Item.Caption := List.Names[I];
    Item.SubItems.Add(List.Values[Item.Caption]);
  end;
{$ENDIF}
end;

procedure TCnDebugEnhanceForm.SaveReplacersToStrings(List: TStringList);
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
var
  I: Integer;
{$ENDIF}
begin
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
   List.Clear;
   for I := 0 to lvReplacers.Items.Count - 1 do
     List.Add(lvReplacers.Items[I].Caption + '=' + lvReplacers.Items[I].SubItems[0]);
{$ENDIF}
end;

procedure TCnDebugEnhanceForm.actRemoveHintExecute(Sender: TObject);
begin
  if lvReplacers.Selected <> nil then
    if QueryDlg(SCnDebugRemoveReplacerHint) then
      lvReplacers.Items.Delete(lvReplacers.Selected.Index);
end;

procedure TCnDebugEnhanceForm.actlstDebugUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
  if Action = actRemoveHint then
    (Action as TCustomAction).Enabled := lvReplacers.Selected <> nil
  else
    (Action as TCustomAction).Enabled := True;
  Handled := True;
end;

procedure TCnDebugEnhanceForm.actAddHintExecute(Sender: TObject);
var
  S, S1, S2: string;
  Idx: Integer;
  Item: TListItem;
begin
  S := 'TSample=%s.ToString';
  if CnWizInputQuery(SCnDebugAddReplacerCaption, SCnDebugAddReplacerHint, S) then
  begin
    Idx := Pos('=', S);
    if Idx > 1 then
    begin
      S1 := Copy(S, 1, Idx - 1);
      S2 := Copy(S, Idx + 1, MaxInt);
      if Pos('%s', S2) > 0 then
      begin
        Item := lvReplacers.Items.Add;
        Item.Caption := S1;
        Item.SubItems.Add(S2);
        Exit;
      end;
    end;

    ErrorDlg(SCnDebugErrorReplacerFormat);
  end;
end;

procedure TCnDebugEnhanceForm.lvReplacersDblClick(Sender: TObject);
var
  S, S1, S2: string;
  Idx: Integer;
  Item: TListItem;
begin
  Item := lvReplacers.Selected;
  if Item = nil then
    Exit;

  S := Item.Caption + '=' + Item.SubItems[0];
  if CnWizInputQuery(SCnDebugAddReplacerCaption, SCnDebugAddReplacerHint, S) then
  begin
    Idx := Pos('=', S);
    if Idx > 1 then
    begin
      S1 := Copy(S, 1, Idx - 1);
      S2 := Copy(S, Idx + 1, MaxInt);
      if Pos('%s', S2) > 0 then
      begin
        Item.Caption := S1;
        Item.SubItems[0] := S2;
        Exit;
      end;
    end;

    ErrorDlg(SCnDebugErrorReplacerFormat);
  end;
end;

procedure TCnDebugEnhanceWizard.AcquireSubActions;
begin
  FIdEvalObj := RegisterASubAction('EvalAsObj',
    'Evaluate As Object...', 0, '');
  FIdEvalAsDataSet := RegisterASubAction(SCnDebugEvalAsDataSet,
    SCnDebugEvalAsDataSetCaption, 0, SCnDebugEvalAsDataSetHint);
  AddSepMenu;
  FIdConfig := RegisterASubAction(SCnDebugConfig, SCnDebugConfigCaption, 0,
    SCnDebugConfigHint);
end;

procedure TCnDebugEnhanceWizard.SubActionExecute(Index: Integer);
var
  S: string;
  I1: Integer;
begin
  if Index = FIdEvalObj then
  begin
    S := CnOtaGetCurrentSelection;
    if Trim(S) = '' then
      CnOtaGetCurrPosToken(S, I1);

    if Trim(S) <> '' then
      EvaluateRemoteExpression(Trim(S));
  end
  else if Index = FIdEvalAsDataSet then
  begin
    S := CnOtaGetCurrentSelection;
    if Trim(S) = '' then
      CnOtaGetCurrPosToken(S, I1);

    if Trim(S) <> '' then
      ShowDataSetExternalViewer(Trim(S));
  end
  else if Index = FIdConfig then
    Config;
end;

procedure TCnDebugEnhanceWizard.SubActionUpdate(Index: Integer);
begin

end;

function TCnDebugEnhanceWizard.GetCaption: string;
begin
  Result := SCnDebugEnhanceWizardCaption;
end;

function TCnDebugEnhanceWizard.GetHint: string;
begin
  Result := SCnDebugEnhanceWizardHint;
end;

procedure TCnDebugEnhanceWizard.BeforeCompile(const Project: IOTAProject;
  IsCodeInsight: Boolean; var Cancel: Boolean);
var
  Exe: string;
begin
  if not Active or not AutoClose or IsCodeInsight then
    Exit;

  // ��ǰ���̵Ŀ�ִ���ļ������������ɱ��
  Exe := CnOtaGetProjectOutputTarget(Project);
  if (Exe <> '') and FileExists(Exe) then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnDebugEnhanceWizard.BeforeCompile to Kill: ' + Exe);
{$ENDIF}
    KillProcessByFullFileName(Exe);
  end;
end;

initialization
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  FDebuggerValueReplacerClass := TList.Create;
{$ENDIF}
  RegisterCnWizard(TCnDebugEnhanceWizard);

finalization
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  FDebuggerValueReplacerClass.Free;
{$ENDIF}

{$ENDIF CNWIZARDS_CNDEBUGENHANCEWIZARD}
end.

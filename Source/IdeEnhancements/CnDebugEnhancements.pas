{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2023 CnPack ������                       }
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

{$I CnPack.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IniFiles, ToolsAPI, CnConsts, CnWizConsts, CnWizClasses, CnWizOptions;

type
  TCnDebugEnhanceWizard = class(TCnIDEEnhanceWizard)
  private
    FVisualCalls: TStrings;
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
    FReplacer: IOTADebuggerVisualizerValueReplacer;
{$ENDIF}
  protected
    procedure SetActive(Value: Boolean); override;
  public
    constructor Create; override;
    destructor Destroy; override;

    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;

    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure ResetSettings(Ini: TCustomIniFile); override;

    property VisualCalls: TStrings read FVisualCalls;
    {* ��ֵ���滻���÷�ʽ����ʽΪ����.������}
  end;

{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}

  TCnDebuggerValueReplacer = class(TInterfacedObject, IOTAThreadNotifier,
    IOTADebuggerVisualizerValueReplacer)
  private
    FRes: array[0..2047] of Char;
    FWizard: TCnDebugEnhanceWizard;
    FNames, FFunctions: TStrings;
    FNotifierIndex: Integer;
    FEvalComplete: Boolean;
    FEvalSuccess: Boolean;
    FCanModify: Boolean;
    FEvalResult: string;
  protected
    procedure ParseReplacers;
  public
    constructor Create(AWizard: TCnDebugEnhanceWizard);
    destructor Destroy; override;

    procedure AfterSave;
    procedure BeforeSave;
    procedure Destroyed;
    procedure Modified;

    procedure ThreadNotify(Reason: TOTANotifyReason);
    procedure EvaluteComplete(const ExprStr, ResultStr: string; CanModify: Boolean;
      ResultAddress, ResultSize: LongWord; ReturnCode: Integer);
     procedure ModifyComplete(const ExprStr, ResultStr: string; ReturnCode: Integer);

    function GetSupportedTypeCount: Integer;
    procedure GetSupportedType(Index: Integer; var TypeName: string;
      var AllDescendants: Boolean); overload;
    function GetVisualizerIdentifier: string;
    function GetVisualizerName: string;
    function GetVisualizerDescription: string;

    function GetReplacementValue(const Expression, TypeName, EvalResult: string): string;
  end;

{$ENDIF}

  TCnDebugEnhanceForm = class(TForm)
  private

  public

  end;

implementation

{$R *.dfm}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

{ TCnDebugEnhanceWizard }

constructor TCnDebugEnhanceWizard.Create;
begin
  inherited;
  FVisualCalls := TStringList.Create;
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  FReplacer := TCnDebuggerValueReplacer.Create(Self);
{$ENDIF}
end;

destructor TCnDebugEnhanceWizard.Destroy;
begin
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  FReplacer := nil;
{$ENDIF}
  FVisualCalls.Free;
  inherited;
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
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
var
  S: string;
{$ENDIF}
begin
  inherited;
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  S := WizOptions.GetUserFileName(SCnDebugReplacerDataName, True);
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnDebugEnhanceWizard Load: ' + S);
{$ENDIF}

  if FileExists(S) then
  begin
    FVisualCalls.LoadFromFile(S);
    (FReplacer as TCnDebuggerValueReplacer).ParseReplacers;
  end;
{$ENDIF}
end;

procedure TCnDebugEnhanceWizard.ResetSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnDebugEnhanceWizard.SaveSettings(Ini: TCustomIniFile);
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
var
  S: string;
{$ENDIF}
begin
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  S := WizOptions.GetUserFileName(SCnDebugReplacerDataName, False);
  FVisualCalls.SaveToFile(S);
{$ENDIF}
  inherited;
end;

procedure TCnDebugEnhanceWizard.SetActive(Value: Boolean);
var
  ID: IOTADebuggerServices;
begin
  inherited;

{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}

  if not Supports(BorlandIDEServices, IOTADebuggerServices, ID) then
    Exit;

  if Active then
    ID.RegisterDebugVisualizer(FReplacer)
  else
    ID.UnregisterDebugVisualizer(FReplacer);

{$ENDIF}
end;

{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}

{ TCnDebuggerValueReplacer }

constructor TCnDebuggerValueReplacer.Create(AWizard: TCnDebugEnhanceWizard);
begin
  inherited Create;
  FWizard := AWizard;
  FNames := TStringList.Create;
  FFunctions := TStringList.Create;
  ParseReplacers;
end;

destructor TCnDebuggerValueReplacer.Destroy;
begin
  FFunctions.Free;
  FNames.Free;
  inherited;
end;

procedure TCnDebuggerValueReplacer.ParseReplacers;
var
  I, Idx: Integer;
  N, F: string;
begin
  FNames.Clear;
  FFunctions.Clear;

  for I := 0 to FWizard.VisualCalls.Count - 1 do
  begin
    Idx := Pos('.', FWizard.VisualCalls[I]);
    if (Idx > 1) and (Idx < Length(FWizard.VisualCalls[I])) then
    begin
      N := Copy(FWizard.VisualCalls[I], 1, Idx - 1);
      F := Copy(FWizard.VisualCalls[I], Idx + 1, MaxInt);
      FNames.Add(N);
      FFunctions.Add(F);
    end;
  end;
{$IFDEF DEBUG}
  CnDebugger.LogInteger(FNames.Count, 'TCnDebuggerValueReplacer Parse Replacers');
{$ENDIF}
end;

function TCnDebuggerValueReplacer.GetReplacementValue(const Expression,
  TypeName, EvalResult: string): string;
var
  I: Integer;
  Found: Boolean;
  ID: IOTADebuggerServices;
  CP: IOTAProcess;
  CT: IOTAThread;
  NewExpr: string;
  EvalRes: TOTAEvaluateResult;
  ResultAddr: TOTAAddress;
  ResultSize, ResultVal: Cardinal;
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

  Found := False;
  for I := 0 to FNames.Count - 1 do
  begin
    if TypeName = FNames[I] then
    begin
      NewExpr := Expression + '.' + FFunctions[I];
      Found := True;
      Break;
    end;
  end;

{$IFDEF DEBUG}
  if Found then
    CnDebugger.LogMsg('TCnDebuggerValueReplacer to Evaluate: ' + NewExpr)
  else
  begin
    CnDebugger.LogMsg('TCnDebuggerValueReplacer NO Match. Exit');
    Exit;
  end;
{$ENDIF}

  EvalRes := CT.Evaluate(NewExpr, @FRes[0], SizeOf(FRes), FCanModify, True,
    '', ResultAddr, ResultSize, ResultVal);

  case EvalRes of
{$IFDEF DEBUG}
    erError: CnDebugger.LogMsg('TCnDebuggerValueReplacer Evaluate Error');
    erBusy: CnDebugger.LogMsg('TCnDebuggerValueReplacer Evaluate Busy');
{$ENDIF}
    erOK: Result := EvalResult + ': ' + FRes;
    erDeferred:
      begin
{$IFDEF DEBUG}
        CnDebugger.LogMsg('TCnDebuggerValueReplacer Evaluate Deferred. Wait for Events.');
{$ENDIF}
        FEvalComplete := False;
        FEvalSuccess := False;
        FEvalResult := '';

        FNotifierIndex := CT.AddNotifier(Self);
        while not FEvalComplete do
          ID.ProcessDebugEvents;
        CT.RemoveNotifier(FNotifierIndex);

        if FEvalSuccess then
        begin
{$IFDEF DEBUG}
          CnDebugger.LogMsg('TCnDebuggerValueReplacer Evaluate Deferred Success.');
{$ENDIF}
          Result := EvalResult + ': ' + FEvalResult;
        end;
      end;
  end;
end;

procedure TCnDebuggerValueReplacer.GetSupportedType(Index: Integer;
  var TypeName: string; var AllDescendants: Boolean);
begin
  TypeName := FNames[index];
  AllDescendants := False;
end;

function TCnDebuggerValueReplacer.GetSupportedTypeCount: Integer;
begin
  Result := FNames.Count;
end;

function TCnDebuggerValueReplacer.GetVisualizerDescription: string;
begin
  Result := SCnDebugVisualizerDescription;
end;

function TCnDebuggerValueReplacer.GetVisualizerIdentifier: string;
begin
  Result := SCnDebugVisualizerIdentifier;
end;

function TCnDebuggerValueReplacer.GetVisualizerName: string;
begin
  Result := SCnDebugVisualizerName;
end;


procedure TCnDebuggerValueReplacer.AfterSave;
begin

end;

procedure TCnDebuggerValueReplacer.BeforeSave;
begin

end;

procedure TCnDebuggerValueReplacer.Destroyed;
begin

end;

procedure TCnDebuggerValueReplacer.EvaluteComplete(const ExprStr,
  ResultStr: string; CanModify: Boolean; ResultAddress,
  ResultSize: LongWord; ReturnCode: Integer);
begin
  // Defer �Ľ�� Evaluate ��ϣ���� ReturnCode ������ 0��ResultStr ������ǳ�����Ϣ
{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnDebuggerValueReplacer EvaluteComplete for %s: %d, %s',
    [ExprStr, ReturnCode, ResultStr]);
{$ENDIF}

  FEvalSuccess := ReturnCode = 0;

  if FEvalSuccess then
  begin
    FEvalResult := AnsiDequotedStr(ResultStr, '''');
  end
  else
    FEvalResult := '';

  FEvalComplete := True;
end;

procedure TCnDebuggerValueReplacer.Modified;
begin

end;

procedure TCnDebuggerValueReplacer.ModifyComplete(const ExprStr,
  ResultStr: string; ReturnCode: Integer);
begin

end;

procedure TCnDebuggerValueReplacer.ThreadNotify(Reason: TOTANotifyReason);
begin

end;

{$ENDIF}

initialization
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  RegisterCnWizard(TCnDebugEnhanceWizard);
{$ENDIF}

end.

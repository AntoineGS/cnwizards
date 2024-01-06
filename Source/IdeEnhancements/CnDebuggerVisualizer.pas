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

unit CnDebuggerVisualizer;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�����ֵ���ӻ��������Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע��
* ����ƽ̨��Win7 + Delphi XE2
* ���ݲ��ԣ�Win7/10/11 + Delphi All
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2024.01.06 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Classes, Contnrs, ToolsAPI, CnHashMap;

type
  TCnDebuggerBaseValueReplacer = class(TObject)
  {* ��װ�� ValueReplacer �������滻�ͻ��࣬����һЩ�ڲ�����}
  private

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

  end;

  TCnDebuggerBaseValueReplacerClass = class of TCnDebuggerBaseValueReplacer;

  TCnDebuggerValueReplacerManager = class(TInterfacedObject,
    IOTAThreadNotifier, IOTADebuggerVisualizerValueReplacer)
  {* ���е����͵���ֵ�滻��Ĺ����࣬����ۺϳɵ�����ע���� Delphi}
  private
    FRes: array[0..2047] of Char;
    FNotifierIndex: Integer;
    FEvalComplete: Boolean;
    FEvalSuccess: Boolean;
    FCanModify: Boolean;
    FEvalResult: string;
    FReplacers: TObjectList;
    FMap: TCnStrToPtrHashMap;
  protected
    procedure CreateVisualizers;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure RegisterToService;
    {* ��������ע���� Delphi}
    procedure UnregisterFromService;
    {* �������ô� Delphi �з�ע�ᵫһ��û�˵���}

    // IOTANotifier
    procedure AfterSave;
    procedure BeforeSave;
    procedure Destroyed;
    procedure Modified;

    // IOTAThreadNotifier
    procedure ThreadNotify(Reason: TOTANotifyReason);
    procedure EvaluteComplete(const ExprStr, ResultStr: string; CanModify: Boolean;
      ResultAddress, ResultSize: LongWord; ReturnCode: Integer);
     procedure ModifyComplete(const ExprStr, ResultStr: string; ReturnCode: Integer);

    // IOTADebuggerVisualizer
    function GetSupportedTypeCount: Integer;
    procedure GetSupportedType(Index: Integer; var TypeName: string;
      var AllDescendants: Boolean);
    function GetVisualizerIdentifier: string;
    function GetVisualizerName: string;
    function GetVisualizerDescription: string;

    // IOTADebuggerVisualizerValueReplacer
    function GetReplacementValue(const Expression, TypeName, EvalResult: string): string;
  end;

procedure RegisterCnDebuggerValueReplacer(ReplacerClass: TCnDebuggerBaseValueReplacerClass);
{* ������ TCnDebuggerBaseValueReplacer ����ע�ᣬʵ������ض����͵ĵ�������ʾ���ݵ�ֵ���滻}

implementation

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

var
  FDebuggerValueReplacerClass: TList = nil;

procedure RegisterCnDebuggerValueReplacer(ReplacerClass: TCnDebuggerBaseValueReplacerClass);
begin
  if FDebuggerValueReplacerClass.IndexOf(ReplacerClass) < 0 then
    FDebuggerValueReplacerClass.Add(ReplacerClass);
end;

{ TCnDebuggerBaseValueReplacer }

function TCnDebuggerBaseValueReplacer.GetFinalResult(const OldExpression, TypeName,
  OldEvalResult, NewEvalResult: string): string;
begin
  Result := OldEvalResult + ': ' + NewEvalResult;
end;

{ TCnDebuggerValueReplacerManager }

procedure TCnDebuggerValueReplacerManager.AfterSave;
begin

end;

procedure TCnDebuggerValueReplacerManager.BeforeSave;
begin

end;

constructor TCnDebuggerValueReplacerManager.Create;
begin
  inherited;
  CreateVisualizers;
end;

procedure TCnDebuggerValueReplacerManager.CreateVisualizers;
var
  I: Integer;
  Clz: TCnDebuggerBaseValueReplacerClass;
  Obj: TCnDebuggerBaseValueReplacer;
begin
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
end;

destructor TCnDebuggerValueReplacerManager.Destroy;
begin
  FMap.Free;
  FReplacers.Free;
  inherited;
end;

procedure TCnDebuggerValueReplacerManager.Destroyed;
begin

end;

procedure TCnDebuggerValueReplacerManager.EvaluteComplete(const ExprStr,
  ResultStr: string; CanModify: Boolean; ResultAddress, ResultSize: LongWord;
  ReturnCode: Integer);
begin
  // Defer �Ľ�� Evaluate ��ϣ���� ReturnCode ������ 0��ResultStr ������ǳ�����Ϣ
{$IFDEF DEBUG}
  CnDebugger.LogFmt('DebuggerVisualizerValueReplacer EvaluteComplete for %s: %d, %s',
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

function TCnDebuggerValueReplacerManager.GetReplacementValue(const Expression,
  TypeName, EvalResult: string): string;
var
  ID: IOTADebuggerServices;
  CP: IOTAProcess;
  CT: IOTAThread;
  NewExpr: string;
  EvalRes: TOTAEvaluateResult;
  ResultAddr: TOTAAddress;
  ResultSize, ResultVal: Cardinal;
  P: Pointer;
  Replacer: TCnDebuggerBaseValueReplacer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('DebugValueReplacerManager get %s: %s, Display %s',
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

  if FMap.Find(TypeName, P) then
  begin
    Replacer := TCnDebuggerBaseValueReplacer(P);
    NewExpr := Replacer.GetNewExpression(Expression, TypeName, EvalResult);
  end
  else
    Exit;

  EvalRes := CT.Evaluate(NewExpr, @FRes[0], SizeOf(FRes), FCanModify, True,
    '', ResultAddr, ResultSize, ResultVal);

  case EvalRes of
{$IFDEF DEBUG}
    erError: CnDebugger.LogMsg('DebugValueReplacerManager Evaluate Error');
    erBusy: CnDebugger.LogMsg('DebugValueReplacerManager Evaluate Busy');
{$ENDIF}
    erOK: Result := EvalResult + ': ' + FRes;
    erDeferred:
      begin
{$IFDEF DEBUG}
        CnDebugger.LogMsg('DebugValueReplacerManager Evaluate Deferred. Wait for Events.');
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
          CnDebugger.LogMsg('DebugValueReplacerManager Evaluate Deferred Success.');
{$ENDIF}
          Result := Replacer.GetFinalResult(Expression, TypeName, EvalResult, FEvalResult);
        end;
      end;
  end;
end;

procedure TCnDebuggerValueReplacerManager.GetSupportedType(Index: Integer;
  var TypeName: string; var AllDescendants: Boolean);
begin
  AllDescendants := True;
  TypeName := (FReplacers[Index] as TCnDebuggerBaseValueReplacer).GetEvalType;
end;

function TCnDebuggerValueReplacerManager.GetSupportedTypeCount: Integer;
begin
  Result := FReplacers.Count;
end;

function TCnDebuggerValueReplacerManager.GetVisualizerDescription: string;
begin

end;

function TCnDebuggerValueReplacerManager.GetVisualizerIdentifier: string;
begin
  Result := 'CnWizardsDebugValueReplacer';
end;

function TCnDebuggerValueReplacerManager.GetVisualizerName: string;
begin

end;

procedure TCnDebuggerValueReplacerManager.Modified;
begin

end;

procedure TCnDebuggerValueReplacerManager.ModifyComplete(const ExprStr,
  ResultStr: string; ReturnCode: Integer);
begin

end;

procedure TCnDebuggerValueReplacerManager.RegisterToService;
begin

end;

procedure TCnDebuggerValueReplacerManager.ThreadNotify(Reason: TOTANotifyReason);
begin

end;

procedure TCnDebuggerValueReplacerManager.UnregisterFromService;
begin

end;

initialization
  FDebuggerValueReplacerClass := TList.Create;

finalization
  FDebuggerValueReplacerClass.Free;

end.

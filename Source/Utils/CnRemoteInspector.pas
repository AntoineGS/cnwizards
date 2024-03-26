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
{            ��վ��ַ��https://www.cnpack.org                                  }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnRemoteInspector;
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

uses
  SysUtils, Classes, Windows, CnWizDebuggerNotifier, CnPropSheetFrm;

function EvaluateRemoteExpression(const Expression: string;
  AForm: TCnPropSheetForm = nil; SyncMode: Boolean = True;
  AParentSheet: TCnPropSheetForm = nil): TCnPropSheetForm;
{* ִ�б����Ե�Զ�̽����е���ֵ�鿴}

implementation

uses
  CnNative {$IFDEF DEBUG}, CnDebug {$ENDIF};

type
  TCnRemoteEvaluationInspector = class(TCnObjectInspector)
  private
    FObjectExpr: string;
    FEvaluator: TCnRemoteProcessEvaluator;
  protected
    procedure SetObjectAddr(const Value: Pointer); override;

    procedure DoEvaluate; override;
  public
    constructor Create(Data: Pointer); override;
    destructor Destroy; override;

{$IFDEF SUPPORT_ENHANCED_RTTI}
    function ChangeFieldValue(const FieldName, Value: string;
      FieldObj: TCnFieldObject): Boolean; override;
{$ENDIF}
    function ChangePropertyValue(const PropName, Value: string;
      PropObj: TCnPropertyObject): Boolean; override;

    property ObjectExpr: string read FObjectExpr;
  end;

  // ClassInfo ָ��ýṹ
  TCnTypeInfoRec = packed record
    TypeKind: Byte;
    NameLength: Byte;
    // NameLength �� Byte �� ClassName���ٺ����� TCnTypeDataRec32/64
  end;
  PCnTypeInfoRec = ^TCnTypeInfoRec;

  TCnTypeDataRec32 = packed record
    ClassType: Cardinal;
    ParentInfo: Cardinal;
    PropCount: SmallInt;
    UnitNameLength: Byte;
    // UnitNameLength �� Byte �� UnitName���ٺ����� TCnPropDataRec
  end;
  PCnTypeDataRec32 = ^TCnTypeDataRec32;

  TCnTypeDataRec64 = packed record
    ClassType: Int64;
    ParentInfo: Int64;
    PropCount: SmallInt;
    UnitNameLength: Byte;
    // UnitNameLength �� Byte �� UnitName���ٺ����� TCnPropDataRec
  end;
  PCnTypeDataRec64 = ^TCnTypeDataRec64;

  TCnPropDataRec = packed record
    PropCount: Word;
    // �ٺ����� TCnPropInfoRec32/64 �б�
  end;
  PCnPropDataRec = ^TCnPropDataRec;

  TCnPropInfoRec32 = packed record
    PropType: Cardinal;
    GetProc: Cardinal;
    SetProc: Cardinal;
    StoredProc: Cardinal;
    Index: Integer;
    Default: Longint;
    NameIndex: SmallInt;
    NameLength: Byte;
    // NameLength �� Byte �� PropName
  end;
  PCnPropInfoRec32 = ^TCnPropInfoRec32;

  TCnPropInfoRec64 = packed record
    PropType: Int64;
    GetProc: Int64;
    SetProc: Int64;
    StoredProc: Int64;
    Index: Integer;
    Default: Longint;
    NameIndex: SmallInt;
    NameLength: Byte;
    // NameLength �� Byte �� PropName
  end;
  PCnPropInfoRec64 = ^TCnPropInfoRec64;

function EvaluateRemoteExpression(const Expression: string;
  AForm: TCnPropSheetForm; SyncMode: Boolean;
  AParentSheet: TCnPropSheetForm): TCnPropSheetForm;
var
  Eval: TCnRemoteProcessEvaluator;
begin
  Result := nil;
  if Trim(Expression) = '' then Exit;

  if AForm = nil then
    AForm := TCnPropSheetForm.Create(nil);

  AForm.ObjectPointer := nil;
  AForm.ObjectExpr := Trim(Expression); // ע���ʱ ObjectPointer ����Ϊ nil���ڲ��ж�ʹ��
  AForm.Clear;
  AForm.ParentSheetForm := AParentSheet;

  AForm.SyncMode := SyncMode;
  AForm.InspectorClass := TCnRemoteEvaluationInspector;

  Eval := TCnRemoteProcessEvaluator.Create;
  if SyncMode then
  begin
    AForm.DoEvaluateBegin;
    try
      AForm.InspectParam := Eval;
      AForm.InspectObject(AForm.InspectParam);
    finally
      AForm.DoEvaluateEnd;
      AForm.Show;  // After Evaluation. Show the form.
    end;
  end
  else
    PostMessage(AForm.Handle, CN_INSPECTOBJECT, WParam(Eval), 0);

  Result := AForm;
end;

{ TCnRemoteEvaluationInspector }

{$IFDEF SUPPORT_ENHANCED_RTTI}

function TCnRemoteEvaluationInspector.ChangeFieldValue(const FieldName,
  Value: string; FieldObj: TCnFieldObject): Boolean;
begin

end;

{$ENDIF}

function TCnRemoteEvaluationInspector.ChangePropertyValue(const PropName,
  Value: string; PropObj: TCnPropertyObject): Boolean;
begin

end;

constructor TCnRemoteEvaluationInspector.Create(Data: Pointer);
begin
  inherited Create(Data);
  FEvaluator := TCnRemoteProcessEvaluator(Data);
end;

destructor TCnRemoteEvaluationInspector.Destroy;
begin
  FEvaluator.Free;
  inherited;
end;

{
  ������ʽ�Ƕ��������� ClassInfo �õ���ַָ�룬��һ�θ��� 256 + 256 �ֽڣ������õ����������� Info ָ������������
  �ٸ������������������� ClassInfo �� 256 * �������� + 1���ֽڣ��õ�������������������ȡ
  �ٸ��ݸ��� Info ָ�룬�ٶ� 256 * �������� + 1���ֽڣ��õ���������������������������ȡ
  �ܹ������㹻���������� TObject ��ͣ�����Ҫ���ö���Ĳ㼶����ô��εĵ�ַ�ռ�����
}
procedure TCnRemoteEvaluationInspector.DoEvaluate;
var
  C, I, L, APCnt, PCnt, PSum: Integer;
  RemotePtr: TCnOTAAddress;
  V, S: string;
  Buf: TBytes;
  BufPtr: PByte;
  Hies: TStringList;
  AProp: TCnPropertyObject;
  Is32: Boolean;
begin
  if FObjectExpr = '' then
  begin
    InspectComplete := True;
    Exit;
  end;

  if not IsRefresh then
  begin
    Properties.Clear;
    Fields.Clear;
    Events.Clear;
    Methods.Clear;
    Components.Clear;
    Controls.Clear;
    CollectionItems.Clear;
    Strings.Clear;
    MenuItems.Clear;
    Graphics.Graphic := nil;
  end;

  if not CnWizDebuggerObjectInheritsFrom(FObjectExpr, 'TObject', FEvaluator) then
  begin
    InspectComplete := True;
    Exit;
  end;

  // ��һ�����󣬿�ʼ��ֵ
//  ContentTypes := [pctHierarchy];
//  Hies := TStringList.Create;
//  try
//    V := FObjectExpr;
//    while True do
//    begin
//      S := FEvaluator.EvaluateExpression(V + '.ClassName');
//      if (S = '') or (S = 'nil') then
//        Break;
//
//      Hies.Add(S);
//      if S = 'TObject' then
//        Break;
//
//      V := V + '.ClassParent';
//    end;
//    Hierarchy := Hies.Text;
//  finally
//    Hies.Free;
//  end;
//  DoAfterEvaluateHierarchy;

  if CnWizDebuggerObjectInheritsFrom(FObjectExpr, 'TStrings', FEvaluator) then
  begin
    ContentTypes := ContentTypes + [pctStrings];
    S := FEvaluator.EvaluateExpression('(' + FObjectExpr + ' as TStrings).Text');
    if Strings.DisplayValue <> S then
    begin
      Strings.Changed := True;
      Strings.DisplayValue := S;
    end;
  end;

  S := Format('Pointer((%s).ClassInfo)', [FObjectExpr]);
  S := FEvaluator.EvaluateExpression(S);

  RemotePtr := StrToUInt64(S);
  if RemotePtr <> 0 then
  begin
    L := 512;
    SetLength(Buf, L);
    L := FEvaluator.ReadProcessMemory(RemotePtr, L, Buf[0]);

{$IFDEF DEBUG}
    CnDebugger.LogInteger(L, 'FEvaluator.ReadProcessMemory Return');
    CnDebugger.LogMemDump(@Buf[0], L);
{$ENDIF}

    // ��������������Buf �� TCnTypeInfoRec
    BufPtr := @Buf[0];
    L := PCnTypeInfoRec(BufPtr)^.NameLength;
    Inc(BufPtr, SizeOf(TCnTypeInfoRec) + L); // �������ֽ�ָ�� ClassName���������ַ�������ָ�� TypeData

    ContentTypes := [pctHierarchy];
    Hies := TStringList.Create;

    try
      Is32 := FEvaluator.CurrentProcessIs32;
      if Is32 then
        APCnt := PCnTypeDataRec32(BufPtr)^.PropCount
      else
        APCnt := PCnTypeDataRec64(BufPtr)^.PropCount;

{$IFDEF DEBUG}
      CnDebugger.LogFmt('FEvaluator.DoEvaluate %s: All Property Count: %d', [FObjectExpr, APCnt]);
{$ENDIF}

      PSum := 0; // �Ѿ��������������ۼ�
      // RemotePtr ʼ���Ǳ����ε� ClassInfo ָ�룬ѭ������������ʼ��һ��ѭ��ʱ��ָ�����ָ��
      while True do
      begin
        L := (APCnt + 1) * 256; // Ԥ�������ܴ�Ŀռ�
        SetLength(Buf, L);
        L := FEvaluator.ReadProcessMemory(RemotePtr, L, Buf[0]);

        // Buf �Ǳ���� PCnTypeInfoRec
        BufPtr := @Buf[0];
        L := PCnTypeInfoRec(BufPtr)^.NameLength;
        Inc(BufPtr, SizeOf(TCnTypeInfoRec)); // �������ֽ�ָ�� ClassName

        SetLength(S, L);
        Move(BufPtr^, S[1], L);              // ���� ClassName
        Inc(BufPtr, L);
        Hies.Add(S);

        // ��ʱ BufPtr ָ�� TypeData�����ø��������ָ��
        if Is32 then
        begin
          RemotePtr := TCnOTAAddress(PCnTypeDataRec32(BufPtr)^.ParentInfo);
          Inc(BufPtr, SizeOf(TCnTypeDataRec32) + PCnTypeDataRec32(BufPtr)^.UnitNameLength);
        end
        else
        begin
          RemotePtr := TCnOTAAddress(PCnTypeDataRec64(BufPtr)^.ParentInfo);
          Inc(BufPtr, SizeOf(TCnTypeDataRec64) + PCnTypeDataRec64(BufPtr)^.UnitNameLength);
        end;

        // ��ʱ BufPtr ָ�� PropData�����ñ����������
        PCnt := PCnPropDataRec(Buf)^.PropCount;
        Inc(BufPtr, SizeOf(TCnPropDataRec));

        // ��ʱ BufPtr ָ�� PropInfo �ĵ�һ��Ԫ��
        for I := 0 to PCnt - 1 do
        begin
          // �޷����� PCnPropInfoRec32(BufPtr)^.PropType �ж��Ƿ�Ҫ��������ԣ�
          // ��Ȼ 32 �� 64 һ������ֿ���������һ��ָ�룬�޷���ָһ�Σ����ٴ���ֵ

          if Is32 then
          begin
            L := PCnPropInfoRec32(BufPtr)^.NameLength;  // �õ��������ĳ���
            Inc(BufPtr, SizeOf(TCnPropInfoRec32));      // BufPtr ָ��������
            SetLength(S, L);
            Move(BufPtr^, S[1], L);                     // ����������
            Inc(BufPtr, L);                             // BufPtr �������ƣ�ָ����һ��
          end
          else
          begin
            L := PCnPropInfoRec64(BufPtr)^.NameLength;  // �õ��������ĳ���
            Inc(BufPtr, SizeOf(TCnPropInfoRec64));      // BufPtr ָ��������
            SetLength(S, L);
            Move(BufPtr^, S[1], L);                     // ����������
            Inc(BufPtr, L);                             // BufPtr �������ƣ�ָ����һ��
          end;
          // �õ��������� S ����� TypeKind���ٸ����Ƿ�Ҫ�����������Ƿ������

          if not IsRefresh then
          begin
            AProp := TCnPropertyObject.Create;
            AProp.IsNewRTTI := True;
          end
          else
            AProp := IndexOfProperty(Properties, V);

          AProp.PropName := S;

          if not IsRefresh then
            Properties.Add(AProp);

          ContentTypes := ContentTypes + [pctProps];

          Inc(PSum);
        end;

        if RemotePtr = 0 then // û�����ˣ���
          Break;
      end;

      Hierarchy := Hies.Text;
      DoAfterEvaluateHierarchy;
    finally
      Hies.Free;
    end;
  end;

//{$IFDEF SUPPORT_ENHANCED_RTTI}
//  S := Format('Length(TRttiContext.Create.GetType(%s.ClassInfo).GetProperties)', [FObjectExpr]);
//  S := FEvaluator.EvaluateExpression(S);
//  C := StrToIntDef(S, 0);
//  if C > 0 then
//  begin
//    for I := 0 to C - 1 do
//    begin
//      S := FEvaluator.EvaluateExpression(Format('TRttiContext.Create.GetType(%s.ClassInfo).GetProperties[%d].PropertyType.TypeKind', [FObjectExpr, I]));
//      // �õ���������
//      if (S <> 'tkMethod') and (S <> 'tkUnknown') then
//      begin
//        // ������
//        V := FEvaluator.EvaluateExpression(Format('TRttiContext.Create.GetType(%s.ClassInfo).GetProperties[%d].Name', [FObjectExpr, I]));
//
//        // V �õ�����
//        if not IsRefresh then
//        begin
//          AProp := TCnPropertyObject.Create;
//          AProp.IsNewRTTI := True;
//        end
//        else
//          AProp := IndexOfProperty(Properties, V);
//
//        AProp.PropName := V;
//        // AProp.PropType := S;
//
//        S := FEvaluator.EvaluateExpression(Format('TRttiContext.Create.GetType(%s.ClassInfo).GetProperties[%d].GetValue(%s)', [FObjectExpr, I, FObjectExpr]));
//        if S <> AProp.DisplayValue then
//        begin
//          AProp.DisplayValue := S;
//          AProp.Changed := True;
//        end
//        else
//          AProp.Changed := False;
//
//        if not IsRefresh then
//          Properties.Add(AProp);
//
//        ContentTypes := ContentTypes + [pctProps];
//      end;
//    end;
//  end;
//
//{$ELSE}
//
//
//
//  S := Format('GetTypeData(PTypeInfo((%s).ClassInfo))^.PropCount', [FObjectExpr]);
//  S := FEvaluator.EvaluateExpression(S);
//  C := StrToIntDef(S, 0);
//  if C > 0 then
//  begin
//    S := Format('Pointer((%s).ClassInfo)', [FObjectExpr]);
//    S := FEvaluator.EvaluateExpression(S);
//
//    // �õ� ClassInfo ��ָ���ַ�����ת����ָ��
//    PropPtr := Pointer(StrToUInt64(S));
//
//    L := (C + 1) * 256; // ׼��һ���������� TypeInfo �����Ա��ٶ�ÿ������ռ�ݿռ䲻����� 256 �ֽ�
//    SetLength(TypeInfoBuf, L);
//    L := FEvaluator.ReadProcessMemory(PropPtr, L, TypeInfoBuf[0]);
//
//{$IFDEF DEBUG}
//    CnDebugger.LogInteger(L, 'FEvaluator.ReadProcessMemory Return');
//    CnDebugger.LogMemDump(@TypeInfoBuf[0], L);
//{$ENDIF}
//  end;
//
//{$ENDIF}

  InspectComplete := True;
end;

procedure TCnRemoteEvaluationInspector.SetObjectAddr(const Value: Pointer);
var
  L: Integer;
begin
  inherited;
  if Value = nil then
    FObjectExpr := ''
  else
  begin
    L := StrLen(PChar(Value));
    if L > 0 then
    begin
      SetLength(FObjectExpr, L);
      Move(Value^, FObjectExpr[1], L * SizeOf(Char));
    end;
  end;
end;

end.

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

unit CnPropertyCompareFrm;
{ |<PRE>
================================================================================
* ������ƣ�CnPack ר�Ұ�
* ��Ԫ���ƣ�������ԶԱȴ��嵥Ԫ
* ��Ԫ���ߣ���Х��LiuXiao�� liuxiao@cnpack.org
* ��    ע��
* ����ƽ̨��Win7 + Delphi 5
* ���ݲ��ԣ�δ����
* �� �� �����ô����е��ַ����ݲ����ϱ��ػ�����ʽ
* �޸ļ�¼��2021.04.18
*               ������Ԫ��ʵ�ֻ�������
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Contnrs,
  TypInfo, StdCtrls, ComCtrls, ToolWin, Menus, ExtCtrls, ActnList, CommCtrl, Grids,
  {$IFNDEF STAND_ALONE}
  CnWizClasses, CnWizUtils, CnWizIdeUtils, CnWizManager, CnComponentSelector,
  {$ENDIF}
  {$IFDEF SUPPORT_ENHANCED_RTTI} Rtti, {$ENDIF}
  CnConsts, CnWizConsts, CnWizMultiLang, CnCommon, CnPropSheetFrm, CnWizShareImages;

const
  WM_SYNC_SELECT = WM_USER + $30;

type
{$IFNDEF STAND_ALONE}
  TCnPropertyCompareManager = class;

  TCnSelectCompareExecutor = class(TCnContextMenuExecutor)
  {* ���һ��ѡ������Ĳ˵����ʾΪѡΪ�����Ƚ����}
  private
    FManager: TCnPropertyCompareManager;
  public
    function GetActive: Boolean; override;
    function GetCaption: string; override;

    property Manager: TCnPropertyCompareManager read FManager write FManager;
  end;

  TCnDoCompareExecutor = class(TCnContextMenuExecutor)
  {* ���һ��������ѡ������Ĳ˵����ʾΪ�� XX �Ƚϣ��������Ƚ�}
  private
    FManager: TCnPropertyCompareManager;
  public
    function GetActive: Boolean; override;
    function GetCaption: string; override;

    property Manager: TCnPropertyCompareManager read FManager write FManager;
  end;

  TCnPropertyCompareManager = class(TComponent)
  private
    FSelectExtutor: TCnSelectCompareExecutor; // ֻѡ��һ��ʱ������ѡΪ���
    FCompareExecutor: TCnDoCompareExecutor;   // ֻѡ����һ��ʱ���� xxxx �Ƚϣ���ѡ������ʱ�Ƚ�����
    FLeftComponent: TComponent;
    FRightObject: TComponent;
    FSelection: TList;
    procedure SetLeftComponent(const Value: TComponent);
    procedure SetRightComponent(const Value: TComponent);
    function GetSelectionCount: Integer;
    procedure SelectExecute(Sender: TObject);
    procedure CompareExecute(Sender: TObject);
  protected
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property LeftComponent: TComponent read FLeftComponent write SetLeftComponent;
    property RightObject: TComponent read FRightObject write SetRightComponent;
    property SelectionCount: Integer read GetSelectionCount;
  end;

{$ENDIF}

  TCnDiffPropertyObject = class(TCnPropertyObject)
  private
    FIsSingle: Boolean;
    FModified: Boolean;
  public
    property IsSingle: Boolean read FIsSingle write FIsSingle;
    {* �Զ��Ƿ������Զ�Ӧ}
    property Modified: Boolean read FModified write FModified;
    {* �Ƿ�Ķ���}
  end;

  TCnPropertyCompareForm = class(TCnTranslateForm)
    mmMain: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    tlbMain: TToolBar;
    btnNewCompare: TToolButton;
    pnlMain: TPanel;
    spl2: TSplitter;
    pnlLeft: TPanel;
    pnlRight: TPanel;
    pnlDisplay: TPanel;
    pbFile: TPaintBox;
    pbPos: TPaintBox;
    actlstPropertyCompare: TActionList;
    actExit: TAction;
    actSelectLeft: TAction;
    actSelectRight: TAction;
    actPropertyToRight: TAction;
    actPropertyToLeft: TAction;
    pmGrid: TPopupMenu;
    actRefresh: TAction;
    actPrevDiff: TAction;
    actNextDiff: TAction;
    gridLeft: TStringGrid;
    gridRight: TStringGrid;
    actNewCompare: TAction;
    actCompareObjProp: TAction;
    Select1: TMenuItem;
    SelectLeftComponent1: TMenuItem;
    SelectRight1: TMenuItem;
    actNewCompare1: TMenuItem;
    Refresh1: TMenuItem;
    Assign1: TMenuItem;
    actPropertyToLeft1: TMenuItem;
    actPropertyToRight1: TMenuItem;
    PreviousDifferent1: TMenuItem;
    NextDifferent1: TMenuItem;
    Help1: TMenuItem;
    actAllToLeft: TAction;
    actAllToRight: TAction;
    actHelp: TAction;
    Help2: TMenuItem;
    N1: TMenuItem;
    AllToLeft1: TMenuItem;
    AllToRight1: TMenuItem;
    ToLeft1: TMenuItem;
    ToRight1: TMenuItem;
    AllToLeft2: TMenuItem;
    AllToRight2: TMenuItem;
    PreviousDifferent2: TMenuItem;
    NextDifferent2: TMenuItem;
    AllToLeft3: TMenuItem;
    btnRefresh: TToolButton;
    btnSelectLeft: TToolButton;
    btnSelectRight: TToolButton;
    btn1: TToolButton;
    btn2: TToolButton;
    btnPropertyToLeft: TToolButton;
    btnPropertyToRight: TToolButton;
    btnAllToLeft: TToolButton;
    btnAllToRight: TToolButton;
    btn7: TToolButton;
    btnPrevDiff: TToolButton;
    btnNextDiff: TToolButton;
    btn3: TToolButton;
    btnHelp: TToolButton;
    actOptions: TAction;
    N2: TMenuItem;
    Options1: TMenuItem;
    btnOptions: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure actSelectLeftExecute(Sender: TObject);
    procedure actSelectRightExecute(Sender: TObject);
    procedure pnlResize(Sender: TObject);
    procedure gridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure gridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure gridTopLeftChanged(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actNewCompareExecute(Sender: TObject);
    procedure actPropertyToRightExecute(Sender: TObject);
    procedure actPropertyToLeftExecute(Sender: TObject);
    procedure actlstPropertyCompareUpdate(Action: TBasicAction;
      var Handled: Boolean);
    procedure actPrevDiffExecute(Sender: TObject);
    procedure actNextDiffExecute(Sender: TObject);
    procedure gridDblClick(Sender: TObject);
    procedure actCompareObjPropExecute(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
  private
    FLeftObject: TObject;
    FRightObject: TObject;
    FLeftProperties: TObjectList;
    FRightProperties: TObjectList;
    function ListContainsProperty(const APropName: string; List: TObjectList): Boolean;
    procedure TransferProperty(PFrom, PTo: TCnDiffPropertyObject; FromObj, ToObj: TObject);
    procedure SelectGridRow(Grid: TStringGrid; ARow: Integer);
    procedure LoadProperty(List: TObjectList; AObject: TObject);
    procedure MakeAlignList;   // �������Ի�����룬�м����հ�
    procedure MakeSingleMarks; // ���������Ա�ע�Է��Ƿ�Ϊ��
    procedure GetGridSelectObjects(var SelectLeft, SelectRight: Integer;
      var LeftObj, RightObj: TCnDiffPropertyObject);
    procedure OnSyncSelect(var Msg: TMessage); message WM_SYNC_SELECT;
  public
    procedure LoadProperties;
    procedure ShowProperties(IsRefresh: Boolean = False);

    property LeftObject: TObject read FLeftObject write FLeftObject;
    property RightObject: TObject read FRightObject write FRightObject;
  end;

procedure CompareTwoObjects(ALeft: TObject; ARight: TObject);

implementation

{$R *.DFM}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  PROPNAME_LEFT_MARGIN = 16;
  PROP_NAME_MIN_WIDTH = 60;

function PropInfoName(PropInfo: PPropInfo): string;
begin
  Result := string(PropInfo^.Name);
end;

procedure CompareTwoObjects(ALeft: TObject; ARight: TObject);
var
  CompareForm: TCnPropertyCompareForm;
begin
  if (ALeft <> nil) and (ARight <> nil) and (ALeft <> ARight) then
  begin
    CompareForm := TCnPropertyCompareForm.Create(Application);
    CompareForm.LeftObject := ALeft;
    CompareForm.RightObject := ARight;
    CompareForm.LoadProperties;
    CompareForm.ShowProperties;
    CompareForm.Show;
  end;
end;

procedure DrawTinyDotLine(Canvas: TCanvas; X1, X2, Y1, Y2: Integer);
var
  XStep, YStep, I: Integer;
begin
  with Canvas do
  begin
    if X1 = X2 then
    begin
      YStep := Abs(Y2 - Y1) div 2; // Y �����ܲ�������ֵ
      if Y1 < Y2 then
      begin
        for I := 0 to YStep - 1 do
        begin
          MoveTo(X1, Y1 + (2 * I + 1));
          LineTo(X1, Y1 + (2 * I + 2));
        end;
      end
      else
      begin
        for I := 0 to YStep - 1 do
        begin
          MoveTo(X1, Y1 - (2 * I + 1));
          LineTo(X1, Y1 - (2 * I + 2));
        end;
      end;
    end
    else if Y1 = Y2 then
    begin
      XStep := Abs(X2 - X1) div 2; // X �����ܲ���
      if X1 < X2 then
      begin
        for I := 0 to XStep - 1 do
        begin
          MoveTo(X1 + (2 * I + 1), Y1);
          LineTo(X1 + (2 * I + 2), Y1);
        end;
      end
      else
      begin
        for I := 0 to XStep - 1 do
        begin
          MoveTo(X1 - (2 * I + 1), Y1);
          LineTo(X1 - (2 * I + 2), Y1);
        end;
      end;
    end;
  end;
end;

{$IFNDEF STAND_ALONE}

{ TCnPropertyCompareManager }

procedure TCnPropertyCompareManager.CompareExecute(Sender: TObject);
var
  Comp, Comp2: TComponent;
begin
  if (SelectionCount = 1) and (FLeftComponent <> nil) then
  begin
    Comp := TComponent(FSelection[0]);
    if (Comp <> nil) and (Comp <> FLeftComponent) then
    begin
      RightObject := Comp;
{$IFDEF DEBUG}
      CnDebugger.LogMsg('TCnPropertyCompareManager Compare Execute for Selected and Left.');
{$ENDIF}
    end;
  end
  else if SelectionCount = 2 then
  begin
    Comp := TComponent(FSelection[0]);
    Comp2 := TComponent(FSelection[1]);
    if (Comp <> nil) and (Comp2 <> nil) and (Comp <> Comp2) then
    begin
{$IFDEF DEBUG}
    CnDebugger.LogFmt('TCnPropertyCompareManager Compare Execute for 2 Selected Components: %s vs %s.',
      [Comp.Name, Comp2.Name]);
{$ENDIF}
      LeftComponent := Comp;
      RightObject := Comp2;
    end;
  end;

  CompareTwoObjects(LeftComponent, RightObject);
end;

constructor TCnPropertyCompareManager.Create(AOwner: TComponent);
begin
  inherited;
  FSelection := TList.Create;

  FSelectExtutor := TCnSelectCompareExecutor.Create;
  FCompareExecutor := TCnDoCompareExecutor.Create;

  FSelectExtutor.Manager := Self;
  FCompareExecutor.Manager := Self;

  FSelectExtutor.OnExecute := SelectExecute;
  FCompareExecutor.OnExecute := CompareExecute;

  RegisterDesignMenuExecutor(FSelectExtutor);
  RegisterDesignMenuExecutor(FCompareExecutor);
end;

destructor TCnPropertyCompareManager.Destroy;
begin
  FSelection.Free;
  inherited;
end;

function TCnPropertyCompareManager.GetSelectionCount: Integer;
begin
  Result := FSelection.Count;
end;

procedure TCnPropertyCompareManager.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if Operation = opRemove then
  begin
    if AComponent = FLeftComponent then
    begin
      FLeftComponent := nil;
{$IFDEF DEBUG}
      CnDebugger.LogMsg('TCnPropertyCompareManager Get Free Notification. Left set nil.');
{$ENDIF}
    end
    else if AComponent = FRightObject then
    begin
      FRightObject := nil;
{$IFDEF DEBUG}
      CnDebugger.LogMsg('TCnPropertyCompareManager Get Free Notification. Right set nil.');
{$ENDIF}
    end;
  end;
end;

procedure TCnPropertyCompareManager.SelectExecute(Sender: TObject);
var
  Comp: TComponent;
begin
  if SelectionCount = 1 then
  begin
    Comp := TComponent(FSelection[0]);
    if Comp <> nil then
      LeftComponent := Comp;
  end;
end;

procedure TCnPropertyCompareManager.SetLeftComponent(
  const Value: TComponent);
begin
  if FLeftComponent <> Value then
  begin
    if FLeftComponent <> nil then
      FLeftComponent.RemoveFreeNotification(Self);
    FLeftComponent := Value;

{$IFDEF DEBUG}
    if FLeftComponent = nil then
      CnDebugger.LogMsg('TCnPropertyCompareManager LeftComponent Set to nil.')
    else
      CnDebugger.LogMsg('TCnPropertyCompareManager LeftComponent Set to ' + FLeftComponent.Name);
{$ENDIF}

    if FLeftComponent <> nil then
      FLeftComponent.FreeNotification(Self);
  end;
end;

procedure TCnPropertyCompareManager.SetRightComponent(
  const Value: TComponent);
begin
  if FRightObject <> Value then
  begin
    if FRightObject <> nil then
      FRightObject.RemoveFreeNotification(Self);
    FRightObject := Value;

{$IFDEF DEBUG}
    if FRightObject = nil then
      CnDebugger.LogMsg('TCnPropertyCompareManager RightComponent Set to nil.')
    else
      CnDebugger.LogMsg('TCnPropertyCompareManager RightComponent Set to ' + FRightObject.Name);
{$ENDIF}

    if FRightObject <> nil then
      FRightObject.FreeNotification(Self);
  end;
end;

{ TCnSelectCompareExecutor }

function TCnSelectCompareExecutor.GetActive: Boolean;
begin
  // ֻѡ��һ��ʱ����
  Result := FManager.SelectionCount = 1;
{$IFDEF DEBUG}
  CnDebugger.LogBoolean(Result, 'TCnSelectCompareExecutor GetActive');
{$ENDIF}
end;

function TCnSelectCompareExecutor.GetCaption: string;
var
  Comp: TComponent;
begin
  Result := '';
  IdeGetFormSelection(FManager.FSelection);

  // ֻѡ��һ��ʱ������Ϊѡ��Ϊ���Ƚ����
  if FManager.SelectionCount = 1 then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogPointer(FManager.FSelection[0], 'TCnSelectCompareExecutor FManager.FSelection[0]');
{$ENDIF}
    Comp := TComponent(FManager.FSelection[0]);
    if Comp <> nil then
      Result := Format(SCnPropertyCompareSelectCaptionFmt, [Comp.Name, Comp.ClassName]);
  end;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnSelectCompareExecutor GetCaption: ' + Result);
{$ENDIF}
end;

{ TCnDoCompareExecutor }

function TCnDoCompareExecutor.GetActive: Boolean;
begin
  // ֻѡ��һ��ʱ������ Left ʱ������
  // ѡ������ʱ������
  Result := (FManager.SelectionCount = 2) or
    ((FManager.LeftComponent <> nil) and (FManager.SelectionCount = 1));
{$IFDEF DEBUG}
  CnDebugger.LogBoolean(Result, 'TCnDoCompareExecutor GetActive');
{$ENDIF}
end;

function TCnDoCompareExecutor.GetCaption: string;
var
  Comp, Comp2: TComponent;
begin
  Result := '';
  IdeGetFormSelection(FManager.FSelection);
  // ֻѡ��һ��ʱ������ Left ʱ�������� Left �Ƚ�
  // ѡ������ʱ�����رȽ�����

  if FManager.SelectionCount = 1 then
  begin
    Comp := TComponent(FManager.FSelection[0]);
    if (Comp <> nil) and (FManager.LeftComponent <> nil) then
      Result := Format(SCnPropertyCompareToComponentsFmt,
        [FManager.LeftComponent.Name, FManager.LeftComponent.ClassName]);
  end
  else if FManager.SelectionCount = 2 then
  begin
    Comp := TComponent(FManager.FSelection[0]);
    Comp2 := TComponent(FManager.FSelection[1]);
    Result := Format(SCnPropertyCompareTwoComponentsFmt,
      [Comp.Name, Comp.ClassName, Comp2.Name, Comp2.ClassName]);
  end;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnDoCompareExecutor GetCaption: ' + Result);
{$ENDIF}
end;

{$ENDIF}

function PropertyListCompare(Item1, Item2: Pointer): Integer;
var
  P1, P2: TCnPropertyObject;
begin
  P1 := TCnPropertyObject(Item1);
  P2 := TCnPropertyObject(Item2);

  Result := CompareStr(P1.PropName, P2.PropName);
end;

{ TCnPropertyCompareForm }

procedure TCnPropertyCompareForm.LoadProperties;
begin
  FLeftProperties.Clear;
  FRightProperties.Clear;

  if FLeftObject <> nil then
    LoadProperty(FLeftProperties, FLeftObject);
  if FRightObject <>nil then
  LoadProperty(FRightProperties, FRightObject);

  FLeftProperties.Sort(PropertyListCompare);
  FRightProperties.Sort(PropertyListCompare);

  // �������Զ��룬�Դﵽ���б�����һ��
  MakeAlignList;
  MakeSingleMarks;
end;

procedure TCnPropertyCompareForm.FormCreate(Sender: TObject);
begin
  FLeftProperties := TObjectList.Create(True);
  FRightProperties := TObjectList.Create(True);

  pnlLeft.OnResize(pnlLeft);
  pnlRight.OnResize(pnlRight);

//  FOldLeftGridWindowProc := gridLeft.WindowProc;
//  FOldRightGridWindowProc := gridRight.WindowProc;
//  gridLeft.WindowProc := LeftGridWindowProc;
//  gridRight.WindowProc := RightGridWindowProc;
end;

procedure TCnPropertyCompareForm.LoadProperty(List: TObjectList;
  AObject: TObject);
var
  AProp: TCnPropertyObject;
{$IFDEF SUPPORT_ENHANCED_RTTI}
  RttiContext: TRttiContext;
  RttiType: TRttiType;
  RttiProperty: TRttiProperty;
{$ELSE}
  PropListPtr: PPropList;
  I, APropCount: Integer;
  PropInfo: PPropInfo;
{$ENDIF}
begin
{$IFDEF SUPPORT_ENHANCED_RTTI}
  // D2010 �����ϣ�ʹ���� RTTI ������ȡ��������
  RttiContext := TRttiContext.Create;
  try
    RttiType := RttiContext.GetType(AObject.ClassInfo);
    if RttiType <> nil then
    begin
      for RttiProperty in RttiType.GetProperties do
      begin
        if RttiProperty.PropertyType.TypeKind in tkProperties then
        begin
          if RttiProperty.Visibility <> mvPublished then // ֻ�� published ��
            Continue;

          if ListContainsProperty(RttiProperty.Name, List) then // ���ࡢ�����������ͬ������
            Continue;

          AProp := TCnDiffPropertyObject.Create;
          AProp.IsNewRTTI := True;

          AProp.PropName := RttiProperty.Name;
          AProp.PropType := RttiProperty.PropertyType.TypeKind;
          AProp.IsObjOrIntf := AProp.PropType in [tkClass, tkInterface];

          // ��д��Ȩ�ޣ�����ָ�����ͣ��ſ��޸ģ����������û����
          AProp.CanModify := (RttiProperty.IsWritable) and (RttiProperty.PropertyType.TypeKind
            in CnCanModifyPropTypes);

          if RttiProperty.IsReadable then
          begin
            try
              AProp.PropRttiValue := RttiProperty.GetValue(AObject)
            except
              // Getting Some Property causes Exception. Catch it.
              AProp.PropRttiValue := nil;
            end;

            AProp.ObjValue := nil;
            AProp.IntfValue := nil;
            try
              if AProp.IsObjOrIntf and RttiProperty.GetValue(AObject).IsObject then
                AProp.ObjValue := RttiProperty.GetValue(AObject).AsObject
              else if AProp.IsObjOrIntf and (RttiProperty.GetValue(AObject).TypeInfo <> nil) and
                (RttiProperty.GetValue(AObject).TypeInfo^.Kind = tkInterface) then
                AProp.IntfValue := RttiProperty.GetValue(AObject).AsInterface;
            except
              // Getting Some Property causes Exception. Catch it.;
            end;
          end
          else
            AProp.PropRttiValue := SCnCanNotReadValue;

          AProp.DisplayValue := GetRttiPropValueStr(AObject, RttiProperty);
          List.Add(AProp);
        end;
      end;
    end;
  finally
    RttiContext.Free;
  end;

{$ELSE}

  APropCount := GetTypeData(PTypeInfo(AObject.ClassInfo))^.PropCount;
  GetMem(PropListPtr, APropCount * SizeOf(Pointer));
  GetPropList(PTypeInfo(AObject.ClassInfo), tkAny, PropListPtr);

  for I := 0 to APropCount - 1 do
  begin
    PropInfo := PropListPtr^[I];
    if PropInfo^.PropType^^.Kind in tkProperties then
    begin
      AProp := TCnDiffPropertyObject.Create;

      AProp.PropName := PropInfoName(PropInfo);
      AProp.PropType := PropInfo^.PropType^^.Kind;
      AProp.IsObjOrIntf := AProp.PropType in [tkClass, tkInterface];

      // ��д��Ȩ�ޣ�����ָ�����ͣ��ſ��޸ģ����������û����
      AProp.CanModify := (PropInfo^.SetProc <> nil) and (PropInfo^.PropType^^.Kind
        in CnCanModifyPropTypes);

      AProp.PropValue := GetPropValue(AObject, PropInfoName(PropInfo));

      AProp.ObjValue := nil;
      AProp.IntfValue := nil;
      if AProp.IsObjOrIntf then
      begin
        if AProp.PropType = tkClass then
          AProp.ObjValue := GetObjectProp(AObject, PropInfo)
        else
          AProp.IntfValue := IUnknown(GetOrdProp(AObject, PropInfo));
      end;

      AProp.DisplayValue := GetPropValueStr(AObject, PropInfo);;
      List.Add(AProp);
    end;
  end;
{$ENDIF}
end;

procedure TCnPropertyCompareForm.ShowProperties(IsRefresh: Boolean);

  procedure FillGridWithProperties(G: TStringGrid; Props: TObjectList);
  var
    I: Integer;
    P: TCnPropertyObject;
  begin
    if (G = nil) or (Props = nil) then
      Exit;

    if not IsRefresh then // ����ʱ��������
      G.RowCount := 0;
    G.RowCount := Props.Count;

    for I := 0 to Props.Count - 1 do
    begin
      P := TCnPropertyObject(Props[I]);
      if P <> nil then
      begin
        if IsRefresh then
        begin
          if G.Cells[1, I] <> P.DisplayValue then
            G.Cells[1, I] := P.DisplayValue;
        end
        else
        begin
          G.Cells[0, I] := P.PropName;
          G.Cells[1, I] := P.DisplayValue;
        end;
      end;
    end;
  end;

begin
  FillGridWithProperties(gridLeft, FLeftProperties);
  FillGridWithProperties(gridRight, FRightProperties);
end;

procedure TCnPropertyCompareForm.MakeAlignList;
var
  L, R, C: Integer;
  PL, PR: TCnPropertyObject;
  Merge: TStringList;
begin
  Merge := TStringList.Create;
  Merge.Duplicates := dupIgnore;

  try
    L := 0;
    R := 0;
    while (L < FLeftProperties.Count) and (R < FRightProperties.Count) do
    begin
      PL := TCnPropertyObject(FLeftProperties[L]);
      PR := TCnPropertyObject(FRightProperties[R]);

      C := CompareStr(PL.PropName, PR.PropName);
      if C = 0 then
      begin
        Inc(L);
        Inc(R);
        Merge.Add(PL.PropName);
      end
      else if C < 0 then // �����С
      begin
        Merge.Add(PL.PropName);
        Inc(L);
      end
      else // �ұ���С
      begin
        Merge.Add(PR.PropName);
        Inc(R);
      end;
    end;

    // Merge �еõ��鲢�������㣬Ȼ�����Ҹ����Լ�ÿһ���Ӧ������
    L := 0;
    while L < FLeftProperties.Count do
    begin
      PL := TCnPropertyObject(FLeftProperties[L]);
      R := Merge.IndexOf(PL.PropName);

      // R һ���� >= L
      if R > L then
      begin
        // �� L ��ǰһ�������ʵ������� nil
        for C := 1 to R - L do
          FLeftProperties.Insert(L, nil);
        Inc(L, R - L);
      end;

      Inc(L);
    end;

    R := 0;
    while R < FRightProperties.Count do
    begin
      PR := TCnPropertyObject(FRightProperties[R]);
      L := Merge.IndexOf(PR.PropName);

      // L һ���� >= R
      if L > R then
      begin
        // �� R ��ǰһ�������ʵ������� nil
        for C := 1 to L - R do
          FRightProperties.Insert(R, nil);
        Inc(R, L - R);
      end;

      Inc(R);
    end;

    // β�����ȵĻ�������
    if FLeftProperties.Count > FRightProperties.Count then
    begin
      for L := 0 to FLeftProperties.Count - FRightProperties.Count - 1 do
        FRightProperties.Add(nil);
    end
    else if FRightProperties.Count > FLeftProperties.Count then
    begin
      for L := 0 to FRightProperties.Count - FLeftProperties.Count - 1 do
        FLeftProperties.Add(nil);
    end;
  finally
    Merge.Free;
  end;
end;

procedure TCnPropertyCompareForm.FormResize(Sender: TObject);
begin
  pnlLeft.Width := pnlLeft.Parent.Width div 2 - 5;
end;

procedure TCnPropertyCompareForm.OnSyncSelect(var Msg: TMessage);
var
  Old: TSelectCellEvent;
  G: TStringGrid;
  R: Integer;
  CR: TGridRect;
begin
  if Msg.Msg = WM_SYNC_SELECT then
  begin
    G := TStringGrid(Msg.WParam);
    R := Msg.LParam;

    if G <> nil then
    begin
      CR := G.Selection;
      if (CR.Top <> R) or (CR.Bottom <> R) then
      begin
        Old := G.OnSelectCell;
        G.OnSelectCell := nil;
        if G.Cells[0, R] = '' then // Ŀ����û����
        begin
          CR.Top := -1;
          CR.Bottom := -1;
        end
        else
        begin
          CR.Top := R;
          CR.Bottom := R;
        end;
        CR.Left := 0;
        CR.Right := 1;
        G.Selection := CR;
        G.Invalidate;

        G.OnSelectCell := Old;
      end;
    end;
  end;
end;

procedure TCnPropertyCompareForm.MakeSingleMarks;
var
  I: Integer;
  PL, PR: TCnDiffPropertyObject;
begin
  if FLeftProperties.Count = FRightProperties.Count then
  begin
    for I := 0 to FLeftProperties.Count - 1 do
    begin
      PL := TCnDiffPropertyObject(FLeftProperties[I]);
      PR := TCnDiffPropertyObject(FRightProperties[I]);

      if (PL = nil) and (PR <> nil) then
        PR.IsSingle := True;

      if (PR = nil) and (PL <> nil) then
        PL.IsSingle := True;
    end;
  end;
end;

function TCnPropertyCompareForm.ListContainsProperty(
  const APropName: string; List: TObjectList): Boolean;
var
  I: Integer;
  P: TCnPropertyObject;
begin
  Result := False;
  for I := 0 to List.Count - 1 do
  begin
    P := TCnPropertyObject(List[I]);
    if (P <> nil) and (P.PropName = APropName) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

procedure TCnPropertyCompareForm.actSelectLeftExecute(Sender: TObject);
{$IFNDEF STAND_ALONE}
var
  List: TComponentList;
{$ENDIF}
begin
{$IFNDEF STAND_ALONE}
  List := TComponentList.Create(False);
  try
    if SelectComponentsWithSelector(List) then
    begin
      if List.Count = 1 then
        LeftObject := List[0]
      else if List.Count > 1 then
      begin
        LeftObject := List[0];   // ѡ�����������ϣ��������
        RightObject := List[1];
      end
      else
        Exit;

      LoadProperties;
      ShowProperties;
    end;
  finally
    List.Free;
  end;
{$ENDIF}
end;

procedure TCnPropertyCompareForm.actSelectRightExecute(Sender: TObject);
{$IFNDEF STAND_ALONE}
var
  List: TComponentList;
{$ENDIF}
begin
{$IFNDEF STAND_ALONE}
  List := TComponentList.Create(False);
  try
    if SelectComponentsWithSelector(List) then
    begin
      if List.Count = 1 then
        RightObject := List[0]
      else if List.Count > 1 then
      begin
        RightObject := List[0];  // ѡ�����������ϣ����Һ���
        LeftObject := List[1];
      end
      else
        Exit;

      LoadProperties;
      ShowProperties;
    end;
  finally
    List.Free;
  end;
{$ENDIF}
end;

procedure TCnPropertyCompareForm.pnlResize(Sender: TObject);
var
  P: TPanel;
  G: TStringGrid;
  I: Integer;
  C: TControl;
begin
  if Sender is TPanel then
  begin
    P := Sender as TPanel;
    G := nil;
    for I := 0 to P.ControlCount - 1 do
    begin
      C := P.Controls[I];
      if C is TStringGrid then
      begin
        G := C as TStringGrid;
        Break;
      end;
    end;

    if G <> nil then
    begin
      I := (P.Width - 2) div 3;
      if I < PROP_NAME_MIN_WIDTH then
        I := PROP_NAME_MIN_WIDTH;

      G.ColWidths[0] := I;
      G.ColWidths[1] := P.Width - I - 2;
    end;
  end;
end;

procedure TCnPropertyCompareForm.gridDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  S: string;
  H, W: Integer;
  G: TStringGrid;
  One, Another: TObjectList;
  P1, P2: TCnDiffPropertyObject;
begin
  G := Sender as TStringGrid;
  if G = gridLeft then
  begin
    One := FLeftProperties;
    Another := FRightProperties;
  end
  else
  begin
    One := FRightProperties;
    Another := FLeftProperties;
  end;

  if ARow >= One.Count then
    P1 := nil
  else
    P1 := TCnDiffPropertyObject(One[ARow]);

  if ARow >= Another.Count then
    P2 := nil
  else
    P2 := TCnDiffPropertyObject(Another[ARow]);

  // ������
  G.Canvas.Font.Color := clBtnText;
  G.Canvas.Brush.Style := bsSolid;

  if ACol = 0 then
  begin
    if (P2 <> nil) and P2.IsSingle then // �Լ�û�жԷ��У��׵ף�
      G.Canvas.Brush.Color := clWhite
    else
      G.Canvas.Brush.Color := clBtnFace;
  end
  else if gdSelected in State then
  begin
    if (P2 <> nil) and P2.IsSingle then // �Լ�û�жԷ��У��׵ף�
    begin
      G.Canvas.Brush.Color := clWhite;
    end
    else
    begin
      G.Canvas.Brush.Color := clHighlight;
      G.Canvas.Font.Color := clHighlightText;
    end;
  end
  else
  begin
    // ���ݶԱȽ�����ñ���ɫ
    G.Canvas.Brush.Color := clBtnFace;

    if (P1 <> nil) and P1.IsSingle then // �Լ��жԷ�û�У���ͨ�ҵף�
    begin

    end
    else if (P2 <> nil) and P2.IsSingle then // �Լ�û�жԷ��У��׵ף�
    begin
      G.Canvas.Brush.Color := clWhite;
    end
    else if (P1 <> nil) and (P2 <> nil) then
    begin
      if P1.DisplayValue <> P2.DisplayValue then  // �����Ҳ�ͬ������ף�
        G.Canvas.Brush.Color := $00C0C0FF;
    end;
    // ��������ͬ����ͨ�ҵף�
  end;

  G.Canvas.FillRect(Rect);

  // ������
  S := G.Cells[ACol, ARow];

  G.Canvas.Brush.Style := bsClear;
  H := G.Canvas.TextHeight(S);
  H := (Rect.Bottom - Rect.Top - H) div 2;
  if H < 0 then
    H := 0;
  if ACol = 0 then
    W := PROPNAME_LEFT_MARGIN
  else
    W := PROPNAME_LEFT_MARGIN div 2;
  G.Canvas.TextOut(Rect.Left + W, Rect.Top + H, S);

  // ����ָ���
  G.Canvas.Pen.Color := clBtnText;
  G.Canvas.Pen.Style := psSolid;

  DrawTinyDotLine(G.Canvas, Rect.Left, Rect.Right, Rect.Bottom - 1, Rect.Bottom - 1);

  // �� 0 �� 1 ֮�������
  if ACol = 0 then
  begin
    H := Rect.Right - 1;

    G.Canvas.Pen.Color := clBlack;
    G.Canvas.MoveTo(H, Rect.Top);
    G.Canvas.LineTo(H, Rect.Bottom);
  end
  else if ACol = 1 then
  begin
    G.Canvas.Pen.Color := clWhite;
    G.Canvas.MoveTo(Rect.Left, Rect.Top);
    G.Canvas.LineTo(Rect.Left, Rect.Bottom);
    G.Canvas.Pen.Color := clBlack;
    DrawTinyDotLine(G.Canvas, Rect.Right - 1, Rect.Right - 1, Rect.Top, Rect.Bottom);
  end;
end;

procedure TCnPropertyCompareForm.gridSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
var
  G: TStringGrid;
begin
  if Sender = gridLeft then
    G := gridRight
  else
    G := gridLeft;

  PostMessage(Handle, WM_SYNC_SELECT, Integer(G), ARow);
end;

procedure TCnPropertyCompareForm.gridTopLeftChanged(Sender: TObject);
var
  G: TStringGrid;
begin
  if Sender = gridLeft then
    G := gridRight
  else
    G := gridLeft;

  G.TopRow := (Sender as TStringGrid).TopRow;
end;

procedure TCnPropertyCompareForm.actRefreshExecute(Sender: TObject);
begin
  LoadProperties;
  ShowProperties(True);
end;

procedure TCnPropertyCompareForm.actExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TCnPropertyCompareForm.actNewCompareExecute(Sender: TObject);
var
  CompareForm: TCnPropertyCompareForm;
begin
  CompareForm := TCnPropertyCompareForm.Create(Application);;
  CompareForm.LoadProperties;
  CompareForm.ShowProperties;
  CompareForm.Show;
end;

procedure TCnPropertyCompareForm.actPropertyToRightExecute(
  Sender: TObject);
var
  ARow: Integer;
  POne, PAnother: TCnDiffPropertyObject;
begin
  ARow := gridLeft.Selection.Top;
  if (ARow < 0) or (ARow >= FLeftProperties.Count) then
    Exit;

  POne := TCnDiffPropertyObject(FLeftProperties[ARow]);
  PAnother := TCnDiffPropertyObject(FRightProperties[ARow]);

  TransferProperty(POne, PAnother, FLeftObject, FRightObject);

  LoadProperties;
  ShowProperties(True);
  SelectGridRow(gridLeft, ARow);
end;

procedure TCnPropertyCompareForm.TransferProperty(PFrom,
  PTo: TCnDiffPropertyObject; FromObj, ToObj: TObject);
var
  V: Variant;
begin
  if (PFrom = nil) or (PTo = nil) or (FromObj = nil) or (ToObj = nil) then
    Exit;

  if PFrom.PropName <> PTo.PropName then
    Exit;

{$IFDEF SUPPORT_ENHANCED_RTTI}
  if PFrom.IsNewRTTI and PTo.IsNewRTTI then
  begin


    Exit;
  end;
{$ENDIF}

  // TODO: Object ��������
  V := GetPropValue(FromObj, PFrom.PropName);
  SetPropValue(ToObj, PTo.PropName, V);
end;

procedure TCnPropertyCompareForm.actPropertyToLeftExecute(Sender: TObject);
var
  ARow: Integer;
  POne, PAnother: TCnDiffPropertyObject;
begin
  ARow := gridRight.Selection.Top;
  if (ARow < 0) or (ARow >= FRightProperties.Count) then
    Exit;

  POne := TCnDiffPropertyObject(FRightProperties[ARow]);
  PAnother := TCnDiffPropertyObject(FLeftProperties[ARow]);

  TransferProperty(POne, PAnother, FRightObject, FLeftObject);

  LoadProperties;
  ShowProperties(True);
  SelectGridRow(gridRight, ARow);
end;

procedure TCnPropertyCompareForm.SelectGridRow(Grid: TStringGrid;
  ARow: Integer);
var
  Sel: TGridRect;
begin
  Sel.Top := ARow;
  Sel.Bottom := ARow;
  Sel.Left := 0;
  Sel.Right := Grid.ColCount - 1;

  Grid.Selection := Sel;

  // ���� ARow �ɼ�
  if ARow < Grid.TopRow then
    Grid.TopRow := ARow
  else if ARow > (Grid.TopRow + Grid.VisibleRowCount - 1) then
    Grid.TopRow := ARow - Grid.VisibleRowCount + 1;
end;

procedure TCnPropertyCompareForm.actlstPropertyCompareUpdate(
  Action: TBasicAction; var Handled: Boolean);
var
  Sl, Sr: Integer;
  Pl, Pr: TCnDiffPropertyObject;
begin
  GetGridSelectObjects(Sl, Sr, Pl, Pr);

  if Action = actPropertyToLeft then
    (Action as TCustomAction).Enabled := (Pr <> nil) and not Pr.IsSingle
  else if Action = actPropertyToRight then
    (Action as TCustomAction).Enabled := (Pl <> nil) and not Pl.IsSingle
  else if Action = actCompareObjProp then
    (Action as TCustomAction).Enabled := (Pl <> nil) and Pl.IsObjOrIntf
     and (Pr <> nil) and Pr.IsObjOrIntf and ((Pl.ObjValue <> nil) or (Pr.ObjValue <> nil));
end;

procedure TCnPropertyCompareForm.actPrevDiffExecute(Sender: TObject);
var
  I, Sl, Sr: Integer;
  Pl, Pr: TCnDiffPropertyObject;
begin
  GetGridSelectObjects(Sl, Sr, Pl, Pr);

  if (Sl > 0) and (Sr > 0) then
  begin
    for I := Sl - 1 downto 0 do
    begin
      Pl := TCnDiffPropertyObject(FLeftProperties[I]);
      Pr := TCnDiffPropertyObject(FRightProperties[I]);
      if (Pl <> nil) and (Pr <> nil) then
      begin
        if Pl.DisplayValue <> Pr.DisplayValue then
        begin
          SelectGridRow(gridLeft, I);
          SelectGridRow(gridRight, I);
          Exit;
        end;
      end;
    end;
  end;

  ErrorDlg(SCnPropertyCompareNoPrevDiff);
end;

procedure TCnPropertyCompareForm.GetGridSelectObjects(var SelectLeft,
  SelectRight: Integer; var LeftObj, RightObj: TCnDiffPropertyObject);
begin
  SelectLeft := gridLeft.Selection.Top;
  SelectRight := gridRight.Selection.Top;

  if (SelectLeft >= 0) and (SelectLeft < FLeftProperties.Count) then
    LeftObj := TCnDiffPropertyObject(FLeftProperties[SelectLeft])
  else
    LeftObj := nil;

  if (SelectRight >= 0) and (SelectRight < FRightProperties.Count) then
    RightObj := TCnDiffPropertyObject(FRightProperties[SelectRight])
  else
    RightObj := nil;
end;

procedure TCnPropertyCompareForm.actNextDiffExecute(Sender: TObject);
var
  I, Sl, Sr: Integer;
  Pl, Pr: TCnDiffPropertyObject;
begin
  GetGridSelectObjects(Sl, Sr, Pl, Pr);

  if (Sl < FLeftProperties.Count) and (Sr < FRightProperties.Count) then
  begin
    for I := Sl + 1 to FLeftProperties.Count - 1 do
    begin
      Pl := TCnDiffPropertyObject(FLeftProperties[I]);
      Pr := TCnDiffPropertyObject(FRightProperties[I]);
      if (Pl <> nil) and (Pr <> nil) then
      begin
        if Pl.DisplayValue <> Pr.DisplayValue then
        begin
          SelectGridRow(gridLeft, I);
          SelectGridRow(gridRight, I);
          Exit;
        end;
      end;
    end;
  end;

  ErrorDlg(SCnPropertyCompareNoNextDiff);
end;

procedure TCnPropertyCompareForm.gridDblClick(Sender: TObject);
begin
  actCompareObjProp.Execute;
end;

procedure TCnPropertyCompareForm.actCompareObjPropExecute(Sender: TObject);
var
  Sl, Sr: Integer;
  Pl, Pr: TCnDiffPropertyObject;
begin
  GetGridSelectObjects(Sl, Sr, Pl, Pr);
  if (Pl <> nil) and (Pr <> nil) then
  begin
    if Pl.IsObjOrIntf and Pr.IsObjOrIntf then
      CompareTwoObjects(Pl.ObjValue, Pr.ObjValue);
  end;
end;

procedure TCnPropertyCompareForm.actHelpExecute(Sender: TObject);
begin
  ShowFormHelp;
end;

end.

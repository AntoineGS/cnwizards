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
  TypInfo, CnConsts, CnWizConsts, CnWizMultiLang, CnPropSheetFrm, {$IFNDEF STAND_ALONE}
  CnWizClasses, CnWizUtils, CnWizIdeUtils, CnWizManager, {$ENDIF}
  {$IFDEF SUPPORT_ENHANCED_RTTI} Rtti, {$ENDIF}
  StdCtrls, ComCtrls, ToolWin, Menus, ExtCtrls;

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
    FRightComponent: TComponent;
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
    property RightComponent: TComponent read FRightComponent write SetRightComponent;
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
    ToolButton1: TToolButton;
    pnlMain: TPanel;
    spl2: TSplitter;
    pnlLeft: TPanel;
    pnlRight: TPanel;
    pnlDisplay: TPanel;
    pbFile: TPaintBox;
    pbPos: TPaintBox;
    lvLeft: TListView;
    lvRight: TListView;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ListViewChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
  private
    FLeftComponet: TComponent;
    FRightComponent: TComponent;
    FLeftProperties: TObjectList;
    FRightProperties: TObjectList;
    function ListContainsProperty(const APropName: string; List: TObjectList): Boolean;
    procedure LoadProperty(List: TObjectList; Component: TComponent);
    procedure MakeAlignList;
    procedure MakeSingleMarks;
    procedure OnSyncSelect(var Msg: TMessage); message WM_SYNC_SELECT;
  public
    procedure LoadProperties;
    procedure ShowProperties;

    property LeftComponet: TComponent read FLeftComponet write FLeftComponet;
    property RightComponent: TComponent read FRightComponent write FRightComponent;
  end;

procedure CompareTwoComponents(ALeft: TComponent; ARight: TComponent);

implementation

{$R *.DFM}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

function PropInfoName(PropInfo: PPropInfo): string;
begin
  Result := string(PropInfo^.Name);
end;

procedure CompareTwoComponents(ALeft: TComponent; ARight: TComponent);
var
  CompareForm: TCnPropertyCompareForm;
begin
  if (ALeft <> nil) and (ARight <> nil) and (ALeft <> ARight) then
  begin
    CompareForm := TCnPropertyCompareForm.Create(Application);
    CompareForm.LeftComponet := ALeft;
    CompareForm.RightComponent := ARight;
    CompareForm.LoadProperties;
    CompareForm.ShowProperties;
    CompareForm.Show;
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
      RightComponent := Comp;
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
      RightComponent := Comp2;
    end;
  end;

  CompareTwoComponents(LeftComponent, RightComponent);
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
    else if AComponent = FRightComponent then
    begin
      FRightComponent := nil;
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
  if FRightComponent <> Value then
  begin
    if FRightComponent <> nil then
      FRightComponent.RemoveFreeNotification(Self);
    FRightComponent := Value;

{$IFDEF DEBUG}
    if FRightComponent = nil then
      CnDebugger.LogMsg('TCnPropertyCompareManager RightComponent Set to nil.')
    else
      CnDebugger.LogMsg('TCnPropertyCompareManager RightComponent Set to ' + FRightComponent.Name);
{$ENDIF}

    if FRightComponent <> nil then
      FRightComponent.FreeNotification(Self);
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

  LoadProperty(FLeftProperties, FLeftComponet);
  LoadProperty(FRightProperties, FRightComponent);

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
end;

procedure TCnPropertyCompareForm.LoadProperty(List: TObjectList;
  Component: TComponent);
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
    RttiType := RttiContext.GetType(Component.ClassInfo);
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
              AProp.PropRttiValue := RttiProperty.GetValue(Component)
            except
              // Getting Some Property causes Exception. Catch it.
              AProp.PropRttiValue := nil;
            end;

            AProp.ObjValue := nil;
            AProp.IntfValue := nil;
            try
              if AProp.IsObjOrIntf and RttiProperty.GetValue(Component).IsObject then
                AProp.ObjValue := RttiProperty.GetValue(Component).AsObject
              else if AProp.IsObjOrIntf and (RttiProperty.GetValue(Component).TypeInfo <> nil) and
                (RttiProperty.GetValue(Component).TypeInfo^.Kind = tkInterface) then
                AProp.IntfValue := RttiProperty.GetValue(Component).AsInterface;
            except
              // Getting Some Property causes Exception. Catch it.;
            end;
          end
          else
            AProp.PropRttiValue := SCnCanNotReadValue;

          AProp.DisplayValue := GetRttiPropValueStr(Component, RttiProperty);
          List.Add(AProp);
        end;
      end;
    end;
  finally
    RttiContext.Free;
  end;

{$ELSE}

  APropCount := GetTypeData(PTypeInfo(Component.ClassInfo))^.PropCount;
  GetMem(PropListPtr, APropCount * SizeOf(Pointer));
  GetPropList(PTypeInfo(Component.ClassInfo), tkAny, PropListPtr);

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

      AProp.PropValue := GetPropValue(Component, PropInfoName(PropInfo));

      AProp.ObjValue := nil;
      AProp.IntfValue := nil;
      if AProp.IsObjOrIntf then
      begin
        if AProp.PropType = tkClass then
          AProp.ObjValue := GetObjectProp(Component, PropInfo)
        else
          AProp.IntfValue := IUnknown(GetOrdProp(Component, PropInfo));
      end;

      AProp.DisplayValue := GetPropValueStr(Component, PropInfo);;
      List.Add(AProp);
    end;
  end;
{$ENDIF}
end;

procedure TCnPropertyCompareForm.ShowProperties;
var
  I: Integer;
  P: TCnPropertyObject;
  Item: TListItem;
begin
  lvLeft.Items.Clear;
  for I := 0 to FLeftProperties.Count - 1 do
  begin
    Item := lvLeft.Items.Add;
    P := TCnPropertyObject(FLeftProperties[I]);
    if P <> nil then
    begin
      Item.Caption := P.PropName;
      Item.SubItems.Add(P.DisplayValue);
    end;
  end;

  lvRight.Items.Clear;
  for I := 0 to FRightProperties.Count - 1 do
  begin
    Item := lvRight.Items.Add;
    P := TCnPropertyObject(FRightProperties[I]);
    if P <> nil then
    begin
      Item.Caption := P.PropName;
      Item.SubItems.Add(P.DisplayValue);
    end;
  end;
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
  finally
    Merge.Free;
  end;
end;

procedure TCnPropertyCompareForm.FormResize(Sender: TObject);
begin
  lvLeft.Width := lvLeft.Parent.Width div 2 - 5;
end;

procedure TCnPropertyCompareForm.ListViewChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
var
  LV: TListView;
begin
  if Sender = lvLeft then
    LV := lvRight
  else
    LV := lvLeft;

  if (ctState = Change) and (Item <> nil) then
  begin
    if Item.Selected and ((LV.Selected = nil) or (LV.Selected.Index <> Item.Index)) then
      PostMessage(Handle, WM_SYNC_SELECT, Integer(LV), Item.Index);
  end;
end;

procedure TCnPropertyCompareForm.OnSyncSelect(var Msg: TMessage);
var
  Old: TLVChangeEvent;
  LV: TListView;
begin
  if Msg.Msg = WM_SYNC_SELECT then
  begin
    LV := TListView(Msg.WParam);
    if (LV <> nil) and not LV.Items[Msg.LParam].Selected then
    begin
      Old := LV.OnChange;
      LV.OnChange := nil;
      LV.Items[Msg.LParam].Selected := True;
      LV.OnChange := Old;
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

end.

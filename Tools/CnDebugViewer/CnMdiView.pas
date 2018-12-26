{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2018 CnPack 开发组                       }
{                   ------------------------------------                       }
{                                                                              }
{            本开发包是开源的自由软件，您可以遵照 CnPack 的发布协议来修        }
{        改和重新发布这一程序。                                                }
{                                                                              }
{            发布这一开发包的目的是希望它有用，但没有任何担保。甚至没有        }
{        适合特定目的而隐含的担保。更详细的情况请参阅 CnPack 发布协议。        }
{                                                                              }
{            您应该已经和开发包一起收到一份 CnPack 发布协议的副本。如果        }
{        还没有，可访问我们的网站：                                            }
{                                                                              }
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnMdiView;
{ |<PRE>
================================================================================
* 软件名称：CnDebugViewer
* 单元名称：子窗体单元
* 单元作者：刘啸（LiuXiao） liuxiao@cnpack.org
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2014.10.05
*               显示统一使用 FViewStore 以修正和 FStore 可能不一致的问题。
*           2008.01.18
*               Sesame 增加分秒方式显示时间
*           2005.01.01
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CnMsgClasses, ComCtrls, StdCtrls, ExtCtrls, Grids, VirtualTrees, Buttons,
  CnLangMgr, ToolWin, Menus, ActnList;

type
  TCnFilterUpdate = (fuThreadId, fuTag);
  TCnFilterUpdates = set of TCnFilterUpdate;

  TCnMemoContent = (mcNone, mcMsg, mcTime);

  TCnMsgChild = class(TForm)
    lvTime: TListView;
    splDetail: TSplitter;
    splTime: TSplitter;
    pnlTree: TPanel;
    pnlFilter: TPanel;
    Splitter3: TSplitter;
    pnlLevel: TPanel;
    cbbLevel: TComboBox;
    Splitter4: TSplitter;
    pnlThread: TPanel;
    cbbThread: TComboBox;
    pnlMsg: TPanel;
    Splitter5: TSplitter;
    pnlType: TPanel;
    cbbType: TComboBox;
    pnlLabel: TPanel;
    pnlTag: TPanel;
    cbbTag: TComboBox;
    pnlDetail: TPanel;
    mmoDetail: TMemo;
    cbbSearch: TComboBox;
    btnSearch: TSpeedButton;
    Label1: TLabel;
    tlbBookmark: TToolBar;
    btnBookmark: TToolButton;
    pmTree: TPopupMenu;
    C1: TMenuItem;
    A1: TMenuItem;
    D1: TMenuItem;
    E1: TMenuItem;
    S1: TMenuItem;
    X1: TMenuItem;
    F1: TMenuItem;
    B1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    MenuDropBookmark: TMenuItem;
    M1: TMenuItem;
    SaveMemDump1: TMenuItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure lvTimeData(Sender: TObject; Item: TListItem);
    procedure HeadPanelResize(Sender: TObject);
    procedure FilterChange(Sender: TObject);
    procedure cbbSearchKeyPress(Sender: TObject; var Key: Char);
    procedure lvTimeClick(Sender: TObject);
    procedure lvTimeEnter(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure pmTreePopup(Sender: TObject);
  private
    FStore: TCnMsgStore;     // 交由外部线程用来读写并通知本界面更新
    FViewStore: TCnMsgStore; // 用来显示的，其内部Item只是引用，由FStore内容同步更新
    FProcessID: DWORD;
    FProcName: string;
    FMsgTree: TVirtualStringTree;
    FFilter: TCnDisplayFilter;
    FMemContent: TCnMemoContent;
    FSelectedIndex: Integer;
    FBookmarks: array[0..9] of Integer;
    FHasBookmarks: Boolean;
    FIsResizing: Boolean;

    procedure TreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
    procedure TreeColumnResize(Sender: TVTHeader; Column: TColumnIndex);
    // procedure TreeClick(Sender: TObject);
    procedure TreeChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure TreeBeforeItemPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; ItemRect: TRect;
      var CustomDraw: Boolean);
    procedure TreeBeforeItemErase(Sender: TBaseVirtualTree; TargetCanvas:
      TCanvas; Node: PVirtualNode; ItemRect: TRect; var ItemColor: TColor;
      var EraseAction: TItemEraseAction);

    procedure TreeEnter(Sender: TObject);
    procedure TreeKeyPress(Sender: TObject; var Key: Char);

    procedure InitTree;
    procedure InitControls;

    procedure UpdateToViewStore(Source, Dest: TCnMsgStore);
    procedure UpdateConditionsToView(Content: TCnFilterUpdates);
    procedure UpdateViewStoreToTree;
    procedure AddAItemToTree(var OldIndent: Integer; var PrevNode: PVirtualNode;
      AItem: TCnMsgItem);
    procedure AddBatchItemToView(AStore: TCnMsgStore; StartIndex, EndIndex: Integer);
    procedure RefreshTime(Sender: TObject);

    function GetAnEmptyBookmarkSlot: Integer;
    function GetSlotFromBookmarkLine(Line: Integer): Integer;
    procedure SetSlotToBookmark(Slot, Line: Integer);
    procedure ReleaseAnBookmarkSlot(Slot: Integer);
    procedure ClearBookMarks;
    procedure BookmarkMenuClick(Sender: TObject);
    procedure pnlTreeOnResize(Sender: TObject);
    procedure SetStore(const Value: TCnMsgStore);
    function GetSelectedContent: string;
    function GetSelectedItem: TCnMsgItem;
  protected
    procedure DoCreate; override;
    procedure LanguageChanged(Sender: TObject);
  public
    procedure OnStoreChange(Sender: TObject; Operation: TCnStoreChangeType;
      StartIndex, EndIndex: Integer);
    procedure ClearStores;
    procedure ClearTimes;
    procedure LoadFromFile(const FileName: string);
    procedure SaveToFile(const FileName: string);
    procedure FindNode(const AText: string; IsDown: Boolean; IsSeperator: Boolean = False);
    function CheckFind(AItem: TCnMsgItem; const AText: string; IsSeperator: Boolean = False): Boolean;
    procedure ToggleBookmark;
    procedure UpdateBookmarkMenu;
    procedure UpdateBookmarkToMainMenu;
    procedure GotoPrevBookmark;
    procedure GotoNextBookmark;
    procedure ClearAllBookmarks;
    procedure RequireRefreshTime;
    procedure InitFont;
    function DescriptionOfMsg(Index: Integer; AMsgItem: TCnMsgItem): string;
    function DescriptionOfTime(Index: Integer ): string;

    property Store: TCnMsgStore read FStore write SetStore;
    property Filter: TCnDisplayFilter read FFilter;
    property ProcessID: DWORD read FProcessID write FProcessID;
    property ProcName: string read FProcName write FProcName;
    property MsgTree: TVirtualStringTree read FMsgTree;
    property HasBookmarks: Boolean read FHasBookmarks;
    property IsResizing: Boolean read FIsResizing write FIsResizing;
    property SelectedContent: string read GetSelectedContent;
    property SelectedItem: TCnMsgItem read GetSelectedItem;
  end;

var
  CnMsgChild: TCnMsgChild;

implementation

uses CnCommon, CnViewMain, CnViewCore, CnDebugIntf, CnMsgXMLFiler;

{$R *.DFM}

procedure TCnMsgChild.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TCnMsgChild.FormCreate(Sender: TObject);
begin
  // 初始化工作，创建 Store
  FViewStore := TCnMsgStore.Create(nil, False);
  FStore := CnMsgManager.AddStore(0, SCnNoneProcName);
  if FStore <> nil then
    FStore.OnChange := OnStoreChange;

  CnMainViewer.UpdateFormInSwitch(Self, fsAdd);
  FMsgTree := TVirtualStringTree.Create(Self);
  FFilter := TCnDisplayFilter.Create;

  InitControls;
end;

procedure TCnMsgChild.FormDestroy(Sender: TObject);
begin
  CnLanguageManager.RemoveChangeNotifier(LanguageChanged);
  CnViewerOptions.MsgColumnWidth := MsgTree.Header.Columns[1].Width;
  CnMainViewer.UpdateFormInSwitch(Self, fsDelete);
  FFilter.Free;
  FViewStore.Free;
  if FStore <> nil then
  begin
    CnMsgManager.RemoveStore(FStore);
    FStore := nil;
  end;
end;

procedure TCnMsgChild.OnStoreChange(Sender: TObject;
  Operation: TCnStoreChangeType; StartIndex, EndIndex: Integer);
begin
  if Sender is TCnMsgStore then
  begin
    case Operation of
      ctProcess:
        begin
          ProcessID := (Sender as TCnMsgStore).ProcessID;
          ProcName := (Sender as TCnMsgStore).ProcName;
          CnMainViewer.UpdateFormInSwitch(Self, fsUpdate);
        end;
      ctAdd:
        begin
          AddBatchItemToView(Sender as TCnMsgStore, StartIndex, EndIndex);
        end;
      ctModify:
        begin

        end;
      ctTimeChanged:
        begin
          RefreshTime(Sender);
        end;
    else
      ; // Other situation
    end;
  end;
end;

procedure TCnMsgChild.SetStore(const Value: TCnMsgStore);
begin
  if FStore <> Value then
  begin
    if FStore <> nil then
      CnMsgManager.RemoveStore(FStore);
    FStore := Value;
    if FStore <> nil then
    begin
      FStore.OnChange := OnStoreChange;
      FProcessID := FStore.ProcessID;
      FProcName := FStore.ProcName;
    end;
  end;
end;

procedure TCnMsgChild.FormActivate(Sender: TObject);
begin
  if not CnMainViewer.UpdatingSwitch and not CnMainViewer.ClickingSwitch then
    CnMainViewer.UpdateFormInSwitch(Self, fsActiveChange);
end;

procedure TCnMsgChild.lvTimeData(Sender: TObject; Item: TListItem);
var
  ATimeItem: TCnTimeItem;
begin
  if (FStore = nil) or (Item.Index > FStore.TimeCount) then Exit;
  ATimeItem := FStore.Times[Item.Index];
  if ATimeItem = nil then Exit;
  
  Item.Caption := IntToStr(Item.Index + 1);
  Item.SubItems.Add(IntToStr(ATimeItem.PassCount));
  Item.SubItems.Add(Format('%f', [ATimeItem.CPUPeriod / CPUClock]));
  Item.SubItems.Add(Format('%f', [ATimeItem.AvePeriod / CPUClock]));
  Item.SubItems.Add(Format('%f', [ATimeItem.MaxPeriod / CPUClock]));
  Item.SubItems.Add(Format('%f', [ATimeItem.MinPeriod / CPUClock]));

  Item.SubItems.Add(ATimeItem.Tag);
end;

procedure TCnMsgChild.TreeGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
var
  Index: Integer;
begin
  if FViewStore = nil then Exit;
  
  Index := Node^.AbsoluteIndex - 1; //.AbsoluteIndex(Node);
  // 原始的VirtualTree中，获得该 Index 严重影响显示速度，
  // 后经修改VirtualTree源码解决，但只支持顺序增加的节点

  case Column of
    0: CellText := IntToStr(Index + 1);                                  // 序号
    1: CellText := FViewStore.Msgs[Index].Msg;                           // 正文
    2: CellText := SCnMsgTypeDescArray[FViewStore.Msgs[Index].MsgType]^; // 类型
    3: CellText := IntToStr(FViewStore.Msgs[Index].Level);               // 层次
    4: CellText := '$' + IntToHex(FViewStore.Msgs[Index].ThreadId, 2);   // 线程 ID
    5: CellText := FViewStore.Msgs[Index].Tag;
    6: CellText := GetTimeDesc(FViewStore.Msgs[Index]);
  else
    CellText := '';
  end;
end;

procedure TCnMsgChild.UpdateToViewStore(Source, Dest: TCnMsgStore);
var
  I: Integer;
begin
  if (Source = nil) or (Dest = nil) then Exit;
  Dest.ClearMsgs;
  for I := 0 to Source.MsgCount - 1 do
    if FFilter.CheckVisible(Source.Msgs[I]) then
      Dest.AddAMsgItem(Source.Msgs[I]);
end;

procedure TCnMsgChild.InitTree;
const
  CnColumnsWidth: array[0..6] of Integer = (36, 240, 55, 41, 77, 60, 84);
var
  I: Integer;
begin
  if FMsgTree = nil then Exit;

  FMsgTree.Align := alClient;
  FMsgTree.DefaultNodeHeight := 16;
  FMsgTree.LineStyle := lsSolid;
  FMsgTree.Hint := SCnHintMsgTree;
  FMsgTree.Header.Options := FMsgTree.Header.Options + [hoVisible];
  FMsgtree.TreeOptions.SelectionOptions := FMsgtree.TreeOptions.SelectionOptions
    + [toFullRowSelect, toMiddleClickSelect, toRightClickSelect, toMultiSelect];
  FMsgTree.TreeOptions.PaintOptions := FMsgTree.TreeOptions.PaintOptions + [toHideFocusRect];
  FMsgTree.TreeOptions.AutoOptions := FMsgTree.TreeOptions.AutoOptions + [toAutoExpand, toAutoScroll];
  FMsgTree.OnGetText := TreeGetText;
  FMsgTree.OnChange := TreeChange;
  FMsgTree.OnEnter := TreeEnter;
  FMsgTree.OnKeyPress := TreeKeyPress;
  FMsgTree.OnColumnResize := TreeColumnResize;
  FMsgTree.OnBeforeItemPaint := TreeBeforeItemPaint;
  FMsgTree.OnBeforeItemErase := TreeBeforeItemErase;

  FMsgTree.Parent := pnlTree;
  FMsgTree.PopupMenu := pmTree;
  for I := Low(SCnTreeColumnArray) to High(SCnTreeColumnArray) do
  begin
    with FMsgTree.Header.Columns.Add do
    begin
      Text := SCnTreeColumnArray[I]^;
      if (I <> 1) or (CnViewerOptions.MsgColumnWidth < CnColumnsWidth[I]) then
        Width := CnColumnsWidth[I]
      else
        Width := CnViewerOptions.MsgColumnWidth; // 信息列宽
    end;
  end;
  
  FMsgTree.Header.MainColumn := 1; // "输出信息" 列
  FMsgTree.Header.Columns[0].MinWidth := CnColumnsWidth[0];
  FMsgTree.Header.Options := FMsgTree.Header.Options - [hoDrag];
  for I := 0 to FMsgTree.Header.Columns.Count - 1 do
    FMsgTree.OnColumnResize(FMsgTree.Header, I);
end;

procedure TCnMsgChild.HeadPanelResize(Sender: TObject);
var
  I: Integer;
begin
  if Sender is TPanel then
    for I := 0 to (Sender as TPanel).ControlCount - 1 do
      if (Sender as TPanel).Controls[I] is TComboBox then
        ((Sender as TPanel).Controls[I] as TComboBox).Width := (Sender as TPanel).Width - 1;
end;

procedure TCnMsgChild.TreeColumnResize(Sender: TVTHeader;
  Column: TColumnIndex);
var
  APanel: TPanel;
begin
  case Column of
  0: APanel := pnlLabel;
  1: APanel := pnlMsg;
  2: APanel := pnlType;
  3: APanel := pnlLevel;
  4: APanel := pnlThread;
  5: APanel := pnlTag;
  6: APanel := nil;
  else
    APanel := nil;
  end;
  if APanel = nil then Exit;
  APanel.Width := FMsgTree.Header.Columns[Column].Width + Column mod 2;
  // 小技巧，避免 Width 的误差累计
end;

procedure TCnMsgChild.InitControls;
var
  I: Integer;
begin
  cbbLevel.Items.Clear;
  for I := CnDefLevel downto 0 do
    cbbLevel.Items.Add('<=' + IntToStr(I));
  cbbLevel.ItemIndex := 0;

  cbbType.Items.Clear;
  for I := Ord(Low(CnMsgTypesArray)) to Ord(High(CnMsgTypesArray)) do
    cbbType.Items.Add(SCnMsgTypesDescArray[I]^);
  cbbType.ItemIndex := 0;

  cbbThread.Items.Clear;
  cbbThread.Items.Add('*');
  cbbThread.ItemIndex := 0;
  pnlTree.OnResize := pnlTreeOnResize;
  InitTree;

  for I := Low(FBookmarks) to High(FBookmarks) do
    FBookmarks[I] := CnInvalidLine;
  btnBookmark.Enabled := FHasBookmarks;

  InitFont;
end;

procedure TCnMsgChild.InitFont;
begin
  if CnViewerOptions.DisplayFont <> nil then
  begin
    FMsgTree.Font.Assign(CnViewerOptions.DisplayFont);
    mmoDetail.Font := CnViewerOptions.DisplayFont;
    lvTime.Font := CnViewerOptions.DisplayFont;
  end;
end;

procedure TCnMsgChild.UpdateConditionsToView(Content: TCnFilterUpdates);
var
  I, OldItemIndex: Integer;
  OldOnChange: TNotifyEvent;
begin
  if fuThreadId in Content then  // 加入新的 ThreadID 条件
  begin
    OldOnChange := cbbThread.OnChange;
    try
      OldItemIndex := cbbThread.ItemIndex;

      cbbThread.OnChange := nil;
      cbbThread.Items.Clear;
      cbbThread.Items.Add('*');
      for I := 0 to FFilter.Conditions.ThreadIDs.Count - 1 do
        if FFilter.Conditions.ThreadIDs[I] <> nil then
          cbbThread.Items.Add('$' + IntToHex(Integer(FFilter.Conditions.ThreadIDs[I]), 2));

      if cbbThread.Items.Count > 0 then
        cbbThread.ItemIndex := OldItemIndex;
    finally
      cbbThread.OnChange := OldOnChange;
    end;
  end;

  if fuTag in Content then // 加入新的 Tags 条件
  begin
    OldOnChange := cbbTag.OnChange;
    try
      OldItemIndex := cbbTag.ItemIndex;
      if OldItemIndex = -1 then
        OldItemIndex := 0;

      cbbTag.OnChange := nil;
      cbbTag.Items.Clear;
      for I := 0 to FFilter.Conditions.Tags.Count - 1 do
        cbbTag.Items.Add(FFilter.Conditions.Tags[I]);

      if cbbTag.Items.Count > 0 then
        cbbTag.ItemIndex := OldItemIndex;
    finally
      cbbTag.OnChange := OldOnChange;
    end;
  end;
end;

procedure TCnMsgChild.FilterChange(Sender: TObject);
begin
  // 根据操作，修改 Filter，然后更新界面
  if Sender = cbbType then
  begin
    FFilter.MsgTypes := CnMsgTypesArray[cbbType.ItemIndex];
  end
  else if Sender = cbbThread then
  begin
    if cbbThread.ItemIndex <= 0 then
      FFilter.ThreadId := 0
    else
      FFilter.ThreadId := Cardinal(FFilter.Conditions.ThreadIDs[cbbThread.ItemIndex])
    // ThreadIDs 中多了第一项 0 通配，但 cbbThread中第一项也是 *，所以相等，无需加一
  end

  else if Sender = cbbLevel then
    FFilter.Level := CnDefLevel - cbbLevel.ItemIndex
  else if Sender = cbbTag then
    FFilter.Tag := cbbTag.Text;

  UpdateToViewStore(FStore, FViewStore);
  UpdateViewStoreToTree;
  mmoDetail.Clear;
end;

procedure TCnMsgChild.UpdateViewStoreToTree;
var
  I, OldIndent: Integer;
  Node: PVirtualNode;
begin
  FMsgTree.Clear;
  if FViewStore.MsgCount = 0 then Exit;

  OldIndent := FViewStore.Msgs[0].Indent;
  Node := FMsgTree.AddChild(nil, nil);

  for I := 1 to FViewStore.MsgCount - 1 do
    AddAItemToTree(OldIndent, Node, FViewStore.Msgs[I]);
end;

procedure TCnMsgChild.AddAItemToTree(var OldIndent: Integer;
  var PrevNode: PVirtualNode; AItem: TCnMsgItem);
var
  Indent: Integer;
  Parent, OldParent: PVirtualNode;
begin
  Indent := AItem.Indent;
  if Indent = OldIndent then      // 同层，是前一节点的父节点的最后子节点
  begin
    if PrevNode = nil then
      PrevNode := FMsgTree.AddChild(nil, nil)  // 前一节点无父节点，按顶层加之
    else
      PrevNode := FMsgTree.AddChild(PrevNode.Parent, nil);
  end
  else if Indent > OldIndent then // 进一层，是前一节点的子节点
  begin
    OldParent := PrevNode;
    PrevNode := FMsgTree.AddChild(PrevNode, nil);
    FMsgTree.FullExpand(OldParent);
  end
  else // 退一层，是前一节点的父节点的父节点的最后子节点
  begin
    if PrevNode = nil then
      Parent := nil
    else
      Parent := PrevNode.Parent;

    // 如果父节点是根节点，则不能再取 Parent 了，否则就会出错
    if (Parent <> nil) and (Parent <> FMsgTree.RootNode) then
      Parent := Parent.Parent;

    PrevNode := FMsgTree.AddChild(Parent, nil);
  end;

  OldIndent := Indent;
end;

procedure TCnMsgChild.TreeChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  Index: Integer;
begin
  if (FViewStore <> nil) and (Node <> nil) then
  begin
    Index := Node^.AbsoluteIndex - 1;
    FSelectedIndex := Index;
    mmoDetail.Text := DescriptionOfMsg(Index, FViewStore.Msgs[Index]);
    FMemContent := mcMsg;
  end;
end;

procedure TCnMsgChild.TreeBeforeItemPaint(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; ItemRect: TRect;
  var CustomDraw: Boolean);
const
  SCnMsgCustomDrawTypes: TCnMsgTypes = [cmtSeparator];
var
  Index, WidthStart: Integer;
  AMsgItem: TCnMsgItem;
  AText: string;
  ATree: TVirtualStringTree;
begin
  if FViewStore = nil then Exit;
  
  Index := Node^.AbsoluteIndex - 1;
  // 原始的 VirtualTree 获得该 Index 严重影响显示速度，目前优化后无此问题了。
  AMsgItem := FViewStore.Msgs[Index];
  if AMsgItem = nil then Exit;
      
  CustomDraw := (AMsgItem.MsgType in SCnMsgCustomDrawTypes);
  if not CustomDraw then Exit;

  ATree := Sender as TVirtualStringTree;
  case AMsgItem.MsgType of
    cmtSeparator:
      begin
        with TargetCanvas do
        begin
          Font := ATree.Font;
          if vsSelected in Node.States then
          begin
            Brush.Color := ATree.Colors.SelectionRectangleBlendColor;
            Font.Color := clHighlightText;
          end
          else if AMsgItem.Bookmarked then
            TargetCanvas.Brush.Color := $0066CC66
          else
            Brush.Color := ATree.Color;

          FillRect(ItemRect);
          Pen.Color := clRed;
          Pen.Width := 3;

          AText := IntToStr(Index + 1);
          if TextWidth(AText) + ATree.Margin + ATree.TextMargin < ATree.Header.Columns[0].Width then
            TextOut(ATree.TextMargin + ATree.Margin, ATree.Margin div 2, AText);
            
          WidthStart := ATree.Header.Columns[0].Width + 1;
          MoveTo(WidthStart, (ItemRect.Top + ItemRect.Bottom) div 2);
          LineTo(ItemRect.Right, (ItemRect.Top + ItemRect.Bottom) div 2);
        end;
      end;
  else
    ;
  end;
end;

procedure TCnMsgChild.ClearStores;
begin
  FMsgTree.Clear;
  FViewStore.ClearMsgs;
  if FStore <> nil then
    FStore.ClearMsgs;
  if FMemContent = mcMsg then
    mmoDetail.Clear;
end;

procedure TCnMsgChild.cbbSearchKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    if cbbSearch.Text <> '' then
    begin
      btnSearch.Click;
      if (cbbSearch.Items.IndexOf(cbbSearch.Text) < 0) then
      begin
        if (cbbSearch.Items.Count >= CnViewerOptions.SearchDownCount) then
          cbbSearch.Items.Delete(cbbSearch.Items.Count - 1);
        cbbSearch.Items.Insert(0, cbbSearch.Text);
      end;
    end;
    Key := #0;
  end;
end;

function TCnMsgChild.DescriptionOfMsg(Index: Integer;
  AMsgItem: TCnMsgItem): string;
begin
  Result := Format(SCnMsgDescriptionFmt, [Index + 1, AMsgItem.Indent,
    AMsgItem.Level, AMsgItem.ThreadId, AMsgItem.ProcessId, AMsgItem.Tag,
    {AMsgItem.MsgCPInterval, } GetLongTimeDesc(AMsgItem), AMsgItem.Msg]);
end;

procedure TCnMsgChild.lvTimeClick(Sender: TObject);
begin
  if lvTime.Selected <> nil then
  begin
    mmoDetail.Clear;
    mmoDetail.Text := DescriptionOfTime(lvTime.Selected.Index);
    FMemContent := mcTime;
  end;
end;

function TCnMsgChild.DescriptionOfTime(Index: Integer): string;
var
  dTime, aTime, MaxTime, MinTime: Double;
begin
  Result := '';
  if FStore = nil then Exit;
  //Add Sesame 2008-1-22 增加时分秒方式显示时间
  dTime := FStore.Times[Index].CPUPeriod / CPUClock;
  aTime := FStore.Times[Index].AvePeriod / CPUClock;
  MaxTime := FStore.Times[Index].MaxPeriod / CPUClock;
  MinTime := FStore.Times[Index].MinPeriod / CPUClock;

  if (Index >= 0) and (Index < FStore.TimeCount) then
    Result := Format(SCnTimeDescriptionFmt, [Index + 1, FStore.Times[Index].PassCount,
      //FStore.Times[Index].Tag, FStore.Times[Index].CPUPeriod / CPUClock]);
      FStore.Times[Index].Tag, dTime, FStore.UsToTime(dTime),
      aTime, FStore.UsToTime(aTime), MaxTime, FStore.UsToTime(MaxTime),
      MinTime, FStore.UsToTime(MinTime)]);
end;

procedure TCnMsgChild.ClearTimes;
begin
  if FStore <> nil then
    FStore.ClearTimes;
  lvTime.Items.Clear;
  if FMemContent = mcTime then
    mmoDetail.Clear;
end;

procedure TCnMsgChild.lvTimeEnter(Sender: TObject);
begin
  (Sender as TListView).OnClick(Sender);
end;

procedure TCnMsgChild.TreeEnter(Sender: TObject);
var
  Tree: TVirtualStringTree;
begin
  if Sender is TVirtualStringTree then
  begin
    Tree := Sender as TVirtualStringTree;
    if Assigned(Tree.OnChange) then
      Tree.OnChange(Tree, Tree.FocusedNode);
  end
end;

procedure TCnMsgChild.LoadFromFile(const FileName: string);
var
  Filer: ICnMsgFiler;
  Ext: string;
  DumpFile: TFileStream;
  AMsgDesc: TCnMsgDesc;
  MsgSize: Integer;
begin
  if (FStore <> nil) and FileExists(FileName) then
  begin
    Screen.Cursor := crHourGlass;
    try
      ClearStores;
      ClearTimes;
      ClearBookMarks;

      Ext := LowerCase(_CnExtractFileExt(FileName));
      if Ext = '.xml' then // 是 CnDebugViewer 保存的 XML 文件
      begin
        Filer := TCnMsgXMLFiler.Create;
        FStore.LoadFromFile(Filer, FileName);
        AddBatchItemToView(FStore, 0, FStore.MsgCount - 1);
        RefreshTime(FStore);
      end
      else if Ext = '.cdd' then // 是 CnDebug.pas 直接 Dump 出的文件
      begin
        DumpFile := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
        try
          FStore.BeginUpdate;
          try
            while DumpFile.Position < DumpFile.Size do
            begin
              DumpFile.Read(MsgSize, SizeOf(MsgSize));
              if MsgSize > SizeOf(TCnMsgDesc) then
                Break; // 出错跳出
              DumpFile.Seek(0 - SizeOf(MsgSize), soFromCurrent); // 回跳一下
              DumpFile.Read(AMsgDesc, MsgSize);
              FStore.AddMsgDesc(@AMsgDesc);
            end;
          except
            ; // 读完了
          end;
        finally
          FStore.EndUpdate;
        end;
      end;
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TCnMsgChild.SaveToFile(const FileName: string);
var
  Filer: ICnMsgFiler;
begin
  if FStore <> nil then
  begin
    Screen.Cursor := crHourGlass;
    try
      Filer := TCnMsgXMLFiler.Create;
      FStore.SaveToFile(Filer, FileName);
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TCnMsgChild.AddBatchItemToView(AStore: TCnMsgStore; StartIndex,
  EndIndex: Integer);
var
  I, Slot, OldIndent: Integer;
  UpdateContent: TCnFilterUpdates;
  AMsgItem: TCnMsgItem;
  PrevNode, LastNode: PVirtualNode;
begin
  if (AStore = nil) or (StartIndex < 0) or (EndIndex < 0) then Exit;
  for I := StartIndex to EndIndex do
  begin
    AMsgItem := AStore.Msgs[I];
    UpdateContent := [];
    if FFilter.Conditions.CheckAndAddThreadID(AMsgItem.ThreadId) then
      Include(UpdateContent, fuThreadId);
    if FFilter.Conditions.CheckAndAddTag(AMsgItem.Tag) then
      Include(UpdateContent, fuTag);
    UpdateConditionsToView(UpdateContent);

    // if not FFilter.Filtered or not FFilter.CheckVisible(AMsgItem) then
    if FFilter.Filtered and not FFilter.CheckVisible(AMsgItem) then
    begin
      // 此条不可见则不处理
    end
    else
    begin
      // FStore已由读写线程更新，此处复制可见Item到ViewStore中。
      if FViewStore.MsgCount > 0 then
        OldIndent := FViewStore.Msgs[FViewStore.MsgCount - 1].Indent
      else
        OldIndent := 0;
      FViewStore.AddAMsgItem(AMsgItem);
      PrevNode := FMsgTree.GetLast;
      AddAItemToTree(OldIndent, PrevNode, AMsgItem);

      if AMsgItem.Bookmarked then
      begin
        FHasBookmarks := True;
        Slot := GetAnEmptyBookmarkSlot();
        if Slot <> CnInvalidSlot then
        begin
          LastNode := FMsgTree.GetLast;
          if LastNode <> nil then
          begin
            SetSlotToBookmark(Slot, LastNode.AbsoluteIndex - 1);
            // Line 就是 Index，从 0 开始
            UpdateBookmarkMenu;
          end;
        end;
      end;

      // FMsgTree. 向下滚
      if CnViewerOptions.AutoScroll then
        PostMessage(FMsgTree.Handle, WM_KEYDOWN, VK_END, 0);
    end;
  end;
end;

procedure TCnMsgChild.RefreshTime(Sender: TObject);
begin
  lvTime.Items.Count := (Sender as TCnMsgStore).TimeCount;
  lvTime.Repaint;
  if Assigned(lvTime.OnClick) then
    lvTime.OnClick(lvTime);
end;

procedure TCnMsgChild.FindNode(const AText: string; IsDown: Boolean;
  IsSeperator: Boolean);
var
  I, OldPos: Integer;
  FoundNode: PVirtualNode;
begin
  if (AText = '') or (FStore = nil) then Exit;

  if FMsgTree.FocusedNode <> nil then
    OldPos := FMsgTree.FocusedNode.AbsoluteIndex // 从 1 开始的
  else
    OldPos := 0;

  try
    Screen.Cursor := crHourGlass;
    if IsDown then
    begin
      for I := OldPos to FViewStore.MsgCount - 1 do // 从选中的下一个开始搜索
      begin
        if CheckFind(FViewStore.Msgs[I], AText, IsSeperator) then
        begin
          FoundNode := FMsgTree.GetNodeByAbsoluteIndex(I + 1);
          FMsgTree.FocusedNode := FoundNode;
          FMsgTree.Selected[FoundNode] := True;
          Exit;
        end;
      end;

      if OldPos > 0 then
      begin
        for I := 0 to OldPos - 1 do // 循环查找
        begin
          if CheckFind(FViewStore.Msgs[I], AText, IsSeperator) then
          begin
            FoundNode := FMsgTree.GetNodeByAbsoluteIndex(I + 1);
            FMsgTree.FocusedNode := FoundNode;
            FMsgTree.Selected[FoundNode] := True;
            Exit;
          end;
        end;
      end;
    end
    else // 向上找
    begin
      if OldPos > 0 then
      begin
        for I := OldPos - 1 downto 0 do // 循环查找
        begin
          if CheckFind(FViewStore.Msgs[I], AText, IsSeperator) then
          begin
            FoundNode := FMsgTree.GetNodeByAbsoluteIndex(I + 1);
            FMsgTree.FocusedNode := FoundNode;
            FMsgTree.Selected[FoundNode] := True;
            Exit;
          end;
        end;
      end;

      for I := FViewStore.MsgCount - 1 downto OldPos do // 从选中的下一个开始搜索
      begin
        if CheckFind(FViewStore.Msgs[I], AText, IsSeperator) then
        begin
          FoundNode := FMsgTree.GetNodeByAbsoluteIndex(I + 1);
          FMsgTree.FocusedNode := FoundNode;
          FMsgTree.Selected[FoundNode] := True;
          Exit;
        end;
      end;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
  // 显示未找到
  ErrorDlg(SCnNotFound);
end;

function TCnMsgChild.CheckFind(AItem: TCnMsgItem;
  const AText: string; IsSeperator: Boolean): Boolean;
begin
  Result := False;
  if (AText = '') or (AItem = nil) then Exit;
  if IsSeperator then
    Result := AItem.MsgType = cmtSeparator
  else
    Result := Pos(UpperCase(AText), UpperCase(AItem.Msg)) > 0;
end;

procedure TCnMsgChild.btnSearchClick(Sender: TObject);
begin
  if Trim(cbbSearch.Text) <> '' then
    FindNode(cbbSearch.Text, True);
end;

procedure TCnMsgChild.TreeKeyPress(Sender: TObject; var Key: Char);
begin
  if Key in ['0'..'9', 'A'..'z'] then
  begin
    cbbSearch.SetFocus;
    PostMessage(cbbSearch.Handle, WM_CHAR, Integer(Key), 0);
  end;
end;

procedure TCnMsgChild.DoCreate;
begin
  inherited;
  CnLanguageManager.AddChangeNotifier(LanguageChanged);
  CnLanguageManager.TranslateForm(Self);
end;

procedure TCnMsgChild.LanguageChanged(Sender: TObject);
var
  I, OldIndex: Integer;
begin
  for I := Low(SCnTreeColumnArray) to High(SCnTreeColumnArray) do
  begin
    with FMsgTree.Header.Columns[I] do
    begin
      Text := SCnTreeColumnArray[I]^;
    end;
  end;
  FMsgTree.Hint := SCnHintMsgTree;

  OldIndex := cbbType.ItemIndex;
  cbbType.Items.Clear;
  cbbType.Items.Add(SCnMsgTypeNone);
  for I := Ord(Low(TCnMsgType)) to Ord(High(TCnMsgType)) do
    cbbType.Items.Add(SCnMsgTypeDescArray[TCnMsgType(I)]^);
  cbbType.ItemIndex := OldIndex;

  if FProcName = '' then
    CnMainViewer.UpdateFormInSwitch(Self, fsUpdate);
end;

function TCnMsgChild.GetAnEmptyBookmarkSlot: Integer;
var
  I: Integer;
begin
  Result := CnInvalidSlot;
  for I := Low(FBookmarks) to High(FBookmarks) do
  begin
    if FBookmarks[I] = CnInvalidLine then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

procedure TCnMsgChild.ReleaseAnBookmarkSlot(Slot: Integer);
begin
  if (FStore <> nil) and (Slot >= Low(FBookmarks)) and (Slot <= High(FBookmarks))
    and (FBookmarks[Slot] <> CnInvalidSlot) then
  begin
    if (FBookmarks[Slot] >= 0) and (FBookmarks[Slot] < FViewStore.MsgCount) then
      FViewStore.Msgs[FBookmarks[Slot]].Bookmarked := False;
    FBookmarks[Slot] := CnInvalidLine;
    FMsgTree.Refresh;
  end;
end;

function TCnMsgChild.GetSlotFromBookmarkLine(Line: Integer): Integer;
var
  I: Integer;
begin
  Result := CnInvalidSlot;
  for I := Low(FBookmarks) to High(FBookmarks) do
  begin
    if FBookmarks[I] = Line then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

procedure TCnMsgChild.SetSlotToBookmark(Slot, Line: Integer);
begin
  if (FStore <> nil) and (Slot >= Low(FBookmarks)) and (Slot <= High(FBookmarks)) then
  begin
    FViewStore.Msgs[Line].Bookmarked := True;
    FBookmarks[Slot] := Line;
    FMsgTree.Refresh;
  end;
end;

procedure TCnMsgChild.ToggleBookmark;
var
  Slot: Integer;
begin
  if FMsgTree.ObtainFirstSelection <> nil then
    FSelectedIndex := FMsgTree.ObtainFirstSelection^.AbsoluteIndex - 1;

  Slot := GetSlotFromBookmarkLine(FSelectedIndex);
  if Slot = CnInvalidSlot then
  begin
    Slot := GetAnEmptyBookmarkSlot;

    if Slot <> CnInvalidSlot then
      SetSlotToBookmark(Slot, FSelectedIndex)
    else
      ErrorDlg(SCnBookmarkFull);
  end
  else
    ReleaseAnBookmarkSlot(Slot);
  UpdateBookmarkMenu;
end;

procedure TCnMsgChild.TreeBeforeItemErase(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; ItemRect: TRect;
  var ItemColor: TColor; var EraseAction: TItemEraseAction);
var
  Index: Integer;
  AMsgItem: TCnMsgItem;
begin
  if FStore = nil then Exit;
  Index := Node^.AbsoluteIndex - 1;

  AMsgItem := FViewStore.Msgs[Index];
  if AMsgItem = nil then Exit;

  EraseAction := eaDefault;
  if AMsgItem.Bookmarked then
  begin
    ItemColor := $0066CC66;
    EraseAction := eaColor;
  end;
end;

procedure TCnMsgChild.UpdateBookmarkMenu;
var
  Item: TMenuItem;
  I, J: Integer;
begin
  J := 0;
  MenuDropBookmark.Clear;
  FHasBookmarks := False;
  for I := Low(FBookmarks) to High(FBookmarks) do
  begin
    if FBookmarks[I] <> CnInvalidLine then
    begin
      Inc(J);
      FHasBookmarks := True;

      Item := TMenuItem.Create(pmTree);
      Item.Caption := Format(SCnBookmark, [J, FBookmarks[I] + 1]);
      Item.Tag := I; // Slot
      Item.ImageIndex := 82;
      Item.OnClick := BookmarkMenuClick;
      MenuDropBookmark.Insert(MenuDropBookmark.Count, Item);
    end;
  end;
  btnBookmark.Enabled := FHasBookmarks;
  UpdateBookmarkToMainMenu;
end;

procedure TCnMsgChild.BookmarkMenuClick(Sender: TObject);
var
  Index: Integer;
  BookmarkVisible: Boolean;
begin
  if (Sender <> nil) and (FStore <> nil) then
  begin
    Index := (Sender as TComponent).Tag;
    if (Index >= Low(FBookmarks)) and (Index <= High(FBookmarks)) then
      Index := Abs(FBookmarks[Index]);

    // 超界或不在显示区则隐藏
    if (FViewStore.MsgCount > 0) and (Index < FViewStore.MsgCount) then
      BookmarkVisible := FViewStore.Msgs[Index].Bookmarked
    else
      BookmarkVisible := False;

    if not BookmarkVisible then
    begin
      ErrorDlg(SCnBookmarkNOTExist);
      Exit;
    end;

    FMsgTree.Selected[FMsgTree.GetNodeByAbsoluteIndex(Index + 1)] := True;
    FMsgTree.FocusedNode := FMsgTree.GetNodeByAbsoluteIndex(Index + 1);
  end;
end;

procedure TCnMsgChild.UpdateBookmarkToMainMenu;
var
  Item: TMenuItem;
  I, J: Integer;
begin
  J := 0;
  CnMainViewer.MenuJump.Clear;
  for I := Low(FBookmarks) to High(FBookmarks) do
  begin
    if FBookmarks[I] <> CnInvalidLine then
    begin
      Inc(J);

      Item := TMenuItem.Create(CnMainViewer.mmMain);
      Item.Caption := Format(SCnBookmark, [J, FBookmarks[I] + 1]);
      Item.Tag := I;
      Item.ImageIndex := 78;
      Item.OnClick := BookmarkMenuClick;
      CnMainViewer.MenuJump.Insert(CnMainViewer.MenuJump.Count, Item);
    end;
  end;
  CnMainViewer.MenuJump.Enabled := FHasBookmarks;
end;

procedure TCnMsgChild.GotoNextBookmark;
var
  I, Index: Integer;
begin
  if (FStore = nil) or (FMsgTree.TotalCount = 0) or (FMsgTree.FocusedNode = nil) then
    Exit;

  Index := FMsgTree.FocusedNode.AbsoluteIndex - 1;
  // AbsoluteIndex 从 1 开始

  for I := Index + 1 to FViewStore.MsgCount - 1 do
  begin
    if FViewStore.Msgs[I].Bookmarked then
    begin
      FMsgTree.Selected[FMsgTree.GetNodeByAbsoluteIndex(I + 1)] := True;
      FMsgTree.FocusedNode := FMsgTree.GetNodeByAbsoluteIndex(I + 1);
      Exit;
    end;
  end;
end;

procedure TCnMsgChild.GotoPrevBookmark;
var
  I, Index: Integer;
begin
  if (FStore = nil) or (FMsgTree.TotalCount = 0) or (FMsgTree.FocusedNode = nil) then
    Exit;

  Index := FMsgTree.FocusedNode.AbsoluteIndex - 1;
  // AbsoluteIndex 从 1 开始
  if Index = 0 then Exit;

  for I := Index - 1 downto 0 do
  begin
    if FViewStore.Msgs[I].Bookmarked then
    begin
      FMsgTree.Selected[FMsgTree.GetNodeByAbsoluteIndex(I + 1)] := True;
      FMsgTree.FocusedNode := FMsgTree.GetNodeByAbsoluteIndex(I + 1);
      Exit;
    end;
  end;
end;

procedure TCnMsgChild.ClearBookMarks;
var
  I: Integer;
begin
  for I := Low(FBookmarks) to High(FBookmarks) do
    ReleaseAnBookmarkSlot(I);
end;

procedure TCnMsgChild.pmTreePopup(Sender: TObject);
begin
  MenuDropBookmark.Enabled := FHasBookmarks;
  MenuDropBookmark.Caption := CnMainViewer.MenuJump.Caption;
end;

procedure TCnMsgChild.ClearAllBookmarks;
begin
  ClearBookMarks;
  UpdateBookmarkMenu;
  FMsgTree.Invalidate;
end;

procedure TCnMsgChild.pnlTreeOnResize(Sender: TObject);
var
  i: Integer;
begin
  if (not Showing) or IsResizing then
    Exit;

  with FMsgTree do
  begin
    Visible := False;
    try
      Header.Columns[1].Width := Width - Header.Columns[0].Width - 20;
      if not VertScrollBar.Visible then
        Header.Columns[1].Width := Header.Columns[1].Width - VertScrollBar.Size;
      for i := Header.Columns.Count - 1 downto 2 do
        Header.Columns[1].Width := Header.Columns[1].Width - Header.Columns[i].Width;
    finally
      Visible := True;
    end;
  end;
end;

function TCnMsgChild.GetSelectedContent: string;
var
  I, Index: Integer;
  List: TList;
  Node: PVirtualNode;
begin
  if FMsgTree.SelectedCount = 1 then
  begin
    if mmoDetail.SelLength > 0 then
      Result := mmoDetail.SelText
    else
      Result := mmoDetail.Lines.Text;
  end
  else
  begin
    List := TList.Create;
    FMsgTree.ObtainSelections(List);

    for I := 0 to List.Count - 1 do
    begin
      Node := PVirtualNode(List[I]);
      Index := Node^.AbsoluteIndex - 1;
      Result := Result + DescriptionOfMsg(Index, FViewStore.Msgs[Index]) + #13#10#13#10;
    end;

    List.Free;
  end;
end;

procedure TCnMsgChild.RequireRefreshTime;
begin
  RefreshTime(FStore);
end;

function TCnMsgChild.GetSelectedItem: TCnMsgItem;
begin
  Result := nil;
  if FMsgTree.SelectedCount = 1 then
    if (FSelectedIndex >= 0) and (FSelectedIndex < FViewStore.MsgCount) then
      Result := FViewStore.Msgs[FSelectedIndex];
end;

end.

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

unit CnDataSetVisualizer;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ���� TDataSet ��������ĵ����ڲ鿴��
* ��Ԫ���ߣ�CnPack������
* ��    ע���ṹ�ο��� VCL ���Դ��ĸ��� Visualizer
* ����ƽ̨��PWin11 + Delphi 12
* ���ݲ��ԣ�
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2024.03.07 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Classes, Graphics, Controls, Forms, Messages, Dialogs, ComCtrls,
  StdCtrls, Grids, ExtCtrls, ToolsAPI, CnWizConsts, CnWizDebuggerNotifier;

type
  TCnDataSetViewerFrame = class(TFrame, IOTADebuggerVisualizerExternalViewerUpdater,
    IOTAThreadNotifier, IOTAThreadNotifier160)
    pcViews: TPageControl;
    tsProp: TTabSheet;
    mmoProp: TMemo;
    tsData: TTabSheet;
    Panel1: TPanel;
    Grid: TStringGrid;
    procedure pcViewsChange(Sender: TObject);
  private
    FOwningForm: TCustomForm;
    FClosedProc: TOTAVisualizerClosedProcedure;
    FExpression: string;
    FNotifierIndex: Integer;
    FCompleted: Boolean;
    FDeferredResult: string;
    FDeferredError: Boolean;
    FItems: TStrings;
    FAvailableState: TCnAvailableState;
    function Evaluate(Expression: string): string;
    procedure SetForm(AForm: TCustomForm);
    procedure AddDataSetContent(const Expression, TypeName, EvalResult: string);
    procedure SetAvailableState(const AState: TCnAvailableState);

    procedure WMDPIChangedAfterParent(var Message: TMessage); message WM_DPICHANGED_AFTERPARENT;
  protected
    procedure SetParent(AParent: TWinControl); override;
  public
    { IOTADebuggerVisualizerExternalViewerUpdater }
    procedure CloseVisualizer;
    procedure MarkUnavailable(Reason: TOTAVisualizerUnavailableReason);
    procedure RefreshVisualizer(const Expression, TypeName, EvalResult: string);
    procedure SetClosedCallback(ClosedProc: TOTAVisualizerClosedProcedure);
    { IOTAThreadNotifier }
    procedure AfterSave;
    procedure BeforeSave;
    procedure Destroyed;
    procedure Modified;
    procedure ThreadNotify(Reason: TOTANotifyReason);
    procedure EvaluateComplete(const ExprStr, ResultStr: string; CanModify: Boolean;
      ResultAddress, ResultSize: LongWord; ReturnCode: Integer); overload;
    procedure ModifyComplete(const ExprStr, ResultStr: string; ReturnCode: Integer);
    { IOTAThreadNotifier160 }
    procedure EvaluateComplete(const ExprStr, ResultStr: string; CanModify: Boolean;
      ResultAddress: TOTAAddress; ResultSize: LongWord; ReturnCode: Integer); overload;
  end;

  TCnDebuggerDataSetVisualizer = class(TInterfacedObject, IOTADebuggerVisualizer,
    IOTADebuggerVisualizer250, IOTADebuggerVisualizerExternalViewer)
  public
    { IOTADebuggerVisualizer }
    function GetSupportedTypeCount: Integer;
    procedure GetSupportedType(Index: Integer; var TypeName: string;
      var AllDescendants: Boolean); overload;
    function GetVisualizerIdentifier: string;
    function GetVisualizerName: string;
    function GetVisualizerDescription: string;
    { IOTADebuggerVisualizer250 }
    procedure GetSupportedType(Index: Integer; var TypeName: string;
      var AllDescendants: Boolean; var IsGeneric: Boolean); overload;
    { IOTADebuggerVisualizerExternalViewer }
    function GetMenuText: string;
    function Show(const Expression, TypeName, EvalResult: string;
      SuggestedLeft, SuggestedTop: Integer): IOTADebuggerVisualizerExternalViewerUpdater;
  end;

implementation

uses
  DesignIntf, Actnlist, ImgList, Menus, IniFiles, GraphUtil, BrandingAPI;

{$R *.dfm}

resourcestring
  sProcessNotAccessible = 'process not accessible';
  sValueNotAccessible = 'value not accessible';
  sOutOfScope = 'out of scope';

type
  IFrameFormHelper = interface
    ['{0FD4A98F-CE6B-422A-BF13-14E59707D3B2}']
    function GetForm: TCustomForm;
    function GetFrame: TCustomFrame;
    procedure SetForm(Form: TCustomForm);
    procedure SetFrame(Form: TCustomFrame);
  end;

  TCnDataSetVisualizerForm = class(TInterfacedObject, INTACustomDockableForm, IFrameFormHelper)
  private
    FMyFrame: TCnDataSetViewerFrame;
    FMyForm: TCustomForm;
    FExpression: string;
  public
    constructor Create(const Expression: string);
    { INTACustomDockableForm }
    function GetCaption: string;
    function GetFrameClass: TCustomFrameClass;
    procedure FrameCreated(AFrame: TCustomFrame);
    function GetIdentifier: string;
    function GetMenuActionList: TCustomActionList;
    function GetMenuImageList: TCustomImageList;
    procedure CustomizePopupMenu(PopupMenu: TPopupMenu);
    function GetToolbarActionList: TCustomActionList;
    function GetToolbarImageList: TCustomImageList;
    procedure CustomizeToolBar(ToolBar: TToolBar);
    procedure LoadWindowState(Desktop: TCustomIniFile; const Section: string);
    procedure SaveWindowState(Desktop: TCustomIniFile; const Section: string; IsProject: Boolean);
    function GetEditState: TEditState;
    function EditAction(Action: TEditAction): Boolean;
    { IFrameFormHelper }
    function GetForm: TCustomForm;
    function GetFrame: TCustomFrame;
    procedure SetForm(Form: TCustomForm);
    procedure SetFrame(Frame: TCustomFrame);
  end;

{ TCnDebuggerDataSetVisualizer }

function TCnDebuggerDataSetVisualizer.GetMenuText: string;
begin
  Result := SCnDebugDataSetViewerMenuText;
end;

function TCnDebuggerDataSetVisualizer.GetSupportedTypeCount: Integer;
begin
  Result := 1;
end;

procedure TCnDebuggerDataSetVisualizer.GetSupportedType(Index: Integer; var TypeName: string;
  var AllDescendants: Boolean);
begin
  TypeName := 'TDataSet';
  AllDescendants := True;
end;

procedure TCnDebuggerDataSetVisualizer.GetSupportedType(Index: Integer;
  var TypeName: string; var AllDescendants, IsGeneric: Boolean);
begin
  TypeName := 'TDataSet';
  AllDescendants := True;
  IsGeneric := False;
end;

function TCnDebuggerDataSetVisualizer.GetVisualizerDescription: string;
begin
  Result := SCnDebugDataSetViewerDescription;
end;

function TCnDebuggerDataSetVisualizer.GetVisualizerIdentifier: string;
begin
  Result := ClassName;
end;

function TCnDebuggerDataSetVisualizer.GetVisualizerName: string;
begin
  Result := SCnDebugDataSetViewerName;
end;

function TCnDebuggerDataSetVisualizer.Show(const Expression, TypeName, EvalResult: string;
  SuggestedLeft, SuggestedTop: Integer): IOTADebuggerVisualizerExternalViewerUpdater;
var
  AForm: TCustomForm;
  AFrame: TCnDataSetViewerFrame;
  VisDockForm: INTACustomDockableForm;
  LThemingServices: IOTAIDEThemingServices;
begin
  VisDockForm := TCnDataSetVisualizerForm.Create(Expression) as INTACustomDockableForm;
  AForm := (BorlandIDEServices as INTAServices).CreateDockableForm(VisDockForm);
  AForm.LockDrawing;
  try
    AForm.Left := SuggestedLeft;
    AForm.Top := SuggestedTop;
    (VisDockForm as IFrameFormHelper).SetForm(AForm);
    AFrame := (VisDockForm as IFrameFormHelper).GetFrame as TCnDataSetViewerFrame;
    AFrame.AddDataSetContent(Expression, TypeName, EvalResult);
    AFrame.pcViewsChange(nil);
    Result := AFrame as IOTADebuggerVisualizerExternalViewerUpdater;
    if Supports(BorlandIDEServices, IOTAIDEThemingServices, LThemingServices) and
      LThemingServices.IDEThemingEnabled then
    begin
      AFrame.Panel1.StyleElements := AFrame.Panel1.StyleElements - [seClient];
      AFrame.Panel1.ParentBackground := False;
      LThemingServices.ApplyTheme(AForm);
      AFrame.Panel1.Color := ColorBlendRGB(LThemingServices.StyleServices.GetSystemColor(clWindowText),
      LThemingServices.StyleServices.GetSystemColor(clWindow), 0.5);

      if TIDEThemeMetrics.Font.Enabled then
        AFrame.Font.Assign(TIDEThemeMetrics.Font.GetFont());
    end;
  finally
    AForm.UnlockDrawing;
  end;
end;

{ TCnDataSetViewerFrame }

procedure TCnDataSetViewerFrame.SetAvailableState(const AState: TCnAvailableState);
var
  S: string;
begin
  FAvailableState := AState;
  case FAvailableState of
    asAvailable:
      ;
    asProcRunning:
      S := sProcessNotAccessible;
    asOutOfScope:
      S := sOutOfScope;
    asNotAvailable:
      S := sValueNotAccessible;
  end;
end;

procedure TCnDataSetViewerFrame.AddDataSetContent(const Expression, TypeName,
  EvalResult: string);
var
  DebugSvcs: IOTADebuggerServices;
  CurProcess: IOTAProcess;
  CurThread: IOTAThread;
begin
  if Supports(BorlandIDEServices, IOTADebuggerServices, DebugSvcs) then
    CurProcess := DebugSvcs.CurrentProcess;
  if CurProcess = nil then
    Exit;
  CurThread := CurProcess.CurrentThread;
  if CurThread = nil then
    Exit;

  FExpression := Expression;
  SetAvailableState(asAvailable);
  mmoProp.Lines.Text := Evaluate(FExpression + '.Active');
end;

procedure TCnDataSetViewerFrame.AfterSave;
begin

end;

procedure TCnDataSetViewerFrame.BeforeSave;
begin

end;

procedure TCnDataSetViewerFrame.CloseVisualizer;
begin
  if FOwningForm <> nil then
    FOwningForm.Close;
end;

procedure TCnDataSetViewerFrame.Destroyed;
begin

end;

function TCnDataSetViewerFrame.Evaluate(Expression: string): string;
var
  CurProcess: IOTAProcess;
  CurThread: IOTAThread;
  ResultStr: array[0..4095] of Char;
  CanModify: Boolean;
  Done: Boolean;
  ResultAddr, ResultSize, ResultVal: LongWord;
  EvalRes: TOTAEvaluateResult;
  DebugSvcs: IOTADebuggerServices;
begin
//  Result := CnEvaluationManager.EvaluateExpression(Expression);

  Result := '';
  if Supports(BorlandIDEServices, IOTADebuggerServices, DebugSvcs) then
    CurProcess := DebugSvcs.CurrentProcess;
  if CurProcess <> nil then
  begin
    CurThread := CurProcess.CurrentThread;
    if CurThread <> nil then
    begin
      repeat
      begin
        Done := True;
        EvalRes := CurThread.Evaluate(Expression, @ResultStr, Length(ResultStr),
          CanModify, eseAll, '', ResultAddr, ResultSize, ResultVal, '', 0);
        case EvalRes of
          erOK: Result := ResultStr;
          erDeferred:
            begin
              FCompleted := False;
              FDeferredResult := '';
              FDeferredError := False;
              FNotifierIndex := CurThread.AddNotifier(Self);
              while not FCompleted do
                DebugSvcs.ProcessDebugEvents;
              CurThread.RemoveNotifier(FNotifierIndex);
              FNotifierIndex := -1;
              if not FDeferredError then
              begin
                if FDeferredResult <> '' then
                  Result := FDeferredResult
                else
                  Result := ResultStr;
              end;
            end;
          erBusy:
            begin
              DebugSvcs.ProcessDebugEvents;
              Done := False;
            end;
        end;
      end
      until Done = True;
    end;
  end;
end;

procedure TCnDataSetViewerFrame.EvaluateComplete(const ExprStr,
  ResultStr: string; CanModify: Boolean; ResultAddress, ResultSize: LongWord;
  ReturnCode: Integer);
begin
  EvaluateComplete(ExprStr, ResultStr, CanModify, TOTAAddress(ResultAddress), ResultSize, ReturnCode);
end;

procedure TCnDataSetViewerFrame.EvaluateComplete(const ExprStr,
  ResultStr: string; CanModify: Boolean; ResultAddress: TOTAAddress; ResultSize: LongWord;
  ReturnCode: Integer);
begin
  FCompleted := True;
  FDeferredResult := ResultStr;
  FDeferredError := ReturnCode <> 0;
end;

procedure TCnDataSetViewerFrame.MarkUnavailable(
  Reason: TOTAVisualizerUnavailableReason);
begin
  if Reason = ovurProcessRunning then
    SetAvailableState(asProcRunning)
  else if Reason = ovurOutOfScope then
    SetAvailableState(asOutOfScope);
end;

procedure TCnDataSetViewerFrame.Modified;
begin

end;

procedure TCnDataSetViewerFrame.ModifyComplete(const ExprStr,
  ResultStr: string; ReturnCode: Integer);
begin

end;

procedure TCnDataSetViewerFrame.RefreshVisualizer(const Expression, TypeName,
  EvalResult: string);
begin
  AddDataSetContent(Expression, TypeName, EvalResult);
end;

procedure TCnDataSetViewerFrame.SetClosedCallback(
  ClosedProc: TOTAVisualizerClosedProcedure);
begin
  FClosedProc := ClosedProc;
end;

procedure TCnDataSetViewerFrame.SetForm(AForm: TCustomForm);
begin
  FOwningForm := AForm;
end;

procedure TCnDataSetViewerFrame.SetParent(AParent: TWinControl);
begin
  if AParent = nil then
  begin
    FreeAndNil(FItems);
    if Assigned(FClosedProc) then
      FClosedProc;
  end;
  inherited;
end;

procedure TCnDataSetViewerFrame.WMDPIChangedAfterParent(var Message: TMessage);
begin
  inherited;
  if TIDEThemeMetrics.Font.Enabled then
    TIDEThemeMetrics.Font.AdjustDPISize(Font, TIDEThemeMetrics.Font.Size, PixelsPerInch);
end;

procedure TCnDataSetViewerFrame.pcViewsChange(Sender: TObject);
begin
  if pcViews.ActivePage = tsProp then
    mmoProp.SetFocus
  else if pcViews.ActivePage = tsData then
    Grid.SetFocus;
end;

procedure TCnDataSetViewerFrame.ThreadNotify(Reason: TOTANotifyReason);
begin

end;

{ TCnDataSetVisualizerForm }

constructor TCnDataSetVisualizerForm.Create(const Expression: string);
begin
  inherited Create;
  FExpression := Expression;
end;

procedure TCnDataSetVisualizerForm.CustomizePopupMenu(PopupMenu: TPopupMenu);
begin
  // no toolbar
end;

procedure TCnDataSetVisualizerForm.CustomizeToolBar(ToolBar: TToolBar);
begin
 // no toolbar
end;

function TCnDataSetVisualizerForm.EditAction(Action: TEditAction): Boolean;
begin
  Result := False;
end;

procedure TCnDataSetVisualizerForm.FrameCreated(AFrame: TCustomFrame);
begin
  FMyFrame := TCnDataSetViewerFrame(AFrame);
end;

function TCnDataSetVisualizerForm.GetCaption: string;
begin
  Result := Format(SCnDataSetViewerFormCaption, [FExpression]);
end;

function TCnDataSetVisualizerForm.GetEditState: TEditState;
begin
  Result := [];
end;

function TCnDataSetVisualizerForm.GetForm: TCustomForm;
begin
  Result := FMyForm;
end;

function TCnDataSetVisualizerForm.GetFrame: TCustomFrame;
begin
  Result := FMyFrame;
end;

function TCnDataSetVisualizerForm.GetFrameClass: TCustomFrameClass;
begin
  Result := TCnDataSetViewerFrame;
end;

function TCnDataSetVisualizerForm.GetIdentifier: string;
begin
  Result := 'DataSetDebugVisualizer';
end;

function TCnDataSetVisualizerForm.GetMenuActionList: TCustomActionList;
begin
  Result := nil;
end;

function TCnDataSetVisualizerForm.GetMenuImageList: TCustomImageList;
begin
  Result := nil;
end;

function TCnDataSetVisualizerForm.GetToolbarActionList: TCustomActionList;
begin
  Result := nil;
end;

function TCnDataSetVisualizerForm.GetToolbarImageList: TCustomImageList;
begin
  Result := nil;
end;

procedure TCnDataSetVisualizerForm.LoadWindowState(Desktop: TCustomIniFile;
  const Section: string);
begin
  //no desktop saving
end;

procedure TCnDataSetVisualizerForm.SaveWindowState(Desktop: TCustomIniFile;
  const Section: string; IsProject: Boolean);
begin
  //no desktop saving
end;

procedure TCnDataSetVisualizerForm.SetForm(Form: TCustomForm);
begin
  FMyForm := Form;
  if Assigned(FMyFrame) then
    FMyFrame.SetForm(FMyForm);
end;

procedure TCnDataSetVisualizerForm.SetFrame(Frame: TCustomFrame);
begin
   FMyFrame := TCnDataSetViewerFrame(Frame);
end;

end.


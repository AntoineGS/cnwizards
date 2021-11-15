{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2021 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ���������������������� CnPack �ķ���Э������        }
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

unit CnUsesIdentFrm;
{ |<PRE>
================================================================================
* �������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����õ�Ԫ���Ҵ���
* ��Ԫ���ߣ���Х (liuxiao@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin7 SP2 + Delphi 5.01
* ���ݲ��ԣ�PWin7 + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ���֧�ֱ��ػ�������ʽ
* �޸ļ�¼��2021.11.09 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNUSESTOOLS}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CnProjectViewBaseFrm, ActnList, ComCtrls, ToolWin, StdCtrls, ExtCtrls,
  Clipbrd, ToolsAPI, CnWizConsts, CnCommon, CnWizUtils, CnWizIdeUtils;

type
  TCnIdentUnitInfo = class(TCnBaseElementInfo)
  public
    FullNameWithPath: string; // ��·���������ļ���
  end;

  TCnUsesIdentForm = class(TCnProjectViewBaseForm)
    rbImpl: TRadioButton;
    rbIntf: TRadioButton;
    lblAddTo: TLabel;
    procedure lvListData(Sender: TObject; Item: TListItem);
    procedure edtMatchSearchKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure rbIntfDblClick(Sender: TObject);
    procedure edtMatchSearchChange(Sender: TObject);
    procedure actCopyExecute(Sender: TObject);
  private

  protected
    procedure UpdateStatusBar; override;
    procedure OpenSelect; override;
  public
    function GetDataList: TStringList;
  end;

var
  CnUsesIdentForm: TCnUsesIdentForm;

{$ENDIF CNWIZARDS_CNUSESTOOLS}

implementation

{$IFDEF CNWIZARDS_CNUSESTOOLS}

{$R *.DFM}

{ TCnUsesIdentForm }

function TCnUsesIdentForm.GetDataList: TStringList;
begin
  Result := DataList;
end;

procedure TCnUsesIdentForm.lvListData(Sender: TObject; Item: TListItem);
var
  Info: TCnIdentUnitInfo;
begin
  if (Item.Index >= 0) and (Item.Index < DisplayList.Count) then
  begin
    Info := TCnIdentUnitInfo(DisplayList.Objects[Item.Index]);
    Item.Caption := Info.Text;
    Item.ImageIndex := Info.ImageIndex;
    Item.Data := Info;

    with Item.SubItems do
    begin
      Add(_CnChangeFileExt(_CnExtractFileName(Info.FullNameWithPath), ''));
      Add(_CnExtractFileDir(Info.FullNameWithPath));
    end;
    RemoveListViewSubImages(Item);
  end;

end;

procedure TCnUsesIdentForm.edtMatchSearchKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  inherited;
  if Key = VK_RIGHT then
  begin
    if edtMatchSearch.SelStart = Length(edtMatchSearch.Text) then
    begin
      if rbIntf.Checked then
      begin
        rbIntf.Checked := False;
        rbImpl.Checked := True;
        rbImpl.SetFocus;
      end
      else
      begin
        rbIntf.Checked := True;
        rbImpl.Checked := False;
        rbIntf.SetFocus;
      end;
    end;
  end;
end;

procedure TCnUsesIdentForm.UpdateStatusBar;
begin
  StatusBar.Panels[1].Text := Format(SCnCountFmt, [lvList.Items.Count]);
end;

procedure TCnUsesIdentForm.OpenSelect;
var
  CharPos: TOTACharPos;
  IsIntfOrH: Boolean;
  IsFromSystem: Boolean;
  EditView: IOTAEditView;
  HasUses: Boolean;
  LinearPos: LongInt;
  Sl: TStrings;
  I: Integer;
begin
  if lvList.SelCount > 0 then
  begin
    ModalResult := mrOk;
    Sl := TStringList.Create;
    for I := 0 to lvList.Items.Count - 1 do
      if lvList.Items[I].Selected then
        Sl.Add(lvList.Items[I].SubItems[0]);

    IsIntfOrH := rbIntf.Checked;
    EditView := CnOtaGetTopMostEditView;
    if EditView = nil then
      Exit;

    // Pascal ֻ��Ҫʹ�õ�ǰ�ļ��� EditView ���� uses�����ô����� uses �����
    if not SearchUsesInsertPosInCurrentPas(IsIntfOrH, HasUses, CharPos) then
    begin
      ErrorDlg(SCnProjExtUsesNoPasPosition);
      Exit;
    end;

    // �Ѿ��õ��� 1 �� 0 ��ʼ�� CharPos���� EditView.CharPosToPos(CharPos) ת��Ϊ����;
    LinearPos := EditView.CharPosToPos(CharPos);
    CnOtaInsertTextIntoEditorAtPos(JoinUsesOrInclude(False, HasUses, False, Sl), LinearPos);
  end;
end;

procedure TCnUsesIdentForm.rbIntfDblClick(Sender: TObject);
begin
  OpenSelect;
end;

procedure TCnUsesIdentForm.edtMatchSearchChange(Sender: TObject);
var
  L: Integer;
begin
  L := Length(edtMatchSearch.Text);
  if L in [1..2] then
    Exit;

  inherited;
end;

procedure TCnUsesIdentForm.actCopyExecute(Sender: TObject);
begin
  // ���Ƶ�Ԫ��
  if lvList.Selected <> nil then
    if lvList.Selected.SubItems.Count > 0 then
      Clipboard.AsText := lvList.Selected.SubItems[0];
end;

{$ENDIF CNWIZARDS_CNUSESTOOLS}
end.
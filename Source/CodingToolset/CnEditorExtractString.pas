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

unit CnEditorExtractString;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ���Դ���г�ȡ�ַ�����Ԫ
* ��Ԫ���ߣ���Х (liuxiao@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7
* �� �� �����ô����е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2023.02.10 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

// {$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ToolsAPI,
  TypInfo, StdCtrls, ExtCtrls, ComCtrls, IniFiles,
  CnConsts, CnCommon, CnWizConsts, CnWizUtils, CnCodingToolsetWizard,
  CnEditControlWrapper, CnPasCodeParser, CnWidePasParser;

type
  TCnEditorExtractString = class(TCnBaseCodingToolset)
  private
    FUseUnderLine: Boolean;
    FIgnoreSingleChar: Boolean;
    FMaxWords: Integer;
    FMaxPinYinWords: Integer;
    FPrefix: string;
    FIdentWordStyle: TCnIdentWordStyle;
    FUseFullPinYin: Boolean;
    FShowPreview: Boolean;
    FIgnoreSimpleFormat: Boolean;
    function CanExtract(const S: PCnIdeTokenChar): Boolean;
  protected

  public
    constructor Create(AOwner: TCnCodingToolsetWizard); override;
    destructor Destroy; override;

    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
    procedure GetEditorInfo(var Name, Author, Email: string); override;

  published
    property IgnoreSingleChar: Boolean read FIgnoreSingleChar write FIgnoreSingleChar;
    {* ɨ��ʱ�Ƿ���Ե��ַ����ַ���}
    property IgnoreSimpleFormat: Boolean read FIgnoreSimpleFormat write FIgnoreSimpleFormat;
    {* ɨ��ʱ�Ƿ���Լ򵥵ĸ�ʽ���ַ���}

    property Prefix: string read FPrefix write FPrefix;
    {* ���ɵı�������ǰ׺����Ϊ�գ������Ƽ�}
    property UseUnderLine: Boolean read FUseUnderLine write FUseUnderLine;
    {* �������ķִ��Ƿ�ʹ���»�����Ϊ�ָ���}
    property IdentWordStyle: TCnIdentWordStyle read FIdentWordStyle write FIdentWordStyle;
    {* �������ķִʷ��ȫ��д����ȫСд��������ĸ��д���Сд}
    property UseFullPinYin: Boolean read FUseFullPinYin write FUseFullPinYin;
    {* ��������ʱ��ʹ��ȫƴ����ƴ������ĸ��True Ϊǰ��}
    property MaxPinYinWords: Integer read FMaxPinYinWords write FMaxPinYinWords;
    {* ����ƴ���ִʸ���}
    property MaxWords: Integer read FMaxWords write FMaxWords;
    {* ������ͨӢ�ķִʸ���}

    property ShowPreview: Boolean read FShowPreview write FShowPreview;
    {* �Ƿ���ʾԤ������}
  end;

  TCnExtractStringForm = class(TForm)
    grpScanOption: TGroupBox;
    chkIgnoreSingleChar: TCheckBox;
    chkIgnoreSimpleFormat: TCheckBox;
    grpPinYinOption: TGroupBox;
    lblPinYin: TLabel;
    cbbPinYinRule: TComboBox;
    btnReScan: TButton;
    pnl1: TPanel;
    lvStrings: TListView;
    mmoPreview: TMemo;
    spl1: TSplitter;
    cbbMakeType: TComboBox;
    lblMake: TLabel;
    lblToArea: TLabel;
    cbbToArea: TComboBox;
    btnHelp: TButton;
    btnReplace: TButton;
    btnClose: TButton;
    lblPrefix: TLabel;
    edtPrefix: TEdit;
    lblStyle: TLabel;
    cbbIdentWordStyle: TComboBox;
    lblMaxWords: TLabel;
    edtMaxWords: TEdit;
    udMaxWords: TUpDown;
    lblMaxPinYin: TLabel;
    edtMaxPinYin: TEdit;
    udMaxPinYin: TUpDown;
    chkUseUnderLine: TCheckBox;
    chkShowPreview: TCheckBox;
    procedure chkShowPreviewClick(Sender: TObject);
  private
    FTool: TCnEditorExtractString;
  public
    property Tool: TCnEditorExtractString read FTool write FTool;
  end;

implementation

{$R *.DFM}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  CnSourceStringPosKinds: TCodePosKinds = [pkField, pkProcedure, pkFunction,
    pkConstructor, pkDestructor, pkFieldDot];

  CN_DEF_MAX_WORDS = 7;

{ TCnEditorExtractString }

function TCnEditorExtractString.CanExtract(const S: PCnIdeTokenChar): Boolean;
var
  L: Integer;
begin
  Result := False;
  L := StrLen(S);
  if L <= 2 then // �����Ż�ȫ������
    Exit;

  if (L = 3) and (S[0] = '''') and (S[2] = '''') then // �����ַ�Ҳ����
    Exit;

  if (L = 4) and (S[0] = '''') and (S[1] = '''') and (S[2] = '''') and (S[2] = '''') then // ����������Ҳ����
    Exit;

  Result := True;
end;

constructor TCnEditorExtractString.Create(AOwner: TCnCodingToolsetWizard);
begin
  inherited;
  FIdentWordStyle := iwsUpperCase;
  FPrefix := 'S';
  FMaxWords := CN_DEF_MAX_WORDS;
  FMaxPinYinWords := CN_DEF_MAX_WORDS;
  FIgnoreSingleChar := True; 
end;

destructor TCnEditorExtractString.Destroy;
begin

  inherited;
end;

procedure TCnEditorExtractString.Execute;
var
  PasParser: TCnGeneralPasStructParser;
  Stream: TMemoryStream;
  I, CurrPos, LastTokenPos: Integer;
  EditView: IOTAEditView;
  Token, StartToken, EndToken, PrevToken: TCnGeneralPasToken;
  EditPos: TOTAEditPos;
  Info: TCodePosInfo;
  TokenList: TCnIdeStringList;
  S, NewCode: TCnIdeTokenString;
  EditWriter: IOTAEditWriter;
begin
  EditView := CnOtaGetTopMostEditView;
  if EditView = nil then
    Exit;

  with TCnExtractStringForm.Create(Application) do
  begin
    Tool := Self;

    edtPrefix.Text := FPrefix;
    cbbIdentWordStyle.ItemIndex := Ord(FIdentWordStyle);
    if FUseFullPinYin then
      cbbPinYinRule.ItemIndex := 1
    else
      cbbPinYinRule.ItemIndex := 0;
    udMaxWords.Position := FMaxWords;
    udMaxPinYin.Position := FMaxPinYinWords;
    chkUseUnderLine.Checked := FUseUnderLine;
    chkIgnoreSingleChar.Checked := FIgnoreSingleChar;
    chkIgnoreSimpleFormat.Checked := FIgnoreSimpleFormat;
    chkShowPreview.Checked := FShowPreview;

    if ShowModal = mrOK then
    begin
      Prefix := edtPrefix.Text;
      IdentWordStyle := TCnIdentWordStyle(cbbIdentWordStyle.ItemIndex);
      UseFullPinYin := cbbPinYinRule.ItemIndex = 1;

      MaxWords := udMaxWords.Position;
      MaxPinYinWords := udMaxPinYin.Position;
      UseUnderLine := chkUseUnderLine.Checked;
      IgnoreSingleChar := chkIgnoreSingleChar.Checked;
      IgnoreSimpleFormat := chkIgnoreSimpleFormat.Checked;
      ShowPreview := chkShowPreview.Checked;
    end;

    Free;
  end;

  PasParser := nil;
  Stream := nil;
  TokenList := nil;

  try
    PasParser := TCnGeneralPasStructParser.Create;
{$IFDEF BDS}
    PasParser.UseTabKey := True;
    PasParser.TabWidth := EditControlWrapper.GetTabWidth;
{$ENDIF}

    Stream := TMemoryStream.Create;
    CnGeneralSaveEditorToStream(EditView.Buffer, Stream);

{$IFDEF DEBUG}
    CnDebugger.LogMsg('CnEditorExtractString.Execute to ParseString.');
{$ENDIF}

    // ������ǰ��ʾ��Դ�ļ��е��ַ���
    CnPasParserParseString(PasParser, Stream);
    for I := 0 to PasParser.Count - 1 do
    begin
      Token := PasParser.Tokens[I];
      if CanExtract(Token.Token) then
      begin
        ConvertGeneralTokenPos(Pointer(EditView), Token);

{$IFDEF UNICODE}
        ParsePasCodePosInfoW(PChar(Stream.Memory), Token.EditLine, Token.EditCol, Info);
{$ELSE}
        EditPos.Line := Token.EditLine;
        EditPos.Col := Token.EditCol;
        CurrPos := CnOtaGetLinePosFromEditPos(EditPos);

        Info := ParsePasCodePosInfo(PChar(Stream.Memory), CurrPos);
{$ENDIF}
        Token.Tag := Ord(Info.PosKind);
      end
      else
        Token.Tag := Ord(pkUnknown);
    end;

{$IFDEF DEBUG}
    CnDebugger.LogInteger(PasParser.Count, 'PasParser.Count');
{$ENDIF}

    TokenList := TCnIdeStringList.Create;
    for I := 0 to PasParser.Count - 1 do
    begin
      Token := PasParser.Tokens[I];
      if TCodePosKind(Token.Tag) in CnSourceStringPosKinds then
      begin
        S := ConvertStringToIdent(string(Token.Token));
        // �� D2005~2007 ���� AnsiString �� WideString ��ת����Ҳ��Ӱ��

        TokenList.AddObject(S, Token);
      end;
    end;

    // TokensRefList �е� Token ��Ҫ��ȡ������
    if TokenList.Count <= 0 then
    begin
      ErrorDlg(SCnEditorExtractStringNotFound);
      Exit;
    end;

{$IFDEF DEBUG}
    CnDebugger.LogInteger(TokenList.Count, 'TokensRefList.Count');
{$ENDIF}

    for I := 0 to TokenList.Count - 1 do
    begin
      Token := TCnGeneralPasToken(TokenList.Objects[I]);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('#%3.3d. Line: %2.2d, Col %2.2d, Pos %4.4d. PosKind: %-18s, Token: %-14s, ConvertTo: %14s',
        [I, Token.LineNumber, Token.CharIndex, Token.TokenPos,
        GetEnumName(TypeInfo(TCodePosKind), Token.Tag), Token.Token, TokenList[I]]);
{$ENDIF}
    end;

    StartToken := TCnGeneralPasToken(TokenList.Objects[0]);
    EndToken := TCnGeneralPasToken(TokenList.Objects[TokenList.Count - 1]);
    PrevToken := nil;

    // ƴ���滻����ַ���
    for I := 0 to TokenList.Count - 1 do
    begin
      Token := TCnGeneralPasToken(TokenList.Objects[I]);
      if PrevToken = nil then
        NewCode := TokenList[I]
      else
      begin
        // ����һ Token ��β�ͣ������� Token ��ͷ���ټ��滻������֣��� Ansi/Wide/Wide String ������
        LastTokenPos := PrevToken.TokenPos + Length(PrevToken.Token);
        NewCode := NewCode + Copy(PasParser.Source, LastTokenPos + 1,
          Token.TokenPos - LastTokenPos) + TokenList[I];
      end;
      PrevToken := TCnGeneralPasToken(TokenList.Objects[I]);
    end;
    
    EditWriter := CnOtaGetEditWriterForSourceEditor;

{$IFDEF IDE_WIDECONTROL}
    // ����ʱ��Wide Ҫ�� Utf8 ת��
    EditWriter.CopyTo(Length(UTF8Encode(Copy(Parser.Source, 1, StartToken.TokenPos))));
    EditWriter.DeleteTo(Length(UTF8Encode(Copy(Parser.Source, 1, EndToken.TokenPos + Length(EndToken.Token)))));
  {$IFDEF UNICODE}
    EditWriter.Insert(PAnsiChar(ConvertTextToEditorTextW(NewCode)));
  {$ELSE}
    EditWriter.Insert(PAnsiChar(ConvertWTextToEditorText(NewCode)));
  {$ENDIF}
{$ELSE}
    EditWriter.CopyTo(StartToken.TokenPos);
    EditWriter.DeleteTo(EndToken.TokenPos + Length(EndToken.Token));
    EditWriter.Insert(PAnsiChar(ConvertTextToEditorText(AnsiString(NewCode))));
{$ENDIF}
    EditWriter := nil;

    RemoveDuplicatedStrings(TokenList); // ȥ��

    // �����������
    for I := 0 to TokenList.Count - 1 do
    begin
      Token := TCnGeneralPasToken(TokenList.Objects[I]);
      TokenList[I] := '  ' + TokenList[I] + ' = ' + Token.Token + ';';
    end;
    TokenList.Insert(0, 'const');

    // TODO: �ҵ� implementation �����ٴβ���
  finally
    TokenList.Free;
    Stream.Free;
    PasParser.Free;
  end;
end;

function TCnEditorExtractString.GetCaption: string;
begin
  Result := SCnEditorExtractStringMenuCaption;
end;

function TCnEditorExtractString.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

procedure TCnEditorExtractString.GetEditorInfo(var Name, Author,
  Email: string);
begin
  Name := SCnEditorExtractStringName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

function TCnEditorExtractString.GetHint: string;
begin
  Result := SCnEditorExtractStringMenuHint;
end;

procedure TCnExtractStringForm.chkShowPreviewClick(Sender: TObject);
begin
  mmoPreview.Visible := chkShowPreview.Checked;
  // spl1.Visible := chkShowPreview.Checked;
end;

initialization
  RegisterCnCodingToolset(TCnEditorExtractString); // ע�Ṥ��

end.

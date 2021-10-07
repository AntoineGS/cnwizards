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

unit CnWizShareImages;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����� ImageList ��Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע���õ�Ԫ������ CnPack IDE ר�Ұ�����Ĺ����� ImageList 
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2021.09.15 V1.1
*               ֧�� HDPI �ɱ�ֱ������
*           2003.04.18 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Windows, Classes, Graphics, Forms, ImgList, Buttons, Controls,
  {$IFDEF IDE_SUPPORT_HDPI} Vcl.VirtualImageList, Vcl.ImageCollection, {$ENDIF}
  {$IFDEF SUPPORT_GDIPLUS} WinApi.GDIPOBJ, WinApi.GDIPAPI, {$ENDIF}
  {$IFNDEF STAND_ALONE} CnWizUtils, CnWizOptions, CnWizIdeUtils, {$ENDIF}
  CnGraphUtils;

type
  TdmCnSharedImages = class(TDataModule)
    Images: TImageList;
    DisabledImages: TImageList;
    SymbolImages: TImageList;
    ilBackForward: TImageList;
    ilInputHelper: TImageList;
    ilProcToolBar: TImageList;
    ilBackForwardBDS: TImageList;
    ilProcToolbarLarge: TImageList;
    ilColumnHeader: TImageList;
    LargeImages: TImageList;
    DisabledLargeImages: TImageList;
    IDELargeImages: TImageList;
    procedure DataModuleCreate(Sender: TObject);
  private
    FIdxUnknownInIDE: Integer;
    FIdxUnknown: Integer;
{$IFDEF IDE_SUPPORT_HDPI}
    FIdxUnknownLargeInIDE: Integer;
    FLargeVirtualImages: TVirtualImageList;   // ��Ӧ Images
    FLargeImageCollection: TImageCollection;
    FDisabledLargeVirtualImages: TVirtualImageList;   // ��Ӧ DisabledImages
    FDisabledLargeImageCollection: TImageCollection;
    FIDELargeVirtualImages: TVirtualImageList;   // ��Ӧ IDELargeImages �� IDELargeDisabledImages
    FIDELargeImageCollection: TImageCollection;
    FLargeIDEOffset: Integer; // D110A ֮���ͼ��ƫ��ֵ��ͬ
    FLargeProcToolbarVirtualImages: TVirtualImageList; // ��Ӧ ilProcToolbarLarge
    FLargeProcToolbarImageCollection: TImageCollection;
{$ENDIF}
{$IFNDEF STAND_ALONE}
    FIDEOffset: Integer;      // D110A ֮ǰ�������Ƿ��ͼ�궼�����ֵ
    FCopied: Boolean;       // ��¼���ǵ� ImageList �������� IDE �� ImageList ��
    FLargeCopied: Boolean;  // ��¼ IDE �� ImageList ���޸���һ�ݴ��
    FLargeCopiedCount: Integer; // ��¼ IDE �� ImageList ����һ�ݴ������
{$ENDIF}
    function GetIdxUnknownInIDE: Integer;
  public
    property IdxUnknown: Integer read FIdxUnknown;
    property IdxUnknownInIDE: Integer read GetIdxUnknownInIDE;
{$IFNDEF STAND_ALONE}
    procedure GetSpeedButtonGlyph(Button: TSpeedButton; ImageList: TImageList; 
      EmptyIdx: Integer);
    procedure CenterCopyTo(SrcImageList, DstImageList: TCustomImageList);
    {* ����С�ߴ� ImageList ԭ�ߴ���л��Ƶ���� ImageList ��}
    procedure StretchCopyToLarge(SrcImageList, DstImageList: TCustomImageList);
    {* ���ⶼʹ�ã�����С�ߴ� ImageList ������Ƶ���� ImageList ��}
    procedure CopyToIDEMainImageList;
    // Images �ᱻ���ƽ� IDE �� ImageList ��ͼ�걻ͬʱʹ�õĳ��ϣ�FIDEOffset ��ʾƫ����
    procedure CopyLargeIDEImageList(Force: Boolean = False);
    // ��ר��ȫ�����������ز˵������ã��� IDE �� ImageList �ٸ���һ�ݴ��
    // ע������ᱻ�����ظ������Σ�һ�ο�ǰ�Գ�ʼ��ר�ҹ�������أ�һ�� IDE ��������Է�ӳ����ͼ��
    // Force Ϊ True ʱ��ʾ�� FLargeCopied Ϊ True ʱ�ж��������������ٽ���һ�θ���

    function GetMixedImageList(ForceSmall: Boolean = False): TCustomImageList;
    function CalcMixedImageIndex(ImageIndex: Integer): Integer;

{$IFDEF IDE_SUPPORT_HDPI}
    property LargeVirtualImages: TVirtualImageList read FLargeVirtualImages;
    {* ��ߴ��µ� D110A �����ϣ���ͨ�����������}
    property DisabledLargeVirtualImages: TVirtualImageList read FDisabledLargeVirtualImages;
    {* ��ߴ��µ� D110A �����ϣ���ͨ����������״̬�����}
    property IDELargeVirtualImages: TVirtualImageList read FIDELargeVirtualImages;
    {* ��ߴ��µ� D110A �����ϣ��༭������������Ҫ IDE �������}
    property LargeProcToolbarVirtualImages: TVirtualImageList read FLargeProcToolbarVirtualImages;
    {* ��ߴ��µ� D110A �����ϣ������б�������Ҫ�����}
{$ENDIF}
{$ENDIF}
  end;

var
  dmCnSharedImages: TdmCnSharedImages;

implementation

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

{$R *.dfm}

const
  MaskColor = clBtnFace;

procedure TdmCnSharedImages.StretchCopyToLarge(SrcImageList,
  DstImageList: TCustomImageList);
var
  Src, Dst: TBitmap;
  Rs, Rd: TRect;
  I: Integer;
begin
  // ��С�� ImageList ���������ƣ��� 16*16 ��չ�� 24* 24
  Src := nil;
  Dst := nil;

{$IFNDEF SUPPORT_GDIPLUS}
  CnStartUpGdiPlus;
{$ENDIF}

  try
    Src := CreateEmptyBmp24(16, 16, MaskColor);
    Dst := CreateEmptyBmp24(24, 24, MaskColor);

    Rs := Rect(0, 0, Src.Width, Src.Height);
    Rd := Rect(0, 0, Dst.Width, Dst.Height);

    Src.Canvas.Brush.Color := MaskColor;
    Src.Canvas.Brush.Style := bsSolid;
    Dst.Canvas.Brush.Color := clFuchsia;
    Dst.Canvas.Brush.Style := bsSolid;

    for I := 0 to SrcImageList.Count - 1 do
    begin
      Src.Canvas.FillRect(Rs);
      SrcImageList.GetBitmap(I, Src);

      StretchDrawBmp(Src, Dst);
      DstImageList.AddMasked(Dst, MaskColor);
    end;
  finally
{$IFNDEF SUPPORT_GDIPLUS}
    CnShutDownGdiPlus;
{$ENDIF}
    Src.Free;
    Dst.Free;
  end;
end;

procedure TdmCnSharedImages.CenterCopyTo(SrcImageList,
  DstImageList: TCustomImageList);
var
  Src, Dst: TBitmap;
  Rs, Rd: TRect;
  I: Integer;
begin
  // ��С�� ImageList ���������ƣ���Сͼ���л������
  Src := nil;
  Dst := nil;
  try
    Src := TBitmap.Create;
    Src.Width := SrcImageList.Width;
    Src.Height := SrcImageList.Height;
    Src.PixelFormat := pf24bit;

    Dst := TBitmap.Create;
    Dst.Width := DstImageList.Width;
    Dst.Height := DstImageList.Height;
    Dst.PixelFormat := pf24bit;

    Rs := Rect(0, 0, Src.Width, Src.Height);
    Rd := Rect(0, 0, Dst.Width, Dst.Height);

    Src.Canvas.Brush.Color := MaskColor;
    Src.Canvas.Brush.Style := bsSolid;
    Dst.Canvas.Brush.Color := clFuchsia;
    Dst.Canvas.Brush.Style := bsSolid;

    for I := 0 to SrcImageList.Count - 1 do
    begin
      Src.Canvas.FillRect(Rs);
      SrcImageList.GetBitmap(I, Src);
      Dst.Canvas.FillRect(Rd);
      Dst.Canvas.Draw((Dst.Width - Src.Width) div 2, (Dst.Height - Src.Height) div 2, Src);
      DstImageList.AddMasked(Dst, MaskColor);
    end;
  finally
    Src.Free;
    Dst.Free;
  end;
end;

procedure TdmCnSharedImages.DataModuleCreate(Sender: TObject);
{$IFNDEF STAND_ALONE}
var
  ImgLst: TCustomImageList;
{$IFDEF IDE_SUPPORT_HDPI}
  Ico: TIcon;
{$ELSE}
  Bmp: TBitmap;
{$ENDIF}
  Save: TColor;
{$ENDIF}
begin
{$IFNDEF STAND_ALONE}
  FIdxUnknown := 66;
  ImgLst := GetIDEImageList;

{$IFDEF IDE_SUPPORT_HDPI}
  Ico := TIcon.Create;
  try
    Images.GetIcon(IdxUnknown, Ico);
    FIdxUnknownInIDE := AddGraphicToVirtualImageList(Ico,
      ImgLst as TVirtualImageList, 'CnWizardsUnknown');
  finally
    Ico.Free;
  end;
{$ELSE}
  Bmp := TBitmap.Create;        // �� IDE ���� List �Ӹ� Unknown ��ͼ��
  try
    Bmp.PixelFormat := pf24bit;
    Save := Images.BkColor;
    Images.BkColor := clFuchsia;
    Images.GetBitmap(IdxUnknown, Bmp);
    FIdxUnknownInIDE := ImgLst.AddMasked(Bmp, clFuchsia);
    Images.BkColor := Save;
  finally
    Bmp.Free;
  end;
{$ENDIF}

  if WizOptions.UseLargeIcon then
  begin
    // Ϊ��ͼ�������׼��
{$IFDEF IDE_SUPPORT_HDPI}
    FLargeVirtualImages := TVirtualImageList.Create(Self);
    FLargeImageCollection := TImageCollection.Create(Self);
    FLargeVirtualImages.ImageCollection := FLargeImageCollection;
    FLargeVirtualImages.Width := csLargeImageListWidth;
    FLargeVirtualImages.Height := csLargeImageListHeight;

    FDisabledLargeVirtualImages := TVirtualImageList.Create(Self);
    FDisabledLargeImageCollection := TImageCollection.Create(Self);
    FDisabledLargeVirtualImages.ImageCollection := FDisabledLargeImageCollection;
    FDisabledLargeVirtualImages.Width := csLargeImageListWidth;
    FDisabledLargeVirtualImages.Height := csLargeImageListHeight;

    FIDELargeVirtualImages := TVirtualImageList.Create(Self);
    FIDELargeImageCollection := TImageCollection.Create(Self);
    FIDELargeVirtualImages.ImageCollection := FIDELargeImageCollection;
    FIDELargeVirtualImages.Width := csLargeImageListWidth;
    FIDELargeVirtualImages.Height := csLargeImageListHeight;

    FLargeProcToolbarVirtualImages := TVirtualImageList.Create(Self);
    FLargeProcToolbarImageCollection := TImageCollection.Create(Self);
    FLargeProcToolbarVirtualImages.ImageCollection := FLargeProcToolbarImageCollection;
    FLargeProcToolbarVirtualImages.Width := csLargeImageListWidth;
    FLargeProcToolbarVirtualImages.Height := csLargeImageListHeight;

    CopyImageListToVirtual(Images, FLargeVirtualImages);
    CopyImageListToVirtual(DisabledImages, FDisabledLargeVirtualImages);
    CopyImageListToVirtual(ilProcToolbar, FLargeProcToolbarVirtualImages);
{$ELSE}
    StretchCopyToLarge(ilProcToolbar, ilProcToolbarLarge);
    StretchCopyToLarge(Images, LargeImages);
    StretchCopyToLarge(DisabledImages, DisabledLargeImages);
{$ENDIF}
  end;
{$ENDIF}
end;

{$IFNDEF STAND_ALONE}

function TdmCnSharedImages.CalcMixedImageIndex(
  ImageIndex: Integer): Integer;
begin
  if FCopied and (ImageIndex >= 0) then
  begin
    Result := ImageIndex + FIDEOffset;
{$IFDEF IDE_SUPPORT_HDPI}
    if WizOptions.UseLargeIcon then
      Result := ImageIndex + FLargeIDEOffset;
{$ENDIF}
  end
  else
    Result := ImageIndex;
end;

function TdmCnSharedImages.GetMixedImageList(ForceSmall: Boolean): TCustomImageList;
begin
  if FCopied then
  begin
    if WizOptions.UseLargeIcon and not ForceSmall and FLargeCopied then
    begin
{$IFDEF IDE_SUPPORT_HDPI}
      Result := FIDELargeVirtualImages;
{$ELSE}
      Result := IDELargeImages;
{$ENDIF}
    end
    else
      Result := GetIDEImageList;
  end
  else
    Result := Images;
end;

procedure TdmCnSharedImages.CopyToIDEMainImageList;
var
  IDEs: TCustomImageList;
  Cnt: Integer;
begin
  if FCopied then
    Exit;

  IDEs := GetIDEImageList;
  if IDEs <> nil then
  begin
    Cnt := IDEs.Count;
{$IFDEF IDE_SUPPORT_HDPI}
    if WizOptions.UseLargeIcon then
    begin
      // D11 �����Ժ�IDE ���� ImageList �� VirtualImageList �ˣ��������ڷֱ��ʱ仯��FLargeOffset ������
      CopyVirtualImageList(IDEs as TVirtualImageList, FIDELargeVirtualImages);
      FLargeIDEOffset := FIDELargeVirtualImages.Count;
      FIDELargeVirtualImages.Clear;   // ���ֻ������ FIDELargeOffset
    end;
    CopyImageListToVirtual(Images, IDEs as TVirtualImageList, 'CnWizardsItem');
{$IFDEF DEBUG}
    CnDebugger.LogFmt('Add %d Images to IDE Main VirtualImageList. Offset %d. LargeOffset %d', [Images.Count, Cnt, FLargeIDEOffset]);
{$ENDIF}
{$ELSE}
    if (IDEs.Width = Images.Width) and (IDEs.Height = Images.Height) then
    begin
      IDEs.AddImages(Images);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('Add %d Images to IDE Main 16x16 ImageList. Offset %d.', [Images.Count, Cnt]);
{$ENDIF}
    end;
{$ENDIF}

    FIDEOffset := Cnt;
    FCopied := True;
  end;
end;

procedure TdmCnSharedImages.GetSpeedButtonGlyph(Button: TSpeedButton;
  ImageList: TImageList; EmptyIdx: Integer);
var
  Save: TColor;
begin
  Button.Glyph.TransparentMode := tmFixed; // ǿ��͸��
  Button.Glyph.TransparentColor := clFuchsia;
  if Button.Glyph.Empty then
  begin
    Save := dmCnSharedImages.Images.BkColor;
    ImageList.BkColor := clFuchsia;
    ImageList.GetBitmap(EmptyIdx, Button.Glyph);
    ImageList.BkColor := Save;
  end;

  // ������ťλͼ�Խ����Щ��ť Disabled ʱ��ͼ�������
  AdjustButtonGlyph(Button.Glyph);
  Button.NumGlyphs := 2;
end;

procedure TdmCnSharedImages.CopyLargeIDEImageList(Force: Boolean);
var
  IDEs: TCustomImageList;
{$IFDEF IDE_SUPPORT_HDPI}
  Ico: TIcon;
{$ENDIF}
begin
  if not WizOptions.UseLargeIcon then
    Exit;

  if FLargeCopied and not Force then // �Ѿ������ˣ��� Force ʱ���˳�
    Exit;

  IDEs := GetIDEImageList;
  if IDEs = nil then
    Exit;

  // �� Force ʱ�ж� IDE �� ImageList �������Ƿ���ȣ�����򲻸���
  if Force and (FLargeCopiedCount = IDEs.Count) then
    Exit;

  // ������ IDE �� ImageList ����һ�������͵Ĺ���ߴ���ʹ��
{$IFDEF IDE_SUPPORT_HDPI}
  FIDELargeVirtualImages.Clear;
  CopyVirtualImageList(IDEs as TVirtualImageList, FIDELargeVirtualImages);
{$IFDEF DEBUG}
  CnDebugger.LogFmt('Copy IDE ImageList %d to a Large Virtual ImageList %d',
    [IDEs.Count, FIDELargeVirtualImages.Count]);
{$ENDIF}

  Ico := TIcon.Create;
  try
    Images.GetIcon(IdxUnknown, Ico);
    FIdxUnknownLargeInIDE := AddGraphicToVirtualImageList(Ico,
      FIDELargeVirtualImages, 'CnWizardsLargeUnknown');
{$IFDEF DEBUG}
    CnDebugger.LogFmt('Add an Unknown Icon to IDE Large Index %d',
      [FIdxUnknownLargeInIDE]);
{$ENDIF}
  finally
    Ico.Free;
  end;
{$ENDIF}

  IDELargeImages.Clear;
  StretchCopyToLarge(IDEs, IDELargeImages);
{$IFDEF DEBUG}
  CnDebugger.LogFmt('Copy IDE ImageList %d to a Large ImageList %d',
    [IDEs.Count, IDELargeImages.Count]);
{$ENDIF}
  FLargeCopiedCount := IDEs.Count;
  FLargeCopied := True;
end;

function TdmCnSharedImages.GetIdxUnknownInIDE: Integer;
begin
  Result := FIdxUnknownInIDE;
{$IFDEF IDE_SUPPORT_HDPI}
  if WizOptions.UseLargeIcon then
    Result := FIdxUnknownLargeInIDE;
{$ENDIF}
end;

{$ENDIF}
end.

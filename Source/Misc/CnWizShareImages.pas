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
* �޸ļ�¼��2003.04.18 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Windows, Classes, Graphics, Forms, ImgList, Buttons, Controls,
  {$IFNDEF STAND_ALONE} CnWizUtils,  CnWizOptions, CnWizIdeUtils, {$ENDIF}
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
{$IFNDEF STAND_ALONE}
    FIDEOffset: Integer;
    FCopied: Boolean;
{$ENDIF}
    procedure CopyToLarge(SrcImageList, DstImageList: TCustomImageList);
  public
    property IdxUnknown: Integer read FIdxUnknown;
    property IdxUnknownInIDE: Integer read FIdxUnknownInIDE;
{$IFNDEF STAND_ALONE}
    procedure GetSpeedButtonGlyph(Button: TSpeedButton; ImageList: TImageList; 
      EmptyIdx: Integer);

    procedure CopyToIDEMainImageList;
    // Images �ᱻ���ƽ� IDE �� ImageList ��ͼ�걻ͬʱʹ�õĳ��ϣ�FIDEOffset ��ʾƫ����

    function GetMixedImageList(ForceSmall: Boolean = False): TCustomImageList;
    function CalcMixedImageIndex(ImageIndex: Integer): Integer;
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

procedure TdmCnSharedImages.CopyToLarge(SrcImageList,
  DstImageList: TCustomImageList);
const
  MaskColor = clBtnFace;
var
  Src, Dst: TBitmap;
  Rs, Rd: TRect;
  I: Integer;
begin
  // ��С�� ImageList ���������ƣ��� 16*16 ��չ�� 24* 24
  Src := nil;
  Dst := nil;
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
      Dst.Canvas.FillRect(Rd);
      Dst.Canvas.StretchDraw(Rd, Src);
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
  Bmp: TBitmap;
  Save: TColor;
{$ENDIF}
begin
{$IFNDEF STAND_ALONE}
  FIdxUnknown := 66;
  ImgLst := GetIDEImageList;
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

  if WizOptions.UseLargeIcon then
  begin
    CopyToLarge(ilProcToolbar, ilProcToolbarLarge);
    CopyToLarge(Images, LargeImages);
    CopyToLarge(DisabledImages, DisabledLargeImages);
  end;
{$ENDIF}
end;

{$IFNDEF STAND_ALONE}

function TdmCnSharedImages.CalcMixedImageIndex(
  ImageIndex: Integer): Integer;
begin
  if FCopied and (ImageIndex >= 0) then
    Result := ImageIndex + FIDEOffset
  else
    Result := ImageIndex;
end;

function TdmCnSharedImages.GetMixedImageList(ForceSmall: Boolean): TCustomImageList;
begin
  if FCopied then
  begin
    if WizOptions.UseLargeIcon and not ForceSmall then
      Result := IDELargeImages
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
  if (IDEs <> nil) and (IDEs.Width = Images.Width) and (IDEs.Height = Images.Height) then
  begin
    Cnt := IDEs.Count;
    IDEs.AddImages(Images);
    FIDEOffset := Cnt;
    FCopied := True;
{$IFDEF DEBUG}
    CnDebugger.LogFmt('Add %d Images to IDE Main ImageList. Offset %d.', [Images.Count, FIDEOffset]);
{$ENDIF}

    if WizOptions.UseLargeIcon then
    begin
      // ��ߴ��£��ٰ� IDE �� ImageList ����һ�������͵�
      CopyToLarge(IDEs, IDELargeImages);
    end;
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

{$ENDIF}
end.

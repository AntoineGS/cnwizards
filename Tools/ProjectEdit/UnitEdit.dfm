object FormProjectEdit: TFormProjectEdit
  Left = 286
  Top = 138
  BorderStyle = bsDialog
  Caption = '�������� CnPack IDE ר�Ұ������ļ�'
  ClientHeight = 536
  ClientWidth = 832
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = '����'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 12
  object lblRoot: TLabel
    Left = 16
    Top = 16
    Width = 120
    Height = 12
    Caption = 'ר�Ұ������ļ�Ŀ¼��'
  end
  object bvl1: TBevel
    Left = 16
    Top = 48
    Width = 801
    Height = 17
    Shape = bsTopLine
  end
  object lblDpr: TLabel
    Left = 16
    Top = 72
    Width = 90
    Height = 12
    Caption = '������dpr�ļ���'
  end
  object lblDprAdd: TLabel
    Left = 744
    Top = 72
    Width = 48
    Height = 12
    Caption = '��������'
  end
  object bvl2: TBevel
    Left = 16
    Top = 128
    Width = 801
    Height = 17
    Shape = bsTopLine
  end
  object lblDproj: TLabel
    Left = 16
    Top = 148
    Width = 126
    Height = 12
    Caption = '������bds/dproj�ļ���'
  end
  object lblDprojAdd: TLabel
    Left = 744
    Top = 148
    Width = 48
    Height = 12
    Caption = '��������'
  end
  object bvl3: TBevel
    Left = 16
    Top = 296
    Width = 801
    Height = 17
    Shape = bsTopLine
  end
  object edtRootDir: TEdit
    Left = 144
    Top = 12
    Width = 577
    Height = 20
    TabOrder = 0
  end
  object btnBrowse: TButton
    Left = 744
    Top = 12
    Width = 75
    Height = 22
    Caption = 'ѡ��Ŀ¼'
    TabOrder = 1
    OnClick = btnBrowseClick
  end
  object edtDprBefore: TEdit
    Left = 144
    Top = 68
    Width = 577
    Height = 20
    TabOrder = 2
    Text = 'CnWizDfmParser in '#39'Utils\CnWizDfmParser.pas'#39','
  end
  object edtDprAdd: TEdit
    Left = 144
    Top = 92
    Width = 577
    Height = 20
    TabOrder = 3
    Text = 'CnVclToFmxIntf in '#39'VclToFmx\CnVclToFmxIntf.pas'#39','
  end
  object btnDprAdd: TButton
    Left = 744
    Top = 92
    Width = 75
    Height = 22
    Caption = '����'
    TabOrder = 4
    OnClick = btnDprAddClick
  end
  object btnDprojAdd: TButton
    Left = 744
    Top = 172
    Width = 75
    Height = 22
    Caption = '����'
    TabOrder = 5
    OnClick = btnDprojAddClick
  end
  object mmoDprojAdd: TMemo
    Left = 144
    Top = 208
    Width = 577
    Height = 65
    Lines.Strings = (
      '<DCCReference Include="VclToFmx\CnVclToFmxIntf.pas"/>')
    TabOrder = 6
  end
  object mmoDprojBefore: TMemo
    Left = 144
    Top = 144
    Width = 577
    Height = 57
    Lines.Strings = (
      '<DCCReference Include="Utils\CnWizDfmParser.pas"/>')
    TabOrder = 7
  end
end

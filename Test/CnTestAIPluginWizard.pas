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

unit CnTestAIPluginWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ�CnTestAIPluginWizard
* ��Ԫ���ߣ�CnPack ������
* ��    ע��
* ����ƽ̨��Windows 7 + Delphi 5
* ���ݲ��ԣ�XP/7 + Delphi 5/6/7
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2024.09.21 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  {$IFDEF OTA_HAS_AISERVICE} ToolsAPI.AI, {$ENDIF}
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts;

type

//==============================================================================
// CnTestAIPluginWizard �˵�ר��
//==============================================================================

{ TCnTestAIPluginWizard }

  TCnTestAIPluginWizard = class(TCnMenuWizard)
  private

  protected
    function GetHasConfig: Boolean; override;
  public
    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

implementation

//==============================================================================
// CnTestAIPluginWizard �˵�ר��
//==============================================================================

{ TCnTestAIPluginWizard }

procedure TCnTestAIPluginWizard.Config;
begin
  ShowMessage('No Option for this Test Case.');
end;

procedure TCnTestAIPluginWizard.Execute;
{$IFDEF OTA_HAS_AISERVICE}
var
  I: Integer;
  SL: TStringList;
{$ENDIF}
begin
{$IFDEF OTA_HAS_AISERVICE}
  ShowMessage('AIEngineService PluginCount: ' + IntToStr(AIEngineService.PluginCount));
  SL := TStringList.Create;
  try
    for I := 0 to AIEngineService.PluginCount - 1 do
      SL.Add(AIEngineService.GetPluginByIndex(I).Name);

    ShowMessage(SL.Text);
  finally
    SL.Free;
  end;
{$ENDIF}
end;

function TCnTestAIPluginWizard.GetCaption: string;
begin
  Result := 'Test AIPlugin';
end;

function TCnTestAIPluginWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestAIPluginWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestAIPluginWizard.GetHint: string;
begin
  Result := 'Test Hint';
end;

function TCnTestAIPluginWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestAIPluginWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test AIPlugin Menu Wizard';
  Author := 'CnPack IDE Wizards';
  Email := 'master@cnpack.org';
  Comment := '';
end;

procedure TCnTestAIPluginWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestAIPluginWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestAIPluginWizard); // ע��˲���ר��

end.

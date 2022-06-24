{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2022 CnPack ������                       }
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

unit CnTestDebuggerVisualizerWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ����� DebuggerVisualizer �Ĳ���������Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע������ DebuggerVisualizer �Ը��ĵ���������ʾ����
            ���ڴ���λ�����������֣���Ҫ�� D5/2007/2009 �Ȳ���ͨ����
* ����ƽ̨��Win7 + Delphi XE2
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi All
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2022.06.24 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnCommon, CnWizClasses, CnWizUtils, CnWizConsts;

type

//==============================================================================
// ���� DebuggerVisualizer �Ĳ˵�ר��
//==============================================================================

{ TCnTestDebuggerVisualizerWizard }

  TCnTestDebuggerVisualizerWizard = class(TCnMenuWizard)
  private
    FRegistered: Boolean;
    FVisualizer: IOTADebuggerVisualizerValueReplacer;
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

  TCnTestDebuggerVisualizerValueReplacer = class(TInterfacedObject, IOTADebuggerVisualizerValueReplacer)
  public
    function GetSupportedTypeCount: Integer;
    procedure GetSupportedType(Index: Integer; var TypeName: string;
      var AllDescendants: Boolean);
    function GetVisualizerIdentifier: string;
    function GetVisualizerName: string;
    function GetVisualizerDescription: string;

    function GetReplacementValue(const Expression, TypeName, EvalResult: string): string;
  end;

implementation

uses
  CnDebug;

//==============================================================================
// ���� DebuggerVisualizer �Ĳ˵�ר��
//==============================================================================

{ TCnTestDebuggerVisualizerWizard }

procedure TCnTestDebuggerVisualizerWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

procedure TCnTestDebuggerVisualizerWizard.Execute;
var
  ID: IOTADebuggerServices;
begin
  if not Supports(BorlandIDEServices, IOTADebuggerServices, ID) then
    Exit;

  if FVisualizer = nil then
    FVisualizer := TCnTestDebuggerVisualizerValueReplacer.Create;

  if not FRegistered then
  begin
    ID.RegisterDebugVisualizer(FVisualizer);
    FRegistered := True;
    ShowMessage('Debugger Visualizer Registered');
  end
  else
  begin
    ID.UnregisterDebugVisualizer(FVisualizer);
    FRegistered := False;
    ShowMessage('Debugger Visualizer UnRegistered');
  end;
end;

function TCnTestDebuggerVisualizerWizard.GetCaption: string;
begin
  Result := 'Test DebuggerVisualizer';
end;

function TCnTestDebuggerVisualizerWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestDebuggerVisualizerWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestDebuggerVisualizerWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestDebuggerVisualizerWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestDebuggerVisualizerWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test DebuggerVisualizer Menu Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for DebuggerVisualizer under Delphi XE or above';
end;

procedure TCnTestDebuggerVisualizerWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestDebuggerVisualizerWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

{ TCnTestDebuggerVisualizerValueReplacer }

function TCnTestDebuggerVisualizerValueReplacer.GetReplacementValue(
  const Expression, TypeName, EvalResult: string): string;
begin
  CnDebugger.LogFmt('DebuggerVisualizerValueReplacer get %s: %s, Display %s',
    [Expression, TypeName, EvalResult]);
  Result := EvalResult + ' - From CnPack';
end;

procedure TCnTestDebuggerVisualizerValueReplacer.GetSupportedType(
  Index: Integer; var TypeName: string; var AllDescendants: Boolean);
begin
  AllDescendants := False;
  case Index of
    0: TypeName := 'TCnBigNumber';
    1: TypeName := 'TCnBigNumberPolynomial';
    2: TypeName := 'TCnEccPoint';
    3: TypeName := 'TCnEcc3Point';
  end;
end;

function TCnTestDebuggerVisualizerValueReplacer.GetSupportedTypeCount: Integer;
begin
  Result := 4;
end;

function TCnTestDebuggerVisualizerValueReplacer.GetVisualizerDescription: string;
begin
  Result := 'CnPack CnVcl Debugger Visualizer for some Classes.'
end;

function TCnTestDebuggerVisualizerValueReplacer.GetVisualizerIdentifier: string;
begin
  Result := 'CnVclVisualizer';
end;

function TCnTestDebuggerVisualizerValueReplacer.GetVisualizerName: string;
begin
  Result := 'CnPack CnVcl Visualizer'
end;

initialization
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  RegisterCnWizard(TCnTestDebuggerVisualizerWizard); // ע��˲���ר��
{$ENDIF}

end.

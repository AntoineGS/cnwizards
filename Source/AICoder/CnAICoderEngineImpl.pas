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
{            ��վ��ַ��https://www.cnpack.org                                  }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnAICoderEngineImpl;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�AI ��������ר�ҵ�����ʵ�ֵ�Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע��
* ����ƽ̨��PWin7 + Delphi 5.01
* ���ݲ��ԣ�PWin7/10/11 + Delphi/C++Builder
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2024.05.04 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Classes, CnAICoderEngine;

type
  TCnOpenAIEngine = class(TCnAIBaseEngine)
  {* OpenAI ����}
  private
  public
    class function EngineName: string; override;
  end;

  TCnMoonshotAIEngine = class(TCnAIBaseEngine)
  {* ��֮���� AI ����}
  private
  public
    class function EngineName: string; override;
  end;

implementation

{ TCnMoonshotAIEngine }

class function TCnMoonshotAIEngine.EngineName: string;
begin
  Result := 'Moonshot';
end;

{ TCnOpenAIEngine }

class function TCnOpenAIEngine.EngineName: string;
begin
  Result := 'OpenAI';
end;

initialization
  RegisterAIEngine(TCnOpenAIEngine);
  RegisterAIEngine(TCnMoonshotAIEngine);

end.

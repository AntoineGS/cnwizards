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
  TCnOpenAIAIEngine = class(TCnAIBaseEngine)
  {* OpenAI ����}
  public
    class function EngineName: string; override;
  end;

  TCnMoonshotAIEngine = class(TCnAIBaseEngine)
  {* ��֮���� AI ����}
  public
    class function EngineName: string; override;
  end;

  TCnChatGLMAIEngine = class(TCnAIBaseEngine)
  {* �������� AI ����}
  public
    class function EngineName: string; override;
  end;

  TCnBaiChuanAIEngine = class(TCnAIBaseEngine)
  {* �ٴ� AI ����}
  public
    class function EngineName: string; override;
  end;

implementation

{ TCnOpenAIEngine }

class function TCnOpenAIAIEngine.EngineName: string;
begin
  Result := 'OpenAI';
end;

{ TCnMoonshotAIEngine }

class function TCnMoonshotAIEngine.EngineName: string;
begin
  Result := '��֮����';
end;

{ TCnChatGLMAIEngine }

class function TCnChatGLMAIEngine.EngineName: string;
begin
  Result := '��������';
end;

{ TCnBaiChuanAIEngine }

class function TCnBaiChuanAIEngine.EngineName: string;
begin
  Result := '�ٴ�����';
end;

initialization
  RegisterAIEngine(TCnOpenAIAIEngine);
  RegisterAIEngine(TCnMoonshotAIEngine);
  RegisterAIEngine(TCnChatGLMAIEngine);
  RegisterAIEngine(TCnBaiChuanAIEngine);

end.

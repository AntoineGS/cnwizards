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

unit CnAICoderEngine;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�AI ��������ר�ҵ��������Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע��
* ����ƽ̨��PWin7 + Delphi 5.01
* ���ݲ��ԣ�PWin7/10/11 + Delphi/C++Builder
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2024.05.01 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Classes, Contnrs, Windows, CnContainers,
  CnNative, CnInetUtils, CnAICoderConfig, CnThreadPool, CnAICoderNetClient;

type
  TCnAIAnswerObject = class(TPersistent)
  {* ��װ�� AI Ӧ����}
  private
    FSendId: Integer;
    FAnswer: TBytes;
    FSuccess: Boolean;
    FCallback: TCnAIAnswerCallback;
  public
    property Success: Boolean read FSuccess write FSuccess;
    property SendId: Integer read FSendId write FSendId;
    property Answer: TBytes read FAnswer write FAnswer;
    property Callback: TCnAIAnswerCallback read FCallback write FCallback;
  end;

  TCnAIBaseEngine = class
  {* �����ض� AI �����ṩ�ߵ�������࣬��������ض����ã�
   ��������������񡢷����������󡢻�ý�����ص��ĵ��͹���}
  private
    FPoolRef: TCnThreadPool; // �� Manager ���������е��̳߳ض�������
    FOption: TCnAIEngineOption;
    FAnswerQueue: TCnObjectQueue;
    procedure CheckOptionPool;
  protected
    class function EngineName: string; virtual; abstract;
    {* ��������и�����}

    procedure TalkToEngine(Sender: TCnThreadPool; DataObj: TCnTaskDataObject;
      Thread: TCnPoolingThread); virtual;
    {* ��Ĭ��ʵ������������صġ��� AI �����ṩ�߽�������ͨѶ��ȡ�����ʵ�ֺ���
      �ǵ�һ����װ�������Ӹ��̳߳غ����̳߳ص��Ⱥ��ھ��幤���߳��б�����
      ��һ�������� AI ����ͨѶ���������ڵ��������ڲ�����ݽ���ص� OnAINetDataResponse �¼�}
    procedure OnAINetDataResponse(Success: Boolean; Thread: TCnPoolingThread;
      DataObj: TCnAINetRequestDataObject; Data: TBytes); virtual;
    {* AI �����ṩ�߽�������ͨѶ�Ľ���ص����������߳��б����õģ��ڲ�Ӧ Sync �����������
      Success ���سɹ���񣬳ɹ��� Data ��������
      ��һ�������� AI ����ͨѶ���������ڵ��Ĳ�}
    procedure SyncCallback;
    {* ���������Ĳ�ͨ�� Synchronize �ķ�ʽ���ã�֮ǰ�ѽ�Ӧ��������� FAnswerQueue ����
      ��һ�������� AI ����ͨѶ���������ڵ��岽}
  public
    constructor Create(ANetPool: TCnThreadPool); virtual;
    destructor Destroy; override;

    procedure InitOption;
    {* ����������ȥ���ù�������ȡ��������ö���}

    function AskAIEngineExplainCode(const Code: string;
      AnswerCallback: TCnAIAnswerCallback = nil): Integer; virtual;
    {* �û����õĽ��ʹ�����̣��ڲ����װ����������װ����������Ӹ��̳߳أ�����һ������ ID
      ��һ�������� AI ����ͨѶ���������ڵ�һ�����ڶ������̳߳ص��ȵ� ProcessRequest ת��}

    property Option: TCnAIEngineOption read FOption;
    {* �������ã��������ִ����ù�������ȡ��������}
  end;

  TCnAIBaseEngineClass = class of TCnAIBaseEngine;
  {* AI �����༰������}

  TCnAIEngineManager = class
  {* �����ṩ AI ���������Ĺ����࣬��������ʵ���б�}
  private
    FPool: TCnThreadPool; // ���е��̳߳ض���
    FCurrentIndex: Integer;
    FEngines: TObjectList;
    function GetCurrentEngine: TCnAIBaseEngine;
    function GetEnginCount: Integer;
    function GetEngine(Index: Integer): TCnAIBaseEngine;
    procedure SetCurrentIndex(const Value: Integer);
  protected
    procedure ProcessRequest(Sender: TCnThreadPool;
      DataObj: TCnTaskDataObject; Thread: TCnPoolingThread);
  public
    constructor Create; virtual;
    {* ���캯���������ⲿ�������̳߳����ã�������� AI ����ʹ��}
    destructor Destroy; override;

    property CurrentIndex: Integer read FCurrentIndex write SetCurrentIndex;
    {* ��ǰ�����������ţ�������л�����}
    property CurrentEngine: TCnAIBaseEngine read GetCurrentEngine;
    {* ��ǰ�����}

    property EngineCount: Integer read GetEnginCount;
    {* ��������}
    property Engines[Index: Integer]: TCnAIBaseEngine read GetEngine; default;
    {* ��������ȡ AI ����ʵ��}
  end;

procedure RegisterAIEngine(AIEngineClass: TCnAIBaseEngineClass);
{* ע��һ�� AI ����}

function CnAIEngineManager: TCnAIEngineManager;
{* ����һȫ�� AI ����������}

implementation

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

type
  TThreadHack = class(TThread);

var
  FAIEngineManager: TCnAIEngineManager = nil;

  FAIEngines: TClassList = nil;

procedure RegisterAIEngine(AIEngineClass: TCnAIBaseEngineClass);
begin
  if FAIEngines.IndexOf(AIEngineClass) < 0 then
    FAIEngines.Add(AIEngineClass);
end;

function CnAIEngineManager: TCnAIEngineManager;
begin
  if FAIEngineManager = nil then
    FAIEngineManager := TCnAIEngineManager.Create;
  Result := FAIEngineManager;
end;

{ TCnAIEngineManager }

constructor TCnAIEngineManager.Create;
var
  I: Integer;
  Clz: TCnAIBaseEngineClass;
  Engine: TCnAIBaseEngine;
begin
  inherited Create;
  FEngines := TObjectList.Create(True);
  FPool := TCnThreadPool.CreateSpecial(nil, TCnAINetRequestThread);

  // ��ʼ�������̳߳�
  FPool.OnProcessRequest := ProcessRequest;
  FPool.AdjustInterval := 5 * 1000;
  FPool.MinAtLeast := False;
  FPool.ThreadDeadTimeout := 10 * 1000;
  FPool.ThreadsMinCount := 0;
  FPool.ThreadsMaxCount := 2;
  FPool.TerminateWaitTime := 2 * 1000;
  FPool.ForceTerminate := True; // ����ǿ�ƽ���

  // ������ AI ����ʵ��
  for I := 0 to FAIEngines.Count - 1 do
  begin
    Clz := TCnAIBaseEngineClass(FAIEngines[I]);
    if Clz <> nil then
    begin
      Engine := TCnAIBaseEngine(Clz.NewInstance);
      Engine.Create(FPool);

      FEngines.Add(Engine);
    end;
  end;
end;

destructor TCnAIEngineManager.Destroy;
begin
  inherited;
  FPool.Free;
  FEngines.Free;
end;

function TCnAIEngineManager.GetCurrentEngine: TCnAIBaseEngine;
begin
  if (FCurrentIndex >= 0) and (FCurrentIndex < FEngines.Count) then
    Result := TCnAIBaseEngine(FEngines[FCurrentIndex])
  else
    raise Exception.Create('NO Engine Selected.');
end;

function TCnAIEngineManager.GetEnginCount: Integer;
begin
  Result := FEngines.Count;
end;

function TCnAIEngineManager.GetEngine(Index: Integer): TCnAIBaseEngine;
begin
  Result := TCnAIBaseEngine(FEngines[Index]);
end;

procedure TCnAIEngineManager.ProcessRequest(Sender: TCnThreadPool;
  DataObj: TCnTaskDataObject; Thread: TCnPoolingThread);
begin
  CurrentEngine.TalkToEngine(Sender, DataObj, Thread);
end;

procedure TCnAIEngineManager.SetCurrentIndex(const Value: Integer);
begin
  if FCurrentIndex <> Value then
  begin
    FCurrentIndex := Value;
    // ��¼����ı���
  end;
end;

{ TCnAIBaseEngine }

function TCnAIBaseEngine.AskAIEngineExplainCode(const Code: string;
  AnswerCallback: TCnAIAnswerCallback): Integer;
var
  Obj: TCnAINetRequestDataObject;
begin
  CheckOptionPool;
  Result := 0;

  if Code <> '' then
  begin
    Obj := TCnAINetRequestDataObject.Create;
    Obj.URL := FOption.URL;
    Obj.SendId := 10000000 + Random(100000000);
    Obj.Engine := EngineName;

    // TODO: ƴװ JSON ��ʽ��������Ϊ Post �ĸ������ݸ� Data ��

    Obj.OnAnswer := AnswerCallback;
    Obj.OnResponse := OnAINetDataResponse;
    FPoolRef.AddRequest(Obj);
    Result := Obj.SendId;
  end;
end;

procedure TCnAIBaseEngine.CheckOptionPool;
begin
  // ��� Pool��Option �������Ƿ�Ϸ�
end;

constructor TCnAIBaseEngine.Create(ANetPool: TCnThreadPool);
begin
  inherited Create;
  FPoolRef := ANetPool;

  FAnswerQueue := TCnObjectQueue.Create(True);
  InitOption;
end;

destructor TCnAIBaseEngine.Destroy;
begin
  while not FAnswerQueue.IsEmpty do
    FAnswerQueue.Pop.Free;

  FAnswerQueue.Free;
  inherited;
end;

procedure TCnAIBaseEngine.InitOption;
begin
  FOption := CnAIEngineOptionManager.GetOptionByEngine(EngineName)
end;

procedure TCnAIBaseEngine.OnAINetDataResponse(Success: Boolean;
  Thread: TCnPoolingThread; DataObj: TCnAINetRequestDataObject; Data: TBytes);
var
  AnswerObj: TCnAIAnswerObject;
begin
  // �����߳����õ����ݻ������¼���ֱ�ӵ��ã��ʵ���װ�� Synchronize ���ظ�����
  if (DataObj <> nil) and Assigned(TCnAINetRequestDataObject(DataObj).OnAnswer) then
    TCnAINetRequestDataObject(DataObj).OnAnswer(Success, TCnAINetRequestDataObject(DataObj).SendId, Data);

  AnswerObj := TCnAIAnswerObject.Create;
  AnswerObj.Success := Success;
  AnswerObj.SendId := TCnAINetRequestDataObject(DataObj).SendId;
  AnswerObj.Answer := Data; // ���õ��м�������������ͷ�

  FAnswerQueue.Push(AnswerObj);
  TThreadHack(Thread).Synchronize(SyncCallback);
end;

procedure TCnAIBaseEngine.SyncCallback;
var
  AnswerObj: TCnAIAnswerObject;
begin
  AnswerObj := TCnAIAnswerObject(FAnswerQueue.Pop);
  if AnswerObj <> nil then
  begin
    if Assigned(AnswerObj.Callback) then
      AnswerObj.Callback(AnswerObj.Success, AnswerObj.SendId, AnswerObj.Answer);
    AnswerObj.Free;
  end;
end;

procedure TCnAIBaseEngine.TalkToEngine(Sender: TCnThreadPool;
  DataObj: TCnTaskDataObject; Thread: TCnPoolingThread);
var
  HTTP: TCnHTTP;
  Stream: TMemoryStream;
begin
  HTTP := nil;
  Stream := nil;

  try
    HTTP := TCnHTTP.Create;
    Stream := TMemoryStream.Create;

    if HTTP.GetStream(TCnAINetRequestDataObject(DataObj).URL, Stream) then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg('*** HTTP Request OK Get Bytes ' + IntToStr(Stream.Size));
{$ENDIF}

      // ����Ҫ�ѽ���͸� UI ������������������ڱ��̣߳���Ϊ UI ���̵߳ĵ��ô�������ʱ���ǲ�ȷ���ģ�
      // �����˱�������Thread ��״̬��δ֪�ˣ��� Thread ������ݿ��ܻ��� Thread �����ӵ��ȶ������
      if Assigned(TCnAINetRequestDataObject(DataObj).OnResponse) then
        TCnAINetRequestDataObject(DataObj).OnResponse(True, Thread, TCnAINetRequestDataObject(DataObj), StreamToBytes(Stream));
    end
    else
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg('*** HTTP Request Fail. ' + IntToStr(GetLastError));
{$ENDIF}
      if Assigned(TCnAINetRequestDataObject(DataObj).OnResponse) then
        TCnAINetRequestDataObject(DataObj).OnResponse(False, Thread, TCnAINetRequestDataObject(DataObj), nil);
    end;
  finally
    Stream.Free;
    HTTP.Free;
  end;
end;

initialization
  FAIEngines := TClassList.Create;

finalization
  FAIEngineManager.Free;
  FAIEngines.Free;

end.

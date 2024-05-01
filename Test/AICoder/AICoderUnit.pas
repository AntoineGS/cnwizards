unit AICoderUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, CnThreadPool, CnInetUtils, CnNative, CnContainers, CnJSON,
  CnAICoderConfig, CnAICoderEngine;

type
  TFormAITest = class(TForm)
    dlgSave1: TSaveDialog;
    dlgOpen1: TOpenDialog;
    pgcAICoder: TPageControl;
    tsHTTP: TTabSheet;
    mmoHTTP: TMemo;
    btnAddHttps: TButton;
    tsAIConfig: TTabSheet;
    btnAIConfigSave: TButton;
    btnAIConfigLoad: TButton;
    mmoConfig: TMemo;
    tsEngine: TTabSheet;
    btnLoadAIConfig: TButton;
    lblAIName: TLabel;
    cbbAIEngines: TComboBox;
    btnSaveAIConfig: TButton;
    btnExplainCode: TButton;
    mmoAI: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnAddHttpsClick(Sender: TObject);
    procedure btnAIConfigSaveClick(Sender: TObject);
    procedure btnAIConfigLoadClick(Sender: TObject);
    procedure btnLoadAIConfigClick(Sender: TObject);
    procedure cbbAIEnginesChange(Sender: TObject);
    procedure btnSaveAIConfigClick(Sender: TObject);
    procedure btnExplainCodeClick(Sender: TObject);
  private
    FNetPool: TCnThreadPool;
    FResQueue: TCnObjectQueue;
    FAIConfig: TCnAIEngineOptionManager;

    // �������ۺϲ���
    procedure AIOnExplainCodeAnswer(Success: Boolean; SendId: Integer; Answer: TBytes);
  protected
    procedure ShowData;
  public
    procedure ProcessRequest(Sender: TCnThreadPool;
      DataObj: TCnTaskDataObject; Thread: TCnPoolingThread);
    procedure MyResponse(Success: Boolean; Thread: TCnPoolingThread;
      SendId: Integer; Data: TBytes);
  end;

  TSendThread = class(TCnPoolingThread)
  private
    FData: TBytes;
    FSendId: Integer;
  public
    property SendId: Integer read FSendId write FSendId;
    property Data: TBytes read FData write FData;
  end;

  TSendDataResponse = procedure(Success: Boolean; Thread: TCnPoolingThread;
    SendId: Integer; Data: TBytes) of object;
  {* ��������Ļص������߳ɹ���񣬳ɹ��� Data ��������}

  TSendDataObject = class(TCnTaskDataObject)
  {* ������������������࣬�ɷ����߸�����������������������Ӹ��̳߳�
    �н��ʱ�̻߳�ص� OnResponse �¼�}
  private
    FURL: string;
    FSendId: Integer;
    FOnResponse: TSendDataResponse;
  public
    function Clone: TCnTaskDataObject; override;

    property SendId: Integer read FSendId write FSendId;
    property URL: string read FURL write FURL;

    property OnResponse: TSendDataResponse read FOnResponse write FOnResponse;
    {* �յ���������ʱ�Ļص��¼���ע���������߳��б����õģ�����ʱ���� Synchronize �����߳����輰ʱ��������}
  end;

  TResponseDataObject = class(TObject)
  {* ����ص�����ķ�װ�����ڵݸ����̹߳�����}
  private
    FSendId: Integer;
    FData: TBytes;
  public
    property SendId: Integer read FSendId write FSendId;
    property Data: TBytes read FData write FData;
  end;

var
  FormAITest: TFormAITest;

implementation

{$R *.DFM}

uses
  CnDebug;

const
  DBG_TAG = 'NET';

type
  TCnAITestEngine = class(TCnAIBaseEngine)
  protected
    class function EngineName: string; override;
  end;

procedure TFormAITest.FormCreate(Sender: TObject);
begin
  FNetPool := TCnThreadPool.CreateSpecial(nil, TSendThread);

  FNetPool.OnProcessRequest := ProcessRequest;
  FNetPool.AdjustInterval := 5 * 1000;
  FNetPool.MinAtLeast := False;
  FNetPool.ThreadDeadTimeout := 10 * 1000;
  FNetPool.ThreadsMinCount := 0;
  FNetPool.ThreadsMaxCount := 5;
  FNetPool.TerminateWaitTime := 2 * 1000;
  FNetPool.ForceTerminate := True; // ����ǿ�ƽ���

  FResQueue := TCnObjectQueue.Create(True);

  FAIConfig := TCnAIEngineOptionManager.Create;
end;

procedure TFormAITest.FormDestroy(Sender: TObject);
begin
  FAIConfig.Free;

  FNetPool.Free;

  while not FResQueue.IsEmpty do
    FResQueue.Pop.Free;

  FResQueue.Free;
end;

type
  TThreadHack = class(TThread);

procedure TFormAITest.ProcessRequest(Sender: TCnThreadPool;
  DataObj: TCnTaskDataObject; Thread: TCnPoolingThread);
var
  HTTP: TCnHTTP;
  Stream: TMemoryStream;
begin
  HTTP := TCnHTTP.Create;
  Stream := TMemoryStream.Create;

  try
    CnDebugger.LogMsgWithTag('*** HTTP To Request.', DBG_TAG);
    Sleep(2000 + Random(5000));
    if HTTP.GetStream(TSendDataObject(DataObj).URL, Stream) then
    begin
      CnDebugger.LogMsgWithTag('*** HTTP Request OK Get Bytes ' + IntToStr(Stream.Size), DBG_TAG);

      // ����Ҫ�ѽ���͸� UI ������������������ڱ��̣߳���Ϊ UI ���̵߳ĵ��ô�������ʱ���ǲ�ȷ���ģ�
      // �����˱�������Thread ��״̬��δ֪�ˣ��� Thread ������ݿ��ܻ��� Thread �����ӵ��ȶ������
      if Assigned(TSendDataObject(DataObj).OnResponse) then
        TSendDataObject(DataObj).OnResponse(True, Thread, TSendDataObject(DataObj).SendId, StreamToBytes(Stream));
    end
    else
    begin
      CnDebugger.LogMsgWithTag('*** HTTP Request Fail. ' + IntToStr(GetLastError), DBG_TAG);
      if Assigned(TSendDataObject(DataObj).OnResponse) then
        TSendDataObject(DataObj).OnResponse(False, Thread, TSendDataObject(DataObj).SendId, nil);
    end;
  finally
    Stream.Free;
    HTTP.Free;
  end;
end;

procedure TFormAITest.btnAddHttpsClick(Sender: TObject);
const
  A_URL = 'http://www.baidu.com/s?wd=CnPack';
var
  I: Integer;
  Obj: TSendDataObject;
begin
  // mmoHTTP.Lines.Clear;
  CnDebugger.LogMsgWithTag('*** Button Click.', DBG_TAG);
  for I := 1 to 20 do
  begin
    Obj := TSendDataObject.Create;
    Obj.URL := A_URL;
    Obj.SendId := 1000 + Random(10000);
    Obj.OnResponse := MyResponse;

    FNetPool.AddRequest(Obj);
  end;
end;

{ TSendDataObject }

function TSendDataObject.Clone: TCnTaskDataObject;
begin
  Result := TSendDataObject.Create;
  TSendDataObject(Result).URL := FURL;
  TSendDataObject(Result).SendId := FSendId;
  TSendDataObject(Result).OnResponse := FOnResponse;
end;

{ TSendThread }

procedure TFormAITest.MyResponse(Success: Boolean; Thread: TCnPoolingThread;
  SendId: Integer; Data: TBytes);
var
  Res: TResponseDataObject;
begin
  // ���¼��������߳��е��õġ�
  // ���� Synchronize ȥ���̣߳����豣�� SendId �� Data ���ӹ�ȥ
  // ���������Ƶ��ö��У�����룬���߳�ȡ
  if Success and (Length(Data) > 0) then
  begin
    Res := TResponseDataObject.Create;
    Res.SendId := SendId;
    Res.Data := Data;

    FResQueue.Push(Res);
    TThreadHack(Thread).Synchronize(ShowData);
  end;
end;

procedure TFormAITest.ShowData;
var
  Obj: TResponseDataObject;
begin
  Obj := TResponseDataObject(FResQueue.Pop);
  if Obj <> nil then
  begin
    FormPool.mmoHTTP.Lines.Add(Format('Get Bytes %d from SendId %d', [Length(Obj.Data), Obj.SendId]));
    // FormPool.mmoHTTP.Lines.Add(BytesToString(Obj.Data));
    Obj.Free;
  end;
end;

procedure TFormAITest.btnAIConfigSaveClick(Sender: TObject);
var
  Option: TCnAIEngineOption;
begin
  FAIConfig.Clear;

  Option := TCnAIEngineOption.Create;
  Option.EngineName := 'Moonshot';
  Option.Model := 'moonshot-v1-8k';
  Option.URL := 'https://api.moonshot.cn/v1/chat/completions';
  Option.ApiKey := '{B13DB6F2-B0DA-40BC-B0F7-E654F96FD159}';
  Option.SystemMessage := '����һ�� Delphi ר��';
  Option.Temperature := '0.3';
  Option.ExplainCodePrompt := '��������´��룺';

  FAIConfig.AddOption(Option);

  Option := TCnAIEngineOption.Create;
  Option.EngineName := '����������';
  Option.Model := 'cnpack-noai-9.8';
  Option.URL := 'https://upgrade.cnpack.org/';
  Option.ApiKey := '{ACED92D0-6D09-4B88-BEA7-B963A8301CA4}';
  Option.SystemMessage := '����һ�� C++Builder ר��';
  Option.Temperature := '0.3';
  Option.ExplainCodePrompt := '��������´��룺';

  FAIConfig.AddOption(Option);
  FAIConfig.ActiveEngine := 'Moonshot';

  dlgSave1.FileName := 'AIConfig.json';
  if dlgSave1.Execute then
    FAIConfig.SaveToFile(dlgSave1.FileName);
end;

procedure TFormAITest.btnAIConfigLoadClick(Sender: TObject);
begin
  dlgOpen1.FileName := 'AIConfig.json';
  if dlgOpen1.Execute then
  begin
    FAIConfig.LoadFromFile(dlgOpen1.FileName);
    mmoConfig.Lines.Clear;
    mmoConfig.Lines.Add(FAIConfig.SaveToJSON);
  end;
end;

procedure TFormAITest.btnLoadAIConfigClick(Sender: TObject);
var
  I: Integer;
begin
  if dlgOpen1.Execute then
  begin
    CnAIEngineOptionManager.LoadFromFile(dlgOpen1.FileName);
    cbbAIEngines.Items.Clear;
    for I := 0 to CnAIEngineOptionManager.OptionCount - 1 do
      cbbAIEngines.Items.Add(CnAIEngineOptionManager.Options[I].EngineName);

    cbbAIEngines.ItemIndex := CnAIEngineOptionManager.ActiveEngineIndex;
    CnAIEngineManager.CurrentIndex := CnAIEngineOptionManager.ActiveEngineIndex;
  end;
end;

procedure TFormAITest.cbbAIEnginesChange(Sender: TObject);
begin
  CnAIEngineOptionManager.ActiveEngine := cbbAIEngines.Text;
  CnAIEngineManager.CurrentIndex := CnAIEngineOptionManager.ActiveEngineIndex;
end;

procedure TFormAITest.btnSaveAIConfigClick(Sender: TObject);
begin
 dlgSave1.FileName := 'AIConfig.json';
  if dlgSave1.Execute then
    CnAIEngineOptionManager.SaveToFile(dlgSave1.FileName);
end;

procedure TFormAITest.btnExplainCodeClick(Sender: TObject);
begin
  CnAIEngineManager.CurrentEngine.AskAIEngineExplainCode('Application.Terminate;',
    AIOnExplainCodeAnswer);
end;

procedure TFormAITest.AIOnExplainCodeAnswer(Success: Boolean;
  SendId: Integer; Answer: TBytes);
begin
  if Success then
    mmoAI.Lines.Add(Format('Explain Code OK for Request %d: %s', [SendId, BytesToAnsi(Answer)]))
  else
    mmoAI.Lines.Add(Format('Explain Code Fail for Request %d: Error Code %d', [SendId, GetLastError]));
end;

{ TCnAITestEngine }

class function TCnAITestEngine.EngineName: string;
begin
  Result := 'Moonshot';
end;

initialization
  RegisterAIEngine(TCnAITestEngine);

end.

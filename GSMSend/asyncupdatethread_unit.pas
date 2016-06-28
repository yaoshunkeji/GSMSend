unit AsyncUpdateThread_Unit;

{$mode delphi}

interface

uses
  Classes, SysUtils,syncobjs,ServerComm_Unit;

type

  PAsyncUpdateItem=^TAsyncUpdateItem;
  TAsyncUpdateItem=packed record
    MSG:TMSGData;
    StrLst:TStringList;
  end;

  { TAsyncUpdateThread }

  TAsyncUpdateThread= class(TThread)
  private
    UpdateItem:PAsyncUpdateItem;
    procedure DoUpdate;

  protected
    procedure Execute;override;
  public

    constructor Create();
    destructor Destroy; override;
  end;

var
  AsyncUpdateList:TThreadList=nil;
  AsyncUpdateThread:TAsyncUpdateThread=nil;

  procedure PushAsyncUpdate(msg:TMSGData;strlst:TStrings);
  procedure StartAsyncUpdateThread();

implementation

uses
  mainform_unit;

{ TAsyncUpdateThread }
var
  AsyncUpdateEvent:TEvent=nil;



procedure PushAsyncUpdate(msg:TMSGData;strlst:TStrings);
var
  m:PAsyncUpdateItem;
begin
  m:=GetMem(sizeof(TAsyncUpdateItem));
  m^.MSG:=msg;
  m^.StrLst:=TStringList.Create;
  m^.StrLst.Clear;
  m^.StrLst.AddStrings(strlst);
  AsyncUpdateList.Add(m);
  AsyncUpdateEvent.SetEvent;
end;

procedure StartAsyncUpdateThread();
begin
  AsyncUpdateThread:=TAsyncUpdateThread.Create();

end;

function PopAsyncUpdate():PAsyncUpdateItem;
var
  lst:TList;
begin
  Result:=nil;
  lst:=AsyncUpdateList.LockList;
  if lst.Count>0 then
  begin
    Result:=lst.Items[0];
    lst.Delete(0);
  end;
  AsyncUpdateList.UnlockList;

end;

procedure TAsyncUpdateThread.DoUpdate;
begin
  try
    if UpdateItem=nil then
    exit;
    if mainform=nil then
    exit;
    mainform.OnRecvMsg(UpdateItem^.msg,UpdateItem^.strlst);
  except
  end;

end;

procedure TAsyncUpdateThread.Execute;
begin
  UpdateItem:=nil;
  while not self.Terminated do
  begin
    AsyncUpdateEvent.WaitFor(10000);
    while not self.Terminated do
    begin
      UpdateItem:=PopAsyncUpdate();
      if UpdateItem=nil then
      system.Break;

      self.Synchronize(self.DoUpdate);
      sysutils.FreeAndNil(UpdateItem^.strlst);
      freemem(UpdateItem);
      sleep(5);
    end;
  end;

end;

constructor TAsyncUpdateThread.Create;
begin
  inherited Create(True);
  self.FreeOnTerminate:=true;
  self.Resume;

end;

destructor TAsyncUpdateThread.Destroy;
begin
  AsyncUpdateThread:=nil;
  inherited Destroy;
end;

initialization
AsyncUpdateList:=TThreadList.Create;
AsyncUpdateEvent:=TEvent.Create(nil,false,false,'AsyncUpdateEvent');

finalization
sysutils.FreeAndNil(AsyncUpdateList);

end.


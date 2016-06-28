unit SDR_IO_Unit;

{$mode delphi}

interface

uses
  Classes, SysUtils;

type

  { TSDR }
  TOnSample=procedure(Sender:TObject;Data:Pointer;Size:DWORD) of object;
//  TOnSampleBitEvent=procedure(Sender:TObject;Data:Pointer;Size:DWORD) of object;
//  TOnSampleRate=procedure(Sender:TObject;Data:Pointer;Size:DWORD) of object;

  TSDR= class(TObject)
  private
    FFreq: int64;
    FSampleRate: DWORD;
    FOnSample:TOnSample;
    procedure SetFreq(AValue: int64);
    procedure SetSampleRate(AValue: DWORD);

  protected
//    procedure execute;override;
  public
//    class FindDevice:Boolean;
    function InitDevice:Boolean;
    function DeInitDevice:Boolean;

    property Freq:int64 read FFreq write SetFreq;
    property SampleRate:DWORD read FSampleRate write SetSampleRate;
    property OnSample:TOnSample read FOnSample write FOnSample;
    function ConfigDialog:Boolean;
    function StartIQ:Boolean;
    function StopIQ:Boolean;

    constructor Create;
    destructor Destroy; override;

  end;

implementation

{ TSDR }

procedure TSDR.SetFreq(AValue: int64);
begin
  if FFreq=AValue then Exit;
  FFreq:=AValue;
end;

procedure TSDR.SetSampleRate(AValue: DWORD);
begin
  if FSampleRate=AValue then Exit;
  FSampleRate:=AValue;
end;

function TSDR.InitDevice: Boolean;
begin

end;

function TSDR.DeInitDevice: Boolean;
begin

end;

function TSDR.ConfigDialog: Boolean;
begin

end;

function TSDR.StartIQ: Boolean;
begin

end;

function TSDR.StopIQ: Boolean;
begin

end;

constructor TSDR.Create;
begin

end;

destructor TSDR.Destroy;
begin
  inherited Destroy;
end;

end.


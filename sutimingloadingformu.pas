unit sutimingloadingformu;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Windows;

type

  TTextFileLoadFun = function(Sender: TObject; const ALine: string;
    const LineNo: Cardinal): Boolean of object;

  TLoadResult = (lrOK, lrCancel, lrAbort);

  { TSuTimingLoadingForm }

  TSuTimingLoadingForm = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    FLoadFun: TTextFileLoadFun;
    FCancel: Boolean;
  public
    function LoadFile(const Fn: string; Fun: TTextFileLoadFun): TLoadResult;
  end;

var
  SuTimingLoadingForm: TSuTimingLoadingForm;

implementation

{$R *.lfm}

{ TSuTimingLoadingForm }

procedure TSuTimingLoadingForm.Button1Click(Sender: TObject);
begin
  FCancel := True;
end;

function TSuTimingLoadingForm.LoadFile(const Fn: string; Fun: TTextFileLoadFun): TLoadResult;
var
  F: TextFile;
  S: string;
  C: Cardinal = 0;
  FS, P: Int64;
  T: TDateTime;
  O: TDateTime;
begin
  Result := lrOK;
  FCancel := False;
  Label1.Caption := '';
  Label2.Caption := '';
  FLoadFun := Fun;
  FS := FileSize(Fn);
  AssignFile(F, Fn);
  Reset(F);
  T := Now;
  Show;
  while (not FCancel) and (not EOF(F)) do
  begin
    Inc(C);
    Readln(F, S);
    if not Fun(Self, S, C) then
    begin
      Result := lrAbort;
      Break;
    end;
    if C and $3FFF = 0 then
    begin
      O := (Now - T) * SecsPerDay;
      if O > 0.5 then
      begin
        P := SetFilePointer(GetFileHandle(F), 0, nil, FILE_CURRENT);
        Label1.Caption := Format('%d%%', [Round(P / FS * 100)]);
        Label2.Caption := Format('%.1fMB/s', [(P / O / 1000000)]);
        Application.ProcessMessages;
      end;
    end;
  end;
  Hide;
  CloseFile(F);
  if FCancel then Result := lrCancel;
end;

end.


unit Telemetries;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  System.Generics.Defaults;

type

  TTelemetryHeader = record
    SessionUID: UInt64;
    SessionTime: Single;
    FrameIdentifier: UInt32;
    PlayerIndex: UInt8;

    function Equals(const AHeader: TTelemetryHeader): Boolean;
  end;

  TTelemetry = class
  public
    Header: TTelemetryHeader;
    // Session Data
    SafetyCarStatus: UInt8;
    // Lap Data
    CurrentLapTimeInMS: UInt64;
    CurrentLapNum: UInt8;
    DriverStatus: UInt8;
    ResultStatus: UInt8;
    // Participant Data
    AiControlled: UInt8;
    YourTelemetry: UInt8;
    // Car Telemetry Data
    Speed: UInt16;
    Throttle: Single;
    Steer: Single;
    Brake: Single;
    Gear: Int8;
    Drs: UInt8;
    // Car Damage Data
    TyresWearRearLeft: Single;
    TyresWearRearRight: Single;
    TyresWearFrontLeft: Single;
    TyresWearFrontRight: Single;

    constructor Create; reintroduce;

    function Clone: TTelemetry; virtual;
  end;

  TTelemetryComparer = class(TComparer<TTelemetry>)
  public
    function Compare(const L: TTelemetry; const R: TTelemetry): Integer; override;
  end;

  TTelemetryHistory = class(TObjectList<TTelemetry>)
  public
    function SearchFor(const AHeader: TTelemetryHeader; out ATelemetry: TTelemetry): Boolean; virtual;
    function CreateNew(const AHeader: TTelemetryHeader): TTelemetry; virtual;
  end;

  TTelemetryCSVReader = class(TStreamReader)
  public
    procedure ReadTelemetry(out ATelemetry: TTelemetry); virtual;
  end;

  TTelemetryCSVWriter = class(TStreamWriter)
  public
    procedure WriteTelemetry(const ATelemetry: TTelemetry); virtual;
  end;

const
  CSV_COL_SESSIONUID: Integer = 0;
  CSV_COL_SESSIONTIME: Integer = 1;
  CSV_COL_FRAMEIDENTIFIER: Integer = 2;
  CSV_COL_PLAYERINDEX: Integer = 3;
  CSV_COL_SAFETYCARSTATUS: Integer = 4;
  CSV_COL_CURRENTLAPTIMEINMS: Integer = 5;
  CSV_COL_CURRENTLAPNUM: Integer = 6;
  CSV_COL_DRIVERSTATUS: Integer = 7;
  CSV_COL_RESULTSTATUS: Integer = 8;
  CSV_COL_AICONTROLLED: Integer = 9;
  CSV_COL_YOURTELEMETRY: Integer = 10;
  CSV_COL_SPEED: Integer = 11;
  CSV_COL_THROTTLE: Integer = 12;
  CSV_COL_STEER: Integer = 13;
  CSV_COL_BRAKE: Integer = 14;
  CSV_COL_GEAR: Integer = 15;
  CSV_COL_DRS: Integer = 16;
  CSV_COL_TYRESWEARRL: Integer = 17;
  CSV_COL_TYRESWEARRR: Integer = 18;
  CSV_COL_TYRESWEARFL: Integer = 19;
  CSV_COL_TYRESWEARFR: Integer = 20;


implementation

function TTelemetryHeader.Equals(const AHeader: TTelemetryHeader): Boolean;
begin
  Result := (Self.SessionUID = AHeader.SessionUID) and (Self.FrameIdentifier = AHeader.FrameIdentifier) and (Self.PlayerIndex = AHeader.PlayerIndex);
end;

constructor TTelemetry.Create;
begin
  inherited Create;
  Self.Header.SessionUID := 0;
  Self.Header.SessionTime := 0;
  Self.Header.FrameIdentifier := 0;
  Self.Header.PlayerIndex := 0;
  Self.SafetyCarStatus := 0;
  Self.CurrentLapTimeInMS := 0;
  Self.CurrentLapNum := 0;
  Self.DriverStatus := 0;
  Self.ResultStatus := 0;
  Self.AiControlled := 0;
  Self.YourTelemetry := 0;
  Self.Speed := 0;
  Self.Throttle := 0;
  Self.Brake := 0;
  Self.Gear := 0;
  Self.Drs := 0;
  Self.TyresWearRearLeft := 0;
  Self.TyresWearRearRight := 0;
  Self.TyresWearFrontLeft := 0;
  Self.TyresWearFrontRight := 0;
end;

function TTelemetry.Clone: TTelemetry;
begin
  Result := TTelemetry.Create;
  // Header Data
  Result.Header.SessionUID := Self.Header.SessionUID;
  Result.Header.SessionTime := Self.Header.SessionTime;
  Result.Header.FrameIdentifier := Self.Header.FrameIdentifier;
  Result.Header.PlayerIndex := Self.Header.PlayerIndex;
  // Session Data
  Result.SafetyCarStatus := Self.SafetyCarStatus;
  // Lap Data
  Result.CurrentLapTimeInMS := Self.CurrentLapTimeInMS;
  Result.CurrentLapNum := Self.CurrentLapNum;
  Result.DriverStatus := Self.DriverStatus;
  Result.ResultStatus := Self.ResultStatus;
  // Participant Data
  Result.AiControlled := Self.AiControlled;
  Result.YourTelemetry := Self.YourTelemetry;
  // Car Telemetry Data
  Result.Speed := Self.Speed;
  Result.Throttle := Self.Throttle;
  Result.Steer := Self.Steer;
  Result.Brake := Self.Brake;
  Result.Gear := Self.Gear;
  Result.Drs := Self.Drs;
  // Car Damage Data
  Result.TyresWearRearLeft := Self.TyresWearRearLeft;
  Result.TyresWearRearRight := Self.TyresWearRearRight;
  Result.TyresWearFrontLeft := Self.TyresWearFrontLeft;
  Result.TyresWearFrontRight := Self.TyresWearFrontRight;
end;

function TTelemetryComparer.Compare(const L: TTelemetry; const R: TTelemetry): Integer;
begin
  if L.Header.SessionUID = R.Header.SessionUID then
    if L.Header.FrameIdentifier = R.Header.FrameIdentifier then
      Result := R.Header.PlayerIndex - L.Header.PlayerIndex
    else
      Result := R.Header.FrameIdentifier - L.Header.FrameIdentifier
  else
    Result := R.Header.SessionUID - L.Header.SessionUID;
end;

function TTelemetryHistory.SearchFor(const AHeader: TTelemetryHeader; out ATelemetry: TTelemetry): Boolean;
var
  Index: Integer;
begin
  for Index := Pred(Self.Count) downto 0 do
  begin
    if Self[Index].Header.Equals(AHeader) then
    begin
      ATelemetry := Self[Index];
      Exit(True);
    end;
  end;
  Exit(False);
end;

function TTelemetryHistory.CreateNew(const AHeader: TTelemetryHeader): TTelemetry;
begin
  if Self.Count = 0 then
    Result := TTelemetry.Create
  else
    Result := Self.Last.Clone;

  Result.Header.SessionUID := AHeader.SessionUID;
  Result.Header.SessionTime := AHeader.SessionTime;
  Result.Header.FrameIdentifier := AHeader.FrameIdentifier;
  Result.Header.PlayerIndex := AHeader.PlayerIndex;

  Self.Add(Result);
end;

procedure TTelemetryCSVReader.ReadTelemetry(out ATelemetry: TTelemetry);
var
  Row: TStrings;
  Index: Integer;
begin
  Row := TStringList.Create;
  try
    Row.AddStrings(Self.ReadLine.Replace(',', '.', [rfReplaceAll]).Split([';']));

    for Index := 0 to Pred(Row.Count) do
      Row[Index] := Row[Index].Trim;

    ATelemetry.Header.SessionUID := UInt64.Parse(Row[CSV_COL_SESSIONUID]);
    ATelemetry.Header.SessionTime := Single.Parse(Row[CSV_COL_SESSIONTIME]);
    ATelemetry.Header.FrameIdentifier := UInt32.Parse(Row[CSV_COL_FRAMEIDENTIFIER]);
    ATelemetry.Header.PlayerIndex := Byte.Parse(Row[CSV_COL_PLAYERINDEX]);
    ATelemetry.SafetyCarStatus := Byte.Parse(Row[CSV_COL_SAFETYCARSTATUS]);
    ATelemetry.CurrentLapTimeInMS := UInt64.Parse(Row[CSV_COL_CURRENTLAPTIMEINMS]);
    ATelemetry.CurrentLapNum := Byte.Parse(Row[CSV_COL_CURRENTLAPNUM]);
    ATelemetry.DriverStatus := Byte.Parse(Row[CSV_COL_DRIVERSTATUS]);
    ATelemetry.ResultStatus := Byte.Parse(Row[CSV_COL_RESULTSTATUS]);
    ATelemetry.AiControlled := Byte.Parse(Row[CSV_COL_AICONTROLLED]);
    ATelemetry.YourTelemetry := Byte.Parse(Row[CSV_COL_YOURTELEMETRY]);
    ATelemetry.Speed := UInt16.Parse(Row[CSV_COL_SPEED]);
    ATelemetry.Throttle := Single.Parse(Row[CSV_COL_THROTTLE]);
    ATelemetry.Steer := Single.Parse(Row[CSV_COL_STEER]);
    ATelemetry.Brake := Single.Parse(Row[CSV_COL_BRAKE]);
    ATelemetry.Gear := ShortInt.Parse(Row[CSV_COL_GEAR]);
    ATelemetry.Drs := Byte.Parse(Row[CSV_COL_DRS]);
    ATelemetry.TyresWearRearLeft := Single.Parse(Row[CSV_COL_TYRESWEARRL]);
    ATelemetry.TyresWearRearRight := Single.Parse(Row[CSV_COL_TYRESWEARRR]);
    ATelemetry.TyresWearFrontLeft := Single.Parse(Row[CSV_COL_TYRESWEARFL]);
    ATelemetry.TyresWearFrontRight := Single.Parse(Row[CSV_COL_TYRESWEARFR]);
  finally
    Row.Free;
  end;
end;

procedure TTelemetryCSVWriter.WriteTelemetry(const ATelemetry: TTelemetry);
var
  Builder: TStringBuilder;
begin
  Builder := TStringBuilder.Create;
  try
    Builder
      .Append(ATelemetry.Header.SessionUID).Append(';')
      .Append(ATelemetry.Header.SessionTime).Append(';')
      .Append(ATelemetry.Header.FrameIdentifier).Append(';')
      .Append(ATelemetry.Header.PlayerIndex).Append(';')
      .Append(ATelemetry.SafetyCarStatus).Append(';')
      .Append(ATelemetry.CurrentLapTimeInMS).Append(';')
      .Append(ATelemetry.CurrentLapNum).Append(';')
      .Append(ATelemetry.DriverStatus).Append(';')
      .Append(ATelemetry.ResultStatus).Append(';')
      .Append(ATelemetry.AiControlled).Append(';')
      .Append(ATelemetry.YourTelemetry).Append(';')
      .Append(ATelemetry.Speed).Append(';')
      .Append(ATelemetry.Throttle).Append(';')
      .Append(ATelemetry.Steer).Append(';')
      .Append(ATelemetry.Brake).Append(';')
      .Append(ATelemetry.Gear).Append(';')
      .Append(ATelemetry.Drs).Append(';')
      .Append(ATelemetry.TyresWearRearLeft).Append(';')
      .Append(ATelemetry.TyresWearRearRight).Append(';')
      .Append(ATelemetry.TyresWearFrontLeft).Append(';')
      .Append(ATelemetry.TyresWearFrontRight)
      .AppendLine;

    Self.WriteLine(Builder.ToString);
  finally
    Builder.Free;
  end;
end;

end.

program DataPreProcessing;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Classes,
  System.SysUtils,
  System.StrUtils,
  Telemetries in '..\Share\Telemetries.pas',
  TimeSeries in '..\Share\TimeSeries.pas';

const
  TIMESERIES_LENGTH: Integer = 10;

  function CheckIsValidTelemetry(const ATelemetry: TTelemetry): Boolean;
  begin
    Result := (ATelemetry.Header.SessionTime > 0)
          and (ATelemetry.Header.FrameIdentifier > 0)
          and (ATelemetry.SafetyCarStatus = 0)
          and (ATelemetry.CurrentLapTimeInMS > 0)
          and (ATelemetry.CurrentLapNum > 0)
          and (ATelemetry.DriverStatus = 4)
          and (ATelemetry.ResultStatus = 2)
          and (ATelemetry.AiControlled = 0)
          and (ATelemetry.YourTelemetry = 1);
  end;

  function NormalMaxMin(const AValue: Integer; const AMin: Integer; const AMax: Integer): Extended; overload;
  begin
    Result := (AValue - AMin) / (AMax - AMin);
  end;

  function NormalMaxMin(const AValue: Extended; const AMin: Extended; const AMax: Extended): Extended; overload;
  begin
    Result := (AValue - AMin) / (AMax - AMin);
  end;

var
  FileNameInput: TFileName;
  FileNameOutput: TFileName;
  Input: TTelemetryCSVReader;
  Output: TTimeSerieCSVWriter;
  PlayerClass: Byte;
  Telemetry: TTelemetry;
  TimeSerie: TTimeSerie;
  Moment: TMoment;
begin
  try
    FormatSettings.DecimalSeparator := '.';
    FormatSettings.ThousandSeparator := ' ';

    // Player class (0 = Legit, 1 = Cheat)
    PlayerClass := Byte.Parse(ParamStr(1));

    FileNameInput := ParamStr(2);

    if not FileExists(FileNameInput) then
      raise EFileNotFoundException.CreateFmt('File %s not found', [FileNameInput]);

    WriteLn('Input = ' + FileNameInput);
    FileNameOutput := Copy(FileNameInput, 1, 14) + '_' + IfThen(PlayerClass = 1, 'trapaca', 'legitimo') + '.csv';
    WriteLn('Output = ' + FileNameOutput);

    TimeSerie := TTimeSerie.Create(True);
    Input := TTelemetryCSVReader.Create(FileNameInput, TEncoding.ANSI, False, 32768);
    Output := TTimeSerieCSVWriter.Create(FileNameOutput, True, TEncoding.ANSI, 32768);
    try
      Input.OwnStream;
      Output.OwnStream;

      while not Input.EndOfStream do
      begin
        Telemetry := TTelemetry.Create;
        try
          Input.ReadTelemetry(Telemetry);

          if CheckIsValidTelemetry(Telemetry) then
          begin
            Moment := TimeSerie.AddNew;
            // Normalize values
            Moment.Speed := NormalMaxMin(Telemetry.Speed, 0.0, 347.0);
            Moment.Steer := NormalMaxMin(Telemetry.Steer, -1.0, 1.0);
            Moment.Gear := NormalMaxMin(Telemetry.Gear, -1, 8);
            Moment.TyreWearRL := Telemetry.TyresWearRearLeft / 100.0;
            Moment.TyreWearRR := Telemetry.TyresWearRearRight / 100.0;
            Moment.TyreWearFL := Telemetry.TyresWearFrontLeft / 100.0;
            Moment.TyreWearFR := Telemetry.TyresWearFrontRight / 100.0;

            if TimeSerie.Count = TIMESERIES_LENGTH then
            begin
              Output.WriteTimeSerie(TimeSerie);
              TimeSerie.Clear;

              TimeSerie.PlayerClass := PlayerClass;
            end;
          end;
        finally
          Telemetry.Free;
        end;
      end;
      Input.Close;
      Output.Close;
    finally
      Output.Free;
      Input.Free;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.

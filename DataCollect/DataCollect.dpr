program DataCollect;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Classes,
  System.SysUtils,
  IdGlobal,
  IdUDPClient,
  Packets in '..\Share\Packets.pas',
  Telemetries in '..\Share\Telemetries.pas',
  TimeSeries in '..\Share\TimeSeries.pas';

const
  VALIDATION_MODE: Boolean = False;

var
  History: TTelemetryHistory;

  function GetCurrentTelemetry(const APacketHeader: TPacketHeader; const APlayerIndex: Integer): TTelemetry;
  var
    Header: TTelemetryHeader;
  begin
    Header.SessionUID := APacketHeader.m_sessionUID;
    Header.SessionTime := APacketHeader.m_sessionTime;
    Header.FrameIdentifier := APacketHeader.m_frameIdentifier;
    Header.PlayerIndex := APlayerIndex;

    if APacketHeader.m_packetId = PACKET_LAP_ID then
      Exit(History.CreateNew(Header));

    if not History.SearchFor(Header, Result) then
      Exit(History.CreateNew(Header));
  end;

  procedure ProcessPacketSessionData(const APacketHeader: TPacketHeader; const ABuffer: TIdBytes);
  var
    SessionData: TPacketSessionData;
    PlayerIndex: Integer;
    Telemetry: TTelemetry;
  begin
    Move(ABuffer[0], SessionData, SizeOf(SessionData));

    for PlayerIndex := 0 to 21 do
    begin
      Telemetry := GetCurrentTelemetry(APacketHeader, PlayerIndex);
      Telemetry.SafetyCarStatus := SessionData.m_safetyCarStatus;
    end;
  end;

  procedure ProcessPacketLapData(const APacketHeader: TPacketHeader; const ABuffer: TIdBytes);
  var
    LapData: TPacketLapData;
    PlayerIndex: Integer;
    Telemetry: TTelemetry;
  begin
    Move(ABuffer[0], LapData, SizeOf(LapData));

    for PlayerIndex := 0 to 21 do
    begin
      Telemetry := GetCurrentTelemetry(APacketHeader, PlayerIndex);
      Telemetry.CurrentLapTimeInMS := LapData.m_lapData[PlayerIndex].m_currentLapTimeInMS;
      Telemetry.CurrentLapNum := LapData.m_lapData[PlayerIndex].m_currentLapNum;
      Telemetry.DriverStatus := LapData.m_lapData[PlayerIndex].m_driverStatus;
      Telemetry.ResultStatus := LapData.m_lapData[PlayerIndex].m_resultStatus;
    end;
  end;

  procedure ProcessPacketParticipantsData(const APacketHeader: TPacketHeader; const ABuffer: TIdBytes);
  var
    ParticipantsData: TPacketParticipantsData;
    PlayerIndex: Integer;
    Telemetry: TTelemetry;
  begin
    Move(ABuffer[0], ParticipantsData, SizeOf(ParticipantsData));

    for PlayerIndex := 0 to 21 do
    begin
      Telemetry := GetCurrentTelemetry(APacketHeader, PlayerIndex);
      Telemetry.AiControlled := ParticipantsData.m_participants[PlayerIndex].m_aiControlled;
      Telemetry.YourTelemetry := ParticipantsData.m_participants[PlayerIndex].m_yourTelemetry;
    end;
  end;

  procedure ProcessPacketCarTelemetryData(const APacketHeader: TPacketHeader; const ABuffer: TIdBytes);
  var
    CarTelemetryData: TPacketCarTelemetryData;
    PlayerIndex: Integer;
    Telemetry: TTelemetry;
  begin
    Move(ABuffer[0], CarTelemetryData, SizeOf(CarTelemetryData));

    for PlayerIndex := 0 to 21 do
    begin
      Telemetry := GetCurrentTelemetry(APacketHeader, PlayerIndex);
      Telemetry.Speed := CarTelemetryData.m_carTelemetryData[PlayerIndex].m_speed;
      Telemetry.Throttle := CarTelemetryData.m_carTelemetryData[PlayerIndex].m_throttle;
      Telemetry.Steer := CarTelemetryData.m_carTelemetryData[PlayerIndex].m_steer;
      Telemetry.Brake := CarTelemetryData.m_carTelemetryData[PlayerIndex].m_brake;
      Telemetry.Gear := CarTelemetryData.m_carTelemetryData[PlayerIndex].m_gear;
      Telemetry.Drs := CarTelemetryData.m_carTelemetryData[PlayerIndex].m_drs;

      if VALIDATION_MODE and (PlayerIndex = APacketHeader.m_playerCarIndex) then
        Writeln(Format('LapNum: %d / LapTime: %f / Speed: %f / Gear: %d', [Telemetry.CurrentLapNum, Telemetry.CurrentLapTimeInMS, Telemetry.Speed, Telemetry.Gear]));
    end;
  end;

  procedure ProcessPacketCarDamageData(const APacketHeader: TPacketHeader; const ABuffer: TIdBytes);
  var
    CarDamageData: TPacketCarDamageData;
    PlayerIndex: Integer;
    Telemetry: TTelemetry;
  begin
    Move(ABuffer[0], CarDamageData, SizeOf(CarDamageData));

    for PlayerIndex := 0 to 21 do
    begin
      Telemetry := GetCurrentTelemetry(APacketHeader, PlayerIndex);
      Telemetry.TyresWearRearLeft := CarDamageData.m_carDamageData[PlayerIndex].m_tyresWear[0];
      Telemetry.TyresWearRearRight := CarDamageData.m_carDamageData[PlayerIndex].m_tyresWear[1];
      Telemetry.TyresWearFrontLeft := CarDamageData.m_carDamageData[PlayerIndex].m_tyresWear[2];
      Telemetry.TyresWearFrontRight := CarDamageData.m_carDamageData[PlayerIndex].m_tyresWear[3];
    end;
  end;

  procedure ExportCSVPlayerTelemetry(const APlayerIndex: Integer);
  var
    FileName: string;
    Writer: TTelemetryCSVWriter;
    Telemetry: TTelemetry;
  begin
    FileName := 'C:\F123Data\f123telemetria_' + FormatDateTime('yyyymmddhhnnss', Now) + '_' + FormatFloat('00', APlayerIndex) + '.csv';
    Writer := TTelemetryCSVWriter.Create(FileName, True, TEncoding.ANSI, 32768);
    try
      for Telemetry in History do
        if Telemetry.Header.PlayerIndex = APlayerIndex then
          Writer.WriteTelemetry(Telemetry);
    finally
      Writer.Free;
    end;
  end;

  procedure ExportCSVTelemetries;
  var
    Comparer: TTelemetryComparer;
    PlayerIndex: Integer;
  begin
    Comparer := TTelemetryComparer.Create;
    try
      History.Sort(Comparer);
    finally
      Comparer.Free;
    end;

    for PlayerIndex := 0 to 21 do
      ExportCSVPlayerTelemetry(PlayerIndex);
  end;

var
  UDPClient: TIdUDPClient;
  Buffer: TIdBytes;
  PacketHeader: TPacketHeader;
begin
  try
    History := TTelemetryHistory.Create;
    UDPClient := TIdUDPClient.Create;
    try
      FormatSettings.DecimalSeparator := '.';
      FormatSettings.ThousandSeparator := ',';

      UDPClient.BufferSize := 2048;
      UDPClient.BoundIP := '127.0.0.1';
      UDPClient.BoundPort := 20777;
      UDPClient.Host := '127.0.0.1';
      UDPClient.Port := 20777;
      UDPClient.ReceiveTimeout := 60000;

      SetLength(Buffer, UDPClient.BufferSize);
      UDPClient.Active := True;
      while UDPClient.ReceiveBuffer(Buffer, -1) > 0 do
      begin
        Move(Buffer[0], PacketHeader, SizeOf(PacketHeader));

        case PacketHeader.m_packetId of
          PACKET_SESSION_ID: ProcessPacketSessionData(PacketHeader, Buffer);
          PACKET_LAP_ID: ProcessPacketLapData(PacketHeader, Buffer);
          PACKET_PARTICIPANTS_ID: ProcessPacketParticipantsData(PacketHeader, Buffer);
          PACKET_CARTELEMETRY_ID: ProcessPacketCarTelemetryData(PacketHeader, Buffer);
          PACKET_FINALCLASSIFICATION_ID: Break;
          PACKET_CARDAMAGE_ID: ProcessPacketCarDamageData(PacketHeader, Buffer);
        end;
      end;
      UDPClient.Active := False;

      ExportCSVTelemetries;
    finally
      UDPClient.Free;
      History.Free;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.

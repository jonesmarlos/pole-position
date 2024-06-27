unit TimeSeries;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections;

type

  TMoment = class
  public
    Speed: Extended;
    Throttle: Extended;
    Steer: Extended;
    Brake: Extended;
    Gear: Extended;
    DRS: Integer;
    TyreWearFR: Extended;
    TyreWearFL: Extended;
    TyreWearRR: Extended;
    TyreWearRL: Extended;
  end;

  TTimeSerie = class(TObjectList<TMoment>)
  public
    PlayerClass: Byte;

    function AddNew: TMoment; virtual;
  end;

  TTimeSerieCSVWriter = class(TStreamWriter)
  public
    procedure WriteTimeSerie(const ATimeSerie: TTimeSerie); virtual;
  end;


implementation

function TTimeSerie.AddNew;
begin
  Result := TMoment.Create;
  Self.Add(Result);
end;

procedure TTimeSerieCSVWriter.WriteTimeSerie(const ATimeSerie: TTimeSerie);
var
  Builder: TStringBuilder;
  Index: Integer;
begin
  Builder := TStringBuilder.Create;
  try
    Builder.Append(ATimeSerie.PlayerClass);
    for Index := 0 to Pred(ATimeSerie.Count) do
    begin
      Builder
        .Append(';').Append(FloatToStrF(ATimeSerie[Index].Speed, ffFixed, 18, 5).Replace(FormatSettings.ThousandSeparator, '', [rfReplaceAll]))
        .Append(';').Append(FloatToStrF(ATimeSerie[Index].Throttle, ffFixed, 18, 5).Replace(FormatSettings.ThousandSeparator, '', [rfReplaceAll]))
        .Append(';').Append(FloatToStrF(ATimeSerie[Index].Steer, ffFixed, 18, 5).Replace(FormatSettings.ThousandSeparator, '', [rfReplaceAll]))
        .Append(';').Append(FloatToStrF(ATimeSerie[Index].Brake, ffFixed, 18, 5).Replace(FormatSettings.ThousandSeparator, '', [rfReplaceAll]))
        .Append(';').Append(FloatToStrF(ATimeSerie[Index].Gear, ffFixed, 18, 5).Replace(FormatSettings.ThousandSeparator, '', [rfReplaceAll]))
        .Append(';').Append(FloatToStrF(ATimeSerie[Index].DRS, ffFixed, 18, 5).Replace(FormatSettings.ThousandSeparator, '', [rfReplaceAll]))
        .Append(';').Append(FloatToStrF(ATimeSerie[Index].TyreWearFR, ffFixed, 18, 5).Replace(FormatSettings.ThousandSeparator, '', [rfReplaceAll]))
        .Append(';').Append(FloatToStrF(ATimeSerie[Index].TyreWearFL, ffFixed, 18, 5).Replace(FormatSettings.ThousandSeparator, '', [rfReplaceAll]))
        .Append(';').Append(FloatToStrF(ATimeSerie[Index].TyreWearRR, ffFixed, 18, 5).Replace(FormatSettings.ThousandSeparator, '', [rfReplaceAll]))
        .Append(';').Append(FloatToStrF(ATimeSerie[Index].TyreWearRL, ffFixed, 18, 5).Replace(FormatSettings.ThousandSeparator, '', [rfReplaceAll]));
    end;

    Self.WriteLine(Builder.ToString);
  finally
    Builder.Free;
  end;
end;

end.

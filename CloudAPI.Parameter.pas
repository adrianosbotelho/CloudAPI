﻿unit CloudAPI.Parameter;

interface

uses
  CloudAPI.Types,
  System.Rtti;

type
  TcaParameter = record
  private
    FName: string;
    FValue: TValue;
    FParameterType: TcaParameterType;
    FIsRequired: Boolean;
    FDefaultValue: TValue;
  public
    function ValueAsString: string;
    function DefaultValueAsString: string;
    function IsDefaultParameter: Boolean;
    class function Create(const AName: string; const AValue, ADefaultValue: TValue;
      const AParameterType: TcaParameterType; AIsRequired: Boolean): TcaParameter; static;
  public
    property Name: string read FName write FName;
    property Value: TValue read FValue write FValue;
    property DefaultValue: TValue read FDefaultValue write FDefaultValue;
    property ParameterType: TcaParameterType read FParameterType write FParameterType;
    property IsRequired: Boolean read FIsRequired write FIsRequired;
  end;

implementation

uses
  CloudAPI.RequestArgument;

{ TcaParameter }

class function TcaParameter.Create(const AName: string; const AValue, ADefaultValue: TValue;
  const AParameterType: TcaParameterType; AIsRequired: Boolean): TcaParameter;
begin
  Result.Name := AName;
  Result.Value := AValue;
  Result.DefaultValue := ADefaultValue;
  Result.ParameterType := AParameterType;
  Result.IsRequired := AIsRequired;
end;

function TcaParameter.DefaultValueAsString: string;
begin
  Result := TcaRequestArgument.ConvertToString(DefaultValue);
end;

function TcaParameter.IsDefaultParameter: Boolean;
begin
  Result := ValueAsString = DefaultValueAsString;
end;

function TcaParameter.ValueAsString: string;
begin
  Result := TcaRequestArgument.ConvertToString(Value);
end;

end.

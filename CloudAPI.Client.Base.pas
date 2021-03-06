﻿unit CloudAPI.Client.Base;

interface

uses
  CloudAPI.Ext.MethodLimits,
  CloudAPI.IAuthenticator,
  CloudAPI.Parameter,
  CloudAPI.Request,
  CloudAPI.Response,
  System.Classes,
  System.Generics.Collections,
  System.JSON.Serializers,
  System.Net.HttpClient,
  System.Net.Mime,
  System.Net.URLClient,
  System.SysUtils;

type
  TCloudApiClientBase = class
  private
    FAuthenticator: IAuthenticator;
    FBaseUrl: string;
    FHttpClient: THTTPClient;
    FVersion: string;
    FDefaultParams: TList<TcaParameter>;
    FRequestLimitManager: TcaRequestLimitManager;
    FResponseStream: TStream;
  private
    class var FSerializer: TJsonSerializer;
  private
    function GetAuthenticator: IAuthenticator;
    function GetBaseUrl: string;
    procedure SetAuthenticator(const Value: IAuthenticator);
    procedure SetBaseUrl(const Value: string);
  protected
    procedure AuthenticateIfNeeded(ARequest: IcaRequest);
    function GetSerializer: TJsonSerializer;
    function InternalExecute(ARequest: IcaRequest): IcaResponseBase;
    procedure WriteLimitInfo(ARequest: IcaRequest);
    procedure DoOnLimit(const ATimeLimit: Int64);
  public
    constructor Create; overload;
    constructor Create(const ABaseUrl: string); overload;
    destructor Destroy; override;
{$REGION 'Property'}
    property Authenticator: IAuthenticator read GetAuthenticator write SetAuthenticator;
    property BaseUrl: string read GetBaseUrl write SetBaseUrl;
    property DefaultParams: TList<TcaParameter> read FDefaultParams;
    property HttpClient: THTTPClient read FHttpClient;
    property RequestLimitManager: TcaRequestLimitManager read FRequestLimitManager write FRequestLimitManager;
    property ResponseStream: TStream read FResponseStream write FResponseStream;
    property Version: string read FVersion;
    class property Serializer: TJsonSerializer read FSerializer;
{$ENDREGION}
  end;

implementation

uses
  CloudAPI.Types,
  System.Rtti,
  CloudAPI.Core.RequestBuilder;

{ TCloudApiClientBase }

procedure TCloudApiClientBase.AuthenticateIfNeeded(ARequest: IcaRequest);
begin
  if Assigned(FAuthenticator) then
    FAuthenticator.Authenticate(ARequest);
end;

constructor TCloudApiClientBase.Create;
begin
  FHttpClient := THTTPClient.Create;
  FHttpClient.UserAgent := 'CloudAPI for Delphi v 4.0.0';
  FHttpClient.ResponseTimeout := 5000;
  FSerializer := TJsonSerializer.Create;
  FDefaultParams := TList<TcaParameter>.Create;
  FRequestLimitManager := TcaRequestLimitManager.Create;
  FResponseStream := nil;
end;

constructor TCloudApiClientBase.Create(const ABaseUrl: string);
begin
  self.Create;
  FBaseUrl := ABaseUrl;
end;

destructor TCloudApiClientBase.Destroy;
begin
  FRequestLimitManager.Free;
  FDefaultParams.Free;
  FSerializer.Free;
  FHttpClient.Free;
  inherited;
end;

procedure TCloudApiClientBase.DoOnLimit(const ATimeLimit: Int64);
begin
  if ATimeLimit > 0 then
    if Assigned(FRequestLimitManager.OnLimit) then
      FRequestLimitManager.OnLimit(ATimeLimit);
end;

function TCloudApiClientBase.InternalExecute(ARequest: IcaRequest): IcaResponseBase;
var
  LHttpRequest: IHTTPRequest;
  LHttpResponse: IHTTPResponse;
  LRequestBuilder: TRequestBuilder;
  I: Integer;
begin
  if not Assigned(ARequest) then
    ARequest := TcaRequest.Create;
  AuthenticateIfNeeded(ARequest);
  for I := 0 to FDefaultParams.Count - 1 do
    ARequest.AddParam(FDefaultParams[I]);
  WriteLimitInfo(ARequest);
  ARequest.StartAt := Now;
  LRequestBuilder := TRequestBuilder.Create(self, ARequest);
  try
    LHttpRequest := LRequestBuilder.Build();
    LHttpResponse := FHttpClient.Execute(LHttpRequest, FResponseStream, LHttpRequest.Headers);
    Result := TcaResponseBase.Create(ARequest, LHttpRequest, LHttpResponse);
  finally
    LRequestBuilder.Free;
  end;
end;

function TCloudApiClientBase.GetAuthenticator: IAuthenticator;
begin
  Result := FAuthenticator;
end;

function TCloudApiClientBase.GetBaseUrl: string;
begin
  Result := FBaseUrl;
end;

function TCloudApiClientBase.GetSerializer: TJsonSerializer;
begin
  Result := FSerializer;
end;

procedure TCloudApiClientBase.SetAuthenticator(const Value: IAuthenticator);
begin
  FAuthenticator := Value;
end;

procedure TCloudApiClientBase.SetBaseUrl(const Value: string);
begin
  FBaseUrl := Value;
end;

procedure TCloudApiClientBase.WriteLimitInfo(ARequest: IcaRequest);
var
  LTotalWait: Int64;
begin
  LTotalWait := FRequestLimitManager.LocalWait(ARequest.LimitInfo.Name);
  DoOnLimit(LTotalWait);
  FRequestLimitManager.Add(ARequest.LimitInfo.Limit, ARequest.LimitInfo.Name, ARequest.LimitInfo.IsGlobal);
end;

end.

program ConsoleBot;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  TelegAPI.Bot,
  TelegAPI.Recesiver.Console,
  System.SysUtils,
  TelegAPI.Types;

procedure Main;
var
  LBot: ITelegramBot;
  LRecesiver: TtgRecesiverConsole;
  LStop: string;
  I: Integer;
begin
  LBot := CreateTelegramBot('283107814:AAF9VZC6TRv6qKmOMCsLFoI8SBlV_xFMI80');
  LRecesiver := TtgRecesiverConsole.Create(LBot);
  try
    LRecesiver.OnStart :=
      procedure
      begin
        Writeln('started');
      end;
    LRecesiver.OnStop :=
      procedure
      begin
        Writeln('stoped');
      end;
    LRecesiver.OnUpdate :=
      procedure(AUpd: ItgUpdate)
      begin
        Writeln(AUpd.message.From.Username, ': ', AUpd.message.Text);
        LBot.SendMessage(AUpd.message.Chat.ID, AUpd.message.Text);
      end;
//    LRecesiver.OnMessage :=
//      procedure(AMessage: ITgMessage)
//      begin
//        Writeln(AMessage.From.Username, ': ', AMessage.Text);
//        LBot.SendMessage(AMessage.Chat.ID, '345t6yu');
//      end;
    with LBot.GetMe do
    begin
      Writeln('Bot nick: ', Username);
    end;
    LRecesiver.IsActive := True;
    while LStop.ToLower.Trim <> 'exit' do
    begin
      Readln(LStop);
      if LStop.ToLower.Trim = 'stop' then
        LRecesiver.IsActive := False
      else if LStop.ToLower.Trim = 'start' then
        LRecesiver.IsActive := True;

    end;
  finally
    // LRecesiver.Free;
  end;
end;

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
    Main;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.message);
  end;

end.


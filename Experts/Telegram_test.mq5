#property strict

#include <Telegram.mqh>
//--- input parameters
input string InpChannelName="RiverBotSignals"; //"ForexSignalChannel";//Channel Name
input string InpToken="766819099:AAFZ0E51fbCcpHPuGeORCEpa3cVZykqDLko";//Token

//--- global variables
CCustomBot bot;
int macd_handle;
bool checked;
/*
string CurrPair[29] = { "GBPAUD", "GBPCAD", "GBPCHF", "GBPJPY", "GBPNZD", "GBPUSD",
 "EURGBP", "EURAUD", "EURCAD", "EURCHF", "EURJPY", "EURNZD", "EURUSD",
 "AUDCAD", "AUDCHF", "AUDJPY", "AUDNZD", "AUDUSD",
 "NZDJPY", "NZDUSD", "NZDCAD", "NZDCHF", "CADCHF", 
 "CADJPY" "CHFJPY", "USDCAD", "USDCHF", "USDJPY"};

 */
string CurrPair[28] = { "GBPAUD", "GBPCAD", "GBPCHF", "GBPJPY", "GBPNZD", "GBPUSD",
 "EURGBP", "EURAUD", "EURCAD", "EURJPY", "EURNZD", "EURUSD",
 "AUDCAD", "AUDCHF", "AUDJPY", "AUDNZD", "AUDUSD", 
 "NZDJPY", "NZDUSD", "NZDCAD", "NZDCHF", "CADCHF", "CADJPY",
 "CHFJPY", "USDCAD", "USDCHF", "USDJPY" };


int OnInit()
{

   bot.Token(InpToken);
   
   bot.SendMessage(-498343047,"test");
    
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(reason==REASON_PARAMETERS ||
      reason==REASON_RECOMPILE ||
      reason==REASON_ACCOUNT)
     {
      checked=false;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_KEYDOWN && 
      lparam=='Q')
     {
         
         bot.SendMessage(InpChannelName,"ee\nAt:100\nDDDD");
     }
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

   if(!checked) {
      if(StringLen(InpChannelName)==0) {
         Print("Error: Channel name is empty");
         Sleep(10000);
         return;
      }

      int result=bot.GetMe();
      if(result==0) {
         Print("Bot name: ",bot.Name());
         checked=true;
      }
      else {
         Print("Error: ",GetErrorDescription(result));
         Sleep(10000);
         return;
      }
   }


  }


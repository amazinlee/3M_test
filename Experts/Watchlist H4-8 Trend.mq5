#property strict

#include <Telegram.mqh>
#include "Trend.mqh"
#include <All Slope v1.5.mqh>
#include <River.mqh>
bool debug=false;

//--- input parameters
input string InpChannelName= "RiverBotSignals"; //Channel Name
input string InpToken="766819099:AAFZ0E51fbCcpHPuGeORCEpa3cVZykqDLko";//Token
//input int chat_id = -409741689;
input int chat_id = -483151043;

//--- global variables
CCustomBot bot;
int macd_handle;
datetime lastbar[2]={0,0};
bool checked;
int Total_Pairs=32;

/*
string CurrPair[6] = { "GBPAUD", "GBPCAD", "GBPCHF", "GBPJPY", "GBPNZD", "GBPUSD" };
*/

string CurrPair[32] = { "XAUUSD", "XAGUSD", "SPX500", "WTI", "BTCUSD",
 "GBPAUD", "GBPCAD", "GBPCHF", "GBPJPY", "GBPNZD", "GBPUSD",
 "EURGBP", "EURAUD", "EURCAD", "EURJPY", "EURNZD", "EURUSD",
 "AUDCAD", "AUDCHF", "AUDJPY", "AUDNZD", "AUDUSD", "NZDJPY",
 "NZDUSD", "NZDCAD", "NZDCHF", "CADCHF", "CADJPY", "CHFJPY",
 "USDCAD", "USDCHF", "USDJPY" };
 // 5,6,6,6,6,3  
 
int OnInit()
{
   //lastbar1=0;

   bot.Token(InpToken);
   
   bot.SendMessage(chat_id, "Start");
    
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
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam) {
  if(id==CHARTEVENT_KEYDOWN && lparam=='Q') {
    bot.SendMessage(chat_id,"ee\nAt:100\nDDDD");
  }
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
  if(!checked) {
    if(StringLen(chat_id)==0) {
       Print("Error: Channel name is empty");
       Sleep(10000);
       return;
    }
  
    int result=bot.GetMe();
    if(result==0) {
       //Print("Bot name: ",bot.Name());
       checked=true;
    }
    else {
       Print("Error: ",GetErrorDescription(result));
       Sleep(10000);
       return;
    }
  }

  ENUM_TIMEFRAMES TF1= PERIOD_H4;
  ENUM_TIMEFRAMES TF2= PERIOD_H8;
  datetime tm;
  string msg, sSignal;
  bool bTF1=false, bTF2=false;
  //check for new bar for two timeframe
  bTF1=IsNewBar1(Symbol(),TF1);
  bTF2=IsNewBar2(Symbol(),TF2);
  
  //only if one of the TF has a new bar then we do
  if (bTF1 || bTF2) {
  Sleep (5000); //need to wait for multi TF, if not there will be issues
   tm=iTime(_Symbol,0,1); //EA is loaed on the lowest TF, will display the prev bar closed.
      //First TF, first sig
      if (bTF1) {
        for (int i=0;i<Total_Pairs;i++) {    //check for each symbol
          sSignal=Signals(CurrPair[i], TF1);
          if (sSignal!="") {
            StringConcatenate(msg,msg,sSignal);
          }
        }//for loop multi pairs
      }//if bTF1
      //second TF
      if (bTF2) {
        for (int i=0;i<Total_Pairs;i++) {    //check for each symbol
          sSignal=Signals(CurrPair[i], TF2);
          if (sSignal!="") {
            StringConcatenate(msg,msg,sSignal);
          }
        }//for loop for symbols
      } //if second TF    
  }//new bar in any of the TFs
  if (msg!=NULL) {
    //add timestamp heading to the text
    string sTime= StringFormat("%s\n", TimeToString(tm));  //previous bar close is the signal bar
    StringConcatenate(msg, sTime, msg);
    int res=bot.SendMessage(chat_id,msg);         
  }
  
} //OnTick

string Signals(string sCurr, ENUM_TIMEFRAMES TF) {
  string msg="", sSignal="";
  
  sSignal=fnTrend(sCurr, TF);
  if (sSignal!="") {        //found a signal return either up or down, if empty skip
    sSignal= "Trend " + sSignal;
    string sRes=StringFormat("%s %s %s\n",
                            sCurr,
                            StringSubstr(EnumToString(TF),7),
                            sSignal);
                            
    StringConcatenate(msg, msg, sRes);
  }

  return msg;
}

bool IsNewBar1(const string symbol, const ENUM_TIMEFRAMES period)
{
  bool isNewBar = false;
  static datetime priorBarOpenTime = NULL;
  // New Bar event handler -> per https://www.mql5.com/en/articles/159
  // SERIES_LASTBAR_DATE == Open time of the last bar of the symbol-period
  const datetime currentBarOpenTime = (datetime) SeriesInfoInteger(symbol,period,SERIES_LASTBAR_DATE);
  if( priorBarOpenTime != currentBarOpenTime )
  {
    // Don't want new bar just because EA started
    //if ( priorBarOpenTime == NULL ) { isNewBar = false; }            
    isNewBar = true;
    
    // Regardless of new bar, update the held bar time
    priorBarOpenTime = currentBarOpenTime;
  }
  return isNewBar;
}

bool IsNewBar2(const string symbol, const ENUM_TIMEFRAMES period)
{
  bool isNewBar = false;
  static datetime priorBarOpenTime2 = NULL;
  // New Bar event handler -> per https://www.mql5.com/en/articles/159
  // SERIES_LASTBAR_DATE == Open time of the last bar of the symbol-period
  const datetime currentBarOpenTime2 = (datetime) SeriesInfoInteger(symbol,period,SERIES_LASTBAR_DATE);
  if( priorBarOpenTime2 != currentBarOpenTime2 )
  {
    // Don't want new bar just because EA started
    //if ( priorBarOpenTime2 == NULL ) { isNewBar = false; }            
    isNewBar = true;
    // isNewBar = ( priorBarOpenTime2 == NULL )?false:true;  // priorBarOpenTime2 is only NULL once
//Print("newbar2 is true " ,priorBarOpenTime2, " ", currentBarOpenTime2);
    // Regardless of new bar, update the held bar time
    priorBarOpenTime2 = currentBarOpenTime2;
  }
  return isNewBar;
}

bool IsNewBar3(const string symbol, const ENUM_TIMEFRAMES period)
{
  bool isNewBar = false;
  static datetime priorBarOpenTime3 = NULL;
  // New Bar event handler -> per https://www.mql5.com/en/articles/159
  // SERIES_LASTBAR_DATE == Open time of the last bar of the symbol-period
  const datetime currentBarOpenTime3 = (datetime) SeriesInfoInteger(symbol,period,SERIES_LASTBAR_DATE);
  if( priorBarOpenTime3 != currentBarOpenTime3 )
  {
    // Don't want new bar just because EA started
    //if ( priorBarOpenTime3 == NULL ) { isNewBar = false; }            
    isNewBar = true;
    // isNewBar = ( priorBarOpenTime3 == NULL )?false:true;  // priorBarOpenTime3 is only NULL once
    // Regardless of new bar, update the held bar time
    priorBarOpenTime3 = currentBarOpenTime3;
  }
  return isNewBar;
}
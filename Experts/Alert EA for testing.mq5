#property strict

#include <Telegram.mqh>
#include "NearMA MA Slope Include.mqh"
//--- input parameters
input string InpToken="766819099:AAFZ0E51fbCcpHPuGeORCEpa3cVZykqDLko";//Token
input int chat_id= -473189315;

//--- global variables
CCustomBot bot;
datetime lastbar[2]={0,0};
bool checked;

/*
string CurrPair[6] = { "GBPAUD", "GBPCAD", "GBPCHF", "GBPJPY", "GBPNZD", "GBPUSD" };
*/

string CurrPair[28] = { "XAUUSD", "GBPAUD", "GBPCAD", "GBPCHF", "GBPJPY", "GBPNZD", "GBPUSD",
 "EURGBP", "EURAUD", "EURCAD", "EURJPY", "EURNZD", "EURUSD",
 "AUDCAD", "AUDCHF", "AUDJPY", "AUDNZD", "AUDUSD", 
 "NZDJPY", "NZDUSD", "NZDCAD", "NZDCHF", "CADCHF", "CADJPY",
 "CHFJPY", "USDCAD", "USDCHF", "USDJPY" };
 

int OnInit()
{
   //lastbar1=0;

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

  ENUM_TIMEFRAMES TF1= PERIOD_H1;
 
  datetime tm;
  string msg, sSignal;
  bool bTF1=false, bTF2=false, bTF3=false;
  //check for new bar for two timeframe
  //Sleep(5000);
  bTF1=IsNewBar1(Symbol(),TF1);
  //only if one of the TF has a new bar then we do
  if (bTF1) {
  //Sleep (5000);
   tm=iTime(_Symbol,0,1); //EA is loaed on the lowest TF, will display the prev bar closed.
    //First TF, first sig
    if (bTF1) {
      sSignal=Signals(Symbol(), TF1);
      if (sSignal!="") {
        StringConcatenate(msg,msg,sSignal);
      }
    }
  }//new bar in any of the TFs
  //add timestamp heading to the text
  if (msg!=NULL) {
    string sTime= StringFormat("%s\n", TimeToString(tm));  //previous bar close is the signal bar
    StringConcatenate(msg, sTime, msg);
    int res=bot.SendMessage(chat_id,msg);         
  }
  
} //OnTick

string Signals(string sCurr, ENUM_TIMEFRAMES TF) {
  string msg="", sSignal="";
/*  
  sSignal=BW(sCurr, TF);
  if (sSignal!="") {        //found a signal return either up or down, if empty skip
    sSignal= "BW " + sSignal;
    string sRes=StringFormat("%s %s %s\n",
                            sCurr,
                            StringSubstr(EnumToString(TF),7),
                            sSignal);
                            
    StringConcatenate(msg, msg, sRes);
  } //BW
*/
  //First TF, second sig
  sSignal=NearMA(sCurr, TF);
  if (sSignal!="") {  
    sSignal= "NearMA " + sSignal;   
    string sRes=StringFormat("%s %s %s\n",
                            sCurr,
                            StringSubstr(EnumToString(TF),7),
                            sSignal);
                            
    StringConcatenate(msg, msg, sRes);
  }
  Print(msg);
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

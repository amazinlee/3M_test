#include <River.mqh>
#include <Telegram.mqh>
#include <3M Include.mqh>
#include <Common.mqh>
#include <TradeTransaction.mqh>

bool debug=false;
bool debugEA=false;
//--- input parameters
input string InpToken="766819099:AAFZ0E51fbCcpHPuGeORCEpa3cVZykqDLko";//Token
input int chat_id= -950027962;
//input int chat_id= -252783614; //test


//--- global variables
CCustomBot bot;
datetime lastbar[2]={0,0};
bool checked;
static int Total_Pairs=33;

/*
string CurrPair[6] = { "GBPAUD", "GBPCAD", "GBPCHF", "GBPJPY", "GBPNZD", "GBPUSD" };
*/

string CurrPair[34] = { "XAUUSD", "XAGUSD", "WTI", "US100", "ETHUSD", "BTCUSD",
 "GBPAUD", "GBPCAD", "GBPCHF", "GBPJPY", "GBPNZD", "GBPUSD",
 "EURGBP", "EURAUD", "EURCAD", "EURJPY", "EURNZD", "EURUSD",
 "AUDCAD", "AUDCHF", "AUDJPY", "AUDNZD", "AUDUSD", "NZDJPY",
 "NZDUSD", "NZDCAD", "NZDCHF", "CADCHF", "CADJPY", "CHFJPY",
 "USDCAD", "USDCHF", "USDJPY" };
 // 6,6,6,6,6,3  

int OnInit()
{
   //lastbar1=0;

   bot.Token(InpToken);
   //bot.SendMessage(chat_id, "start");
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
  bool bTF1=false, bTF2=false, bTF3=false;
  //check for new bar for two timeframe
  bTF1=IsNewBar1(Symbol(),TF1);
  bTF2=IsNewBar2(Symbol(),TF2);
  //only if one of the TF has a new bar then we do
  //only if one of the TF has a new bar then we do
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
    msg=StringFormat("%s\n", msg); //return carriage for second TF
    for (int i=0;i<Total_Pairs;i++) {    //check for each symbol
      sSignal=Signals(CurrPair[i], TF2);
      if (sSignal!="") {
        StringConcatenate(msg,msg,sSignal);
      }
    }//for loop for symbols
  } //if second TF   */   
  if (!(msg==NULL)) {
    //add timestamp heading to the text
    string sTime= StringFormat("%s\n", TimeToString(tm));  //previous bar close is the signal bar
    StringConcatenate(msg, sTime, msg);
    int res=bot.SendMessage(chat_id,msg);         
  }
  
} //OnTick

string Signals(string sCurr, ENUM_TIMEFRAMES TF) {
  string msg="", sSignal="";
    
  sSignal=ThreeM(sCurr, TF);
  if (sSignal!="") {        //found a signal return either up or down, if empty skip
    //sSignal= "3M " + sSignal;
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
  const datetime currentBarOpenTime = iTime(symbol, period, 0);
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
  const datetime currentBarOpenTime2 = iTime(symbol, period, 0);
  if( priorBarOpenTime2 != currentBarOpenTime2 )
  {
    // Don't want new bar just because EA started
    //if ( priorBarOpenTime2 == NULL ) { isNewBar = false; }            
    isNewBar = true;
    // isNewBar = ( priorBarOpenTime2 == NULL )?false:true;  // priorBarOpenTime2 is only NULL once
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
  const datetime currentBarOpenTime3 = iTime(symbol, period, 0);
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
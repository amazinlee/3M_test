//+------------------------------------------------------------------+
//|                                                         test.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//#include "NearMA Include.mqh"
#include "NearMA MA Slope Include.mqh"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
  return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
    if (IsNewBar(Symbol(),Period())) {
      //Print(rates[2].time, " ", rates[1].time);
      double ATRBuffer[];
      int ATR_handle=iATR(_Symbol,0,21);
      MqlRates rates[];
      CopyRates(Symbol(),0,0,2,rates);
      CopyBuffer(ATR_handle,0,0,2,ATRBuffer);
      double arrowbuffer = 0.6*ATRBuffer[0];

      string sRes=NearMA(Symbol(), Period());
      if (sRes=="Up") {
        string name= "up"+TimeToString(iTime(NULL,0,1));
        ObjectCreate(0,name,OBJ_ARROW_UP,0,iTime(NULL,0,1), rates[0].low-arrowbuffer);
        ObjectSetInteger(0,name,OBJPROP_COLOR,clrLime);
        ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
      }
      
      if (sRes=="Down") {
        string name= "down"+TimeToString(iTime(NULL,0,1));  
        ObjectCreate(0,name,OBJ_ARROW_DOWN,0,iTime(NULL,0,1), rates[0].high+arrowbuffer);
        ObjectSetInteger(0,name,OBJPROP_COLOR,clrRed);
        ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
      }    
    } //new bar
     
  }


double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+

bool IsNewBar(const string symbol, const ENUM_TIMEFRAMES period)
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
    // isNewBar = ( priorBarOpenTime == NULL )?false:true;  // priorBarOpenTime is only NULL once

    // Regardless of new bar, update the held bar time
    priorBarOpenTime = currentBarOpenTime;
  }
  
  return isNewBar;
}
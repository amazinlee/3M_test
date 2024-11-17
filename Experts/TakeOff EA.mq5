#include <River.mqh>
#include <TakeOff Include.mqh>
#include <Common.mqh>
#include <Trade\Trade.mqh>
//#include <4M close together Include.mqh>
bool debug=false;

input float SLfactor=1.4;
input float TPfactor=1.8;

CTrade  trade;
CPositionInfo position;

datetime dtSigUp=0, dtSigDown=0; //for prevent subsequent signals  

int OnInit()
  {
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   
  }

void OnTick() {
  if (!IsNewBar(_Symbol,0)) return;
  
  string sRes;
  float atr;
  double ATRBuffer[];
  int ATR_handle=iATR(_Symbol,0,21), iPreventSig=4;
  
  
  MqlRates rates[];
  CopyRates(Symbol(),0,0,5,rates);
  CopyBuffer(ATR_handle,0,0,2,ATRBuffer);
  double arrowbuffer = 0.6*ATRBuffer[0];  
  
  sRes=TakeOff(_Symbol,0, iPreventSig, atr);

  double bid=SymbolInfoDouble(NULL,SYMBOL_BID);             // current price for closing LONG
  double ask=SymbolInfoDouble(NULL,SYMBOL_ASK);
  double SL=SLfactor*atr;                                     // unnormalized SL value
  double TP=TPfactor*atr;                                     // unnormalized SL value

Print("EA Time: ", rates[0].time," Results: ", sRes);
  if (sRes=="Up") {
    string name= "arrow"+TimeToString(iTime(NULL,0,1));
    ObjectCreate(0,name,OBJ_ARROW,0,rates[0].time,rates[0].low-arrowbuffer);
    ObjectSetInteger(0,name,OBJPROP_ARROWCODE,159);  //233
    ObjectSetInteger(0,name,OBJPROP_COLOR,clrLime);
    ObjectSetInteger(0,name,OBJPROP_WIDTH,1);  
    Print("Up Time: ", rates[0].time);
  }

  
  if (sRes=="Down") {
    //Print(rates[0].time);
    string name= "arrow"+TimeToString(iTime(NULL,0,1));
    ObjectCreate(0,name,OBJ_ARROW,0,rates[0].time,rates[0].low+arrowbuffer);
    ObjectSetInteger(0,name,OBJPROP_ARROWCODE,159);  //233
    ObjectSetInteger(0,name,OBJPROP_COLOR,clrCrimson);
    ObjectSetInteger(0,name,OBJPROP_WIDTH,1);  

  
  }    
  if (sRes!=NULL) {
    //Print("results: ", sRes);
    if (!position.Select(_Symbol)) {
      //if (sRes=="Up") trade.Buy(0.1,NULL,ask,bid-SL,bid+TP);
      //if (sRes=="Down") trade.Sell(0.1,NULL,bid,bid+SL,bid-TP);
    }   
  }
}

void CreateArrow() {


}

void OnTrade()
  {

   
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

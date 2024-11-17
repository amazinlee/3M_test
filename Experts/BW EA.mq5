#include <River.mqh>
#include <BW Include.mqh>
#include <Common.mqh>
#include <Trade\Trade.mqh>
//#include <4M close together Include.mqh>
bool debug=false;

float TPfactor=1.5,SLfactor=1.2;

CTrade  trade;
CPositionInfo position;


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
  double atr;
  int iSignal=0, iPreventSig=0;
  
  sRes=BW(_Symbol,0, atr);

  double bid=SymbolInfoDouble(NULL,SYMBOL_BID);             // current price for closing LONG
  double ask=SymbolInfoDouble(NULL,SYMBOL_ASK);
  double SL=SLfactor*atr;                                     // unnormalized SL value
  double TP=TPfactor*atr;                                     // unnormalized SL value

  //trade signal appeared
  if (sRes!=NULL || sRes!="") {
    if (!position.Select(_Symbol)) {
      if (dtSigUp==0 ||  Bars(_Symbol,0,dtSigUp,iTime(_Symbol,0,1))>iPreventSig) { //must be more than 10 bars past before a new signal starts     
        if (sRes=="Up") trade.Buy(0.1,NULL,ask,bid-SL,bid+TP);
        dtSigUp=iTime(_Symbol,0,1);
      }
      if (dtSigDown==0 ||  Bars(_Symbol,0,dtSigDown,iTime(_Symbol,0,1))>iPreventSig) { //must be more than 10 bars past before a new signal starts     
        if (sRes=="Down") trade.Sell(0.1,NULL,bid,bid+SL,bid-TP);
        dtSigDown=iTime(_Symbol,0,1);
      }
    }   
  }
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

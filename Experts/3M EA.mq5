#include <River.mqh>
#include <3M Include.mqh>
#include <Common.mqh>
#include <Trade\Trade.mqh>
#include <TradeTransaction.mqh>
#include <Trade\DealInfo.mqh>

bool debugEA=true, debug=false;

CTrade  trade;
CPositionInfo position;
CExtTransaction m_Trans;
CDealInfo      m_deal;

string sOutput;

float TPfactor=1.5,SLfactor=1.0;
int OnInit() {
  return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {}


void OnTick() {
  if (!IsNewBar(_Symbol,0)) return;
  
  string sRes;
  int iSignal=0, iPreventSig=0;
  
  sRes=ThreeM(_Symbol,0); //PERIOD_CURRENT
  
  double bid=SymbolInfoDouble(NULL,SYMBOL_BID);             // current price for closing LONG
  double ask=SymbolInfoDouble(NULL,SYMBOL_ASK);
  double SL=SLfactor*val.atr;                                     // unnormalized SL value
  double TP=TPfactor*val.atr;                                     // unnormalized SL value
  string sTicket;
  bool bTrade=false;
  //trade signal appeared
  if (sRes!="") {
    if (!position.Select(_Symbol)) {
      if (dtSigUp==0 ||  Bars(_Symbol,0,dtSigUp,iTime(_Symbol,0,1))>iPreventSig) { //must be more than 10 bars past before a new signal starts     
        if (sRes=="Up") trade.Buy(0.1,NULL,ask,bid-SL,bid+TP);
        dtSigUp=iTime(_Symbol,0,1);
        bTrade=true;
      }
      if (dtSigDown==0 ||  Bars(_Symbol,0,dtSigDown,iTime(_Symbol,0,1))>iPreventSig) { //must be more than 10 bars past before a new signal starts     
        if (sRes=="Down") trade.Sell(0.1,NULL,bid,bid+SL,bid-TP);
        dtSigDown=iTime(_Symbol,0,1);
        bTrade=true;
      }
    }
    //printf("tradeID----"+trade.ResultOrder());
    //if (debugEA && bTrade && trade.ResultOrder()!=0) sOutput=val.sValues;
    if (debugEA && bTrade) sOutput=val.sValues+", ";
    bTrade=false; //reset
  } //if have sig
}//OnTick

void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result) {

  m_Trans.OnTradeTransaction(trans,request,result);
  if (IS_TRANSACTION_POSITION_STOP_TAKE) {  
    m_deal.Ticket(m_Trans.dealID);
    printf("posID " +m_deal.PositionId() +" profit: "+m_deal.Profit());
    if (debugEA) WriteToFile(sOutput+RoundN(m_deal.Profit())+"\n"); 
  }
}


double OnTester() {

  double ret=0.0;
  
  return(ret);
}


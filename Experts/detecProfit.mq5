//+------------------------------------------------------------------+
//|                             Last Deal Take Profit activation.mq5 |
//|                              Copyright © 2020, Vladimir Karputov |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2020, Vladimir Karputov"
/*
   barabashkakvn Trading engine 3.143
*/
#include <Trade\DealInfo.mqh>
//---
CDealInfo      m_deal;                       // object of CDealInfo class
//--- input parameters
input int      Input1=9;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result) {

//--- get transaction type as enumeration value
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;
//--- if transaction is result of addition of the transaction in history
   if(type==TRADE_TRANSACTION_DEAL_ADD)
     {
      ResetLastError();
      if(HistoryDealSelect(trans.deal))
         m_deal.Ticket(trans.deal);
      else
        {
         Print(__FILE__," ",__FUNCTION__,", ERROR: ","HistoryDealSelect(",trans.deal,") error: ",GetLastError());
         return;
        }
      if(m_deal.DealType()==DEAL_TYPE_BUY || m_deal.DealType()==DEAL_TYPE_SELL)
        {
         if(m_deal.Entry()==DEAL_ENTRY_OUT)
           {
            long deal_reason=-1;
            if(m_deal.InfoInteger(DEAL_REASON,deal_reason)==DEAL_REASON_TP)
              {
               long position_id=m_deal.PositionId();
               if(HistorySelectByPosition(position_id))
                 {
                  printf("pos: " + position_id);
                  uint     total = HistoryDealsTotal();
                  ulong    ticket= 0;
                  //--- for all deals
                  for(uint i=0; i<total; i++)
                    {
                     //--- try to get deals ticket
                     if((ticket=HistoryDealGetTicket(i))>0)
                       {
                        //--- get deals properties
                        long     lng_time=HistoryDealGetInteger(ticket,DEAL_TIME);
                        datetime dat_time=(datetime)lng_time;
                        long     entry    = HistoryDealGetInteger(ticket,DEAL_ENTRY);
                        //long     type     = HistoryDealGetInteger(ticket,DEAL_TYPE);
                        double   volume   =HistoryDealGetDouble(ticket,DEAL_VOLUME);
                        double   price    = HistoryDealGetDouble(ticket,DEAL_PRICE);
                        Print(dat_time,", ",DoubleToString(price,8));
                       }
                    }
                 }
              }
           }
        }
     }
}

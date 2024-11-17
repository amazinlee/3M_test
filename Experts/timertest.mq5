//+------------------------------------------------------------------+
//|                                               OnTimer_Sample.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "Example of using the timer for calculating the trading server time"
#property description "It is recommended to run the EA at the end of a trading week before the weekend"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create a timer with a 1 second period
   EventSetTimer(5);
 
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy the timer after completing the work
   EventKillTimer();
 
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
 
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//--- time of the OnTimer() first call
   static datetime start_time=TimeCurrent();
//--- trade server time during the first OnTimer() call
   static datetime start_tradeserver_time=0;
//--- calculated trade server time
   static datetime calculated_server_time=0;
//--- local PC time
   datetime local_time=TimeLocal();
//--- current estimated trade server time
   datetime trade_server_time=TimeTradeServer();
//--- if a server time is unknown for some reason, exit ahead of time
   if(trade_server_time==0)
      return;
//--- if the initial trade server value is not set yet
   if(start_tradeserver_time==0)
     {
      start_tradeserver_time=trade_server_time;
      //--- set a calculated value of a trade server      
      Print(trade_server_time);
      calculated_server_time=trade_server_time;
     }
   else
     {
      //--- increase time of the OnTimer() first call
      if(start_tradeserver_time!=0)
         calculated_server_time=calculated_server_time+1;;
     }
//--- 
   string com=StringFormat("                  Start time: %s\r\n",TimeToString(start_time,TIME_MINUTES|TIME_SECONDS));
   com=com+StringFormat("                  Local time: %s\r\n",TimeToString(local_time,TIME_MINUTES|TIME_SECONDS));
   com=com+StringFormat("TimeTradeServer time: %s\r\n",TimeToString(trade_server_time,TIME_MINUTES|TIME_SECONDS));
   com=com+StringFormat(" EstimatedServer time: %s\r\n",TimeToString(calculated_server_time,TIME_MINUTES|TIME_SECONDS));
//--- display values of all counters on the chart
   Comment(com);
  }
//+------------------------------------------------------------------+
//|                                            OnNewBarCalculate.mqh |
//|                                            Copyright 2010, Lizar |
//|                                                    Lizar@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, Lizar"
#property link      "Lizar@mail.ru"

#include <LibCisNewBar.mqh>
CisNewBar current_chart; // CisNewBar class instance (used for the current chart)
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- seconds of the chart timeframe
   int period_seconds=PeriodSeconds(_Period);
//--- open time of the bar on the current chart
   datetime new_time=TimeCurrent()/period_seconds*period_seconds;

//--- when the new bar has appeared, call NewBar event handler
   if(current_chart.isNewBar(new_time))
      OnNewBarCalculate(rates_total,prev_calculated,time,open,high,low,close,tick_volume,volume,spread);
   return(rates_total);
  }


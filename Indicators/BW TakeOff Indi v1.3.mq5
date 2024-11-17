#include <River.mqh>
#include <BW TakeOff Include.mqh>

#property   indicator_buffers 2
#property   indicator_plots   2
//--- plot Arrows

#property indicator_type1  DRAW_ARROW
#property indicator_color1 clrLime  

#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrCrimson

bool debug=false;
datetime StartDt=D'2022.07.18 11:00'; 
//datetime StartDt=D'2022.02.22 04:00';
datetime EndDt;

//--- input parameters
int MaxBars = 10000;

//ATR factor set to 3 to catch the recent ATF, so more buffer for volatility
//input int MinUpDown = 2;t 
//--- An indicator buffer for the plot
double Up1[],Down1[];

// Declare Indicator handles
int ATR_handle=iATR(Symbol(),0,ATR_Factor);
int EMA5_handle=iMA(Symbol(),0,5,0,MODE_EMA,PRICE_CLOSE);
int SMA8_handle=iMA(Symbol(),0,8,0,MODE_SMA,PRICE_CLOSE);
int EMA13_handle=iMA(Symbol(),0,13,0,MODE_EMA,PRICE_CLOSE);
int SMA21_handle=iMA(Symbol(),0,21,0,MODE_SMA,PRICE_CLOSE);
int SMA42_handle=iMA(Symbol(),0,42,0,MODE_SMA,PRICE_CLOSE);
int SMA63_handle=iMA(Symbol(),0,63,0,MODE_SMA,PRICE_CLOSE);
int SMA84_handle=iMA(Symbol(),0,84,0,MODE_SMA,PRICE_CLOSE);
int SMA126_handle=iMA(Symbol(),0,126,0,MODE_SMA,PRICE_CLOSE);
int SMA168_handle=iMA(Symbol(),0,168,0,MODE_SMA,PRICE_CLOSE);
int SMA252_handle=iMA(Symbol(),0,252,0,MODE_SMA,PRICE_CLOSE);
int SMA336_handle=iMA(Symbol(),0,336,0,MODE_SMA,PRICE_CLOSE);
int SMA630_handle=iMA(Symbol(),0,630,0,MODE_SMA,PRICE_CLOSE);

int start;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0, Up1, INDICATOR_DATA);
   SetIndexBuffer(1, Down1, INDICATOR_DATA);
   
   //Setting the Buffer 0 to draw down arrow
   PlotIndexSetInteger(0,PLOT_ARROW,159);
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,35);

   //Setting the Buffer 0 to draw down arrow
   PlotIndexSetInteger(1,PLOT_ARROW,159);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,-35);



   return(INIT_SUCCEEDED);
  }
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
                const int &spread[] ) 
{
  //if (rates_total == prev_calculated) return(-1); //for backtest only, need to take out for live chart
  static datetime LastBar;
  if(LastBar==iTime(Symbol(),0,0)) return(-1);  //stop indicator from calculating current bar
  else LastBar=iTime(Symbol(),0,0);

  int iToCopy;
  if(prev_calculated>rates_total || prev_calculated<=0)
    iToCopy=rates_total;
  else
   {
    iToCopy=rates_total-prev_calculated;
    if(prev_calculated>0)
       iToCopy++;
   }
  int limit=MaxBars;
  if (limit+LookBackBuffer_TakeOff>rates_total) {
    limit=rates_total-LookBackBuffer_TakeOff;
  }
  if (limit<0) return 0; //too little bars, we exit
  
  if(prev_calculated==0){
    ArrayInitialize(Up1,0);
    ArrayInitialize(Down1,0);
    start = rates_total-limit; //limited total no of bars to calc. 
  } 
  else {
    start=prev_calculated-1;
  }
  CopyRates(NULL,0,0,iToCopy,rates);

  CopyBuffer(ATR_handle,0,0,iToCopy,ATR);
  CopyBuffer(EMA5_handle,0,0,iToCopy,EMA5);
  CopyBuffer(SMA8_handle,0,0,iToCopy,SMA8);
  CopyBuffer(EMA13_handle,0,0,iToCopy,EMA13);
  CopyBuffer(SMA21_handle,0,0,iToCopy,SMA21);
  CopyBuffer(SMA42_handle,0,0,iToCopy,SMA42);
  CopyBuffer(SMA63_handle,0,0,iToCopy,SMA63);
  CopyBuffer(SMA84_handle,0,0,iToCopy,SMA84);
  CopyBuffer(SMA126_handle,0,0,iToCopy,SMA126);
  CopyBuffer(SMA168_handle,0,0,iToCopy,SMA168);
  CopyBuffer(SMA252_handle,0,0,iToCopy,SMA252);
  CopyBuffer(SMA336_handle,0,0,iToCopy,SMA336);
  CopyBuffer(SMA630_handle,0,0,iToCopy,SMA630);

  string sRes="";
  for(int i = start; i < rates_total-1 && !IsStopped(); i++) {  //don't include the current bar rates_total-1 is the current bar.
    double arrowbuffer = 2.1*ATR[i];
    //plot dots on the chart to indicate positive or negative scoring of al the MA slopes add up
    EndDt = StartDt + 2*PeriodSeconds(Period()); //end date for debug
    //EndDt= D'2022.06.17 11:00';
    if (debug) {   
      if (time[i]> StartDt && time[i] < EndDt ) {
        Print("Debug: ", Symbol()," ", time[i]);
        sRes=fnTakeOff(i, Symbol());
        if (sRes=="Up") {  //check for signal
          Up1[i] = SMA8[i] - arrowbuffer;
        }
        //if (sRes=="") sRes = fnTakeOff(i); //check for down signal if it was not up signal
        if (sRes=="Down") {  //check for signal
          Down1[i] =  SMA8[i] + arrowbuffer;
        }
      }// specific period for debug
    }//debug
    else {
      sRes=fnTakeOff(i, Symbol());
      if (sRes=="Up") {
        Up1[i] = SMA8[i] - arrowbuffer;
      }  
      if (sRes=="Down") {
        Down1[i] =  SMA8[i] + arrowbuffer;
      }
    } //else if not debug
  } //for loop
  return(rates_total);
}
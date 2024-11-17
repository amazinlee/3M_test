#include <River.mqh>
#include <3M Include.mqh>

#property   indicator_buffers 6
#property   indicator_plots   6
//--- plot Arrows

#property indicator_type1  DRAW_ARROW
#property indicator_color1 clrLime

#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrDeepPink

#property indicator_type3  DRAW_ARROW
#property indicator_color3 clrBlue

#property indicator_type4  DRAW_ARROW
#property indicator_color4 clrCrimson

bool debugEA=false, debug1=true;
datetime StartDt=
D'2024.10.17 23:00';
//datetime StartDt=InputDt-PeriodSeconds(Period());
//datetime EndDt = D'2023.05.01 00:00';
datetime EndDt;
CValues value;

//--- input parameters
int MaxBars = 25000;

//ATR factor set to 3 to catch the recent ATF, so more buffer for volatility
//input int MinUpDown = 2;t 
//--- An indicator buffer for the plot
double Up1[],Down1[],Up2[],Down2[];

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

int start;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0, Up1, INDICATOR_DATA);
   SetIndexBuffer(1, Down1, INDICATOR_DATA);
   SetIndexBuffer(2, Up2, INDICATOR_DATA);
   SetIndexBuffer(3, Down2, INDICATOR_DATA);
   
   //Setting the Buffer 0 to draw down arrow
   PlotIndexSetInteger(0,PLOT_ARROW,159);
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,39);

   //Setting the Buffer 0 to draw down arrow
   PlotIndexSetInteger(1,PLOT_ARROW,159);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,-39);

   PlotIndexSetInteger(2,PLOT_ARROW,159);
   PlotIndexSetInteger(2,PLOT_ARROW_SHIFT,40);

   //Setting the Buffer 0 to draw down arrow
   PlotIndexSetInteger(3,PLOT_ARROW,159);
   PlotIndexSetInteger(3,PLOT_ARROW_SHIFT,-40);

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
  if(prev_calculated>rates_total || prev_calculated<0)
    iToCopy=rates_total;
  else
   {
    iToCopy=rates_total-prev_calculated;
    if(prev_calculated>0)
       iToCopy++;
   }
  int limit=MaxBars;
  if (limit+LookBackBuffer>rates_total) {
    limit=rates_total-LookBackBuffer;
  }
  if (limit<0) return 0; //too little bars, we exit
  
  if(prev_calculated==0){
    ArrayInitialize(Up1,0);
    ArrayInitialize(Down1,0);
    ArrayInitialize(Up2,0);
    ArrayInitialize(Down2,0);
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

  string sSignal=0, iPreventSig=0;
  EndDt = StartDt + 2*PeriodSeconds(Period()); //end date for debug1
  for(int i = start; i < rates_total-1 && !IsStopped(); i++) {  //don't include the current bar rates_total-1 is the current bar.
    double arrowbuffer = 1*value.atr;
    //plot dots on the chart to indicate positive or negative scoring of al the MA slopes add up    
    if (debug1) {
      //Print(time[i]," ",EndDt," ", time[i]< EndDt);
      //if (time[i]> StartDt && time[i] < EndDt ) {  //  
      if (time[i] == StartDt) {  //
        Print("Debug: ", time[i]);
        sSignal = ThreeM_Logic(i); //check for signal
        if (StringSubstr(sSignal,0,2)=="Up") {
          Up1[i] = SMA8[i] - arrowbuffer;
          dtSigUp=rates[i].time; //remember the time, to prevent near future signal.
        }
        if (StringSubstr(sSignal,0,2)=="Do") {
          Down1[i] =  SMA8[i] + arrowbuffer;
          dtSigDown=rates[i].time; //remember the time, to prevent near future signal.
        }
      }// specific period for debug1
    }//debug1
    else {  
      //if (time[i]> StartDt) Print("Not Debug: ", time[i]);
      sSignal=ThreeM_Logic(i);
      if (StringSubstr(sSignal,0,2)=="Up") {
        if (dtSigUp==0 ||  Bars(Symbol(),0,dtSigUp,rates[i].time)>iPreventSig) { //must be more than 10 bars past before a new signal starts     
          Up1[i] = SMA8[i] - arrowbuffer;
          dtSigUp=rates[i].time; //remember the time, to prevent near future signal.
        }
      }  
      if (StringSubstr(sSignal,0,2)=="Do") {
        if (dtSigDown==0 || Bars(Symbol(),0,dtSigDown,rates[i].time)>iPreventSig) { //must be more than 10 bars past before a new signal starts
          Down1[i] =  SMA8[i] + arrowbuffer;
          dtSigDown=rates[i].time; //remember the time, to prevent near future signal.
        }
      }
    } //else if not debug1
  } //for loop
  
  return(rates_total);
}


#include <River.mqh>
#include <BW 4M Include.mqh>

#property   indicator_buffers 2
#property   indicator_plots   2
//--- plot Arrows

#property indicator_type1  DRAW_ARROW
#property indicator_color1 clrLime  

#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrCrimson

bool debug=false;
bool debugUp=true;

////datetime StartDt=D'2022.12.28 16:00';
datetime InputDt=D'2023.06.13 17:00'; //   D'2023.05.18 12:00'; 
datetime StartDt=InputDt-PeriodSeconds(Period());
//datetime StartDt=D'2021.03.30 03:00';
datetime EndDt;

//--- input parameters
input int MaxBars = 100;

//ATR factor set to 3 to catch the recent ATF, so more buffer for volatility
//input int MinUpDown = 2;
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
   PlotIndexSetInteger(0,PLOT_ARROW,233);
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,30);

   //Setting the Buffer 0 to draw down arrow
   PlotIndexSetInteger(1,PLOT_ARROW,234);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,-30);



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
  if (limit+LookBackBuffer>rates_total) {
    limit=rates_total-LookBackBuffer;
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
  int iPreventSig=0, iRes;
  string sRes="";
  for(int i = start; i < rates_total-1 && !IsStopped(); i++) {  //don't include the current bar rates_total-1 is the current bar.
    double arrowbuffer = 1*ATR[i];
    //plot dots on the chart to indicate positive or negative scoring of al the MA slopes add up
    EndDt = StartDt + 2*PeriodSeconds(Period()); //end date for debug
    //EndDt= D'2022.03.13 00:00';
    if (debug) {
      if (time[i]> StartDt && time[i] < EndDt ) {
        Print("Debug: ", time[i]);
        sRes=fnBW4M_Sig(i);
        iRes=StringFind(sRes,"Up");
        if (iRes>0) {  //up signal
          Up1[i] = SMA8[i] - arrowbuffer;
          dtSigUp=rates[i].time; //remember the time, to prevent near future signal.
        }
        //if (sRes=="") sRes = fnBW4M_Sig(i); //check for signal if it have not been check for up before
        iRes=StringFind(sRes,"Down");
        if (iRes>0) {  // up signal
          Down1[i] =  SMA8[i] + arrowbuffer;
          dtSigDown=rates[i].time; //remember the time, to prevent near future signal.
        }  
      }// specific period for debug
    }//debug
    else {
      sRes=fnBW4M_Sig(i);
      iRes=StringFind(sRes,"Up");
      if (iRes>0) {  //up signal
        Up1[i] = SMA8[i] - arrowbuffer;
        dtSigUp=rates[i].time; //remember the time, to prevent near future signal.
      }
      iRes=StringFind(sRes,"Down");
      if (iRes>0) {  //down signal
        Down1[i] =  SMA8[i] + arrowbuffer;
        dtSigDown=rates[i].time; //remember the time, to prevent near future signal.
      }
    } //else if not debug
  } //for loop
  return(rates_total);
}


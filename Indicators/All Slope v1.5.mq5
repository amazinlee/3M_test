#include <All Slope v1.5.mqh>
#include <River.mqh>
#property   indicator_buffers 6
#property   indicator_plots   6
//--- plot Arrows

#property indicator_type1  DRAW_ARROW
#property indicator_color1 clrBlue

#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrCrimson

#property indicator_type3  DRAW_ARROW
#property indicator_color3 clrPowderBlue

#property indicator_type4  DRAW_ARROW
#property indicator_color4 clrPink

bool debug = false;

//--- input parameters
input int MaxBars = 20000;

//--- An indicator buffer for the plot
double Up1[],Down1[],Up2[],Down2[];
double distant;

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
  static datetime LastBar;

  if(LastBar==iTime(Symbol(),0,0)) return(-1);  //stop indicator from calculating current bar
  else LastBar=iTime(Symbol(),0,0);
  int iToCopy;
//  in case MaxBars more than rates_total
  if (MaxBars>rates_total) {  
    iToCopy=rates_total;
  }
  else {
    iToCopy=MaxBars;
  }

  if(prev_calculated==0){
    ArrayInitialize(Up1,0);
    ArrayInitialize(Down1,0);
    ArrayInitialize(Up2,0);
    ArrayInitialize(Down2,0);
    start = rates_total-MaxBars+LookBackBuffer ; //limited total no of bars to calc. 
  } 
  else {
//  total_rates - 1 is the current bar, a bit weird, so the last closed bar need to -2
    start = rates_total - 2; //check the last closed bar
  }

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
  int iArrowPos; 
  for(int i = start; i < rates_total-1 && !IsStopped(); i++) {  //don't include the current bar rates_total-1 is the current bar.
    iArrowPos=LookBackBuffer+i-start;
    datetime StartDt=D'2021.06.11 10:00', EndDt=D'2021.06.11 11:00';
    double arrowbuffer = 1*ATR[iArrowPos];
    //plot dots on the chart to indicate positive or negative scoring of al the MA slopes add up
    if (debug) {
      if ( time[i]> StartDt && time[i] < EndDt ) {
        Print(time[i]); //debug      
        double score=MA_Score(iArrowPos, EMA5[iArrowPos]);
        //Print("return score: ", score);
        Print(time[i]," return score: ", score);
        if (score>=MinUpDown) {
          Up1[i] = SMA84[iArrowPos] - arrowbuffer;
        }
        else if (score<=-MinUpDown) {
          Down1[i] =  SMA84[iArrowPos] + arrowbuffer;
        }
      }//time range
    } //debug for time range
    else {
      double score=MA_Score(iArrowPos, EMA5[iArrowPos]);
      if (score>=MinUpDown) {
        Up1[i] = SMA84[iArrowPos] - arrowbuffer;
      }
      else if (score<=-MinUpDown) {
        Down1[i] =  SMA84[iArrowPos] + arrowbuffer;
      }
    }//else
  } //for loop
    
  return(rates_total);
}


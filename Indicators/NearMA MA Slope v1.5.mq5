#include <River.mqh>
#include <All Slope v1.5.mqh>

#property   indicator_buffers 2
#property   indicator_plots   2
//--- plot Arrows
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrChartreuse

#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrCrimson

bool debug=false;
bool debug1=false;
//--- input parameters
int MaxBars= 10000;
input int NoTouchMA =10;
input double adjust_distant=0.1;

//--- An indicator buffer for the plot
//--- An indicator buffer for the plot
double UpArrow[],DownArrow[];
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
   SetIndexBuffer(0, UpArrow, INDICATOR_DATA);
   SetIndexBuffer(1, DownArrow, INDICATOR_DATA);
   
   //Setting the Buffer 0 to draw up arrow
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
  MqlRates rates[];
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
    ArrayInitialize(UpArrow,0);
    ArrayInitialize(DownArrow,0);
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
  
  double distant;
  for(int i = start; i < rates_total-1 && !IsStopped(); i++) {  //don't include the current bar rates_total-1 is the current bar.
    //if ((MathAbs(high[i]-low[i]))<0.8*ATR[i]) {continue;} //bar must be of min height in relative to ATR
    distant = ATR[i]*adjust_distant;
    double arrowbuffer = 0.5*ATR[i];
    string sSignal="", sMASlope="";
    datetime StartDt=D'2021.01.20 13:00', EndDt=D'2021.01.21 16:00';
    //if (debug1) {
      //if ( time[i]> StartDt && time[i] < EndDt ) {
        //Print("debug: ", time[i]," ", low[i]); //debug      
        //check for MA slope first
        double score=MA_Score(i, EMA5[i]);
        if (score>=MinUpDown) {
          sMASlope="Up";
        }
        else if (score<=-MinUpDown) {
          sMASlope="Down";
        }    
        //check for NearMA signal if Slope requirement is fulfilled
        if (sMASlope!="") {
          //if (sSignal=="") {sSignal=fnSignal(SMA21,rates,i,distant,sMASlope);}
          if (sSignal=="") {sSignal=fnSignal(SMA42,rates,i,distant,sMASlope);} 
          if (sSignal=="") {sSignal=fnSignal(SMA63,rates,i,distant,sMASlope);} 
          if (sSignal=="") {sSignal=fnSignal(SMA84,rates,i,distant,sMASlope);}
          //if (sSignal=="") {sSignal=fnSignal(SMA126,rates,i,distant,sMASlope);} 
          //if (sSignal=="") {sSignal=fnSignal(SMA168,rates,i,distant,sMASlope);}
          //if (sSignal=="") {sSignal=fnSignal(SMA252,rates,i,distant,sMASlope);} 
          //if (sSignal=="") {sSignal=fnSignal(SMA336,rates,i,distant,sMASlope);}    
          //if (sSignal=="") {sSignal=fnSignal(SMA630,rates,i,distant,sMASlope);} 
        }//MAslope
        if (sSignal=="Up") { UpArrow[i] = low[i]; }
        if (sSignal=="Down") {DownArrow[i] = high[i]; }
      //}//debug time range   
    //} //debug for time range    
  } //for loop
    
  return(rates_total);
}

string fnSignal(double &MA[], MqlRates &rates[], int pos, double dist, string MASlope ) {
  string sSig="", sNearMA="", sPinBar="";
  if (MathAbs(rates[pos].close - MA[pos])<dist && rates[pos].open>rates[pos].close) {sNearMA="Up";} //bear bar and rates[pos].close[i] must be near MA up signal
  if (MathAbs(rates[pos].close - MA[pos])<dist && rates[pos].close>rates[pos].open) {sNearMA="Down";} //bear bar and close[i] must be near MA up signal
  if ((MathMin(rates[pos].open,rates[pos].close)> MA[pos]) && (rates[pos].low<MA[pos]+dist)) {sPinBar="Up";} //pinbar
  if ((MathMax(rates[pos].open,rates[pos].close)< MA[pos]) && (rates[pos].high>MA[pos]-dist)) {sPinBar="Down";} //pinbar
  //if (MathAbs(rates[pos].low - MA[pos])<dist) {sNearMA="Up";}  //lowest point must be near MA
  //if (MathAbs(rates[pos].high - MA[pos])<dist) {sNearMA="Down";} //lowest point must be near MA

  if (sPinBar!="") sNearMA=sPinBar; //we give pinbar priority, combine both signals into sNearMA
  //check for past bars if bars touch MA only for NearMA, Pinbar no need to check
  if (sNearMA==MASlope && NoTouchMA>0) {
    int index=pos;
    for (int i=1; i<=NoTouchMA;i++) {
      index--;
      if ((MA[index]<rates[index].high+dist && MA[index]>rates[index].low-dist)) {
        //Print("touched ", index);
        sNearMA=""; //reset sNearMA to empty since there is a touch on MA
        break;
      } //if
    } //for
  }  //check sig
  

  //if both NearMA and MAslope are in same direction we give a signal
  if (sNearMA==MASlope) {
    sSig=sNearMA;
  } 
  else {
    sSig="";
  }

  return (sSig);
}
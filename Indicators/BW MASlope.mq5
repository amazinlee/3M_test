#include <River.mqh>
#include <All Slope v1.5.mqh>

#property   indicator_buffers 2
#property   indicator_plots   2
//--- plot Arrows
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrChartreuse

#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrCrimson

//--- input parameters
input int MaxBars= 20000;
input int NoTouchMA =4;
input int BB_NoTouchMA =0;
input double adjust_distant=0.1;
//ATF factor set to 3 to catch the recent ATF, so more buffer for volatility

bool debug=false;
//--- An indicator buffer for the plot
double UpArrow[],DownArrow[],UpBB[],LoBB[];

// Declare Indicator handles
int ATR_handle=iATR(Symbol(),0,ATR_Factor);
int BB_handle=iBands(Symbol(),0,21,0,2,PRICE_CLOSE);
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
  //MqlRates rates[];
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
  CopyBuffer(BB_handle,1,0,iToCopy,UpBB);
  CopyBuffer(BB_handle,2,0,iToCopy,LoBB);
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

  for(int i = start; i < rates_total-1 && !IsStopped(); i++) {  //don't include the current bar rates_total-1 is the current bar.
    if ((MathAbs(rates[i].high-rates[i].low))<0.3*ATR[i]) {continue;} //bar must be of min height in relative to ATR
    double arrowbuffer = 0.5*ATR[i];
    string sSignal="", sMASlope="";

    double score=MA_Score(i, EMA5[i]);
    if (score>=MinUpDown) {
      sMASlope="Up";
    }
    else if (score<=-MinUpDown) {
      sMASlope="Down";
    }    
    
    //if (sSignal=="") {sSignal=CheckBB(UpBB,LoBB,rates,i,sMASlope);} 
    //if (sSignal=="") {sSignal=fnSignal(EMA13,rates,i,sMASlope);}
    //if (sSignal=="") {sSignal=fnSignal(SMA21,rates,i,sMASlope);}
    //if (sSignal=="") {sSignal=fnSignal(SMA42,rates,i,sMASlope);} 
    if (sSignal=="") {sSignal=fnSignal(SMA63,rates,i,sMASlope);} 
    if (sSignal=="") {sSignal=fnSignal(SMA84,rates,i,sMASlope);}         
    if (sSignal=="") {sSignal=fnSignal(SMA126,rates,i,sMASlope);} 
    if (sSignal=="") {sSignal=fnSignal(SMA168,rates,i,sMASlope);}
    if (sSignal=="") {sSignal=fnSignal(SMA252,rates,i,sMASlope);} 
    if (sSignal=="") {sSignal=fnSignal(SMA336,rates,i,sMASlope);}
    if (sSignal=="") {sSignal=fnSignal(SMA630,rates,i,sMASlope);}

    if (sSignal=="Up") { UpArrow[i] = rates[i].low; }
    if (sSignal=="Down") {DownArrow[i] = rates[i].high; }
  } //for loop
    
  return(rates_total);
}

string fnSignal(double &MA[], MqlRates &rates[], int pos, string MASlope ) {
  string sSig="";
  //BW up
  if (rates[pos-1].close < MA[pos-1] && rates[pos-1].open > MA[pos-1] &&  //first bar must be bear
     rates[pos].open < MA[pos] && rates[pos].close > MA[pos]) //second bar must be bull
     {sSig="Up";} //bear bar and rates[pos].close[i] must be near MA up signal
  //BW down
  if (rates[pos-1].close > MA[pos-1] && rates[pos-1].open < MA[pos-1] &&  //first bar must be bull
     rates[pos].open > MA[pos] && rates[pos].close < MA[pos]) //second bar must be bear
     {sSig="Down";} //bear bar and rates[pos].close[i] must be near MA up signal
  
  //check for past bars if bars body cross MA if there is a signal
  if (sSig!="" && NoTouchMA>0) {
    int index=pos-1; //starts with the left bar, so shift one bar to the left
    for (int i=1; i<=NoTouchMA;i++) {
      index--;
      if ( (MA[index]>rates[index].open && MA[index]<rates[index].close) ||
           (MA[index]<rates[index].open && MA[index]>rates[index].close) ) 
      
      {
        sSig=""; //reset sSig to empty since there is a body cross on MA
        break;
      } //if
    } //for
  }  //check sig
  
  //if both BW and MAslope are in same direction we give a signal
  if (sSig!=MASlope) {
    sSig="";
  }
  return (sSig);
}

string CheckBB(double &Up_BB[], double &Lo_BB[], MqlRates &rates[], int pos, string MASlope ) {
  string sSig="";
  //BB up
  if (rates[pos-1].close < Lo_BB[pos-1] && rates[pos-1].open > Lo_BB[pos-1] &&  //first bar must be bear
  rates[pos].open < Lo_BB[pos] && rates[pos].close > Lo_BB[pos]) { //second bar must be bull
     sSig="Up"; 
     if (debug) Print (rates[pos-1].time, " ", Lo_BB[pos-1]);
  } //bear bar and rates[pos].close[i] must be near MA up signal
  //BB down
  if (rates[pos-1].close > Up_BB[pos-1] && rates[pos-1].open < Up_BB[pos-1] &&  //first bar must be bull
     rates[pos].open > Up_BB[pos] && rates[pos].close < Up_BB[pos]) { //second bar must be bear
     sSig="Down";
  } //bear bar and rates[pos].close[i] must be near MA up signal

  //check for past bars if bars body cross MA if there is a signal
  if (sSig!="" && BB_NoTouchMA>0) {
  bool bFound=false;
    int index=pos-1; //starts with the left bar, so shift one bar to the left
    for (int i=1; i<=BB_NoTouchMA;i++) {
      index--;
      if (sSig=="Up") {
        if ( (Lo_BB[index]>rates[index].open && Lo_BB[index]<rates[index].close) || //bull
             (Lo_BB[index]<rates[index].open && Lo_BB[index]>rates[index].close) )  //bear
             { sSig=""; }//reset sSig to empty since there is a body cross on UpBB
             
      }
      else {
        if ( (Up_BB[index]>rates[index].open && Up_BB[index]<rates[index].close) ||
             (Up_BB[index]<rates[index].open && Up_BB[index]>rates[index].close) ) 
             { sSig=""; }//reset sSig to empty since there is a body cross on LoBB      
      }
      if (sSig=="") {break;}  //break for loop if found touched
    } //for
  }  //check sig
  
  if (sSig!=MASlope) {
    sSig="";
  }
  return (sSig);
}
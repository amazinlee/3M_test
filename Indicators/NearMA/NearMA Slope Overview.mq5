#property   indicator_buffers 4
#property   indicator_plots   4
//--- plot Arrows
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrChartreuse

#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrCrimson

#property indicator_type3  DRAW_ARROW
#property indicator_color3 clrYellow

#property indicator_type4  DRAW_ARROW
#property indicator_color4 clrYellow

//--- input parameters
input int MaxBars= 100;
input int NoTouchMA =4;
input int ATR_Factor = 21;  
input double adjust_distant=0.15;
input int LookBack =4;
input double SignalSlope=0.1;
input double SlopeDistant_8=0.6;
input double SlopeDistant_21=0.2;
input double SlopeDistant_63=0.2;
input double SlopeDistant_126=0.2;

//ATF factor set to 3 to catch the recent ATF, so more buffer for volatility

//--- An indicator buffer for the plot
double UpArrow[],DownArrow[], ATR[], UpX[], DownX[];
double EMA5[], SMA8[],EMA13[],SMA21[],SMA42[],SMA63[],SMA84[],SMA126[],SMA168[],SMA252[],SMA336[],SMA630[];

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
   SetIndexBuffer(0, UpArrow, INDICATOR_DATA);
   SetIndexBuffer(1, DownArrow, INDICATOR_DATA);
   SetIndexBuffer(2, UpX, INDICATOR_DATA);
   SetIndexBuffer(3, DownX, INDICATOR_DATA);
   
   //Setting the Buffer 0 to draw up arrow
   PlotIndexSetInteger(0,PLOT_ARROW,233);
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,30);

   //Setting the Buffer 0 to draw down arrow
   PlotIndexSetInteger(1,PLOT_ARROW,234);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,-30);

   //Setting the Buffer 0 to draw down arrow
   PlotIndexSetInteger(2,PLOT_ARROW,170);
   PlotIndexSetInteger(2,PLOT_ARROW_SHIFT,40);

   //Setting the Buffer 0 to draw down arrow
   PlotIndexSetInteger(3,PLOT_ARROW,170);
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
  MqlRates rates[];
  static datetime LastBar;
  
  if(LastBar==iTime(Symbol(),0,0)) return(-1);  //stop indicator from calculating current bar
  else LastBar=iTime(Symbol(),0,0);
  
  int iEnd_Of_Arr= MaxBars-1; //for array index , need to minus 1
  
  if(prev_calculated==0){
    ArrayInitialize(UpArrow,0);
    ArrayInitialize(DownArrow,0);
    ArrayInitialize(UpX,0);
    ArrayInitialize(DownX,0);
    start = NoTouchMA; //need to buffer for NoTouch
    //Print("prev calc is 0");
    //start = rates_total-30;
  } else {
      start = iEnd_Of_Arr - 1; //check the last closed bar
  }
  
  CopyRates(NULL,0,0,MaxBars,rates);
  CopyBuffer(ATR_handle,0,0,MaxBars,ATR);
  CopyBuffer(EMA5_handle,0,0,MaxBars,EMA5);
  CopyBuffer(SMA8_handle,0,0,MaxBars,SMA8);
  CopyBuffer(EMA13_handle,0,0,MaxBars,EMA13);
  CopyBuffer(SMA21_handle,0,0,MaxBars,SMA21);
  CopyBuffer(SMA42_handle,0,0,MaxBars,SMA42);
  CopyBuffer(SMA63_handle,0,0,MaxBars,SMA63);
  CopyBuffer(SMA84_handle,0,0,MaxBars,SMA84);
  CopyBuffer(SMA126_handle,0,0,MaxBars,SMA126);
  CopyBuffer(SMA168_handle,0,0,MaxBars,SMA168);
  CopyBuffer(SMA252_handle,0,0,MaxBars,SMA252);
  CopyBuffer(SMA336_handle,0,0,MaxBars,SMA336);
  CopyBuffer(SMA630_handle,0,0,MaxBars,SMA630);

  for(int i = start; i < iEnd_Of_Arr && !IsStopped(); i++) {  //don't include the current bar rates_total-1 is the current bar.
    int iArrowPos=rates_total-MaxBars+i;
    if ((MathAbs(rates[i].high-rates[i].low))<0.6*ATR[i]) {continue;} //bar must be of min height in relative to ATR
    string sSignal="";
    //check for pinbar for each MA
    if (sSignal=="") {sSignal=fnSignal(EMA13,rates,i,iArrowPos);}
    if (sSignal=="") {sSignal=fnSignal(SMA21,rates,i,iArrowPos);}
    if (sSignal=="") {sSignal=fnSignal(SMA42,rates,i,iArrowPos);} 
    if (sSignal=="") {sSignal=fnSignal(SMA63,rates,i,iArrowPos);} 
    if (sSignal=="") {sSignal=fnSignal(SMA84,rates,i,iArrowPos);}         
    if (sSignal=="") {sSignal=fnSignal(SMA126,rates,i,iArrowPos);} 
    if (sSignal=="") {sSignal=fnSignal(SMA168,rates,i,iArrowPos);}
    if (sSignal=="") {sSignal=fnSignal(SMA252,rates,i,iArrowPos);} 
    if (sSignal=="") {sSignal=fnSignal(SMA336,rates,i,iArrowPos);}
    if (sSignal=="") {sSignal=fnSignal(SMA630,rates,i,iArrowPos);} 

  } //for loop
    
  return(rates_total);
}

string fnSignal(double &MA[], MqlRates &rates[], int pos, int iArrowPos) {
//check for either a pin bar (tail protrudes MA) or close of the bar is near MA
//proximity of bar close to the MA is measured bye distant, which is a factor (adjust_distant input) multiply by ATR  
  double dist = ATR[pos]*adjust_distant;
  string sSig=""; /*
  if (MathAbs(rates[pos].close - MA[pos])<dist && rates[pos].open>rates[pos].close && SlopeUp(MA,pos)) {sSig="Up";} //bear bar and rates[pos].close[i] must be near MA up signal
  if (MathAbs(rates[pos].close - MA[pos])<dist && rates[pos].close>rates[pos].open && SlopeDown(MA,pos)) {sSig="Down";} //bear bar and close[i] must be near MA up signal
  if ((MathMin(rates[pos].open,rates[pos].close)> MA[pos]) && (rates[pos].low<MA[pos]+dist) && SlopeUp(MA,pos)) {sSig="Up";} //pinbar
  if ((MathMax(rates[pos].open,rates[pos].close)< MA[pos]) && (rates[pos].high>MA[pos]-dist) && SlopeDown(MA,pos)) {sSig="Down";} //pinbar
*/
  if (MathAbs(rates[pos].close - MA[pos])<dist && rates[pos].open>rates[pos].close) {sSig="Up";} //bear bar and rates[pos].close[i] must be near MA up signal
  if (MathAbs(rates[pos].close - MA[pos])<dist && rates[pos].close>rates[pos].open) {sSig="Down";} //bear bar and close[i] must be near MA up signal
  if ((MathMin(rates[pos].open,rates[pos].close)> MA[pos]) && (rates[pos].low<MA[pos]+dist)) {sSig="Up";} //pinbar
  if ((MathMax(rates[pos].open,rates[pos].close)< MA[pos]) && (rates[pos].high>MA[pos]-dist)) {sSig="Down";} //pinbar
    
  //check for past bars if bars touch MA
  if (sSig!="" && NoTouchMA>0) {
    int index=pos;
    for (int i=1; i<=NoTouchMA;i++) {
      index--;
      if ((MA[index]<rates[index].high+dist && MA[index]>rates[index].low-dist)) {
        //Print("touched ", index);
        sSig=""; //reset sSig to empty since there is a touch on MA
        break;
      } //if
    } //for
  }  //check sig
  double arrowbuffer = 0.2*ATR[pos];
  if (sSig=="Up") {
    UpArrow[iArrowPos] = rates[pos].low;
    if (CheckBlockUp(MA, pos, rates[pos].low)) { 
      UpX[iArrowPos] = rates[pos].low - arrowbuffer; 
    }
  }
  if (sSig=="Down") {
    DownArrow[iArrowPos] = rates[pos].high; 
    if (CheckBlockDown(MA, pos, rates[pos].high)) { 
      DownX[iArrowPos] = rates[pos].high + arrowbuffer; 
    }
  }
  return (sSig);
}

bool CheckBlockUp(double &MA[], int pos, double low ) {
//
  double Dist8 = ATR[pos]*SlopeDistant_8;
  double Dist21 = ATR[pos]*SlopeDistant_21;
  double Dist63 = ATR[pos]*SlopeDistant_63;
  double Dist126 = ATR[pos]*SlopeDistant_126;
  
  double UpLimit=4.5*ATR[pos] + low;
  
  bool bBlocked=false;
  //lowest of bar must be lower than MA and below the upper limit for blockage clearence
  
  if (low < SMA8[pos] && SMA8[pos] < UpLimit*2) {
    if ( SMA8[pos-2]  - SMA8[pos] > Dist8 && Dist8 > 0 ) { //check if MA is slope down against the up signal
      bBlocked=true;
    } 
  }  
  if (low < SMA21[pos] && SMA21[pos] < UpLimit) {
    if ( SMA21[pos-LookBack]  - SMA21[pos] > Dist21 && Dist21 > 0 ) { //check if MA is slope down against the up signal
      bBlocked=true;
    } 
  }
  if (low < SMA42[pos] && SMA42[pos] < UpLimit) {
    if ( SMA42[pos-LookBack]  - SMA42[pos] > Dist21 && Dist21 > 0 ) { //check if MA is slope down against the up signal
      bBlocked=true;
    } 
  }
  if (low < SMA63[pos] && SMA63[pos] < UpLimit) {
    if ( SMA63[pos-LookBack]  - SMA63[pos] > Dist63 && Dist63 > 0 ) { //check if MA is slope down against the up signal
      bBlocked=true;
    } 
  }  
  if (low < SMA84[pos] && SMA84[pos] < UpLimit) {
    if ( SMA84[pos-LookBack]  - SMA84[pos] > Dist63 && Dist63 > 0 ) { //check if MA is slope down against the up signal
      bBlocked=true;
    } 
  }  
  if (low < SMA126[pos] && SMA126[pos] < UpLimit) {
    if ( SMA126[pos-LookBack]  - SMA126[pos] > Dist126 && Dist126 > 0 ) { //check if MA is slope down against the up signal
      bBlocked=true;
    } 
  }
  if (low < SMA168[pos] && SMA168[pos] < UpLimit) {
    if ( SMA168[pos-LookBack]  - SMA168[pos] > Dist126 && Dist126 > 0 ) { //check if MA is slope down against the up signal
      bBlocked=true;
    } 
  }      
  return (bBlocked);
}

bool CheckBlockDown(double &MA[], int pos, double high ) {
//
  double Dist8 = ATR[pos]*SlopeDistant_8;
  double Dist21 = ATR[pos]*SlopeDistant_21;
  double Dist63 = ATR[pos]*SlopeDistant_63;
  double Dist126 = ATR[pos]*SlopeDistant_126;
  
  double DownLimit = high - 4.5*ATR[pos];
  
  bool bBlocked=false;
  //highest of bar must be higher than MA and above the lower limit for blockage clearence
  if (high > SMA8[pos] && SMA8[pos] > DownLimit*2) {
    if ( SMA8[pos] - SMA8[pos-2] > Dist8 && Dist8 > 0 ) { //check if MA is slope down against the up signal
      bBlocked=true;
    } 
  }
  if (high > SMA21[pos] && SMA21[pos] > DownLimit) {
    if ( SMA21[pos] - SMA21[pos-LookBack] > Dist21 && Dist21 > 0 ) { //check if MA is slope down against the up signal
      bBlocked=true;
    } 
  }
  if (high > SMA42[pos] && SMA42[pos] > DownLimit) {
    if ( SMA42[pos] - SMA42[pos-LookBack] > Dist21 && Dist21 > 0 ) { //check if MA is slope down against the up signal
      bBlocked=true;
    } 
  }
  if (high > SMA63[pos] && SMA63[pos] > DownLimit) {
    if ( SMA63[pos] - SMA63[pos-LookBack] > Dist63 && Dist63 > 0 ) { //check if MA is slope down against the up signal
      bBlocked=true;
    } 
  }
  if (high > SMA84[pos] && SMA84[pos] > DownLimit) {
    if ( SMA84[pos] - SMA84[pos-LookBack] > Dist63 && Dist63 > 0 ) { //check if MA is slope down against the up signal
      bBlocked=true;
    } 
  }
  if (high > SMA126[pos] && SMA126[pos] > DownLimit) {
    if ( SMA126[pos] - SMA126[pos-LookBack] > Dist126 && Dist126 > 0 ) { //check if MA is slope down against the up signal
      bBlocked=true;
    } 
  }   
  if (high > SMA168[pos] && SMA168[pos] > DownLimit) {
    if ( SMA168[pos] - SMA168[pos-LookBack] > Dist126 && Dist126 > 0 ) { //check if MA is slope down against the up signal
      bBlocked=true;
    } 
  }   
  return (bBlocked);
}

bool SlopeUp(double &MA[], int pos) {
  double Dist = ATR[pos]*SignalSlope;
  
  if ( MA[pos] - MA[pos-4] > Dist ) { return true; }
  else {return false;}
  return true;
}

bool SlopeDown(double &MA[], int pos) {
  double Dist = ATR[pos]*SignalSlope;
  
  if ( MA[pos-4] - MA[pos] > Dist ) { return true; }
  else {return false;}
  return true;
}
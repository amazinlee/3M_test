#property   indicator_chart_window
#property   indicator_buffers 2
#property   indicator_plots   2
//--- plot Arrows
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrChartreuse

#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrCrimson

//--- input parameters
input int MaxBars= 10000;
input int NoTouchMA =4;
input int ATR_Factor = 21;  
input double adjust_distant=0.1;
//ATF factor set to 3 to catch the recent ATF, so more buffer for volatility

//--- An indicator buffer for the plot
double UpArrow[],DownArrow[], ATRBuffer[];
double EMA5[],EMA13[],SMA21[],SMA42[],SMA63[],SMA84[],SMA126[],SMA168[],SMA252[],SMA336[],SMA630[];

double distant;

// Declare Indicator handles
int ATR_handle=iATR(Symbol(),0,ATR_Factor);
int EMA5_handle=iMA(Symbol(),0,5,0,MODE_EMA,PRICE_CLOSE);
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
   //PlotIndexSetInteger(0,PLOT_ARROW,233);
   PlotIndexSetInteger(0,PLOT_ARROW,170);
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,30);

   //Setting the Buffer 0 to draw down arrow
   PlotIndexSetInteger(1,PLOT_ARROW,170);
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
  
  int iEnd_Of_Arr= MaxBars-1; //for array index , need to minus 1
  
  if(prev_calculated==0){
    ArrayInitialize(UpArrow,0);
    ArrayInitialize(DownArrow,0);
    start = NoTouchMA; //need to buffer for NoTouch
    //Print("prev calc is 0");
    //start = rates_total-30;
  } else {
      start = iEnd_Of_Arr - 1; //check the last closed bar
  }
  
  CopyRates(NULL,0,0,MaxBars,rates);
  CopyBuffer(ATR_handle,0,0,MaxBars,ATRBuffer);
  CopyBuffer(EMA5_handle,0,0,MaxBars,EMA5);
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
    if ((MathAbs(rates[i].high-rates[i].low))<0.6*ATRBuffer[i]) {continue;} //bar must be of min height in relative to ATR
    distant = ATRBuffer[i]*adjust_distant;
    double arrowbuffer = 0.5*ATRBuffer[i];
    string sSignal="";
    //check for pinbar for each MA
    if (sSignal=="") {sSignal=fnSignal(EMA13,rates,i,distant);}
    if (sSignal=="") {sSignal=fnSignal(SMA21,rates,i,distant);}
    if (sSignal=="") {sSignal=fnSignal(SMA42,rates,i,distant);} 
    if (sSignal=="") {sSignal=fnSignal(SMA63,rates,i,distant);} 
    if (sSignal=="") {sSignal=fnSignal(SMA84,rates,i,distant);}         
    if (sSignal=="") {sSignal=fnSignal(SMA126,rates,i,distant);} 
    if (sSignal=="") {sSignal=fnSignal(SMA168,rates,i,distant);}
    if (sSignal=="") {sSignal=fnSignal(SMA252,rates,i,distant);} 
    if (sSignal=="") {sSignal=fnSignal(SMA336,rates,i,distant);}
    if (sSignal=="") {sSignal=fnSignal(SMA630,rates,i,distant);} 
                
    if (sSignal=="Up") { UpArrow[iArrowPos] = rates[i].low; }
    if (sSignal=="Down") {DownArrow[iArrowPos] = rates[i].high; }
  } //for loop
    
  return(rates_total);
}

string fnSignal(double &MA[], MqlRates &rates[], int pos, double dist ) {
//check for either a pin bar (tail protrudes MA) or close of the bar is near MA
//proximity of bar close to the MA is measured bye distant, which is a factor (adjust_distant input) multiply by ATR  
  string sSig="";
  if (MathAbs(rates[pos].close - MA[pos])<dist && rates[pos].open>rates[pos].close) {sSig="Up";} //bear bar and rates[pos].close[i] must be near MA up signal
  if (MathAbs(rates[pos].close - MA[pos])<dist && rates[pos].close>rates[pos].open) {sSig="Down";} //bear bar and close[i] must be near MA up signal
  if ((MathMin(rates[pos].open,rates[pos].close)> MA[pos]) && (rates[pos].low<MA[pos]+dist)) {sSig="Up";} //pinbar
  if ((MathMax(rates[pos].open,rates[pos].close)< MA[pos]) && (rates[pos].high>MA[pos]-dist)) {sSig="Down";} //pinbar
  //if (MathAbs(rates[pos].low - MA[pos])<dist) {sSig="Up";}  //lowest point must be near MA
  //if (MathAbs(rates[pos].high - MA[pos])<dist) {sSig="Down";} //lowest point must be near MA

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
  return (sSig);
}
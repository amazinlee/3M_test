//--- input parameters
input bool NearMA_CheckTail=true;
input int NoTouchMA =2;
input double NearMA_adjust_distant=0.1;

string NearMA(string sSymbol, ENUM_TIMEFRAMES TF) {

  MqlRates rates[];
  // Declare Indicator handles
  int ATR_handle=iATR(sSymbol,TF,ATR_Factor);
  int EMA5_handle=iMA(sSymbol,TF,5,0,MODE_EMA,PRICE_CLOSE);
  int SMA8_handle=iMA(sSymbol,TF,8,0,MODE_SMA,PRICE_CLOSE);
  int EMA13_handle=iMA(sSymbol,TF,13,0,MODE_EMA,PRICE_CLOSE);
  int SMA21_handle=iMA(sSymbol,TF,21,0,MODE_SMA,PRICE_CLOSE);
  int SMA42_handle=iMA(sSymbol,TF,42,0,MODE_SMA,PRICE_CLOSE);
  int SMA63_handle=iMA(sSymbol,TF,63,0,MODE_SMA,PRICE_CLOSE);
  int SMA84_handle=iMA(sSymbol,TF,84,0,MODE_SMA,PRICE_CLOSE);
  int SMA126_handle=iMA(sSymbol,TF,126,0,MODE_SMA,PRICE_CLOSE);
  int SMA168_handle=iMA(sSymbol,TF,168,0,MODE_SMA,PRICE_CLOSE);
  int SMA252_handle=iMA(sSymbol,TF,252,0,MODE_SMA,PRICE_CLOSE);
  int SMA336_handle=iMA(sSymbol,TF,336,0,MODE_SMA,PRICE_CLOSE);
  int SMA630_handle=iMA(sSymbol,TF,630,0,MODE_SMA,PRICE_CLOSE);

  int iToCopy= NoTouchMA+20;
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
  
  CopyRates(sSymbol,TF,0,iToCopy,rates);
  int i=iToCopy-2;  //i is the last closed bar
  double distant = NearMA_adjust_distant*ATR[i];
  //bar must be of min height in relative to ATR
  if (MathAbs(rates[i].high-rates[i].low)<0.8*ATR[i]) {return "";} 
  string sSignal="", sRes="", sMASlope="";

  //check for MA slope first
  double MAslope=MA_Score(i, EMA5[i]);

  if (MAslope>=MinUpDown) {
    sMASlope="Up";
  }
  else if (MAslope<=-MinUpDown) {
    sMASlope="Down";
  }
  //check for NearMA signal if Slope requirement is fulfilled
  if (sMASlope!="") {  
    if (sSignal=="") {sSignal=fnNearMASig(EMA13,rates,i,distant,sMASlope);}
    if (sSignal=="") {sSignal=fnNearMASig(SMA21,rates,i,distant,sMASlope);}
    if (sSignal=="") {sSignal=fnNearMASig(SMA42,rates,i,distant,sMASlope);} 
    if (sSignal=="") {sSignal=fnNearMASig(SMA63,rates,i,distant,sMASlope);} 
    if (sSignal=="") {sSignal=fnNearMASig(SMA84,rates,i,distant,sMASlope);}         
    if (sSignal=="") {sSignal=fnNearMASig(SMA126,rates,i,distant,sMASlope);} 
    if (sSignal=="") {sSignal=fnNearMASig(SMA168,rates,i,distant,sMASlope);}
    if (sSignal=="") {sSignal=fnNearMASig(SMA168,rates,i,distant,sMASlope);}
    if (sSignal=="") {sSignal=fnNearMASig(SMA252,rates,i,distant,sMASlope);} 
    if (sSignal=="") {sSignal=fnNearMASig(SMA336,rates,i,distant,sMASlope);}    
    if (sSignal=="") {sSignal=fnNearMASig(SMA630,rates,i,distant,sMASlope);} 
  }//MAslope

//if (sRes!="") Print("debug from Fn: ", sSymbol," ",TF, " ", sRes);

  if (sSignal=="Up") {
    sRes="Up";
  }
  
  if (sSignal=="Down") {
    sRes="Down";    
  }
  return sRes;
} //NearMA


string fnNearMASig(double &MA[], MqlRates &rates[], int pos, double dist, string MASlope) {
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
//--- input parameters
input bool NearMA_CheckTail=true;
input int NearMA_NoTouchMA=5;
input int NearMA_ATR = 21;
input double NearMA_adjust_distant=0.1;

string NearMA(string sSymbol, ENUM_TIMEFRAMES TF) {

  double ATRBuffer[];
  double EMA5[],EMA13[],SMA21[],SMA42[],SMA63[],SMA84[],SMA126[],SMA168[],SMA252[],MA10[],SMA336[],SMA630[];
  MqlRates rates[];
    
  int ATR_handle=iATR(sSymbol,TF,NearMA_ATR);
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
  int iToCopy= NearMA_NoTouchMA+20;
  
  CopyBuffer(ATR_handle,0,0,iToCopy,ATRBuffer);
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
  double distant = NearMA_adjust_distant*ATRBuffer[i];
  double arrowbuffer = 0.6*ATRBuffer[i];
  //bar must be of min height in relative to ATR
  if (MathAbs(rates[i].high-rates[i].low)<0.8*ATRBuffer[i]) {return "";} 
  string sSignal="", sRes="";
  
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

  if (sSignal=="Up") {
    sRes="Up";
  }
  
  if (sSignal=="Down") {
    sRes="Down";    
  }
  return sRes;
} //NearMA


string fnSignal(double &MA[], MqlRates &rates[], int pos, double dist ) {
  
  string sSig="";
  if (MathAbs(rates[pos].close - MA[pos])<dist && rates[pos].open>rates[pos].close) {sSig="Up";} //bear bar and rates[pos].close[i] must be near MA up signal
  if (MathAbs(rates[pos].close - MA[pos])<dist && rates[pos].close>rates[pos].open) {sSig="Down";} //bear bar and close[i] must be near MA up signal
  if ((MathMin(rates[pos].open,rates[pos].close)> MA[pos]) && (rates[pos].low<MA[pos]+dist)) {sSig="Up";} //pinbar
  if ((MathMax(rates[pos].open,rates[pos].close)< MA[pos]) && (rates[pos].high>MA[pos]-dist)) {sSig="Down";} //pinbar
  //if (MathAbs(rates[pos].low - MA[pos])<dist) {sSig="Up";}  //lowest point must be near MA
  //if (MathAbs(rates[pos].high - MA[pos])<dist) {sSig="Down";} //lowest point must be near MA
  //check for past bars if bars touch MA
  if (sSig!="" || NearMA_NoTouchMA>0) {
    //Print(StringFormat("%s MA: %f Dist: %f", TimeToString(rates[pos].time), MA[pos], dist));
    bool bTouch=false;
    int index=pos;
    for (int i=1; i<=NearMA_NoTouchMA;i++) {
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
#include <Values.mqh>

int LookBackBuffer = 50;

datetime dtSigUp, dtSigDown; //for prevent subsequent signals
bool debug2=true;

CValues *val; //class to store values
CFilterMAStrict *filter;
//CFilterMA_3M *filter;

//for Expert Advisor
string ThreeM(string sSymbol, ENUM_TIMEFRAMES TF) {
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
  int SMA252_handle=iMA(sSymbol,TF,252,0,MODE_SMA,PRICE_CLOSE);
 
  int iToCopy = LookBackBuffer;
  CopyRates(sSymbol,TF,0,iToCopy,rates);
  CopyBuffer(ATR_handle,0,0,iToCopy,ATR);
  CopyBuffer(EMA5_handle,0,0,iToCopy,EMA5);
  CopyBuffer(SMA8_handle,0,0,iToCopy,SMA8);  
  CopyBuffer(EMA13_handle,0,0,iToCopy,EMA13);
  CopyBuffer(SMA21_handle,0,0,iToCopy,SMA21);
  CopyBuffer(SMA42_handle,0,0,iToCopy,SMA42);
  CopyBuffer(SMA63_handle,0,0,iToCopy,SMA63);
  CopyBuffer(SMA84_handle,0,0,iToCopy,SMA84);
  CopyBuffer(SMA126_handle,0,0,iToCopy,SMA126);
  CopyBuffer(SMA252_handle,0,0,iToCopy,SMA252);
  

  int pos=iToCopy-2;  //i is the last closed bar, for tracking current closed bar
  string sSignal="", sRes="";
  
  sRes=ThreeM_Logic(pos); //pass pos value to class and let it process the values

  return sRes;  
}
//for both EA and Indicator
string ThreeM_Logic(int pos) {
  string sRes="";
  string test;
  val= new CValues(); //value object
  //filter = new CFilterMA_3M(); //CFilter object to store values of filter criteria
  filter = new CFilterMAStrict();
  //pass pos value to class and let it process the values
  val.SetPos(pos);
  //atr can't be 0
  if (val.atr==0) return "";

  //feed the steepmode (gentle or steep) to the filter object
  filter.Load(val);
  //run checks
  if (sRes=="") {
    //if (val.SteepMode==0) sRes = Checks(pos);
    sRes = filter.sResults;
  }

  if (debug1) Print("Values: ", " slope5: ",RoundN(val.slope5), " slope8: ",RoundN(val.slope8), " slope13: ",
   RoundN(val.slope13), " slope8a: ", RoundN(val.a_slope8), " slope21: ",RoundN(val.slope21), " slope42: ",RoundN(val.slope42),
   " slope63: ",RoundN(val.slope63)," slope126: ",RoundN(val.slope126)," slope5one: ",RoundN(val.slope5one)); 
  //roc values
  if (debug1 && debug2) Print("Roc Values: "," roc5 ", RoundN(val.roc5)," roc8 ",RoundN(val.roc8), 
   " roc13 ",RoundN(val.roc13)," prcCtrl8: ",RoundN(val.prcCtrl8)," prcCtrl5: ",RoundN(val.prcCtrl5),
   " prcCtrl21: ",RoundN(val.prcCtrl21)  );
   
  if (debug1) Print("Dist13_21: ",RoundN(val.dist13_21)," Dist5_13: ", RoundN(val.dist5_13)," dist21_42: ",RoundN(val.dist21_42),
   " Dist8_13: ",RoundN(val.dist8_13)," dist13_21: ", RoundN(val.dist13_21)," dist8_42: ", RoundN(val.dist8_42), 
   " dist63_126: ", RoundN(val.dist63_126)," dist21_63: ", RoundN(val.dist21_63)," dist42_63: ", RoundN(val.dist42_63),
   " dist5_21: ", RoundN(val.dist5_21) );
  if (debug1) Print(" div5_21s: ",RoundN(val.div5_21s)," div5_13: ",RoundN(val.div5_13),
   " div21_63: ",RoundN(val.div21_63)," div8_13: ", RoundN(val.div8_13), " div21_42: ", RoundN(val.div21_42),
   " div21_42s: ", RoundN(val.div21_42s)," div8_21: ", RoundN(val.div8_21), " div8_21s: ", RoundN(val.div8_21s),
   " div8_42: ", RoundN(val.div8_42)," div8_42s: ", RoundN(val.div8_42s) ); 

  val.sValues = TimeToString(rates[pos].time) +", "+ RoundN(MathAbs(val.slope13))+", "+ RoundN(val.dist5_13)+", "+ RoundN(val.dist13_21)+
  ", "+RoundN(val.dist21_42)+", "+RoundN(val.div5_21s)+", "+RoundN(val.div8_21s)+", "+RoundN(val.div5_13)  ; 
  
  //if (debug1) WriteToFile(val.sValues);
  delete filter;
  delete val;
  return (sRes);
}

void WriteToFile(string sString) {
  int file_handle;
  file_handle=FileOpen("Output.csv",FILE_CSV|FILE_READ|FILE_WRITE|FILE_COMMON,",");
  if (file_handle<0) {Print("Error code ",GetLastError());}
  //FileSeek(file_handle,0,SEEK_END);
  FileSeek(file_handle,0,SEEK_SET);
  FileWriteString(file_handle,sString);
  FileClose(file_handle);
}

//check MA that slope down and above 35, need to filter
bool CheckNearUp_bu() {
  bool bPass=true;
  double NearUp = EMA13[val.pos] + val.atr*6.0;
  double Roc5=1.2;
  double Dist5_13=0.58, Dist8_13a=0.075, Slope8_13=0.2, Slope8=0.12, Slope21=-0.03;
  double Div5_13=0.3;
  double SlopeBlock42=0.02, SlopeBlock63=0.01, SlopeBlock126=0.01;
  int NumOfBlocks = 0;
  //if 126 is too far, we disqualify
  //if (SMA126[val.pos] > (EMA13[val.pos] + val.atr) ) {
    //if (debug1) Print("CheckNear Fail 126 is too far "); return false; 
  //}
  //21 below 63
  if (SMA21[val.pos]<SMA63[val.pos]*0.999) {
    if (debug1) Print("CheckNear Fail 21 below 63"); return false; 
  }   
  //8n13 need to be above 21
  if (SMA8[val.pos]<SMA21[val.pos]*0.999 || EMA13[val.pos]<SMA21[val.pos]*0.999) {
    if (debug1) Print("CheckNear Fail 8n13 below 21"); return false; 
  } 
  //3M need to be above 42, need to buffer 42 value 0.2% less
  if (EMA13[val.pos]<SMA42[val.pos]*0.9999) {
    if (debug1) Print("CheckNear Fail 13<42"); return false; 
  }
  //either 42 and 63 need to be up
  if (val.slope42<filter.Slope42 && val.slope63<filter.Slope63) {
    if (debug1) Print("CheckNear Fail 42/63 slope"); return false;
  }
  //one of the MA too steep against 
  if (val.SteepMode==0 && SMA126[val.pos]<NearUp && EMA13[val.pos]<SMA126[val.pos] && val.slope126<SlopeBlock126) {
    if (debug1) Print("CheckNearUp Fail 126 Block"); return false;
    NumOfBlocks=NumOfBlocks+1;    
  } /*
  if (SMA252[val.pos]<NearUp && EMA13[val.pos]<SMA252[val.pos] && val.slope252<SlopeBlock126) {
    if (debug1) Print("CheckNearUp Fail 252 Block"); return false;
    NumOfBlocks=NumOfBlocks+1;    
  } */
  //if one of River2 block and both MA slope against
  if (NumOfBlocks>=1 && val.slope126<SlopeBlock126 && val.slope252<SlopeBlock126) {
    if (debug1) Print("CheckNearUp Fail River2 block"); return false;
    return false;    
  }
  //slope13 not steep enough and near 63
  if (SMA63[val.pos]<NearUp && (EMA13[val.pos]*0.9999)<SMA63[val.pos] && val.slope63<SlopeBlock63) {
    NumOfBlocks=NumOfBlocks+1;
  }
  //slope13 not steep enough and near 42
  if (SMA42[val.pos]<NearUp && (EMA13[val.pos]*0.9999)<SMA42[val.pos] && val.slope42<SlopeBlock42) {
    NumOfBlocks=NumOfBlocks+1;
  }
  if (NumOfBlocks==0) return true;
  //able to break through one MA block with steep 3M
  //now there are one or more MA is blocking
  if (val.dist5_13>Dist5_13) {
    if (debug1) Print("CheckNear Fail Dist5_13 ",RoundN(val.dist5_13)," ",Dist5_13 ); return false;  
  }  
  if (val.div5_13>Div5_13) {
    if (debug1) Print("CheckNear Fail Div5_13 ",RoundN(val.div5_13)," ",Div5_13 ); return false;  
  }
  if (val.slope21<Slope21) {
    if (debug1) Print("CheckNear Fail slope21 ",RoundN(val.slope21)," ",Slope21 ); return false;  
  }

  return bPass;
}

bool CheckNearDown_bu() { 
  bool bPass=true;
  double NearDown = EMA13[val.pos] - val.atr*6.0;
  float Roc5=1.0;
  double Dist5_13=0.58, Dist8_13a=0.075, Slope8_13=-0.2, Slope8=-0.1, Slope21=0.03;
  double Div5_13=0.3;
  double SlopeBlock42=-0.02, SlopeBlock63=0.01,  SlopeBlock126=-0.01;
  int NumOfBlocks=0;

  //21 above 63
  if (SMA21[val.pos]>SMA63[val.pos]*1.001) {
    if (debug1) Print("CheckNear Fail 21 above 63"); return false; 
  }      
  //8n13 need to be below 21
  if (SMA8[val.pos]>SMA21[val.pos]*1.001 || EMA13[val.pos]>SMA21[val.pos]*1.001) {
    if (debug1) Print("CheckNear Fail 8n13 below 21"); return false; 
  }   
  //3M need to be below 42, need to buffer 42 value 10% more
  if (EMA13[val.pos]>SMA42[val.pos]*1.0001) {
    if (debug1) Print("CheckNearDown Fail 13>42"); return false; 
  }
  //either 42 and 63 need to be down
  if (val.slope42>-filter.Slope42 && val.slope63>filter.Slope63) {
    if (debug1) Print("CheckNearDown Fail 42/63 slope"); return false;
  }
  //blockage by MA
  if (SMA126[val.pos]>NearDown && (EMA13[val.pos]*1.0001)>SMA126[val.pos] && val.slope126>SlopeBlock126) {
    //if (debug1) Print("CheckNearDown Fail 126 Block ", (EMA13[val.pos]*1.01)>SMA126[val.pos]); return false;
    NumOfBlocks=NumOfBlocks+1;    
  }
  if (SMA252[val.pos]>NearDown && (EMA13[val.pos]*1.0001)>SMA252[val.pos] && val.slope252>SlopeBlock126) {
    //if (debug1) Print("CheckNearDown Fail 126 Block ", (EMA13[val.pos]*1.01)>SMA126[val.pos]); return false;
    NumOfBlocks=NumOfBlocks+1;    
  } 
  if (SMA63[val.pos]>NearDown && EMA13[val.pos]*1.0001>SMA63[val.pos] && val.slope63>SlopeBlock63) {
    NumOfBlocks=NumOfBlocks+1;
  }   
  //slope13 not steep enough and near 42
  if (SMA42[val.pos]>NearDown && (EMA13[val.pos]*1.0001)>SMA42[val.pos] && val.slope42>SlopeBlock42) {
    NumOfBlocks=NumOfBlocks+1;
  }
  if (NumOfBlocks==0) {return true;}
  //able to break through one MA block with steep
  
  //now there are one or more MA is blocking
  if (val.dist5_13>Dist5_13) {
    if (debug1) Print("CheckNear Fail Dist5_13 ",val.dist5_13," ",Dist5_13 ); return false;  
  }  
  if (val.div5_13>Div5_13) {
    if (debug1) Print("CheckNear Fail Div5_13 ",val.div5_13," ",Div5_13 ); return false;  
  }
  if (val.slope21>Slope21) {
    if (debug1) Print("CheckNear Fail slope21 ",val.slope21," ",Slope21 ); return false;  
  }

  return bPass;
}

//5 and 13 for past few bars can't be too far apart
bool CheckBackMA_Dist(int iPos) {
  bool bPass=true;  //allow trade by default
  double Dist5_13, Dist5_13a;
  
  if (val.slope13<val.Steep || val.slope13>-val.Steep) { //gentle
    Dist5_13=0.8; Dist5_13a=0.57;
  }
  if (val.slope13>val.Steep || val.slope13<-val.Steep) { //steep
    Dist5_13=1.3; Dist5_13a=1.5;
  }
  for (int i=0; i<=3; i++) {
    int pos=iPos-i;
    double dist5_13 = MathAbs(EMA5[pos]-EMA13[pos])/val.atr;
    //if dist is too big we disqualify
    if ( i==0 && (dist5_13>Dist5_13a) ) {  //first 
      bPass=false;
      if (debug1) Print ("Fail CheckBacMA Curr: ", RoundN(dist5_13)," ",RoundN(Dist5_13a) );
    }    
    if ( (dist5_13>Dist5_13) ) { 
      bPass=false;
      if (debug1) Print ("Fail CheckBacMA Past: ", RoundN(dist5_13)," ",RoundN(Dist5_13) );
    }
  }//for
  
  return bPass;
}

string SetBW8(int pos) {
  string sRes="";
  double barHgt, barHgtPrev;
  double MinHgt=0.01, MaxHgt=3.2;

  
  barHgt = MathAbs(rates[pos].open - rates[pos].close)/val.atr;
  barHgtPrev=MathAbs(rates[pos-1].open - rates[pos-1].close)/val.atr;

  if (barHgt<MinHgt || barHgtPrev<MinHgt || barHgt>MaxHgt) return sRes; //exit function if bar too small
  //Bullish bar first bar don't need to body cross MA
  if (rates[pos].open < SMA8[pos] && rates[pos].close > SMA8[pos] && rates[pos-1].close < rates[pos-1].open) {}
  //bearish bar
  if (rates[pos].open > SMA8[pos] && rates[pos].close < SMA8[pos] && rates[pos-1].close > rates[pos-1].open) {}

  return sRes;
}
#include <Values.mqh>

int LookBackBuffer = 50;

input double Slope13=0.02; input double Slope8=-0.01;
input double Slope13Steep=0.04; input double Slope8Steep=0.01;
input double Slope21=0.05; input double Steep=0.18;
input double Slope42=-0.15; input double Slope63=-0.15; input double Slope126=-0.15;
input double ROC8=0.5; input double ROC8Steep=0.5;
input double Dist5_13=0.6; input double Dist5_13Steep=1.2; input double Dist5_21=3; 
input double Dist13_21=0.3; input double Dist13_21Steep=0.8;
input double Div5_13=0.4; input double Div5_13Steep=0.6;
input double Div8_21=0.5; input double Div8_21Steep=0.5;
input double Div5_21Steep=1.25; 
input double Div21_42=0.78; input double Div21_42Short=0.32; input double Div21_42ShortSteep=0.45;
input double DistCloseTog=0.3; input double DistCloseTogSteep=1.5;

datetime dtSigUp, dtSigDown; //for prevent subsequent signals
bool bFirstSig=true; //for prevent subsequent signals
bool debug1=true;

CValues val; //class to store values

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

  int pos=iToCopy-2;  //i is the last closed bar, for tracking current closed bar
  string sSignal="", sRes="";
  int score;
  
  val.SetPos(pos); //pass pos value to class and let it process the values
  sRes=Set1(pos);
  
  return sRes;  
}
//for both EA and Indicator
string fn4M(int pos) {
//calculate total scores of all MA slopes add together to get either positive or negative score.
//if MA is near ema5 it will get a higher weightage
  string sRes="";
  
  if (val.atr==0) return 0;  
  
  sRes = Set1(pos);
  
  return (sRes);
}

string Set1(int pos) {
  string sRes="";
  //double Slope13=0.18, Slope8=0.18; Slope13=0.11;
  double PrcCtrl8=1.25, PrcCtrl8steep=2.2, PrcCtrl5=1.95;
  double ROC5=0.4, ROC13=1.0, ROC8_13=2.8;  //ROC8=0.8,
  //double Div8_21=0.99;
  //double Steep=0.15;
  //double DistCloseTog=0.7;

  bool bSlopeUp = val.slope13one>Slope13 && val.slope8one>Slope8; 
  bool bSlopeSteepUp = val.slope13one>Slope13Steep && val.slope8one>Slope8Steep;
  bool bSlopeDown = val.slope13one<-Slope13 && val.slope8one<-Slope8; 
  bool bSlopeSteepDown = val.slope13one<-Slope13Steep && val.slope8one<-Slope8Steep;
  bool b8SlopeUp = val.slope8>Slope8; bool b13SlopeUp = val.slope13>Slope13; bool b21SlopeUp = val.slope21>Slope21;
  bool b42SlopeUp = val.slope42>Slope42; bool b63SlopeUp =val.slope63>Slope63;
  bool b42SlopeDown = val.slope42<-Slope42; bool b63SlopeDown =val.slope63<-Slope63;
  bool b8SlopeDown = val.slope8<-Slope8; bool b13SlopeDown = val.slope13<-Slope13; bool b21SlopeDown = val.slope21<-Slope21;
  
  bool bDist5_13 = val.dist5_13<Dist5_13; bool bDist5_13Steep = val.dist5_13<Dist5_13Steep;
  bool bDistCloseTog = val.dist13_21<DistCloseTog;
  bool bDistCloseTogSteep = val.dist13_21<DistCloseTogSteep;
  bool bDist5_21 = val.dist5_21<Dist5_21;
  bool bPrcCtrl5 = val.prcCtrl5<PrcCtrl5; bool bPrcCtrl8 = val.prcCtrl8<PrcCtrl8; bool bPrcCtrl8steep = val.prcCtrl8<PrcCtrl8steep;
  bool bRoc5 = val.roc5>ROC5;  bool bRoc8 = val.roc8>ROC8; bool bRoc8Steep = val.roc8>ROC8Steep; bool bRoc13 = val.roc13>ROC13;
  bool bDiv5_13=val.diverge5_13<Div5_13; bool bDiv5_13Steep=val.diverge5_13<Div5_13Steep; 
  bool bDiv8_21=val.diverge8_21<Div8_21; bool bDiv8_21Steep=val.diverge8_21<Div8_21Steep;
  bool bDiv5_21Steep=val.diverge5_21<Div5_21Steep; 
  bool bDiv21_42=val.diverge21_42<Div21_42; bool bDiv21_42Short=val.diverge21_42Short<Div21_42Short; 
  bool bDiv21_42ShortSteep=val.diverge21_42Short<Div21_42ShortSteep;
  bool bGentle = (val.slope21>0 && val.slope21<Steep) || (val.slope21<0 && val.slope21>-Steep); 

  //check distant gentle
  if (bGentle) {
    if (bSlopeUp && b21SlopeUp && CheckNearUp()) {
      sRes="Up";
    }
    if (bSlopeDown && b21SlopeDown && CheckNearDown()) {
      sRes="Down";
    }
    if (debug && sRes=="") Print("Gentle fail stage 1");  //reset  
    //check for distance
    if (sRes!="" && bDistCloseTog && bDist5_13 && bPrcCtrl8) {if (debug) Print("pass stage 2");}  //do nothing
    else {sRes=""; if (debug) Print("Gentle fail stage 2");}  //reset   
    //check for ROC and Diverge
    if (sRes!="" && bRoc8 && bDiv5_13 && bDiv8_21 && bDiv21_42 && bDiv21_42Short) {} // 
      //do nothing
    else {sRes="";if (debug) Print("Gentle fail stage 3");} //reset
    
    if (debug && val.slope21>0) Print("set1 Up: ",bSlopeUp," ",b21SlopeUp," ",CheckNearUp());
    if (debug && val.slope21<0) Print("set1 Down: ",bSlopeDown," ",b21SlopeDown," ",CheckNearDown());
    if (debug) Print("Dist ", bDistCloseTog," ",bDist5_13 ," ",bPrcCtrl8 );
    if (debug) Print("Roc and Div ",bRoc8," ",bDiv5_13," ",bDiv8_21," ",bDiv21_42," ",bDiv21_42Short );
  }//gentle
  
  if (!bGentle){
    if (bSlopeSteepUp && b21SlopeUp && CheckNearUp()) {
      sRes="Up";
    }
    if (bSlopeSteepDown && b21SlopeDown && CheckNearDown()) {
      sRes="Down";
    }
    //distance
    if (sRes!="" && bDistCloseTogSteep && bDist5_13Steep && bPrcCtrl8steep) {}  //do nothing
    else {sRes=""; if (debug) Print("Steep fail stage 2");} //reset
    //check for ROC and Diverge
    if (sRes!="" && bRoc8Steep && bDiv5_13Steep && bDiv8_21Steep && bDiv21_42 && bDiv21_42ShortSteep) {} // 
      //do nothing
    else {sRes="";if (debug) Print("Steep fail stage 3");} //reset
    
    if (debug && val.slope8>0) Print("set1 Up: ",bSlopeSteepUp," "," ",b21SlopeUp," ",b42SlopeUp);
    if (debug && val.slope8<0) Print("set1 Down: ",bSlopeSteepDown," "," ",b21SlopeDown);
    if (debug) Print("Dist ", bDistCloseTogSteep," ",bDist5_13Steep ," ",bPrcCtrl8steep );
    if (debug) Print("Roc and Div steep ",bRoc8Steep," ",bDiv5_13Steep," ",bDiv8_21Steep," ",bDiv21_42," ",bDiv21_42ShortSteep );
  }//steep
  
  if (debug ) Print("Set1 Results: ", sRes, " slope5: ",RoundN(val.slope5), " slope8a: ",RoundN(val.slope8one), " slope13: ",
   RoundN(val.slope13), " slope13a: ", RoundN(val.slope13one), " slope21: ",RoundN(val.slope21), " slope42: ",RoundN(val.slope42),
   " slope63: ",RoundN(val.slope63)," slope126: ",RoundN(val.slope126)," roc5 ", RoundN(val.roc5)," roc8 ",RoundN(val.roc8), " roc13 ",RoundN(val.roc13) ); 
  
  if (debug) Print("Dist5_8: ",RoundN(val.dist5_8), " Dist8_21: ", RoundN(MathAbs(val.distLast8_21)), " Dist5_13: ", RoundN(val.dist5_13),
   " Dist8_13: ",RoundN(val.dist8_13)," Dist13_21: ", RoundN(val.dist13_21), " prcCtrl5: ", RoundN(val.prcCtrl5), " prcCtrl8: ", 
   RoundN(val.prcCtrl8), " div5_13: ",RoundN(val.diverge5_13)," div21_42: ",RoundN(val.diverge21_42), " div21_42Short: ",RoundN(val.diverge21_42Short) );

  val.sValues = rates[pos].time +", "+ RoundN(val.dist5_13)+", "+ RoundN(val.dist5_8)+", "+ RoundN(val.dist8_13)+", "+ RoundN(MathAbs(val.slope8))+", "+ 
   RoundN(MathAbs(val.slope13))+", "+RoundN(val.roc5)+", "+RoundN(val.roc8)+ ", "+RoundN(val.roc13)+ ", "+RoundN(val.roc21)+
   ", "+RoundN(val.diverge5_13)+", "+RoundN(val.diverge8_13)+", "+RoundN(val.diverge8_21);
  
  if (debug) Print("sRes ", sRes);
  //if (debug) WriteToFile(val.sValues);

  return sRes;
}

void WriteToFile(string sString) {
  int file_handle;
  file_handle=FileOpen("OutputEA.csv",FILE_CSV|FILE_READ|FILE_WRITE|FILE_COMMON,";");
  if (file_handle<0) {Print("Error code ",GetLastError());}
  FileSeek(file_handle,0,SEEK_END);
  FileWriteString(file_handle,sString);
  FileClose(file_handle);
}

//check MA that slope down and above 35, need to filter
bool CheckNearUp() {
  bool bResults=false;
  double NearUp = EMA13[val.pos] + val.atr*2.5;
  double VeryNearUp = EMA13[val.pos] + val.atr*1.3;
  double Dist5_13a=0.4, Dist8_13a=0.075, Slope13a=0.19, Slope5=-0.001, Div5_13a= 0.15;
  double Slope13oneBreak=0.03, Slope13Break=0.02, SlopeBlock42=-0.01, SlopeBlock63=0.03,  SlopeBlock126=0.07;
  int NumOfBlocks = 0;
  //3M need to be above 21
  if (EMA13[val.pos]<SMA21[val.pos]) { return false; }
  
  //plateau
  if (val.dist5_13>Dist5_13a && (val.a_slope5<Slope5 || val.slope5one<Slope5) ) { return false; }
  //too near have to exit
  if (SMA126[val.pos]<VeryNearUp && EMA13[val.pos]<SMA126[val.pos] && val.slope13one<Slope13oneBreak && val.slope126<SlopeBlock126) { return false; }
  
  if (SMA126[val.pos]<NearUp && EMA13[val.pos]<SMA126[val.pos] && val.slope126<SlopeBlock126) {
    NumOfBlocks=NumOfBlocks+1;
  }
  //slope13 not steep enough and near 63
  if (SMA63[val.pos]<NearUp && EMA13[val.pos]<SMA63[val.pos] && val.slope63<SlopeBlock63) {
    NumOfBlocks=NumOfBlocks+1;
  }
  //slope13 not steep enough and near 42
  if (SMA42[val.pos]<NearUp && EMA13[val.pos]<SMA42[val.pos] && val.slope42<SlopeBlock42) {
    NumOfBlocks=NumOfBlocks+1;
  }
  if (NumOfBlocks==0) { return true; }
  //able to break through one MA block with steep 3M
  if (NumOfBlocks>0 && val.slope13one>Slope13oneBreak && val.slope13>Slope13Break) { bResults=true; }
  
  if (debug) Print("CheckNearUp ", bResults, " ", NumOfBlocks);
  return bResults;
}

bool CheckNearDown() { 
  bool bResults=false;
  double NearDown = EMA13[val.pos] - val.atr*2.5;
  double VeryNearDown = EMA13[val.pos] - val.atr*1.3;
  double Dist5_13a=0.4, Dist8_13a=0.075, Slope13a=-0.19, Slope5=0.001, Div5_13a= 0.15;
  double Slope13oneBreak=-0.03, Slope13Break=-0.02, SlopeBlock42=0.01, SlopeBlock63=-0.03,  SlopeBlock126=-0.07;
  int NumOfBlocks=0;
  //3M need to be below 21
  if (EMA13[val.pos]>SMA21[val.pos]) { return false; }
  //plateau
  if (val.dist5_13>Dist5_13a && (val.a_slope5>Slope5 || val.slope5one>Slope5) ) { 
    if (debug && debug1) Print("fail plateau ");
    return false;
  }
  //too near have to exit
  if (SMA126[val.pos]>VeryNearDown && EMA13[val.pos]>SMA126[val.pos] && val.slope13one>Slope13oneBreak && val.slope126>SlopeBlock126) { return false; }
  Print("checkdown");
  //blockage by MA
  if (SMA126[val.pos]>NearDown && EMA13[val.pos]>SMA126[val.pos] && val.slope126>SlopeBlock126) {
    if (debug && debug1) Print("near 126");
    NumOfBlocks=NumOfBlocks+1;
  }
  if (SMA63[val.pos]>NearDown && EMA13[val.pos]>SMA63[val.pos] && val.slope63>SlopeBlock63) {
    if (debug && debug1) Print("near 63 ");
    NumOfBlocks=NumOfBlocks+1;
  }   
  //slope13 not steep enough and near 42
  if (SMA42[val.pos]>NearDown && EMA13[val.pos]>SMA42[val.pos] && val.slope42>SlopeBlock42) {
    if (debug && debug1) Print("near 42 ");
    NumOfBlocks=NumOfBlocks+1;
  }
  if (NumOfBlocks==0) { return true; }
  //able to break through one MA block with steep 3M
  if (NumOfBlocks>0 && val.slope13one<Slope13oneBreak && val.slope13<Slope13Break) { bResults=true; }
  
  if (debug) Print("CheckNearDown ", bResults);
  
  return bResults;
}

//5 and 13 for past few bars can't be too far apart
bool CheckBackMA_Dist(int pos) {
  bool bPass=true;  //allow trade by default
  double dblDist5_13=1.7, Dist8=1.3;
  
  for (int i=0; i<=4; i++) {
    double dist5_13 = MathAbs(EMA5[pos]-EMA13[pos])/val.atr;

    if ( (dist5_13>dblDist5_13) ) { 
      bPass=false;
      if (debug1) Print ("CheckBacMA: ", RoundN(dist5_13));
    }
  }//for
  //if (debug) Print("CheckBackMA Results: ", bPass);
  return bPass;
}

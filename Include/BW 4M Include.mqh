//--- input parameters
input int BW_NoTouchMA=0;
int LookBackBuffer = 30;

int LookBack3M = 5;
int LookBack21 = 5;
int LookBack = 7;

datetime dtSigUp, dtSigDown; //for prevent subsequent signals
bool bFirstSig=true; //for prevent subsequent signals

string BW4M(string sSymbol, ENUM_TIMEFRAMES TF, double &atr) {

  int ATR_handle=iATR(sSymbol,TF,ATR_Factor);
  int BB_handle=iBands(Symbol(),0,21,0,2,PRICE_CLOSE);
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
  
  int iToCopy= BW_NoTouchMA+LookBackBuffer;
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
  CopyBuffer(SMA168_handle,0,0,iToCopy,SMA168);
  CopyBuffer(SMA252_handle,0,0,iToCopy,SMA252);
  CopyBuffer(SMA336_handle,0,0,iToCopy,SMA336);
  CopyBuffer(SMA630_handle,0,0,iToCopy,SMA630);

  int iRes, pos=iToCopy-2;  //i is the last closed bar
  string sSignal="", sRes="", sMASlope="";  
  //pass by ref
  atr=ATR[pos];

  sSignal=fnBW4M_Sig(pos);
  sRes=sSignal;
/*  
  iRes=StringFind(sRes,"Up");
  if (iRes>0) {  //up signal  
    sRes=sSignal;
  }
*/
  return sRes;
} //BW

string fnBW4M_Sig(int pos) {
  //bar must be of min height in relative to ATR
  double atr=ATR[pos];
  //atr=atr*0.7;
  if (atr==0) return 0;
  //Print(0.3*atr, " ", MathAbs(rates[pos].high-rates[pos].low));
  if (MathAbs(rates[pos].high-rates[pos].low)<0.3*atr) {return "";} 
  
  MA[0]= EMA5[pos];
  MA[1]= SMA8[pos];
  MA[2]= EMA13[pos];
  MA[3]= SMA21[pos];
  MA[4]= SMA42[pos];
  MA[5]= SMA63[pos];
  MA[6]= SMA84[pos];
  MA[7]= SMA126[pos];
  MA[8]= SMA168[pos];
  MA[9]= SMA252[pos];
  MA[10]=SMA336[pos];
  MA[11]=SMA630[pos];
  
  int iBack=2;
  double slope21a = ((SMA21[pos]-SMA21[pos-iBack])/atr)/iBack;
  double slope8a = ((SMA8[pos]-SMA8[pos-iBack])/atr)/iBack;  
  double slope13a = ((EMA13[pos]-EMA13[pos-iBack])/atr)/iBack;  
  double Dist5_21=0.9;
  double dist5_21 = MathAbs(EMA5[pos]-SMA21[pos])/atr;
  
  double Slope8=0.075, Slope13=0.11, Slope21=0.02, Slope63=0.02, PriceControl8=1.2, PriceControl5=1.2; //priceControl 1.5
  // Slope8=0.11
  string sRes="", sBW="";
  // 3M BW (8 and 13)

  for (int i=2; i<3; i++) {  
    //BW up 
    
    if (BWup(pos,i,atr)) { //second bar must be bull 
      if (Filter_3M(pos,atr,"Up")) { sBW="BW3M Up"; }  //&& CheckNearUp(pos,atr))
    }
    //BW down
    if (BWdown(pos,i,atr)) {  //second bar must be bear
      if (Filter_3M(pos,atr,"Down")) { sBW="BW3M Down"; }   //&& CheckNearDown(pos,atr)) {
    }
    //
  }//for */
  //BW 21
  
  if (BWup(pos,3,atr)) { //second bar must be bull 
    if (Filter_21(pos,atr,"Up")) { sBW="BW21 Up"; }  //&& CheckNearUp(pos,atr))
  }
  //BW down
  if (BWdown(pos,3,atr)) {  //second bar must be bear
    if (Filter_21(pos,atr,"Down")) { sBW="BW21 Down"; }   //&& CheckNearDown(pos,atr)) {
  }  
  // and River 
/*  
  for (int i=4; i<8; i++) {    
    if (BWup(pos,i,atr) && Filter_River(i,pos,atr,"Up") ) //second bar must be bull  && CheckNearUp(pos,atr)
       {sBW="BW Up";} //bear bar and rates[pos].close[i] must be near MA up signal
    //BW down2
    if (BWdown(pos,i,atr) && Filter_River(i,pos,atr,"Down") ) //second bar must be bear
       {sBW="BW Down"; } //bear bar and rates[pos].close[i] must be near MA up signal
  }//for */

  //check for past bars if bars body cross MA if there is a signal, if there was touch before we 
  if ((sBW!="") && BW_NoTouchMA>0) {
    int index=pos-1; //starts with the left bar, so shift one bar to the left
    for (int i=1; i<=BW_NoTouchMA;i++) {
      index--;
      if ( (MA[index]>rates[index].open && MA[index]<rates[index].close) ||
           (MA[index]<rates[index].open && MA[index]>rates[index].close) ) 
      {
        sBW=""; //reset sSig to empty since there is a body cross on MA
        break;
      } //if
    } //for
  }  //check sig
  sRes=sBW;
  //if (debug) Print ("Slope8: ", RoundN(MA_Tan[1]), " Slope13: ", RoundN(MA_Tan[2]), " slope13a: ", RoundN(slope13a), " slope8a: ", RoundN(slope8a), " Slope5: ", RoundN(MA_Tan[0]), " Dist5_21: ", RoundN(dist5_21) );
  if (debug)  Print("BW ", sBW);
  return (sRes);
}

bool Filter_21(int pos, double atr, string sDir) {
  double slope5, slope8, slope42, slope42a, slope21, slope21a, slope63;
  double Dist3M_21=2.8, Dist13_21=1.5, Dist5_13=0.9;
  double Slope8=-0.1, Slope13a=0.001, Slope21=0.03, Slope21a=-0.1, Slope42=-0.01, Slope63=-0.06;
  int iBack=2, iLookBack=5, iBack5=3;
  bool bPass=false;
  
  slope5 = ((EMA5[pos]-EMA5[pos-iBack5])/atr)/iBack;
  slope8 = ((SMA8[pos]-SMA8[pos-iLookBack])/atr)/iBack;
  slope21 = ((SMA21[pos]-SMA21[pos-iLookBack])/atr)/iLookBack;
  slope42 = ((SMA42[pos]-SMA42[pos-iLookBack])/atr)/iLookBack;
  slope21a = ((SMA21[pos]-SMA21[pos-iBack])/atr)/iBack; //current slope
  slope63 = ((SMA63[pos]-SMA63[pos-iLookBack])/atr)/iLookBack;
  //21

  if (sDir=="Up" && slope21>Slope21 && slope21a>Slope21a && slope42>Slope42 && slope63>Slope63) {  //basic criteria
    bPass=true;
  }
  if (sDir=="Down" && slope21<-Slope21 && slope21a<-Slope21a && slope42<-Slope42 && slope63<-Slope63) {
    bPass=true;
  }


  if (debug && debugUp) Print("Filter21 ",bPass," details: ", slope21>Slope21 ," ", slope21a>Slope21a  ," ", RoundN(slope42) );
  if (debug && !debugUp) Print("Filter21 ",bPass," details: ", slope21<-Slope21 ," ", slope21a<-Slope21a ," ", slope8>-Slope8 ," ", RoundN(slope63) );
  return bPass;
}

bool Filter_River(int ma, int pos, double atr, string sDir) {
  double slope1, slope5, slope8, slope42, slope42a, slope21, slope21a, slope63, slope126;
  double Dist3M_21=2.8, Dist13_21=1.5, Dist5_13=0.9;
  double Slope8=-0.1, Slope13a=0.001, Slope21=0.03, Slope21a=-0.1, Slope42=0.03, Slope63=0.01,Slope63Filter=-0.06, Slope126=0.001;
  int iBack=2, iLookBack=5, iBack5=3;
  bool bPass=false;
  
  slope5 = ((EMA5[pos]-EMA5[pos-iBack5])/atr)/iBack;
  slope8 = ((SMA8[pos]-SMA8[pos-iLookBack])/atr)/iBack;
  slope21 = ((SMA21[pos]-SMA21[pos-iLookBack])/atr)/iLookBack;
  slope42 = ((SMA42[pos]-SMA42[pos-iLookBack])/atr)/iLookBack;
  slope21a = ((SMA21[pos]-SMA21[pos-iBack])/atr)/iBack; //current slope
  slope63 = ((SMA63[pos]-SMA63[pos-iLookBack])/atr)/iLookBack;
  slope126 = ((SMA126[pos]-SMA126[pos-iLookBack])/atr)/iLookBack;
  
  if (ma==4) {  //42
    if (sDir=="Up" && slope42>Slope42 && slope63>Slope63 && slope126>Slope126) {  //basic criteria
      bPass=true;
    }
    if (sDir=="Down" && slope42<-Slope42 && slope63<-Slope63 && slope126<-Slope126) {
      bPass=true;
    }
  }
  if (ma==5) { //63
    if (sDir=="Up" && slope63>Slope63 && slope126>Slope126) {  //basic criteria
      bPass=true;
    }
    if (sDir=="Down" && slope63<-Slope63 && slope126<-Slope126) {
      bPass=true;
    }
  } 
  if (ma==7) { //126
    if (sDir=="Up" && slope63>Slope63Filter && slope126>Slope126) {  //basic criteria
      bPass=true;
    }
    if (sDir=="Down" && slope63<-Slope63Filter && slope126<-Slope126) {
      bPass=true;
    }
  } 
    
  if (debug && debugUp) Print("Filter_River ",bPass," details: ", slope126>Slope126 ," ", slope63>Slope63 ," ", RoundN(slope1) );
  if (debug && !debugUp) Print("Filter_River ",bPass," details: ", slope42>Slope42 ," ", slope63>Slope63 ," "," ", RoundN(slope1) );
  return bPass;
}
//Filter for slope of 8 and 13 
bool Filter_3M(int pos, double atr, string sDir) {
  bool bPass=false, bFirst8_21=true, bFirst5_21=true, bFirst5_13=true, bFirst5_8=true;
  double Diverge8_21=0.9, Diverge5_21=0.9, Diverge5_13=0.5, Diverge5_8=0.5;
  double distFirst8_21, distLast8_21 , distFirst5_21, distLast5_21, distFirst5_13, distFirst5_8;
  double dist5_13, dist8_13, dist5_21, dist13_21, dist8_21, dist8_63;
  double slope5,slope5a,slope8,slope8a,slope13, slope13a, slope21, slope21a, slope42;
  //double Dist3M_21=0.8, Dist13_21=1.5;
  double Dist3M_21=2.8, Dist13_21=1.5, Dist5_13=1.1, Dist8_21=2.2, Dist8_63=0.5, Dist8_13ThresH=0.66, Dist13_21ThresH=1.0;
  double Slope5a=0.12, Slope3M=0.048, Slope8=0.05, Slope21=-0.055, Slope21a=0.07, Slope13=0.1 , Slope13a=0.001;
  double Slope21Thres=0.10, Slope13ThresH1=0.17, Slope13ThresH2=0.25, Slope8ThresH1=0.2, Slope8ThresH2=0.35;
  int iBack=3, iLookBack=5;
  //WTI atr is big, so need to reduce
  dist13_21 = MathAbs(EMA13[pos]-SMA21[pos])/atr;
  dist5_13 = MathAbs(EMA5[pos]-EMA13[pos])/atr;
  dist8_13 = MathAbs(SMA8[pos]-EMA13[pos])/atr;
  dist8_21 = MathAbs(SMA8[pos]-SMA21[pos])/atr;
  dist8_63 = MathAbs(SMA8[pos]-SMA63[pos])/atr;

  slope5a = ((EMA5[pos]-EMA5[pos-iBack])/atr)/iBack;  //curr slope for 2 bars
  slope5 = ((EMA5[pos]-EMA5[pos-iLookBack])/atr)/iLookBack; //prev slope
  slope8 = ((SMA8[pos]-SMA8[pos-iLookBack])/atr)/iLookBack; //prev slope
  slope8a = ((SMA8[pos]-SMA8[pos-iBack])/atr)/iBack;  //curr slope for 2 bars
  slope13 = ((EMA13[pos]-EMA13[pos-iBack])/atr)/iBack; //prev slope
  slope13a = ((EMA13[pos]-EMA13[pos-iBack])/atr)/iBack;  //curr slope for 2 bars
  slope21 = ((SMA21[pos]-SMA21[pos-iLookBack])/atr)/iLookBack; //prev slope
  slope21a = ((SMA21[pos]-SMA21[pos-iBack])/atr)/iBack;  //curr slope for 2 bars
  slope42 = ((SMA42[pos]-SMA42[pos-iLookBack])/atr)/iLookBack; //prev slope
  
  if (sDir=="Up" && slope8>Slope8 && slope13>Slope13 && slope21>Slope21 && slope42>Slope21 ) {  //basic criteria && dist13_21<Dist3M_21 && dist8_21<Dist3M_21
    bPass=true;
    //if 21 is less than 0.12 , 8 and 13 must be more than 0.12, we use Slope21Thres
    if (slope21<Slope21Thres && !(slope8>Slope8ThresH1 || slope13>Slope13ThresH1)) { bPass=false; }
    if (slope13a<Slope13a || slope13<Slope13) bPass=false; //slope13a not steep enough 
    if (debug) Print ("inside:", bPass, "   ", slope13<Slope13);
    if (slope5a<-Slope5a) bPass=false; //slope5a can't slope against too much
    if (dist8_13>Dist8_13ThresH && slope13<Slope13ThresH2) {bPass=false;}//slope13 must be steep enough if dist8_13 is greater than 0.6
    if (dist13_21>Dist13_21ThresH && slope13<Slope13ThresH2) {bPass=false;}  
    if (dist5_13>Dist5_13 || dist8_21>Dist8_21) bPass=false; //dist5_13 can't be too big
  }
  if (sDir=="Down" && slope8<-Slope8 && slope13<-Slope13 && slope21<-Slope21 && slope42<-Slope21) {  // && dist13_21<Dist3M_21 && dist8_21<Dist3M_21
    bPass=true; 
    //if 21 is less than 0.12 , 8 and 13 must be more than 0.12
    if (slope21>-Slope21Thres && !(slope8<-Slope8ThresH1 || slope13<-Slope13ThresH1) ) { bPass=false; }
    if (slope13a>-Slope13a || slope13>-Slope13) bPass=false; //slope8a not steep enough, 8can't be too far from 21    
    if (debug) Print ("Inside: ", bPass,"  ");
    if (slope5a>Slope5a) {bPass=false;} //slope5a can't slope against too much
    if (dist8_13>Dist8_13ThresH && slope13>-Slope13ThresH2) {bPass=false;} //slope13 must be steep enough if dist8_13 is greater than 0.6
    if (dist13_21>Dist13_21ThresH && slope13>-Slope13ThresH2) {bPass=false;}
    if (dist5_13>Dist5_13 || dist8_21>Dist8_21) bPass=false; //dist5_13 can't be too big 
  }
  
  if (debug && debugUp) Print( "Up 3M Filter: ", slope13a>Slope13a , " ", slope21>Slope21 ," ", 
   slope42>Slope21 ," ", dist5_13<Dist5_13," ", dist8_21<Dist8_21 );
  if (debug && !debugUp) Print( "Down 3M Filter: ", slope21<-Slope21, " ",slope13<-Slope13 ," ", 
   slope42<-Slope21 ," ", dist5_13<Dist5_13," ", dist8_21<Dist8_21 );
  if (debug) Print ("slope8: ", RoundN(slope8), " Slope8a: ", RoundN(slope8a), " slope13: ", RoundN(slope13),
   " slope13a: ", RoundN(slope13a)," slope42: ", RoundN(slope42), " slope21: ", RoundN(slope21));
  string sOut = rates[pos].time +", "+ RoundN(dist8_63)+", "+ RoundN(dist8_13)+", "+ RoundN(dist13_21)+", "+RoundN(slope8)+ ", "+
   RoundN(slope8a)+", "+ RoundN(slope13)+ ", "+RoundN(slope13a)+", "+ RoundN(slope21)+", "+ RoundN(slope21a);
  if (debug) WriteToFile(sOut);
  if (debug) Print ("3M filter Pass-fail: ", bPass , " Dist5_13: ", RoundN(dist5_13), " Dist13_21: ", RoundN(dist13_21)," dist8_13: ", RoundN(dist8_13), 
   " dist8_63: ", RoundN(dist8_63));
  
  return bPass;
  
}
bool BWup(int pos, int i, double atr) {
  bool bRes=false;
  double barHgt, barHgtPrev;
  double MinHgt=0.16, MaxHgt=3.2;
  barHgt = MathAbs(rates[pos].open - rates[pos].close)/atr;
  barHgtPrev=MathAbs(rates[pos-1].open - rates[pos-1].close)/atr;
  if (barHgt<MinHgt || barHgtPrev<MinHgt || barHgt>MaxHgt) return false; //exit function if bar too small
  //first bar don't need to body cross MA
  if (rates[pos].open < MA[i] && rates[pos].close > MA[i] && rates[pos-1].close < rates[pos-1].open) {
    bRes=true;
  }
  if (debug) Print ("BWUp ", bRes, " MA ", i );
  return bRes;
}

bool BWdown(int pos, int i, double atr) {
  bool bRes=false;
  double barHgt, barHgtPrev;
  double MinHgt=0.16, MaxHgt=3.2;  
  barHgt = MathAbs(rates[pos].open - rates[pos].close)/atr;
  barHgtPrev=MathAbs(rates[pos-1].open - rates[pos-1].close)/atr;
  if (barHgt<MinHgt || barHgtPrev<MinHgt || barHgt>MaxHgt) return false; //exit function if bar too small
  //first bar don't need to body cross MA
  if (rates[pos].open > MA[i] && rates[pos].close < MA[i] && rates[pos-1].close > rates[pos-1].open) {
    bRes=true;
  }
  if (debug) Print ("BWdown ", bRes, " MA ", i, " hgt ", RoundN(barHgt));
  return bRes;
}




//Filter for slope of 8 and 13 for lookback 1 give score to acceleration
bool CheckBack(int pos, double atr) {
  bool bPass=false, bFirst8_21=true, bFirst5_21=true, bFirst5_13=true, bFirst5_8=true;
  double Diverge8_21=0.9, Diverge5_21=0.9, Diverge5_13=0.5, Diverge5_8=0.5;
  double Dist8_21=0.88, Dist5_21=1.8, Dist5_13=0.7, ROC13=0.62, ROC8=0.75, ROC5=0.01;
  double Slope13=0.08, Slope8=0.06, Slope21=0.08;
  double distFirst8_21, distLast8_21 , distFirst5_21, distLast5_21, distFirst5_13, distLast5_13, distFirst5_8, distLast5_8;
  double dist5_13, dist5_21, dist8_21;
  double slope5, slope8, slope13, prevSlope5, prevSlope8, prevSlope13, slope21;
  int iBack=2;

  distLast8_21 = (SMA8[pos]-SMA21[pos])/atr;
  distLast5_21 = (EMA5[pos]-SMA21[pos])/atr;
  distLast5_13 = (EMA5[pos]-EMA13[pos])/atr;
  distLast5_8 = (EMA5[pos]-SMA8[pos])/atr;

  slope5 = ((EMA5[pos]-EMA5[pos-1])/atr)/iBack;  //curr slope for 2 bars
  prevSlope5 = ((EMA5[pos-2]-EMA5[pos-3])/atr)/iBack; //prev slope
  slope8 = ((SMA8[pos]-SMA8[pos-2])/atr)/iBack;  //curr slope for 2 bars
  prevSlope8 = ((SMA8[pos-3]-SMA8[pos-5])/atr)/iBack; //prev slope
  slope13 = ((EMA13[pos]-EMA13[pos-2])/atr)/iBack;  //curr slope for 2 bars
  prevSlope13 = ((EMA13[pos-3]-EMA13[pos-5])/atr)/iBack; //prev slope

  for (int i=6; i>0; i--) {
    dist5_13 = (EMA5[pos-i]-EMA13[pos-i])/atr;
    dist5_21 = (EMA5[pos-i]-SMA21[pos-i])/atr;
    dist8_21 = (SMA8[pos-i]-SMA21[pos-i])/atr;
    slope13 = ((EMA13[pos-i]-EMA13[pos-iBack-i])/atr)/iBack;   
    //store values of first and last dist of 8 and 13
    //If last is positive, First need to be positive as well, the position of First is dynamic
    if (bFirst8_21 && ((distLast8_21>0 && dist8_21>0) || (distLast8_21<0 && dist8_21<0))) { 
      distFirst8_21 = dist8_21;
      bFirst8_21=false;
      //if (debug1) Print(i, " distFirst8_21: " , RoundN(distFirst8_21));
    }
    if (bFirst5_21 && ((distLast5_21>0 && dist5_21>0) || (distLast5_21<0 && dist5_21<0))) { 
      distFirst5_21 = dist5_21;
      bFirst5_21=false;
    }    
    if (bFirst5_13 && ((distLast5_13>0 && dist5_13>0) || (distLast5_13<0 && dist5_13<0))) { 
      distFirst5_13 = dist5_13;
      bFirst5_13=false;
    }

    //previous slope need to be flat 
    if (debug) Print("3M_Filter: ", i, " slope8: ",RoundN(slope8), " slope13: ",RoundN(slope13), " slope21: ",RoundN(slope21) , 
     " dist8_21: ",RoundN(dist8_21) , " dist5_21: ",RoundN(dist5_21));
  }//for
  double diverge8_21 = MathAbs((distLast8_21-distFirst8_21)); // find ROC of dist 8 13 diverge8_21 /distFirst8_21); 
  double diverge5_21 = MathAbs((distLast5_21-distFirst5_21)); // find ROC of dist 8 13 diverge5_21
  double diverge5_13 = MathAbs((distLast5_13-distFirst5_13)); // find ROC of dist 8 13 diverge5_13
  if (debug) Print (diverge8_21<Diverge8_21, " ", diverge5_21<Diverge5_21, " ", diverge5_13<Diverge5_13, " ", MathAbs(distLast5_21)<Dist5_21, " ",MathAbs(distLast5_13)<Dist5_13);
  if (debug) Print(" diverge8_21: ", RoundN(diverge8_21), " diverge5_21: ", RoundN(diverge5_21) ,
    " diverge5_13: ", RoundN(diverge5_13), " Dist8-21: ", RoundN(distLast8_21), " Dist5_13: ", RoundN(distLast5_13), " Dist5_21: ", RoundN(distLast5_21) );
  //if dist of 8_13 is more than 0.5 than Diverge can't be more than 0.6
  if (diverge8_21<Diverge8_21 && diverge5_21<Diverge5_21 && diverge5_13<Diverge5_13 && 
   MathAbs(distLast5_21)<Dist5_21 && MathAbs(distLast5_13)<Dist5_13 ) {  // 
    bPass=true;
  }
  if (debug) Print("3M_Filter: ", bPass);
  return bPass;
}
void WriteToFile(string sString) {
  int file_handle=FileOpen("Output.csv",FILE_WRITE|FILE_CSV);
  FileWriteString(file_handle,sString);
  FileClose(file_handle);
}

bool Filter_RiverBU(int pos, double atr) {
  bool bPass=false, bFirst8_21=true, bFirst5_21=true, bFirst5_13=true, bFirst5_8=true;
  double Diverge8_21=0.9, Diverge5_21=0.9, Diverge5_13=0.5, Diverge5_8=0.5;
  double Dist8_21=0.88, Dist5_21=1.8, Dist5_13=0.7, ROC13=0.62, ROC8=0.75, ROC5=0.01;
  double Slope13=0.08, Slope8=0.06, Slope21=0.08;
  double distFirst8_21, distLast8_21 , distFirst5_21, distLast5_21, distFirst5_13, distLast5_13, distFirst5_8, distLast5_8;
  double dist5_13, dist5_21, dist8_21;
  double slope5, slope8, slope13, prevSlope5, prevSlope8, prevSlope13, slope21;
  int iBack=2;

  distLast8_21 = (SMA8[pos]-SMA21[pos])/atr;
  distLast5_21 = (EMA5[pos]-SMA21[pos])/atr;
  distLast5_13 = (EMA5[pos]-EMA13[pos])/atr;
  distLast5_8 = (EMA5[pos]-SMA8[pos])/atr;

  slope5 = ((EMA5[pos]-EMA5[pos-1])/atr)/iBack;  //curr slope for 2 bars
  prevSlope5 = ((EMA5[pos-2]-EMA5[pos-3])/atr)/iBack; //prev slope
  slope8 = ((SMA8[pos]-SMA8[pos-2])/atr)/iBack;  //curr slope for 2 bars
  prevSlope8 = ((SMA8[pos-3]-SMA8[pos-5])/atr)/iBack; //prev slope
  slope13 = ((EMA13[pos]-EMA13[pos-2])/atr)/iBack;  //curr slope for 2 bars
  prevSlope13 = ((EMA13[pos-3]-EMA13[pos-5])/atr)/iBack; //prev slope
  double roc13 =slope13/prevSlope13;
  double roc8 =slope8/prevSlope8;
  double roc5=slope5/prevSlope5;
  if (roc5<0) roc5=10; //if prev slope is neg and curr slope is positive
  if (roc8<0) roc8=10; //if prev slope is neg and curr slope is positive
  if (roc13<0) roc13=10; //if prev slope is neg and curr slope is positive

//if (debug) Print (slope8, " ", prevSlope8);
  for (int i=6; i>0; i--) {
    dist5_13 = (EMA5[pos-i]-EMA13[pos-i])/atr;
    dist5_21 = (EMA5[pos-i]-SMA21[pos-i])/atr;
    dist8_21 = (SMA8[pos-i]-SMA21[pos-i])/atr;
    slope13 = ((EMA13[pos-i]-EMA13[pos-iBack-i])/atr)/iBack;   
    //store values of first and last dist of 8 and 13
    //If last is positive, First need to be positive as well, the position of First is dynamic
    if (bFirst8_21 && ((distLast8_21>0 && dist8_21>0) || (distLast8_21<0 && dist8_21<0))) { 
      distFirst8_21 = dist8_21;
      bFirst8_21=false;
      //if (debug1) Print(i, " distFirst8_21: " , RoundN(distFirst8_21));
    }
    if (bFirst5_21 && ((distLast5_21>0 && dist5_21>0) || (distLast5_21<0 && dist5_21<0))) { 
      distFirst5_21 = dist5_21;
      bFirst5_21=false;
    }    
    if (bFirst5_13 && ((distLast5_13>0 && dist5_13>0) || (distLast5_13<0 && dist5_13<0))) { 
      distFirst5_13 = dist5_13;
      bFirst5_13=false;
    }

    //previous slope need to be flat 
    if (debug) Print("3M_Filter: ", i, " slope8: ",RoundN(slope8), " slope13: ",RoundN(slope13), " slope21: ",RoundN(slope21) , 
     " dist8_21: ",RoundN(dist8_21) , " dist5_21: ",RoundN(dist5_21));
  }//for
  double diverge8_21 = MathAbs((distLast8_21-distFirst8_21)); // find ROC of dist 8 13 diverge8_21 /distFirst8_21); 
  double diverge5_21 = MathAbs((distLast5_21-distFirst5_21)); // find ROC of dist 8 13 diverge5_21
  double diverge5_13 = MathAbs((distLast5_13-distFirst5_13)); // find ROC of dist 8 13 diverge5_13
  if (debug) Print ( diverge8_21<Diverge8_21, " ", diverge5_21<Diverge5_21, " ", diverge5_13<Diverge5_13, " ", MathAbs(distLast5_21)<Dist5_21, " ",MathAbs(distLast5_13)<Dist5_13);
  if (debug) Print(" diverge8_21: ", RoundN(diverge8_21), " diverge5_21: ", RoundN(diverge5_21) ,
    " diverge5_13: ", RoundN(diverge5_13), " Dist8-21: ", RoundN(distLast8_21), " Dist5_13: ", RoundN(distLast5_13), " Dist5_21: ", RoundN(distLast5_21) );
  //if dist of 8_13 is more than 0.5 than Diverge can't be more than 0.6
  if ( true ) {  // 
    bPass=true;
  }
  if (debug) Print("3M_Filter: ", bPass);
  return bPass;
}

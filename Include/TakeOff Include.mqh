int LookBack3M_TakeOff = 3;
int LookBack_TakeOff = 7;
int LookBackBuffer_TakeOff = 30;
//double Gradient1=0.004; //good
input double Gradient1=0.05;
//input double Dist21_42=0.6;
double Dist21_42=1.9;
double Dist84_126=6.8;
double Dist42_63=1.9;
double Dist21_63=3.5;
double Dist5_126=1.4;
double Dist8_21=2.0;
double Slope5=-0.6, Slope8=0.01, Slope21=0.02, Slope42=0.03, PriceControl=2.5;
double R1Slope=0.03, R2Slope=0.02;

bool bFirstSigUp=true; //for prevent subsequent signals
bool bFirstSigDown=true; //for prevent subsequent signals

bool debugDn = false;
bool debugUp = true;

//for Expert Advisor
string TakeOff(string sSymbol, ENUM_TIMEFRAMES TF, float &atr) {
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
  
  int iToCopy = LookBackBuffer_TakeOff;
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

  int pos=iToCopy-2;  //i is the last closed bar, for tracking current closed bar
  string sSignal="", sRes;

  //pass by ref
  atr=ATR[pos];

  sRes=fnTakeOff(pos, sSymbol);
  return sRes;
}
//for both EA and Indicator
string fnTakeOff(int pos, string sSymbol) {
  string sResults; 
  double atr=ATR[pos];
  int iPreventSig=0;
  if (atr==0) return 0;
  //assign MA values array
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
  
  double slope8 = ((SMA8[pos] - SMA8[pos-2])/atr)/2;
  double slope5 = ((EMA5[pos] - EMA5[pos-3])/atr)/3;
  MA_Tan[0]= ((EMA5[pos] - EMA5[pos-LookBack3M_TakeOff])/atr)/LookBack3M_TakeOff;
  MA_Tan[1]= ((SMA8[pos] - SMA8[pos-LookBack3M_TakeOff])/atr)/LookBack3M_TakeOff;
  MA_Tan[2]= ((EMA13[pos] - EMA13[pos-LookBack3M_TakeOff])/atr)/LookBack3M_TakeOff; //3M LookBack3M_TakeOff is different from the big MAs
  MA_Tan[3]= ((SMA21[pos] - SMA21[pos-LookBack_TakeOff])/atr)/LookBack_TakeOff;
  MA_Tan[4]= ((SMA42[pos] - SMA42[pos-LookBack_TakeOff])/atr)/LookBack_TakeOff;  
  MA_Tan[5]= ((SMA63[pos] - SMA63[pos-LookBack_TakeOff])/atr)/LookBack_TakeOff;
  MA_Tan[6]= ((SMA84[pos] - SMA84[pos-LookBack_TakeOff])/atr)/LookBack_TakeOff;
  MA_Tan[7]= ((SMA126[pos] - SMA126[pos-LookBack_TakeOff])/atr)/LookBack_TakeOff;
  MA_Tan[8]= ((SMA168[pos] - SMA168[pos-LookBack_TakeOff])/atr)/LookBack_TakeOff;
  MA_Tan[9]= ((SMA252[pos] - SMA252[pos-LookBack_TakeOff])/atr)/LookBack_TakeOff;
  MA_Tan[10]= ((SMA336[pos] - SMA336[pos-LookBack_TakeOff])/atr)/LookBack_TakeOff;
  MA_Tan[11]= ((SMA630[pos] - SMA630[pos-LookBack_TakeOff])/atr)/LookBack_TakeOff;
    
  //double Dist21_42=0.9, Dist5_21=1.5, Dist21_63=2.0, Dist5_126=2.8, Dist42_63=0.6, DistPrice_8=0.7;
  //double Dist63_126=1.8, Dist21_42=0.9, Dist21_63=2.0; //win
  bool b21UpSlope=false, b8UpSlope=false;
  bool b21DownSlope=false, b8DownSlope=false;
  //use LookBack_TakeOff 1 for slope of sma8
  //current price distance to sma8/21
  double prcCtrl = MathAbs(MA[0]-MA[4])/atr;   //close price dist to 42
  double dist8_21=MathAbs(MA[1]-MA[3])/atr; //sma8 to 21 dist
  double dist84_126=MathAbs(MA[5]-MA[7])/atr; // 63 to 126
  double dist5_126=MathAbs(MA[0]-MA[5])/atr; //ema5 to 63 dist
  double dist21_63=MathAbs(MA[3]-MA[5])/atr; //21 to 21 dist
  double dist21_42=MathAbs(MA[3]-MA[4])/atr;
  double dist42_63=MathAbs(MA[4]-MA[5])/atr;
  
  // River one need to be more than 0.025
  //buy signal
  bool b8SlopeUp = slope8>Slope8;
  bool b5SlopeUp = slope5>Slope5;
  //bool b13SlopeUp = MA_Tan[2]>Slope8;
  bool b42SlopeUp = MA_Tan[4]>Slope42;
  bool bR1SlopeUp = (MA_Tan[5]>R1Slope || MA_Tan[6]>R1Slope); //only one MA need to be up
  bool bR2SlopeUp = (MA_Tan[7]>R2Slope && MA_Tan[8]>R2Slope);  //both MA need to be up
  
  //bool bDist8_13 = dist8_13<Dist8_13;
  //bool bDist5_13 = dist5_13<Dist5_13;
  bool bDist5_126 = dist5_126<Dist5_126;
  bool bPrice_greater_21_Up = rates[pos].close>MA[3];
  bool bDist8_21 = dist8_21<Dist8_21;
  bool bDist21_63 = dist21_63<Dist21_63;
  bool bDist21_42 = dist21_42<Dist21_42;
  bool bDist42_63 = dist42_63<Dist42_63;
  bool bDist84_126 = dist84_126<Dist84_126;
  bool b13_higher_R1 = (MA[1]>MA[5]) || (MA[1]>MA[6]);
  bool b21_higher_R1 = (MA[3]>MA[5]) || (MA[3]>MA[6]);
  bool b13_lower_R1 = (MA[1]<MA[5]) || (MA[1]<MA[6]);
  bool b21_lower_R1 = (MA[3]<MA[5]) || (MA[3]<MA[6]);
  bool b5_greater_42_Up = MA[0]>MA[4];
  bool b63_greater_126_252_Up = MA[5]>MA[7] && MA[5]>MA[8];
  bool b84_greater_126_252_Up = MA[6]>MA[7] && MA[6]>MA[8];
  
  bool b21Tan_Up = MA_Tan[3]>-0.03;
  bool b42Tan_Up = MA_Tan[4]>-0.03;
  bool bPriceCtrl = prcCtrl<PriceControl;
  //21 can go against for 0.02
  if ( ScoreMAUp(pos,atr) && b13_higher_R1 && b21_higher_R1 && bDist8_21 && bDist21_42 && bDist21_63 && bDist84_126 && bDist42_63 
  && CheckNearUp(pos,atr) && CheckBackUp(pos,atr) && (bPriceCtrl) ) {
    sResults="Up";
  }
  if ( ScoreMADown(pos,atr) && b13_lower_R1 && b21_lower_R1 && bDist8_21 && bDist21_42 && bDist21_63 && bDist84_126 && bDist42_63 
  && CheckNearDown(pos,atr) && CheckBackDown(pos,atr) && (bPriceCtrl) ) {
    sResults="Down";
  }
  if (debug && debugUp) Print ("Up ",b13_higher_R1," ",b21_higher_R1," ", bDist8_21," ", bDist21_42," ",bDist21_63," ", bDist84_126,
    " ", bDist42_63," ", bPriceCtrl );
  if (debug && debugDn) Print ("Down ", bDist8_21," ",bDist21_42," ",bDist21_63," ", bDist84_126,
    " ", bDist42_63," ", bPriceCtrl );

  if (debug && (debugUp || debugDn)) Print ("21: ", RoundN(MA_Tan[3])," 63: ", RoundN(MA_Tan[5])," 84: ", RoundN(MA_Tan[6])," dist21_63: ", 
   RoundN(dist21_63)," dist42_63: ",RoundN(dist42_63)," dist84_126: ",RoundN(dist84_126)," "," dist8_21: ",
   RoundN(dist8_21)," PrcCtrl: ", RoundN(prcCtrl) );
  
  return (sResults);
}

//Need to have min. number MA that is up for a good trend
bool ScoreMAUp(int pos, double atr) {
  bool bRes=false, bR1Slope=false;
  int iScore=0;
  double slope1=0.01, slope2=0.024, slope3=0.05, slope21=0.035;

  for (int i=3; i<=6; i++) { //21 to R1, 3 of the 4 MAs should be steep enough to get score of 6
    if (MA_Tan[i]>slope1) {iScore=iScore+1;} //count number of MA that slope in favour  
    if (MA_Tan[i]>slope2) {iScore=iScore+1;} //add more score if more than slope2
    if ( (i==3 || i==4) && MA_Tan[i]<-slope21 ) { iScore=iScore-7; }  //21 and 42 can't slope too much against
    if ((i==5 || i==6) && MA_Tan[i]<-slope3) { iScore=iScore-4; }  //one of R1 can't slope against
    if ((i==5 || i==6) && MA_Tan[i]>slope1) { bR1Slope=true; }  //one of R1 must be steep enough
    if (debug && debugUp) Print("ScoreMAUp: ", i, " ", " Tan: ", RoundN(MA_Tan[i]), " Score: ", iScore);
  }//for
  for (int i=7; i<=8; i++) { //R2 add score of 1 if slope in favor
    if (MA_Tan[i]>slope1) {iScore=iScore+1;} //count number of MA that slope in favour
    if (MA_Tan[i]>slope2) {iScore=iScore+1;} //add more score if more than slope2    
    if (MA_Tan[i]<-slope3) { iScore=iScore-1; }  //R1 can't slope too much against
    if (debug && debugUp) Print("ScoreMAUp: ", i, " ", " Tan: ", RoundN(MA_Tan[i]), " Score: ", iScore);
  }//for  
  if (iScore>=9 && bR1Slope) bRes=true; 
  if (debug && debugUp) Print("ScoreMAUp: ", bRes);  // need to have 4 MA out of 6 to be up slope
  
  return bRes;
}

//Need to have min. number MA that is up for a good trend
bool ScoreMADown(int pos, double atr) {
  bool bRes=false, bR1Slope=false;
  int iScore=0;
  double slope1=0.001, slope2=0.024, slope3=0.05, slope21=0.035;

  for (int i=3; i<=6; i++) { //21 to R1, 3 of the 4 MAs should be steep enough to get score of 6
    if (MA_Tan[i]<-slope1) {iScore=iScore+1;} //count number of MA that slope in favour
    if (MA_Tan[i]<-slope2) {iScore=iScore+1;} //add more for slope2
    if ((i==3 || i==4) && MA_Tan[i]>slope21) { iScore=iScore-7; }  //21 and 42 can't sleep against too much
    if ((i==5 || i==6) && MA_Tan[i]>slope3) { iScore=iScore-4; }  //slope against, deduct points
    if ((i==5 || i==6) && MA_Tan[i]<-slope1) { bR1Slope=true; }   //one of R1 must be steep enough  
    if (debug && debugDn) Print("ScoreMADown: ", i, " ", " Tan: ", RoundN(MA_Tan[i]), " Score: ", iScore, " ", bR1Slope);
  }//for
  for (int i=7; i<=8; i++) { //R2 add score of 1 if slope in favor
    if (MA_Tan[i]<-slope1) {iScore=iScore+1;} //count number of MA that slope in favour
    if (MA_Tan[i]<-slope2) {iScore=iScore+1;} //count number of MA that slope in favour    
    if (MA_Tan[i]>slope3) { iScore=iScore-1; }  //R1 can't slope too much against
    if (debug && debugDn) Print("ScoreMADown: ", i, " ", " Tan: ", RoundN(MA_Tan[i]), " Score: ", iScore);
  }//for    
  if (iScore>=9 && bR1Slope) bRes=true; 
  if (debug && debugDn) Print("ScoreMADown: ", bRes);   // need to have 4 MA out of 6 to be up slope
  
  return bRes;
}

//check MA that slope down and above 5, need to filter
bool CheckNearUp(int pos, double atr) {
  bool bRes=false;
  double NearUp = EMA13[pos] + atr*4.0;
  int iCount=0;
  double Slope1=-0.01, Slope2=-0.02, Slope3=-0.04, Slope4=-0.08, slope3M_1=-0.2, slope3M_2=-0.3;  //Slope1=-0.03,
  //for R1 and above we filter MA above/below in our way
  for (int i=3; i<12; i++) {  //MA5 to MA11
    if (i>4 && MA[i]<NearUp && MA[i]>EMA13[pos]) { //buffer for MA that is above 13 as well
      if (MA_Tan[i]<Slope1) {iCount=iCount+1;} //count number of MA that slope against 
      if (MA_Tan[i]<Slope2) {iCount=iCount+2;} //add one more score if MA is steeper, if only one MA so steep, for R3 we add more, disallow
      //if (i>8 && MA_Tan[i]<Slope3) {iCount=iCount+1;} //R3 we tolerate more
      //if (i>8 && MA_Tan[i]<Slope4) {iCount=iCount+2;}
      if (debug && debugUp) Print("CheckNearUp: ", i, " ", RoundN(MA[i]), " Tan: ", RoundN(MA_Tan[i]), " count: ", iCount);
    }
  }//for

  //if 3M steep enough we compensate the count
  if (MA_Tan[1]<slope3M_1 || MA_Tan[2]<slope3M_1) {iCount=iCount+2;}  //if 3M go against too much we give demerit
  
  if (iCount<3) {bRes=true;} //can't have more than 1 MA slope against
  if (debug && debugUp) Print("CheckNearUp Res: ", bRes, " count ", iCount);
  return bRes;
}

//check MA that slope up and above 5, need to filter
bool CheckNearDown(int pos, double atr) {
  bool bRes=false;
  double NearDown = EMA13[pos] - atr*4.0;
  int iCount=0;
  double Slope1=0.01, Slope2=0.02, Slope3=0.04, Slope4=0.08, slope3M_1=0.2, slope3M_2=0.3;  //Slope1=-0.03,
  //for R1 and above we filter MA above/below in our way
  for (int i=3; i<12; i++) {
    if (i>4 && MA[i]>NearDown && MA[i]<(EMA13[pos])) {
      if (MA_Tan[i]>Slope1) {iCount=iCount+1;} //count number of MA that slope against and must be steeper than -0.01
      if (MA_Tan[i]>Slope2) {iCount=iCount+2;} //add one more score if MA is steeper, if only one MA so steep, for R3 we add more, disallow
      //if (i>8 && MA_Tan[i]>Slope3) {iCount=iCount+1;} //R3 we tolerate more
      //if (i>8 && MA_Tan[i]>Slope4) {iCount=iCount+2;}
      //if (debug && debugDn) Print("CheckNearDown ", i, " MA ", RoundN(MA[i]), " Tan: ", RoundN(MA_Tan[i]), " ", iCount);
    }
  }//for
  //if 3M go against too much we give demerit
  if (MA_Tan[1]>slope3M_1 || MA_Tan[2]>slope3M_1) {
    iCount=iCount+2;
    if (debug && debugDn) Print("CheckNearDown 3M against ", " slope ", RoundN(MA_Tan[1]));
  }  
  
  if (iCount<3) {bRes=true;} //can't have more than 1 MA slope against
  if (debug && debugDn) Print("CheckNearDown Res: ", bRes, " count ", iCount);
  return bRes;
}

//check back to see if price came down from high
bool CheckBackUp(int pos, double atr) {
  bool bPass=true;
  double Dist=-2.9, Dist42=-1.7;

  for (int i=0; i<=12; i++) {
    double dist=(rates[pos].close-rates[pos-i].close)/atr;  //for up trades the price can't come down from too high
    double dist42=(SMA42[pos-i]-SMA8[pos-i])/atr;  //for up trades the price can't come down from too high
    if (debug) Print ("Checkback: ",rates[pos-i].time," ", RoundN(dist), " ", RoundN(dist42));
    if (dist<Dist || dist42<Dist42) { //the price came down 
      bPass=false;
    }//if
  }//for
  if (debug) Print("CheckBackUp: ", bPass);
  return bPass;
}

//check back to see if price came down from high
bool CheckBackDown(int pos, double atr) {
  bool bPass=true;
  double Dist=2.9, Dist42=1.7;

  for (int i=0; i<=12; i++) {
    double dist=(rates[pos].close-rates[pos-i].close)/atr;  //for up trades the price can't come down from too high
    double dist42=(SMA42[pos-i]-SMA8[pos-i])/atr;  //for up trades the price can't come down from too high    
    if (debug) Print ("CheckbackDown: ",rates[pos-i].time," ", RoundN(dist), " ", RoundN(dist42));
    if (dist>Dist || dist42>Dist42) { //the price came Up 
      bPass=false;
    }//if
  }//for
  if (debug) Print("CheckBack: ", bPass);
  return bPass;
}

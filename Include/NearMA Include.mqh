input int ATR_Factor = 21;  
int LookBack3M = 5;
int LookBack = 21;
int LookBackBuffer = 30;
input double Gradient_21=0.15;
double Gradient1=0.02;
input double Gradient2=0.03;
input double Gradient3=0.06;
input double GradientFilter=0.15;
int MinUpDown = 5;
int MinScore = 1;


//for Expert Advisor
string NearMA(string sSymbol, ENUM_TIMEFRAMES TF, float &atr) {
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
  
  int iToCopy = LookBackBuffer;
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
  int score;
  //pass by ref
  atr=ATR[pos];
  score=MA_Score_NearMA(pos);

  if (score>=MinUpDown) {
    sRes="Up";
  }
  if (score<=-MinUpDown) {
    sRes="Down";
  }
  
  return sRes;  
}
//for both EA and Indicator
int MA_Score_NearMA(int pos) {
//calculate total scores of all MA slopes add together to get either positive or negative score.
//if MA is near ema5 it will get a higher weightage
  int ScoreUp=0, ScoreDown=0;
  int iResults; 
  bool SlopeUp_21=false, SlopeDown_21=false, Steep21Up=false, Steep21Down=false;
  double MA_Tan[12], MA_Tan5[12], MA[12];
  double atr=ATR[pos];
  if (atr==0) return 0;
  
  //NearUp and Down are not used at the moment
  double NearUp1 = EMA5[pos] + atr*2.5;
  double NearDown1 = EMA5[pos] - atr*2.5;
  double NearUp2 = EMA5[pos] + atr*2.5;
  double NearDown2 = EMA5[pos] - atr*2.5;
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
  
  MA_Tan[0]= ((EMA5[pos] - EMA5[pos-LookBack3M])/atr)/LookBack3M;
  MA_Tan[1]= ((SMA8[pos] - SMA8[pos-LookBack3M])/atr)/LookBack3M;
  MA_Tan[2]= ((EMA13[pos] - EMA13[pos-LookBack3M])/atr)/LookBack3M; //3M LookBack3M is different from the big MAs
  MA_Tan[3]= ((SMA21[pos] - SMA21[pos-LookBack3M])/atr)/LookBack3M;
  MA_Tan[4]= ((SMA42[pos] - SMA42[pos-LookBack])/atr)/LookBack;
  MA_Tan[5]= ((SMA63[pos] - SMA63[pos-LookBack])/atr)/LookBack;
  MA_Tan[6]= ((SMA84[pos] - SMA84[pos-LookBack])/atr)/LookBack;
  MA_Tan[7]= ((SMA126[pos] - SMA126[pos-LookBack])/atr)/LookBack;
  MA_Tan[8]= ((SMA168[pos] - SMA168[pos-LookBack])/atr)/LookBack;
  MA_Tan[9]= ((SMA252[pos] - SMA252[pos-LookBack])/atr)/LookBack;
  MA_Tan[10]= ((SMA336[pos] - SMA336[pos-LookBack])/atr)/LookBack;
  MA_Tan[11]= ((SMA630[pos] - SMA630[pos-LookBack])/atr)/LookBack;
  
  MA_Tan5[4]= ((SMA42[pos] - SMA42[pos-LookBack3M])/atr)/LookBack3M;
  MA_Tan5[5]= ((SMA63[pos] - SMA63[pos-LookBack3M])/atr)/LookBack3M;
  MA_Tan5[6]= ((SMA84[pos] - SMA84[pos-LookBack3M])/atr)/LookBack3M;
  MA_Tan5[7]= ((SMA126[pos] - SMA126[pos-LookBack3M])/atr)/LookBack3M;
  MA_Tan5[8]= ((SMA168[pos] - SMA168[pos-LookBack3M])/atr)/LookBack3M;
  MA_Tan5[9]= ((SMA252[pos] - SMA252[pos-LookBack3M])/atr)/LookBack3M;
  MA_Tan5[10]= ((SMA336[pos] - SMA336[pos-LookBack3M])/atr)/LookBack3M;
  MA_Tan5[11]= ((SMA630[pos] - SMA630[pos-LookBack3M])/atr)/LookBack3M;
  
  double Tan13= (EMA13[pos] - EMA13[pos-1])/atr;

  float Dist5_21=1, Dist8_21=1.2, Dist5_13=0.75, Dist5_63=2.8, DistPrice_8=0.8;
  float Slope13=0.1, Slope21=0.2, Slope13_LB1=0.1;
  bool b21UpSlope=false, b8UpSlope=false;
  bool b21DownSlope=false, b8DownSlope=false;
  //use lookback 1 for slope of sma8
  float slope8=(SMA8[pos]-SMA8[pos-1])/atr;
  //for scoring of MA slopes up, skip ema 5
  //current price distance to sma8
  double priceTo8 =  MathAbs(SymbolInfoDouble(NULL,SYMBOL_BID)-MA[1])/atr;
  
  for (int i=0; i<=4; i++) {
    //slope up score
    if (MA_Tan[i] > Gradient1) {
      ScoreUp = ScoreUp + 1;
    }
    //reset toggles
    //slope down score
    if (MA_Tan[i] < -Gradient1) {
      ScoreDown = ScoreDown - 1;
    }    
    if (debug) Print("MA slope: ", i," ", RoundNumber(MA_Tan[i],3), " Lookback5: ", RoundNumber(MA_Tan5[i],3));    
  }//main loop 

  float dist5_21=MathAbs(MA[0]-MA[3])/atr; //ema5 to 63 dist
  float dist8_21=MathAbs(MA[1]-MA[3])/atr; // 63 to 126
  float dist5_13=MathAbs(MA[0]-MA[2])/atr; //ema5 to 63 dist
  float dist21_R1=MathAbs(MA[3]-MA[5])/atr; //21 to 21 dist
  //Print("tot score down: ", total_score_down, " ", -MinScore);
  if (debug) {Print("ScoreUp:", ScoreUp, " ScoreDown: ", ScoreDown); }
  //if (debug) {Print( "CounterDown ", CounterDown, " CounterUp ", CounterUp);}
  //21 need to be higher than 42
  // River one need to be more than 0.025
  //buy signal
  if (ScoreUp>=MinUpDown && dist8_21<Dist8_21 && dist5_13<Dist5_13 && CheckBack5_13(pos,atr) && CheckBack13_21(pos,atr) && 
  //priceTo8<DistPrice_8 && MA_Tan[3]>Slope21 && MA_Tan[2]>Slope13) {
  MA_Tan[3]>Slope21 && MA_Tan[2]>Slope13 && Tan13>Slope13_LB1) {
    iResults=ScoreUp;
  }
  else if (ScoreDown<=-MinUpDown && dist8_21<Dist8_21 && dist5_13<Dist5_13 && CheckBack5_13(pos,atr) && CheckBack13_21(pos,atr) && 
  MA_Tan[3]<-Slope21 && MA_Tan[2]<-Slope13 && Tan13<-Slope13_LB1) {
    iResults=ScoreDown;
  }
  else {
    iResults=0;    
  }
  
  if (iResults!=0) Print("PriceTo8 ", SymbolInfoDouble(NULL,SYMBOL_BID), " ", MA[1]);
  return (iResults);
}

//check back 5 bars to see if 5-21 distance is far
bool CheckBack13_21(int pos, double atr) {
  bool bPass=true;
  float Threshold=0.8;
  
  for (int i=0; i<=3; i++) {
    float dist=MathAbs(EMA13[pos-i]-SMA21[pos-i])/atr; //
  
    if (dist>Threshold) {
      bPass=false;
    }//if
  }//for
  return bPass;
}

//check back 5 bars to see if 5-21 distance is far
bool CheckBack5_13(int pos, double atr) {
  bool bPass=true;
  float Threshold=0.7;
  
  for (int i=0; i<=3; i++) {
    float dist=MathAbs(EMA13[pos-i]-SMA21[pos-i])/atr; //
  
    if (dist>Threshold) {
      bPass=false;
    }//if
  }//for
  return bPass;
}

bool ROC_NotSlow (int pos, string dir, double atr) {
  double MA_Tan1[7], MA_Tan2[7], MA_Tan3[7];
  bool res=false;

  //for ROC
  MA_Tan3[0]= (EMA5[pos] - EMA5[pos-1]) / atr;
  MA_Tan3[1]= (SMA8[pos] - SMA8[pos-1]) / atr;
  MA_Tan3[2]= (EMA13[pos] - EMA13[pos-1]) / atr;
  MA_Tan3[3]= (SMA21[pos] - SMA21[pos-1]) / atr;
  MA_Tan3[5]= (SMA42[pos] - SMA42[pos-1]) / atr;
  MA_Tan3[5]= (SMA63[pos] - SMA63[pos-1]) / atr;
  MA_Tan3[6]= (SMA84[pos] - SMA84[pos-1]) / atr;
  
  MA_Tan2[0]= (EMA5[pos-1] - EMA5[pos-2]) / atr;
  MA_Tan2[1]= (SMA8[pos-1] - SMA8[pos-2]) / atr;
  MA_Tan2[2]= (EMA13[pos-1] - EMA13[pos-2]) / atr;
  MA_Tan2[3]= (SMA21[pos-1] - SMA21[pos-2]) / atr;
  MA_Tan2[5]= (SMA42[pos-1] - SMA42[pos-2]) / atr;
  MA_Tan2[5]= (SMA63[pos-1] - SMA63[pos-2]) / atr;
  MA_Tan2[6]= (SMA84[pos-1] - SMA84[pos-2]) / atr;
  
  MA_Tan1[0]= (EMA5[pos-2] - EMA5[pos-3]) / atr;
  MA_Tan1[1]= (SMA8[pos-2] - SMA8[pos-3]) / atr;
  MA_Tan1[2]= (EMA13[pos-2] - EMA13[pos-3]) / atr;  
  MA_Tan1[3]= (SMA21[pos-2] - SMA21[pos-3]) / atr;
  MA_Tan1[4]= (SMA42[pos-2] - SMA42[pos-3]) / atr;
  MA_Tan1[5]= (SMA63[pos-2] - SMA63[pos-3]) / atr;
  MA_Tan1[6]= (SMA84[pos-2] - SMA84[pos-3]) / atr;

  //8 and 13 have to be together
  for (int i=1; i<=2; i++) {
    if  (dir=="Up" && !((MA_Tan1[i] > MA_Tan2[i]) && (MA_Tan2[i] > MA_Tan3[i]))) {  //ROC of 8, 13 didn't slow down for consecutive 3 bars
      res=true;
    }
    if (dir=="Down" && !((MA_Tan1[i] < MA_Tan2[i]) && (MA_Tan2[i] < MA_Tan3[i]))) {  //ROC of 8, 13 didn't slow down for consecutive 3 bars
      res=true;
    }
  }
  return res;
}

double RoundNumber(double number, int digits) {
  number = MathRound(number * MathPow(10, digits));  
  return (number * MathPow(10, -digits)); 
}
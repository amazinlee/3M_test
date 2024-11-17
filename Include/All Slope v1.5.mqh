//--- input parameters
input int LookBack = 7;
input int LookBackBuffer = 10;
double Gradient1=0.01;
double Gradient2=0.3;
double Gradient3=0.4;
input int  AllowCounterMA=0;
input double GradientFilter=2;

//ATR factor set to 3 to catch the recent ATF, so more buffer for volatility
int MinUpDown = 4;
int MinCoreMA = 5;
int MinScore = 1;

int MA_Score(int pos, double ema5_pos ) {
//calculate total scores of all MA slopes add together to get either positive or negative score.
//if MA is near ema5 it will get a higher weightage
  int CounterDown=0, CounterUp=0, ScoreUp=0, ScoreDown=0, CoreMA_Up=0, CoreMA_Down=0;
  int iResults; 
  bool R1_Slope=true, AllowUp=true, AllowDown=true;
  double atr=ATR[pos];
  //make sure there is no divide by zero
  if (atr==0) return 0;
  //NearUp and Down are not used at the moment
  double NearUp1 = ema5_pos + atr*2;
  double NearDown1 = ema5_pos - atr*2;
  double NearUp2 = ema5_pos + atr*2.5;
  double NearDown2 = ema5_pos - atr*2.5;
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
  
  MA_Tan[0]= (EMA5[pos] - EMA5[pos-LookBack]) / atr;
  MA_Tan[1]= (SMA8[pos] - SMA8[pos-LookBack]) / atr;
  MA_Tan[2]= (EMA13[pos] - EMA13[pos-LookBack]) / atr;
  MA_Tan[3]= (SMA21[pos] - SMA21[pos-LookBack]) / atr;
  MA_Tan[4]= (SMA42[pos] - SMA42[pos-LookBack]) / atr;
  MA_Tan[5]= (SMA63[pos] - SMA63[pos-LookBack]) / atr;
  MA_Tan[6]= (SMA84[pos] - SMA84[pos-LookBack]) / atr;
  MA_Tan[7]= (SMA126[pos] - SMA126[pos-LookBack]) / atr;
  MA_Tan[8]= (SMA168[pos] - SMA168[pos-LookBack]) / atr;
  MA_Tan[9]= (SMA252[pos] - SMA252[pos-LookBack]) / atr;
  MA_Tan[10]= (SMA336[pos] - SMA336[pos-LookBack]) / atr;
  MA_Tan[11]= (SMA630[pos] - SMA630[pos-LookBack]) / atr;
  
  float score=0, total_score_up=0, total_score_down=0;
  //for scoring of MA slopes up, start from sma 31, skip ema 5 and sma 8
  for (int i=1; i<11; i++) {
    //slope up score
    if (MA_Tan[i] > Gradient1 && MA_Tan[i] < Gradient2) {
      score=1;
    } 
    else if (MA_Tan[i] > Gradient2 && MA_Tan[i] < Gradient3) {
      score = 2;
    }
    else if (MA_Tan[i] > Gradient3) {
      score = 3;
    }
    else {
      score=0;
    }
    //use counter to keep track all MA up dir
    if (score>0) {
      ScoreUp = ScoreUp + 1;
      //count the 4 smaller MA to make sure most are up
      if ( i==3 || i==4 || i==5 || i==6 || i==7 || i==8) {  //42 63 84 126 168
        CoreMA_Up = CoreMA_Up + 1;
        total_score_up=total_score_up+score;
      }
      if (debug) Print(i, " ",MA_Tan[i], " CoreMA ", CoreMA_Up);
    }
    //scoring for MA slope down
    if (MA_Tan[i]<0) { 
      double MAdown= MathAbs(MA_Tan[i]);
      if (MAdown > Gradient1 && MAdown < Gradient2) {
        score=-1;
      }
      else if (MAdown > Gradient2 && MAdown < Gradient3) {
        score = -2;
      }
      else if (MAdown > Gradient3) {
        score = -3;
      }
      else {
        score=0;
      }      
    } //slope down
    //if (debug) { Print(i," score: ", score, " Gradient ", MA_Tan[i]); } //detail
    //use counter to keep track all MA up dir
    if (score<0) {
      ScoreDown = ScoreDown -1;
      if ( i==4 || i==5 || i==6 || i==7 || i==8) {  //42 63 84 126 168
        CoreMA_Down = CoreMA_Down + 1;
        total_score_down=total_score_down+score;
      }
      if (debug) Print(i, " ",MA_Tan[i]);
    }
    
    //for calculating number of MA that slope against, Filter, we are skipping 8,21,42,252,336
    //4:63 7:252
    if (i>=5 && i<=8) {
      if (MA_Tan[i] > GradientFilter) {
        CounterDown = CounterDown + 1;
      } 
    }
    //slope down, that it counter the uptrend
    if (i>=5 && i<=8 && MA_Tan[i]<0) { 
      double MAdown= MathAbs(MA_Tan[i]);
      if (MAdown > GradientFilter) {
        CounterUp = CounterUp + 1;
      }
    } //slope down if
    //for 252 and 336, we use nearby method, if MA is near to ema5 then we add to counter list
    if (i>=9 && i<=11) {
      //check for MA slope against(block), for downtrend, need to check if any MA below ema 5 and within the buffer distance and the MA is slope up against
      if (MA[i] < ema5_pos && MA[i] > NearDown1) {
        if (MA_Tan[i] > GradientFilter) {
          CounterDown = CounterDown + 1;
        } 
      }
    }
    //slope down, that it counter the uptrend
    if (i>=9 && i<=11 && MA_Tan[i]<0) { 
      if (MA[i] > ema5_pos && MA[i] < NearUp1) {
        if (MA_Tan[i] < -GradientFilter) {
          CounterUp = CounterUp + 1;
        }
      }
    } //slope down if     
  }//for loop  
  if (debug) {Print("ScoreUp:", ScoreUp, " ScoreDown: ", ScoreDown); }
  if (debug) {Print( "CounterDown ", CounterDown, " CounterUp ", CounterUp);}
  if (debug) {Print( "TotScoreDown ", total_score_down, " TotScoreUp ", total_score_up);}
  if (debug) {Print( "CoreMADown ", CoreMA_Down, " CoreMAUp ", CoreMA_Up);}
  
  if (ScoreUp>=MinUpDown && CoreMA_Up>=MinCoreMA && CounterUp<=AllowCounterMA && total_score_up>=MinScore && AllowUp) {
    iResults=ScoreUp;
  }
  else if (ScoreDown<=-MinUpDown && CoreMA_Down>=MinCoreMA && CounterDown<=AllowCounterMA && total_score_down<=-MinScore && AllowDown) {
    iResults=ScoreDown;
    if (debug) Print ("1st Res: ", iResults);
  } 
  else {
    iResults=0;    
  }    
  return (iResults);
}

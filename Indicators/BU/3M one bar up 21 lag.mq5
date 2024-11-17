//#property   indicator_separate_window

#property   indicator_buffers 6
#property   indicator_plots   6
//--- plot Arrows

#property indicator_type1  DRAW_ARROW
#property indicator_color1 clrWhite

#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrGold

#property indicator_type3  DRAW_ARROW
#property indicator_color3 clrBlue

#property indicator_type4  DRAW_ARROW
#property indicator_color4 clrRed

#property   indicator_type5      DRAW_LINE

bool debug = false;

//--- input parameters
input int MaxBars = 10000;
input int ATR_Factor = 21;  
input int LookBack = 2;
input int LookBackFilter = 7;
input int LookBackBuffer = 10;
input double Gradient_21_3M=0.06;
input double Gradient_21=0.10;
input double SteepGradient_21=0.25;
//input double Gradient1=0.1;
double Gradient1=0.4;
input double Gradient2=0.3;
input double Gradient3=0.4;
input int AllowCounterMA=0;
input double GradientFilter=0.1;

//ATF factor set to 3 to catch the recent ATF, so more buffer for volatility

input int MinUpDown = 1;
input int MinScore = 1;
//--- An indicator buffer for the plot
double ATR[],Up1[],Down1[],Up2[],Down2[],Line1[];
//buffers
double EMA5[],SMA8[],EMA13[],SMA21[],SMA42[],SMA63[],SMA84[],SMA126[],SMA168[],SMA252[],SMA336[],SMA630[];

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
   SetIndexBuffer(0, Up1, INDICATOR_DATA);
   SetIndexBuffer(1, Down1, INDICATOR_DATA);
   SetIndexBuffer(2, Up2, INDICATOR_DATA);
   SetIndexBuffer(3, Down2, INDICATOR_DATA);
   SetIndexBuffer(4, Line1, INDICATOR_DATA);
   
   //Setting the Buffer 0 to draw down arrow
   PlotIndexSetInteger(0,PLOT_ARROW,159);
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,39);

   //Setting the Buffer 0 to draw down arrow
   PlotIndexSetInteger(1,PLOT_ARROW,159);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,-39);

   PlotIndexSetInteger(2,PLOT_ARROW,159);
   PlotIndexSetInteger(2,PLOT_ARROW_SHIFT,40);

   //Setting the Buffer 0 to draw down arrow
   PlotIndexSetInteger(3,PLOT_ARROW,159);
   PlotIndexSetInteger(3,PLOT_ARROW_SHIFT,-40);
   
   //for window line
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0);   
   PlotIndexSetString(4,PLOT_LABEL,"EMA13 ROC "+EnumToString(_Period));   
   PlotIndexSetInteger(4,PLOT_LINE_COLOR,clrWhite);


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
  static datetime LastBar;

  if(LastBar==iTime(Symbol(),0,0)) return(-1);  //stop indicator from calculating current bar
  else LastBar=iTime(Symbol(),0,0);
  int iToCopy;
  if(prev_calculated>rates_total || prev_calculated<0)
    iToCopy=rates_total;
  else
   {
    iToCopy=rates_total-prev_calculated;
    if(prev_calculated>0)
       iToCopy++;
   }
  int limit=MaxBars;
  if (limit+LookBackBuffer>rates_total) {
    limit=rates_total-LookBackBuffer;
  }
  if (limit<0) return 0; //too little bars, we exit
  
  if(prev_calculated==0){
    ArrayInitialize(Up1,0);
    ArrayInitialize(Down1,0);
    ArrayInitialize(Up2,0);
    ArrayInitialize(Down2,0);
    ArrayInitialize(Line1,0);
    start = rates_total-limit; //limited total no of bars to calc. 
  } 
  else {
    start=prev_calculated-1;
  }

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

  for(int i = start; i < rates_total-1 && !IsStopped(); i++) {  //don't include the current bar rates_total-1 is the current bar.
    datetime StartDt=D'2020.09.02 12:00', EndDt=D'2020.09.02 14:00';
    double arrowbuffer = 0.8*ATR[i];
    //plot dots on the chart to indicate positive or negative scoring of al the MA slopes add up
    if (debug) {
      if (time[i]>StartDt && time[i]<EndDt) {
        Print("Debug: ", time[i]); //debug      
        double score=MA_Score(i, EMA5[i]);
        //Print("return score: ", score);
        Print(time[i]," return score: ", score);
        if (score>=MinUpDown) {
          Up1[i] = SMA63[i] - arrowbuffer;
        }
        else if (score<=-MinUpDown) {
          Down1[i] =  SMA63[i] + arrowbuffer;
        }
      }//time range
    } //debug for time range
    else {
      Line1[i]=1;
      double score=MA_Score(i, EMA5[i]);
      if (score>=MinUpDown) {
        Up2[i] = SMA21[i] - arrowbuffer;
      }
      else if (score<=-MinUpDown) {
        Down2[i] =  SMA21[i] + arrowbuffer;
      }
    }//else
  } //for loop
    
  return(rates_total);
}

int MA_Score(int pos, double HighLow ) {
//calculate total scores of all MA slopes add together to get either positive or negative score.
//if MA is near ema5 it will get a higher weightage
  int CounterDown=0, CounterUp=0, ScoreUp=0, ScoreDown=0;
  int iResults; 
  bool SlopeUp_21=false, SlopeDown_21=false, Steep21Up=false, Steep21Down=false;
  double MA[12], MA_Tan1[12], MA_Tan2[12], MA_Tan3[12],MA_Tan[12];
  //NearUp and Down are not used at the moment
  double NearUp1 = HighLow + ATR[pos]*0.5;
  double NearDown1 = HighLow - ATR[pos]*2.5;
  double NearUp2 = EMA5[pos] + ATR[pos]*2.5;
  double NearDown2 = EMA5[pos] - ATR[pos]*2.5;
  
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
  
  MA_Tan3[0]= (EMA5[pos] - EMA5[pos-1]) / ATR[pos];
  MA_Tan3[1]= (SMA8[pos] - SMA8[pos-1]) / ATR[pos];
  MA_Tan3[2]= (EMA13[pos] - EMA13[pos-1]) / ATR[pos];
  MA_Tan3[3]= (SMA21[pos] - SMA21[pos-1]) / ATR[pos];
  MA_Tan3[4]= (SMA42[pos] - SMA42[pos-1]) / ATR[pos];
  MA_Tan3[5]= (SMA63[pos] - SMA63[pos-1]) / ATR[pos];
  MA_Tan3[6]= (SMA84[pos] - SMA84[pos-1]) / ATR[pos];

  MA_Tan2[0]= (EMA5[pos-1] - EMA5[pos-2]) / ATR[pos];
  MA_Tan2[1]= (SMA8[pos-1] - SMA8[pos-2]) / ATR[pos];
  MA_Tan2[2]= (EMA13[pos-1] - EMA13[pos-2]) / ATR[pos];
  MA_Tan2[3]= (SMA21[pos-1] - SMA21[pos-2]) / ATR[pos];
  MA_Tan2[4]= (SMA42[pos-1] - SMA42[pos-2]) / ATR[pos];
  MA_Tan2[5]= (SMA63[pos-1] - SMA63[pos-2]) / ATR[pos];
  MA_Tan2[6]= (SMA84[pos-1] - SMA84[pos-2]) / ATR[pos];

  MA_Tan1[0]= (EMA5[pos-2] - EMA5[pos-3]) / ATR[pos];
  MA_Tan1[1]= (SMA8[pos-2] - SMA8[pos-3]) / ATR[pos];
  MA_Tan1[2]= (EMA13[pos-2] - EMA13[pos-3]) / ATR[pos];  
  MA_Tan1[3]= (SMA21[pos-2] - SMA21[pos-3]) / ATR[pos];
  MA_Tan1[4]= (SMA42[pos-2] - SMA42[pos-3]) / ATR[pos];
  MA_Tan1[5]= (SMA63[pos-2] - SMA63[pos-3]) / ATR[pos];
  MA_Tan1[6]= (SMA84[pos-2] - SMA84[pos-3]) / ATR[pos];

  MA_Tan[0]= (EMA5[pos] - EMA5[pos-LookBack]) / ATR[pos];
  MA_Tan[1]= (SMA8[pos] - SMA8[pos-LookBack]) / ATR[pos];
  MA_Tan[2]= (EMA13[pos] - EMA13[pos-LookBack]) / ATR[pos]; //3M lookback is different from the big MAs
  MA_Tan[3]= (SMA21[pos] - SMA21[pos-LookBack]) / ATR[pos];
  MA_Tan[4]= (SMA42[pos] - SMA42[pos-LookBackFilter]) / ATR[pos];
  MA_Tan[5]= (SMA63[pos] - SMA63[pos-LookBackFilter]) / ATR[pos];
  MA_Tan[6]= (SMA84[pos] - SMA84[pos-LookBackFilter]) / ATR[pos];
  MA_Tan[7]= (SMA126[pos] - SMA126[pos-LookBackFilter]) / ATR[pos];
  MA_Tan[8]= (SMA168[pos] - SMA168[pos-LookBackFilter]) / ATR[pos];
  MA_Tan[9]= (SMA252[pos] - SMA252[pos-LookBackFilter]) / ATR[pos];
  MA_Tan[10]= (SMA336[pos] - SMA336[pos-LookBackFilter]) / ATR[pos];
  MA_Tan[11]= (SMA630[pos] - SMA630[pos-LookBackFilter]) / ATR[pos];

  float score=0, total_score_up=0, total_score_down=0, thresholdMA=2.5, DistThreshold=1.5;
  //for scoring of MA slopes up, start from sma 31, skip ema 5 and sma 8
  
  Line1[pos]=MA_Tan[2]; //ema13 tangent
  for (int i=1; i<=1; i++) {
    float Dist= (MA[0]-MA[3])/ATR[pos];
    //Print(Dist);
    //there must be an drop in ROC, 21 must be slope up too
    if (MA_Tan[1] > Gradient1 && MA_Tan[3]>0 && (MA_Tan[1]/MA_Tan[3]<thresholdMA) && Dist<DistThreshold) {
      score=1;
    } 
    else {
      score=0;
    }
    //use counter to keep track all MA up dir
    if (score>0) { 
      ScoreUp = ScoreUp + 1;
      total_score_up = total_score_up + score;
    }
    //SMA 63, 84 must be slope, score must be at least, if MA is not slope up and is 63 or 84 then nullify
    //scoring for MA slope down
    if (MA_Tan[1] < -Gradient1 && MA_Tan[3]<0 && (MA_Tan[1]/MA_Tan[3]<thresholdMA) && Dist>-DistThreshold ) {
      score=-1;
    }
    else {
      score=0;
    }      
    //use counter to keep track all MA up dir
    if (score<0) { 
      ScoreDown = ScoreDown -1;
      total_score_down = total_score_down + score;
    }
    //if (debug) { Print(i," Tan1: ",MA_Tan1[i]," Tan2: ", MA_Tan2[i], " Tan3: ", MA_Tan3[i]); }
    if (debug) Print("3M slope: ", i," ", MA_Tan[i], " Score: ", score);

  }//for loop 3M

  //Print("tot score down: ", total_score_down, " ", -MinScore);
  if (debug) {Print("ScoreUp:", ScoreUp, " ScoreDown: ", ScoreDown); }

  if (ScoreUp>=MinUpDown) {
    iResults=ScoreUp;
  }
  else if (ScoreDown<=-MinUpDown) {
    iResults=ScoreDown;
  } 
  else {
    iResults=0;    
  }
  return (iResults);
}

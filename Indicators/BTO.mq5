#property indicator_buffers 2
#property indicator_plots   2
//--- plot Arrows
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrLime

#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrRed

//--- input parameters
input bool Check_MA = true;
input int MaxBars= 10;

input double adjust_distant=0.5;
input double adjust_distant_body=0.4;

//--- An indicator buffer for the plot
double UpArrow[],DownArrow[],ATRBuffer[],UpBB[],LoBB[];
double MA1[],MA2[],MA3[],MA4[],MA5[],MA6[],MA7[],MA8[],MA9[];
int atr_handle, ma_handle, band_handle;

//--- An array to store colors
color colors[]={clrRed,clrBlue,clrLime};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0, UpArrow, INDICATOR_DATA);
   SetIndexBuffer(1, DownArrow, INDICATOR_DATA);
   
   ArraySetAsSeries(UpArrow,true);ArraySetAsSeries(DownArrow,true);    
   ArraySetAsSeries(ATRBuffer,true);ArraySetAsSeries(UpBB,true);ArraySetAsSeries(LoBB,true);
   ArraySetAsSeries(MA1,true);ArraySetAsSeries(MA2,true);ArraySetAsSeries(MA3,true);
   ArraySetAsSeries(MA4,true);ArraySetAsSeries(MA5,true);ArraySetAsSeries(MA6,true);
   ArraySetAsSeries(MA7,true);ArraySetAsSeries(MA8,true);ArraySetAsSeries(MA9,true);

   atr_handle=iATR(Symbol(),0,21);
   ma_handle=iMA(Symbol(),0,5,0,MODE_EMA,PRICE_CLOSE);
   band_handle=iBands(Symbol(),0,21,0,2,PRICE_CLOSE);
   
   //Setting the Buffer 0 to draw up arrow
   PlotIndexSetInteger(0,PLOT_ARROW,233);
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,30);

   //Setting the Buffer 0 to draw down arrow
   PlotIndexSetInteger(1,PLOT_ARROW,234);
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
                const int &spread[])
{
   if (rates_total == prev_calculated) return(-1);

   if(prev_calculated==0)
   {
      ArrayInitialize(UpArrow,0);
      ArrayInitialize(DownArrow,0);
      ArrayInitialize(ATRBuffer,0);
      ArrayInitialize(MA1,0);
   }
   
   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   int copied=CopyRates(NULL,0,0,MaxBars,rates);

   CopyBuffer(atr_handle,0,0,MaxBars,ATRBuffer);
   CopyBuffer(ma_handle,0,0,MaxBars,MA1);
   CopyBuffer(band_handle,1,0,MaxBars,UpBB);
   CopyBuffer(band_handle,2,0,MaxBars,LoBB);
   CopyBuffer(iMA(Symbol(),0,21,0,MODE_SMA,PRICE_CLOSE),0,0,MaxBars,MA2);
   CopyBuffer(iMA(Symbol(),0,63,0,MODE_SMA,PRICE_CLOSE),0,0,MaxBars,MA3);
   CopyBuffer(iMA(Symbol(),0,84,0,MODE_SMA,PRICE_CLOSE),0,0,MaxBars,MA4);
   CopyBuffer(iMA(Symbol(),0,126,0,MODE_SMA,PRICE_CLOSE),0,0,MaxBars,MA5);
   CopyBuffer(iMA(Symbol(),0,168,0,MODE_SMA,PRICE_CLOSE),0,0,MaxBars,MA6);
   CopyBuffer(iMA(Symbol(),0,252,0,MODE_SMA,PRICE_CLOSE),0,0,MaxBars,MA7);
   CopyBuffer(iMA(Symbol(),0,336,0,MODE_SMA,PRICE_CLOSE),0,0,MaxBars,MA8);
   CopyBuffer(iMA(Symbol(),0,630,0,MODE_SMA,PRICE_CLOSE),0,0,MaxBars,MA9);

   bool bSignal;
   for( int i=0;i<MaxBars;i++ )
   {
      double distant = adjust_distant*ATRBuffer[i];
      double distant_body = adjust_distant_body*ATRBuffer[i];
      double PointFromO = MathMax(rates[i].close,rates[i].open); //higher of close or open
      double BodySize = MathAbs(rates[i].close -rates[i].open);  //size of bar body
      if((MA1[i]-PointFromO>distant) && (BodySize < distant_body))  //O need to be higher than the bar by more than distant
      {
         if (Check_MA) {
            bSignal = false;
            if (PointFromO < LoBB[i]) bSignal=true;
            if (PointFromO < MA2[i] && MA2[i] < MA1[i]) bSignal=true;
            if (PointFromO < MA3[i] && MA3[i] < MA1[i]) {bSignal=true;}
            if (PointFromO < MA4[i] && MA4[i] < MA1[i]) {bSignal=true;}
            if (PointFromO < MA5[i] && MA5[i] < MA1[i]) {bSignal=true;}
            if (PointFromO < MA6[i] && MA6[i] < MA1[i]) bSignal=true;
            if (PointFromO < MA7[i] && MA7[i] < MA1[i]) bSignal=true;
            if (PointFromO < MA8[i] && MA8[i] < MA1[i]) bSignal=true;
            if (PointFromO < MA9[i] && MA2[i] < MA1[i]) bSignal=true;
         }
         else bSignal = true;
         
         if (bSignal) UpArrow[i] = rates[i].low;
      }
      
      bSignal=false;
      PointFromO = MathMin(rates[i].close,rates[i].open);  //lower or close or open of bar
      if((PointFromO-MA1[i]>distant) && (BodySize < distant_body))  //O need to be higher than the bar by more than distant
      {
         if (Check_MA) {
            bSignal = false;
            if (PointFromO > UpBB[i]) bSignal=true;
            if (PointFromO > MA2[i] && MA2[i] > MA1[i]) bSignal=true;
            if (PointFromO > MA3[i] && MA3[i] > MA1[i]) bSignal=true;
            if (PointFromO > MA4[i] && MA4[i] > MA1[i]) bSignal=true;
            if (PointFromO > MA5[i] && MA5[i] > MA1[i]) bSignal=true;
            if (PointFromO > MA6[i] && MA6[i] > MA1[i]) bSignal=true;
            if (PointFromO > MA7[i] && MA7[i] > MA1[i]) bSignal=true;
            if (PointFromO > MA8[i] && MA8[i] > MA1[i]) bSignal=true;
            if (PointFromO > MA9[i] && MA2[i] > MA1[i]) bSignal=true;
         }
         else bSignal = true;
         
         if (bSignal) DownArrow[i] = rates[i].high;
      }
   }
   
   return(rates_total);
}


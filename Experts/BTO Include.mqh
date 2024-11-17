//--- input parameters
input bool BTO_Check_MA = true;
input double BTO_adjust_distant=0.5;
input double BTO_adjust_distant_body=0.4;
input double BTO_adjust_distant_tip=0.1;

string BTO(string sSymbol, ENUM_TIMEFRAMES TF) {

   double ATRBuffer[],UpBB[],LoBB[];
   double MA1[],MA2[],MA3[],MA4[],MA5[],MA6[],MA7[],MA8[],MA9[];
   int atr_handle, ma_handle, band_handle;

   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   int copied=CopyRates(sSymbol,TF,0,2,rates);

   ArraySetAsSeries(ATRBuffer,true);ArraySetAsSeries(UpBB,true);ArraySetAsSeries(LoBB,true);
   ArraySetAsSeries(MA1,true);ArraySetAsSeries(MA2,true);ArraySetAsSeries(MA3,true);
   ArraySetAsSeries(MA4,true);ArraySetAsSeries(MA5,true);ArraySetAsSeries(MA6,true);
   ArraySetAsSeries(MA7,true);ArraySetAsSeries(MA8,true);ArraySetAsSeries(MA9,true);

   atr_handle=iATR(sSymbol,TF,21);
   ma_handle=iMA(sSymbol,TF,5,0,MODE_EMA,PRICE_CLOSE);
   band_handle=iBands(sSymbol,TF,21,0,2,PRICE_CLOSE);

   CopyBuffer(atr_handle,0,0,2,ATRBuffer);
   CopyBuffer(ma_handle,0,0,2,MA1);
   CopyBuffer(band_handle,1,0,2,UpBB);
   CopyBuffer(band_handle,2,0,2,LoBB);
   CopyBuffer(iMA(sSymbol,TF,21,0,MODE_SMA,PRICE_CLOSE),0,0,2,MA2);
   CopyBuffer(iMA(sSymbol,TF,63,0,MODE_SMA,PRICE_CLOSE),0,0,2,MA3);
   CopyBuffer(iMA(sSymbol,TF,84,0,MODE_SMA,PRICE_CLOSE),0,0,2,MA4);
   CopyBuffer(iMA(sSymbol,TF,126,0,MODE_SMA,PRICE_CLOSE),0,0,2,MA5);
   CopyBuffer(iMA(sSymbol,TF,168,0,MODE_SMA,PRICE_CLOSE),0,0,2,MA6);
   CopyBuffer(iMA(sSymbol,TF,252,0,MODE_SMA,PRICE_CLOSE),0,0,2,MA7);
   CopyBuffer(iMA(sSymbol,TF,336,0,MODE_SMA,PRICE_CLOSE),0,0,2,MA8);
   CopyBuffer(iMA(sSymbol,TF,630,0,MODE_SMA,PRICE_CLOSE),0,0,2,MA9);

   bool bSignal=false;
   string sRes="";
   double distant = BTO_adjust_distant*ATRBuffer[0];
   double distant_body = BTO_adjust_distant_body*ATRBuffer[0];
   double distant_tip = BTO_adjust_distant_tip*ATRBuffer[0];
   double arrowbuffer = 0.5*ATRBuffer[0];   
   double PointFromO = MathMax(rates[1].close,rates[1].open); //higher of close or open
   double BodySize = MathAbs(rates[1].close -rates[1].open);  //size of bar body
   if((MA1[1]-PointFromO>distant) && (BodySize < distant_body))  //O need to be higher than the bar by more than distant
   {
      if (BTO_Check_MA) {
         bSignal = false;
         if (PointFromO < LoBB[1]) bSignal=true;
         if (PointFromO < MA2[1] && MA2[1] < MA1[1]) bSignal=true;
         if (PointFromO < MA3[1] && MA3[1] < MA1[1]) bSignal=true;
         if (PointFromO < MA4[1] && MA4[1] < MA1[1]) bSignal=true;
         if (PointFromO < MA5[1] && MA5[1] < MA1[1]) bSignal=true;
         if (PointFromO < MA6[1] && MA6[1] < MA1[1]) bSignal=true;
         if (PointFromO < MA7[1] && MA7[1] < MA1[1]) bSignal=true;
         if (PointFromO < MA8[1] && MA8[1] < MA1[1]) bSignal=true;
         if (PointFromO < MA9[1] && MA2[1] < MA1[1]) bSignal=true;
       }
      else bSignal = true; //no need to check MA cut across
      
      if (bSignal) {
         sRes="Up BTO";
         ObjectCreate(0,"up"+iTime(NULL,0,1),OBJ_ARROW_BUY,0,iTime(NULL,0,1), rates[1].low-arrowbuffer);
      }
   }
      
   bSignal=false;
   PointFromO = MathMin(rates[1].close,rates[1].open);  //lower or close or open of bar
   if((PointFromO-MA1[1]>distant) && (BodySize < distant_body))  //O need to be higher than the bar by more than distant
   {
      if (BTO_Check_MA) {
         bSignal = false;
         if (PointFromO > UpBB[1]) bSignal=true;
         if (PointFromO > MA2[1] && MA2[1] > MA1[1]) bSignal=true;
         if (PointFromO > MA3[1] && MA3[1] > MA1[1]) bSignal=true;
         if (PointFromO > MA4[1] && MA4[1] > MA1[1]) bSignal=true;
         if (PointFromO > MA5[1] && MA5[1] > MA1[1]) bSignal=true;
         if (PointFromO > MA6[1] && MA6[1] > MA1[1]) bSignal=true;
         if (PointFromO > MA7[1] && MA7[1] > MA1[1]) bSignal=true;
         if (PointFromO > MA8[1] && MA8[1] > MA1[1]) bSignal=true;
         if (PointFromO > MA9[1] && MA2[1] > MA1[1]) bSignal=true;
      }
      else bSignal = true;
      
      if (bSignal) {
      //Print("BTO ", rates[1].close);
         sRes="Down BTO";
         ObjectCreate(0,"down"+iTime(NULL,0,1),OBJ_ARROW_SELL,0,iTime(NULL,0,1), rates[1].high+arrowbuffer);
      }
   }
   //Print("BTO ", sSymbol," ", TF, " ", rates[1].time, " ", rates[1].close);     
   return sRes;
} //BTO

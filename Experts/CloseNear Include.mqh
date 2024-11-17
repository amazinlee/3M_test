//--- input parameters
input bool NearMA_CheckTail=true;
input int NearMA_NoTouchMA=5;
input int NearMA_ATR = 3;
input double NearMA_adjust_distant=0.2;

string CloseNear(string sSymbol, ENUM_TIMEFRAMES TF) {

   double ATRBuffer[];
   double MA1[],MA2[],MA3[],MA4[],MA5[],MA6[],MA7[],MA8[],MA9[],MA10[],MA11[];
   int atr_handle, ma_handle;
   
   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   int copied=CopyRates(sSymbol,TF,0,NearMA_NoTouchMA+2,rates);

   ArraySetAsSeries(MA1,true);ArraySetAsSeries(MA2,true);ArraySetAsSeries(MA3,true);
   ArraySetAsSeries(MA4,true);ArraySetAsSeries(MA5,true);ArraySetAsSeries(MA6,true);
   ArraySetAsSeries(MA7,true);ArraySetAsSeries(MA8,true);ArraySetAsSeries(MA9,true);
   ArraySetAsSeries(MA10,true);ArraySetAsSeries(MA11,true);


   atr_handle=iATR(sSymbol,TF,NearMA_ATR);
   ArraySetAsSeries(ATRBuffer,true);
   CopyBuffer(atr_handle,0,0,2,ATRBuffer);
   
   ma_handle=iMA(sSymbol,TF,5,0,MODE_EMA,PRICE_CLOSE);
   CopyBuffer(ma_handle,0,0,1,MA1);
   CopyBuffer(iMA(sSymbol,TF,21,0,MODE_SMA,PRICE_CLOSE),0,0,NearMA_NoTouchMA+2,MA2);
   CopyBuffer(iMA(sSymbol,TF,63,0,MODE_SMA,PRICE_CLOSE),0,0,NearMA_NoTouchMA+2,MA3);
   CopyBuffer(iMA(sSymbol,TF,84,0,MODE_SMA,PRICE_CLOSE),0,0,NearMA_NoTouchMA+2,MA4);
   CopyBuffer(iMA(sSymbol,TF,126,0,MODE_SMA,PRICE_CLOSE),0,0,NearMA_NoTouchMA+2,MA5);
   CopyBuffer(iMA(sSymbol,TF,168,0,MODE_SMA,PRICE_CLOSE),0,0,NearMA_NoTouchMA+2,MA6);
   CopyBuffer(iMA(sSymbol,TF,252,0,MODE_SMA,PRICE_CLOSE),0,0,NearMA_NoTouchMA+2,MA7);
   CopyBuffer(iMA(sSymbol,TF,336,0,MODE_SMA,PRICE_CLOSE),0,0,NearMA_NoTouchMA+2,MA8);
   CopyBuffer(iMA(sSymbol,TF,630,0,MODE_SMA,PRICE_CLOSE),0,0,NearMA_NoTouchMA+2,MA9);
   CopyBuffer(iMA(sSymbol,TF,13,0,MODE_EMA,PRICE_CLOSE),0,0,NearMA_NoTouchMA+2,MA10);
   CopyBuffer(iMA(sSymbol,TF,42,0,MODE_SMA,PRICE_CLOSE),0,0,NearMA_NoTouchMA+2,MA11);


   double barOpen,barClose,barHigh,barLow;
   bool bSignal;
   string sRes="";

   double distant = NearMA_adjust_distant*ATRBuffer[0];
   double arrowbuffer = 0.5*ATRBuffer[0];
   bSignal=false;

   barOpen= rates[1].open; barClose=rates[1].close; barHigh=rates[1].high; barLow=rates[1].low;
   
   if (fnNoTouchMA(MA2,rates,NearMA_NoTouchMA)) {
      if (MathAbs(barClose - MA2[1])<distant && barOpen>barClose) bSignal=true; //bear bar and close must be near MA up signal
      if (MathAbs(barLow - MA2[1])<distant) bSignal=true;  //lowest point must be near MA
   }
   if (fnNoTouchMA(MA3,rates,NearMA_NoTouchMA)) {
      if (MathAbs(barClose - MA3[1])<distant && barOpen>barClose) bSignal=true; //bear bar and close must be near MA up signal
      if (MathAbs(barLow - MA3[1])<distant) bSignal=true;  //lowest point must be near MA
   }
   if (fnNoTouchMA(MA4,rates,NearMA_NoTouchMA)) {
      if (MathAbs(barClose - MA4[1])<distant && barOpen>barClose) bSignal=true; //bear bar and close must be near MA up signal
      if (MathAbs(barLow - MA4[1])<distant) bSignal=true;  //lowest point must be near MA
   }
   if (fnNoTouchMA(MA5,rates,NearMA_NoTouchMA)) {
      if (MathAbs(barClose - MA5[1])<distant && barOpen>barClose) bSignal=true; //bear bar and close must be near MA up signal
      if (MathAbs(barLow - MA5[1])<distant) bSignal=true;  //lowest point must be near MA
   }
   if (fnNoTouchMA(MA6,rates,NearMA_NoTouchMA)) {
      if (MathAbs(barClose - MA6[1])<distant && barOpen>barClose) bSignal=true; //bear bar and close must be near MA up signal
      if (MathAbs(barLow - MA6[1])<distant) bSignal=true;  //lowest point must be near MA
   }
   if (fnNoTouchMA(MA7,rates,NearMA_NoTouchMA)) {
      if (MathAbs(barClose - MA7[1])<distant && barOpen>barClose) bSignal=true; //bear bar and close must be near MA up signal
      if (MathAbs(barLow - MA7[1])<distant) bSignal=true;  //lowest point must be near MA
   }
   if (fnNoTouchMA(MA8,rates,NearMA_NoTouchMA)) {
      if (MathAbs(barClose - MA8[1])<distant && barOpen>barClose) bSignal=true; //bear bar and close must be near MA up signal
      if (MathAbs(barLow - MA8[1])<distant) bSignal=true;  //lowest point must be near MA
   }
   if (fnNoTouchMA(MA9,rates,NearMA_NoTouchMA)) {
      if (MathAbs(barClose - MA9[1])<distant && barOpen>barClose) bSignal=true; //bear bar and close must be near MA up signal
      if (MathAbs(barLow - MA9[1])<distant) bSignal=true;  //lowest point must be near MA
   }

   if (bSignal) {
      ObjectCreate(0,"up"+TimeToString(iTime(NULL,0,1)),OBJ_ARROW_BUY,0,iTime(NULL,0,1), barLow-arrowbuffer);
      sRes="CloseNear Up";
   }
   //sell trades
   bSignal = false;
   if (fnNoTouchMA(MA2,rates,NearMA_NoTouchMA)) {
      if (MathAbs(barClose - MA2[1])<distant && barClose>barOpen) bSignal=true; //bear bar and close must be near MA up signal
      if (MathAbs(barHigh - MA2[1])<distant) bSignal=true;  //lowest point must be near MA
   }
   if (fnNoTouchMA(MA3,rates,NearMA_NoTouchMA)) {
      if (MathAbs(barClose - MA3[1])<distant && barClose>barOpen) bSignal=true; //bear bar and close must be near MA up signal
      if (MathAbs(barHigh - MA3[1])<distant) bSignal=true;  //lowest point must be near MA
   }
   if (fnNoTouchMA(MA4,rates,NearMA_NoTouchMA)) {
      if (MathAbs(barClose - MA4[1])<distant && barClose>barOpen) bSignal=true; //bear bar and close must be near MA up signal
      if (MathAbs(barHigh - MA4[1])<distant) bSignal=true;  //lowest point must be near MA
   }
   if (fnNoTouchMA(MA5,rates,NearMA_NoTouchMA)) {
      if (MathAbs(barClose - MA5[1])<distant && barClose>barOpen) bSignal=true; //bear bar and close must be near MA up signal
      if (MathAbs(barHigh - MA5[1])<distant) bSignal=true;  //lowest point must be near MA
   }
   if (fnNoTouchMA(MA6,rates,NearMA_NoTouchMA)) {
      if (MathAbs(barClose - MA6[1])<distant && barClose>barOpen) bSignal=true; //bear bar and close must be near MA up signal
      if (MathAbs(barHigh - MA6[1])<distant) bSignal=true;  //lowest point must be near MA
   }
   if (fnNoTouchMA(MA7,rates,NearMA_NoTouchMA)) {
      if (MathAbs(barClose - MA7[1])<distant && barClose>barOpen) bSignal=true; //bear bar and close must be near MA up signal
      if (MathAbs(barHigh - MA7[1])<distant) bSignal=true;  //lowest point must be near MA
   }      
   if (fnNoTouchMA(MA8,rates,NearMA_NoTouchMA)) {
      if (MathAbs(barClose - MA8[1])<distant && barClose>barOpen) bSignal=true; //bear bar and close must be near MA up signal
      if (MathAbs(barHigh - MA8[1])<distant) bSignal=true;  //lowest point must be near MA
   }      
   if (fnNoTouchMA(MA9,rates,NearMA_NoTouchMA)) {
      if (MathAbs(barClose - MA9[1])<distant && barClose>barOpen) bSignal=true; //bear bar and close must be near MA up signal
      if (MathAbs(barHigh - MA9[1])<distant) bSignal=true;  //lowest point must be near MA
   }
   
   if (bSignal) {
      ObjectCreate(0,"up"+TimeToString(iTime(NULL,0,1)),OBJ_ARROW_SELL,0,iTime(NULL,0,1), barHigh+arrowbuffer);
      sRes="CloseNear Down";
   }   
   return sRes;
} //CloseNear


bool fnNoTouchMA(double &ma[], MqlRates &rates[], int limit)
{
   bool bTouch=false;
   
   if (NearMA_NoTouchMA==0) return(true);
   
   for (int cnt=2;cnt<=limit;cnt++)
   {
      if ((ma[cnt]<rates[cnt].high && ma[cnt]>rates[cnt].low)) 
      {
         bTouch=true;
         break;
      }
   }
   return (!bTouch);
}

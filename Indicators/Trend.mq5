//+------------------------------------------------------------------+
//|                                                       Chew-Trend |
//|                                                             ProF |
//|                                                          http:// |
//+------------------------------------------------------------------+
#property copyright "Chew"                      //Author

//--------
#property indicator_separate_window             //The indicator is plotted in a separate window
#property indicator_level1    10
#property indicator_level2    3
#property indicator_level3    -3
#property indicator_level4    -10

#property indicator_buffers 22                   //Number of indicator buffers
#property indicator_plots 11                     //Number of indicator plots

#property indicator_type1 DRAW_COLOR_ARROW  //Drawing style - Color Arrow
#property indicator_type2 DRAW_COLOR_ARROW  //Drawing style - Color Arrow
#property indicator_type3 DRAW_COLOR_ARROW  //Drawing style - Color Arrow
#property indicator_type4 DRAW_COLOR_ARROW  //Drawing style - Color Arrow
#property indicator_type5 DRAW_COLOR_ARROW  //Drawing style - Color Arrow
#property indicator_type6 DRAW_COLOR_ARROW  //Drawing style - Color Arrow
#property indicator_type7 DRAW_COLOR_ARROW  //Drawing style - Color Arrow
#property indicator_type8 DRAW_COLOR_ARROW  //Drawing style - Color Arrow
#property indicator_type9 DRAW_COLOR_ARROW  //Drawing style - Color Arrow
#property indicator_type10 DRAW_COLOR_ARROW  //Drawing style - Color Arrow
#property indicator_type11 DRAW_COLOR_LINE  //Drawing style - Color Line

//---- the declaration of the dynamic array
//that will be used further as an indicator's buffer

// indicator array for buffer and color_indexes
double   up_mn[], up_mn_color[];
double   up_w1[], up_w1_color[];
double   up_d1[], up_d1_color[];
double   up_h1[], up_h1_color[];
double   up_m30[], up_m30_color[];
double   down_mn[], down_mn_color[];
double   down_w1[], down_w1_color[];
double   down_d1[], down_d1_color[];
double   down_h1[], down_h1_color[];
double   down_m30[], down_m30_color[];

double   ma_strength[], ma_strength_color[];

// Indicators Arrays
double   EMA8[], EMA13[], EMA20[];
double   SMA21[], SMA42[], SMA63[], SMA84[], SMA126[], SMA168[], SMA252[], SMA336[];

// Stochastic Array
double   MN_Main[], MN_Signal[];
double   W1_Main[], W1_Signal[];
double   D1_Main[], D1_Signal[];
double   H1_Main[], H1_Signal[];
double   M30_Main[], M30_Signal[];


//---- indicator input parameters
int minBars = 336;        // Minimum number of bars to start calculation
int start;

//---- indicator handles
int      Handle_Stochastic_MN = iStochastic(_Symbol,PERIOD_MN1,5,3,3,MODE_SMA,STO_LOWHIGH);
int      Handle_Stochastic_W1 = iStochastic(_Symbol,PERIOD_W1,5,3,3,MODE_SMA,STO_LOWHIGH);
int      Handle_Stochastic_D1 = iStochastic(_Symbol,PERIOD_D1,5,3,3,MODE_SMA,STO_LOWHIGH);
int      Handle_Stochastic_H1 = iStochastic(_Symbol,PERIOD_H1,5,3,3,MODE_SMA,STO_LOWHIGH);
int      Handle_Stochastic_M30 = iStochastic(_Symbol,PERIOD_M30,5,3,3,MODE_SMA,STO_LOWHIGH);

int      Handle_EMA_8 = iMA(_Symbol,_Period,8,0,MODE_EMA,PRICE_TYPICAL);
int      Handle_EMA_13 = iMA(_Symbol,_Period,13,0,MODE_EMA,PRICE_TYPICAL);
int      Handle_EMA_20 = iMA(_Symbol,_Period,20,0,MODE_EMA,PRICE_CLOSE);
int      Handle_SMA_21 = iMA(_Symbol,_Period,21,0,MODE_EMA,PRICE_CLOSE);
int      Handle_SMA_42 = iMA(_Symbol,_Period,42,0,MODE_EMA,PRICE_CLOSE);
int      Handle_SMA_63 = iMA(_Symbol,_Period,63,0,MODE_EMA,PRICE_CLOSE);
int      Handle_SMA_84 = iMA(_Symbol,_Period,84,0,MODE_EMA,PRICE_CLOSE);
int      Handle_SMA_126 = iMA(_Symbol,_Period,126,0,MODE_EMA,PRICE_CLOSE);
int      Handle_SMA_168 = iMA(_Symbol,_Period,168,0,MODE_EMA,PRICE_CLOSE);
int      Handle_SMA_252 = iMA(_Symbol,_Period,252,0,MODE_EMA,PRICE_CLOSE);
int      Handle_SMA_336 = iMA(_Symbol,_Period,336,0,MODE_EMA,PRICE_CLOSE);


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(){

   // Assign data array with indicator's buffer
   // For Stochastic
   SetIndexBuffer(0,up_mn,INDICATOR_DATA);                  // data
   SetIndexBuffer(1,up_mn_color,INDICATOR_COLOR_INDEX);     // color
   SetIndexBuffer(2,down_mn,INDICATOR_DATA);                  // data
   SetIndexBuffer(3,down_mn_color,INDICATOR_COLOR_INDEX);     // color
   SetIndexBuffer(4,up_w1,INDICATOR_DATA);                  // data
   SetIndexBuffer(5,up_w1_color,INDICATOR_COLOR_INDEX);     // color
   SetIndexBuffer(6,down_w1,INDICATOR_DATA);                  // data
   SetIndexBuffer(7,down_w1_color,INDICATOR_COLOR_INDEX);     // color
   SetIndexBuffer(8,up_d1,INDICATOR_DATA);                  // data
   SetIndexBuffer(9,up_d1_color,INDICATOR_COLOR_INDEX);     // color
   SetIndexBuffer(10,down_d1,INDICATOR_DATA);                  // data
   SetIndexBuffer(11,down_d1_color,INDICATOR_COLOR_INDEX);     // color
   SetIndexBuffer(12,up_h1,INDICATOR_DATA);                  // data
   SetIndexBuffer(13,up_h1_color,INDICATOR_COLOR_INDEX);     // color
   SetIndexBuffer(14,down_h1,INDICATOR_DATA);                  // data
   SetIndexBuffer(15,down_h1_color,INDICATOR_COLOR_INDEX);     // color
   SetIndexBuffer(16,up_m30,INDICATOR_DATA);                  // data
   SetIndexBuffer(17,up_m30_color,INDICATOR_COLOR_INDEX);     // color
   SetIndexBuffer(18,down_m30,INDICATOR_DATA);                  // data
   SetIndexBuffer(19,down_m30_color,INDICATOR_COLOR_INDEX);     // color
   // For MA Strength
   SetIndexBuffer(20,ma_strength,INDICATOR_DATA);           // data
   SetIndexBuffer(21,ma_strength_color,INDICATOR_COLOR_INDEX);     // color
   

//-- STOCHASTIC MONTH
   // Plot Additional Property - Monthly Up
   PlotIndexSetString(0,PLOT_LABEL,"Stochastic Monthly Up");   
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetInteger(0,PLOT_LINE_WIDTH,1); 
   // Color Indexes
   PlotIndexSetInteger(0,PLOT_COLOR_INDEXES,4);   
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,White);   
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,1,Green);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,2,Orange);   
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,3,Red);
   
   // Plot Additional Property - Monthly Down
   PlotIndexSetString(1,PLOT_LABEL,"Stochastic Monthly Down");   
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
   PlotIndexSetInteger(1,PLOT_LINE_WIDTH,1); 
   //Specify colors for each index
   PlotIndexSetInteger(1,PLOT_COLOR_INDEXES,4);
   PlotIndexSetInteger(1,PLOT_LINE_COLOR,0,White);   
   PlotIndexSetInteger(1,PLOT_LINE_COLOR,1,Green);
   PlotIndexSetInteger(1,PLOT_LINE_COLOR,2,Orange);   
   PlotIndexSetInteger(1,PLOT_LINE_COLOR,3,Red);   
//-- STOCHASTIC WEEK   
   // Plot Additional Property - Weekly Up
   PlotIndexSetString(2,PLOT_LABEL,"Stochastic Weekly Up");   
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
   PlotIndexSetInteger(2,PLOT_LINE_WIDTH,1); 
   // Color Indexes
   PlotIndexSetInteger(2,PLOT_COLOR_INDEXES,4);   
   PlotIndexSetInteger(2,PLOT_LINE_COLOR,0,White);   
   PlotIndexSetInteger(2,PLOT_LINE_COLOR,1,Green);
   PlotIndexSetInteger(2,PLOT_LINE_COLOR,2,Orange);   
   PlotIndexSetInteger(2,PLOT_LINE_COLOR,3,Red);
   
   // Plot Additional Property - Weekly Down
   PlotIndexSetString(3,PLOT_LABEL,"Stochastic Weekly Down");   
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);
   PlotIndexSetInteger(3,PLOT_LINE_WIDTH,1); 
   //Specify colors for each index
   PlotIndexSetInteger(3,PLOT_COLOR_INDEXES,4);
   PlotIndexSetInteger(3,PLOT_LINE_COLOR,0,White);   
   PlotIndexSetInteger(3,PLOT_LINE_COLOR,1,Green);
   PlotIndexSetInteger(3,PLOT_LINE_COLOR,2,Orange);   
   PlotIndexSetInteger(3,PLOT_LINE_COLOR,3,Red);   
//-- STOCHASTIC DAY   
   // Plot Additional Properties - Daily up
   PlotIndexSetString(4,PLOT_LABEL,"Stochastic Daily Up");   
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0);
   PlotIndexSetInteger(4,PLOT_LINE_WIDTH,1); 
   // Color Indexes
   PlotIndexSetInteger(4,PLOT_COLOR_INDEXES,4);   
   PlotIndexSetInteger(4,PLOT_LINE_COLOR,0,White);   
   PlotIndexSetInteger(4,PLOT_LINE_COLOR,1,Green);
   PlotIndexSetInteger(4,PLOT_LINE_COLOR,2,Orange);   
   PlotIndexSetInteger(4,PLOT_LINE_COLOR,3,Red);
   
   // Plot Additional Properties - Daily Down
   PlotIndexSetString(5,PLOT_LABEL,"Stochastic Daily Down");   
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,0);
   PlotIndexSetInteger(5,PLOT_LINE_WIDTH,1); 
   //Specify colors for each index
   PlotIndexSetInteger(5,PLOT_COLOR_INDEXES,4);
   PlotIndexSetInteger(5,PLOT_LINE_COLOR,0,White);   
   PlotIndexSetInteger(5,PLOT_LINE_COLOR,1,Green);
   PlotIndexSetInteger(5,PLOT_LINE_COLOR,2,Orange);   
   PlotIndexSetInteger(5,PLOT_LINE_COLOR,3,Red);   
//-- STOCHASTIC HOUR   
   // Plot Additional Property - Hour Up
   PlotIndexSetString(6,PLOT_LABEL,"Stochastic Hourly Up");   
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,0);
   PlotIndexSetInteger(6,PLOT_LINE_WIDTH,1); 
   // Color Indexes
   PlotIndexSetInteger(6,PLOT_COLOR_INDEXES,4);   
   PlotIndexSetInteger(6,PLOT_LINE_COLOR,0,White);   
   PlotIndexSetInteger(6,PLOT_LINE_COLOR,1,Green);
   PlotIndexSetInteger(6,PLOT_LINE_COLOR,2,Orange);   
   PlotIndexSetInteger(6,PLOT_LINE_COLOR,3,Red);
   
   // Plot Additional Property - Hour Down
   PlotIndexSetString(7,PLOT_LABEL,"Stochastic Hourly Down");   
   PlotIndexSetDouble(7,PLOT_EMPTY_VALUE,0);
   PlotIndexSetInteger(7,PLOT_LINE_WIDTH,1); 
   //Specify colors for each index
   PlotIndexSetInteger(7,PLOT_COLOR_INDEXES,4);
   PlotIndexSetInteger(7,PLOT_LINE_COLOR,0,White);   
   PlotIndexSetInteger(7,PLOT_LINE_COLOR,1,Green);
   PlotIndexSetInteger(7,PLOT_LINE_COLOR,2,Orange);   
   PlotIndexSetInteger(7,PLOT_LINE_COLOR,3,Red);   
   
//-- STOCHASTIC M30   
   // Plot Additional Property - M30 Up
   PlotIndexSetString(8,PLOT_LABEL,"Stochastic M30 Up");   
   PlotIndexSetDouble(8,PLOT_EMPTY_VALUE,0);
   PlotIndexSetInteger(8,PLOT_LINE_WIDTH,1); 
   // Color Indexes
   PlotIndexSetInteger(8,PLOT_COLOR_INDEXES,4);   
   PlotIndexSetInteger(8,PLOT_LINE_COLOR,0,White);   
   PlotIndexSetInteger(8,PLOT_LINE_COLOR,1,Green);
   PlotIndexSetInteger(8,PLOT_LINE_COLOR,2,Orange);   
   PlotIndexSetInteger(8,PLOT_LINE_COLOR,3,Red);
   
   // Plot Additional Property - Hour Down
   PlotIndexSetString(9,PLOT_LABEL,"Stochastic M30 Down");   
   PlotIndexSetDouble(9,PLOT_EMPTY_VALUE,0);
   PlotIndexSetInteger(9,PLOT_LINE_WIDTH,1); 
   //Specify colors for each index
   PlotIndexSetInteger(9,PLOT_COLOR_INDEXES,4);
   PlotIndexSetInteger(9,PLOT_LINE_COLOR,0,White);   
   PlotIndexSetInteger(9,PLOT_LINE_COLOR,1,Green);
   PlotIndexSetInteger(9,PLOT_LINE_COLOR,2,Orange);   
   PlotIndexSetInteger(9,PLOT_LINE_COLOR,3,Red);   
//---   

// Plot MA Strength
   PlotIndexSetString(10,PLOT_LABEL,"MA Strength");   
   PlotIndexSetDouble(10,PLOT_EMPTY_VALUE,0);
   PlotIndexSetInteger(10,PLOT_LINE_WIDTH,1); 
   // Color Indexes
   PlotIndexSetInteger(10,PLOT_COLOR_INDEXES,4);   
   PlotIndexSetInteger(10,PLOT_LINE_COLOR,0,White);   
   PlotIndexSetInteger(10,PLOT_LINE_COLOR,1,clrLimeGreen);
   PlotIndexSetInteger(10,PLOT_LINE_COLOR,2,Orange);   
   PlotIndexSetInteger(10,PLOT_LINE_COLOR,3,Red);   
//---   


   // Initiate Data Loading for CopyBuffer (in OnCalculate)
   BarsCalculated(Handle_EMA_8);
   BarsCalculated(Handle_EMA_13);
   BarsCalculated(Handle_EMA_20);
   
   BarsCalculated(Handle_Stochastic_MN);
   BarsCalculated(Handle_Stochastic_W1);
   BarsCalculated(Handle_Stochastic_D1);
   BarsCalculated(Handle_Stochastic_H1);
   BarsCalculated(Handle_Stochastic_M30);
   
   //---
   Print ("Loaded");
   return(0);
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
  
   if (rates_total < minBars-1){
      return(0);
   }

   //---- calculation of starting index first of the main loop   
   if(prev_calculated==0){          
   
      // Initialise the indicator arrays to 0 so that you will not get crazy symbols popping up randomly
      ArrayInitialize(up_mn,0);
      ArrayInitialize(up_w1,0);
      ArrayInitialize(up_d1,0);
      ArrayInitialize(up_h1,0);
      ArrayInitialize(up_m30,0);
      ArrayInitialize(down_mn,0);
      ArrayInitialize(down_w1,0);
      ArrayInitialize(down_d1,0);
      ArrayInitialize(down_h1,0);
      ArrayInitialize(down_m30,0);
      
      ArrayInitialize(ma_strength,0);
            
      start    = minBars;                     // set position to start      

   } else {
      start    = prev_calculated-1;             // set position to start      
   }
   
   // Prepar
   
   // Acquire DATA   
   bool dataReady = false;          // flag to check data ready status
   
   

   if (
         CopyBuffer(Handle_EMA_8,0,0,rates_total,EMA8) > 0 &&
         CopyBuffer(Handle_EMA_13,0,0,rates_total,EMA13) > 0 &&
         CopyBuffer(Handle_EMA_20,0,0,rates_total,EMA20) > 0 &&
         CopyBuffer(Handle_SMA_21,0,0,rates_total,SMA21) > 0 &&
         CopyBuffer(Handle_SMA_42,0,0,rates_total,SMA42) > 0 &&
         CopyBuffer(Handle_SMA_63,0,0,rates_total,SMA63) > 0 &&
         CopyBuffer(Handle_SMA_84,0,0,rates_total,SMA84) > 0 &&
         CopyBuffer(Handle_SMA_126,0,0,rates_total,SMA126) > 0 &&
         CopyBuffer(Handle_SMA_168,0,0,rates_total,SMA168) > 0 &&
         CopyBuffer(Handle_SMA_252,0,0,rates_total,SMA252) > 0 &&
         CopyBuffer(Handle_SMA_336,0,0,rates_total,SMA336) > 0 &&         
         
         CopyBuffer(Handle_Stochastic_MN,0,0,Bars(_Symbol,PERIOD_MN1),MN_Main) > 0 &&
         CopyBuffer(Handle_Stochastic_MN,1,0,Bars(_Symbol,PERIOD_MN1),MN_Signal) > 0 &&
         CopyBuffer(Handle_Stochastic_W1,0,0,Bars(_Symbol,PERIOD_W1),W1_Main) > 0 &&
         CopyBuffer(Handle_Stochastic_W1,1,0,Bars(_Symbol,PERIOD_W1),W1_Signal) > 0 &&
         CopyBuffer(Handle_Stochastic_D1,0,0,Bars(_Symbol,PERIOD_D1),D1_Main) > 0 &&
         CopyBuffer(Handle_Stochastic_D1,1,0,Bars(_Symbol,PERIOD_D1),D1_Signal) > 0 &&
         CopyBuffer(Handle_Stochastic_H1,0,0,Bars(_Symbol,PERIOD_H1),H1_Main) > 0 &&
         CopyBuffer(Handle_Stochastic_H1,1,0,Bars(_Symbol,PERIOD_H1),H1_Signal) > 0 &&
         CopyBuffer(Handle_Stochastic_M30,0,0,Bars(_Symbol,PERIOD_M30),M30_Main) > 0 &&
         CopyBuffer(Handle_Stochastic_M30,1,0,Bars(_Symbol,PERIOD_M30),M30_Signal) > 0
   ){
      dataReady = true;
   }
   
/*
   if (BarsCalculated(Handle_Stochastic_MN) > 0){
      if (CopyBuffer(Handle_Stochastic_MN,0,0,Bars(_Symbol,PERIOD_MN1),MN_Main) > 0){    dataReady = true;   } else {    dataReady = false;   }
      if (CopyBuffer(Handle_Stochastic_MN,1,0,Bars(_Symbol,PERIOD_MN1),MN_Signal) > 0){    dataReady = true;   } else {    dataReady = false;   }      
   }
   
   if (BarsCalculated(Handle_Stochastic_W1) > 0 && dataReady == true){
      if (CopyBuffer(Handle_Stochastic_W1,0,0,Bars(_Symbol,PERIOD_W1),W1_Main) > 0){    dataReady = true;   } else {    dataReady = false;   }
      if (CopyBuffer(Handle_Stochastic_W1,1,0,Bars(_Symbol,PERIOD_W1),W1_Signal) > 0){    dataReady = true;   } else {    dataReady = false;   }
   }
   
   if (BarsCalculated(Handle_Stochastic_D1) > 0 && dataReady == true){
      if (CopyBuffer(Handle_Stochastic_D1,0,0,Bars(_Symbol,PERIOD_D1),D1_Main) > 0){    dataReady = true;   } else {    dataReady = false;   }
      if (CopyBuffer(Handle_Stochastic_D1,1,0,Bars(_Symbol,PERIOD_D1),D1_Signal) > 0){    dataReady = true;   } else {    dataReady = false;   }
   }
   
   if (BarsCalculated(Handle_Stochastic_H1) > 0 && dataReady == true){
      if (CopyBuffer(Handle_Stochastic_H1,0,0,Bars(_Symbol,PERIOD_H1),H1_Main) > 0){    dataReady = true;   } else {    dataReady = false;   }
      if (CopyBuffer(Handle_Stochastic_H1,1,0,Bars(_Symbol,PERIOD_H1),H1_Signal) > 0){    dataReady = true;   } else {    dataReady = false;   }
   }
*/
   // MAIN LOOP
   if (dataReady == true){       // proceed only if all data are ready
      for(int i=prev_calculated;i<=rates_total-1;i++){
         
         if (i > minBars){    // Make sure that i is more than minBars to avoid buffer out of range
            
            // Calculate shift for MTF
            int shift_m30 = iBarShift(_Symbol,PERIOD_M30,time[i],false);
            int shift_h1 = iBarShift(_Symbol,PERIOD_H1,time[i],false);
            int shift_d1 = iBarShift(_Symbol,PERIOD_D1,time[i],false);
            int shift_w1 = iBarShift(_Symbol,PERIOD_W1,time[i],false);
            int shift_mn = iBarShift(_Symbol,PERIOD_MN1,time[i],false);  

            // ---------- //
            // Stochastic //
            // ---------- //
            int main_line;
            int signal_line;
            int plot_value;    

            // Monthly
            if (BarsCalculated(Handle_Stochastic_MN) == ArraySize(MN_Main)){
               main_line     = MN_Main[Bars(_Symbol,PERIOD_MN1)-shift_mn-1];
               signal_line   = MN_Signal[Bars(_Symbol,PERIOD_MN1)-shift_mn-1];
               plot_value     = 1;
               plot_stochastic(i,main_line, signal_line, plot_value, up_mn, up_mn_color, down_mn, down_mn_color);
            }
         
            // Week
            if (BarsCalculated(Handle_Stochastic_W1) == ArraySize(W1_Main)){
               main_line     = W1_Main[Bars(_Symbol,PERIOD_W1)-shift_w1-1];
               signal_line   = W1_Signal[Bars(_Symbol,PERIOD_W1)-shift_w1-1];
               plot_value     = 3;
               plot_stochastic(i,main_line, signal_line, plot_value, up_w1, up_w1_color, down_w1, down_w1_color);
            }
      
            // Day
            if (BarsCalculated(Handle_Stochastic_D1) == ArraySize(D1_Main)){
               main_line     = D1_Main[Bars(_Symbol,PERIOD_D1)-shift_d1-1];
               signal_line   = D1_Signal[Bars(_Symbol,PERIOD_D1)-shift_d1-1];
               plot_value     = 5;
               plot_stochastic(i,main_line, signal_line, plot_value, up_d1, up_d1_color, down_d1, down_d1_color);
            }      
         
            //Hour
            if (BarsCalculated(Handle_Stochastic_H1) == ArraySize(H1_Main)){
               main_line     = H1_Main[Bars(_Symbol,PERIOD_H1)-shift_h1-1];            
               signal_line   = H1_Signal[Bars(_Symbol,PERIOD_H1)-shift_h1-1];
               plot_value     = 7;
               plot_stochastic(i,main_line, signal_line, plot_value, up_h1, up_h1_color, down_h1, down_h1_color);
            }
         
            //M30
            if (BarsCalculated(Handle_Stochastic_M30) == ArraySize(M30_Main)){
               main_line     = M30_Main[Bars(_Symbol,PERIOD_M30)-shift_m30-1];            
               signal_line   = M30_Signal[Bars(_Symbol,PERIOD_M30)-shift_m30-1];
               plot_value     = 9;
               plot_stochastic(i,main_line, signal_line, plot_value, up_m30, up_m30_color, down_m30, down_m30_color);
            }
            // -----------
         
            // ----------- //
            // MA Strength //
            // ----------- //
            float strength = 0;
         
            strength = plot_ma_strength(strength, i, EMA8, EMA13);
            strength = plot_ma_strength(strength, i, EMA13, EMA20);
            strength = plot_ma_strength(strength, i, EMA20, SMA21);
            strength = plot_ma_strength(strength, i, SMA21, SMA42);
            strength = plot_ma_strength(strength, i, SMA42, SMA63);
            strength = plot_ma_strength(strength, i, SMA63, SMA84);
            strength = plot_ma_strength(strength, i, SMA84, SMA126);
            strength = plot_ma_strength(strength, i, SMA126, SMA168);
            strength = plot_ma_strength(strength, i, SMA168, SMA252);
            strength = plot_ma_strength(strength, i, SMA252, SMA336);
            
            // plot line
            ma_strength[i]=strength;
            
            // set color
            if (ma_strength[i] > 3){
               ma_strength_color[i]=1;
            } else if (ma_strength[i] < -3){
               ma_strength_color[i]=3;
            } else {
               ma_strength_color[i]=0;
            }
            /*
            if (ma_strength[i] > 0){
               ma_strength_color[i]=1;
               
               // if weakening
               if (ma_strength[i] < ma_strength[i-1]){
                  ma_strength_color[i]=2;
               }
            }
            
            if (strength == 0){
               ma_strength_color[i]=0;
            }
            
            if (ma_strength[i] < 0){
               ma_strength_color[i]=3;
               
               // if strengthening
               if (ma_strength[i] > ma_strength[i-1]){
               ma_strength_color[i]=2;
               }
            }
            */
            
            // -----------
         
         }
      }

  }

   if (dataReady == true){
   
      return(rates_total-1); //Return the number of calculated bars, 
                         //subtract 1 for the last bar recalculation
   } else {
      return(0);
   }
}
//+------------------------------------------------------------------+

// -------------- //
// PLOT FUNCTIONS //
// -------------- //
void plot_stochastic(int i, double main_line, double signal_line, int plot_value, double &up_line[], double &up_color[], double &down_line[], double &down_color[]){


   if (main_line > signal_line){
        
         // Draw
         up_line[i] = plot_value;
         // Set color
         if (main_line < 20){
            up_color[i] = 0;
         }
         if (main_line >= 20 && main_line < 70){
            up_color[i] = 1;
         }
         if (main_line >= 70 && main_line < 80){
            up_color[i] = 2;
         }
         if (main_line >= 80){
            up_color[i] = 3;
         }
      }

      if (main_line < signal_line){
         down_line[i] = -plot_value;
         if (main_line > 80){
            down_color[i] = 0;
         }
         if (main_line <= 80 && main_line > 30){
            down_color[i] = 1;
         }
         if (main_line <= 30 && main_line > 20){
            down_color[i] = 2;
         }
         if (main_line < 20){
            down_color[i] = 3;
         }
      }
     
}

float plot_ma_strength(float strength, int i, double &ma1[], double &ma2[]){

   // ------- //
   // BULLISH //
   // ------- //

   // if ma1 is above ma2, +0.5
   if (ma1[i] > ma2[i]){            
      strength += 0.5;

      // if ma1 is getting higher, +0.25
      if (ma1[i] > ma1[i-1]){
         strength += 0.25;
      } 

      // if ma1 is bullish accelerating, +0.25      
      if (ma1[i] - ma1[i-1] > ma1[i-1] - ma1[i-2] ){
         strength += 0.25;
      }            
      
      // if ma1 is decelerating, -0.25
      if (ma1[i] - ma1[i-1] < ma1[i-1] - ma1[i-2]){
         strength -= 0.25;
      }
   }
   
   // ------- //
   // BEARISH //
   // ------- //
   
   // if ma1 is below ma2, -0.5
   if (ma1[i] < ma2[i]){
      strength -= 0.5;
      
      // if ma1 is getting lower, -0.25
      if (ma1[i] < ma1[i-1]){
         strength -= 0.25;
      } 

      // if ma1 is bearish accelerating, -0.25      
      if (ma1[i-1] - ma1[i] > ma1[i-2] - ma1[i-1] ){
         strength -= 0.25;
      }            
      
      // if ma1 is bearish decelerating, -0.25
      if (ma1[i-1] - ma1[i] < ma1[i-2] - ma1[i-1]){
         strength += 0.25;
      }
   
   }
   
   return strength;
}


// -------------- //
// MISC FUNCTIONS //
// -------------- //
bool LabelCreate(const long              chart_ID=0,               // chart's ID
                 const string            name="Label",             // label name
                 const int               sub_window=0,             // subwindow index
                 const int               x=0,                      // X coordinate
                 const int               y=0,                      // Y coordinate
                 const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                 const string            text="Label",             // text
                 const string            font="Arial",             // font
                 const int               font_size=10,             // font size
                 const color             clr=clrRed,               // color
                 const double            angle=0.0,                // text slope
                 const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type
                 const bool              back=false,               // in the background
                 const bool              selection=false,          // highlight to move
                 const bool              hidden=true,              // hidden in the object list
                 const long              z_order=0)                // priority for mouse click
   {
      //--- reset the error value
      ResetLastError();
      //--- create a text label
      if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
      {
         Print(__FUNCTION__,
               ": failed to create text label! Error code = ",GetLastError());
         return(false);
      }
      //--- set label coordinates
      ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
      //--- set the chart's corner, relative to which point coordinates are defined
      ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
      //--- set the text
      ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
      //--- set text font
      ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
      //--- set font size
      ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
      //--- set the slope angle of the text
      ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
      //--- set anchor type
      ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
      //--- set color
      ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
      //--- display in the foreground (false) or background (true)
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      //--- enable (true) or disable (false) the mode of moving the label by mouse
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      //--- hide (true) or display (false) graphical object name in the object list
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      //--- set the priority for receiving the event of a mouse click in the chart
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
      
      //--- successful execution
      return(true);
  }
#define PROPERTY_COPYRIGHT     "Copyright © by iDiamond @ Forex Factory"

#property   indicator_buffers 7
#property   indicator_plots   7
//--- plot Arrows
#property indicator_type1  DRAW_LINE
#property indicator_color1 clrGold  
#property indicator_type2  DRAW_LINE
#property indicator_color2 clrDarkOliveGreen
#property indicator_type3  DRAW_LINE
#property indicator_color3 clrDarkOrange
//--- the Upper BB
#property indicator_label4  "Upper"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrNONE
//--- the Lower BB
#property indicator_label5  "Lower"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrNONE
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrNONE
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrNONE

double MA42[],MA63[],MA84[],MA126[],MA168[];
double UpperBuffer[],LowerBuffer[];

int SMA42_handle=iMA(Symbol(),0,42,0,MODE_SMA,PRICE_CLOSE);
int SMA63_handle=iMA(Symbol(),0,63,0,MODE_SMA,PRICE_CLOSE);
int SMA84_handle=iMA(Symbol(),0,84,0,MODE_SMA,PRICE_CLOSE);
int SMA126_handle=iMA(Symbol(),0,126,0,MODE_SMA,PRICE_CLOSE);
int SMA168_handle=iMA(Symbol(),0,168,0,MODE_SMA,PRICE_CLOSE);
int BB_handle=iBands(Symbol(),0,21,0,2,PRICE_CLOSE);

#include <Arrays\ArrayString.mqh>                             // CArrayString
#include <ChartObjects\ChartObjectsTxtControls.mqh>           // CChartObjectButton
#define DbugInfo(x)                                           // define as x for informational debugging 4
#define INPUTVARDELIMITER               "================================"

ENUM_TIMEFRAMES period;
sinput string Note_Symbols             = INPUTVARDELIMITER;   // Symbol List

sinput string InputSymbols             = "WTI NQ100 XAGUSD ETH XAUUSD BITCOIN EURGBP EURAUD EURNZD EURUSD EURCAD EURJPY";
sinput string Note_Layout              = INPUTVARDELIMITER;   // Layout
sinput bool   bChartForeground         = true;                // Chart Foreground (Price overwrites buttons)
sinput int    iChartWindow             = 0;                   // Chart Window, 0=Main,1=Subwindow 1...
sinput ENUM_BASE_CORNER BaseCorner     = CORNER_LEFT_LOWER;   // Base Corner
sinput int    MarginX                  = 1;                   // Horizontal Margin from Corner
sinput int    MarginY                  = 1;                   // Vertical Margin from Corner
sinput int    ButtonsInARow            = 14;                  // Number of Symbol Columns
sinput int    ButtonSpacing            = 0;                   // Space Between Buttons
sinput bool   bTransparent             = false;               // Transparent Buttons

sinput string Note_Button              = INPUTVARDELIMITER;   // Unselected Button Appearance
sinput color  ButtonColr               = clrWhite;            // Button Color
sinput color  ButtonBorderColr         = clrDarkGray;         // Button Border Color
sinput string sFontName                = "Calibri Light";     // Button Font Name
sinput int    iFontSize                = 8;                   // Button Font Size
sinput color  TextColr                 = clrBlack;            // Button Text Color

sinput string Note_ButtonSelected      = INPUTVARDELIMITER;   // Selected Button Appearance
sinput color  ButtonColrSelected       = clrDimGray;          // Button Color - Selected
sinput color  ButtonBorderColrSelected = clrDarkGray;         // Button Border Color - Selected
sinput string sFontNameSelected        = "Calibri Light";     // Button Font Name - Selected
sinput int    iFontSizeSelected        = 8;                   // Button Font Size - Selected
sinput color  TextColrSelected         = clrWhite;            // Button Text Color - Selected

int SymbolIdx, iTotalSymbols;
const string sSymbolDelimiter          = " ";
string sUniquePrefix;
string sSymbolList;
string sCurr, sCurrMode;
CArrayString casSymbols;                // Symbols to use
CChartObjectButton ObjButtonSymbols[];  // Button Objects
string sGBP="WTI NQ100 XAGUSD ETH XAUUSD BITCOIN GBPAUD GBPNZD GBPUSD GBPCAD GBPJPY EURGBP",
 sEUR="WTI NQ100 XAGUSD ETH XAUUSD BITCOIN EURGBP EURAUD EURNZD EURUSD EURCAD EURJPY";
string sUSD="WTI NQ100 XAUUSD XAGUSD BITCOIN ETH USDJPY USDCAD AUDUSD NZDUSD", sJPY="WTI NQ100 XAUUSD XAGUSD BITCOIN ETH AUDJPY NZDJPY CADJPY USDJPY";

int OnInit() {

  SetIndexBuffer(0, MA42, INDICATOR_DATA);
  SetIndexBuffer(1, MA63, INDICATOR_DATA);
  SetIndexBuffer(2, MA126, INDICATOR_DATA);
  SetIndexBuffer(3,UpperBuffer,INDICATOR_DATA);
  SetIndexBuffer(4,LowerBuffer,INDICATOR_DATA);
  SetIndexBuffer(5, MA84, INDICATOR_DATA);
  SetIndexBuffer(6, MA168, INDICATOR_DATA);
  
  bool bResult;
  int iResult, Indx, iNum;
  uint FontFlags = FW_NORMAL, uiWidth, uiHeight, uiMaxWidth = 0, uiMaxHeight = 0;
  long lChartWinHandl;
  string sExeName, sSymbol;
  GlobalVariableSet("Mode",0);
  
  sExeName = MQLInfoString(MQL_PROGRAM_NAME);
  ChartGetInteger(0, CHART_WINDOW_HANDLE, 0, lChartWinHandl);
  sUniquePrefix = StringFormat("%s %lld.%d.%d[%d,%d] ", sExeName, lChartWinHandl, iChartWindow, BaseCorner, MarginX, MarginY);
  sSymbol=ChartSymbol(ChartFirst());
  //sync current chart with button collection
  sCurrMode=ObjectGetString(0,"Curr",OBJPROP_TEXT,0);
  
  if (sCurrMode=="EUR" ) {  //EUR pairs and Xau 
    sSymbolList = sEUR;
    sCurr ="EUR";
  }
  if (sCurrMode=="GBP") { 
    sSymbolList = sGBP;
    sCurr = "GBP";
  }
  if (sCurrMode=="USD") {  //USD pairs for USDCAD USDJPY
    sSymbolList = sUSD;
    sCurr = "USD";
  }
  if (sCurrMode=="JPY") {  //USD pairs for USDCAD USDJPY
    sSymbolList = sJPY;
    sCurr = "JPY";
  }
   
  iTotalSymbols = PrepareSymbols(&casSymbols);
  
  bResult = TextSetFont(sFontName, iFontSize * -10, FontFlags);
  iNum = casSymbols.Total();
  
  for (Indx = 0; Indx < iNum; Indx++)
  {   // Get Max Width and Max Height of all Unselected Symbols using this Font and Size
     TextGetSize(" " + casSymbols.At(Indx) + " ", uiWidth, uiHeight);
     if (uiWidth > uiMaxWidth)
       uiMaxWidth = uiWidth;
     if (uiHeight > uiMaxHeight)
       uiMaxHeight = uiHeight;
  }
  bResult = TextSetFont(sFontNameSelected, iFontSizeSelected * -10, FontFlags);
  for (Indx = 0; Indx < iNum; Indx++)
  {   // Get Max Width and Max Height of all Selected Symbols using this Font and Size
     TextGetSize(" " + casSymbols.At(Indx) + " ", uiWidth, uiHeight);
     if (uiWidth > uiMaxWidth)
       uiMaxWidth = uiWidth;
     if (uiHeight > uiMaxHeight)
       uiMaxHeight = uiHeight;
  }
  iResult = CreateSymbolButtons(&casSymbols, ObjButtonSymbols, (int)uiMaxWidth, (int)uiMaxHeight);
  //highlight button to current chart symbol
  SetSymbolButtonSelections();
  
  return (0);
} // OnInit() 


int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[])
{

  static datetime LastBar;
  if(LastBar==iTime(Symbol(),0,0)) return(-1);  //stop indicator from calculating current bar
  else LastBar=iTime(Symbol(),0,0);

  int iToCopy;
  if(prev_calculated>rates_total || prev_calculated<=0)
    iToCopy=rates_total;
  else
   {
    iToCopy=rates_total-prev_calculated;
    if(prev_calculated>0)
       iToCopy++;
   }
  
  if(prev_calculated==0){
    ArrayInitialize(MA42,0);
    ArrayInitialize(MA63,0);
    ArrayInitialize(MA84,0);
    ArrayInitialize(MA126,0);
    ArrayInitialize(MA168,0);
    ArrayInitialize(UpperBuffer,0);
    ArrayInitialize(LowerBuffer,0);
  } 

  CopyBuffer(SMA42_handle,0,0,iToCopy,MA42);
  CopyBuffer(SMA63_handle,0,0,iToCopy,MA63);
  CopyBuffer(SMA84_handle,0,0,iToCopy,MA84);
  CopyBuffer(SMA126_handle,0,0,iToCopy,MA126);
  CopyBuffer(SMA168_handle,0,0,iToCopy,MA168);
  CopyBuffer(BB_handle,1,0,iToCopy,UpperBuffer); //UpperBB
  CopyBuffer(BB_handle,2,0,iToCopy,LowerBuffer); //LowerBB
  return(rates_total);
}

void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam) {
  switch (id) {
    case CHARTEVENT_KEYDOWN:
      if (lparam==90) { ChangeTemplateFull(); }  // Z key, add MA
      if (lparam==82) { ChangeTemplateSim_4M(); }  // R key, simplied vs 4M template
      if (lparam==40) LowerTF(); // down arrow
      if (lparam==38) HigherTF(); // up arrow
      if (lparam==39) NextSymbol();  // right arrow              
      if (lparam==37) PrevSymbol();

      if (lparam==71) { //G change to GBP series
        SetChartCurr("GBP"); //set label to the current Currency
        sSymbolList = sGBP;
        PrepareSymbols(&casSymbols);
        SetChart(casSymbols[6]); //set charts for multi TF for one symbol
      }
      if (lparam==69) { //E
        SetChartCurr("EUR"); //set label to the current Currency
        sSymbolList = sEUR;
        PrepareSymbols(&casSymbols);
        SetChart(casSymbols[6]); //set all charts to the first symbol in the sSymbolList
      } 
      if (lparam==74 && (_Symbol=="GBPJPY" || _Symbol=="EURJPY" || _Symbol=="USDJPY" )) { //J must be pressed on GBPJPY or EURJPY in order to change to all JPY pairs
         SetChartCurr("JPY");
         sSymbolList = sJPY;
         PrepareSymbols(&casSymbols);
         SetChart(casSymbols[6]); //set all charts to the first symbol in the sSymbolList
      }
      if (lparam==85 && (_Symbol=="GBPUSD" || _Symbol=="EURUSD")) { //U must be pressed on GBPUSD or EURUSD in order to change to all JPY pairs
         SetChartCurr("USD");
         sSymbolList = sUSD;
         PrepareSymbols(&casSymbols);
         SetChart(casSymbols[6]); //set all charts to the first symbol in the sSymbolList
      }
      //for six charts version, don't allow TF lower than H4
      if (lparam==73 && NumOfCharts()<4) {ChangeTF(PERIOD_M1);} //I M1 one min chart
      if (lparam==76 && NumOfCharts()<4) {ChangeTF(PERIOD_M5);} //L         
      if (lparam==77 && NumOfCharts()<4) {ChangeTF(PERIOD_M15);} //M
      if (lparam==72 && NumOfCharts()<4) {ChangeTF(PERIOD_H1);} //H
      if (lparam==55) {ChangeTF(PERIOD_H4);} //7
      if (lparam==56) {ChangeTF(PERIOD_H8);} //8
      if (lparam==57) {ChangeTF(PERIOD_H12);} //9    
      if (lparam==68) {ChangeTF(PERIOD_D1);} //D
      if (lparam==75) {ChangeTF(PERIOD_W1);} //K
      
      if (sCurr=="EUR") {  //changing symbol under EUR
        if (lparam==87) {SetChart(casSymbols[0]);} //W WTI
        if (lparam==81) {SetChart(casSymbols[1]);} //Q NQ100
        if (lparam==86) {SetChart(casSymbols[2]);} //V Siver 86
        if (lparam==84) {SetChart(casSymbols[3]);} //T ETH 84 ETHEREUM
        if (lparam==88) {SetChart(casSymbols[4]);} //X Gold 88
        if (lparam==66) {SetChart(casSymbols[5]);} //B BITCOIN 66
        if (lparam==69) {SetChart(casSymbols[6]);} //E         
        if (lparam==65) {SetChart(casSymbols[7]);} //A
        if (lparam==78) {SetChart(casSymbols[8]);} //N
        if (lparam==85) {SetChart(casSymbols[9]);} //U
        if (lparam==67) {SetChart(casSymbols[10]);} //C
        if (lparam==74) {SetChart(casSymbols[11]);} //J
      }
      if (sCurr=="GBP") {
        if (lparam==87) {SetChart(casSymbols[0]);} //W WTI
        if (lparam==81) {SetChart(casSymbols[1]);} //Q NQ100
        if (lparam==86) {SetChart(casSymbols[2]);} //V Siver 86
        if (lparam==84) {SetChart(casSymbols[3]);} //T ETH 84 ETHEREUM
        if (lparam==88) {SetChart(casSymbols[4]);} //X Gold 88
        if (lparam==66) {SetChart(casSymbols[5]);} //B BITCOIN 66          
        if (lparam==65) {SetChart(casSymbols[6]);} //A
        if (lparam==78) {SetChart(casSymbols[7]);} //N
        if (lparam==85) {SetChart(casSymbols[8]);} //U
        if (lparam==67) {SetChart(casSymbols[9]);} //C
        if (lparam==74) {SetChart(casSymbols[10]);} //J  Skipping EURGBP

      }
      if (sCurr=="JPY") {
        if (lparam==87) {SetChart(casSymbols[0]);} //W WTI
        if (lparam==81) {SetChart(casSymbols[1]);} //Q NQ100
        if (lparam==88) {SetChart(casSymbols[2]);} //X Gold
        if (lparam==86) {SetChart(casSymbols[3]);} //V Siver
        if (lparam==66) {SetChart(casSymbols[4]);} //B BITCOIN
        if (lparam==84) {SetChart(casSymbols[5]);} //T ETHEREUM                
        if (lparam==65) {SetChart(casSymbols[6]);} //A
        if (lparam==78) {SetChart(casSymbols[7]);} //N
        if (lparam==67) {SetChart(casSymbols[8]);} //C
        if (lparam==85) {SetChart(casSymbols[9]);} //U
      }
      if (sCurr=="USD") {
        if (lparam==87) {SetChart(casSymbols[0]);} //W WTI
        if (lparam==81) {SetChart(casSymbols[1]);} //Q NQ100
        if (lparam==88) {SetChart(casSymbols[2]);} //X Gold
        if (lparam==86) {SetChart(casSymbols[3]);} //V Siver
        if (lparam==66) {SetChart(casSymbols[4]);} //B BITCOIN
        if (lparam==84) {SetChart(casSymbols[5]);} //T ETHEREUM                
        if (lparam==74) {SetChart(casSymbols[6]);} //J
        if (lparam==67) {SetChart(casSymbols[7]);} //C
        if (lparam==65) {SetChart(casSymbols[8]);} //A
        if (lparam==78) {SetChart(casSymbols[9]);} //N
      }
      break;
    case CHARTEVENT_MOUSE_MOVE:
    case CHARTEVENT_MOUSE_WHEEL:
    case CHARTEVENT_OBJECT_CREATE: 
         break;
    case CHARTEVENT_OBJECT_CHANGE:
         break;
    case CHARTEVENT_OBJECT_DELETE:
         break;
    case CHARTEVENT_CLICK:
         break;
    case CHARTEVENT_OBJECT_CLICK:  // lparam = X coordinate, dparam = Y coordinate, sparam = Name of the graphical object
         PressButton(sparam);
         break;
    case CHARTEVENT_OBJECT_DRAG:
    case CHARTEVENT_OBJECT_ENDEDIT:
         break;
    case CHARTEVENT_CHART_CHANGE:
         ManualChangeCharts();
         break;
    case CHARTEVENT_CUSTOM:
    case CHARTEVENT_CUSTOM_LAST:
         break;
  }//switch
} // OnChartEvent()

void SetChartCurr(string sCurr) {
  
  long ID=ChartFirst();
  while(ID!=-1) {
    ObjectSetString(ID,"Curr",OBJPROP_TEXT,sCurr);
    ID=ChartNext(ID);
  }

}

void NextSymbol() {
  int idx;
  string sSym;
  //if symbol is the last of the list
  for (idx = 0; idx < iTotalSymbols-1; idx++) {
    sSym=_Symbol;
    if (sSym=="ETHEREUM") sSym="ETH";
    if (sSym==casSymbols[idx]) SetChart(casSymbols[idx+1]);
  }
  SymbolIdx=idx+1;
}

void PrevSymbol() {
  int idx;
  string sSym;
  //if symbol is the last of the list
  for (idx = 1; idx < iTotalSymbols; idx++) {
    sSym=_Symbol;
    if (sSym=="ETHEREUM") sSym="ETH";
    if (sSym==casSymbols[idx]) SetChart(casSymbols[idx-1]);
  }
  SymbolIdx=idx-1;
}

void PressButton(string sKey) {
  int iButton, nObjects;
  string sDescKey;
  
  nObjects = ArraySize(ObjButtonSymbols);
  for (iButton = 0; iButton < nObjects; iButton++) {
    sDescKey=ObjButtonSymbols[iButton].Name();
    if (sDescKey == sKey) {  // if button clicked, for ETH we need convert
      SetChart(ObjButtonSymbols[iButton].Description());
      SymbolIdx=iButton;
      break;
    }
  }//for
}

void ChangeTemplateFull() {
//change to full or simple
  string sTemplate, sFullSim;
  sFullSim=ObjectGetString(0,"FullSim",OBJPROP_TEXT,0);
  //full set
  if (sFullSim!="Full") {
    PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,clrGold);
    PlotIndexSetInteger(1,PLOT_LINE_COLOR,0,clrDarkOliveGreen);
    PlotIndexSetInteger(2,PLOT_LINE_COLOR,0,clrDarkOrange);
    PlotIndexSetInteger(3,PLOT_LINE_COLOR,0,clrDimGray);
    PlotIndexSetInteger(4,PLOT_LINE_COLOR,0,clrDimGray);
    PlotIndexSetInteger(5,PLOT_LINE_COLOR,0,clrBlack);
    PlotIndexSetInteger(6,PLOT_LINE_COLOR,0,clrMaroon);
    sFullSim="Full";
  } 
  else {
    PlotIndexSetInteger(3,PLOT_LINE_COLOR,0,clrNONE);
    PlotIndexSetInteger(4,PLOT_LINE_COLOR,0,clrNONE);
    PlotIndexSetInteger(5,PLOT_LINE_COLOR,0,clrNONE);
    PlotIndexSetInteger(6,PLOT_LINE_COLOR,0,clrNONE);
    sFullSim="Sim";    
  }
  
  ObjectSetString(0,"FullSim",OBJPROP_TEXT,sFullSim);
  //ObjectSetString(0,"Curr",OBJPROP_TEXT,sCurrMode);
  ChartSaveTemplate(0,"MyTemplate");
  long ID=ChartFirst();
  while(ID!=-1) {
    ChartApplyTemplate(ID,"MyTemplate");
    ChartRedraw(ID);
    ID=ChartNext(ID);
  }
}

void ChangeTemplateSim_4M() {
//change to full or simple
  string sTemplate, sFullSim, sMode;
  sFullSim=ObjectGetString(0,"FullSim",OBJPROP_TEXT,0);
  if (sFullSim!="Sim") { 
    PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,clrGold);
    PlotIndexSetInteger(1,PLOT_LINE_COLOR,0,clrDarkOliveGreen);
    PlotIndexSetInteger(2,PLOT_LINE_COLOR,0,clrDarkOrange);    
    PlotIndexSetInteger(3,PLOT_LINE_COLOR,0,clrNONE);
    PlotIndexSetInteger(4,PLOT_LINE_COLOR,0,clrNONE);
    PlotIndexSetInteger(5,PLOT_LINE_COLOR,0,clrNONE);
    PlotIndexSetInteger(6,PLOT_LINE_COLOR,0,clrNONE);
    sFullSim="Sim"; 
  } //full set
  else { 
    //4M
    PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,clrNONE); 
    PlotIndexSetInteger(1,PLOT_LINE_COLOR,0,clrNONE);
    PlotIndexSetInteger(2,PLOT_LINE_COLOR,0,clrNONE);
    PlotIndexSetInteger(3,PLOT_LINE_COLOR,0,clrNONE);
    PlotIndexSetInteger(4,PLOT_LINE_COLOR,0,clrNONE);
    PlotIndexSetInteger(5,PLOT_LINE_COLOR,0,clrNONE);
    PlotIndexSetInteger(6,PLOT_LINE_COLOR,0,clrNONE);
    sFullSim="4M"; 
  }
  
  ObjectSetString(0,"FullSim",OBJPROP_TEXT,sFullSim);
  //ObjectSetString(0,"Curr",OBJPROP_TEXT,sCurrMode);
  Print(sCurrMode);
  ChartSaveTemplate(0,"MyTemplate");
  long ID=ChartFirst();
  while(ID!=-1) {
    ChartApplyTemplate(ID,"MyTemplate");
    ChartRedraw(ID);
    ID=ChartNext(ID);
  }
}

void ManualChangeCharts() {
  long id = ChartFirst();
  if (ChartSymbol(id)!= ChartSymbol(ChartNext(id))) {
    SetChart(ChartSymbol(id)); //change all the charts to the symbol of the first chart
  }
}
//change all the charts to the specified symbol.
void SetChart(string sSymbol) {
  if (sSymbol=="ETH") sSymbol="ETHEREUM";
  long id=ChartFirst();
  while(id!=-1) {
    ChartSetSymbolPeriod(id, sSymbol, ChartPeriod(id));  // Set/Change Symbol
    id=ChartNext(id);
  }
}

int NumOfCharts() {
  int iChartsNum=0;
  //count number of charts
  long id=ChartFirst();
  while (id!=-1) {
    iChartsNum=iChartsNum+1;
    id=ChartNext(id);
  }
  return iChartsNum;
}

void ChangeTF(ENUM_TIMEFRAMES iPeriod) {
 
  long id=ChartFirst();
  ChartSetSymbolPeriod(id, ChartSymbol(id), iPeriod);  // Set/Change Symbol
  GetTF(iPeriod);
  id=id+2;
  ChartSetSymbolPeriod(id, ChartSymbol(id), iPeriod);  // Set/Change Symbol
  GetTF(iPeriod);
  id=id+2;
  ChartSetSymbolPeriod(id, ChartSymbol(id), iPeriod);  // Set/Change Symbol
  GetTF(iPeriod);
  id=id-3;
  ChartSetSymbolPeriod(id, ChartSymbol(id), iPeriod);  // Set/Change Symbol
  GetTF(iPeriod);
  id=id+2;
  ChartSetSymbolPeriod(id, ChartSymbol(id), iPeriod);  // Set/Change Symbol
  GetTF(iPeriod);
  id=id+2;
  ChartSetSymbolPeriod(id, ChartSymbol(id), iPeriod);  // Set/Change Symbol   
}

void GetTF(ENUM_TIMEFRAMES &iPeriod)
{
   if(iPeriod<PERIOD_M1) iPeriod=PERIOD_M1;
   else
      if(iPeriod>PERIOD_MN1) iPeriod=PERIOD_MN1;
   else
      if(iPeriod>PERIOD_W1) iPeriod=PERIOD_W1;
   else
      if(iPeriod>PERIOD_D1) iPeriod=PERIOD_D1;
   else
      if(iPeriod>PERIOD_H12) iPeriod=PERIOD_H12;
   else
      if(iPeriod>PERIOD_H8) iPeriod=PERIOD_H8;
   else
      if(iPeriod>PERIOD_H4) iPeriod=PERIOD_H4;
   else
      if(iPeriod>PERIOD_H1) iPeriod=PERIOD_H1;
   else
      if(iPeriod>PERIOD_M30) iPeriod=PERIOD_M30;
   else
      if(iPeriod>PERIOD_M15) iPeriod=PERIOD_M15;
   else
      if(iPeriod>PERIOD_M5) iPeriod=PERIOD_M5;
   else
      if(iPeriod>PERIOD_M1) iPeriod=PERIOD_M1;
}

void OnDeinit(const int reason)
{
   int nButtons, iButton;
   
   //casSymbols.Clear();
   
   nButtons = ArraySize(ObjButtonSymbols);    
   for (iButton = 0; iButton < nButtons; iButton++)
   {      
   //    bResult = ObjButtonSymbols[iButton].Delete();
   }
   //ArrayFree(ObjButtonSymbols);       
   
   ChartRedraw(); 
} // OnDeinit()


//add symbols list to Array class
int PrepareSymbols(CArrayString* SymbolsArray)
{
  int iIndx, nSymbols;
  int nSubStrings;
  ushort uDelimiter;
  string sResult[];
  SymbolsArray.Clear();
  
  uDelimiter = StringGetCharacter(sSymbolDelimiter, 0); 
  nSubStrings = StringSplit(sSymbolList, uDelimiter, sResult);
  
  for (iIndx = 0; iIndx < nSubStrings; iIndx++) {
    SymbolsArray.Add(sResult[iIndx]);
  }
     
  return( nSymbols = SymbolsArray.Total() );
} // PrepareSymbols()

//  iWidth, iHeight specify Width/Height of each Button
int CreateSymbolButtons(CArrayString* SymbolsArray, CChartObjectButton& ButtonSymbols[], int iWidth, int iHeight)
{
    bool bResult;
    int iRow, nRows, iCol, Xdistance, Ydistance;
    int nSymbols, iSymbol, iResult, ChartWin;
    string UniqueName;


    //DbugInfo(Print(__FILE__, " ", __FUNCTION__, "@", __LINE__); )
    ChartSetInteger(0, CHART_FOREGROUND, bChartForeground);  // Price chart in the foreground

    nSymbols = casSymbols.Total();
    nRows = (nSymbols / ButtonsInARow);    // Div, Full Rows
    if ((nSymbols % ButtonsInARow) > 0)    // Modulus Remainder, if a Partial Row
      nRows++;

    ArrayFree(ObjButtonSymbols);    
    iResult = ArrayResize(ObjButtonSymbols, nSymbols);
    for (iSymbol = 0; iSymbol < nSymbols; iSymbol++)
      {
          ChartWin = iChartWindow;
          UniqueName = sUniquePrefix + casSymbols[iSymbol] + "-" + string(iSymbol);   
          bResult = ObjButtonSymbols[iSymbol].Create(0, UniqueName, ChartWin, 0, 0, 1, 1);
          bResult = ObjButtonSymbols[iSymbol].Description(casSymbols[iSymbol]);
          
          bResult = ObjButtonSymbols[iSymbol].SetInteger(OBJPROP_BACK, bTransparent);       
          //bResult = ObjButtonSymbols[iSymbol].SetInteger(OBJPROP_HIDDEN, true); // Prohibit showing via terminal menu "Charts" - "Objects" - "List of objects". 
          bResult = ObjButtonSymbols[iSymbol].State(false);                       // button state (Pressed/Depressed) 
          //bResult = ObjButtonSymbols[iSymbol].Tooltip(casSymbols[iSymbol]);

          // Determine the Button Row. Start at Top if using a Top Corner, Reverse Order if using a Lower Corner 
          if ((BaseCorner == CORNER_LEFT_LOWER) || (BaseCorner == CORNER_RIGHT_LOWER))
            iRow = (nRows - 1) - (iSymbol / ButtonsInARow);
            else iRow = iSymbol / ButtonsInARow;  // Div
            
          // Determine the Button Column. Start at Left if using a Left Corner, Reverse Order if using a Right Corner 
          if ((BaseCorner == CORNER_RIGHT_LOWER) || (BaseCorner == CORNER_RIGHT_UPPER))
            iCol = (ButtonsInARow - 1) - (iSymbol % ButtonsInARow);
            else iCol = iSymbol % ButtonsInARow;  // Modulus Remainder

          Xdistance = MarginX + (iCol * (iWidth + ButtonSpacing));
          if ((BaseCorner == CORNER_RIGHT_LOWER) || (BaseCorner == CORNER_RIGHT_UPPER))
            Xdistance += iWidth;
          Ydistance = MarginY + (iRow * (iHeight + ButtonSpacing));
          if ((BaseCorner == CORNER_LEFT_LOWER) || (BaseCorner == CORNER_RIGHT_LOWER))
            Ydistance += iHeight;

          bResult = ObjButtonSymbols[iSymbol].Corner(BaseCorner);
          bResult = ObjButtonSymbols[iSymbol].X_Distance(Xdistance);
          bResult = ObjButtonSymbols[iSymbol].Y_Distance(Ydistance);
          bResult = ObjButtonSymbols[iSymbol].X_Size(iWidth);
          bResult = ObjButtonSymbols[iSymbol].Y_Size(iHeight);
      }

    return(0);
} // CreateSymbolButtons()


void SetSymbolButtonSelections() {
  int nButtons, iSymbol;
  string sDesc;
  nButtons = ArraySize(ObjButtonSymbols);    
  for (iSymbol = 0; iSymbol < nButtons; iSymbol++) {
    sDesc=ObjButtonSymbols[iSymbol].Description();
    if (ChartFirst()==ChartID()) {
       if (sDesc == _Symbol || (sDesc == "ETH" && _Symbol == "ETHEREUM") )
       {
         SymbolIdx=iSymbol; //track current symbol idx
         ObjButtonSymbols[iSymbol].BackColor(ButtonColrSelected);
         ObjButtonSymbols[iSymbol].BorderColor(ButtonBorderColrSelected);
         ObjButtonSymbols[iSymbol].Color(TextColrSelected);
         ObjButtonSymbols[iSymbol].Font(sFontNameSelected);
         ObjButtonSymbols[iSymbol].FontSize(iFontSizeSelected);
         continue;
       }
        
       ObjButtonSymbols[iSymbol].BackColor(ButtonColr);
       ObjButtonSymbols[iSymbol].BorderColor(ButtonBorderColr);
       ObjButtonSymbols[iSymbol].Color(TextColr);
       ObjButtonSymbols[iSymbol].Font(sFontName);
       ObjButtonSymbols[iSymbol].FontSize(iFontSize);
    } //Chartfirst
    else {  //if not first chart camoufalge them
       SymbolIdx=iSymbol; //track current symbol idx
       ObjButtonSymbols[iSymbol].BackColor(clrDarkGray);
       ObjButtonSymbols[iSymbol].BorderColor(clrDarkGray);
       ObjButtonSymbols[iSymbol].Color(clrDarkGray);
       ObjButtonSymbols[iSymbol].Font(sFontName);
       ObjButtonSymbols[iSymbol].FontSize(iFontSize);      
    } 
  }//for
} // SetSymbolButtonSelections()

void HigherTF() //up arrow
{
   long id=ChartFirst();
   if (ChartPeriod(id)==PERIOD_MN1) id=-1;   //can't go up further
   while(id!=-1) {
      period=ChartPeriod(id);
      if(period<PERIOD_M1) period=PERIOD_M1;
      else
         if(period<PERIOD_M1) period=PERIOD_M1; 
      else
         if(period<PERIOD_M5) period=PERIOD_M5; 
      else
         if(period<PERIOD_M15) period=PERIOD_M15;
      else
         if(period<PERIOD_M30) period=PERIOD_M30;
      else
         if(period<PERIOD_H1) period=PERIOD_H1;
      else
         if(period<PERIOD_H4) period=PERIOD_H4;
      else
         if(period<PERIOD_H8) period=PERIOD_H8;
      else
         if(period<PERIOD_H12) period=PERIOD_H12;
      else
         if(period<PERIOD_D1) period=PERIOD_D1;
      else
         if(period<PERIOD_W1) period=PERIOD_W1;
      else
         if(period<PERIOD_MN1) period=PERIOD_MN1;
      else
         period=PERIOD_M5;

      string symbol=ChartSymbol(id);
      ChartSetSymbolPeriod(id,symbol,period);
      id=ChartNext(id);         
   } //while
}

void LowerTF() //down arrow
{
  bool bM1=false;
  long id;
  id=ChartFirst();
  //look through all the charts to find if one of them is M1, if true then we shall not shift TF down
  while(id!=-1) {    
    if (ChartPeriod(id)==PERIOD_M1) {bM1=true;}
    id=ChartNext(id);
  }//while
  
  if (bM1) return;  //exit function
  
  id=ChartFirst();
  while(id!=-1) {    
    period=ChartPeriod(id);
    if(period<PERIOD_M1) period=PERIOD_M1;
    else
       if(period>PERIOD_MN1) period=PERIOD_MN1;
    else
       if(period>PERIOD_W1) period=PERIOD_W1;
    else
       if(period>PERIOD_D1) period=PERIOD_D1;
    else
       if(period>PERIOD_H12) period=PERIOD_H12;
    else
       if(period>PERIOD_H8) period=PERIOD_H8;
    else
       if(period>PERIOD_H4) period=PERIOD_H4;
    else
       if(period>PERIOD_H1) period=PERIOD_H1;
    else
       if(period>PERIOD_M30) period=PERIOD_M30;
    else
       if(period>PERIOD_M15) period=PERIOD_M15;
    else
       if(period>PERIOD_M5) period=PERIOD_M5;
    else
       if(period>PERIOD_M1) period=PERIOD_M1;
  
    string symbol=ChartSymbol(id);
    ChartSetSymbolPeriod(id,symbol,period);
    id=ChartNext(id);
  }//while
}
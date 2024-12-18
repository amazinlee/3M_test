#define PROPERTY_COPYRIGHT     "Copyright © by iDiamond @ Forex Factory"

#include <Arrays\ArrayString.mqh>                             // CArrayString
#include <ChartObjects\ChartObjectsTxtControls.mqh>           // CChartObjectButton
#define DbugInfo(x)                                           // define as x for informational debugging 4
#define INPUTVARDELIMITER               "================================"

ENUM_TIMEFRAMES period;
sinput string Note_Symbols             = INPUTVARDELIMITER;   // Symbol List
sinput string InputSymbols             = "NQ WTI XAUUSD XAGUSD ETH BTC EURGBP EURAUD EURNZD EURUSD EURCAD EURJPY";
sinput string Note_Layout              = INPUTVARDELIMITER;   // Layout
sinput bool   bChartForeground         = true;                // Chart Foreground (Price overwrites buttons)
sinput int    iChartWindow             = 0;                   // Chart Window, 0=Main,1=Subwindow 1...
sinput ENUM_BASE_CORNER BaseCorner     = CORNER_RIGHT_UPPER;   // Base Corner CORNER_LEFT_LOWER
sinput int    MarginX                  = 1;                   // Horizontal Margin from Corner
sinput int    MarginY                  = 50;                   // Vertical Margin from Corner
sinput int    ButtonsInARow            = 1;                  // Number of Symbol Columns 14
sinput int    ButtonSpacing            = 2;                   // Space Between Buttons
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
//EightCap NDX100 for NQ
string sGBP="ETH BTC XAUUSD XAGUSD NQ WTI GBPAUD GBPNZD GBPUSD GBPCAD GBPJPY EURGBP",
 sEUR="ETH BTC XAUUSD XAGUSD NQ WTI EURGBP EURAUD EURNZD EURUSD EURCAD EURJPY";
string sUSD="ETH BTC XAUUSD XAGUSD NQ WTI USDJPY USDCAD AUDUSD NZDUSD", sJPY="ETH BTC XAUUSD XAGUSD NQ WTI AUDJPY NZDJPY CADJPY USDJPY";

int OnInit() {
 
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
  //read the CurrMode from File
  sCurrMode=ReadCurr();
  if (sCurrMode==NULL) sCurrMode="EUR"; //first loading, file not exist yet
  
  if (sCurrMode=="EUR") {  //EUR pairs and Xau 
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

int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[]) {
  return(rates_total);
}
//store info into file as memory can't stay perm
void StoreCurr(string sCurrency) {
  int file_handle=FileOpen("Curr.csv",FILE_WRITE|FILE_CSV);
  FileWriteString(file_handle,sCurrency);
  FileClose(file_handle);
}

string ReadCurr() {
  string sCurrency;
  int file_handle=FileOpen("Curr.csv",FILE_READ|FILE_CSV);
  sCurrency=FileReadString(file_handle,1);  //FileReadString(file_handle,sCurr);
  FileClose(file_handle);
  
  return sCurrency;
}

void OnChartEvent(const int ID, const long& lparam, const double& dparam, const string& sparam) {
  switch (ID) {
    case CHARTEVENT_KEYDOWN:
      if (lparam==90) { ChangeTemplateFull(); }  // Z key, add MA
      if (lparam==82) { ChangeTemplateSim_4M(); }  // R key, simplied vs 4M template
      if (lparam==40) LowerTF(); // down arrow
      if (lparam==38) HigherTF(); // up arrow
      if (lparam==39) NextSymbol();  // right arrow
      if (lparam==37) PrevSymbol();  //left arrow
      if (lparam==33) HigherTF_Current(); // page up
      if (lparam==34) LowerTF_Current();  // page down
      

      if (lparam==71) { //G change to GBP series
        SetChartCurr("GBP"); //set label to the current Currency
        sSymbolList = sGBP;
        PrepareSymbols(&casSymbols);
        SetChart(casSymbols[6]); //set charts for multi TF for one symbol
        StoreCurr("GBP");
      }
      if (lparam==69) { //E
        SetChartCurr("EUR"); //set label to the current Currency
        sSymbolList = sEUR;
        PrepareSymbols(&casSymbols);
        SetChart(casSymbols[6]); //set all charts to the first symbol in the sSymbolList
        StoreCurr("EUR");
      } 
      if (lparam==74 && (_Symbol=="GBPJPY" || _Symbol=="EURJPY" || _Symbol=="USDJPY" )) { //J must be pressed on GBPJPY or EURJPY in order to change to all JPY pairs
         SetChartCurr("JPY");
         sSymbolList = sJPY;
         PrepareSymbols(&casSymbols);
         SetChart(casSymbols[6]); //set all charts to the first symbol in the sSymbolList
         StoreCurr("JPY");
      }
      if (lparam==85 && (_Symbol=="GBPUSD" || _Symbol=="EURUSD")) { //U must be pressed on GBPUSD or EURUSD in order to change to all JPY pairs
         SetChartCurr("USD");
         sSymbolList = sUSD;
         PrepareSymbols(&casSymbols);
         SetChart(casSymbols[6]); //set all charts to the first symbol in the sSymbolList
         StoreCurr("USD");
      }
      //for six charts version, don't allow TF lower than H4
      //if (lparam==73 && getNumOfCharts()<4) {ChangeTF_2Charts(PERIOD_M1);} //I M1 one min chart
      if (lparam==76 && getNumOfCharts()<4) {ChangeTF_2Charts(PERIOD_M5);} //L         
      if (lparam==77 && getNumOfCharts()<4) {ChangeTF_2Charts(PERIOD_M15);} //M
      if (lparam==72 && getNumOfCharts()<4) {ChangeTF_2Charts(PERIOD_H1);} //H
      if (lparam==55 && getNumOfCharts()<4) {ChangeTF_2Charts(PERIOD_H4);} //7
      if (lparam==56 && getNumOfCharts()<4) {ChangeTF_2Charts(PERIOD_H8);} //8
      if (lparam==57) {ChangeTF(PERIOD_H12);} //9    
      if (lparam==68) {ChangeTF(PERIOD_D1);} //D
      if (lparam==75) {ChangeTF(PERIOD_W1);} //K
      
      if (sCurr=="EUR") {  //changing symbol under EUR
        if (lparam==84) {SetChart(casSymbols[0]);} //T ETH 84
        if (lparam==66) {SetChart(casSymbols[1]);} //B BTC 66    
        if (lparam==88) {SetChart(casSymbols[2]);} //X Gold 88 
        if (lparam==86) {SetChart(casSymbols[3]);} //V Siver 86
        if (lparam==81) {SetChart(casSymbols[4]);} //Q NDX100 81
        if (lparam==87) {SetChart(casSymbols[5]);} //W WTI 87
        if (lparam==69) {SetChart(casSymbols[6]);} //E         
        if (lparam==65) {SetChart(casSymbols[7]);} //A
        if (lparam==78) {SetChart(casSymbols[8]);} //N
        if (lparam==85) {SetChart(casSymbols[9]);} //U
        if (lparam==67) {SetChart(casSymbols[10]);} //C
        if (lparam==74) {SetChart(casSymbols[11]);} //J
      }
      if (sCurr=="GBP") {
        if (lparam==84) {SetChart(casSymbols[0]);} //T ETH 84
        if (lparam==66) {SetChart(casSymbols[1]);} //B BTC 66    
        if (lparam==88) {SetChart(casSymbols[2]);} //X Gold 88 
        if (lparam==86) {SetChart(casSymbols[3]);} //V Siver 86
        if (lparam==81) {SetChart(casSymbols[4]);} //Q NDX100 81
        if (lparam==87) {SetChart(casSymbols[5]);} //W WTI 87         
        if (lparam==65) {SetChart(casSymbols[6]);} //A
        if (lparam==78) {SetChart(casSymbols[7]);} //N
        if (lparam==85) {SetChart(casSymbols[8]);} //U
        if (lparam==67) {SetChart(casSymbols[9]);} //C
        if (lparam==74) {SetChart(casSymbols[10]);} //J  Skipping EURGBP

      }
      if (sCurr=="JPY") {
        if (lparam==84) {SetChart(casSymbols[0]);} //T ETH 84
        if (lparam==66) {SetChart(casSymbols[1]);} //B BTC 66    
        if (lparam==88) {SetChart(casSymbols[2]);} //X Gold 88 
        if (lparam==86) {SetChart(casSymbols[3]);} //V Siver 86
        if (lparam==81) {SetChart(casSymbols[4]);} //Q NDX100 81
        if (lparam==87) {SetChart(casSymbols[5]);} //W WTI 87           
        if (lparam==65) {SetChart(casSymbols[6]);} //A
        if (lparam==78) {SetChart(casSymbols[7]);} //N
        if (lparam==67) {SetChart(casSymbols[8]);} //C
        if (lparam==85) {SetChart(casSymbols[9]);} //U
      }
      if (sCurr=="USD") {
        if (lparam==84) {SetChart(casSymbols[0]);} //T ETH 84
        if (lparam==66) {SetChart(casSymbols[1]);} //B BTC 66    
        if (lparam==88) {SetChart(casSymbols[2]);} //X Gold 88 
        if (lparam==86) {SetChart(casSymbols[3]);} //V Siver 86
        if (lparam==81) {SetChart(casSymbols[4]);} //Q NDX100 81
        if (lparam==87) {SetChart(casSymbols[5]);} //W WTI 87             
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
         if (ChartFirst()==ChartID()) {PressButton(sparam);} //only allow button to be press if it is first chart
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

void SetChartCurr(string sCurrency) {
  long ID=ChartFirst();
  while(ID!=-1) {
    ObjectSetString(ID,"Curr",OBJPROP_TEXT,sCurrency);
    ID=ChartNext(ID);
  }
}

void NextSymbol() {
  int idx;
  string sSym;
  //if symbol is the last of the list
  for (idx = 0; idx < iTotalSymbols-1; idx++) {
    sSym=_Symbol;
    if (sSym=="USOUSD") sSym="WTI";
    if (sSym=="NDX100") sSym="NQ";
    if (sSym=="ETHUSD") sSym="ETH";
    if (sSym=="BTCUSD") sSym="BTC";
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
    if (sSym=="USOUSD") sSym="WTI";
    if (sSym=="NDX100") sSym="NQ";
    if (sSym=="ETHUSD") sSym="ETH";
    if (sSym=="BTCUSD") sSym="BTC";
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
  string sTemplate, sMode;
  sMode=ObjectGetString(0,"FullSim",OBJPROP_TEXT,0);
  //toggle to full
  if (sMode!="Full") {
    sMode="Full";
    sTemplate="MTF_" + sMode;
  }
  else { //toggle to sim
    sMode="Sim";
    sTemplate="MTF_" + sMode;
  }
  //set all chart to Sim template   
  long ID=ChartFirst();
  while(ID!=-1) {
    ChartApplyTemplate(ID,sTemplate);
    ObjectSetString(ID,"FullSim",OBJPROP_TEXT,sMode);
    ChartRedraw(ID);
    ID=ChartNext(ID);
  } //while
}

void ChangeTemplateSim_4M() {
//change to 4M or simple
  string sTemplate, sMode;
  
  sMode=ObjectGetString(0,"FullSim",OBJPROP_TEXT,0);
  if (sMode!="Sim") {
    sMode="Sim";
    sTemplate="MTF_" + sMode;
  }
  else { 
    //4M
    sMode="4M";
    sTemplate="MTF_" + sMode;
  }
  
  long ID=ChartFirst();
  while(ID!=-1) {
    ChartApplyTemplate(ID,sTemplate);
    ObjectSetString(ID,"FullSim",OBJPROP_TEXT,sMode);  
    ChartRedraw(ID);
    ID=ChartNext(ID);
  } //while 
}

void ManualChangeCharts() {
  long ID = ChartFirst();
  if (ChartSymbol(ID)!= ChartSymbol(ChartNext(ID))) {
    SetChart(ChartSymbol(ID)); //change all the charts to the symbol of the first chart
    ChartRedraw(ID);
  }
}
//change all the charts to the specified symbol.
void SetChart(string sSymbol) {
  if (sSymbol=="ETH") sSymbol="ETHUSD";
  if (sSymbol=="BTC") sSymbol="BTCUSD";
  if (sSymbol=="WTI") sSymbol="USOUSD";
  if (sSymbol=="NQ") sSymbol="NDX100"; //EightCap
  long ID=ChartFirst();
  while(ID!=-1) {
    ChartSetSymbolPeriod(ID, sSymbol, ChartPeriod(ID));  // Set/Change Symbol
    ChartRedraw(ID);
    ID=ChartNext(ID);
  }
}

int getNumOfCharts() {
  int iChartsNum=0;
  //count number of charts
  long ID=ChartFirst();
  while (ID!=-1) {
    iChartsNum=iChartsNum+1;
    ID=ChartNext(ID);
  }
  return iChartsNum;
}

void ChangeTF(ENUM_TIMEFRAMES iPeriod) {
  if (iPeriod==PERIOD_W1) {
    SetTF_W1();
  }
  if (iPeriod==PERIOD_D1) {
    SetTF_D1();
  }
  if (iPeriod==PERIOD_H12) {
    SetTF_H12();
  }  
}

void ChangeTF_2Charts(ENUM_TIMEFRAMES iPeriod) {
  long ID=ChartFirst();
  ChartSetSymbolPeriod(ID, ChartSymbol(ID), iPeriod);  // Set/Change Symbol
  GetTF_2Charts(iPeriod);
  ID=ChartNext(ID);
  ChartSetSymbolPeriod(ID, ChartSymbol(ID), iPeriod);  // Set/Change Symbol
}

void SetTF_MN() {
  long ID=ChartFirst();
  ChartSetSymbolPeriod(ID, ChartSymbol(ID), PERIOD_MN1);  // Set/Change Symbol  
  ID=ID+2;  
  ChartSetSymbolPeriod(ID, ChartSymbol(ID), PERIOD_W1);  // Set/Change Symbol
  ID=ID+2;    
  ChartSetSymbolPeriod(ID, ChartSymbol(ID), PERIOD_D1);  // Set/Change Symbol
  ID=ID-3;
  ChartSetSymbolPeriod(ID, ChartSymbol(ID), PERIOD_H8);  // Set/Change Symbol
  ID=ID+2;
  ChartSetSymbolPeriod(ID, ChartSymbol(ID), PERIOD_H4);  // Set/Change Symbol
  ID=ID+2;
  ChartSetSymbolPeriod(ID, ChartSymbol(ID), PERIOD_H1);  // Set/Change Symbol
}

void SetTF_W1() {
  long ID=ChartFirst();
  ChartSetSymbolPeriod(ID, ChartSymbol(ID), PERIOD_W1);  // Set/Change Symbol
  ID=ID+2;    
  ChartSetSymbolPeriod(ID, ChartSymbol(ID), PERIOD_D1);  // Set/Change Symbol
  ID=ID+2;
  ChartSetSymbolPeriod(ID, ChartSymbol(ID), PERIOD_H8);  // Set/Change Symbol
  ID=ID-3;
  ChartSetSymbolPeriod(ID, ChartSymbol(ID), PERIOD_H4);  // Set/Change Symbol
  ID=ID+2;
  ChartSetSymbolPeriod(ID, ChartSymbol(ID), PERIOD_H1);  // Set/Change Symbol
  ID=ID+2;
  ChartSetSymbolPeriod(ID, ChartSymbol(ID), PERIOD_M15);  // Set/Change Symbol
}

void SetTF_D1() {
  long ID=ChartFirst();
  ChartSetSymbolPeriod(ID, ChartSymbol(ID), PERIOD_D1);  // Set/Change Symbol
  ID=ID+2;
  ChartSetSymbolPeriod(ID, ChartSymbol(ID), PERIOD_H8);  // Set/Change Symbol
  ID=ID+2;
  ChartSetSymbolPeriod(ID, ChartSymbol(ID), PERIOD_H4);  // Set/Change Symbol
  ID=ID-3;
  ChartSetSymbolPeriod(ID, ChartSymbol(ID), PERIOD_H1);  // Set/Change Symbol
  ID=ID+2;
  ChartSetSymbolPeriod(ID, ChartSymbol(ID), PERIOD_M15);  // Set/Change Symbol
  ID=ID+2;
  ChartSetSymbolPeriod(ID, ChartSymbol(ID), PERIOD_M5);  // Set/Change Symbol 
}

void SetTF_H12() {
  long ID=ChartFirst();
  ChartSetSymbolPeriod(ID, ChartSymbol(ID), PERIOD_H12);  // Set/Change Symbol
  ID=ID+2;
  ChartSetSymbolPeriod(ID, ChartSymbol(ID), PERIOD_H4);  // Set/Change Symbol
  ID=ID+2;
  ChartSetSymbolPeriod(ID, ChartSymbol(ID), PERIOD_H1);  // Set/Change Symbol
  ID=ID-3;
  ChartSetSymbolPeriod(ID, ChartSymbol(ID), PERIOD_M15);  // Set/Change Symbol
  ID=ID+2;;
  ChartSetSymbolPeriod(ID, ChartSymbol(ID), PERIOD_M5);  // Set/Change Symbol
  ID=ID+2;
  ChartSetSymbolPeriod(ID, ChartSymbol(ID), PERIOD_M1);  // Set/Change Symbol 
}

void GetTF_2Charts(ENUM_TIMEFRAMES &iPeriod) {
  if(iPeriod==PERIOD_H12) iPeriod=PERIOD_H4;
  else
    if(iPeriod==PERIOD_H8) iPeriod=PERIOD_H1;
  else
    if(iPeriod==PERIOD_H4) iPeriod=PERIOD_M30;
  else
    if(iPeriod==PERIOD_H1) iPeriod=PERIOD_M15;
  else
    if(iPeriod==PERIOD_M30) iPeriod=PERIOD_M5;
  else
    if(iPeriod==PERIOD_M15) iPeriod=PERIOD_M5;
  else
    if(iPeriod==PERIOD_M5) iPeriod=PERIOD_M1;
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
       if (sDesc == _Symbol || (sDesc == "WTI" && _Symbol == "USOUSD") || (sDesc == "NQ" && _Symbol == "NDX100") )
       { //color for selected
         SymbolIdx=iSymbol; //track current symbol idx
         ObjButtonSymbols[iSymbol].BackColor(ButtonColrSelected);
         ObjButtonSymbols[iSymbol].BorderColor(ButtonBorderColrSelected);
         ObjButtonSymbols[iSymbol].Color(TextColrSelected);
         ObjButtonSymbols[iSymbol].Font(sFontNameSelected);
         ObjButtonSymbols[iSymbol].FontSize(iFontSizeSelected);
         continue;
       }
       //color for not selected
       ObjButtonSymbols[iSymbol].BackColor(ButtonColr);
       ObjButtonSymbols[iSymbol].BorderColor(ButtonBorderColr);
       ObjButtonSymbols[iSymbol].Color(TextColr);
       ObjButtonSymbols[iSymbol].Font(sFontName);
       ObjButtonSymbols[iSymbol].FontSize(iFontSize);
    } //Chartfirst 
    
    else {  //if not first chart camoufalge them
       SymbolIdx=iSymbol; //track current symbol idx
       ObjButtonSymbols[iSymbol].BackColor(C'172,172,172');
       ObjButtonSymbols[iSymbol].BorderColor(C'172,172,172');
       ObjButtonSymbols[iSymbol].Color(C'172,172,172');
       ObjButtonSymbols[iSymbol].Font(sFontName);
       ObjButtonSymbols[iSymbol].FontSize(iFontSize);      
    }
  }//for
} // SetSymbolButtonSelections()

void HigherTF() { //up arrow
  bool bHighest=false;
  long ID;
  ID=ChartFirst();
  if (getNumOfCharts()>4) {
    if (ChartPeriod(ID)==PERIOD_MN1) {bHighest=true;}
    if (bHighest) return;  //exit function
    
    if (ChartPeriod(ID)==PERIOD_W1) {SetTF_MN();}
    if (ChartPeriod(ID)==PERIOD_D1) {SetTF_W1();}
    if (ChartPeriod(ID)==PERIOD_H12) {SetTF_D1();}
  }
  else {
     if (ChartPeriod(ID)==PERIOD_MN1) ID=-1;   //can't go up further
     while(ID!=-1) {
        period=ChartPeriod(ID);
        if(period<PERIOD_M1) period=PERIOD_M1;
        else
           if(period<PERIOD_M1) period=PERIOD_M1; 
        else
           if(period<PERIOD_M5) period=PERIOD_M5; 
        else
           if(period<PERIOD_M15) period=PERIOD_M15;
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
  
        ChartSetSymbolPeriod(ID,ChartSymbol(ID),period);
        ChartRedraw(ID);
        ID=ChartNext(ID);         
     } //while  
  }//else
}

void LowerTF() { //down arrow
  bool bLowest=false;
  long ID;
  ID=ChartFirst();
  if (getNumOfCharts()>4) {
    if (ChartPeriod(ID)==PERIOD_H12) {bLowest=true;}
    if (bLowest) return;  //exit function
    
    if (ChartPeriod(ID)==PERIOD_MN1) {SetTF_W1();}
    if (ChartPeriod(ID)==PERIOD_W1) {SetTF_D1();}
    if (ChartPeriod(ID)==PERIOD_D1) {SetTF_H12();}
  }
  else {
    bool bM1=false;
    long ID;
    ID=ChartFirst();
    //look through all the charts to find if one of them is M1, if true then we shall not shift TF down
    while(ID!=-1) {    
      if (ChartPeriod(ID)==PERIOD_M1) {bM1=true;}
      ID=ChartNext(ID);
    }//while
    
    if (bM1) return;  //exit function
    
    ID=ChartFirst();
    while(ID!=-1) {    
      period=ChartPeriod(ID);
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
         if(period>PERIOD_M15) period=PERIOD_M15;
      else
         if(period>PERIOD_M5) period=PERIOD_M5;
      else
         if(period>PERIOD_M1) period=PERIOD_M1;
    
      ChartSetSymbolPeriod(ID,ChartSymbol(ID),period);
      ChartRedraw(ID);
      ID=ChartNext(ID);
    }//while    
  }//else
}

void HigherTF_Current()
{
  long id=ChartID();
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
}

void LowerTF_Current()
{
  long id=ChartID();
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
}
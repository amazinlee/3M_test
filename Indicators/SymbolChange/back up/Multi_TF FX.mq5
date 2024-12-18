
#define PROPERTY_COPYRIGHT     "Copyright © by iDiamond @ Forex Factory"

#define PROPERTY_VERSION       "19.033"                       // Year.Day of Year 

#define PROPERTY_DESCRIPTION_1 " "
#define PROPERTY_DESCRIPTION_2 "Set the Symbol on a Chart. Used to change the Chart Symbol to another Symbol."
#define PROPERTY_DESCRIPTION_3 " "
#define PROPERTY_DESCRIPTION_4 "This indicator can be displayed on the Main Chart Window or any Indicator Subwindow."
#define PROPERTY_DESCRIPTION_5 "Symbols can be defined as specified input or can be taken from MarketWatch or the General List."
#define PROPERTY_DESCRIPTION_6 "Symbol Buttons can be set to any Window corner. Other options can be configured for button layout and appearance."


#include <Arrays\ArrayString.mqh>                             // CArrayString
#include <ChartObjects\ChartObjectsTxtControls.mqh>           // CChartObjectButton
#define DbugInfo(x)                                           // define as x for informational debugging 4
#define INPUTVARDELIMITER               "================================"

ENUM_TIMEFRAMES period;
sinput string Note_Symbols             = INPUTVARDELIMITER;   // Symbol List

//sinput string InputSymbols             = "AUDCAD AUDCHF AUDJPY AUDNZD AUDUSD CADCHF CADJPY CHFJPY EURAUD EURCAD EURCHF EURGBP EURJPY EURNZD EURUSD GBPAUD GBPCAD GBPCHF GBPJPY GBPNZD GBPUSD NZDCAD NZDCHF NZDJPY NZDUSD USDCAD USDCHF USDJPY"; // Input_Symbols - Separate each by <Space>
sinput string InputSymbols             = "GBPAUD GBPCAD GBPJPY GBPNZD GBPUSD EURGBP"; // Input_Symbols - Separate each by <Space>
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

int SymbolIdx;
const string sSymbolDelimiter          = " ";
string sUniquePrefix;
string sSymbolList;
CArrayString casSymbols;                // Symbols to use
CChartObjectButton ObjButtonSymbols[];  // Button Objects

int OnInit()
{
   bool bResult;
   int iResult, Indx, iNum;
   uint FontFlags = FW_NORMAL, uiWidth, uiHeight, uiMaxWidth = 0, uiMaxHeight = 0;
   long lChartWinHandl;
   string sExeName, sSymbol;
   
   sExeName = MQLInfoString(MQL_PROGRAM_NAME);
   ChartGetInteger(0, CHART_WINDOW_HANDLE, 0, lChartWinHandl);
   sUniquePrefix = StringFormat("%s %lld.%d.%d[%d,%d] ", sExeName, lChartWinHandl, iChartWindow, BaseCorner, MarginX, MarginY);

   long id=ChartFirst();
   sSymbol=ChartSymbol(id);
   if (StringSubstr(sSymbol,0,3)=="GBP") sSymbolList= "GBPAUD GBPCAD GBPJPY GBPNZD GBPUSD EURGBP";
   if (StringSubstr(sSymbol,0,3)=="EUR") sSymbolList= "EURAUD EURCAD EURJPY EURNZD EURUSD EURGBP";
   
   iResult = PrepareSymbols(&casSymbols);
   
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
   SetSymbolButtonSelections();
   
   return (0);
} // OnInit() 


int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[])
{
   return(rates_total);
}

void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
    int iButton, nObjects;

    switch (id)
      {
          case CHARTEVENT_KEYDOWN:
            //Print (lparam);
            if (lparam==40) PrevTF(); //down arrow
            if (lparam==38) NextTF(); //<up arrow
            if (lparam==39) {
               if (SymbolIdx<5) {SymbolIdx++; SetChart(casSymbols[SymbolIdx]);} //<right arrow
            }
            if (lparam==37) {
               if (SymbolIdx>0) {SymbolIdx--; SetChart(casSymbols[SymbolIdx]);} //<left arrow
            }
            if (lparam==71) { //G
               sSymbolList= "GBPAUD GBPCAD GBPJPY GBPNZD GBPUSD EURGBP";
               PrepareSymbols(&casSymbols);
               SetChart(casSymbols[0]);
            }
            if (lparam==69) { //E
               sSymbolList="EURAUD EURCAD EURJPY EURNZD EURUSD EURGBP";
               PrepareSymbols(&casSymbols);
               //SetChart(casSymbols[0]); //set all charts to the first symbol in the sSymbolList
               SetChart("EURGBP"); //set all charts to the first symbol in the sSymbolList
               SymbolIdx=1;
            }
            if (lparam==74) { //J
            }
            
            if (lparam==56) {ChangeTF(PERIOD_H8);} //8
            if (lparam==57) {ChangeTF(PERIOD_H12);} //9  0=48        
            if (lparam==68) {ChangeTF(PERIOD_D1);} //D
            if (lparam==87) {ChangeTF(PERIOD_W1);}
            if (lparam==77) {ChangeTF(PERIOD_MN1);}
                    
            if (sparam=="30") {SetChart(casSymbols[0]);}
            if (sparam=="46") {SetChart(casSymbols[1]);}
            if (sparam=="36") {SetChart(casSymbols[2]);}
            if (sparam=="49") {SetChart(casSymbols[3]);}
            if (sparam=="22") {SetChart(casSymbols[4]);}
            if (sparam=="18") {SetChart(casSymbols[5]);}
            break;
          case CHARTEVENT_MOUSE_MOVE:
          case CHARTEVENT_MOUSE_WHEEL:
          case CHARTEVENT_OBJECT_CREATE: 
               break;
          case CHARTEVENT_OBJECT_CHANGE:
               break;
          case CHARTEVENT_OBJECT_DELETE:
          case CHARTEVENT_CLICK:
               break;
          case CHARTEVENT_OBJECT_CLICK:  // lparam = X coordinate, dparam = Y coordinate, sparam = Name of the graphical object
               nObjects = ArraySize(ObjButtonSymbols);
               for (iButton = 0; iButton < nObjects; iButton++)
                 {
                    if (ObjButtonSymbols[iButton].Name() == sparam)  // If button clicked
                      {
                          SetChart(ObjButtonSymbols[iButton].Description());
                          SymbolIdx=iButton;
                          break;
                      }
                 }
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
      }
} // OnChartEvent()

void ManualChangeCharts() {
  long id = ChartFirst();
  if (ChartSymbol(id)!= ChartSymbol(ChartNext(id))) {
    SetChart(ChartSymbol(id)); //change all the charts to the symbol of the first chart
  }
}
//change all the charts to the specified symbol.
void SetChart(string sSymbol)
{ 
   long id=ChartFirst();
   
   while(id!=-1)
     {
      ChartSetSymbolPeriod(id, sSymbol, ChartPeriod(id));  // Set/Change Symbol
      id=ChartNext(id);
     }
}

void ChangeTF(ENUM_TIMEFRAMES iPeriod)
{
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
   bool bResult;
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

int PrepareSymbols(CArrayString* SymbolsArray)
{
   int iIndx, nSymbols;
   int nSubStrings;
   ushort uDelimiter;
   string sResult[];
   
   SymbolsArray.Clear();
   
   uDelimiter = StringGetCharacter(sSymbolDelimiter, 0); 
   nSubStrings = StringSplit(sSymbolList, uDelimiter, sResult);
   
   for (iIndx = 0; iIndx < nSubStrings; iIndx++)
   {
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


void SetSymbolButtonSelections()
{
    int nButtons, iSymbol;

    nButtons = ArraySize(ObjButtonSymbols);    
    for (iSymbol = 0; iSymbol < nButtons; iSymbol++) {
      if (ChartFirst()==ChartID()) {
         if (ObjButtonSymbols[iSymbol].Description() == _Symbol)
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
      }
      else {
         SymbolIdx=iSymbol; //track current symbol idx
         ObjButtonSymbols[iSymbol].BackColor(clrDarkGray);
         ObjButtonSymbols[iSymbol].BorderColor(clrDarkGray);
         ObjButtonSymbols[iSymbol].Color(clrDarkGray);
         ObjButtonSymbols[iSymbol].Font(sFontName);
         ObjButtonSymbols[iSymbol].FontSize(iFontSize);      
      } //Chartfirst
    
    }//for
} // SetSymbolButtonSelections()

void NextTF()
{
   long id=ChartFirst();
   if (ChartPeriod(id)==PERIOD_MN1) id=-1;   
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

void PrevTF()
{
   long id=ChartFirst();
   if (ChartPeriod(id)==PERIOD_H4) id=-1;   
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
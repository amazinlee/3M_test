
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
sinput string InputSymbols             = "GBP EUR JPY USD CAD AUD NZD CHF XAU"; // Input_Symbols - Separate each by <Space>
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

const string sSymbolDelimiter          = " ";
string sUniquePrefix;
int SymbolIdx;

CArrayString casCurr, casSymbols;                // Symbols to use
CChartObjectButton ObjButtonSymbols[];  // Button Objects

//
int OnInit()
{
   bool bResult;
   int iResult, Indx, iNum;
   uint FontFlags = FW_NORMAL, uiWidth, uiHeight, uiMaxWidth = 0, uiMaxHeight = 0;
   long lChartWinHandl;
   string sExeName;
   
   sExeName = MQLInfoString(MQL_PROGRAM_NAME);
   ChartGetInteger(0, CHART_WINDOW_HANDLE, 0, lChartWinHandl);
   sUniquePrefix = StringFormat("%s %lld.%d.%d[%d,%d] ", sExeName, lChartWinHandl, iChartWindow, BaseCorner, MarginX, MarginY);
   
   iResult = PrepareSymbols(&casCurr);
   
   bResult = TextSetFont(sFontName, iFontSize * -10, FontFlags);
   iNum = casCurr.Total();
   
   for (Indx = 0; Indx < iNum; Indx++)
   {   // Get Max Width and Max Height of all Unselected Symbols using this Font and Size
       TextGetSize(" " + casCurr.At(Indx) + " ", uiWidth, uiHeight);
       if (uiWidth > uiMaxWidth)
         uiMaxWidth = uiWidth;
       if (uiHeight > uiMaxHeight)
         uiMaxHeight = uiHeight;
   }
   bResult = TextSetFont(sFontNameSelected, iFontSizeSelected * -10, FontFlags);
   for (Indx = 0; Indx < iNum; Indx++)
   {   // Get Max Width and Max Height of all Selected Symbols using this Font and Size
       TextGetSize(" " + casCurr.At(Indx) + " ", uiWidth, uiHeight);
       if (uiWidth > uiMaxWidth)
         uiMaxWidth = uiWidth;
       if (uiHeight > uiMaxHeight)
         uiMaxHeight = uiHeight;
   }
   
   if (ObjectFind(0,"Label_index")<0) //create hidden label to store current
   { 
      ObjectCreate(0,"Label_index",OBJ_LABEL,0,0,0,0,0,0,0);
      ObjectSetInteger(0,"Label_index",OBJPROP_XDISTANCE,50);
      ObjectSetInteger(0,"Label_index",OBJPROP_YDISTANCE,20);
      ObjectSetInteger(0,"Label_index",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
      ObjectSetInteger(0,"Label_index",OBJPROP_COLOR,clrDarkGray);   
   }   
   iResult = CreateSymbolButtons(&casCurr, ObjButtonSymbols, (int)uiMaxWidth, (int)uiMaxHeight);
   SetSymbolButtonSelections();


    return (0);
} // OnInit() 

int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[])
{

    return(rates_total);
}

// id = Event ID from the ENUM_CHART_EVENT enumeration
//
void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
    int iCount, nTotal;

    switch (id)
      {
          case CHARTEVENT_KEYDOWN:
            if (lparam==40) {PrevTF();} //down arrow
            if (lparam==38) {NextTF();} //up arrow
            if (lparam==39) {
               if (SymbolIdx<7) {SymbolIdx++;} //<right arrow
               else SymbolIdx=0;
               
               SetChart(casCurr[SymbolIdx], SymbolIdx);
            }
            if (lparam==37) {
               if (SymbolIdx>0) {SymbolIdx--;} //<left arrow
               else SymbolIdx=7;
               SetChart(casCurr[SymbolIdx], SymbolIdx);
            }            
            if (lparam==79) {period=PERIOD_M1; ChangeTF();} //O
            if (lparam==76) {period=PERIOD_M5; ChangeTF();} //L
            if (lparam==77) {period=PERIOD_M15; ChangeTF();} //M
            if (lparam==48) {period=PERIOD_M30; ChangeTF();} //0 (zero)
            if (lparam==72) {period=PERIOD_H1; ChangeTF();} //H
            if (lparam==55) {period=PERIOD_H4; ChangeTF();} //7
            if (lparam==56) {period=PERIOD_H8; ChangeTF();} //8
            if (lparam==57) {period=PERIOD_H12; ChangeTF();} //9   
            if (lparam==68) {period=PERIOD_D1; ChangeTF();} //D
            if (lparam==75) {period=PERIOD_W1; ChangeTF();} //K
            
            if (lparam==71) SetChart("GBP",0);
            if (lparam==69) SetChart("EUR",1);
            if (lparam==74) SetChart("JPY",2);
            if (lparam==85) SetChart("USD",3);
            if (lparam==67) SetChart("CAD",4);
            if (lparam==65) SetChart("AUD",5);
            if (lparam==78) SetChart("NZD",6);
            if (lparam==70) SetChart("CHF",7);  //F
            if (lparam==88) SetChart("XAU",8);  //X
            
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
               nTotal = casCurr.Total();
               for (iCount = 0; iCount < nTotal; iCount++) {
                 if (ObjButtonSymbols[iCount].Name() == sparam)  { // If button clicked
                    SetChart(casCurr[iCount], iCount);
                    break;
                 }
               }
               break;
          case CHARTEVENT_OBJECT_DRAG:
          case CHARTEVENT_OBJECT_ENDEDIT:
               break;
          case CHARTEVENT_CHART_CHANGE:
               break;
          case CHARTEVENT_CUSTOM:
          case CHARTEVENT_CUSTOM_LAST:
               break;
      }
} // OnChartEvent()

void NextTF()
{
   long id=ChartFirst();
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

void SetChart(string sCurr, int index)
{ 
   long FirstID=ChartFirst();
   long ID;
   int iCount=0;
   
   ID=FirstID;
   LoadSymbols(&casSymbols, sCurr);

   while(ID!=-1)
     {
      ChartSetSymbolPeriod(ID, casSymbols[iCount], ChartPeriod(FirstID));  // Set/Change Symbol
      ObjectSetString(ID,"Label_index",OBJPROP_TEXT,IntegerToString(index));
      ObjectSetInteger(ID,"Label_index",OBJPROP_COLOR,clrDarkGray);   
      ID=ChartNext(ID);
      iCount++;
     }
}

void ChangeTF()
{
   long id=ChartFirst();

   while(id!=-1)
     {
      ChartSetSymbolPeriod(id, ChartSymbol(id), period);  // Set/Change Symbol
      id=ChartNext(id);
     }
}

void OnDeinit(const int reason)
{
    bool bResult;
    int nButtons, iButton;

    casCurr.Clear();
    casSymbols.Clear();
    
    nButtons = ArraySize(ObjButtonSymbols);    
    for (iButton = 0; iButton < nButtons; iButton++)
      {      
          bResult = ObjButtonSymbols[iButton].Delete();
      }
    ArrayFree(ObjButtonSymbols);       

    ChartRedraw();
} // OnDeinit()


int PrepareSymbols(CArrayString* SymbolsArray)
{
   int iIndx, nSymbols;
   
   SymbolsArray.Clear();

   int nSubStrings;
   ushort uDelimiter;
   string sResult[];
    
   uDelimiter = StringGetCharacter(sSymbolDelimiter, 0); 
   nSubStrings = StringSplit(InputSymbols, uDelimiter, sResult); 
   for (iIndx = 0; iIndx < nSubStrings; iIndx++)
   {
       SymbolsArray.Add(sResult[iIndx]);                               
   }
 
   return( nSymbols = SymbolsArray.Total() );
} // PrepareSymbols()

int LoadSymbols(CArrayString* SymbolsArray, string sSymbol)
{
   SymbolsArray.Clear();
   
   if (sSymbol=="GBP")
   {
      SymbolsArray.Add("GBPUSD");
      SymbolsArray.Add("EURGBP");
      SymbolsArray.Add("GBPNZD");
      SymbolsArray.Add("GBPAUD");
      SymbolsArray.Add("GBPCAD");
      SymbolsArray.Add("GBPJPY");
   } else
   if (sSymbol=="EUR")
   {
      SymbolsArray.Add("EURUSD");   
      SymbolsArray.Add("EURGBP");
      SymbolsArray.Add("EURNZD");
      SymbolsArray.Add("EURAUD");
      SymbolsArray.Add("EURCAD");
      SymbolsArray.Add("EURJPY");
   } else
   if (sSymbol=="JPY")
   {
      SymbolsArray.Add("USDJPY");
      SymbolsArray.Add("NZDJPY");
      SymbolsArray.Add("CADJPY");
      SymbolsArray.Add("AUDJPY");
      SymbolsArray.Add("GBPJPY");
      SymbolsArray.Add("EURJPY");
   } else   
   if (sSymbol=="AUD")
   {
      SymbolsArray.Add("AUDUSD");
      SymbolsArray.Add("AUDNZD");
      SymbolsArray.Add("AUDCAD");
      SymbolsArray.Add("EURAUD");
      SymbolsArray.Add("GBPAUD");
      SymbolsArray.Add("AUDJPY");
   } else
   if (sSymbol=="NZD")
   {
      SymbolsArray.Add("NZDUSD");
      SymbolsArray.Add("AUDNZD");
      SymbolsArray.Add("NZDCAD");
      SymbolsArray.Add("EURNZD");
      SymbolsArray.Add("GBPNZD");   
      SymbolsArray.Add("NZDJPY");
   } else
   if (sSymbol=="USD")
   {
      SymbolsArray.Add("USDCAD");
      SymbolsArray.Add("EURUSD");
      SymbolsArray.Add("NZDUSD");
      SymbolsArray.Add("AUDUSD");
      SymbolsArray.Add("GBPUSD");   
      SymbolsArray.Add("USDJPY");
   } else
   if (sSymbol=="CAD")
   {
      SymbolsArray.Add("CADJPY");
      SymbolsArray.Add("NZDCAD");
      SymbolsArray.Add("AUDCAD");
      SymbolsArray.Add("USDCAD");
      SymbolsArray.Add("EURCAD");
      SymbolsArray.Add("GBPCAD");    
   } else
   if (sSymbol=="CHF")
   {
      SymbolsArray.Add("CHFJPY");
      SymbolsArray.Add("NZDCHF");
      SymbolsArray.Add("AUDCHF");
      SymbolsArray.Add("USDCHF");
      SymbolsArray.Add("CADCHF");
      SymbolsArray.Add("GBPCHF");    
   } else
   if (sSymbol=="XAU")
   {
      SymbolsArray.Add("XAUUSD");
      SymbolsArray.Add("XAGUSD");
      SymbolsArray.Add("NQ100");
      SymbolsArray.Add("WTI");
      SymbolsArray.Add("BITCOIN");
      SymbolsArray.Add("ETHEREUM");    
   }       
 
   return(SymbolsArray.Total());
} // LoadSymbols()

//  iWidth, iHeight specify Width/Height of each Button
int CreateSymbolButtons(CArrayString* SymbolsArray, CChartObjectButton& ButtonSymbols[], int iWidth, int iHeight)
{
    bool bResult;
    int iRow, nRows, iCol, Xdistance, Ydistance;
    int nSymbols, iSymbol, iResult, ChartWin;
    string UniqueName;

    ChartSetInteger(0, CHART_FOREGROUND, bChartForeground);  // Price chart in the foreground

    nSymbols = casCurr.Total();
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

          bResult = ObjButtonSymbols[iSymbol].Description(casCurr[iSymbol]);
          bResult = ObjButtonSymbols[iSymbol].SetInteger(OBJPROP_BACK, bTransparent);       
          //bResult = ObjButtonSymbols[iSymbol].SetInteger(OBJPROP_HIDDEN, true); // Prohibit showing via terminal menu "Charts" - "Objects" - "List of objects". 
          bResult = ObjButtonSymbols[iSymbol].State(false);                       // button state (Pressed/Depressed) 
          //bResult = ObjButtonSymbols[iSymbol].Tooltip(casCurr[iSymbol]);

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
   string curr;
   nButtons = ArraySize(ObjButtonSymbols);    
   for (iSymbol = 0; iSymbol < nButtons; iSymbol++) {
      curr=ObjButtonSymbols[iSymbol].Description();
      SymbolIdx=StringToInteger(ObjectGetString(0,"Label_index",OBJPROP_TEXT)); //track current symbol idx
      if (ChartFirst()==ChartID()) {
         if ((curr == "GBP" && _Symbol=="GBPUSD") || (curr == "EUR" && _Symbol=="EURUSD") || (curr == "JPY" && _Symbol=="USDJPY") || (curr == "USD" && _Symbol=="USDCAD") ||
         (curr == "CAD" && _Symbol=="CADJPY") || (curr == "AUD" && _Symbol=="AUDUSD") || (curr == "NZD" && _Symbol=="NZDUSD") || (curr == "CHF" && _Symbol=="CHFJPY")) {
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
      else {   //not first chart so we hide the buttons
         ObjButtonSymbols[iSymbol].BackColor(clrDarkGray);
         ObjButtonSymbols[iSymbol].BorderColor(clrDarkGray);
         ObjButtonSymbols[iSymbol].Color(clrDarkGray);
         ObjButtonSymbols[iSymbol].Font(sFontName);
         ObjButtonSymbols[iSymbol].FontSize(iFontSize);      
      } //Chartfirst
   
   }//for
} // SetSymbolButtonSelections()


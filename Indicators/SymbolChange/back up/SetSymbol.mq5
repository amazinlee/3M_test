
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
//#define DbugInfo(x) x                                         // define as x for informational debugging 4


#define INPUTVARDELIMITER               "================================"


sinput string Note_Symbols             = INPUTVARDELIMITER;   // Symbol List
enum ENUM_SYMBOL_LIST
{ 
    Input_Symbols, 
    MarketWatch_Symbols,
    All_General_List_Symbols
};
sinput ENUM_SYMBOL_LIST SymbolList     = Input_Symbols;       // Which Symbol List
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


const string sSymbolDelimiter          = " ";

string sUniquePrefix;

CArrayString casSymbols;                // Symbols to use
CChartObjectButton ObjButtonSymbols[];  // Button Objects


//
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
    //DbugInfo( Print(__FILE__, " ", __FUNCTION__, "@", __LINE__, " sExeName=", sExeName, " lChartWinHandl=", lChartWinHandl, " sUniquePrefix=", sUniquePrefix); )
    //bResult = IndicatorSetString(INDICATOR_SHORTNAME, sExeName);
    //DbugInfo( Print(__FILE__, " ", __FUNCTION__, "@", __LINE__, " sShortName=", sShortName, " bResult=", bResult); )

    iResult = PrepareSymbols(&casSymbols);

    bResult = TextSetFont(sFontName, iFontSize * -10, FontFlags);
    iNum = casSymbols.Total();
    //DbugInfo(Print(__FILE__, " ", __FUNCTION__, "@", __LINE__, " TextSetFont(", sFontName, ", ", iFontSize*-10, ", ", FontFlags, ")=", bResult, " iNum=", iNum); )
    for (Indx = 0; Indx < iNum; Indx++)
      {   // Get Max Width and Max Height of all Unselected Symbols using this Font and Size
          TextGetSize(" " + casSymbols.At(Indx) + " ", uiWidth, uiHeight);
          if (uiWidth > uiMaxWidth)
            uiMaxWidth = uiWidth;
          if (uiHeight > uiMaxHeight)
            uiMaxHeight = uiHeight;
          //DbugInfo(Print(__FILE__, " ", __FUNCTION__, "@", __LINE__, " [ ", casSymbols.At(Indx), " ] uiWidth=", (int)uiWidth, " uiHeight=", (int)uiHeight); )
      }
    bResult = TextSetFont(sFontNameSelected, iFontSizeSelected * -10, FontFlags);
    for (Indx = 0; Indx < iNum; Indx++)
      {   // Get Max Width and Max Height of all Selected Symbols using this Font and Size
          TextGetSize(" " + casSymbols.At(Indx) + " ", uiWidth, uiHeight);
          if (uiWidth > uiMaxWidth)
            uiMaxWidth = uiWidth;
          if (uiHeight > uiMaxHeight)
            uiMaxHeight = uiHeight;
          //DbugInfo(Print(__FILE__, " ", __FUNCTION__, "@", __LINE__, " [ ", casSymbols.At(Indx), " ] uiWidth=", (int)uiWidth, " uiHeight=", (int)uiHeight); )
      }
    //DbugInfo(Print(__FILE__, " ", __FUNCTION__, "@", __LINE__, " uiMaxWidth=", (int)uiMaxWidth, " uiMaxHeight=", (int)uiMaxHeight); )

    iResult = CreateSymbolButtons(&casSymbols, ObjButtonSymbols, (int)uiMaxWidth, (int)uiMaxHeight);
    SetSymbolButtonSelections();
    
    return (0);
} // OnInit() 


//	
// 
int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[])
{
    return(rates_total);
}


//
// id = Event ID from the ENUM_CHART_EVENT enumeration
//
void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
    int iButton, nObjects;

    switch (id)
      {
          case CHARTEVENT_KEYDOWN:
            if (lparam==49) SetChart(casSymbols[0]); //Keystroke 1 to 8
            if (lparam==50) SetChart(casSymbols[1]);
            if (lparam==51) SetChart(casSymbols[2]);
            if (lparam==52) SetChart(casSymbols[3]);
            if (lparam==53) SetChart(casSymbols[4]);
            if (lparam==54) SetChart(casSymbols[5]);
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
         w        {
                    if (ObjButtonSymbols[iButton].Name() == sparam)  // If button clicked
                      {
                          //ChartSetSymbolPeriod(0, ObjButtonSymbols[iButton].Description(), _Period);  // Set/Change Symbol
                          SetChart(ObjButtonSymbols[iButton].Description());
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


void SetChart(string sSymbol)
{ 
   long id=ChartFirst();
   
   while(id!=-1)
     {
      ChartSetSymbolPeriod(id, sSymbol, ChartPeriod(id));  // Set/Change Symbol
      id=ChartNext(id);
     }
}


void OnDeinit(const int reason)
{
    bool bResult;
    int nButtons, iButton;


    casSymbols.Clear();
    
    nButtons = ArraySize(ObjButtonSymbols);    
    for (iButton = 0; iButton < nButtons; iButton++)
      {      
          bResult = ObjButtonSymbols[iButton].Delete();
      }
    ArrayFree(ObjButtonSymbols);       

    ChartRedraw();
} // OnDeinit()


//
//
int PrepareSymbols(CArrayString* SymbolsArray)
{
    int iIndx, nSymbols;
    
    
    SymbolsArray.Clear();

    if (SymbolList == Input_Symbols)
      {
          int nSubStrings;
          ushort uDelimiter;
          string sResult[];
          
          uDelimiter = StringGetCharacter(sSymbolDelimiter, 0); 
          nSubStrings = StringSplit(InputSymbols, uDelimiter, sResult); 
          for (iIndx = 0; iIndx < nSubStrings; iIndx++)
            {
                SymbolsArray.Add(sResult[iIndx]);                               
            }         
      }
      
    if ((SymbolList == All_General_List_Symbols) || (SymbolList == MarketWatch_Symbols))
      { 
          bool bSelected;
          string sName;
          
          if (SymbolList == All_General_List_Symbols)
            bSelected = false;
            else bSelected = true;
          nSymbols = SymbolsTotal(bSelected);
            
          for (iIndx = 0; iIndx < nSymbols; iIndx++)
            {
                sName = SymbolName(iIndx, bSelected);
                SymbolsArray.Add(sName);
            }
     }
     
    return( nSymbols = SymbolsArray.Total() );
} // PrepareSymbols()


//
//  iWidth, iHeight specify Width/Height of each Button
//
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


//
//
void SetSymbolButtonSelections()
{
    int nButtons, iSymbol;


    nButtons = ArraySize(ObjButtonSymbols);    
    for (iSymbol = 0; iSymbol < nButtons; iSymbol++)
      {
          if (ObjButtonSymbols[iSymbol].Description() == _Symbol)
            {
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
} // SetSymbolButtonSelections()


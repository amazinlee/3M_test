//+------------------------------------------------------------------+
//|                                                    Dashboard.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

//--- indents and gaps
#define INDENT_LEFT                         (11)      // indent from left (with allowance for border width)
#define INDENT_TOP                          (15)      // indent from top (with allowance for border width)
#define CONTROLS_GAP_X                      (20)       // gap by X coordinate
#define CONTROLS_GAP_Y                      (30)       // gap by X coordinate
//--- for buttons
#define LABEL_WIDTH                        (100)     // size by X coordinate
#define LABEL_HEIGHT                       (25)      // size by Y coordinate
#define LIST_WIDTH                          (200)     // size by X coordinate
#define LIST_HEIGHT                         (300)     // size by Y coordinate


bool CreateLabel_HTF_Alert(void) {
  int x1=INDENT_LEFT;        // x1            = 11  pixels
  int y1=INDENT_TOP;         // y1            = 11  pixels
  int x2=x1+LABEL_WIDTH;    // x2 = 11 + 100 = 111 pixels
  int y2=y1+LABEL_HEIGHT;   // y2 = 11 + 20  = 32  pixels
  //--- create
  if(!m_label1.Create(0,"Label_HTF_Alert",0,x1,y1,x2,y2))
    return(false);
  if(!m_label1.Text("HTF Alert"))
    return(false);
  if(!AppWindow.Add(m_label1))
    return(false);
  return(true);
}
bool CreateLabel_HTF_WatchList(void) {
  int x1=INDENT_LEFT;        // x1            = 11  pixels
  int y1=INDENT_TOP+CONTROLS_GAP_Y*2+LIST_HEIGHT;
  int x2=x1+LABEL_WIDTH;    // x2 = 11 + 100 = 111 pixels
  int y2=y1+LABEL_HEIGHT;   // y2 = 11 + 20  = 32  pixels
  //--- create
  if(!m_label4.Create(0,"Label_HTF_WatchList",0,x1,y1,x2,y2))
    return(false);
  if(!m_label4.Text("HTF WatchList"))
    return(false);
  if(!AppWindow.Add(m_label4))
    return(false);
  return(true);
}

bool CreateLabel_H1_Alert(void) {
  int x1=INDENT_LEFT+LIST_WIDTH+CONTROLS_GAP_X;        // x1            = 11  pixels
  int y1=INDENT_TOP;         // y1            = 11  pixels
  int x2=x1+LABEL_WIDTH;    // x2 = 11 + 100 = 111 pixels
  int y2=y1+LABEL_HEIGHT;   // y2 = 11 + 20  = 32  pixels
  //--- create
  if(!m_label2.Create(0,"Label_H1_Alert",0,x1,y1,x2,y2))
    return(false);
  if(!m_label2.Text("H1 Alert"))
    return(false);
  if(!AppWindow.Add(m_label2))
    return(false);
  return(true);
}

bool CreateLabel_H1_WatchList(void) {
  int x1=INDENT_LEFT+LIST_WIDTH+CONTROLS_GAP_X;        // x1            = 11  pixels
  int y1=INDENT_TOP+CONTROLS_GAP_Y*2+LIST_HEIGHT;
  int x2=x1+LABEL_WIDTH;    // x2 = 11 + 100 = 111 pixels
  int y2=y1+LABEL_HEIGHT;   // y2 = 11 + 20  = 32  pixels
  //--- create
  if(!m_label5.Create(0,"Label_H1_WatchList",0,x1,y1,x2,y2))
    return(false);
  if(!m_label5.Text("H1 WatchList"))
    return(false);
  if(!AppWindow.Add(m_label5))
    return(false);
  return(true);
}
bool CreateLabel_LTF_Alert(void) {
  int x1=INDENT_LEFT+((LIST_WIDTH+CONTROLS_GAP_X)*2);        // x1            = 11  pixels
  int y1=INDENT_TOP;         // y1            = 11  pixels
  int x2=x1+LABEL_WIDTH;    // x2 = 11 + 100 = 111 pixels
  int y2=y1+LABEL_HEIGHT;   // y2 = 11 + 20  = 32  pixels
  //--- create
  if(!m_label3.Create(0,"Label_LTF_Alert",0,x1,y1,x2,y2))
    return(false);
  if(!m_label3.Text("LTF Alert"))
    return(false);
  if(!AppWindow.Add(m_label3))
    return(false);
  return(true);
}

bool CreateLabel_LTF_WatchList(void) {
  int x1=INDENT_LEFT+((LIST_WIDTH+CONTROLS_GAP_X)*2);        // x1            = 11  pixels
  int y1=INDENT_TOP+CONTROLS_GAP_Y*2+LIST_HEIGHT;
  int x2=x1+LABEL_WIDTH;    // x2 = 11 + 100 = 111 pixels
  int y2=y1+LABEL_HEIGHT;   // y2 = 11 + 20  = 32  pixels
  //--- create
  if(!m_label6.Create(0,"Label_LTF_WatchList",0,x1,y1,x2,y2))
    return(false);
  if(!m_label6.Text("LTF WatchList"))
    return(false);
  if(!AppWindow.Add(m_label6))
    return(false);
  return(true);
}

bool Create_HTF_Alert_List(void) {
  int x1=INDENT_LEFT;
  int y1=INDENT_TOP+LABEL_HEIGHT;
  int x2=x1+LIST_WIDTH;
  int y2=y1+LIST_HEIGHT;
  //--- create
  if(!m_list1.Create(0,"HTF_Alert_List",0,x1,y1,x2,y2))
    return(false);
  if(!AppWindow.Add(m_list1))
    return(false);
  return(true);
}

bool Create_HTF_WatchList(void) {
  int x1=INDENT_LEFT;
  int y1=INDENT_TOP+LABEL_HEIGHT+CONTROLS_GAP_Y*2+LIST_HEIGHT;
  int x2=x1+LIST_WIDTH;
  int y2=y1+(LIST_HEIGHT)-CONTROLS_GAP_Y;
  //--- create
  if(!m_list4.Create(0,"HTF_WatchList",0,x1,y1,x2,y2))
    return(false);
  if(!AppWindow.Add(m_list4))
    return(false);
  return(true);
}

bool Create_H1_Alert_List(void) {
  int x1=INDENT_LEFT+LIST_WIDTH+CONTROLS_GAP_X;
  int y1=INDENT_TOP+LABEL_HEIGHT;
  int x2=x1+LIST_WIDTH;
  int y2=y1+LIST_HEIGHT;
  //--- create
  if(!m_list2.Create(0,"H1_Alert_List",0,x1,y1,x2,y2))
    return(false);
  if(!AppWindow.Add(m_list2))
    return(false);
  return(true);
}

bool Create_H1_WatchList(void) {
  int x1=INDENT_LEFT+LIST_WIDTH+CONTROLS_GAP_X;
  int y1=INDENT_TOP+LABEL_HEIGHT+CONTROLS_GAP_Y*2+LIST_HEIGHT;
  int x2=x1+LIST_WIDTH;
  int y2=y1+(LIST_HEIGHT)-CONTROLS_GAP_Y;
  //--- create
  if(!m_list5.Create(0,"H1_WatchList",0,x1,y1,x2,y2))
    return(false);
  if(!AppWindow.Add(m_list5))
    return(false);
  return(true);
}

bool Create_LTF_Alert_List(void) {
  int x1=INDENT_LEFT+((LIST_WIDTH+CONTROLS_GAP_X)*2);
  int y1=INDENT_TOP+LABEL_HEIGHT;
  int x2=x1+LIST_WIDTH;
  int y2=y1+LIST_HEIGHT;
  //--- create
  if(!m_list3.Create(0,"LTF_Alert_List",0,x1,y1,x2,y2))
    return(false);
  if(!AppWindow.Add(m_list3))
    return(false);
  return(true);
}

bool Create_LTF_WatchList(void) {
  int x1=INDENT_LEFT+((LIST_WIDTH+CONTROLS_GAP_X)*2);
  int y1=INDENT_TOP+LABEL_HEIGHT+CONTROLS_GAP_Y*2+LIST_HEIGHT;
  int x2=x1+LIST_WIDTH;
  int y2=y1+(LIST_HEIGHT)-CONTROLS_GAP_Y;
  //--- create
  if(!m_list6.Create(0,"LTF_WatchList",0,x1,y1,x2,y2))
    return(false);
  if(!AppWindow.Add(m_list6))
    return(false);
  return(true);
}

bool IsNewBar1(const string symbol, const ENUM_TIMEFRAMES period)
{
  bool isNewBar = false;
  static datetime priorBarOpenTime = NULL;
  // New Bar event handler -> per https://www.mql5.com/en/articles/159
  // SERIES_LASTBAR_DATE == Open time of the last bar of the symbol-period
  const datetime currentBarOpenTime = (datetime) SeriesInfoInteger(symbol,period,SERIES_LASTBAR_DATE);
  if( priorBarOpenTime != currentBarOpenTime )
  {
    // Don't want new bar just because EA started
    //if ( priorBarOpenTime == NULL ) { isNewBar = false; }            
    isNewBar = true;
    
    // Regardless of new bar, update the held bar time
    priorBarOpenTime = currentBarOpenTime;
  }
  return isNewBar;
}

bool IsNewBar2(const string symbol, const ENUM_TIMEFRAMES period)
{
  bool isNewBar = false;
  static datetime priorBarOpenTime2 = NULL;
  // New Bar event handler -> per https://www.mql5.com/en/articles/159
  // SERIES_LASTBAR_DATE == Open time of the last bar of the symbol-period
  const datetime currentBarOpenTime2 = (datetime) SeriesInfoInteger(symbol,period,SERIES_LASTBAR_DATE);
  if( priorBarOpenTime2 != currentBarOpenTime2 )
  {
    // Don't want new bar just because EA started
    //if ( priorBarOpenTime2 == NULL ) { isNewBar = false; }            
    isNewBar = true;
    // isNewBar = ( priorBarOpenTime2 == NULL )?false:true;  // priorBarOpenTime2 is only NULL once
//Print("newbar2 is true " ,priorBarOpenTime2, " ", currentBarOpenTime2);
    // Regardless of new bar, update the held bar time
    priorBarOpenTime2 = currentBarOpenTime2;
  }
  return isNewBar;
}

bool IsNewBar3(const string symbol, const ENUM_TIMEFRAMES period)
{
  bool isNewBar = false;
  static datetime priorBarOpenTime3 = NULL;
  // New Bar event handler -> per https://www.mql5.com/en/articles/159
  // SERIES_LASTBAR_DATE == Open time of the last bar of the symbol-period
  const datetime currentBarOpenTime3 = (datetime) SeriesInfoInteger(symbol,period,SERIES_LASTBAR_DATE);
  if( priorBarOpenTime3 != currentBarOpenTime3 )
  {
    // Don't want new bar just because EA started
    //if ( priorBarOpenTime3 == NULL ) { isNewBar = false; }            
    isNewBar = true;
    // isNewBar = ( priorBarOpenTime3 == NULL )?false:true;  // priorBarOpenTime3 is only NULL once
    // Regardless of new bar, update the held bar time
    priorBarOpenTime3 = currentBarOpenTime3;
  }
  return isNewBar;
}
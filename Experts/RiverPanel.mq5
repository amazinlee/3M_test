#property description "Control Panels and Dialogs. Demonstration class CButton"
#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <Controls\ListView.mqh>
#include <Controls\Label.mqh>
#include <Common.mqh>
#include <All Slope v1.5.mqh>
#include <River.mqh>
#include "Dashboard.mqh"
#include "BW Include.mqh"
#include "NearMA MA Slope Include.mqh"
#include <3M.mqh>
#include "Trend.mqh"

bool debug=false;

//---
CAppDialog           AppWindow;
CLabel               m_label1;
CLabel               m_label2;
CLabel               m_label3;
CLabel               m_label4;
CLabel               m_label5;
CLabel               m_label6;
CListView            m_list1;
CListView            m_list2;
CListView            m_list3;
CListView            m_list4;
CListView            m_list5;
CListView            m_list6;

datetime lastbar[2]={0,0};
static int Total_Pairs=30;

/*
string CurrPair[6] = { "GBPAUD", "GBPCAD", "GBPCHF", "GBPJPY", "GBPNZD", "GBPUSD" };
*/

string CurrPair[30] = { "XAUUSD", "SPX500", "WTI", 
 "GBPAUD", "GBPCAD", "GBPCHF", "GBPJPY", "GBPNZD", "GBPUSD",
 "EURGBP", "EURAUD", "EURCAD", "EURJPY", "EURNZD", "EURUSD",
 "AUDCAD", "AUDCHF", "AUDJPY", "AUDNZD", "AUDUSD", "NZDJPY",
 "NZDUSD", "NZDCAD", "NZDCHF", "CADCHF", "CADJPY", "CHFJPY",
 "USDCAD", "USDCHF", "USDJPY" };
 // 3,6,6,6,6,3  

int OnInit() {
   if(!AppWindow.Create(0,"River Alerts",0,40,40,1200,1100))
      return(INIT_FAILED);
//--- create dependent controls
   if(!CreateLabel_HTF_Alert()) return(false);
   if(!CreateLabel_H1_Alert()) return(false);
   if(!CreateLabel_LTF_Alert()) return(false);
   if(!CreateLabel_HTF_WatchList()) return(false);
   if(!CreateLabel_H1_WatchList()) return(false);
   if(!CreateLabel_LTF_WatchList()) return(false);   
   if(!Create_HTF_Alert_List()) return(false);
   if(!Create_H1_Alert_List()) return(false);
   if(!Create_LTF_Alert_List()) return(false);
   if(!Create_HTF_WatchList()) return(false);
   if(!Create_H1_WatchList()) return(false);
   if(!Create_LTF_WatchList()) return(false);

//--- run application
   AppWindow.Run();
//--- succeed
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   Comment("");
//--- destroy dialog
   AppWindow.Destroy(reason);
  }
  
void OnTick() {

  ENUM_TIMEFRAMES TF1= PERIOD_M15;
  ENUM_TIMEFRAMES TF2= PERIOD_H1;
  ENUM_TIMEFRAMES TF3= PERIOD_H4;
 
  datetime time1,time2,time3;
  string msg, sSignal;
  bool bTF1=false, bTF2=false, bTF3=false;
  bool bTF1msg=true, bTF2msg=true, bTF3msg=true,  bTF1_TrendMsg=true, bTF2_TrendMsg=true, bTF3_TrendMsg=true;;
  
  //check for new bar for two timeframe
  bTF1=IsNewBar1(Symbol(),TF1);
  bTF2=IsNewBar2(Symbol(),TF2);
  bTF3=IsNewBar3(Symbol(),TF3);

  //only if one of the TF has a new bar then we do
  //only if one of the TF has a new bar then we do
  if (bTF1 || bTF2 || bTF3) {
    Sleep (5000); //need to wait for multi TF, if not there will be issues
    time1=iTime(_Symbol,0,1); //EA is loaed on the lowest TF, will display the prev bar closed.
    time2=iTime(_Symbol,TF2,1); //EA is loaed on the lowest TF, will display the prev bar closed.
    time3=iTime(_Symbol,TF3,1); //EA is loaed on the lowest TF, will display the prev bar closed.
    //First TF, first sig
    if (bTF1) {
      for (int i=0;i<Total_Pairs;i++) {    //check for each symbol
        sSignal=Signals(CurrPair[i], TF1);
        if (sSignal!="") {
          if (bTF1msg) { //check if first time create msg
            m_list3.ItemsClear(); //clear old list, clear M15 after H1 bar, so keep for few rounds
            m_list3.AddItem(TimeToString(time1));  //add time to first line
            m_list3.AddItem(sSignal);
            bTF1msg=false;
          }//bTF1msg
          else //subsequent inserts
            m_list3.AddItem(sSignal);
        }//Signals
        sSignal=TrendSignals(CurrPair[i], TF1);
        if (sSignal!="") {
          if (bTF1_TrendMsg) { //check if first time create msg
            m_list6.ItemsClear(); //clear old list, clear M15 after H1 bar, so keep for few rounds
            m_list6.AddItem(TimeToString(time1));  //add time to first line
            m_list6.AddItem(sSignal);
            bTF1_TrendMsg=false;
          }
          else //subsequent inserts
            {  
            m_list6.AddItem(sSignal);
            }  
        }//TrendSignals
      }//for loop multi pairs
    }//if bTF1
    //second TF
    if (bTF2) {
      for (int i=0;i<Total_Pairs;i++) {    //check for each symbol
        sSignal=Signals(CurrPair[i], TF2);
        if (sSignal!="") {
          if (bTF2msg) { //check if first time create msg
            m_list2.ItemsClear(); //clear old list
            m_list2.AddItem(TimeToString(time2));  //add time to first line
            m_list2.AddItem(sSignal);
            bTF2msg=false;
          }//bTF1msg
          else //subsequent inserts
            m_list2.AddItem(sSignal);
        }//Signals
        sSignal=TrendSignals(CurrPair[i], TF2);
        if (sSignal!="") {
          if (bTF1_TrendMsg) { //check if first time create msg
            m_list5.ItemsClear(); //clear old list, clear M15 after H1 bar, so keep for few rounds
            m_list5.AddItem(TimeToString(time1));  //add time to first line
            m_list5.AddItem(sSignal);
            bTF1_TrendMsg=false;
          }
          else //subsequent inserts
            m_list5.AddItem(sSignal);
        }//TrendSignals
      }//for loop multi pairs
    }//if bTF2
    if (bTF3) {
      for (int i=0;i<Total_Pairs;i++) {    //check for each symbol
        sSignal=Signals(CurrPair[i], TF3);
        if (sSignal!="") {
          if (bTF3msg) { //check if first time create msg
            m_list1.ItemsClear(); //clear old list
            m_list1.AddItem(TimeToString(time3));  //add time to first line
            m_list1.AddItem(sSignal);
            bTF3msg=false;
          }//bTF1msg
          else //subsequent inserts
            m_list1.AddItem(sSignal);
        }//Signals
        sSignal=TrendSignals(CurrPair[i], TF3);
        if (sSignal!="") {
          if (bTF3_TrendMsg) { //check if first time create msg
            m_list4.ItemsClear(); //clear old list, clear M15 after H1 bar, so keep for few rounds
            m_list4.AddItem(TimeToString(time1));  //add time to first line
            m_list4.AddItem(sSignal);
            bTF3_TrendMsg=false;
          }
          else //subsequent inserts
            m_list4.AddItem(sSignal);
        }//TrendSignals
      }//for loop multi pairs
    }//if bTF3
  }//new bar in any of the TFs 
}
//Signals Function
string Signals(string sCurr, ENUM_TIMEFRAMES TF) {
  string msg="", sSignal="";
  sSignal=BW(sCurr, TF);
  if (sSignal!="") {        //found a signal return either up or down, if empty skip
    sSignal= "BW " + sSignal;
    string sRes=StringFormat("%s %s %s\n",
                            sCurr,
                            StringSubstr(EnumToString(TF),7),
                            sSignal);
                            
    StringConcatenate(msg, msg, sRes);
  } //BW

  //First TF, second sig
  sSignal=NearMA(sCurr, TF);
  if (sSignal!="") {
    sSignal= "NearMA " + sSignal;   
    string sRes=StringFormat("%s %s %s\n",
                            sCurr,
                            StringSubstr(EnumToString(TF),7),
                            sSignal);
                            
    StringConcatenate(msg, msg, sRes);
  }

  sSignal=ThreeM(sCurr, TF);
  if (sSignal!="") {
    sSignal= "3M " + sSignal;
    string sRes=StringFormat("%s %s %s\n",
                            sCurr,
                            StringSubstr(EnumToString(TF),7),
                            sSignal);
    StringConcatenate(msg, msg, sRes);
    //Print("Panel 3M: ", sCurr," ", TF, " ", sSignal);
  }
    
  return msg;
}

string TrendSignals(string sCurr, ENUM_TIMEFRAMES TF) {
  string msg="", sSignal="";
  
  sSignal=fnTrend(sCurr, TF);
  if (sSignal!="") {
    sSignal= "Trend " + sSignal;
    string sRes=StringFormat("%s %s %s\n",
                            sCurr,
                            StringSubstr(EnumToString(TF),7),
                            sSignal);
    StringConcatenate(msg, msg, sRes);
    //Print("Panel Trend: ", sCurr," ", TF, " ", sSignal);
  }
  
  return msg;
}

//+------------------------------------------------------------------+
//| Expert chart event function                                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event ID  
                  const long& lparam,   // event parameter of the long type
                  const double& dparam, // event parameter of the double type
                  const string& sparam) // event parameter of the string type
  {
   AppWindow.ChartEvent(id,lparam,dparam,sparam);
  }



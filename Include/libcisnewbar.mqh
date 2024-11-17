//+------------------------------------------------------------------+
//|                                                Lib CisNewBar.mqh |
//|                                            Copyright 2010, Lizar |
//|                                               Lizar-2010@mail.ru |
//|                                              Revision 2010.09.27 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Class CisNewBar.                                                 |
//| Purpose: This class can be used to detect the fact               |
//| of a new bar on the chart                                        |
//+------------------------------------------------------------------+
class CisNewBar
  {
protected:
   datetime          m_lastbar_time;   // Open time of the last bar

   string            m_symbol;         // Symbol
   ENUM_TIMEFRAMES   m_period;         // Timeframe

   uint              m_retcode;        // Result
   int               m_new_bars;       // Number of new bars
   string            m_comment;        // Comment

public:
   void              CisNewBar();      // class constructor
   //--- methods for access the protected data:
   uint              GetRetCode() const      {return(m_retcode);     }  // Result
   datetime          GetLastBarTime() const  {return(m_lastbar_time);}  // Open time of the last bar
   int               GetNewBars() const      {return(m_new_bars);    }  // Number of new bars
   string            GetComment() const      {return(m_comment);     }  // Comment
   string            GetSymbol() const       {return(m_symbol);      }  // Symbol
   ENUM_TIMEFRAMES   GetPeriod() const       {return(m_period);      }  // Timeframe
   //--- initialization of protected data:
   void              SetLastBarTime(datetime lastbar_time){m_lastbar_time=lastbar_time;                            }
   void              SetSymbol(string symbol)             {m_symbol=(symbol==NULL || symbol=="")?Symbol():symbol;  }
   void              SetPeriod(ENUM_TIMEFRAMES period)    {m_period=(period==PERIOD_CURRENT)?Period():period;      }
   //--- methods used to detect the new bar:
   bool              isNewBar(datetime new_Time);    // First calling form
   int               isNewBar();                     // Second calling form
  };
//+------------------------------------------------------------------+
//| CisNewBar class constructor                                      |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CisNewBar::CisNewBar()
  {
   m_retcode=0;         // Result
   m_lastbar_time=0;    // Open time of the last bar
   m_new_bars=0;        // Number of new bars
   m_comment="";        // Comment
   m_symbol=Symbol();   // symbol, the current chart symbol is used by default
   m_period=Period();   // timeframe, the timeframe of the current chart is used by default
  }
//+------------------------------------------------------------------+
//| First calling form of the function                               |
//| INPUT:  newbar_time - open time of the (new?) bar                |
//| OUTPUT: true   - new bar(s) has appeared                         |
//|         false  - error or no new bars appeared                   |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CisNewBar::isNewBar(datetime newbar_time)
  {
//--- initialization of protected (internal) variables
//--- number of new bars
   m_new_bars=0;
//--- result: 0 - no erros
   m_retcode  = 0;
   m_comment  =__FUNCTION__+" The checking of the new bar completed";
//---

//--- Check the academic case if m_newbar_time<m_lastbar_time 
   if(m_lastbar_time>newbar_time)
     {
      //--- fill comment if the time of the new bar is lower than last bar time
      m_comment=__FUNCTION__+" Synchronization error: last bar time "+TimeToString(m_lastbar_time)+
                ", new bar time "+TimeToString(newbar_time);
      //--- result retcode: return -1 - synchronization error
      m_retcode=-1;
      return(false);
     }
//---

//--- first call
   if(m_lastbar_time==0)
     {
      //--- define the last bar time and return
      m_lastbar_time=newbar_time;
      m_comment=__FUNCTION__+" Initialization of lastbar_time="+TimeToString(m_lastbar_time);
      return(false);
     }
//---

//--- ñheck the new bar appearance: 
   if(m_lastbar_time<newbar_time)
     {
      //--- number of new bars
      m_new_bars=1;
      //--- save time of the last bar
      m_lastbar_time=newbar_time;
      return(true);
     }
//---

//--- if we here, the bar isn't new or error, return false
   return(false);
  }
//+------------------------------------------------------------------+
//| Second calling form of the function                              |
//| INPUT:  no.                                                      |
//| OUTPUT: m_new_bars - number of new bars                          |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
int CisNewBar::isNewBar()
  {
   datetime newbar_time;
   datetime lastbar_time=m_lastbar_time;

//--- set _LastError to 0.
   ResetLastError();
//--- request of the open time of the last bar:
   if(!SeriesInfoInteger(m_symbol,m_period,SERIES_LASTBAR_DATE,newbar_time))
     {
      //--- fill the comment in the case of error
      //--- set _LastError
      m_retcode=GetLastError();
      m_comment=__FUNCTION__+" Error in request of the time of last bar: "+IntegerToString(m_retcode);
      return(0);
     }
//---

//--- let's call the first calling form of the function:
   if(!isNewBar(newbar_time)) return(0);

//--- how many new bars?
   m_new_bars=Bars(m_symbol,m_period,lastbar_time,newbar_time)-1;

//--- if we here, the new bar(s) has appeared, let's return the number of new bars:
   return(m_new_bars);
  }
//+------------------------------------------------------------------+

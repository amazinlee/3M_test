class CValues {
private:  
  int iBack, iBackTotal, iBack5;
  int iBacka, iBackb, iBack3, iBack6;
  
public:
  double dist5_13, dist8_13, dist8_21, dist5_21, dist13_21, dist8_42, dist21_42, dist21_63, dist42_63, dist63_126;
  double distLast8_13, distLast5_13, distLast8_21, distLast5_21, distLast13_21, distLast8_42, distLast21_42, distLast21_63;
  double slope5, slope5one, slope8, slope8one, slope13, slope13one, slope21, slope42, slope63, slope84, slope126, slope252;
  double a_slope5, a_slope8, a_slope13, a_slope21;
  double b_slope5, b_slope8, b_slope13, b_slope21;
  double roc5, roc8, roc13, roc21;
  double div5_13, div8_13, div5_21, div8_42, div21_42, div5_21s, div8_21, div8_21s, div8_42s, div21_63, div21_42s;
  double bigRoc5, bigRoc8, bigRoc13, bigRoc21;
  double prcCtrl5, prcCtrl8, prcCtrl21, atr;
  double Steep, SteepMin;

  int pos, SteepMode;
  string sValues;
  
  void CValues::div(int iPos);
  void CValues::CriteriaLimit(int iPos);
  
  CValues() { //constructor 
    iBack=4; iBack5=5;
    iBacka=2; iBackb=4;
    iBack3=3; iBack6=6;
    Steep=0.15; SteepMin=0.08;
  }
  
  void SetPos(int i) {
    pos=i;
    atr=ATR[pos]; //get atr

    prcCtrl5 = MathAbs(rates[pos].close-EMA5[pos])/atr; //close price to ema 5
    prcCtrl8 = MathAbs(rates[pos].close-SMA8[pos])/atr; //close price to sma 8
    prcCtrl21 = MathAbs(rates[pos].close-SMA21[pos])/atr; //close price to sma 21
    
    dist8_13 = MathAbs(SMA8[pos]-EMA13[pos])/atr;
    dist5_13 = MathAbs(EMA5[pos]-EMA13[pos])/atr;
    dist5_21 = MathAbs(EMA5[pos]-SMA21[pos])/atr;
    dist8_21 = MathAbs(SMA8[pos]-SMA21[pos])/atr;
    dist13_21 = MathAbs(EMA13[pos]-SMA21[pos])/atr;
    dist8_42 = MathAbs(SMA8[pos]-SMA42[pos])/atr;
    dist21_42 = MathAbs(SMA21[pos]-SMA42[pos])/atr;
    dist21_63 = MathAbs(SMA21[pos]-SMA63[pos])/atr;
    dist42_63 = MathAbs(SMA42[pos]-SMA63[pos])/atr;    
    dist63_126 = MathAbs(SMA63[pos]-SMA126[pos])/atr;
    
    distLast5_13 = (EMA5[pos]-EMA13[pos])/atr;
    distLast8_13 =(SMA8[pos]-EMA13[pos])/atr;
    distLast8_21 =(SMA8[pos]-SMA21[pos])/atr;
    distLast5_21 =(EMA5[pos]-SMA21[pos])/atr;
    distLast13_21 =(EMA13[pos]-SMA21[pos])/atr;
    distLast8_42 =(SMA8[pos]-SMA42[pos])/atr; 
    distLast21_42 =(SMA21[pos]-SMA42[pos])/atr;    
    distLast21_63 =(SMA21[pos]-SMA63[pos])/atr;
        
    slope5 = (EMA5[pos]-EMA5[pos-iBack3])/iBack3/atr;
    slope8 = (SMA8[pos]-SMA8[pos-iBack3])/iBack3/atr;
    slope13 = (EMA13[pos]-EMA13[pos-iBack3])/iBack3/atr;
    slope21 = (SMA21[pos]-SMA21[pos-iBack3])/iBack3/atr;
    slope42 = (SMA42[pos]-SMA42[pos-iBack5])/iBack5/atr;
    slope63 = (SMA63[pos]-SMA63[pos-iBack5])/iBack5/atr;
    slope126 = (SMA126[pos]-SMA126[pos-iBack5])/iBack5/atr;
    slope252 = (SMA252[pos]-SMA252[pos-iBack5])/iBack5/atr;
    
    slope5one = (EMA5[pos]-EMA5[pos-1])/atr;
    slope8one = (SMA8[pos]-SMA8[pos-1])/atr;
    slope13one = (EMA13[pos]-EMA13[pos-1])/atr;
    a_slope5 = (EMA5[pos]-EMA5[pos-iBacka])/iBacka/atr;
    a_slope8 = (SMA8[pos]-SMA8[pos-iBacka])/iBacka/atr;
    a_slope13 = (EMA13[pos]-EMA13[pos-iBacka])/iBacka/atr;
    a_slope21 = (SMA21[pos]-SMA21[pos-iBacka])/iBacka/atr;
    
    b_slope5 = (EMA5[pos]-EMA5[pos-iBackb])/iBackb/atr;
    b_slope8 = (SMA8[pos]-SMA8[pos-iBackb])/iBackb/atr;
    b_slope13 = (EMA13[pos]-EMA13[pos-iBackb])/iBackb/atr;
    b_slope21 = (SMA21[pos]-SMA21[pos-iBackb])/iBackb/atr;
    
    roc5=a_slope5/b_slope5;
    roc8=a_slope8/b_slope8;
    roc13=a_slope13/b_slope13;
    roc21=a_slope21/b_slope21;    
    
    if (slope8>0 && a_slope5<0 && b_slope5<0) roc5=b_slope5; //for up if both a_slope5 and b_slope5 or down, then make roc5 neg
    if (slope8<0 && a_slope5>0 && b_slope5>0) roc5=b_slope5; //for up if both a_slope5 and b_slope5 or down, then make roc5 neg
    if (roc5<0 && slope8>0 && a_slope5>0) roc5=10; //if prev slope is neg and curr slope is positiv, and trend is up
    if (roc5<0 && slope8<0 && a_slope5<0) roc5=10; //if prev slope is neg and curr slope is positiv, and trend is up
    if (roc8<0 && slope13>0 && a_slope8>0) roc8=10; //if prev slope is neg and curr slope is positive
    if (roc8<0 && slope13<0 && a_slope8<0) roc8=10; //if prev slope is neg and curr slope is positive
    if (roc13<0 && slope13>0 && a_slope13>0) roc13=10; //if prev slope is neg and curr slope is positive
    if (roc13<0 && slope13<0 && a_slope13<0) roc13=10; //if prev slope is neg and curr slope is positive

    //function for diverge
    div(pos);
    
    //gentle mode
    if ((slope13<Steep && slope8<Steep) || (slope13>-Steep && slope8>-Steep)) SteepMode=0;
    //Steep mode
    if ((slope13>Steep || slope8>Steep) || (slope13<-Steep || slope8<-Steep))
      if ((slope13>SteepMin && slope8>SteepMin) || (slope13<-SteepMin && slope8<-SteepMin)) SteepMode=1;
  } //GetPos 
};


//Filter for slope of 8 and 13 for lookback 1 give score to acceleration
void CValues::div(int iPos) {
  double distCurr8_21, distCurr8_13, distCurr5_21, distCurr5_13, distCurr21_63, distCurr8_42;
  double big21_42=0, small21_42=10, big5_21=0, small5_21=10, big8_21=0, small8_21=10, big8_21s=0, small8_21s=10;
  double big21_63=0, small21_63=10, big8_42=0, small8_42=10, big8_42s=0, small8_42s=10;
  float Slope21s=-0.01, Slope21=0.01;
   //min dist for the first dist
  int iBack=2;
  //reset values for div
  div5_13=0; div8_13=0; div5_21=0; div21_42=0; div5_21s=0; div8_21=0; div8_21s=0; div8_42=0; div8_42s=0; div21_63=0; div21_42s=0;
  //20 bars ago
  for (int i=20; i>=0; i--) {
    double distCurr21_42 = (SMA21[pos-i]-SMA42[pos-i])/atr;
    double distCurr8_21 = (SMA8[pos-i]-SMA21[pos-i])/atr;
    double distCurr8_42 = (SMA8[pos-i]-SMA42[pos-i])/atr;    
    
    double FirstMinDist=0.2, FirstMinDist21=0.6;
    //store values of first and last dist of 8 and 13
    //FirstMinDist is to prevent the first distance from getting too small
    //if last is positive, First need to be positive as well, the position of First is dynamic
    if (distLast21_42>0 && distCurr21_42>FirstMinDist) {  //long trades
      int iSmallIdx; //remember the index of the smallest and biggest
      if (distCurr21_42<small21_42) {small21_42=distCurr21_42; iSmallIdx=i;} //get smallest value
      if (i==0) div21_42=distCurr21_42-small21_42;
      //if (debug1 && debug2) Print("div21_42 ", i," Last ", RoundN(distLast21_42)," Current: " , RoundN(distCurr21_42)," div ", RoundN(div21_42));
    }
    if (distLast21_42<0 && distCurr21_42<-FirstMinDist) {  //short trades
      int iSmallIdx; //remember the index of the smallest and biggest
      if (MathAbs(distCurr21_42)<small21_42) {small21_42=MathAbs(distCurr21_42); iSmallIdx=i;} //get smallest value
      if (i==0) div21_42=MathAbs(distCurr21_42)-small21_42;
      //if (debug1 && debug2) Print("div21_42 ",i, " First: " , RoundN(distCurr21_42)," ",RoundN(div21_42));
    }
    //div8_42
    if (distLast8_42>0 && distCurr8_42>FirstMinDist) {  //long trades
      int iSmallIdx; //remember the index of the smallest and biggest
      if (distCurr8_42<small8_42) {small8_42=distCurr8_42; iSmallIdx=i;} //get smallest value
      if (i==0) div8_42=distCurr8_42-small8_42;
      //if (debug1 && debug2) Print("div8_42 ", i," Last ", RoundN(distLast8_42)," Current: " , RoundN(distCurr8_42)," div ", RoundN(div8_42));
    }
    if (distLast8_42<0 && distCurr8_42<-FirstMinDist) {  //short trades
      int iSmallIdx; //remember the index of the smallest and biggest
      if (MathAbs(distCurr8_42)<small8_42) {small8_42=MathAbs(distCurr8_42); iSmallIdx=i;} //get smallest value
      if (i==0) div8_42=MathAbs(distCurr8_42)-small8_42; //compare current to smallest to get diverge
      //if (debug1 && debug2) Print("div8_42 ",i, " Div: ", RoundN(div8_42)," Curr ", RoundN(MathAbs(distCurr8_42))," small ",RoundN(small8_42));
    }  
    //div8_21
    if (distLast8_21>0 && distCurr8_21>FirstMinDist && slope21>Slope21s) {  //long trades
      int iSmallIdx; //remember the index of the smallest and biggest
      if (distCurr8_21<small8_21) {small8_21=distCurr8_21; iSmallIdx=i;} //get smallest value
      if (i==0) div8_21=distCurr8_21-small8_21;
      //if (debug1 && debug2) Print("div ",i, " Last8_21 ", RoundN(distLast8_21)," Curr: " , RoundN(distCurr8_21)," small ", RoundN(small8_21));
    }
    if (distLast8_21<0 && distCurr8_21<-FirstMinDist && slope21<-Slope21s) {  //short trades
      int iSmallIdx; //remember the index of the smallest and biggest
      if (MathAbs(distCurr8_21)<small8_21) {small8_21=MathAbs(distCurr8_21); iSmallIdx=i;} //get smallest value
      if (i==0) div8_21=MathAbs(distCurr8_21)-small8_21;
      //if (debug1 && debug2) Print("div 8_21 ",i, " Last: ", RoundN(div8_21)," Curr: " , RoundN(distCurr8_21)," small ", RoundN(small8_21) );
    }
  }
  for (int i=10; i>=0; i--) {    
    double distCurr5_21 = (EMA5[pos-i]-SMA21[pos-i])/atr;
    double distCurr8_13 = (SMA8[pos-i]-EMA13[pos-i])/atr;
    double distCurr21_63 = (SMA21[pos-i]-SMA63[pos-i])/atr;
    double FirstMinDist=0.2, FirstMinDist21=0.6;
    
    //store values of first and last dist of 8 and 13
    //FirstMinDist is to prevent the first distance from getting too small
    //if last is positive, First need to be positive as well, the position of First is dynamic
    if (distLast8_13>0 && distCurr8_13>FirstMinDist) {  //long trades
      double div = (distLast8_13-distCurr8_13);
      if (div>div8_13) div8_13=div; //replace with bigger value 
      //if (debug1 && debug2) Print("div8_13 ", i," Last ", RoundN(distLast8_13)," Current: " , RoundN(distCurr8_13)," div ", RoundN(div8_13));
    }
    if (distLast8_13<0 && distCurr8_13<-FirstMinDist) {  //short trades
      double div = MathAbs(distLast8_13)-MathAbs(distCurr8_13);
      if (div>div8_13) div8_13=div; //replace with bigger value  
      //if (debug1 && debug2) Print("div8_13 ",i, " First: " , RoundN(distCurr8_13)," ",RoundN(div8_13));
    }
    //div21_63
    if (distLast21_63>0 && distCurr21_63>FirstMinDist21 && slope21>Slope21) {  //long trades
      int iSmallIdx, iBigIdx; //remember the index of the smallest and biggest
      if (distCurr21_63>big21_63) {big21_63=distCurr21_63; iBigIdx=i;}
      if (distCurr21_63<small21_63) {small21_63=distCurr21_63; iSmallIdx=i;}
      //the small index should be bigger(on the left) of the biggest
      if ((i==0) && (iSmallIdx>iBigIdx)) div21_63=big21_63-small21_63;
      //if (debug1 && debug2) Print("div ",i, " Last21_63 ", RoundN(distLast21_63)," Curr: " , RoundN(distCurr21_63)," small ", RoundN(small21_63));
    }
    if (distLast21_63<0 && distCurr21_63<-FirstMinDist21 && slope21<-Slope21) {  //short trades
      int iSmallIdx, iBigIdx; //remember the index of the smallest and biggest
      if (MathAbs(distCurr21_63)>big21_63) {big21_63=MathAbs(distCurr21_63); iBigIdx=i;}
      if (MathAbs(distCurr21_63)<small21_63) {small21_63=MathAbs(distCurr21_63); iSmallIdx=i;}
      if ((i==0) && (iSmallIdx>iBigIdx)) div21_63=big21_63-small21_63;
      //if (debug1 && debug2) Print("div 21_63 ",i, " Last: ", RoundN(distLast21_63)," Curr: " , RoundN(distCurr21_63)," small ", RoundN(small21_63));
    }    
  }//for
  
  //for short distance
  for (int i=4; i>=0; i--) {
    double distCurr5_13 = (EMA5[pos-i]-EMA13[pos-i])/atr;  
    double distCurr21_42 = (SMA21[pos-i]-SMA42[pos-i])/atr;
    double distCurr5_21 = (EMA5[pos-i]-SMA21[pos-i])/atr;
    double distCurr8_21 = (SMA8[pos-i]-SMA21[pos-i])/atr;
    double distCurr8_42 = (SMA8[pos-i]-SMA42[pos-i])/atr;
    //FirstMinDist is to prevent the first distance from getting too small
    double FirstMinDist42=0.6; double FirstMinDist21=0.2;
    
    if (distLast5_13>0 && distCurr5_13>FirstMinDist21) {  //long trades
      double div = (distLast5_13-distCurr5_13);
      if (div>div5_13) div5_13=div; //replace with bigger value 
      //if (debug1 && debug2) Print("div5_13 ", i," Last ", RoundN(distLast5_13)," Current: " , RoundN(distCurr5_13)," div ", RoundN(div5_13));
    }
    if (distLast5_13<0 && distCurr5_13<-FirstMinDist21) {  //short trades
      double div = MathAbs(distLast5_13)-MathAbs(distCurr5_13);
      if (div>div5_13) div5_13=div; //replace with bigger value  
      //if (debug1 && debug2) Print("div5_13 ",i, " First: " , RoundN(distCurr5_13)," ",RoundN(div5_13));
    }
    
    if (distLast5_21>0 && distCurr5_21>FirstMinDist21) {  //long trades
      double div = (distLast5_21-distCurr5_21);      
      if (div>div5_21s) div5_21s=div;
    }
    if (distLast5_21<0 && distCurr5_21<-FirstMinDist21) {  //short trades
      double div = (MathAbs(distLast5_21)-MathAbs(distCurr5_21));
      if (div>div5_21s) div5_21s=div;
    }
        
    if (distLast21_42>0 && distCurr21_42>FirstMinDist42 && slope21>Slope21 && slope42>Slope21s) {  //long trades
      double div = (distLast21_42-distCurr21_42);
      if (div>div21_42s) div21_42s=div;
      //if (debug1 && debug2) Print("divShort ", i, " First21_42: ", RoundN(distCurr21_42)," Last21_42 ",RoundN(distLast21_42)," div ", RoundN(div21_42));
    }
    if (distLast21_42<0 && distCurr21_42<-FirstMinDist42 && slope21<-Slope21 && slope42<-Slope21s) {  //short trades
      double div = (MathAbs(distLast21_42)-MathAbs(distCurr21_42));
      if (div>div21_42s) div21_42s=div;
      //if (debug1 && debug2) Print("divShort ",i, " First21_42: " , RoundN(distCurr21_42)," Last21_42 ",RoundN(distLast21_42)," div ", RoundN(div21_42));
    } //8_21
    if (distLast8_21>0 && distCurr8_21>FirstMinDist21 && slope21>Slope21s) {  //long trades
      int iSmallIdx, iBigIdx; //remember the index of the smallest and biggest
      if (distCurr8_21>big8_21s) {big8_21s=distCurr8_21; iBigIdx=i;}
      if (distCurr8_21<small8_21s) {small8_21s=distCurr8_21; iSmallIdx=i;}
      //the small index should be bigger(on the left) of the biggest
      if ((i==0) && (iSmallIdx>iBigIdx)) div8_21s=big8_21s-small8_21s;
      //if (debug1 && debug2) Print("div ",i, " Last8_21 ", RoundN(distLast8_21)," Curr: " , RoundN(distCurr8_21)," div ", RoundN(div8_21s));
    }
    if (distLast8_21<0 && distCurr8_21<-FirstMinDist21 && slope21<-Slope21s) {  //short trades
      int iSmallIdx, iBigIdx; //remember the index of the smallest and biggest
      if (MathAbs(distCurr8_21)>big8_21s) {big8_21s=MathAbs(distCurr8_21); iBigIdx=i;}
      if (MathAbs(distCurr8_21)<small8_21s) {small8_21s=MathAbs(distCurr8_21); iSmallIdx=i;}
      if ((i==0) && (iSmallIdx>iBigIdx)) div8_21s=big8_21s-small8_21s;
      //if (debug1 && debug2) Print("div 8_21s ",i," Last: ",RoundN(distLast8_21)," Curr: ",RoundN(distCurr8_21)," smallest ", RoundN(small8_21s));
    } //8_42
    if (distLast8_42>0 && distCurr8_42>FirstMinDist21 && slope21>Slope21s) {  //long trades
      int iSmallIdx, iBigIdx; //remember the index of the smallest and biggest
      if (distCurr8_42>big8_42s) {big8_42s=distCurr8_42; iBigIdx=i;}
      if (distCurr8_42<small8_42s) {small8_42s=distCurr8_42; iSmallIdx=i;}
      //the small index should be bigger(on the left) of the biggest
      if ((i==0) && (iSmallIdx>iBigIdx)) div8_42s=big8_42s-small8_42s;
      //if (debug1 && debug2) Print("div ",i, " Last8_42 ", RoundN(distLast8_42)," Curr: " , RoundN(distCurr8_42)," div ", RoundN(div8_42s));
    }
    if (distLast8_42<0 && distCurr8_42<-FirstMinDist21 && slope21<-Slope21s) {  //short trades
      int iSmallIdx, iBigIdx; //remember the index of the smallest and biggest
      if (MathAbs(distCurr8_42)>big8_42s) {big8_42s=MathAbs(distCurr8_42); iBigIdx=i;}
      if (MathAbs(distCurr8_42)<small8_42s) {small8_42s=MathAbs(distCurr8_42); iSmallIdx=i;}
      if ((i==0) && (iSmallIdx>iBigIdx)) div8_42s=big8_42s-small8_42s;
      //if (debug1 && debug2) Print("div 8_42s ",i," Last: ",RoundN(distLast8_42)," Curr: ",RoundN(distCurr8_42)," smallest ", RoundN(small8_42s));
    }   
  }//short distance
}//div func

class CFilterMA {
public:
  double Dist5_13, Dist8_13, Dist5_21, Dist8_42, Dist13_21, Dist21_42, Dist21_63, 
   dist42_63, Dist63_126, PrcCtrl8, PrcCtrl5, PrcCtrl21;
  double SlopeMin, SlopeOpti, Slope5one, Slope13, Slope8, Slope21, Slope42, Slope63, Slope126;  
  double ROC5, ROC13, ROC13b, ROC8;
  double Div5_13, Div8_21s, Div8_42s, Div8_21, Div8_42, Div5_21s, Div5_21, Div21_42, Div21_63, Div21_42s;
  string sResults;
  
  virtual void Load(CValues *val) {
    sResults="";//initialise the results string
  }
};

class CFilterMA_3M : public CFilterMA {

public:
  void Load(CValues *val) {
    if (val.SteepMode==0){  //0
      SlopeMin=0.015; SlopeOpti=0.03; Slope5one=-0.015;
      Slope13=0.18; Slope8=0.18; Slope21=-0.01; Slope42=-0.02; Slope63=-0.08; Slope126=-0.15;
      Dist5_13=0.39; Dist8_13=0.55; Dist5_21=1.3; Dist8_42=3.8; Dist13_21=0.4; 
      Dist21_42=2.5; Dist21_63=3.2; dist42_63=4.8; Dist63_126=4.0; 
      PrcCtrl8=1.1; PrcCtrl5=0.65;
      ROC5=0.6; ROC13=1.05; ROC13b=2.0; ROC8=-0.1;
      Div5_13=0.25; Div8_21=1.0; Div8_21s=0.38; Div5_21s=0.6; Div5_21=1.5; Div21_42=0.75; Div21_63=1.8; Div21_42s=0.55;
    }
    if (val.SteepMode==1){ //==1
      SlopeMin=0.08; SlopeOpti=0.15; Slope5one=-0.015;
      Slope13=0.18; Slope8=0.18; Slope21=-0.02; Slope42=-0.04; Slope63=-0.08; Slope126=-0.15;    
      Dist5_13=0.45; Dist8_13=0.75; Dist5_21=1.0; Dist8_42=3.0; Dist13_21=1.0; 
      Dist21_42=3.2; Dist21_63=3.5;  dist42_63=5.0; Dist63_126=3.5; 
      PrcCtrl5=0.9; PrcCtrl8=1.8;
      ROC5=0.8; ROC13=1.25; ROC13b=2.5; ROC8=-0.12;  
      Div5_13=0.5; Div8_21=0.85; Div8_21s=0.8; Div5_21s=0.8; Div5_21=2.0; Div21_42=1.6; Div21_63=1.85; Div21_42s=0.62;     
    }
    Checks();
  }//Load

private:
  void Checks() {
  //check which direction to choose SlopeCheck
    if (val.slope13>SlopeMin && val.slope8>SlopeMin && val.slope5>SlopeMin) {
      if (SlopeCheckUp() && CheckNearUp()) sResults="Up 3M";
      if (debug1) Print("Slope up");
    }

    if (val.slope13<-SlopeMin && val.slope8<-SlopeMin && val.slope5<-SlopeMin) {
      if (SlopeCheckDown() && CheckNearDown()) sResults="Down 3M";
      if (debug1) Print("Slope down");
    }
    if (!DistCheck()) sResults="";
    if (!DivergeCheck()) sResults="";
  }
  
  bool SlopeCheckUp() {
    bool bPass=true;
    double StDev3M=0.07;

    if (val.slope5one<Slope5one) {
      bPass=false;
      if (debug1) Print("Fail SlopeUP Slope5one ",RoundN(val.slope5one)," ",Slope5one);
    }  
    if (val.slope21<Slope21) {
      bPass=false;
      if (debug1) Print("Fail SlopeUP Slope21 ",RoundN(val.slope21)," ",Slope21);
    }
    if (val.slope42<Slope42) {
      bPass=false;
      if (debug1) Print("Fail SlopeUP Slope42 ",RoundN(val.slope42)," ",Slope42);
    }
    if (val.slope63<Slope63) {
      bPass=false;
      if (debug1) Print("Fail SlopeUP Slope63 ",RoundN(val.slope63)," ",Slope63);
    }
    if (val.slope126<Slope126) {
      bPass=false;
      if (debug1) Print("Fail SlopeUP Slope126 ",RoundN(val.slope126)," ",Slope126);
    }
    //63 126 slope against
    if (val.slope63<Slope63 && val.slope126<Slope126) {
      bPass=false;
      if (debug1) Print("Fail SlopeUP Slope63 and Slope126 against",RoundN(val.slope126)," ",Slope126);  
    }
    //slopes of each 3M cannot deviate too much from one another
    if (bPass)
      if ((val.slope13-val.slope8>StDev3M) || (val.slope8-val.slope5>StDev3M)) {
        bPass=false;
        if (debug1) Print("Fail 3M deviate");  
      }
    return bPass;
  }
  
  bool SlopeCheckDown () {
    bool bPass=true;
    double StDev3M=-0.07;

    if (val.slope5one>-Slope5one) {
      bPass=false;
      if (debug1) Print("Fail SlopeUP Slope5one ",RoundN(val.slope5one)," ",Slope5one);
    }   
    if (val.slope21>-Slope21) {
      bPass=false;
      if (debug1) Print("Fail SlopeDown Slope21 ",RoundN(val.slope21)," ",Slope21);
    }
    if (val.slope42>-Slope42) {
      bPass=false;
      if (debug1) Print("Fail SlopeDown Slope42 ",RoundN(val.slope42)," ",Slope42);
    }
    if (val.slope63>-Slope63) {
      bPass=false;
      if (debug1) Print("Fail SlopeDown Slope63 ",RoundN(val.slope63)," ",Slope63);
    }
    if (val.slope126>-Slope126) {
      bPass=false;
      if (debug1) Print("Fail SlopeDown Slope126 ",RoundN(val.slope126)," ",Slope126);
    }
    //63 126 slope against
    if (val.slope63>-Slope63 && val.slope126>-Slope126) {
      bPass=false;
      if (debug1) Print("Fail SlopeDown Slope63 and Slope126 against",RoundN(val.slope126)," ",Slope126);  
    }
    if (bPass)
      if ((val.slope13-val.slope8<StDev3M) || (val.slope8-val.slope5<StDev3M)) {
        bPass=false;
        if (debug1) Print("Fail 3M deviate");  
      }
    if (debug1 && bPass) Print("SlopeDown check done");  
    return bPass;
  }

  //check MA that slope down and above 35, need to filter
  bool CheckNearUp() {
    bool bPass=true;
    double NearUp = EMA13[val.pos] + val.atr*6.0;
    double Roc5=1.2;
    double Dist5_13=0.58, Dist8_13a=0.075, Slope8_13=0.2, Slope8=0.12, Slope21=-0.03;
    double Div5_13=0.3;
    double SlopeBlock42=0.02, SlopeBlock63=0.01, SlopeBlock126=0.01;
    int NumOfBlocks = 0;
    //if 126 is too far, we disqualify
    //if (SMA126[val.pos] > (EMA13[val.pos] + val.atr) ) {
      //if (debug1) Print("CheckNear Fail 126 is too far "); return false; 
    //}
    //21 below 63
    if (SMA21[val.pos]<SMA63[val.pos]*0.999) {
      if (debug1) Print("CheckNear Fail 21 below 63"); return false; 
    }   
    //8n13 need to be above 21
    if (SMA8[val.pos]<SMA21[val.pos]*0.999 || EMA13[val.pos]<SMA21[val.pos]*0.999) {
      if (debug1) Print("CheckNear Fail 8n13 below 21"); return false; 
    } 
    //3M need to be above 42, need to buffer 42 value 0.2% less
    if (EMA13[val.pos]<SMA42[val.pos]*0.9999) {
      if (debug1) Print("CheckNear Fail 13<42"); return false; 
    }
    //either 42 and 63 need to be up
    if (val.slope42<Slope42 && val.slope63<Slope63) {
      if (debug1) Print("CheckNear Fail 42/63 slope"); return false;
    }
    //one of the MA too steep against 
    if (val.SteepMode==0 && SMA126[val.pos]<NearUp && EMA13[val.pos]<SMA126[val.pos] && val.slope126<SlopeBlock126) {
      if (debug1) Print("CheckNearUp Fail 126 Block"); return false;
      NumOfBlocks=NumOfBlocks+1;    
    } /*
    if (SMA252[val.pos]<NearUp && EMA13[val.pos]<SMA252[val.pos] && val.slope252<SlopeBlock126) {
      if (debug1) Print("CheckNearUp Fail 252 Block"); return false;
      NumOfBlocks=NumOfBlocks+1;    
    } */
    //if one of River2 block and both MA slope against
    if (NumOfBlocks>=1 && val.slope126<SlopeBlock126 && val.slope252<SlopeBlock126) {
      if (debug1) Print("CheckNearUp Fail River2 block"); return false;
      return false;    
    }
    //slope13 not steep enough and near 63
    if (SMA63[val.pos]<NearUp && (EMA13[val.pos]*0.9999)<SMA63[val.pos] && val.slope63<SlopeBlock63) {
      NumOfBlocks=NumOfBlocks+1;
    }
    //slope13 not steep enough and near 42
    if (SMA42[val.pos]<NearUp && (EMA13[val.pos]*0.9999)<SMA42[val.pos] && val.slope42<SlopeBlock42) {
      NumOfBlocks=NumOfBlocks+1;
    }
    if (NumOfBlocks==0) return true;
    //able to break through one MA block with steep 3M
    //now there are one or more MA is blocking
    if (val.dist5_13>Dist5_13) {
      if (debug1) Print("CheckNear Fail Dist5_13 ",RoundN(val.dist5_13)," ",Dist5_13 ); return false;  
    }  
    if (val.div5_13>Div5_13) {
      if (debug1) Print("CheckNear Fail Div5_13 ",RoundN(val.div5_13)," ",Div5_13 ); return false;  
    }
    if (val.slope21<Slope21) {
      if (debug1) Print("CheckNear Fail slope21 ",RoundN(val.slope21)," ",Slope21 ); return false;  
    }
  
    return bPass;
  }

  bool CheckNearDown() { 
    bool bPass=true;
    double NearDown = EMA13[val.pos] - val.atr*6.0;
    float Roc5=1.0;
    double Dist5_13=0.58, Dist8_13a=0.075, Slope8_13=-0.2, Slope8=-0.1, Slope21=0.03;
    double Div5_13=0.3;
    double SlopeBlock42=-0.02, SlopeBlock63=0.01,  SlopeBlock126=-0.01;
    int NumOfBlocks=0;
  
    //21 above 63
    if (SMA21[val.pos]>SMA63[val.pos]*1.001) {
      if (debug1) Print("CheckNear Fail 21 above 63"); return false; 
    }      
    //8n13 need to be below 21
    if (SMA8[val.pos]>SMA21[val.pos]*1.001 || EMA13[val.pos]>SMA21[val.pos]*1.001) {
      if (debug1) Print("CheckNear Fail 8n13 below 21"); return false; 
    }   
    //3M need to be below 42, need to buffer 42 value 10% more
    if (EMA13[val.pos]>SMA42[val.pos]*1.0001) {
      if (debug1) Print("CheckNearDown Fail 13>42"); return false; 
    }
    //either 42 and 63 need to be down
    if (val.slope42>-Slope42 && val.slope63>Slope63) {
      if (debug1) Print("CheckNearDown Fail 42/63 slope"); return false;
    }
    //blockage by MA
    if (SMA126[val.pos]>NearDown && (EMA13[val.pos]*1.0001)>SMA126[val.pos] && val.slope126>SlopeBlock126) {
      //if (debug1) Print("CheckNearDown Fail 126 Block ", (EMA13[val.pos]*1.01)>SMA126[val.pos]); return false;
      NumOfBlocks=NumOfBlocks+1;    
    }
    if (SMA252[val.pos]>NearDown && (EMA13[val.pos]*1.0001)>SMA252[val.pos] && val.slope252>SlopeBlock126) {
      //if (debug1) Print("CheckNearDown Fail 126 Block ", (EMA13[val.pos]*1.01)>SMA126[val.pos]); return false;
      NumOfBlocks=NumOfBlocks+1;    
    } 
    if (SMA63[val.pos]>NearDown && EMA13[val.pos]*1.0001>SMA63[val.pos] && val.slope63>SlopeBlock63) {
      NumOfBlocks=NumOfBlocks+1;
    }   
    //slope13 not steep enough and near 42
    if (SMA42[val.pos]>NearDown && (EMA13[val.pos]*1.0001)>SMA42[val.pos] && val.slope42>SlopeBlock42) {
      NumOfBlocks=NumOfBlocks+1;
    }
    if (NumOfBlocks==0) {return true;}
    //able to break through one MA block with steep
    
    //now there are one or more MA is blocking
    if (val.dist5_13>Dist5_13) {
      if (debug1) Print("CheckNear Fail Dist5_13 ",val.dist5_13," ",Dist5_13 ); return false;  
    }  
    if (val.div5_13>Div5_13) {
      if (debug1) Print("CheckNear Fail Div5_13 ",val.div5_13," ",Div5_13 ); return false;  
    }
    if (val.slope21>Slope21) {
      if (debug1) Print("CheckNear Fail slope21 ",val.slope21," ",Slope21 ); return false;  
    }
  
    return bPass;
  }//CheckNearDown
  
  bool DistCheck() {
    bool bPass=true;
    
    if (val.dist5_13>Dist5_13) {
      bPass=false;
      if (debug1) Print("Fail Dist5_13 ",RoundN(val.dist5_13)," ",Dist5_13);
    }    
    if (val.dist8_42>Dist8_42) {
      bPass=false;
      if (debug1) Print("Fail Dist8_42 ",RoundN(val.dist8_42)," ",Dist8_42);
    }
    if (val.dist13_21>Dist13_21) {
      bPass=false;
      if (debug1) Print("Fail Dist13_21 ",RoundN(val.dist13_21)," ",Dist13_21);
    }
    if (val.dist21_42>Dist21_42) {
      bPass=false;
      if (debug1) Print("Fail Dist21_42 ",RoundN(val.dist21_42)," ",Dist21_42);
    }
    if (val.dist21_63>Dist21_63) {
      bPass=false;
      if (debug1) Print("Fail Dist21_63 ",RoundN(val.dist21_63)," ",Dist21_63);
    }
    if (val.dist42_63>dist42_63) {
      bPass=false;
      if (debug1) Print("Fail dist42_63 ",RoundN(val.dist42_63)," ",dist42_63);
    }
    if (val.dist63_126>Dist63_126) {
      bPass=false;
      if (debug1) Print("Fail Dist63_126 ",RoundN(val.dist63_126)," ",Dist63_126);
    }
    //if both exceeds, we disqualify
    if (val.prcCtrl8>PrcCtrl8 || val.prcCtrl5>PrcCtrl5) {
      bPass=false;
      if (debug1) Print("Fail PrcCtrl8 ",RoundN(val.prcCtrl8)," ",PrcCtrl8);
      if (debug1) Print("Fail PrcCtrl5 ",RoundN(val.prcCtrl5)," ",PrcCtrl5);
    } 
    return bPass;
  }//DistCheck

  bool DivergeCheck() {
    bool bPass=true;

    if (val.div5_13>filter.Div5_13) {
      bPass=false;
      if (debug1) Print("Fail Div5_13: ", RoundN(val.div5_13)," ",Div5_13);
    }
    if (val.div8_21>Div8_21) {
      bPass=false;
      if (debug1) Print("Fail Div8_21: ", RoundN(val.div8_21)," ",Div8_21);
    }
    if (val.div8_21s>Div8_21s) {
      bPass=false;
      if (debug1) Print("Fail Div8_21s: ", RoundN(val.div8_21s)," ",Div8_21s);
    }
    if (val.div5_21>Div5_21) {
      bPass=false;
      if (debug1) Print("Fail Div5_21: ", RoundN(val.div5_21)," ",Div5_21);
    }  
    if (val.div5_21s>Div5_21s) {
      bPass=false;
      if (debug1) Print("Fail Div5_21s: ", RoundN(val.div5_21s)," ",Div5_21s);
    }
    if (val.div21_42>Div21_42) {
      bPass=false;
      if (debug1) Print("Fail Div21_42: ", RoundN(val.div21_42)," ",Div21_42);
    }
    if (val.div21_63>Div21_63) {
      bPass=false;
      if (debug1) Print("Fail Div21_63: ", RoundN(val.div21_63)," ",Div21_63);
    }  
    if (val.div21_42s>Div21_42s) {
      bPass=false;
      if (debug1) Print("Fail Div21_42s: ", RoundN(val.div21_42s)," ",Div21_42s);
    }
    
    return bPass;  
  }  
  
}; //Filter3M

class CFilterMAStrict : public CFilterMA
  {
public:
  void Load(CValues *val) {
    //if (val.SteepMode==0){  //0    
      SlopeMin=0.01; SlopeOpti=-0.03; Slope5one=-0.15;
      Slope13=-0.2; Slope8=-0.2; Slope21=-0.05; Slope42=0.01; Slope63=0.01; Slope126=-0.005;
      Dist5_13=0.8; Dist8_13=0.95; Dist5_21=0.8; Dist13_21=0.9; Dist8_42=3.0; //Dist8_42=2.0
      Dist21_42=1.8; Dist21_63=2.4; dist42_63=2.6; Dist63_126=2.4;  //Dist21_42=1.6;  Dist63_126=1.2 dist42_63=1.8;
      PrcCtrl21=1.4;
      ROC5=0.6; ROC13=1.05; ROC13b=2.0; ROC8=-0.1;
      Div5_13=0.25; Div8_21=1.2; Div8_21s=0.8; Div5_21s=0.6; Div5_21=1.5; Div8_42=3.0; Div21_42=1.3; 
      Div21_63=1.8; Div21_42s=0.5;
    //}
    Checks();
  }//Load

private:
  bool SlopeCheckDown();
  bool SlopeCheckUp();
  bool DistCheck();
  bool DivergeCheck();  
  //main Checks function
  void Checks() {
  //check which direction to choose SlopeCheck
    if (val.slope42>SlopeMin) {
      if (SlopeCheckUp()) sResults="Up 3M";
      if (debug1) Print("Slope up");
    }

    if (val.slope42<-SlopeMin) {
      if (SlopeCheckDown()) sResults="Down 3M";
      if (debug1) Print("Slope down");
    }
    if (!DistCheck()) sResults="";
    if (!DivergeCheck()) sResults="";
  }
};

bool CFilterMAStrict::SlopeCheckUp() {
  bool bPass=true;

  if (val.slope21<Slope21) {
    bPass=false;
    if (debug1) Print("Fail SlopeUP Slope21 ",RoundN(val.slope21)," ",Slope21);
  }
  if (val.slope42<Slope42) {
    bPass=false;
    if (debug1) Print("Fail SlopeUP Slope42 ",RoundN(val.slope42)," ",Slope42);
  }
  if (val.slope63<Slope63) {
    bPass=false;
    if (debug1) Print("Fail SlopeUP Slope63 ",RoundN(val.slope63)," ",Slope63);
  }
  if (val.slope126<Slope126) {
    bPass=false;
    if (debug1) Print("Fail SlopeUP Slope126 ",RoundN(val.slope126)," ",Slope126);
  }
  //63 126 slope against
  if (val.slope63<Slope63 && val.slope126<Slope126) {
    bPass=false;
    if (debug1) Print("Fail SlopeUP Slope63 and Slope126 against",RoundN(val.slope126)," ",Slope126);  
  }

  return bPass;
}

bool CFilterMAStrict::SlopeCheckDown () {
  bool bPass=true;

  if (val.slope21>-Slope21) {
    bPass=false;
    if (debug1) Print("Fail SlopeDown Slope21 ",RoundN(val.slope21)," ",Slope21);
  }
  if (val.slope42>-Slope42) {
    bPass=false;
    if (debug1) Print("Fail SlopeDown Slope42 ",RoundN(val.slope42)," ",Slope42);
  }
  if (val.slope63>-Slope63) {
    bPass=false;
    if (debug1) Print("Fail SlopeDown Slope63 ",RoundN(val.slope63)," ",Slope63);
  }
  if (val.slope126>-Slope126) {
    bPass=false;
    if (debug1) Print("Fail SlopeDown Slope126 ",RoundN(val.slope126)," ",Slope126);
  }
  //63 126 slope against
  if (val.slope63>-Slope63 && val.slope126>-Slope126) {
    bPass=false;
    if (debug1) Print("Fail SlopeDown Slope63 and Slope126 against",RoundN(val.slope126)," ",Slope126);  
  }

  return bPass;
}

bool CFilterMAStrict::DistCheck() {
  bool bPass=true;
  /*
  if (val.dist5_13>Dist5_13) {
    bPass=false;
    if (debug1) Print("Fail Dist5_13 ",RoundN(val.dist5_13)," ",Dist5_13);
  }    
  if (val.dist13_21>Dist13_21) {
    bPass=false;
    if (debug1) Print("Fail Dist13_21 ",RoundN(val.dist13_21)," ",Dist13_21);
  } */
  if (val.dist8_42>Dist8_42) {
    bPass=false;
    if (debug1) Print("Fail Dist8_42 ",RoundN(val.dist8_42)," ",Dist8_42);
  }    
  if (val.dist21_42>Dist21_42) {
    bPass=false;
    if (debug1) Print("Fail Dist21_42 ",RoundN(val.dist21_42)," ",Dist21_42);
  }
  if (val.dist21_63>Dist21_63) {
    bPass=false;
    if (debug1) Print("Fail Dist21_63 ",RoundN(val.dist21_63)," ",Dist21_63);
  }
  if (val.dist42_63>dist42_63) {
    bPass=false;
    if (debug1) Print("Fail dist42_63 ",RoundN(val.dist42_63)," ",dist42_63);
  }
  if (val.dist63_126>Dist63_126) {
    bPass=false;
    if (debug1) Print("Fail Dist63_126 ",RoundN(val.dist63_126)," ",Dist63_126);
  }
  //if both exceeds, we disqualify
  if (val.prcCtrl21>PrcCtrl21) {
    bPass=false;
    if (debug1) Print("Fail PrcCtrl21 ",RoundN(val.prcCtrl21)," ",PrcCtrl21);
  } 
  return bPass;
}//DistCheck


bool CFilterMAStrict::DivergeCheck() {
  bool bPass=true;
  
  if (val.div5_13>filter.Div5_13) {
    bPass=false;
    if (debug1) Print("Fail Div5_13: ", RoundN(val.div5_13)," ",Div5_13);
  }
  if (val.div8_21>Div8_21) {
    bPass=false;
    if (debug1) Print("Fail Div8_21: ", RoundN(val.div8_21)," ",Div8_21);
  }
  if (val.div8_21s>Div8_21s) {
    bPass=false;
    if (debug1) Print("Fail Div8_21s: ", RoundN(val.div8_21s)," ",Div8_21s);
  }
  if (val.div5_21>Div5_21) {
    bPass=false;
    if (debug1) Print("Fail Div5_21: ", RoundN(val.div5_21)," ",Div5_21);
  }  
  if (val.div5_21s>Div5_21s) {
    bPass=false;
    if (debug1) Print("Fail Div5_21s: ", RoundN(val.div5_21s)," ",Div5_21s);
  }
  if (val.div8_42>Div8_42) {
    bPass=false;
    if (debug1) Print("Fail Div8_42: ", RoundN(val.div8_42)," ",Div8_42);
  }
  if (val.div21_42>Div21_42) {
    bPass=false;
    if (debug1) Print("Fail Div21_42: ", RoundN(val.div21_42)," ",Div21_42);
  }
  if (val.div21_63>Div21_63) {
    bPass=false;
    if (debug1) Print("Fail Div21_63: ", RoundN(val.div21_63)," ",Div21_63);
  }  
  if (val.div21_42s>Div21_42s) {
    bPass=false;
    if (debug1) Print("Fail Div21_42s: ", RoundN(val.div21_42s)," ",Div21_42s);
  }
  
  return bPass;  
}  

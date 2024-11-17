double One[],EMA5[],SMA8[],EMA13[],SMA21[],SMA42[],SMA63[],SMA84[],SMA126[],SMA168[],SMA252[],SMA336[],SMA630[];
double ATR[],MA[12];
MqlRates rates[];
input int ATR_Factor = 21; 

string RoundN(double number)
{
  string sNum = DoubleToString(number);
 
  return StringSubstr(sNum, 0, 5);
}


double ATRStop(string symbol, int timeframe, int period, int multiple){
   return multiple * iATR(symbol, timeframe, period, 1);
}
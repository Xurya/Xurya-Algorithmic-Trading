
double ATRStop(int timeframe, int period, int multiple){
   return multiple * iATR(pair, timeframe, period, 1);
}
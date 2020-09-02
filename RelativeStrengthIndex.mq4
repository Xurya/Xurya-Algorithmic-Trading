int RSICrossSignal(string symbol, int timeframe, int shift){
   double rsi = iRSI(symbol, timeframe, 20, PRICE_CLOSE, shift);
   double rsiL = iRSI(symbol, timeframe, 20, PRICE_CLOSE, shift+1);
   
   if(rsi < 70 && rsiL >= 70){
      return OP_SELL;
   }else if(rsi > 30 && rsiL <= 30){
      return OP_BUY;
   }
   
   return -1;
}
int RSICrossSignal(){
   double rsi = iRSI(pair, PERIOD_M30, 20, PRICE_CLOSE, 0);
   double rsiL = iRSI(pair,PERIOD_M30, 20, PRICE_CLOSE, 2);
   
   if(rsi < 75 && rsiL > 75){
      return OP_SELL;
   }else if(rsi > 25 && rsiL < 25){
      return OP_BUY;
   }
   
   return -1;
}
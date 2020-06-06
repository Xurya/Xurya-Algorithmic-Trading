int MACrossSignal(){
   double EMA50 = iMA(pair, PERIOD_M30, 50, 0, MODE_EMA, PRICE_CLOSE, 0);
   double EMA50L = iMA(pair, PERIOD_M30, 50, 0, MODE_EMA, PRICE_CLOSE, 1);
   double EMA200 = iMA(pair, PERIOD_M30, 200, 0, MODE_EMA, PRICE_CLOSE, 0);
   double EMA200L = iMA(pair, PERIOD_M30, 200, 0, MODE_EMA, PRICE_CLOSE, 1);
   bool BuyCross = EMA200L>=EMA50L && EMA50>=EMA200 ;
   bool SellCross = EMA200L<=EMA50L && EMA50<=EMA200;
   
   if(BuyCross){
      return OP_BUY;
   }else if(SellCross){
      return OP_SELL;
   }
   
   return -1;
}
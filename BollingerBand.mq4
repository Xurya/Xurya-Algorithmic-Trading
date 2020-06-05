int package[2];

int BollingerSqueezeEntry(){
   double top = iBands(pair, PERIOD_M30, 20, 2.0, 0, PRICE_CLOSE, MODE_UPPER,0);
   double topL = iBands(pair, PERIOD_M30, 20, 1.0, 0, PRICE_CLOSE, MODE_UPPER,0);
   double bottom = iBands(pair, PERIOD_M30, 20, 2.0, 0, PRICE_CLOSE, MODE_LOWER,0);
   double bottomL = iBands(pair, PERIOD_M30, 20, 1.0, 0, PRICE_CLOSE, MODE_LOWER,0);
   double SMA20 = iMA(pair, PERIOD_M30, 20, 0, MODE_SMA, PRICE_CLOSE, 0);
   double BBW = (top-bottom)/SMA20; 
   
   //TODO GOAL: Try to incorperate RSI for regular trading, MFI for reversals.
   double rsi = iRSI(pair, PERIOD_M30, 20, PRICE_CLOSE, 0);
   double rsiL = iRSI(pair,PERIOD_M30, 20, PRICE_CLOSE, 2);
   
   //Figure out BBW range for ratio to find squeeze.
   int bars = 120; 
   double avgBBW = iBands(pair, PERIOD_D1, 20, 2.0, 0, PRICE_CLOSE, MODE_UPPER,0);
   double lowBBW = iBands(pair, PERIOD_D1, 20, 2.0, 0, PRICE_CLOSE, MODE_UPPER,0);
   
   double temptop;
   double tempbottom;
   double tempSMA20;
   double tempBBW;
   for(int i=1; i<bars;i++){
      temptop = iBands(pair, PERIOD_D1, 20, 2.0, 0, PRICE_CLOSE, MODE_UPPER,i);
      tempbottom = iBands(pair, PERIOD_D1, 20, 2.0, 0, PRICE_CLOSE, MODE_LOWER,i);
      tempSMA20 = iMA(pair, PERIOD_D1, 20, 0, MODE_SMA, PRICE_CLOSE, i);
      if(tempSMA20==0){
         tempSMA20=1;
      }
      tempBBW= (temptop-tempbottom)/tempSMA20;
      avgBBW += tempBBW; 
      lowBBW = MathMin(lowBBW, tempBBW); 
   }
   
   avgBBW /= bars;
   
   //Measure current volatility risk
   double volatile = BBW > avgBBW;
   
   
   //TODO GOALS:
   //-Squeeze 
   //-Regular / Reverse / contrarian
   //-Volatile -> Fading/Contrarian Bollinger
   
   //Squeeze Trading
   if(BBW<=lowBBW){
      //Switches trading strategy and Trailing
      package[1] = 1;
   }else{
      package[1] = 0;
   }
   
   if(package[1]==1){
      //Analyze breakout direction
      
      //Signal if RSI hits over thresholds
      if(rsi<75 && rsiL>75){
         return OP_SELL;
      }else if(rsi>10 && rsiL<10){
         return OP_BUY;
      }
   }
   
   return -1;
}


int BollingerSqueezeExit(){
   double top = iBands(pair, PERIOD_M30, 20, 2.0, 0, PRICE_CLOSE, MODE_UPPER,0);
   double topL = iBands(pair, PERIOD_M30, 20, 1.0, 0, PRICE_CLOSE, MODE_UPPER,0);
   double bottom = iBands(pair, PERIOD_M30, 20, 2.0, 0, PRICE_CLOSE, MODE_LOWER,0);
   double bottomL = iBands(pair, PERIOD_M30, 20, 1.0, 0, PRICE_CLOSE, MODE_LOWER,0);
   double SMA20 = iMA(pair, PERIOD_M30, 20, 0, MODE_SMA, PRICE_CLOSE, 0);
   double BBW = (top-bottom)/SMA20; 
   
   //TODO GOAL: Try to incorperate RSI for regular trading, MFI for reversals.
   double rsi = iRSI(pair, PERIOD_M30, 20, PRICE_CLOSE, 0);
   double rsiL = iRSI(pair,PERIOD_M30, 20, PRICE_CLOSE, 2);
   
   if(package[1]==1){
      //Analyze breakout direction
      
      //Signal if RSI hits over thresholds
      if(rsi<70 && rsiL>70){
         return OP_SELL;
      }else if(rsi>70 && rsiL<70){
         return OP_BUY;
      }
   }
   
   return -1;
}
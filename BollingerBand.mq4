/*   
   IDEAS:
   
   //-Squeeze 
   //-Regular / Reverse / contrarian
   //-Volatile -> Fading/Contrarian Bollinger
   
   //Try to incorperate RSI for regular trading, MFI for reversals.
   double rsi = iRSI(pair, PERIOD_M30, 14, PRICE_CLOSE, 0);
   double rsiL = iRSI(pair,PERIOD_M30, 14, PRICE_CLOSE, 2);

   //TODO: IDENTIFY IF WE ARE STILL WITHIN A SQUEEZe.
   
   //TODO: ADD EVENT VISUALS FOR SQUEEZE.
*/

int squeeze = 0;
double oldBBW = 0;

int BollingerSqueezeSignal(){
   int bars = 100;
   if(Bars<bars+20){
      Print("bars less than " + bars);
      return -1;
   }

   double top = iBands(pair, PERIOD_M30, 20, 2.0, 0, PRICE_CLOSE, MODE_UPPER,0);
   double bottom = iBands(pair, PERIOD_M30, 20, 2.0, 0, PRICE_CLOSE, MODE_LOWER,0);
   double SMA20 = iMA(pair, PERIOD_M30, 20, 0, MODE_SMA, PRICE_CLOSE, 0);
   double BBW = (top-bottom)/SMA20; 
   
   //Squeeze continuation
   if(squeeze == 1){
      if(BBW >= 1.3*oldBBW){
         squeeze = 0;
      }else{
         ObjectCreate(ChartID(), "Squeeze" + Time[0], OBJ_ARROW_CHECK,0,Time[0], Ask); 
      }
      return squeeze;
   }
   
   //Figure out BBW low based on bars to identify squeeze.
   double lowBBW = iBands(pair, PERIOD_M30, 20, 2.0, 0, PRICE_CLOSE, MODE_UPPER,1);
   
   double temptop;
   double tempbottom;
   double tempSMA20;
   double tempBBW;
   for(int i=2; i<bars;i++){
      temptop = iBands(pair, PERIOD_M30, 20, 2.0, 0, PRICE_CLOSE, MODE_UPPER,i);
      tempbottom = iBands(pair, PERIOD_M30, 20, 2.0, 0, PRICE_CLOSE, MODE_LOWER,i);
      tempSMA20 = iMA(pair, PERIOD_M30, 20, 0, MODE_SMA, PRICE_CLOSE, i);
      tempBBW= (temptop-tempbottom)/tempSMA20;
      lowBBW = MathMin(lowBBW, tempBBW); 
   }

   //Squeeze Trading
   if(BBW<=lowBBW){
      ObjectCreate(ChartID(),"Squeeze" + Time[0], OBJ_ARROW_CHECK,0,Time[0], Ask); 
      squeeze = 1;
      oldBBW=BBW;
   }
   
   return squeeze;
}

int BollingerBandSignal(){
   double top = iBands(pair, PERIOD_M30, 20, 2.0, 0, PRICE_CLOSE, MODE_UPPER,0);
   double topL = iBands(pair, PERIOD_M30, 20, 1.0, 0, PRICE_CLOSE, MODE_UPPER,0);
   double bottom = iBands(pair, PERIOD_M30, 20, 2.0, 0, PRICE_CLOSE, MODE_LOWER,0);
   double bottomL = iBands(pair, PERIOD_M30, 20, 1.0, 0, PRICE_CLOSE, MODE_LOWER,0);
   
   //Range Trading
   if(Ask < topL && Close[1]>topL){
      ObjectCreate(ChartID(), "BollingerBand " + Time[0], OBJ_ARROW_SELL, 0, Time[0], Ask);
      return OP_SELL;
   }else if(Bid > bottomL && Close[1] < bottomL){
      ObjectCreate(ChartID(), "BollingerBand " + Time[0], OBJ_ARROW_BUY, 0, Time[0], Ask);
      return OP_BUY;
   }
   
   return -1;
}
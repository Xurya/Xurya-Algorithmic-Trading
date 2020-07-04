/*   
   IDEAS:
   
   //-Squeeze 
   //-Regular / Reverse / contrarian
   //-Volatile -> Fading/Contrarian Bollinger
*/

int squeeze = 0;
double oldBBW = 0;

int BollingerSqueezeSignal(int bars){
   if(Bars<bars+20){
      Print("bars less than " + bars);
      return -1;
   }

   double top = iBands(pair, PERIOD_M30, 20, 2.0, 0, PRICE_CLOSE, MODE_UPPER,0);
   double bottom = iBands(pair, PERIOD_M30, 20, 2.0, 0, PRICE_CLOSE, MODE_LOWER,0);
   double SMA20 = iMA(pair, PERIOD_M30, 20, 0, MODE_SMA, PRICE_CLOSE, 0);
   double BBW = (top-bottom)/SMA20; 
   string name = "Squeeze" + Time[0];
   
   //Squeeze continuation
   if(squeeze > 0){
      if(BBW >= oldBBW*1.1){
         squeeze = 0;
      }else{
         squeeze++;
         ObjectCreate(ChartID(),name, OBJ_ARROW_STOP,0,Time[0], Ask); 
         ObjectSetInteger(ChartID(),name,OBJPROP_COLOR,clrYellow);
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
      if(tempSMA20 == 0){
         continue;
      }
      tempBBW= (temptop-tempbottom)/tempSMA20;
      lowBBW = MathMin(lowBBW, tempBBW); 
   }

   //Squeeze Trading
   if(BBW<lowBBW){
      ObjectCreate(ChartID(),name, OBJ_ARROW_STOP,0,Time[0], Ask); 
      ObjectSetInteger(ChartID(),name,OBJPROP_COLOR,clrYellow);
      squeeze = 1;
      oldBBW=BBW;
   }
   
   return squeeze;
}

int BollingerBandBreak(){
   double top = iBands(pair, PERIOD_M30, 20, 2.0, 0, PRICE_CLOSE, MODE_UPPER,0);
   double topL = iBands(pair, PERIOD_M30, 20, 1.0, 0, PRICE_CLOSE, MODE_UPPER,0);
   double bottom = iBands(pair, PERIOD_M30, 20, 2.0, 0, PRICE_CLOSE, MODE_LOWER,0);
   double bottomL = iBands(pair, PERIOD_M30, 20, 1.0, 0, PRICE_CLOSE, MODE_LOWER,0);
   
   string name = "BollingerBreak " + Time[0];
   //Range Trading
   if(Ask > top){
      ObjectCreate(ChartID(), name, OBJ_ARROW, 0, Time[0], Bid);
      ObjectSetInteger(ChartID(),name,OBJPROP_COLOR,clrAliceBlue);
      return OP_BUY;
   }else if(Bid < bottom){
      ObjectCreate(ChartID(), name, OBJ_ARROW_DOWN, 0, Time[0], Ask);
      ObjectSetInteger(ChartID(),name,OBJPROP_COLOR,clrRed);
      return OP_SELL;
   }
   
   return -1;
}

int BollingerBandRange(){
   double top = iBands(pair, PERIOD_M30, 20, 2.0, 0, PRICE_CLOSE, MODE_UPPER,0);
   double topL = iBands(pair, PERIOD_M30, 20, 1.0, 0, PRICE_CLOSE, MODE_UPPER,0);
   double bottom = iBands(pair, PERIOD_M30, 20, 2.0, 0, PRICE_CLOSE, MODE_LOWER,0);
   double bottomL = iBands(pair, PERIOD_M30, 20, 1.0, 0, PRICE_CLOSE, MODE_LOWER,0);
   
   string name = "BollingerRange " + Time[0];
   //Range Trading
   if(Ask < top && iClose(pair, PERIOD_M30, 2) > top && Ask > topL){
      ObjectCreate(ChartID(), name, OBJ_ARROW_DOWN, 0, Time[0], Ask);
      ObjectSetInteger(ChartID(),name,OBJPROP_COLOR,clrRed);
      return OP_SELL;
   }else if(Bid > bottom && iClose(pair, PERIOD_M30, 2) < bottom && Bid < bottomL){
      ObjectCreate(ChartID(), name, OBJ_ARROW, 0, Time[0], Bid);
      ObjectSetInteger(ChartID(),name,OBJPROP_COLOR,clrAliceBlue);
      return OP_BUY;
   }
   
   return -1;
}
int KenkanKijunCross(string symbol, int timeframe, int shift){
   double kenkansen_curr = iIchimoku(symbol, timeframe, 9, 26, 52, 1, shift);
	double kijunsen_curr = iIchimoku(symbol, timeframe, 9, 26, 52, 2, shift);
	
	double kenkansen_prev = iIchimoku(symbol, timeframe, 9, 26, 52, 1, shift+1);
	double kijunsen_prev = iIchimoku(symbol, timeframe, 9, 26, 52, 2, shift+1);
	
	bool BuyCross = kenkansen_prev<=kijunsen_prev && kenkansen_curr>kijunsen_curr;
   bool SellCross = kenkansen_prev>=kijunsen_prev && kenkansen_curr<kijunsen_curr;
   
   string name = "KenkanKijunCross " + Time[0];
   
   if(BuyCross){
   	ObjectCreate(ChartID(), name, OBJ_ARROW, 0, Time[0], Bid);
      ObjectSetInteger(ChartID(),name,OBJPROP_COLOR,clrAliceBlue);
   	return OP_BUY;
   }
   
   if (SellCross) {
   	ObjectCreate(ChartID(), name, OBJ_ARROW_DOWN, 0, Time[0], Ask);
      ObjectSetInteger(ChartID(),name,OBJPROP_COLOR,clrRed);
   	return OP_SELL;
   }
   
   return -1;
}

double KenkanShortTermMomentum(string symbol, int timeframe, int shift){
	double kenkansen_curr = iIchimoku(symbol, timeframe, 9, 26, 52, 1, shift);
	//This would be positive if close is higher and negative if close is lower.
	return iClose(symbol, timeframe, shift) - kenkansen_curr;
}

double KenkanShortTermTrend(string symbol, int timeframe, int shift){
	double kenkansen_curr = iIchimoku(symbol, timeframe, 9, 26, 52, 1, shift);
	double kenkansen_prev = iIchimoku(symbol, timeframe, 9, 26, 52, 1, shift+1);
	return kenkansen_curr-kenkansen_prev;
}

double KijunMediumTermMomentum(string symbol, int timeframe, int shift){
	double kijunsen_curr = iIchimoku(symbol, timeframe, 9, 26, 52, 2, shift);
	return iClose(symbol, timeframe, shift) - kijunsen_curr;
}

int KijunTrailingStop(string symbol, int timeframe, int shift){
	return iIchimoku(symbol, timeframe, 9, 26, 52, 2, shift);
}

int ChikouSpanConfirmation(string symbol, int timeframe, int shift){
	double chikouspan_curr = iIchimoku(symbol, timeframe, 9, 26, 52, 5, shift);
	return chikouspan_curr - iClose(symbol, timeframe, shift+26);
}

//Only long when above, only short when below
int KumoCloudTrend(string symbol, int timeframe, int shift){
	double SenkouA = iIchimoku(symbol, timeframe, 9, 26, 52, 3, shift);
	double SenkouB = iIchimoku(symbol, timeframe, 9, 26, 52, 4, shift);
	double price = iClose(symbol, timeframe, shift);
	
	if(price > SenkouA && price > SenkouB){
		return OP_BUY;
	}
	
	if(price < SenkouA && price < SenkouB){
		return OP_SELL;
	}
	
	return -1;
}

double KumoCloud(string symbol, int timeframe, int shift){
	double SenkouA = iIchimoku(symbol, timeframe, 9, 26, 52, 3, shift);
	double SenkouB = iIchimoku(symbol, timeframe, 9, 26, 52, 4, shift);
	
	return SenkouA - SenkouB;
}
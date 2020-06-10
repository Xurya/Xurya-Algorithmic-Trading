//Fernando Carreiro ->

// Function to Determine Tick Point Value in Account Currency

double dblTickValue( string strSymbol ){
   return( MarketInfo( strSymbol, MODE_TICKVALUE ) );
}


// Function to Determine Pip Point Value in Account Currency

double dblPipValue( string strSymbol ){
   double dblCalcPipValue = dblTickValue( strSymbol );
   switch ( (int) MarketInfo( strSymbol, MODE_DIGITS ) ){
      case 3:
      case 5:
           dblCalcPipValue *= 10;
           break;
   }

   return( dblCalcPipValue );
}


// Calculate Lot Size based on Maximum Risk & Margin

double dblLotsRisk( string strSymbol, double dblStopLossPips, double dblRiskMaxPercent, double dblMarginMaxPercent, double dblLotsMin, double dblLotsMax, double dblLotsStep ){
       double dblValueAccount = MathMin( AccountEquity(), AccountBalance() );
       double  dblValueRisk = dblValueAccount * dblRiskMaxPercent / 100.0;
       double  dblValueMargin = AccountFreeMargin() * dblMarginMaxPercent / 100.0;
       double  dblLossOrder = dblStopLossPips * dblPipValue( strSymbol );
       double  dblMarginOrder = MarketInfo( strSymbol, MODE_MARGINREQUIRED );
       double  dblCalcLotMin = MathMax( dblLotsMin, MarketInfo( strSymbol, MODE_MINLOT ) );
       double  dblCalcLotMax = MathMin( dblLotsMax, MarketInfo( strSymbol, MODE_MAXLOT ) );
       double  dblModeLotStep = MarketInfo( strSymbol, MODE_LOTSTEP );
       double  dblCalcLotStep = MathCeil( dblLotsStep / dblModeLotStep ) * dblModeLotStep;
       double  dblCalcLotLoss = MathFloor( dblValueRisk / dblLossOrder / dblCalcLotStep ) * dblCalcLotStep; 
       double  dblCalcLotMargin = MathFloor( dblValueMargin / dblMarginOrder / dblCalcLotStep ) * dblCalcLotStep;
       double dblCalcLot = MathMin( dblCalcLotLoss, dblCalcLotMargin );
       
       if ( dblCalcLot < dblCalcLotMin ) dblCalcLot = dblCalcLotMin;
       if ( dblCalcLot > dblCalcLotMax ) dblCalcLot = dblCalcLotMax;

       return ( dblCalcLot );
}
//+------------------------------------------------------------------+
//|                                                        Rapid.mq4 |
//|                                                          Ryan Xu |
//|                                                                  |
//+------------------------------------------------------------------+
#property strict

#define MAGICMA 20000913

extern double      risk=0.005;
extern double      maxBalance = 0;
extern double      slatrScale=3.75;
extern int         squeezeBars=5750;

datetime LastTimeBar=0;

int ticket = -1;
string pair = NULL;
double unit_pip = 0;
double minLot = 0.01;
double maxLot = 1.00;
double stepLot = 0.01;
double lastLow = -1;
double lastHigh = -1;
int mode = -1;
int sl_pips = 20; //Temporary Value, this is based off of ATR

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
	//Grab Prelim Info
   pair = Symbol();
   minLot = MarketInfo(pair, MODE_MINLOT);
   maxLot = MarketInfo(pair, MODE_MAXLOT);
   stepLot = MarketInfo(pair, MODE_LOTSTEP);
   unit_pip = MathPow(0.1,Digits-1);
   //Check if there is an existing ticket for the symbol
   for(int i=0;i<OrdersTotal();i++){
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false){
         continue;
      }
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA && OrderCloseTime()==0){
         ticket=OrderTicket();
      }
   }
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {

}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
	if(iTime(Symbol(),0,0)!=LastTimeBar){
		LastTimeBar=iTime(pair,0,0);
      ticket = -1;
      
      //Check if there is an existing ticket for the symbol
      for(int i=0;i<OrdersTotal();i++){
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false){
            continue;
         }
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA && OrderCloseTime()==0){
            ticket=OrderTicket();
         }
      }
	
		if(ticket==-1){ 
         EntryAnalysis();
      }else{
         ExitAnalysis();
      }
	}   
}

void EntryAnalysis(){
	switch mode{
		case default:
			
	}
}

void ExitAnalysis(){

} 

/*
if((conversionLine > baseLine)) {
	      for(int c = 0; c < OrdersTotal(); c++) {
	         order = OrderSelect(c, SELECT_BY_POS);
	         if(OrderType() == OP_SELL){
	      		RefreshRates();
					orderclose = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Digits), 3, Red);
	         }
	      }
	      ticket = OrderSend(Symbol(),OP_BUY,LotSize,NormalizeDouble(Ask, Digits),3,0,0,NULL,1111,0,Green);
	   }else if((baseLine > conversionLine))) {
	      for(int c = 0; c < OrdersTotal(); c++) {
	         order = OrderSelect(c, SELECT_BY_POS);
	         if(OrderType() == OP_BUY) {
	         	RefreshRates();
	            orderclose = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits), 3, Green);
	         }
	      }
	      ticket = OrderSend(Symbol(),OP_SELL,LotSize,NormalizeDouble(Bid, Digits),3,0,0,NULL,2222,0,Red);
	   }
*/
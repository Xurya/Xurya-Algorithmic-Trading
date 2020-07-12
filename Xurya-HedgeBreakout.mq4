//+------------------------------------------------------------------+
//|                                               Xurya-Breakout.mq4 |
//|                                                          Ryan Xu |
//|                                                                  |
//+------------------------------------------------------------------+
#property strict

#define MAGICMA 20000912

//--- input parameters
input double      risk=0.01;
input string      file="";
input int         slatrScale=15;
input int         squeezeBars=500;

int ticketBUY = -1;
int ticketSELL = -1;
int maxBalance = -1;
string pair = NULL;
double unit_pip = 0;
datetime LastTimeBar=0;
double minLot = 0.01;
double maxLot = 1.00;
double stepLot = 0.01;
int mode = -1;
int sl_pips = 20; //Temporary Value, this is based off of ATR

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
   //Grab Balance info

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
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA && OrderType() == OP_BUY){
         ticketBUY = OrderTicket();
         break;
      }else if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA && OrderType() == OP_SELL){
         ticketSELL = OrderTicket();
         break;
      }
   }
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
   if(iTime(Symbol(),0,0)!=LastTimeBar){
      LastTimeBar=iTime(pair,0,0);
      ticketBUY=-1;
      ticketSELL=-1;
      
      //Check if there is an existing ticket for the symbol
      for(int i=0;i<OrdersTotal();i++){
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false){
            continue;
         }
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA && OrderType() == OP_BUY && OrderCloseTime()==0){
            ticketBUY = OrderTicket();
         }else if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA && OrderType() == OP_SELL && OrderCloseTime()==0){
            ticketSELL = OrderTicket();
         }
      }
      
      if(ticketBUY==-1 && ticketSELL==-1){
         EntryAnalysis();
      }else{
         ExitAnalysis();
      }
   }
}

void EntryAnalysis(){
   int squeezeSig = BollingerSqueezeSignal(squeezeBars);

   //Find Squeeze
   if(mode==-1){    
      if(squeezeSig>0){
         mode = 0;
      }
   }
   
   //Find end of squeeze
   if(mode == 0){
      if(squeezeSig==0){
         mode = 1;
      }
   }
   
   if(mode == 1){
      sl_pips = ATRStop(PERIOD_M30, 20, slatrScale) * MathPow(10, Digits-1);
      double lot_size = NormalizeDouble(MathMin(MathMax((risk*AccountBalance()/sl_pips)/dblPipValue(pair), minLot), maxLot),2);
      int steps = lot_size / stepLot;
      lot_size = MathMax(stepLot, steps * stepLot); //instead of MinLot since Oanda is a weird broker...
      
      //Check if we have money in the account
      if(AccountFreeMargin()<(1000*2*lot_size)){
         if(AccountFreeMargin()<(1000*2*minLot)){
            Print("Switching to MinLot");
            lot_size = minLot;
         }else{
            Print("Insufficient Funds. Free Margin = ",AccountFreeMargin() + " lot_size: " + lot_size);
            return;
         }
      }
      
      RefreshRates();
      ticketBUY=OrderSend(pair, OP_BUY, lot_size, NormalizeDouble(Ask, Digits), 10*unit_pip, Ask-sl_pips*unit_pip, 0, "Generated by Xurya Bot!",MAGICMA,0,clrLightGreen);
      RefreshRates();
      ticketSELL=OrderSend(pair, OP_SELL, lot_size, NormalizeDouble(Bid, Digits), 10*unit_pip, Bid+sl_pips*unit_pip, 0, "Generated by Xurya Bot!",MAGICMA,0,clrPurple);
      
      mode = -1;
   }
}


void ExitAnalysis(){
   int sig=-1;
   int bandSig = BollingerBandRange();
   int rsiCrossSig = RSICrossSignal();
   //heuristics
   if(bandSig == rsiCrossSig){
      sig = bandSig;
   }

   //Trailing Stop
   //------------------------------------------------------------------
   double trailing = ATRStop(PERIOD_M30, 20, 3);  
   
   //Buy
   if(ticketBUY!=-1 && OrderSelect(ticketBUY, SELECT_BY_TICKET) && OrderCloseTime()==0){
      double stpl = OrderStopLoss();
      double open_price = OrderOpenPrice();
   
      if(sig==OP_SELL && Bid>open_price+sl_pips*unit_pip){
         //Opposite Cross, this is a sell.
         Alert("Closing BUY " + ticketBUY);
         OrderClose(ticketBUY, OrderLots(), NormalizeDouble(Bid, Digits), 10*unit_pip, clrRed);
         
         ticketBUY == -1;
         EntryAnalysis();
         return;
      }
      
      //Check the absolute distance.
      if(High[1]>open_price+sl_pips*unit_pip){
         double difference = High[1]-stpl;
         if(difference>trailing){
            Alert("Trailing Stop Update " + ticketBUY);
            OrderModify(ticketBUY, OrderOpenPrice(), High[1]-trailing, 0, 0, clrDarkOrange); 
         }
      }
   }
   //Sell
   if(ticketSELL!=-1 && OrderSelect(ticketSELL, SELECT_BY_TICKET) && OrderCloseTime()==0){
      double stpl = OrderStopLoss();
      double open_price = OrderOpenPrice();
      
      if(sig==OP_BUY && Ask<open_price-sl_pips*unit_pip){
         //Opposite Cross, this is a buy.
         Alert("Closing SELL " + ticketSELL);
         OrderClose(ticketSELL, OrderLots(), NormalizeDouble(Ask, Digits), 10*unit_pip, clrRed);
         
         ticketSELL == -1;
         EntryAnalysis();
         return;
      }
      
      if(Low[1]<open_price-sl_pips*unit_pip){
         double difference = stpl-Low[1];
         if(difference>trailing){
            Alert("Trailing Stop Update " + ticketSELL);
            OrderModify(ticketSELL, OrderOpenPrice(), Low[1]+trailing, 0, 0, clrDarkOrange); 
         }
      }
   }
}
//+------------------------------------------------------------------+

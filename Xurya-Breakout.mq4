//+------------------------------------------------------------------+
//|                                               Xurya-Breakout.mq4 |
//|                                                          Ryan Xu |
//|                                                                  |
//+------------------------------------------------------------------+
#property strict

#define MAGICMA 20000912

//--- input parameters
input double      risk=0.005;
input double      maxBalance = 0;
input double      slatrScale=3;
input int         squeezeBars=500;

//int ticketBUY = -1; Hedging Banned
//int ticketSELL = -1; Hedging Banned
int ticket = -1;
string pair = NULL;
double unit_pip = 0;
datetime LastTimeBar=0;
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
int OnInit(){
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
         
      /* Hedging Banned
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA && OrderType() == OP_BUY && OrderCloseTime()==0){
         ticketBUY = OrderTicket();
      }else if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA && OrderType() == OP_SELL && OrderCloseTime()==0){
         ticketSELL = OrderTicket();
      }
      */
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
      //ticketBUY=-1; Hedging Banned
      //ticketSELL=-1; Hedging Banned
      ticket = -1;
      
      //Check if there is an existing ticket for the symbol
      for(int i=0;i<OrdersTotal();i++){
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false){
            continue;
         }
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA && OrderCloseTime()==0){
            ticket=OrderTicket();
         }
            
         /* Hedging Banned
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA && OrderType() == OP_BUY && OrderCloseTime()==0){
            ticketBUY = OrderTicket();
         }else if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA && OrderType() == OP_SELL && OrderCloseTime()==0){
            ticketSELL = OrderTicket();
         }
         */
      }
      
      if(ticket==-1){ //ticketBUY==-1 && ticketSELL==-1){ Hedging Banned
         EntryAnalysis();
      }else{
         ExitAnalysis();
      }
   }
}

void EntryAnalysis(){
   //Find Squeeze
   if(mode==-1){    
      int squeezeSig = BollingerSqueezeSignal(squeezeBars);
      if(squeezeSig>0){
         mode = 0; 
         //mode = 1; //Ignoring squeeze continuation state analysis
         sl_pips = ATRStop(PERIOD_M30, 20, slatrScale) * MathPow(10, Digits-1); //Dynamic SL based on squeeze
      }
   }
   
   //Find end of squeeze
   if(mode == 0){
      int squeezeSig = BollingerSqueezeSignal(squeezeBars);
      if(squeezeSig==0){
         mode = 1;
      }
   }
   
   if(mode == 1){
      double balance = AccountBalance();
      if(maxBalance > 0){
         balance = MathMin(balance, maxBalance);
      }
      //step lot used instead of MinLot since Oanda is a weird broker...
      double lot_size = NormalizeDouble(MathMin(MathMax((risk*balance/sl_pips)/dblPipValue(pair), stepLot), maxLot),2);
      int steps = lot_size / stepLot;
      lot_size = MathMax(stepLot, steps * stepLot); 
      
      //Check if we have money in the account
      if(AccountFreeMargin()<(1000*lot_size)){
         if(AccountFreeMargin()<(1000*minLot)){
            Print("Switching to MinLot");
            lot_size = minLot;
         }else{
            Print("Insufficient Funds. Free Margin = ",AccountFreeMargin() + " lot_size: " + lot_size);
            return;
         }
      }
      
      int sig = BollingerBandBreak();
      
      if(sig==OP_BUY){
         RefreshRates();
         ticket=OrderSend(pair, OP_BUY, lot_size, NormalizeDouble(Ask, Digits), 10*unit_pip, Ask-sl_pips*unit_pip, 0, "Generated by Xurya Bot!",MAGICMA,0,clrLightGreen);
         mode = -1;
      } else if(sig == OP_SELL){
         RefreshRates();  
         ticket=OrderSend(pair, OP_SELL, lot_size, NormalizeDouble(Bid, Digits), 10*unit_pip, Bid+sl_pips*unit_pip, 0, "Generated by Xurya Bot!",MAGICMA,0,clrPurple); 
         mode = -1;
      }
      
      
      
      /* Hedging Banned
      RefreshRates();
      ticketBUY=OrderSend(pair, OP_BUY, lot_size, NormalizeDouble(Ask, Digits), 10*unit_pip, Ask-sl_pips*unit_pip, 0, "Generated by Xurya Bot!",MAGICMA,0,clrLightGreen);
      RefreshRates();
      ticketSELL=OrderSend(pair, OP_SELL, lot_size, NormalizeDouble(Bid, Digits), 10*unit_pip, Bid+sl_pips*unit_pip, 0, "Generated by Xurya Bot!",MAGICMA,0,clrPurple);
      
      mode = -1;
      */
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
   double trailing = ATRStop(PERIOD_M30, 20, MathMax(1,slatrScale));  
   
   //Buy
   if(ticket!=-1 && OrderSelect(ticket, SELECT_BY_TICKET) && OrderType() == OP_BUY && OrderCloseTime() == 0 ){//ticketBUY!=-1 && OrderSelect(ticketBUY, SELECT_BY_TICKET) && OrderCloseTime()==0){
      double stpl = OrderStopLoss();
      double open_price = OrderOpenPrice();
   
      if(sig==OP_SELL && Bid>open_price+sl_pips*unit_pip){
         //Opposite Cross, this is a sell.
         /* Hedging Banned
         Alert("Closing BUY " + ticketBUY);
         OrderClose(ticketBUY, OrderLots(), NormalizeDouble(Bid, Digits), 10*unit_pip, clrRed);
         
         ticketBUY == -1;
         */
         
         Alert("Closing BUY " + ticket);
         OrderClose(ticket, OrderLots(), NormalizeDouble(Bid, Digits), 10*unit_pip, clrRed);
         
         ticket == -1;
         EntryAnalysis();
         return;
      }
      
      if(stpl<open_price && High[0]>open_price+sl_pips*unit_pip){
         OrderModify(ticket, OrderOpenPrice(), open_price+(sl_pips+1)*unit_pip, 0, 0, clrDarkOrange);  
      }
      
      //Check the absolute distance.
      if(High[1]>open_price+2*sl_pips*unit_pip+trailing){
         if(stpl < Low[0]+trailing){
            OrderModify(ticket, OrderOpenPrice(), High[0]-trailing, 0, 0, clrDarkOrange);
         }
      }
   }
   //Sell
   if(ticket!=-1 && OrderSelect(ticket, SELECT_BY_TICKET) && OrderType() == OP_SELL && OrderCloseTime() == 0 ){//ticketSELL!=-1 && OrderSelect(ticketSELL, SELECT_BY_TICKET) && OrderCloseTime()==0){
      double stpl = OrderStopLoss();
      double open_price = OrderOpenPrice();
      
      if(sig==OP_BUY && Ask<open_price-sl_pips*unit_pip){
         //Opposite Cross, this is a buy.
         /* Hedging Banned
         Alert("Closing SELL " + ticketSELL);
         OrderClose(ticketSELL, OrderLots(), NormalizeDouble(Ask, Digits), 10*unit_pip, clrRed);
         
         ticketSELL == -1;
         */
         
         Alert("Closing SELL " + ticket);
         OrderClose(ticket, OrderLots(), NormalizeDouble(Ask, Digits), 10*unit_pip, clrRed);
         
         ticket == -1;
         EntryAnalysis();
         return;
      }
      
      if(stpl>open_price && Low[0]<open_price-sl_pips*unit_pip){
         OrderModify(ticket, OrderOpenPrice(), open_price-(sl_pips+1)*unit_pip, 0, 0, clrDarkOrange); 
      }
      
      if(Low[0]<open_price-2*sl_pips*unit_pip-trailing){
         if(stpl > Low[0]+trailing){
            OrderModify(ticket, OrderOpenPrice(), Low[0]+trailing, 0, 0, clrDarkOrange); 
         }
      }
   }
}
//+------------------------------------------------------------------+

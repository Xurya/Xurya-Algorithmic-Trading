//+------------------------------------------------------------------+
//|                                               ConfigTestDemo.mq4 |
//|                                                          Ryan Xu |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Ryan Xu"
#property link      ""
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   double unit_pip = MathPow(0.1,Digits-1);
   OrderSend(Symbol(), OP_BUY, 0.01, NormalizeDouble(Ask, Digits), 0, Ask-5*unit_pip, 0, "Xurya InstaBuy Demo!");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                 ChartDeleter.mq4 |
//|                                                          Ryan Xu |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Ryan Xu"
#property link      ""
#property version   "1.00"
#property strict
void OnInit()
  {
//---
      for(long curr=ChartNext(ChartFirst());curr >= 0;curr=ChartNext(curr)){
         Print(curr);
         ChartClose(curr);
      }
      ChartClose(ChartID());
  }
//+------------------------------------------------------------------+

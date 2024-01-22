//+------------------------------------------------------------------+
//|                                           TimeRangeEA_Remake.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh> 
#include "InpConfig.mqh"
#include "GlobalVar.mqh"
#include "Helper.mqh"
#include "CustomFunct.mqh"
#include "CustomCriteria.mqh"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // check user inputs
   if(!CheckInputs()){return INIT_PARAMETERS_INCORRECT;}
   
   // set magicnumber
   trade.SetExpertMagicNumber(InpMagicNumber);
   
   //calculated new Range if inputs changed
   if(_UninitReason==REASON_PARAMETERS&&CountOpenPosition()==0){//no position open++
      CalculateRange();
   }
   // draw objects
   DrawObjects();
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // delete objects
   ObjectsDeleteAll(NULL,"Range");
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
  // Get current tick
  prevTick = lastTick;
  SymbolInfoTick(_Symbol,lastTick);
  
  // Range calculation
  if(lastTick.time>=Range.start_time&&lastTick.time<Range.end_time){
   // set flag
   Range.f_entry=true;
   // new high
   if(lastTick.ask>Range.high){
      Range.high=lastTick.ask;
      mid=(Range.high+Range.low)/2;
      DrawObjects();
   }
   // new low
   if(lastTick.bid<Range.low){
      Range.low=lastTick.bid;
      mid=(Range.high+Range.low)/2;
      DrawObjects();
   }
   double cp=(lastTick.ask+lastTick.bid)/2;
   
   //DrawObjects();
  }
  if(lastTick.time==Range.end_time){
      DrawObjects();
  }
  // close position
  if(InpRangeClose>=0&&lastTick.time>=Range.close_time){
   if(!ClosePositions()){return;}
  }
  //calculate new Range if ...
  if((InpRangeClose>=0&&lastTick.time>=Range.close_time)                      // close time reached
      ||(Range.f_high_breakout&&Range.f_low_breakout)                         // both breakout flags are true
      ||(Range.end_time==0)                                                   // Range not calculated yet
      ||((Range.end_time!=0&&lastTick.time>Range.end_time&&!Range.f_entry)   //there was a Range calculated but no tick inside
      &&CountOpenPosition()==0))
   {
      CalculateRange();
   }
   // check to reset high/low breakout flag
  checkPendingPosition();
  // check for breakouts
  CheckBreakouts();
  // update stop loss
  UpdateStopLoss();
  // check if on BIG SL Trailing Period
  CheckBIGSLTrailingPeriod();
}
//+------------------------------------------------------------------+
//| Expert Test function                                             |
//+------------------------------------------------------------------+
double OnTester()  
{
   double customPerformanceMetric;  
   
   if(InpCustomPerfCriterium == STANDARD_PROFIT_FACTOR)
   {
      customPerformanceMetric = TesterStatistics(STAT_PROFIT_FACTOR);
   }
   else if(InpCustomPerfCriterium == MODIFIED_PROFIT_FACTOR)
   {
      int numTrades = ModifiedProfitFactor(customPerformanceMetric);
      
      //IF NUMBER OF TRADES < 250 THEN NO STATISTICAL SIGNIFICANCE, SO DISREGARD RESULTS (PROBABLE THAT GOOD 
      //RESULTS CAUSED BY RANDOM CHANCE / LUCK, THAT WOULD NOT BE REPEATABLE IN FUTURE PERFORMANCE)
      if(numTrades < 250)
         customPerformanceMetric = 0.0;
   } 
   else if(InpCustomPerfCriterium == NO_CUSTOM_METRIC)
   {
      customPerformanceMetric = 0.0;
   }
   else
   {
      Print("Error: Custom Performance Criterium requested (", EnumToString(InpCustomPerfCriterium), ") not implemented in OnTester()");
      customPerformanceMetric = 0.0;
   }
   
   Print("Custom Perfromance Metric = ", DoubleToString(customPerformanceMetric, 3));
   
   return customPerformanceMetric;
}
//+------------------------------------------------------------------+

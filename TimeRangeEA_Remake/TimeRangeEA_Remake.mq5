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
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // check user inputs
   if(!CheckInputs()){return INIT_PARAMETERS_INCORRECT;}
   
   // set magicnumber
   trade.SetExpertMagicNumber(InpMagicNumber);
   
   //calculated new range if inputs changed
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
   ObjectsDeleteAll(NULL,"range");
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
  // Get current tick
  prevTick = lastTick;
  SymbolInfoTick(_Symbol,lastTick);
  
  // range calculation
  if(lastTick.time>=range.start_time&&lastTick.time<range.end_time){
   // set flag
   range.f_entry=true;
   // new high
   if(lastTick.ask>range.high){
      range.high=lastTick.ask;
      mid=(range.high+range.low)/2;
      DrawObjects();
   }
   // new low
   if(lastTick.bid<range.low){
      range.low=lastTick.bid;
      mid=(range.high+range.low)/2;
      DrawObjects();
   }
   double cp=(lastTick.ask+lastTick.bid)/2;
   
   range.lower=  mid+(cp-mid)*InpChangingRangeAmplifier/100       -(range.high-range.low)/2;
   range.upper=  mid+(cp-mid)*InpChangingRangeAmplifier/100       +(range.high-range.low)/2;
   //DrawObjects();
  }
  if(lastTick.time==range.end_time){
      DrawObjects();
  }
  // close position
  if(InpRangeClose>=0&&lastTick.time>=range.close_time){
   if(!ClosePositions()){return;}
  }
  //calculate new range if ...
  if((InpRangeClose>=0&&lastTick.time>=range.close_time)                      // close time reached
      ||(range.f_high_breakout&&range.f_low_breakout)                         // both breakout flags are true
      ||(range.end_time==0)                                                   // range not calculated yet
      ||((range.end_time!=0&&lastTick.time>range.end_time&&!range.f_entry)   //there was a range calculated but no tick inside
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

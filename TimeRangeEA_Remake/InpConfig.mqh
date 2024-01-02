//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input group "==== GENERAL INPUTS ===="
input long InpMagicNumber = 3613; // magic number

enum LOT_MODE_ENUM{
   LOT_MODE_FIXED,// fixed
   LOT_MODE_MONEY,// money
   LOT_MODE_PCT_ACCOUNT// % account
};
input LOT_MODE_ENUM InpLotMode=LOT_MODE_FIXED;// lot mode



input double InpLots=0.01; // risking __ lots / money / percent 
input int InpStopLoss=150; // with a stop loss of __% of the range (0=off)
input bool InpStopLossTrailing = true; // Traditional trailing stop loss is __
input double InpBIGSLTrailingVolume = 2.0; // With an addition scailing down SL by a factor of __ (negative for disable)
input int InpBIGSLTrailingPeriod = 60; // for every __ minutes.
input int InpTakeProfit=300; // If feeling unsafe, create take profit of __% of the range (0=off)

input group "==== RANGE INPUTS ===="
input int InpRangeStart=600; // range start time in minutes
input int InpRangeDuration=120; // range duration in minutes
input int InpRangeClose=1200; //range close time in minutes (-1=off)
input int InpRangeSizeFilter=500; //range size filter in points (0=off)
input bool InpRevertOpenRangeSize=false; // reverting open if size > size filter?
input bool InpChangingRange=true; // changing range's upper and lower respect to currPrice?
input int InpChangingRangeAmplifier=100; //(0=off)change by how much % of diff of currPrice to mid

enum  BREAKOUT_MODE_ENUM{
   ONE_SIGNAL, // one breakout per range
   TWO_SIGNALS // high and low breakout
};
input BREAKOUT_MODE_ENUM InpBreakoutMode = ONE_SIGNAL; // breakout mode

input group "==== DAY OF WEEK FILTER ===="
input bool InpMonday=true; // range on Monday
input bool InpTuesday=true; // range on Tuesday
input bool InpWednesday=true; // range on Wednesday
input bool InpThursday=true; // range on Thursday
input bool InpFriday=true; // range on Friday
input bool InpSaturday=true; // range on Saturday
input bool InpSunday=true; // range on Sunday

bool CheckInputs(){
   if(InpMagicNumber<=0){
      Alert("Magic number <= 0");
      return false;
   }
   if(InpLotMode==LOT_MODE_FIXED&&InpLots<=0){
      Alert("Lots <= 0");
      return false;
   }
   if(InpLotMode==LOT_MODE_MONEY&&InpLots<=0){
      Alert("Lots <= 0");
      return false;
   } 
   if(InpLotMode==LOT_MODE_PCT_ACCOUNT&&InpLots<=0){
      Alert("Lots <= 0");
      return false;
   } 
   if((InpLotMode==LOT_MODE_PCT_ACCOUNT||InpLotMode==LOT_MODE_MONEY)&&InpStopLoss==0){
      Alert("Selected lot mode needs a stop loss");
      return false;
   } 
   if(InpStopLoss<0){
      Alert("Stop loss < 0");
      return false;
   } 
   if(InpTakeProfit<0){
      Alert("Take profit < 0");
      return false;
   } 
   if(InpRangeClose<0&&InpStopLoss==0){
      Alert("Close time and stop loss is off");
      return false;
   } 
   if(InpRangeStart<0||InpRangeStart>=1440){
      Alert("Range start < 0 or >= 1440");
      return false;
   } 
   if(InpRangeDuration<=0||InpRangeDuration>=1440){
      Alert("Range Duration <= 0 or >= 1440");
      return false;
   } 
   if(InpRangeClose>=1440||(InpRangeStart+InpRangeDuration)%1440==InpRangeClose){
      Alert("Close time >=1440 or end time == close time");
      return false;
   } 
   
   if(InpMonday+InpTuesday+InpWednesday+InpThursday+InpFriday==0){
      Alert("Range is prohibited on all days oh the week");
      return false;
   }
   
   if(InpBIGSLTrailingPeriod<=0){
      Alert("Scailing down sl period is <= 0");
      return false;
   }
   if(InpRangeSizeFilter<0){
      Alert("Range Size Filter <0");
      return false;
   }
   if(InpChangingRangeAmplifier<0){
      Alert("InpChangingRangeAmplifier<0");
   }
   return true;
}
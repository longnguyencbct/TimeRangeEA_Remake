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
enum ENUM_CUSTOM_PERF_CRITERIUM_METHOD
{
   NO_CUSTOM_METRIC,                            //No Custom Metric
   STANDARD_PROFIT_FACTOR,                      //Standard Profit Factor
   MODIFIED_PROFIT_FACTOR                       //Modified Profit Factor
};
enum ENUM_DIAGNOSTIC_LOGGING_LEVEL
{
   DIAG_LOGGING_NONE,                           //NONE
   DIAG_LOGGING_LOW,                            //LOW - Major Diagnostics Only
   DIAG_LOGGING_HIGH                            //HIGH - All Diagnostics (Warning - Use with caution)
};
input LOT_MODE_ENUM InpLotMode=LOT_MODE_FIXED;// lot mode



input double InpLots=0.01; // risking __ lots / money / percent 
input int InpStopLoss=150; // with a stop loss of __% of the Range (0=off)
input bool InpStopLossTrailing = true; // Traditional trailing stop loss is __
input double InpBIGSLTrailingVolume = 2.0; // With an addition scailing down SL by a factor of __ (negative for disable)
input int InpBIGSLTrailingPeriod = 60; // for every __ minutes.
input int InpTakeProfit=300; // If feeling unsafe, create take profit of __% of the Range (0=off)
input group "=== Custom Criteria ==="
input ENUM_CUSTOM_PERF_CRITERIUM_METHOD   InpCustomPerfCriterium    = MODIFIED_PROFIT_FACTOR;   //Custom Performance Criterium
input ENUM_DIAGNOSTIC_LOGGING_LEVEL       InpDiagnosticLoggingLevel = DIAG_LOGGING_LOW;         //Diagnostic Logging Level
input group "==== Range INPUTS ===="
input int InpRangeStart=600; // Range start time in minutes
input int InpRangeDuration=120; // Range duration in minutes
input int InpRangeClose=1200; //Range close time in minutes (-1=off)
input int InpRangeSizeFilter=500; //Range size filter in points (0=off)
input bool InpRevertOpenRangeSize=false; // reverting open if size > size filter?

enum  BREAKOUT_MODE_ENUM{
   ONE_SIGNAL, // one breakout per Range
   TWO_SIGNALS // high and low breakout
};
input BREAKOUT_MODE_ENUM InpBreakoutMode = ONE_SIGNAL; // breakout mode


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
   
   
   if(InpBIGSLTrailingPeriod<=0){
      Alert("Scailing down sl period is <= 0");
      return false;
   }
   if(InpRangeSizeFilter<0){
      Alert("Range Size Filter <0");
      return false;
   }
   return true;
}
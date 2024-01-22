//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
struct   RANGE_STRUCT{
   datetime start_time; //start of the Range
   datetime end_time; // end of the Range
   datetime close_time; // close time
   double high; //high of the Range
   double low; // low of the Range
   bool f_entry; // flag if we are inside the Range
   bool f_high_breakout; // flag if a high breakout occured 
   bool f_low_breakout; // flag if a low breakout occured 
   
   RANGE_STRUCT():
   start_time(0),
   end_time(0),
   close_time(0),
   high(0),
   low(DBL_MAX),
   f_entry(false),
   f_high_breakout(false),
   f_low_breakout(false)
   {};
};

RANGE_STRUCT Range;
MqlTick prevTick, lastTick;
CTrade trade;
int currentBuyMinutes;
int currentSellMinutes;
double mid;


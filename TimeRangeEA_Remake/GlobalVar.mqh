//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
struct   RANGE_STRUCT{
   datetime start_time; //start of the range
   datetime end_time; // end of the range
   datetime close_time; // close time
   double high; //high of the range
   double upper; //upper of the range
   double low; // low of the range
   double lower; // lower of the range
   bool f_entry; // flag if we are inside the range
   bool f_high_breakout; // flag if a high breakout occured 
   bool f_low_breakout; // flag if a low breakout occured 
   
   RANGE_STRUCT():
   start_time(0),
   end_time(0),
   close_time(0),
   high(0),
   upper(0),
   low(DBL_MAX),
   lower(DBL_MAX),
   f_entry(false),
   f_high_breakout(false),
   f_low_breakout(false)
   {};
};

RANGE_STRUCT range;
MqlTick prevTick, lastTick;
CTrade trade;
int currentBuyMinutes;
int currentSellMinutes;
double mid;


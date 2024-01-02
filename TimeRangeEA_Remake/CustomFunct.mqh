//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+

// calculate a new range
void CalculateRange(){
   // reset range variables
   range.start_time=0;
   range.end_time=0;
   range.close_time=0;
   range.high=0.0;
   range.upper=0.0;
   range.low=DBL_MAX;
   range.lower=DBL_MAX;
   range.f_entry=false;
   range.f_high_breakout=false;
   range.f_low_breakout=false;
   
   // calculate range start time
   int time_cycle = 86400;
   range.start_time = (lastTick.time - (lastTick.time%time_cycle))+InpRangeStart*60;
   for(int i=0;i<8;i++){
      MqlDateTime tmp;
      TimeToStruct(range.start_time,tmp);
      int dow = tmp.day_of_week;
      if(lastTick.time>=range.start_time||(dow==6&&!InpSaturday)||(dow==0&&!InpSunday)||(dow==1&&!InpMonday)||(dow==2&&!InpTuesday)||(dow==3&&!InpWednesday)||(dow==4&&!InpThursday)||(dow==5&&!InpFriday)){
         range.start_time+=time_cycle;
      }
   }
   // calculate range end time
   range.end_time = range.start_time+InpRangeDuration*60;
   for(int i=0;i<2;i++){
      MqlDateTime tmp;
      TimeToStruct(range.end_time,tmp);
      int dow=tmp.day_of_week;
      if(dow==6||dow==0){
      range.end_time+=time_cycle;
      }
   }
   // calculate range close
   if(InpRangeClose>=0){
      range.close_time = (range.end_time - (range.end_time%time_cycle))+InpRangeClose*60;
      for(int i=0;i<3;i++){
         MqlDateTime tmp;
         TimeToStruct(range.close_time,tmp);
         int dow = tmp.day_of_week;
         if(range.close_time<=range.end_time||dow==6||dow==0){
            range.close_time+=time_cycle;
         }
      }
   }
   // draw objects
   DrawObjects();
}

void DrawObjects(){
   // start time
   ObjectDelete(NULL,"range start");
   if(range.start_time>0){
      ObjectCreate(NULL,"range start",OBJ_VLINE,0,range.start_time,0);
      ObjectSetString(NULL,"range start",OBJPROP_TOOLTIP,"start of the range \n"+TimeToString(range.start_time,TIME_DATE|TIME_MINUTES));
      ObjectSetInteger(NULL,"range start",OBJPROP_COLOR,clrBlue);
      ObjectSetInteger(NULL,"range start",OBJPROP_WIDTH,2);
      ObjectSetInteger(NULL,"range start",OBJPROP_BACK,true);
   }
   // end time
   ObjectDelete(NULL,"range end");
   if(range.end_time>0){
      ObjectCreate(NULL,"range end",OBJ_VLINE,0,range.end_time,0);
      ObjectSetString(NULL,"range end",OBJPROP_TOOLTIP,"end of the range \n"+TimeToString(range.end_time,TIME_DATE|TIME_MINUTES));
      ObjectSetInteger(NULL,"range end",OBJPROP_COLOR,clrDarkBlue);
      ObjectSetInteger(NULL,"range end",OBJPROP_WIDTH,2);
      ObjectSetInteger(NULL,"range end",OBJPROP_BACK,true);
   }
   // close time
   ObjectDelete(NULL,"range close");
   if(range.close_time>0){
      ObjectCreate(NULL,"range close",OBJ_VLINE,0,range.close_time,0);
      ObjectSetString(NULL,"range close",OBJPROP_TOOLTIP,"close of the range \n"+TimeToString(range.close_time,TIME_DATE|TIME_MINUTES));
      ObjectSetInteger(NULL,"range close",OBJPROP_COLOR,clrRed);
      ObjectSetInteger(NULL,"range close",OBJPROP_WIDTH,2);
      ObjectSetInteger(NULL,"range close",OBJPROP_BACK,true);
   }
   // high
   ObjectDelete(NULL,"range high");
   if(range.high>0){
      ObjectCreate(NULL,"range high",OBJ_TREND,0,range.start_time,range.high,range.end_time,range.high);
      ObjectSetString(NULL,"range high",OBJPROP_TOOLTIP,"high of the range \n"+DoubleToString(range.high,_Digits));
      ObjectSetInteger(NULL,"range high",OBJPROP_COLOR,RangeSizeFilter()?clrBlue:clrRed);
      ObjectSetInteger(NULL,"range high",OBJPROP_WIDTH,2);
      ObjectSetInteger(NULL,"range high",OBJPROP_BACK,true);
      
      ObjectDelete(NULL,"range high ");
      ObjectCreate(NULL,"range high ",OBJ_TREND,0,range.end_time,range.high,InpRangeClose>=0?range.close_time:INT_MAX,range.high);
      ObjectSetString(NULL,"range high ",OBJPROP_TOOLTIP,"high of the range \n"+DoubleToString(range.high,_Digits));
      ObjectSetInteger(NULL,"range high ",OBJPROP_COLOR,RangeSizeFilter()?clrBlue:clrRed);
      ObjectSetInteger(NULL,"range high ",OBJPROP_BACK,true);
      ObjectSetInteger(NULL,"range high ",OBJPROP_STYLE,STYLE_DOT);
   }
   // upper
   ObjectDelete(NULL,"range upper");
   if(range.upper>0&&InpChangingRange){
      ObjectCreate(NULL,"range upper",OBJ_TREND,0,range.start_time,range.upper,range.end_time,range.upper);
      ObjectSetString(NULL,"range upper",OBJPROP_TOOLTIP,"upper of the range \n"+DoubleToString(range.upper,_Digits));
      ObjectSetInteger(NULL,"range upper",OBJPROP_COLOR,RangeSizeFilter()?clrCyan:clrRed);
      ObjectSetInteger(NULL,"range upper",OBJPROP_WIDTH,2);
      ObjectSetInteger(NULL,"range upper",OBJPROP_BACK,true);
      
      ObjectDelete(NULL,"range upper ");
      ObjectCreate(NULL,"range upper ",OBJ_TREND,0,range.end_time,range.upper,InpRangeClose>=0?range.close_time:INT_MAX,range.upper);
      ObjectSetString(NULL,"range upper ",OBJPROP_TOOLTIP,"upper of the range \n"+DoubleToString(range.upper,_Digits));
      ObjectSetInteger(NULL,"range upper ",OBJPROP_COLOR,RangeSizeFilter()?clrCyan:clrRed);
      ObjectSetInteger(NULL,"range upper ",OBJPROP_BACK,true);
      ObjectSetInteger(NULL,"range upper ",OBJPROP_STYLE,STYLE_DOT);
   }
   // low
   ObjectDelete(NULL,"range low");
   if(range.low<DBL_MAX){
      ObjectCreate(NULL,"range low",OBJ_TREND,0,range.start_time,range.low,range.end_time,range.low);
      ObjectSetString(NULL,"range low",OBJPROP_TOOLTIP,"low of the range \n"+DoubleToString(range.low,_Digits));
      ObjectSetInteger(NULL,"range low",OBJPROP_COLOR,RangeSizeFilter()?clrBlue:clrRed);
      ObjectSetInteger(NULL,"range low",OBJPROP_WIDTH,2);
      ObjectSetInteger(NULL,"range low",OBJPROP_BACK,true);
      
      ObjectDelete(NULL,"range low ");
      ObjectCreate(NULL,"range low ",OBJ_TREND,0,range.end_time,range.low,InpRangeClose>=0?range.close_time:INT_MAX,range.low);
      ObjectSetString(NULL,"range low ",OBJPROP_TOOLTIP,"low of the range \n"+DoubleToString(range.low,_Digits));
      ObjectSetInteger(NULL,"range low ",OBJPROP_COLOR,RangeSizeFilter()?clrBlue:clrRed);
      ObjectSetInteger(NULL,"range low ",OBJPROP_BACK,true);
      ObjectSetInteger(NULL,"range low ",OBJPROP_STYLE,STYLE_DOT);
   }
   // lower
   ObjectDelete(NULL,"range lower");
   if(range.lower<DBL_MAX&&InpChangingRange){
      ObjectCreate(NULL,"range lower",OBJ_TREND,0,range.start_time,range.lower,range.end_time,range.lower);
      ObjectSetString(NULL,"range lower",OBJPROP_TOOLTIP,"lower of the range \n"+DoubleToString(range.lower,_Digits));
      ObjectSetInteger(NULL,"range lower",OBJPROP_COLOR,RangeSizeFilter()?clrCyan:clrRed);
      ObjectSetInteger(NULL,"range lower",OBJPROP_WIDTH,2);
      ObjectSetInteger(NULL,"range lower",OBJPROP_BACK,true);
      
      ObjectDelete(NULL,"range lower ");
      ObjectCreate(NULL,"range lower ",OBJ_TREND,0,range.end_time,range.lower,InpRangeClose>=0?range.close_time:INT_MAX,range.lower);
      ObjectSetString(NULL,"range lower ",OBJPROP_TOOLTIP,"lower of the range \n"+DoubleToString(range.lower,_Digits));
      ObjectSetInteger(NULL,"range lower ",OBJPROP_COLOR,RangeSizeFilter()?clrCyan:clrRed);
      ObjectSetInteger(NULL,"range lower ",OBJPROP_BACK,true);
      ObjectSetInteger(NULL,"range lower ",OBJPROP_STYLE,STYLE_DOT);
   }
   // refress chart
   ChartRedraw();


}

void CheckBreakouts(){
   // check if we are after the range end
   if(lastTick.time >=range.end_time&&range.end_time>0&&range.f_entry){
      // check for high breakout
      if(!range.f_high_breakout&&
            (
               (lastTick.ask>=range.upper&&prevTick.ask<range.upper&&InpChangingRange)||
               (lastTick.ask>=range.high&&prevTick.ask<range.high&&!InpChangingRange)
            )
        ){
         range.f_high_breakout=true;
         if(InpBreakoutMode==ONE_SIGNAL){range.f_low_breakout=true;}
         if(!RangeSizeFilter()){// if size is big, revert open
            if(!InpRevertOpenRangeSize){return;}
            if(CountSellPosition()>0){return;}
            // calculate sl tp
            double sl= InpStopLoss==0?0:NormalizeDouble(lastTick.ask + (range.high-range.low)*InpStopLoss*0.01,_Digits);
            double tp= InpTakeProfit==0?0:NormalizeDouble(lastTick.ask - (range.high-range.low)*InpTakeProfit*0.01,_Digits);
            
            //calculate lots
            double lots;
            if(!CalculateLots(sl-lastTick.ask,lots)){return;}
            
            // open a sell position
            trade.PositionOpen(_Symbol,ORDER_TYPE_SELL,lots,lastTick.bid,sl,tp,"Time range EA");
            currentSellMinutes=0;
         }
         else{
            if(CountBuyPosition()>0){return;}
            // calculate sl tp
            double sl= InpStopLoss==0?0:NormalizeDouble(lastTick.bid - (range.high-range.low)*InpStopLoss*0.01,_Digits);
            double tp= InpTakeProfit==0?0:NormalizeDouble(lastTick.bid + (range.high-range.low)*InpTakeProfit*0.01,_Digits);
            
            
            //calculate lots
            double lots;
            if(!CalculateLots(lastTick.bid-sl,lots)){return;}
            
            // open a buy position
            trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,lots,lastTick.ask,sl,tp,"Time range EA");
            currentBuyMinutes=0;
         }
      }
      // check for low breakout
      if(!range.f_low_breakout&&
            (
               (lastTick.bid<=range.lower&&prevTick.bid>range.lower&&InpChangingRange)||
               (lastTick.bid<=range.low&&prevTick.bid>range.low&&!InpChangingRange)
            )
        ){
         range.f_low_breakout=true;
         if(InpBreakoutMode==ONE_SIGNAL){range.f_high_breakout=true;}
         if(!RangeSizeFilter()){
            if(!InpRevertOpenRangeSize){return;}
            if(CountBuyPosition()>0){return;}
            // calculate sl tp
            double sl= InpStopLoss==0?0:NormalizeDouble(lastTick.bid - (range.high-range.low)*InpStopLoss*0.01,_Digits);
            double tp= InpTakeProfit==0?0:NormalizeDouble(lastTick.bid + (range.high-range.low)*InpTakeProfit*0.01,_Digits);
            
            
            //calculate lots
            double lots;
            if(!CalculateLots(lastTick.bid-sl,lots)){return;}
            
            // open a buy position
            trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,lots,lastTick.ask,sl,tp,"Time range EA");
            currentBuyMinutes=0;
         }else{
            if(CountSellPosition()>0){return;}
            // calculate sl tp
            double sl= InpStopLoss==0?0:NormalizeDouble(lastTick.ask + (range.high-range.low)*InpStopLoss*0.01,_Digits);
            double tp= InpTakeProfit==0?0:NormalizeDouble(lastTick.ask - (range.high-range.low)*InpTakeProfit*0.01,_Digits);
            
            //calculate lots
            double lots;
            if(!CalculateLots(sl-lastTick.ask,lots)){return;}
            
            // open a sell position
            trade.PositionOpen(_Symbol,ORDER_TYPE_SELL,lots,lastTick.bid,sl,tp,"Time range EA");
            currentSellMinutes=0;
         }
      }
   }
}

bool RangeSizeFilter(){
   if(InpRangeSizeFilter>0&&(range.high-range.low)>InpRangeSizeFilter*_Point){
      return false;
   }
   return true;
}
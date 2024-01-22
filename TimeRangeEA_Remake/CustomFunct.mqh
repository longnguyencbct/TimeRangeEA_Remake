//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+

// calculate a new Range
void CalculateRange(){
   // reset Range variables
   Range.start_time=0;
   Range.end_time=0;
   Range.close_time=0;
   Range.high=0.0;
   Range.low=DBL_MAX;
   Range.f_entry=false;
   Range.f_high_breakout=false;
   Range.f_low_breakout=false;
   
   // calculate Range start time
   int time_cycle = 86400;
   Range.start_time = (lastTick.time - (lastTick.time%time_cycle))+InpRangeStart*60;
   for(int i=0;i<8;i++){
      MqlDateTime tmp;
      TimeToStruct(Range.start_time,tmp);
      int dow = tmp.day_of_week;
      if(lastTick.time>=Range.start_time){
         Range.start_time+=time_cycle;
      }
   }
   // calculate Range end time
   Range.end_time = Range.start_time+InpRangeDuration*60;
   for(int i=0;i<2;i++){
      MqlDateTime tmp;
      TimeToStruct(Range.end_time,tmp);
      int dow=tmp.day_of_week;
      if(dow==6||dow==0){
      Range.end_time+=time_cycle;
      }
   }
   // calculate Range close
   if(InpRangeClose>=0){
      Range.close_time = (Range.end_time - (Range.end_time%time_cycle))+InpRangeClose*60;
      for(int i=0;i<3;i++){
         MqlDateTime tmp;
         TimeToStruct(Range.close_time,tmp);
         int dow = tmp.day_of_week;
         if(Range.close_time<=Range.end_time||dow==6||dow==0){
            Range.close_time+=time_cycle;
         }
      }
   }
   // draw objects
   DrawObjects();
}

void DrawObjects(){
   // start time
   ObjectDelete(NULL,"Range start");
   if(Range.start_time>0){
      ObjectCreate(NULL,"Range start",OBJ_VLINE,0,Range.start_time,0);
      ObjectSetString(NULL,"Range start",OBJPROP_TOOLTIP,"start of the Range \n"+TimeToString(Range.start_time,TIME_DATE|TIME_MINUTES));
      ObjectSetInteger(NULL,"Range start",OBJPROP_COLOR,clrBlue);
      ObjectSetInteger(NULL,"Range start",OBJPROP_WIDTH,2);
      ObjectSetInteger(NULL,"Range start",OBJPROP_BACK,true);
   }
   // end time
   ObjectDelete(NULL,"Range end");
   if(Range.end_time>0){
      ObjectCreate(NULL,"Range end",OBJ_VLINE,0,Range.end_time,0);
      ObjectSetString(NULL,"Range end",OBJPROP_TOOLTIP,"end of the Range \n"+TimeToString(Range.end_time,TIME_DATE|TIME_MINUTES));
      ObjectSetInteger(NULL,"Range end",OBJPROP_COLOR,clrDarkBlue);
      ObjectSetInteger(NULL,"Range end",OBJPROP_WIDTH,2);
      ObjectSetInteger(NULL,"Range end",OBJPROP_BACK,true);
   }
   // close time
   ObjectDelete(NULL,"Range close");
   if(Range.close_time>0){
      ObjectCreate(NULL,"Range close",OBJ_VLINE,0,Range.close_time,0);
      ObjectSetString(NULL,"Range close",OBJPROP_TOOLTIP,"close of the Range \n"+TimeToString(Range.close_time,TIME_DATE|TIME_MINUTES));
      ObjectSetInteger(NULL,"Range close",OBJPROP_COLOR,clrRed);
      ObjectSetInteger(NULL,"Range close",OBJPROP_WIDTH,2);
      ObjectSetInteger(NULL,"Range close",OBJPROP_BACK,true);
   }
   // high
   ObjectDelete(NULL,"Range high");
   if(Range.high>0){
      ObjectCreate(NULL,"Range high",OBJ_TREND,0,Range.start_time,Range.high,Range.end_time,Range.high);
      ObjectSetString(NULL,"Range high",OBJPROP_TOOLTIP,"high of the Range \n"+DoubleToString(Range.high,_Digits));
      ObjectSetInteger(NULL,"Range high",OBJPROP_COLOR,RangeSizeFilter()?clrBlue:clrRed);
      ObjectSetInteger(NULL,"Range high",OBJPROP_WIDTH,2);
      ObjectSetInteger(NULL,"Range high",OBJPROP_BACK,true);
      
      ObjectDelete(NULL,"Range high ");
      ObjectCreate(NULL,"Range high ",OBJ_TREND,0,Range.end_time,Range.high,InpRangeClose>=0?Range.close_time:INT_MAX,Range.high);
      ObjectSetString(NULL,"Range high ",OBJPROP_TOOLTIP,"high of the Range \n"+DoubleToString(Range.high,_Digits));
      ObjectSetInteger(NULL,"Range high ",OBJPROP_COLOR,RangeSizeFilter()?clrBlue:clrRed);
      ObjectSetInteger(NULL,"Range high ",OBJPROP_BACK,true);
      ObjectSetInteger(NULL,"Range high ",OBJPROP_STYLE,STYLE_DOT);
   }
   
   // low
   ObjectDelete(NULL,"Range low");
   if(Range.low<DBL_MAX){
      ObjectCreate(NULL,"Range low",OBJ_TREND,0,Range.start_time,Range.low,Range.end_time,Range.low);
      ObjectSetString(NULL,"Range low",OBJPROP_TOOLTIP,"low of the Range \n"+DoubleToString(Range.low,_Digits));
      ObjectSetInteger(NULL,"Range low",OBJPROP_COLOR,RangeSizeFilter()?clrBlue:clrRed);
      ObjectSetInteger(NULL,"Range low",OBJPROP_WIDTH,2);
      ObjectSetInteger(NULL,"Range low",OBJPROP_BACK,true);
      
      ObjectDelete(NULL,"Range low ");
      ObjectCreate(NULL,"Range low ",OBJ_TREND,0,Range.end_time,Range.low,InpRangeClose>=0?Range.close_time:INT_MAX,Range.low);
      ObjectSetString(NULL,"Range low ",OBJPROP_TOOLTIP,"low of the Range \n"+DoubleToString(Range.low,_Digits));
      ObjectSetInteger(NULL,"Range low ",OBJPROP_COLOR,RangeSizeFilter()?clrBlue:clrRed);
      ObjectSetInteger(NULL,"Range low ",OBJPROP_BACK,true);
      ObjectSetInteger(NULL,"Range low ",OBJPROP_STYLE,STYLE_DOT);
   }
   
   // refress chart
   ChartRedraw();


}

void CheckBreakouts(){
   // check if we are after the Range end
   if(lastTick.time >=Range.end_time&&Range.end_time>0&&Range.f_entry){
      // check for high breakout
      if(!Range.f_high_breakout&&
            (
               (lastTick.ask>=Range.high&&prevTick.ask<Range.high)
            )
        ){
         Range.f_high_breakout=true;
         if(InpBreakoutMode==ONE_SIGNAL){Range.f_low_breakout=true;}
         if(!RangeSizeFilter()){// if size is big, revert open
            if(!InpRevertOpenRangeSize){return;}
            if(CountSellPosition()>0){return;}
            // calculate sl tp
            double sl= InpStopLoss==0?0:NormalizeDouble(lastTick.ask + (Range.high-Range.low)*InpStopLoss*0.01,_Digits);
            double tp= InpTakeProfit==0?0:NormalizeDouble(lastTick.ask - (Range.high-Range.low)*InpTakeProfit*0.01,_Digits);
            
            //calculate lots
            double lots;
            if(!CalculateLots(sl-lastTick.ask,lots)){return;}
            
            // open a sell position
            trade.PositionOpen(_Symbol,ORDER_TYPE_SELL,lots,lastTick.bid,sl,tp,"Time Range EA");
            currentSellMinutes=0;
         }
         else{
            if(CountBuyPosition()>0){return;}
            // calculate sl tp
            double sl= InpStopLoss==0?0:NormalizeDouble(lastTick.bid - (Range.high-Range.low)*InpStopLoss*0.01,_Digits);
            double tp= InpTakeProfit==0?0:NormalizeDouble(lastTick.bid + (Range.high-Range.low)*InpTakeProfit*0.01,_Digits);
            
            
            //calculate lots
            double lots;
            if(!CalculateLots(lastTick.bid-sl,lots)){return;}
            
            // open a buy position
            trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,lots,lastTick.ask,sl,tp,"Time Range EA");
            currentBuyMinutes=0;
         }
      }
      // check for low breakout
      if(!Range.f_low_breakout&&
            (
               (lastTick.bid<=Range.low&&prevTick.bid>Range.low)
            )
        ){
         Range.f_low_breakout=true;
         if(InpBreakoutMode==ONE_SIGNAL){Range.f_high_breakout=true;}
         if(!RangeSizeFilter()){
            if(!InpRevertOpenRangeSize){return;}
            if(CountBuyPosition()>0){return;}
            // calculate sl tp
            double sl= InpStopLoss==0?0:NormalizeDouble(lastTick.bid - (Range.high-Range.low)*InpStopLoss*0.01,_Digits);
            double tp= InpTakeProfit==0?0:NormalizeDouble(lastTick.bid + (Range.high-Range.low)*InpTakeProfit*0.01,_Digits);
            
            
            //calculate lots
            double lots;
            if(!CalculateLots(lastTick.bid-sl,lots)){return;}
            
            // open a buy position
            trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,lots,lastTick.ask,sl,tp,"Time Range EA");
            currentBuyMinutes=0;
         }else{
            if(CountSellPosition()>0){return;}
            // calculate sl tp
            double sl= InpStopLoss==0?0:NormalizeDouble(lastTick.ask + (Range.high-Range.low)*InpStopLoss*0.01,_Digits);
            double tp= InpTakeProfit==0?0:NormalizeDouble(lastTick.ask - (Range.high-Range.low)*InpTakeProfit*0.01,_Digits);
            
            //calculate lots
            double lots;
            if(!CalculateLots(sl-lastTick.ask,lots)){return;}
            
            // open a sell position
            trade.PositionOpen(_Symbol,ORDER_TYPE_SELL,lots,lastTick.bid,sl,tp,"Time Range EA");
            currentSellMinutes=0;
         }
      }
   }
}

bool RangeSizeFilter(){
   if(InpRangeSizeFilter>0&&(Range.high-Range.low)>InpRangeSizeFilter*_Point){
      return false;
   }
   return true;
}
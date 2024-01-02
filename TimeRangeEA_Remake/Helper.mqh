//+------------------------------------------------------------------+
//| Helper functions                                                 |
//+------------------------------------------------------------------+

// update stop loss
void UpdateStopLoss(){
   //return if no SL or fixed stop loss
   if(InpStopLoss==0||!InpStopLossTrailing){return;}
   //loop through open positions
   int total= PositionsTotal();
   for(int i=total-1;i>=0;i--){
      ulong ticket=PositionGetTicket(i);
      if(ticket<=0){Print("Failed to get position ticket"); return;}
      if(!PositionSelectByTicket(ticket)){Print("Failed to select position by ticket"); return;}
      ulong magic;
      if(!PositionGetInteger(POSITION_MAGIC,magic)){Print("Failed to get magic"); return;}
      if(magic==InpMagicNumber){
         //get type
         long type;
         if(!PositionGetInteger(POSITION_TYPE,type)){Print("Failed to get position type");return;}
         //get current sl and tp
         double currSL,currTP;
         if(!PositionGetDouble(POSITION_SL,currSL)){Print("Failed to get position stop loss");return;}
         if(!PositionGetDouble(POSITION_TP,currTP)){Print("Failed to get position take profit");return;}
         //calculate stop loss
         double currPrice=type==POSITION_TYPE_BUY?lastTick.bid:lastTick.ask;
         int n           =type==POSITION_TYPE_BUY?1:-1;
         double newSL = NormalizeDouble(currPrice-((Range.high-Range.low)*InpStopLoss*0.01*n),_Digits);
         
         //check if new stop loss is closer to current price than existing stop loss
         if((newSL*n)<(currSL*n)||NormalizeDouble(MathAbs(newSL-currSL),_Digits)<_Point){
            //Print("No new stop loss needed");
            continue;
         }
         //check for stop level
         long level = SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
         if(level!=0&&MathAbs(currPrice-newSL)<=level*_Point){
            //Print("New stop loss inside stop level");
            continue;
         }
         
         // modify position with new stop loss
         if(!trade.PositionModify(ticket,newSL,currTP)){
            Print("Failed to modify position, ticket:",(string)ticket,", currSL:",(string)currSL,
            ", newSL:",(string)newSL,", currTP:",(string)currTP);
            return;
         }
      }
   }
}

//Calculate lots
bool CalculateLots(double slDistance, double &lots){
   lots=0.0;
   if(InpLotMode==LOT_MODE_FIXED){
      lots=InpLots;
   }
   else{
      double tickSize=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
      double tickValue=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
      double volumeStep=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
      
      double riskMoney = InpLotMode==LOT_MODE_MONEY?InpLots:AccountInfoDouble(ACCOUNT_EQUITY)*InpLots*0.01;
      double moneyVolumeStep=(slDistance/tickSize)*tickValue*volumeStep;
      
      lots=MathFloor(riskMoney/moneyVolumeStep)*volumeStep;
   }
   //check calculated lots
   if(!CheckLots(lots)){return false;}
   
   return true;
}
//check lots for min, max and step
bool CheckLots(double &lots){
   
   double min = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double max = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double step = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   
   if(lots<min){
      Print("Lot size will be set to the minimum allowable volume");
      lots=min;
      return true;
   }
   if(lots>max){
      Print("Lot size greater than and will be set to the maximum allowable volume. lots:",lots,", max:",max);
      lots=max;
      return true;
   }
   lots=(int)MathFloor(lots/step)*step;
   return  true;
}

bool ClosePositions(){
   int total = PositionsTotal();
   for(int i=total-1;i>=0;i--){
      if(total != PositionsTotal()){total=PositionsTotal();i=total;continue;}
      ulong ticket = PositionGetTicket(i); //Select postition
      if(ticket<=0){
         Print("Failed to get position ticket");
         return false;
      }
      if(!PositionSelectByTicket(ticket)){
         Print("Failed to select position by ticket");
         return false;
      }
      long magicnumber;
      if(!PositionGetInteger(POSITION_MAGIC,magicnumber)){
         Print("Failed to get position magicnumber");
         return false;
      }
      if(magicnumber==InpMagicNumber){
         trade.PositionClose(ticket);
         if(trade.ResultRetcode()!=TRADE_RETCODE_DONE){
            Print("Failed to close position, Result: "+(string)trade.ResultRetcode()+":"+trade.ResultRetcodeDescription());
            return false;
         }
      
      }
   }
   
   
   return true;
}
int CountOpenPosition(){
   int counter=0;
   int total = PositionsTotal();
   for(int i=total-1;i>=0;i--){
      ulong ticket = PositionGetTicket(i);
      if(ticket<=0){Print("Failed to get position ticket"); return -1;}
      if(!PositionSelectByTicket(ticket)){Print("Failed to select position by ticket"); return -1;}
      ulong magicnumber;
      if(!PositionGetInteger(POSITION_MAGIC,magicnumber)){Print("Failed to get position magicnumber"); return -1;}
      if(InpMagicNumber==magicnumber){counter++;}
   }
   
   
   return counter;
}
int CountBuyPosition(){
   int counter=0;
   int total = PositionsTotal();
   for(int i=total-1;i>=0;i--){
      ulong ticket = PositionGetTicket(i);
      if(ticket<=0){Print("Failed to get position ticket"); return -1;}
      if(!PositionSelectByTicket(ticket)){Print("Failed to select position by ticket"); return -1;}
      ulong magicnumber;
      if(!PositionGetInteger(POSITION_MAGIC,magicnumber)){Print("Failed to get position magicnumber"); return -1;}
      ulong type;
      if(!PositionGetInteger(POSITION_TYPE,type)){Print("Failed to get position type"); return -1;}
      if(InpMagicNumber==magicnumber&&type==POSITION_TYPE_BUY){counter++;}
   }
   
   
   return counter;
}
int CountSellPosition(){
   int counter=0;
   int total = PositionsTotal();
   for(int i=total-1;i>=0;i--){
      ulong ticket = PositionGetTicket(i);
      if(ticket<=0){Print("Failed to get position ticket"); return -1;}
      if(!PositionSelectByTicket(ticket)){Print("Failed to select position by ticket"); return -1;}
      ulong magicnumber;
      if(!PositionGetInteger(POSITION_MAGIC,magicnumber)){Print("Failed to get position magicnumber"); return -1;}
      ulong type;
      if(!PositionGetInteger(POSITION_TYPE,type)){Print("Failed to get position type"); return -1;}
      if(InpMagicNumber==magicnumber&&type==POSITION_TYPE_SELL){counter++;}
   }
   
   
   return counter;
}
void checkPendingPosition(){
   if(CountBuyPosition()<1&&Range.f_high_breakout){
      Range.f_high_breakout=false;
   }
   if(CountSellPosition()<1&&Range.f_low_breakout){
      Range.f_low_breakout=false;
   }
}


void CheckBIGSLTrailingPeriod(){
   if(InpBIGSLTrailingVolume<0){return;}
   if(!IsNewMinute()){return;}
   int total= PositionsTotal();
   for(int i=total-1;i>=0;i--){
      ulong ticket=PositionGetTicket(i);
      if(ticket<=0){Print("Failed to get position ticket"); return;}
      if(!PositionSelectByTicket(ticket)){Print("Failed to select position by ticket"); return;}
      ulong magic;
      if(!PositionGetInteger(POSITION_MAGIC,magic)){Print("Failed to get magic"); return;}
      if(magic==InpMagicNumber){
         //get type
         long type;
         if(!PositionGetInteger(POSITION_TYPE,type)){Print("Failed to get position type");return;}
         if(type==POSITION_TYPE_BUY){
            currentBuyMinutes++;
            if(ReachedBuyBIGSLTrailingPeriod()){
               UpdateBuyScailingStopLoss();
            }
         }
         else if(type==POSITION_TYPE_SELL){
            currentSellMinutes++;
            if(ReachedSellBIGSLTrailingPeriod()){
               UpdateSellScailingStopLoss();
            }
         }
      }
   }
}
bool IsNewMinute(){
   static datetime previousTime=0;
   datetime currentTime=iTime(_Symbol,PERIOD_M1,0);
   if(previousTime!=currentTime){
      previousTime=currentTime;
      return true;
   }
   return false;
}
bool ReachedBuyBIGSLTrailingPeriod(){
   if(currentBuyMinutes>=InpBIGSLTrailingPeriod){
      currentBuyMinutes=0;
      return true;
   }
   return false;
}
bool ReachedSellBIGSLTrailingPeriod(){
   if(currentSellMinutes>=InpBIGSLTrailingPeriod){
      currentSellMinutes=0;
      return true;
   }
   return false;
}
void UpdateBuyScailingStopLoss(){
   //return if BIG SLtrailing is disabled
   if(InpBIGSLTrailingVolume<0){return;}
   //loop through open positions
   int total= PositionsTotal();
   for(int i=total-1;i>=0;i--){
      ulong ticket=PositionGetTicket(i);
      if(ticket<=0){Print("Failed to get position ticket"); return;}
      if(!PositionSelectByTicket(ticket)){Print("Failed to select position by ticket"); return;}
      ulong magic;
      if(!PositionGetInteger(POSITION_MAGIC,magic)){Print("Failed to get magic"); return;}
      if(magic==InpMagicNumber){
         //get type
         long type;
         if(!PositionGetInteger(POSITION_TYPE,type)){Print("Failed to get position type");return;}
         if(type==POSITION_TYPE_SELL){continue;}
         //get current sl and tp
         double currSL,currTP;
         if(!PositionGetDouble(POSITION_SL,currSL)){Print("Failed to get position stop loss");return;}
         if(!PositionGetDouble(POSITION_TP,currTP)){Print("Failed to get position take profit");return;}
         //calculate stop loss
         double currPrice=type==POSITION_TYPE_BUY?lastTick.bid:lastTick.ask;
         int n           =type==POSITION_TYPE_BUY?1:-1;
         double newSL = NormalizeDouble(currPrice-(currPrice-currSL)/InpBIGSLTrailingVolume,_Digits);
         
         //check if new stop loss is closer to current price than existing stop loss
         if((newSL*n)<(currSL*n)||NormalizeDouble(MathAbs(newSL-currSL),_Digits)<_Point){
            //Print("No new stop loss needed");
            continue;
         }
         //check for stop level
         long level = SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
         if(level!=0&&MathAbs(currPrice-newSL)<=level*_Point){
            //Print("New stop loss inside stop level");
            continue;
         }
         
         // modify position with new stop loss
         if(!trade.PositionModify(ticket,newSL,currTP)){
            Print("Failed to modify position, ticket:",(string)ticket,", currSL:",(string)currSL,
            ", newSL:",(string)newSL,", currTP:",(string)currTP);
            return;
         }
      }
   }
}
void UpdateSellScailingStopLoss(){
   //return if BIG SLtrailing is disabled
   if(InpBIGSLTrailingVolume<0){return;}
   //loop through open positions
   int total= PositionsTotal();
   for(int i=total-1;i>=0;i--){
      ulong ticket=PositionGetTicket(i);
      if(ticket<=0){Print("Failed to get position ticket"); return;}
      if(!PositionSelectByTicket(ticket)){Print("Failed to select position by ticket"); return;}
      ulong magic;
      if(!PositionGetInteger(POSITION_MAGIC,magic)){Print("Failed to get magic"); return;}
      if(magic==InpMagicNumber){
         //get type
         long type;
         if(!PositionGetInteger(POSITION_TYPE,type)){Print("Failed to get position type");return;}
         if(type==POSITION_TYPE_BUY){continue;}
         //get current sl and tp
         double currSL,currTP;
         if(!PositionGetDouble(POSITION_SL,currSL)){Print("Failed to get position stop loss");return;}
         if(!PositionGetDouble(POSITION_TP,currTP)){Print("Failed to get position take profit");return;}
         //calculate stop loss
         double currPrice=type==POSITION_TYPE_BUY?lastTick.bid:lastTick.ask;
         int n           =type==POSITION_TYPE_BUY?1:-1;
         double newSL = NormalizeDouble(currPrice-(currPrice-currSL)/InpBIGSLTrailingVolume,_Digits);
         
         //check if new stop loss is closer to current price than existing stop loss
         if((newSL*n)<(currSL*n)||NormalizeDouble(MathAbs(newSL-currSL),_Digits)<_Point){
            //Print("No new stop loss needed");
            continue;
         }
         //check for stop level
         long level = SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
         if(level!=0&&MathAbs(currPrice-newSL)<=level*_Point){
            //Print("New stop loss inside stop level");
            continue;
         }
         
         // modify position with new stop loss
         if(!trade.PositionModify(ticket,newSL,currTP)){
            Print("Failed to modify position, ticket:",(string)ticket,", currSL:",(string)currSL,
            ", newSL:",(string)newSL,", currTP:",(string)currTP);
            return;
         }
      }
   }
}
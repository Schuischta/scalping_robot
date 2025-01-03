
#property copyright "Copyright 2024"
#property link      ""
#property version   "2.00"

#include <Trade/Trade.mqh>

CTrade            trade;
CPositionInfo     pos;
COrderInfo        ord;


   input group "=== Trading Profiles ==="
   
      enum SystemType{Forex=0, Bitcoin=1, _Gold=2, US_Indicies=3};
      input SystemType SType=0; // Trading System applied (Forex, Bitcoin, Gold, Indicies)
      int SysChoice;
   
   
   input group "===  Common Trading Inputs  ==="
   
         input double         RiskPercent                       = 3;   // Risk as % of Trading Capital
         input ENUM_TIMEFRAMES   Timeframe                      = PERIOD_CURRENT; // Timeframe to run
         input int            InpMagic                          = 1337; // Magic number
         input string         TradeComment                      = "Scalping Robot";
         enum StartHour {Inactive=0, _01=1, _02=2, _03=3, _04=4, _05=5, _06=6, _07=7, _08=8, _09=9, _10=10, _11=11, _12=12, _13=13, _14=14, _15=15, _16=16, _17=17, _18=18, _19=19, _20=20, _21=21, _22=22, _23=23};
         input StartHour SHInput = 0; // Start Hour
         
         enum EndHour {Inactive=0, _01=1, _02=2, _03=3, _04=4, _05=5, _06=6, _07=7, _08=8, _09=9, _10=10, _11=11, _12=12, _13=13, _14=14, _15=15, _16=16, _17=17, _18=18, _19=19, _20=20, _21=21, _22=22, _23=23};
         input EndHour EHInput = 0; // End Hour
         
         int SHChoice;
         int EHChoice;
         
         int         BarsN = 5;  // No. of Bars to identify High/Low
         int         ExpirationBars = 100;     
         double      OrderDistPoints = 100;  // No. of Bars before order is expired
         double      Tppoints, Slpoints, TslPoints, TslTriggerPoints;
         
         int          handleRSI, handleMovAvg;
         input color  ChartColorTradingOff = clrPink;  // Chart color when EA is inactive
         input color  ChartColorTradingOn  = clrBlack; // Chart color when EA is active
               bool   Tradingenabled       = true;
         input bool   HideIndicators       = true;     // Hide Indicators on Chart
               string TradingEnabledComm = "";
         
   
   input group "=== Forex Trading Inputs ==="
   
         
         input int            TppointsInput           = 200; // Take Profit (10 points = 1 pip)
         input int            SlpointsInput           = 200; // Stop Loss Points (10 points = 1 pip)
         input int            TslTriggerPointsInput   = 15;  // Trailing SL trigger (10 points = 1 pip)
         input int            TslPointsInput          = 10;  // Trailing Stop Loss (10 points = 1 pip)
          
         
         
         
         
     input group "=== Bitcoin Trading Inputs (Bitcoin Profile!) ==="
         
           input double TPasPct         = 0.4; // TP as % of Price
           input double SLasPct         = 0.4; // SL as % of Price
           input double TSLasPctofTP    = 5; // Trailing SL as % of TP
           input double TSLTrgasPctofTP = 7; // Trailing SL trigger as % of TP
           
           
           
     input group "=== Gold Trading Inputs (Gold Profile!) ==="
         
           input double TPasPctGold         = 0.2; // TP as % of Price
           input double SLasPctGold         = 0.2; // SL as % of Price
           input double TSLasPctofTPGold    = 5; // Trailing SL as % of TP
           input double TSLTrgasPctofTPGold = 7; // Trailing SL trigger as % of TP
     
     
     
     input group "=== Indicies Trading Inputs (US_Indicies Profile!) ==="
         
           input double TPasPctIndicies         = 0.2; // TP as % of Price
           input double SLasPctIndicies         = 0.2; // SL as % of Price
           input double TSLasPctofTPIndicies    = 5; // Trailing SL as % of TP
           input double TSLTrgasPctofTPIndicies = 7; // Trailing SL trigger as % of TP
     
     
     input group "=== News Filter ==="
     
           input bool              NewsFilterOn      = true;  // Filter for News
           enum sep_dropdown{comma=0,semicolon=1};
           input sep_dropdown      seperator         = 0;     // Seperator to seperate News Keywords
           input string            KeyNews           = "BCB,NFP,JOLTS,Nonfarm,PMI,Retail,GDP,Confidence,Interest Rate"; // Keywords in News to avoid
           input string            NewsCurrencies    = "USD,GBP,EUR,JPY"; // Currencies for News lookup
           input int               DaysNewsLookup    = 100;  // No. of Days to look up news
           input int               StopBeforeMin     = 15;   // Stop trading before News (in minutes)
           input int               StartTradingMin   = 15;   // Start trading after News (in minutes)
                 bool              TrDisabledNews    = false; // Variable to store if trading is disabled due to news
                 
            ushort      sep_code;
            string      Newstoavoid[];
            datetime    LastNewsAvoided;
            
            
       input group "=== RSI Filter ==="
       
             input bool                RSIFilterOn       = false;          // Filter for RSI extremes
             input ENUM_TIMEFRAMES     RSITimeframe      = PERIOD_H1;      // Timeframe for RSI filter
             input int                 RSIlowerlvl       = 20;             // RSI lower level to filter
             input int                 RSIUpperlvl       = 80;             // RSI upper level to filter
             input int                 RSI_MA            = 14;             // RSI period
             input ENUM_APPLIED_PRICE  RSI_AppPrice      = PRICE_MEDIAN;   // RSI applied price
             
             
       input group "=== Moving Average Filter ===" 
       
             input bool             MAFilterOn           = false;          // Filter for Moving Average extremes
             input ENUM_TIMEFRAMES  MATimeframe          = PERIOD_H4;      // Timeframe for Moving Average Filter
             input double           PctPricefromMA       = 3;              // % price is away from Mov. Avg. to be extreme
             input int              MA_Period            = 200;            // Moving Average period
             input ENUM_MA_METHOD   MA_Mode              = MODE_EMA;       // Moving Average Mode/Method
             input ENUM_APPLIED_PRICE MA_AppPrice        = PRICE_MEDIAN;     // Moving Average applied price
             
             
       input group "=== Spread Filter ==="

             input bool    SpreadFilterOn   = true;           // Filter for spread
             input long    MaxSpreadPoints  = 20;             // Max. spread in points
     


       input group "=== ADX Filter ==="
       
             input bool            ADXFilterOn   = false; // Filter for ADX
             input int             ADX_Period    = 14;    // ADX Period
             input double          ADX_Threshold = 20;    // Below this value indicates ranging market
             input ENUM_TIMEFRAMES ADX_Timeframe = PERIOD_H1;  // Timeframe for ADX
             int handleADX;
             


int OnInit(){

   trade.SetExpertMagicNumber(InpMagic);
   
   Tppoints = TppointsInput;
   Slpoints = SlpointsInput;
   TslPoints = TslPointsInput;
   TslTriggerPoints = TslTriggerPointsInput;
   
   SHChoice = SHInput;
   EHChoice = EHInput;
   
   if(SType==0) SysChoice=0;
   if(SType==1) SysChoice=1;
   if(SType==2) SysChoice=2;
   if(SType==3) SysChoice=3;
   
   if(HideIndicators==true) TesterHideIndicators(false);
   
   handleRSI = iRSI(_Symbol,RSITimeframe,RSI_MA,RSI_AppPrice);
   handleMovAvg = iMA(_Symbol,MATimeframe,MA_Period,0,MA_Mode,MA_AppPrice);
   handleADX = iADX(_Symbol, ADX_Timeframe, ADX_Period);
   

   return(INIT_SUCCEEDED);
}



void OnDeinit(const int reason){  
}



void OnTick(){

   TrailStop();
   
   // If spread is too high, delete pending orders
    if(IsSpreadTooHigh()) {
        for(int i=OrdersTotal()-1; i>=0; i--) {
            if(ord.SelectByIndex(i)) {
                if(ord.Symbol() == _Symbol && ord.Magic() == InpMagic) {
                    trade.OrderDelete(ord.Ticket());
                      if(TradingEnabledComm=="" || TradingEnabledComm!="Printed"){
                      TradingEnabledComm = "Pending order deleted, spread too high";
                    
                }
            }
        }
    }
 }
   
   if(IsRSIFilter() || IsUpcomingNews() || IsMAFilter() || IsADXFilter()) {
      CloseAllOrders();
      Tradingenabled = false;
      ChartSetInteger(0,CHART_COLOR_BACKGROUND,ChartColorTradingOff);
      if(TradingEnabledComm!="Printed")
         Print(TradingEnabledComm);
      TradingEnabledComm = "Printed";
      return; 
    }
   
   Tradingenabled = true;
    if(TradingEnabledComm != ""){
        TradingEnabledComm = "Trading is enabled again";
    }
   
   ChartSetInteger(0,CHART_COLOR_BACKGROUND,ChartColorTradingOn);

   if(!IsNewBar()) return;
   
   MqlDateTime time;
   TimeToStruct(TimeCurrent(), time);
   
   int Hournow = time.hour;
   
   
   if(Hournow<SHChoice){CloseAllOrders(); return;}
   if(Hournow>=EHChoice && EHChoice!=0){CloseAllOrders(); return;}
   
   if(SysChoice==1){
      double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
      Tppoints = ask * TPasPct;
      Slpoints = ask * SLasPct;
      OrderDistPoints = Tppoints/2;
      TslPoints = Tppoints * TSLasPctofTP/100;
      TslTriggerPoints = Tppoints * TSLTrgasPctofTP/100;
   
   }
   
   if(SysChoice==2){
      double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
      Tppoints = ask * TPasPctGold;
      Slpoints = ask * SLasPctGold;
      OrderDistPoints = Tppoints/2;
      TslPoints = Tppoints * TSLasPctofTPGold/100;
      TslTriggerPoints = Tppoints * TSLTrgasPctofTPGold/100;
   
   }
   
   if(SysChoice==3){
      double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
      Tppoints = ask * TPasPctIndicies;
      Slpoints = ask * SLasPctIndicies;
      OrderDistPoints = Tppoints/2;
      TslPoints = Tppoints * TSLasPctofTPIndicies/100;
      TslTriggerPoints = Tppoints * TSLTrgasPctofTPIndicies/100;
   
   }
   
   
   int BuyTotal = 0;
   int SellTotal = 0;
   
   for (int i=PositionsTotal()-1; i>=0; i--){
      pos.SelectByIndex(i);
      if(pos.PositionType()==POSITION_TYPE_BUY && pos.Symbol()==_Symbol && pos.Magic()==InpMagic) BuyTotal++;
      if(pos.PositionType()==POSITION_TYPE_SELL && pos.Symbol()==_Symbol && pos.Magic()==InpMagic) SellTotal++;
   }
   
   for (int i=OrdersTotal()-1; i>=0; i--){
      ord.SelectByIndex(i);
      if(ord.OrderType()==ORDER_TYPE_BUY_STOP && ord.Symbol()==_Symbol && ord.Magic()==InpMagic) BuyTotal++;
      if(ord.OrderType()==ORDER_TYPE_SELL_STOP && ord.Symbol()==_Symbol && ord.Magic()==InpMagic) SellTotal++;
   }
   
   if(BuyTotal <=0){
      double high = findHigh();
      if(high > 0){
         SendBuyOrder(high);
      }
   }
   
   if(SellTotal <=0){
      double low = findLow();
      if(low > 0){
         SendSellOrder(low);
      }
    
    }
    
}

  
  
double findHigh(){
   double highestHigh = 0;
      for(int i = 0; i < 200; i++){
      double high = iHigh(_Symbol,Timeframe,i);
         if(i > BarsN && iHighest(_Symbol,Timeframe,MODE_HIGH,BarsN*2+1,i-BarsN) == i){
            if(high > highestHigh){
               return high;
            }
         }
       highestHigh = MathMax(high, highestHigh);      
      }     
      return -1;
}


double findLow(){
   double lowestLow = DBL_MAX;
   for(int i = 0; i < 200; i++){
      double low = iLow(_Symbol,Timeframe,i);
      if(i > BarsN && iLowest(_Symbol,Timeframe,MODE_LOW,BarsN*2+1,i-BarsN) == i){
         if(low < lowestLow){
            return low;
         }
      }
      lowestLow = MathMin(low,lowestLow);
   }  
   return -1;
}


bool IsNewBar(){
   static datetime previousTime = 0;
   datetime currentTime = iTime(_Symbol,Timeframe,0);
   if(previousTime!=currentTime){
      previousTime=currentTime;
      return true;
   }
   return false;
}


void SendBuyOrder(double entry){

   // Spread Check before order placing
    if(IsSpreadTooHigh()) {
        Print("Buy-Stop Order not placed - Spread too high: ", 
              SymbolInfoInteger(_Symbol, SYMBOL_SPREAD), " Points");
        return;
    }

   double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
      if(ask > entry - OrderDistPoints * _Point) return;
      double tp = entry + Tppoints * _Point;
      double sl = entry - Slpoints * _Point;
      
      double lots = 0.01;
      if(RiskPercent > 0) lots = calcLots(entry-sl);
      
      datetime expiration = iTime(_Symbol,Timeframe,0) + ExpirationBars * PeriodSeconds(Timeframe);
      
         trade.BuyStop(lots,entry,_Symbol,sl,tp,ORDER_TIME_SPECIFIED,expiration);
}


void SendSellOrder(double entry){

   // Spread Check before order placing
    if(IsSpreadTooHigh()) {
        Print("Sell-Stop Order not placed - Spread too high: ", 
              SymbolInfoInteger(_Symbol, SYMBOL_SPREAD), " Points");
        return;
    }

   double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
      if(bid < entry + OrderDistPoints * _Point) return;
      double tp = entry - Tppoints * _Point;
      double sl = entry + Slpoints * _Point;
      
      double lots = 0.01;
      if(RiskPercent > 0) lots = calcLots(sl-entry);
      
      datetime expiration = iTime(_Symbol,Timeframe,0) + ExpirationBars * PeriodSeconds(Timeframe);
      
         trade.SellStop(lots,entry,_Symbol,sl,tp,ORDER_TIME_SPECIFIED,expiration);
}




double calcLots (double slPoints) {
   double risk = AccountInfoDouble (ACCOUNT_BALANCE) * RiskPercent / 100;

   double ticksize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE); 
   double tickvalue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE); 
   double lotstep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP); 
   double minvolume = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN); 
   double maxvolume = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX); 
   double volumelimit = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_LIMIT);
   
   
   double moneyPerLotstep = slPoints / ticksize * tickvalue * lotstep; 
   double lots = MathFloor (risk / moneyPerLotstep) * lotstep;
   
   if(volumelimit!=0) lots = MathMin (lots,volumelimit);
   if(maxvolume!=0) lots = MathMin (lots, SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX)); 
   if(minvolume!=0) lots = MathMax (lots, SymbolInfoDouble (_Symbol, SYMBOL_VOLUME_MIN)); 
   lots = NormalizeDouble(lots, 2);
   
   return lots;
}


void CloseAllOrders(){

   for(int i=OrdersTotal()-1;i>=0;i--){
      ord.SelectByIndex(i);
      ulong ticket = ord.Ticket();
      if(ord.Symbol()==_Symbol && ord.Magic()==InpMagic){
         trade.OrderDelete(ticket);
      }
   }
}




void TrailStop(){

    double sl = 0;
    double tp = 0;
      
    double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
    double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
    
       for (int i=PositionsTotal()-1; i>=0; i--){
            if(pos.SelectByIndex(i)){
                  ulong ticket = pos.Ticket();
                  
                     if(pos.Magic()==InpMagic && pos.Symbol()==_Symbol){
                        
                        if(pos.PositionType()==POSITION_TYPE_BUY){
                              if(bid-pos.PriceOpen()>TslTriggerPoints*_Point){
                                 tp = pos.TakeProfit();
                                 sl = bid - (TslPoints * _Point);
                                 
                                 if(sl > pos.StopLoss() && sl!=0){
                                    trade.PositionModify(ticket,sl,tp);
                                 }
                              
                              }
                        
                        }
                        else if(pos.PositionType()==POSITION_TYPE_SELL){
                           if(ask+(TslTriggerPoints*_Point)<pos.PriceOpen()){
                              tp = pos.TakeProfit();
                              sl = ask + (TslPoints * _Point);
                              if(sl < pos.StopLoss() && sl!=0){
                                 trade.PositionModify(ticket,sl,tp);
                              }
                           }
                        }
                     
                     }
            
            }
       
       }



}


bool IsUpcomingNews(){

   if(NewsFilterOn==false) return(false);
   
   if(TrDisabledNews && TimeCurrent()-LastNewsAvoided < StartTradingMin*PeriodSeconds(PERIOD_M1)) return true;
   
   TrDisabledNews = false;
   
   string sep;
   switch(seperator){
      case 0: sep = ","; break;
      case 1: sep = ";";
   
   }
   
   sep_code = StringGetCharacter(sep,0);
   
   int k = StringSplit(KeyNews,sep_code,Newstoavoid);
   
   MqlCalendarValue values[];
   datetime starttime = TimeCurrent(); // iTime(_Symbol,PERIOD_D1,0);
   datetime endtime   = starttime + PeriodSeconds(PERIOD_D1)*DaysNewsLookup;
   
   CalendarValueHistory(values,starttime,endtime,NULL,NULL);
   
   for(int i = 0; i < ArraySize(values); i++){
      MqlCalendarEvent event;
      CalendarEventById(values[i].event_id, event);
      MqlCalendarCountry country;
      CalendarCountryById(event.country_id,country);
      
      if(StringFind(NewsCurrencies,country.currency) < 0) continue;
      
         for(int j=0; j<k; j++){
            string currentevent = Newstoavoid[j];
            string currentnews = event.name;
            if(StringFind(currentnews,currentevent) < 0) continue;
            
            Comment("Next News: ", country.currency ,": ", event.name, " -> ", values[i].time);
            
            if(values[i].time - TimeCurrent() < StopBeforeMin*PeriodSeconds(PERIOD_M1)){
               LastNewsAvoided = values[i].time;
               TrDisabledNews = true;
               if(TradingEnabledComm=="" || TradingEnabledComm!="Printed"){
                  TradingEnabledComm = "Trading is disabled due to upcoming news: " + event.name;
               
               }
               return true;
            
            }
            return false;
         
         }
   
   }
   return false;



}



bool IsRSIFilter(){

   if(RSIFilterOn==false) return(false);
   
   double RSI[];
   
   CopyBuffer(handleRSI,MAIN_LINE,0,1,RSI);
   ArraySetAsSeries(RSI,true);
   
   double RSInow = RSI[0];
   
   Comment("RSI = ",RSInow);
   
   if(RSInow>RSIUpperlvl || RSInow<RSIlowerlvl){
      if(TradingEnabledComm=="" || TradingEnabledComm!="Printed"){
         TradingEnabledComm = "Trading is disabled due to RSI filter";
      
      }
      return(true);
   
   }
   return false;

}


bool IsMAFilter(){

   if(MAFilterOn==false) return(false);
   
   double MovAvg[];
   
   CopyBuffer(handleMovAvg,MAIN_LINE,0,1,MovAvg);
   ArraySetAsSeries(MovAvg,true);
   
   double MAnow = MovAvg[0];
   double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   
   if( ask > MAnow * (1 + PctPricefromMA/100) ||
       ask < MAnow * (1 - PctPricefromMA/100)
       
     ){
         if(TradingEnabledComm=="" || TradingEnabledComm!="Printed"){
            TradingEnabledComm = "Trading is disabled due to Mov. Avg. filter";         
         }
         return true;
     
     
     }
     return false;
}



bool IsSpreadTooHigh() {
    if(!SpreadFilterOn) return false;
    
    long currentSpread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
    return (currentSpread > MaxSpreadPoints);
}


bool IsADXFilter() {

    if(ADXFilterOn==false) return (false);
    
    double ADX[];
    CopyBuffer(handleADX, 0, 0, 1, ADX);
    ArraySetAsSeries(ADX, true);

    double ADXnow = ADX[0];
    Comment("ADX = ", ADXnow);

    if (ADXnow < ADX_Threshold) {
        if (TradingEnabledComm == "" || TradingEnabledComm != "Printed") {
            TradingEnabledComm = "Trading is disabled due to ADX filter";
        }
        return true;
    }
    return false;
}

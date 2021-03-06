//+------------------------------------------------------------------+
//|                                                       Shacho.mq4 |
//|                           Copyright 2017, Palawan Software, Ltd. |
//|                             https://coconala.com/services/204383 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Palawan Software, Ltd."
#property link      "https://coconala.com/services/204383"
#property description "Author: Kotaro Hashimoto <hasimoto.kotaro@gmail.com>"
#property version   "1.00"
#property strict


input int StopLoss_TimeOut = 7;
input int StopLossUSD = 12;
input int StopLossEUR = 15;
input double Entry_Lot = 0.1;
input double Band_Sigma = 3.0;
input int Magic_Number = 1;

enum EntryDirection {
  BOTH = 0,
  LONG_ONLY = 1,
  SHORT_ONLY = 2,
  LONG = 3,
  SHORT = 4, 
  NONE = -1
};

EntryDirection nextDirection;


string thisSymbol;
double sl;


const bool TOP = True;
const bool BOTTOM = False;

double minLot;
double maxLot;

bool determineSAR() {
  return (Ask + Bid) / 2.0 < iSAR(thisSymbol, PERIOD_M1, 0.02, 0.2, 0);
}

EntryDirection determineBand() {

  double price = (Ask + Bid) / 2.0;
  
  if(iBands(thisSymbol, PERIOD_M5, 20, Band_Sigma, 0, PRICE_WEIGHTED, 1, 0) < price) {
    return SHORT;
  }
  else if(price < iBands(thisSymbol, PERIOD_M5, 20, Band_Sigma, 0, PRICE_WEIGHTED, 2, 0)) {
    return LONG;
  }
  else {
    return NONE;
  }
}
 

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

  nextDirection = BOTH;
  thisSymbol = Symbol();
  
  if(thisSymbol == "USDJPY") {
    sl = 10.0 * Point * StopLossUSD;
  }
  else if(thisSymbol == "EURJPY") {
    sl = 10.0 * Point * StopLossEUR;
  }
  else if(thisSymbol == "EURUSD") {
    sl = 10.0 * Point * StopLossEUR;
  }
  else {
    sl = 0.0;
  }
  
  minLot = MarketInfo(Symbol(), MODE_MINLOT);
  maxLot = MarketInfo(Symbol(), MODE_MAXLOT);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  for(int i = 0; i < OrdersTotal(); i++) {
    if(OrderSelect(i, SELECT_BY_POS)) {
      if(!StringCompare(OrderSymbol(), thisSymbol) && OrderMagicNumber() == Magic_Number) {
      
        if(OrderType() == OP_BUY) {
          if(OrderOpenTime() + 60 * StopLoss_TimeOut < TimeCurrent()) {
            if(determineSAR() == TOP) {
              bool profit = 0.0 < OrderProfit();
              bool closed = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits), 0);
              if(profit && closed) {
                nextDirection = BOTH;
              }
            }
          }
        }
        else if(OrderType() == OP_SELL) {
          if(OrderOpenTime() + 60 * StopLoss_TimeOut < TimeCurrent()) {
            if(determineSAR() == BOTTOM) {
              bool profit = 0.0 < OrderProfit();
              bool closed = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Digits), 0);
              if(profit && closed) {
                nextDirection = BOTH;
              }
            }
          }
        }
        
        return;
      }
    }
  }

  if(Entry_Lot < minLot || maxLot < Entry_Lot) {
    Print("lot size invalid, min = ", minLot, ", max = ", maxLot);
    return;
  }
  
  EntryDirection signal = determineBand();
  if(signal == NONE) {
    return;
  }
  else if(signal == SHORT) {
    if(nextDirection != LONG_ONLY) {
      int ticket = OrderSend(thisSymbol, OP_SELL, Entry_Lot, NormalizeDouble(Bid, Digits), 3, NormalizeDouble(Bid + sl, Digits), 0, NULL, Magic_Number);
      if(-1 < ticket) {
        nextDirection = LONG_ONLY;
      }
    }
  }
  else if(signal == LONG) {
    if(nextDirection != SHORT_ONLY) {
      int ticket = OrderSend(thisSymbol, OP_BUY, Entry_Lot, NormalizeDouble(Ask, Digits), 3, NormalizeDouble(Ask - sl, Digits), 0, NULL, Magic_Number);
      if(-1 < ticket) {
        nextDirection = SHORT_ONLY;
      }
    }
  }
}
//+------------------------------------------------------------------+

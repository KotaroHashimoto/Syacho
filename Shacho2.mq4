//+------------------------------------------------------------------+
//|                                                      Shacho2.mq4 |
//|                           Copyright 2017, Palawan Software, Ltd. |
//|                             https://coconala.com/services/204383 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Palawan Software, Ltd."
#property link      "https://coconala.com/services/204383"
#property description "Author: Kotaro Hashimoto <hasimoto.kotaro@gmail.com>"
#property version   "1.00"
#property strict

input int Magic_Number = 1;
input double Entry_Lot = 0.1;

string thisSymbol;

int getTurboSignal() {

  string buyID = "platinum_turbo-fx bsp";
  string sellID = "platinum_turbo-fx ssp";

  if(0 < ObjectGetDouble(0, buyID, OBJPROP_PRICE)) {
    return OP_BUY;
  }
  else if(0 < ObjectGetDouble(0, sellID, OBJPROP_PRICE)) {
    return OP_SELL;
  }
  
  return -1;
}

int getDragonSignal() {

  for(int i = 1; i < 9; i++) {
    if(0 < iCustom(NULL, PERIOD_CURRENT, "DragonArrows", 2, i)) {
      return OP_BUY;
    }
    else if(0 < iCustom(NULL, PERIOD_CURRENT, "DragonArrows", 3, i)) {
      return OP_SELL;
    }
  }

  return -1;
}


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

  thisSymbol = Symbol();
   
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

  int dragon = getDragonSignal();
  int turbo = getTurboSignal();

  if(0 < OrdersTotal()) {  
    if(OrderSelect(0, SELECT_BY_POS)) {
      if(!StringCompare(OrderSymbol(), thisSymbol) && OrderMagicNumber() == Magic_Number) {
        if((dragon == OP_SELL || turbo != OP_BUY) && OrderType() == OP_BUY) {
          bool closed = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits), 0);
        }
        else if((dragon == OP_BUY || turbo != OP_SELL) && OrderType() == OP_SELL) {
          bool closed = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Digits), 0);
        }
      }
    }  
  }
  
  else {
    if(dragon == OP_BUY && turbo == OP_BUY) {
      int ticket = OrderSend(Symbol(), OP_BUY, Entry_Lot, NormalizeDouble(Ask, Digits), 0, 0, 0, NULL, Magic_Number);
    }
    else if(dragon == OP_SELL && turbo == OP_SELL) {
      int ticket = OrderSend(Symbol(), OP_SELL, Entry_Lot, NormalizeDouble(Bid, Digits), 0, 0, 0, NULL, Magic_Number);
    }
  }
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                  ZigZagTrend.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

input color Line_Color = clrCyan;

const string iName = "ZigZag";
const string line1 = "ZigZagLine1";
const string line2 = "ZigZagLine2";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   
//---
   return(INIT_SUCCEEDED);
  }
  
void OnDeinit(const int reason)
{
   ObjectDelete(0, line1);
   ObjectDelete(0, line2);
}
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---

  ObjectDelete(0, line1);
  ObjectDelete(0, line2);

  datetime t[] = {0, 0, 0, 0};
  double p[] = {0, 0, 0, 0};
  
  for(int i = 0, n = -1; n < 4; i++) {
    double z = iCustom(Symbol(), PERIOD_CURRENT, iName, 0, i);
    if(0 < z) {
      if(n < 0) {
        n = 0;
        continue;
      }
      t[n] = iTime(Symbol(), PERIOD_CURRENT, i);
      p[n] = z;
      n ++;
    }
  }

  ObjectCreate(0, line1, OBJ_TREND, 0, t[2], p[2], t[0], p[0]);
  ObjectCreate(0, line2, OBJ_TREND, 0, t[3], p[3], t[1], p[1]);
  
  ObjectSetInteger(0, line1, OBJPROP_COLOR, Line_Color);  
  ObjectSetInteger(0, line2, OBJPROP_COLOR, Line_Color);  

  ObjectSetInteger(0, line1, OBJPROP_STYLE, STYLE_SOLID);
  ObjectSetInteger(0, line2, OBJPROP_STYLE, STYLE_SOLID);
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

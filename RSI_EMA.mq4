//compile//
//+------------------------------------------------------------------+
//|                                                      RSI_EMA.mq4 |
//|                         Copyright © 2006, Robert Hill            |
//|                                                                  |
//| Written Robert Hill for use with AIME for the stochastic cross   |
//| to draw arrows and popup alert or send email                     |
//+------------------------------------------------------------------+

#property copyright "Copyright 2017, Palawan Software, Ltd."
#property link      "https://coconala.com/services/204383"
#property description "Author: Kotaro Hashimoto <hasimoto.kotaro@gmail.com>"
#property version   "1.00"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 LawnGreen
#property indicator_color2 Red
#property indicator_width1  2
#property indicator_width2  2

// この番号の口座番号のアカウントでなければ稼働しない
const int Account_Number = 12345678;

input bool Sound_ON = True;

input int MA_Period = 10;
input int RSI_Period = 2;

input double Buy_Line = 35;
input double Sell_Line = 65;

double CrossUp[];
double CrossDown[];
int flagval1 = 0;
int flagval2 = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_ARROW, EMPTY);
   SetIndexArrow(0, 233);
   SetIndexBuffer(0, CrossUp);
   SetIndexStyle(1, DRAW_ARROW, EMPTY);
   SetIndexArrow(1, 234);
   SetIndexBuffer(1, CrossDown);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 

//----
   return(0);
  }


//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {

  if(AccountNumber() != Account_Number) {
    Print("Account Number mismatch. No operation.: ", Account_Number);
    return -1;
  }
  
   int limit, i, counter;
   double tmp=0;
   double Range, AvgRange;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;

   limit=Bars-counted_bars;
   
   for(i = 1; i <= limit; i++) {
   
      counter=i;
      Range=0;
      AvgRange=0;
      for (counter=i ;counter<=i+9;counter++)
      {
         AvgRange=AvgRange+MathAbs(High[counter]-Low[counter]);
      }
      Range=AvgRange/10;

      double ema = iMA(Symbol(), PERIOD_CURRENT, MA_Period, 0, MODE_EMA, PRICE_WEIGHTED, i);       
      double rsi = iRSI(Symbol(), PERIOD_CURRENT, RSI_Period, PRICE_WEIGHTED, i);
      
      CrossUp[i] = 0;
      CrossDown[i] = 0;
      
      if(rsi < Buy_Line && ema < iLow(Symbol(), PERIOD_CURRENT, i)) {
        CrossUp[i] = Low[i] - Range*0.75;
      }
      else if(Sell_Line < rsi && iHigh(Symbol(), PERIOD_CURRENT, i) < ema) {
        CrossDown[i] = High[i] + Range*0.75;
      }

      
      if(0 < CrossDown[i]) {
        if(i == 1 && flagval2 == 0) {
          flagval2 = 1;
          flagval1 = 0;
          if (Sound_ON) Alert("SELL signal at Ask=",Ask,"\n Bid=",Bid,"\n Date=",TimeToStr(CurTime(),TIME_DATE)," ",TimeHour(CurTime()),":",TimeMinute(CurTime()),"\n Symbol=",Symbol()," Period=",Period());
        }
      }
      
      if(0 < CrossUp[i]) {
        if (i == 1 && flagval1 == 0) {
          flagval1 = 1;
          flagval2 = 0;
          if (Sound_ON) Alert("BUY signal at Ask=",Ask,"\n Bid=",Bid,"\n Time=",TimeToStr(CurTime(),TIME_DATE)," ",TimeHour(CurTime()),":",TimeMinute(CurTime()),"\n Symbol=",Symbol()," Period=",Period());
        }
      }      
   }

   return(0);
}

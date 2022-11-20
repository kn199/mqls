<<<<<<< HEAD
//+------------------------------------------------------------------+
//|                                                  sample_test.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

int ticket;
bool entry;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
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
    entry = OrderSelect(ticket, SELECT_BY_TICKET);
  
    if(TimeHour(TimeLocal()) == 20 && TimeMinute(TimeLocal()) == 34 && entry == false ){
      ticket = OrderSend(
        NULL,
        0,
        0.01,
        Ask,
        3,
        0,
        0,
        0
      );
    };
//---
   
  }
//+------------------------------------------------------------------+
=======
//+------------------------------------------------------------------+
//|                                                  sample_test.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

int ticket;
bool entry;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
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
    entry = OrderSelect(ticket, SELECT_BY_TICKET);
  
    if(TimeHour(TimeLocal()) == 20 && TimeMinute(TimeLocal()) == 34 && entry == false ){
      ticket = OrderSend(
        NULL,
        0,
        0.01,
        Ask,
        3,
        0,
        0,
        0
      );
    };
//---
   
  }
//+------------------------------------------------------------------+
>>>>>>> 0d214ef9625c43f27888ed41f05dfc96ac965720

//+-----------------------------------------------------------------------+
//|                                      　　　　　　　　　【119】usdjpy週初めエントリ|
//|                                                    Copyright (c) 2021 |
//+-----------------------------------------------------------------------+
#property strict                        //MT4パラメータ設定画面が変数名ではなく日本語表示される。

// マジックナンバー
#define MAGIC 119                        //マジックナンバー
#define COMMENT "【119】usdjpy_week_open_entry"  　       //MT4画面上左上のコメント表示

// 外部パラメータ
extern double Lots = 0.01;              //ロット数
extern int Slippage = 3;                //スリッページ

//チケット番号
int Ticket = 0;

//ポジション変数（変数posに0をセッティング、以後ifの状況ごとにposに値を代入し管理）
int pos = 0;

bool result;

//利確、損切幅
input int TPPoint = 400; //利確
input int SLPoint = 200; //損切

//決済用変数
double price;

//ティック時実行関数
void OnTick()
{

//取引時間計算計算用変数
   long diff = TimeCurrent() - OrderOpenTime();

   if(OrderSelect(Ticket, SELECT_BY_TICKET) == true &&
      OrdersTotal() != 0 &&
      OrderType() == 0
      ) 
      {pos = 1;
       price = OrderOpenPrice();
      };

   if(OrderSelect(Ticket, SELECT_BY_TICKET) == true &&
      OrdersTotal() != 0 &&
      OrderType() == 1
      )
      {pos = -1;
       price = OrderOpenPrice();
      };

//buy-entry
   if(iOpen(NULL,PERIOD_M5,0) > iClose(NULL,PERIOD_M5,1) &&
      TimeDayOfWeek(TimeLocal()) == 1 &&
      ((TimeHour(TimeLocal()) == 6) || (TimeHour(TimeLocal()) == 7)) &&
      TimeMinute(TimeLocal()) == 1 &&
      diff > 80000 &&
      pos == 0
      )
    {Ticket = OrderSend(NULL,OP_BUY,Lots,Ask,Slippage,0,0,"119",MAGIC,0,Blue);
     Print("iOpen(NULL,PERIOD_M5,0)", iOpen(NULL,PERIOD_M5,0));
     Print("iClose(NULL,PERIOD_M5,1)", iClose(NULL,PERIOD_M5,1));
     Print("iClose(NULL,PERIOD_M15,1)", iClose(NULL,PERIOD_M15,1));
     Print("iClose(NULL,PERIOD_M30,1)", iClose(NULL,PERIOD_M30,1));
     Print("iClose(NULL,PERIOD_H1,1)", iClose(NULL,PERIOD_H1,1));
     Print("iClose(NULL,PERIOD_D1,1)", iClose(NULL,PERIOD_D1,1));
     Print("iClose(NULL,PERIOD_W1,1)", iClose(NULL,PERIOD_W1,1));
     Print("TimeHour(TimeLocal())", TimeHour(TimeLocal()));
     price = Ask;
         //email = SendMail(subject,text);
    };

//sell-entry
   if(iOpen(NULL,PERIOD_M5,0) < iClose(NULL,PERIOD_M5,1) &&
      TimeDayOfWeek(TimeLocal()) == 1 &&
      ((TimeHour(TimeLocal()) == 6) || (TimeHour(TimeLocal()) == 7)) &&
      TimeMinute(TimeLocal()) == 1 &&
      diff > 80000 &&
      pos == 0
      )
    {Ticket = OrderSend(NULL,OP_SELL,Lots,Bid,Slippage,0,0,"119",MAGIC,0,Blue);
     Print("iOpen(NULL,PERIOD_M5,0)", iOpen(NULL,PERIOD_M5,0));
     Print("iClose(NULL,PERIOD_M5,1)", iClose(NULL,PERIOD_M5,1));
     Print("iClose(NULL,PERIOD_M15,1)", iClose(NULL,PERIOD_M15,1));
     Print("iClose(NULL,PERIOD_M30,1)", iClose(NULL,PERIOD_M30,1));
     Print("iClose(NULL,PERIOD_H1,1)", iClose(NULL,PERIOD_H1,1));
     Print("iClose(NULL,PERIOD_D1,1)", iClose(NULL,PERIOD_D1,1));
     Print("iClose(NULL,PERIOD_W1,1)", iClose(NULL,PERIOD_W1,1));
     Print("TimeHour(TimeLocal())", TimeHour(TimeLocal()));
     price = Bid;
         //email = SendMail(subject,text);
    };

//買い注文利確
   if(pos == 1 &&
      Bid >= (TPPoint*_Point + price)
      )
        {result = OrderClose(Ticket,Lots,Bid,Slippage,clrNONE);
         Print("クローズ:Bid,Ask", Bid,Ask);
         pos = 0;
         //Ticket=0;
        };

//売り注文利確
   if(pos == -1 &&
      Ask <= (price - TPPoint*_Point)
      )
        {result = OrderClose(Ticket,Lots,Ask,Slippage,clrNONE);
         //email = SendMail(subject2,text);
         //Ticket=0;
         pos = 0;
        };

//買い注文損切
   if(pos == 1 &&
      Bid <= (price - SLPoint*_Point)
      )
        {result = OrderClose(Ticket,Lots,Bid,Slippage,clrNONE);
         Print("クローズ:Bid,Ask", Bid,Ask);
         //Ticket=0;
         pos = 0;
        };

//売り注文損切
   if(pos == -1 &&
      Ask >= (SLPoint*_Point + price)
      )
        {result = OrderClose(Ticket,Lots,Ask,Slippage,clrNONE);
         //email = SendMail(subject3,text);
         //Ticket=0;
         pos = 0;
        };

//金曜夜間に自動決済
   if(pos == 1 &&
      TimeDayOfWeek(TimeLocal()) == 6
      )
        {result = OrderClose(Ticket,Lots,Bid,Slippage,clrNONE);
         //email = SendMail(subject4,text);
         //Ticket=0;
         pos = 0;
        };
        
   if(pos == -1 &&
      TimeDayOfWeek(TimeLocal()) == 6
      )
        {result = OrderClose(Ticket,Lots,Ask,Slippage,clrNONE);
         //email = SendMail(subject4,text);
         //Ticket=0;
         pos = 0;
        };
};

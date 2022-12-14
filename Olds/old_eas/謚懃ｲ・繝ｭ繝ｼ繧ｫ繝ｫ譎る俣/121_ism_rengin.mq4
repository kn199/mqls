//+-----------------------------------------------------------------------+
//|                                                        【121】ism_rengin|
//|                                                    Copyright (c) 2021 |
//+-----------------------------------------------------------------------+
#property strict                        //MT4パラメータ設定画面が変数名ではなく日本語表示される。

// マジックナンバー
#define MAGIC 121                       //マジックナンバー
#define COMMENT "121_ism_rengin"  　       //MT4画面上左上のコメント表示

// 外部パラメータ
extern double Lots = 0.01;              //ロット数
extern int Slippage = 3;                //スリッページ

//チケット番号
int Ticket = 0;

//ポジション変数（変数posに0をセッティング、以後ifの状況ごとにposに値を代入し管理）
int pos = 0;

int time = 0;

bool result;

input string currency = "USDJPY";

//利確、損切幅
input int TPPoint = 400; //利確
input int SLPoint = 150; //損切

int hour;

double price;

//ティック時実行関数
void OnTick(){

   if(66 < DayOfYear() < 310)
    hour = 23;
   else
    hour = 24;

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
   if(TimeHour(TimeLocal()) == time &&
      iOpen(currency,5,1) < iClose(currency,5,1) &&
      TimeDay(TimeLocal()) < 8 &&
      TimeDayOfWeek(TimeLocal()) == 3 &&
      TimeMinute(TimeLocal()) == 0 &&
      pos == 0
      )
    {Ticket = OrderSend(currency,OP_BUY,Lots,Ask,Slippage,0,0,"117",MAGIC,0,Blue);
     Print("Bid,Ask", Bid,Ask);
     price = Ask;
    };

//sell-entry
   if(TimeHour(TimeLocal()) == time &&
      iOpen(currency,5,1) > iClose(currency,5,1) &&
      TimeDay(TimeLocal()) < 8 &&
      TimeDayOfWeek(TimeLocal()) == 3 &&
      TimeMinute(TimeLocal()) == 0 &&
      pos == 0
      )
    {Ticket = OrderSend(currency,OP_SELL,Lots,Bid,Slippage,0,0,"117",MAGIC,0,Blue);
     Print("Bid,Ask", Bid,Ask);
     price = Bid;
    };

//買い注文利確
   if(pos == 1 &&
      Bid >= (TPPoint*_Point + price)
      )
        {result = OrderClose(Ticket,Lots,Bid,Slippage,clrNONE);
         Print("クローズ:Bid,Ask", Bid,Ask);
         pos = 0;
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

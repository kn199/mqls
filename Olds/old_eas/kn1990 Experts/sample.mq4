//+-----------------------------------------------------------------------+
//|                                            ローカルとサーバ時間の差を調べる用|
//|                                                    Copyright (c) 2021 |
//+-----------------------------------------------------------------------+
#property strict                        //MT4パラメータ設定画面が変数名ではなく日本語表示される。

// マジックナンバー
#define COMMENT "ローカルとサーバ時間の差を調べる用"  　       //MT4画面上左上のコメント表示
#define MAGIC 999                        //マジックナンバー

// 外部パラメータ
extern double Lots = 0.01;              //ロット数
extern int Slippage = 3;                //スリッページ

//チケット番号
int Ticket = 0;

//ポジション変数（変数posに0をセッティング、以後ifの状況ごとにposに値を代入し管理）
int pos = 0;

bool result;

//利確、損切幅
input int TPPoint = 100; //利確
input int SLPoint = 100; //損切

input int tuning = 9;   //Land:9

//ティック時実行関数
void OnTick()
{

//決済用変数
   double price;
   
//hour
   int hour = Hour() + tuning;
   

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

//買いエントリ
   if(((TimeDayOfWeek(TimeLocal()) == 0) || (TimeDayOfWeek(TimeLocal()) == 1)) &&
      Seconds() < 1
      )
    {
     Print("サーバ分Minute()", Minute());
     Print("ローカル分TimeMinute(TimeLocal())", TimeMinute(TimeLocal()));
     Print("サーバ時間Hour()", Hour());
     Print("ローカル時間TimeHour(TimeLocal()", TimeHour(TimeLocal()));
     Print("サーバ日Day()", Day());
     Print("ローカル日TimeDay(TimeLocal())", TimeDay(TimeLocal()));
     Print("サーバ曜日DayOfWeek()", DayOfWeek());
     Print("ローカル曜日TimeDayOfWeek(TimeLocal())", TimeDayOfWeek(TimeLocal()));
     Print("サーバのタイムTimeCurrent()", TimeCurrent());
     Print("ローカルのタイムTimeLocal()", TimeLocal());
     Print("iClose(NULL,PERIOD_D1,1)", iClose(NULL,PERIOD_D1,1));
     Print("iClose(NULL,PERIOD_W1,1)", iClose(NULL,PERIOD_W1,1));
     Print("iClose(NULL,PERIOD_H1,1)", iClose(NULL,PERIOD_H1,1));
     Print("iOpen(NULL,PERIOD_D1,1)", iOpen(NULL,PERIOD_D1,1));
     Print("iOpen(NULL,PERIOD_W1,1)", iOpen(NULL,PERIOD_W1,1));
     Print("iOpen(NULL,PERIOD_H1,1)", iOpen(NULL,PERIOD_H1,1));   
     Print("ローカルとサーバ時間の差を調べる用");
    };



//買い注文利確
   if(pos == 1 &&
      Bid >= (TPPoint*_Point + price)
      )
        {result = OrderClose(Ticket,Lots,Bid,Slippage,clrNONE);
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
      DayOfWeek() == 5 &&
      Hour() == 20
      )
        {result = OrderClose(Ticket,Lots,Bid,Slippage,clrNONE);
         //email = SendMail(subject4,text);
         //Ticket=0;
         pos = 0;
        };
        
   if(pos == -1 &&
      DayOfWeek() == 5 &&
      Hour() == 20
      )
        {result = OrderClose(Ticket,Lots,Ask,Slippage,clrNONE);
         //email = SendMail(subject4,text);
         //Ticket=0;
         pos = 0;
        };

/*
//エントリ直後逆行で自動決済
   if(pos == 1 &&
      Open[1] > Close[1] &&
      diff > 3610 &&
      diff < 3620
      )
        {bool result = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
         email = SendMail(subject5,text);
        };
      
   if(pos == -1 &&
      Open[1] < Close[1] &&
      diff > 3610 &&
      diff < 3620
      )
        {bool result = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
         email = SendMail(subject5,text);
        };
*/
};

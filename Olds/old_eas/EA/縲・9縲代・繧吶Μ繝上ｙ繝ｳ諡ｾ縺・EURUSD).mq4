//+-----------------------------------------------------------------------+
//|                                                     ボリバン拾い EURUSD  |
//|                                                    Copyright (c) 2021 |
//+-----------------------------------------------------------------------+

/*EA概要
ボリバンで2σを超えてから落ちてきたところを拾う。
*/

#property strict                        //MT4パラメータ設定画面が変数名ではなく日本語表示される。

// マジックナンバー
#define MAGIC   39                     //マジックナンバー
#define COMMENT "ボリバン拾い EURUSD"        //MT4画面上左上のコメント表示

// 外部パラメータ
extern double Lots = 0.01;              //ロット数の調整、1000=0.01、100000=1ロット
extern int Slippage = 3;                //スリッページの設定、楽天証券の場合小数点3桁なので１ ポイント ＝ 0. 001、3は3銭

//チケット番号
int Ticket = 0;

//利確、損切幅
input int SLPoint = 100; //損切り幅（ポイント） 
input int TPPoint = 100; //利食い幅（ポイント）

//初期化関数
int OnInit()
{
  return INIT_SUCCEEDED;
}

//ティック時実行関数
void OnTick()
{
//ポジション変数（変数posに0をセッティング、以後ifの状況ごとにposに値を代入し管理）
   int pos = 0;

//オーダ決済用変数
   bool result;

//決済用変数
   double price;

//取引時間計算計算用変数
   long diff = TimeCurrent() - OrderOpenTime();

//取引時メール送信用変数
   string subject = "新規取引を開始しました";
   string text = "ボリバン拾い EURUSD";
   string subject2 = "利確決済しました";
   string subject3 = "損切決済しました";
   string subject4 = "金曜夜間のため決済しました";
   string subject5 = "エントリ直後逆行のため決済しました";
   bool email;

//サマータイム用処理
   int time1;
   int time2;

   if(DayOfYear() > 66 &&
      DayOfYear() < 310
      )
      {time1 = 4;
       time2 = 18;}
   else
      {time1 = 3;
       time2 = 17;}

//ifの状況ごとにposに値を代入し管理
   if((OrderSelect(Ticket, SELECT_BY_TICKET) == false)||
      (OrderSelect(Ticket, SELECT_BY_TICKET) == true && OrderMagicNumber() != MAGIC))
       pos = 0;

   if(OrderSelect(Ticket, SELECT_BY_TICKET) == true &&
      OrdersTotal() != 0 &&
      OrderType() == 0
      ) pos = 1; price = OrderOpenPrice();

   if(OrderSelect(Ticket, SELECT_BY_TICKET) == true &&
      OrdersTotal() != 0 &&
      OrderType() == 1
      ) pos = -1; price = OrderOpenPrice();

//ボリンジャーバンド
   double Upper1 = iBands (Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_UPPER,1);
   double Lower1 = iBands (Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_LOWER,1);
   double Main1 = iBands (Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_MAIN,1);

   double Upper2 = iBands (Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_UPPER,2);
   double Lower2 = iBands (Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_LOWER,2);
   double Main2 = iBands (Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_MAIN,2);

   double Upper3 = iBands (Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_UPPER,3);
   double Lower3 = iBands (Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_LOWER,3);
   double Main3 = iBands (Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_MAIN,3);

   double Upper4 = iBands (Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_UPPER,4);
   double Lower4 = iBands (Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_LOWER,4);
   double Main4 = iBands (Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_MAIN,4);

   double Upper5 = iBands (Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_UPPER,5);
   double Lower5 = iBands (Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_LOWER,5);
   double Main5 = iBands (Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_MAIN,5);

   double Upper6 = iBands (Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_UPPER,6);
   double Lower6 = iBands (Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_LOWER,6);
   double Main6 = iBands (Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_MAIN,6);

   double Upper7 = iBands (Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_UPPER,7);
   double Lower7 = iBands (Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_LOWER,7);
   double Main7 = iBands (Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_MAIN,7);

   double Upper8 = iBands (Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_UPPER,8);
   double Lower8 = iBands (Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_LOWER,8);
   double Main8 = iBands (Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_MAIN,8);

   double Upper9 = iBands (Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_UPPER,9);
   double Lower9 = iBands (Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_LOWER,9);
   double Main9 = iBands (Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_MAIN,9);

   double Upper10 = iBands (Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_UPPER,10);
   double Lower10 = iBands (Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_LOWER,10);
   double Main10 = iBands (Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_MAIN,10);

//買いエントリ
   if(pos == 0 &&
      Open[1] < Close[1] &&
      //Open[2] < Close[2] &&
      //Close[1] < Upper1 &&
      //Close[2] < Upper2 &&
     (Upper3 < High[3] || Upper4 < High[4] || Upper5 < High[5] || Upper6 < High[6] || Upper7 < High[7] || Upper8 < High[8] || Upper9 < High[9] || Upper10 < High[10]) &&
     ((Upper3+Main3)/2 > Close[3] ||(Upper4+Main4)/2 > Close[4]|| (Upper5+Main5)/2 > Close[5] || (Upper6+Main6)/2 > Close[6] || (Upper7+Main7)/2 > Close[7] || (Upper8+Main8)/2 > Close[8] || (Upper9+Main9)/2 > Close[9] || (Upper10+Main10)/2 > Close[10]) &&
      Hour() > time1 &&
      Hour() < time2 &&
      Minute() == 0 &&
      Seconds() < 10
     )
        {Ticket = OrderSend(NULL,OP_BUY,Lots,Ask,Slippage,0,0,NULL,MAGIC,0,Blue);
         email = SendMail(subject,text);
        };
        
//売りエントリ
    if(pos == 0 &&
       Open[1] > Close[1] &&
       //Open[2] > Close[2] &&
       //Close[1] < Lower1 &&
       //Close[2] < Lower2 &&
      (Lower3 > Low[3] || Lower4 > Low[4] || Lower5 > Low[5] || Lower6 > Low[6] || Lower7 > Low[7] || Lower8 > Low[8] || Lower9 > Low[9] || Lower10 > Low[10]) &&
      ((Lower3+Main3)/2 < Close[3] ||(Lower4+Main4)/2 < Close[4]|| (Lower5+Main5)/2 < Close[5] || (Lower6+Main6)/2 < Close[6] || (Lower7+Main7)/2 < Close[7] || (Lower8+Main8)/2 < Close[8] || (Lower9+Main9)/2 < Close[9] || (Lower10+Main10)/2 < Close[10]) &&
       Hour() > time1 &&
       Hour() < time2 &&
       Minute() == 0 &&
       Seconds() < 10
       )
         {Ticket = OrderSend(NULL,OP_SELL,Lots,Bid,Slippage,0,0,NULL,MAGIC,0,Red);
          email = SendMail(subject,text);
         };

//買い注文利確
   if(pos == 1 &&
      Bid >= (TPPoint*_Point + price)
      )
        {result = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
         email = SendMail(subject2,text);
        };

//売り注文利確
   if(pos == -1 &&
      Ask <= (price - TPPoint*_Point)
      )
        {result = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
         email = SendMail(subject2,text);
        };

//買い注文損切
   if(pos == 1 &&
      Bid <= (price - SLPoint*_Point)
      )
        {result = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
         email = SendMail(subject3,text);
        };

//売り注文損切
   if(pos == -1 &&
      Ask >= (SLPoint*_Point + price)
      )
        {result = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
         email = SendMail(subject3,text);
        };

//金曜夜間に自動決済
   if(pos == 1 &&
      DayOfWeek() == 5 &&
      Hour() == 20
      )
        {result = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
         email = SendMail(subject4,text);
        };
        
   if(pos == -1 &&
      DayOfWeek() == 5 &&
      Hour() == 20
      )
        {result = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
         email = SendMail(subject4,text);
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

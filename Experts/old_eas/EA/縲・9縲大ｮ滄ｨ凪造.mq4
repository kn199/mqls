//+------------------------------------------------------------------+
//|                                               3通貨相関(EURJPY)  |
//|                                               Copyright (c) 2021 |
//+------------------------------------------------------------------+

//3通貨を使ったトレード。
//USDJPY上昇（JPY弱）かつEURUSD上昇（EUR強）ならEUR強かつJPY弱になるはず。=>EURJPY買い
//USDJPY下降（JPY強）かつEURUSD下降（EUR弱）ならEUR弱かつJPY強になるはず。=>EURJPY売り

#property strict                        //MT4パラメータ設定画面が変数名ではなく日本語表示される。

// マジックナンバー
#define MAGIC   34                //マジックナンバー
#define COMMENT "3通貨相関(EURJPY)"   　　　 //MT4画面上左上のコメント表示

// 外部パラメータ
extern double Lots = 0.01;              //ロット数の調整、1000=0.01、100000=1ロット
extern int Slippage = 3;                //スリッページの設定、楽天証券の場合小数点3桁なので１ ポイント ＝ 0. 001、3は3銭

//チケット番号
int Ticket = 0;

//指標バッファ用の配列の宣言
double Buf[]; 

//利確、損切幅
input int SLPoint = 100; //損切り幅（ポイント） 
input int TPPoint = 100; //利食い幅（ポイント）

//値動き幅
input double cp = 0.01; //値幅ユーロ円用

//初期化関数
int OnInit()
{
  return 0;
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
   string text = "3通貨相関(EURJPY)";
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

//買いエントリ
   if(pos == 0 &&
      iOpen(NULL,PERIOD_M30,1) < iClose(NULL,PERIOD_M30,1) &&
      iOpen(NULL,PERIOD_M30,2) < iClose(NULL,PERIOD_M30,2) &&
      iOpen(NULL,PERIOD_M30,3) < iClose(NULL,PERIOD_M30,3) &&
      iOpen(NULL,PERIOD_M30,4) < iClose(NULL,PERIOD_M30,4) &&
      iOpen(NULL,PERIOD_H1,1) < iClose(NULL,PERIOD_H1,1) &&
      iOpen(NULL,PERIOD_H1,2) < iClose(NULL,PERIOD_H1,2) &&
      iOpen(NULL,PERIOD_H1,3) < iClose(NULL,PERIOD_H1,3) &&
      iOpen(NULL,PERIOD_H1,4) < iClose(NULL,PERIOD_H1,4) &&
      iOpen(NULL,PERIOD_H4,1) < iClose(NULL,PERIOD_H4,1) &&
      iOpen(NULL,PERIOD_H4,2) < iClose(NULL,PERIOD_H4,2) &&
      iOpen(NULL,PERIOD_H4,3) < iClose(NULL,PERIOD_H4,3) &&
      //iOpen(NULL,PERIOD_H4,4) < iClose(NULL,PERIOD_H4,4) &&
      //Hour() > time1 &&
      //Hour() < time2 &&
      (Minute() == 0 || Minute() == 30) &&
      Seconds() < 10
      )
        {Ticket = OrderSend(NULL,OP_BUY,Lots,Ask,Slippage,0,0,NULL,MAGIC,0,Blue);
         email = SendMail(subject,text);
        };

//売りエントリ
   if(pos == 0 &&
      iOpen(NULL,PERIOD_M30,1) > iClose(NULL,PERIOD_M30,1) &&
      iOpen(NULL,PERIOD_M30,2) > iClose(NULL,PERIOD_M30,2) &&
      iOpen(NULL,PERIOD_M30,3) > iClose(NULL,PERIOD_M30,3) &&
      iOpen(NULL,PERIOD_M30,4) > iClose(NULL,PERIOD_M30,4) &&
      iOpen(NULL,PERIOD_H1,1) > iClose(NULL,PERIOD_H1,1) &&
      iOpen(NULL,PERIOD_H1,2) > iClose(NULL,PERIOD_H1,2) &&
      iOpen(NULL,PERIOD_H1,3) > iClose(NULL,PERIOD_H1,3) &&
      iOpen(NULL,PERIOD_H1,4) > iClose(NULL,PERIOD_H1,4) &&
      iOpen(NULL,PERIOD_H4,1) > iClose(NULL,PERIOD_H4,1) &&
      iOpen(NULL,PERIOD_H4,2) > iClose(NULL,PERIOD_H4,2) &&
      iOpen(NULL,PERIOD_H4,3) > iClose(NULL,PERIOD_H4,3) &&
      //iOpen(NULL,PERIOD_H4,4) > iClose(NULL,PERIOD_H4,4) &&
      //Hour() > time1 &&
      //Hour() < time2 &&
      (Minute() == 0 || Minute() == 30) &&
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
        {result = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
         email = SendMail(subject5,text);
        };
      
   if(pos == -1 &&
      Open[1] < Close[1] &&
      diff > 3610 &&
      diff < 3620
      )
        {result = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
         email = SendMail(subject5,text);
        };
*/
};

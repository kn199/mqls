//+------------------------------------------------------------------+
//|                                              Daily 逆1128(EURJPY)|
//+------------------------------------------------------------------+
#property strict                        //MT4パラメータ設定画面が変数名ではなく日本語表示される。

// マジックナンバー
#define MAGIC 50                         //マジックナンバー
#define COMMENT "Daily 逆1128 EURJPY" 

// 外部パラメータ
extern double Lots = 0.01;              //ロット数の調整、1000=0.01、100000=1ロット
extern int Slippage = 3;                //スリッページの設定、楽天証券の場合小数点3桁なので１ ポイント ＝ 0. 001、3は3銭

//チケット番号
int Ticket = 0;

//利確、損切幅
input int SLPoint = 12; //損切り幅（ポイント） 
input int TPPoint = 12; //利食い幅（ポイント）

//値幅
input double cp = 0.5;

//取引時間計算計算用変数
long diff1 = TimeCurrent() - OrderOpenTime();
long diff2 = TimeCurrent() - OrderCloseTime();

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

//取引時メール送信用変数
   string subject = "新規取引を開始しました";
   string text = "Daily 逆1128 EURJPY";
   string subject2 = "利確決済しました";
   string subject3 = "損切決済しました";
   string subject4 = "金曜夜間のため決済しました";
   string subject5 = "エントリ直後逆行のため決済しました";
   bool email;
   int situation = 0;
   int patern = 0;


//サマータイム用処理
   int time1;

   if(DayOfYear() > 66 &&
      DayOfYear() < 310
      )
      {time1 = 2;}
   else
      {time1 = 1;}

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
      iOpen(NULL,PERIOD_M1,1) > iClose(NULL,PERIOD_M1,1) &&
      Seconds() < 10
      )
        {Ticket = OrderSend(NULL,OP_BUY,Lots,Ask,Slippage,0,0,NULL,MAGIC,0,Blue);
         situation = 1;
        };

//売りエントリ
   if(pos == 0 &&
      iOpen(NULL,PERIOD_M1,1) < iClose(NULL,PERIOD_M1,1) &&
      Seconds() < 10
      )
         {Ticket = OrderSend(NULL,OP_SELL,Lots,Bid,Slippage,0,0,NULL,MAGIC,0,Red);
          situation = 2;
         };

//買い注文利確
   if(pos == 1 &&
      Bid >= (TPPoint*_Point + price)
      )
        {result = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
         patern = 1;
        };

//売り注文利確
   if(pos == -1 &&
      Ask <= (price - TPPoint*_Point)
      )
        {result = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
         patern = 2;
        };

//買い注文損切
   if(pos == 1 &&
      Bid <= (price - SLPoint*_Point)
      )
        {result = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
         patern = 3;
        };

//売り注文損切
   if(pos == -1 &&
      Ask >= (SLPoint*_Point + price)
      )
        {result = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
         patern = 4;
        };

//金曜夜間に自動決済
   if(pos == 1 &&
      DayOfWeek() == 5 &&
      Hour() == 20
      )
        {result = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
         patern = 5;
        };
        
   if(pos == -1 &&
      DayOfWeek() == 5 &&
      Hour() == 20
      )
        {result = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
         patern = 6;
        };

//メール送信対応
   if(situation == 1)
       email = SendMail(subject,text);
       situation = 0;

   if(situation == 2)
       email = SendMail(subject,text);
       situation = 0;

   if(patern == 1)
       email = SendMail(subject2,text);
       patern = 0;

   if(patern == 2)
       email = SendMail(subject2,text);
       patern = 0;

   if(patern == 3)
       email = SendMail(subject3,text);
       patern = 0;

   if(patern == 4)
       email = SendMail(subject3,text);
       patern = 0;

   if(patern == 5)
       email = SendMail(subject4,text);
       patern = 0;

   if(patern == 6)
       email = SendMail(subject4,text);
       patern = 0;

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

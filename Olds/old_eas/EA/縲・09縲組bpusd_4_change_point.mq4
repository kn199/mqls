//+-----------------------------------------------------------------------+
//|                                            【109】gbpusd_4_change_point |
//|                                                    Copyright (c) 2021 |
//+-----------------------------------------------------------------------+
#property strict                        //MT4パラメータ設定画面が変数名ではなく日本語表示される。

// マジックナンバー
#define MAGIC 109                        //マジックナンバー
#define COMMENT "【109】gbpusd_4_change_point"  　       //MT4画面上左上のコメント表示

// 外部パラメータ
extern double Lots = 0.01;              //ロット数
extern int Slippage = 3;                //スリッページ

//チケット番号
int Ticket = 0;

//利確、損切幅
input int TPPoint = 900; //利確
input int SLPoint = 300; //損切

input int number = 240;  //時間足
//1,5,15,30,60,240,1440

input int cp =100000;

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
   string text = "【109】gbpusd_4_change_point";
   string subject2 = "利確決済しました";
   string subject3 = "損切決済しました";
   string subject4 = "金曜夜間のため決済しました";
   string subject5 = "エントリ直後逆行のため決済しました";

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
   if(iOpen("GBPUSD",number,1) > iOpen("GBPUSD",number,2) &&
      iOpen("GBPUSD",number,2) > iOpen("GBPUSD",number,3) &&
      iOpen("GBPUSD",number,3) > iOpen("GBPUSD",number,4) &&
      iOpen("GBPUSD",number,4) > iOpen("GBPUSD",number,5) &&
      iClose("GBPUSD",number,1) > iClose("GBPUSD",number,2) &&
      iClose("GBPUSD",number,2) > iClose("GBPUSD",number,3) &&
      iClose("GBPUSD",number,3) > iClose("GBPUSD",number,4) &&
      iClose("GBPUSD",number,4) > iClose("GBPUSD",number,5) &&
      iHigh("GBPUSD",number,1) > iHigh("GBPUSD",number,2) &&
      iHigh("GBPUSD",number,2) > iHigh("GBPUSD",number,3) &&
      iHigh("GBPUSD",number,3) > iHigh("GBPUSD",number,4) &&
      iHigh("GBPUSD",number,4) > iHigh("GBPUSD",number,5) &&
      iLow("GBPUSD",number,1) > iLow("GBPUSD",number,2) &&
      iLow("GBPUSD",number,2) > iLow("GBPUSD",number,3) &&
      iLow("GBPUSD",number,3) > iLow("GBPUSD",number,4) &&
      iLow("GBPUSD",number,4) > iLow("GBPUSD",number,5) &&
      diff  > cp &&
      Hour() > time1 &&
      Hour() < time2 &&
      Minute() == 0 &&
      Seconds() < 10 &&
      pos == 0
      )
        {Ticket = OrderSend("GBPUSD",OP_BUY,Lots,Ask,Slippage,0,0,NULL,MAGIC,0,Blue);
        };

//売りエントリ
   if(iOpen("GBPUSD",number,1) < iOpen("GBPUSD",number,2) &&
      iOpen("GBPUSD",number,2) < iOpen("GBPUSD",number,3) &&
      iOpen("GBPUSD",number,3) < iOpen("GBPUSD",number,4) &&
      iOpen("GBPUSD",number,4) < iOpen("GBPUSD",number,5) &&
      iClose("GBPUSD",number,1) < iClose("GBPUSD",number,2) &&
      iClose("GBPUSD",number,2) < iClose("GBPUSD",number,3) &&
      iClose("GBPUSD",number,3) < iClose("GBPUSD",number,4) &&
      iClose("GBPUSD",number,4) < iClose("GBPUSD",number,5) &&
      iHigh("GBPUSD",number,1) < iHigh("GBPUSD",number,2) &&
      iHigh("GBPUSD",number,2) < iHigh("GBPUSD",number,3) &&
      iHigh("GBPUSD",number,3) < iHigh("GBPUSD",number,4) &&
      iHigh("GBPUSD",number,4) < iHigh("GBPUSD",number,5) &&
      iLow("GBPUSD",number,1) < iLow("GBPUSD",number,2) &&
      iLow("GBPUSD",number,2) < iLow("GBPUSD",number,3) &&
      iLow("GBPUSD",number,3) < iLow("GBPUSD",number,4) &&
      iLow("GBPUSD",number,4) < iLow("GBPUSD",number,5) &&
      diff  > cp &&
      Hour() > time1 &&
      Hour() < time2 &&
      Minute() == 0 &&
      Seconds() < 10 &&
      pos == 0
      )
         {Ticket = OrderSend("GBPUSD",OP_SELL,Lots,Bid,Slippage,0,0,NULL,MAGIC,0,Red);
         };

//買い注文利確
   if(pos == 1 &&
      Bid >= (TPPoint*_Point + price)
      )
        {result = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
         //email = SendMail(subject2,text);
        };

//売り注文利確
   if(pos == -1 &&
      Ask <= (price - TPPoint*_Point)
      )
        {result = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
         //email = SendMail(subject2,text);
        };

//買い注文損切
   if(pos == 1 &&
      Bid <= (price - SLPoint*_Point)
      )
        {result = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
         //email = SendMail(subject3,text);
        };

//売り注文損切
   if(pos == -1 &&
      Ask >= (SLPoint*_Point + price)
      )
        {result = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
         //email = SendMail(subject3,text);
        };

//金曜夜間に自動決済
   if(pos == 1 &&
      DayOfWeek() == 5 &&
      Hour() == 20
      )
        {result = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
         //email = SendMail(subject4,text);
        };
        
   if(pos == -1 &&
      DayOfWeek() == 5 &&
      Hour() == 20
      )
        {result = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
         //email = SendMail(subject4,text);
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

//+-----------------------------------------------------------------------+
//|                                                      逆RSI3本線 USDJPY|
//|                                                    Copyright (c) 2021 |
//+-----------------------------------------------------------------------+
#property strict                        //MT4パラメータ設定画面が変数名ではなく日本語表示される。

// マジックナンバー
#define MAGIC 52                        //マジックナンバー
#define COMMENT "逆RSI3本線 USDJPY"   　 //MT4画面上左上のコメント表示

// 外部パラメータ
extern double Lots = 0.01;              //ロット数の調整、1000=0.01、100000=1ロット
extern int Slippage = 3;                //スリッページの設定、楽天証券の場合小数点3桁なので１ ポイント ＝ 0. 001、3は3銭

//チケット番号
int Ticket = 0;

//利確、損切幅
input int SLPoint = 100; //損切り幅（ポイント） 
input int TPPoint = 100; //利食い幅（ポイント）

//cp
input int high = 60; //rsi high
input int low = 40;  //rsi low
input int cp = 756000;  //diff


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
   string text = "逆RSI3本線 USDJPY";
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

//RSI
   double RSI1 = iRSI (               // RSI
                       Symbol(),      // 通貨ペア、MT4表示中のものにする処理
                       PERIOD_H1,     // 時間軸、現在表示の時間軸で返す処理
                       14,            // RSI期間、一般的には14
                       0,             // applied_price。終値は0
                       1              // バンドシフト 1
                       );

   double RSI2 = iRSI (               // RSI
                       Symbol(),      // 通貨ペア、MT4表示中のものにする処理
                       PERIOD_H1,     // 時間軸、現在表示の時間軸で返す処理
                       14,            // RSI期間、一般的には14
                       0,             // applied_price。終値は0
                       2              // バンドシフト 2
                       );

   double RSI3 = iRSI (               // RSI
                       Symbol(),      // 通貨ペア、MT4表示中のものにする処理
                       PERIOD_H1,     // 時間軸、現在表示の時間軸で返す処理
                       14,            // RSI期間、一般的には14
                       0,             // applied_price。終値は0
                       3              // バンドシフト 3
                       );

   double RSI4 = iRSI (               // RSI
                       Symbol(),      // 通貨ペア、MT4表示中のものにする処理
                       PERIOD_H1,     // 時間軸、現在表示の時間軸で返す処理
                       14,            // RSI期間、一般的には14
                       0,             // applied_price。終値は0
                       4              // バンドシフト 4
                       );

   double RSI5 = iRSI (               // RSI
                       Symbol(),      // 通貨ペア、MT4表示中のものにする処理
                       PERIOD_H1,     // 時間軸、現在表示の時間軸で返す処理
                       14,            // RSI期間、一般的には14
                       0,             // applied_price。終値は0
                       5              // バンドシフト 5
                       );
   double RSI6 = iRSI (               // RSI
                       Symbol(),      // 通貨ペア、MT4表示中のものにする処理
                       PERIOD_H1,     // 時間軸、現在表示の時間軸で返す処理
                       14,            // RSI期間、一般的には14
                       0,             // applied_price。終値は0
                       6              // バンドシフト 6
                       );

   double RSI7 = iRSI (               // RSI
                       Symbol(),      // 通貨ペア、MT4表示中のものにする処理
                       PERIOD_H1,     // 時間軸、現在表示の時間軸で返す処理
                       14,            // RSI期間、一般的には14
                       0,             // applied_price。終値は0
                       7              // バンドシフト 7
                       );

   double RSI8 = iRSI (               // RSI
                       Symbol(),      // 通貨ペア、MT4表示中のものにする処理
                       PERIOD_H1,     // 時間軸、現在表示の時間軸で返す処理
                       14,            // RSI期間、一般的には14
                       0,             // applied_price。終値は0
                       8              // バンドシフト 8
                       );

//買いエントリ
   if(iOpen(NULL,PERIOD_H1,1) > iClose(NULL,PERIOD_H1,1) &&
      iOpen(NULL,PERIOD_H1,2) > iClose(NULL,PERIOD_H1,2) &&
      iOpen(NULL,PERIOD_H1,3) > iClose(NULL,PERIOD_H1,3) &&
      Hour() > time1 &&
      Hour() < time2 &&
      Minute() == 0 &&
      Seconds() < 10 &&
      pos == 0 &&
      diff > cp &&
      (RSI1 >= high || RSI2 >= high || RSI3 >= high || RSI4 >= high || RSI5 >= high || RSI6 >= high || RSI7 >= high || RSI8 >= high)
      )
        {Ticket = OrderSend(NULL,OP_BUY,Lots,Ask,Slippage,0,0,NULL,MAGIC,0,Blue);
         email = SendMail(subject,text);
        };

//売りエントリ
   if(iOpen(NULL,PERIOD_H1,1) < iClose(NULL,PERIOD_H1,1) &&
      iOpen(NULL,PERIOD_H1,2) < iClose(NULL,PERIOD_H1,2) &&
      iOpen(NULL,PERIOD_H1,3) < iClose(NULL,PERIOD_H1,3) &&
      Hour() > time1 &&
      Hour() < time2 &&
      Minute() == 0 &&
      Seconds() < 10 &&
      pos == 0 &&
      diff > cp &&
      (RSI1 <= low || RSI2 <= low || RSI3 <= low || RSI4 <= low || RSI5 <= low || RSI6 <= low || RSI7 <= low || RSI8 <= low)
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

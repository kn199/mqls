//+-----------------------------------------------------------------------+
//|                                       【54】usdjpy_1d_three_change_point|
//|                                                    Copyright (c) 2021 |
//+-----------------------------------------------------------------------+
#property strict                        //MT4パラメータ設定画面が変数名ではなく日本語表示される。

// マジックナンバー
#define MAGIC 113                        //マジックナンバー
#define COMMENT "【54】usdjpy_1d_three_change_point"  　       //MT4画面上左上のコメント表示

// 外部パラメータ
extern double Lots = 0.01;              //ロット数
extern int Slippage = 3;                //スリッページ

//チケット番号
int Ticket = 0;

//利確、損切幅
input int TPPoint = 350; //利確
input int SLPoint = 200; //損切

//cp
extern double cp = 1.1; //レンジ

input string currency = "USDJPY";
input int number = 60;  //time

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
   string text = "【54】usdjpy_1d_three_change_point";
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

//ボリンジャーバンド
   double Upper = iBands (               // ボリンジャーバンドアッパー線
                          Symbol(),      // 通貨ペア、MT4表示中のものにする処理
                          number,      // 時間軸、現在表示の時間軸で返す処理
                          20,            // 平均期間
                          2,             // 標準偏差
                          0,             // バンドシフト
                          PRICE_CLOSE,   // 適用価格（ローソク終値）
                          MODE_UPPER,    // ラインインデックス
                          0              // シフト:0
                          );                 

   double Lower = iBands (               // ボリンジャーバンドロウアー線
                          Symbol(),      // 通貨ペア、MT4表示中のものにする処理
                          number,      // 時間軸、現在表示の時間軸で返す処理
                          20,            // 平均期間
                          2,             // 標準偏差
                          0,             // バンドシフト
                          PRICE_CLOSE,   // 適用価格（ローソク終値）
                          MODE_LOWER,    // ラインインデックス
                          0              // シフト:0
                          );

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
   if(iOpen(currency,number,1) < iClose(currency,number,1) &&
      iOpen(currency,number,2) > iClose(currency,number,2) &&
      iOpen(currency,number,3) > iClose(currency,number,3) &&
      iOpen(currency,number,4) > iClose(currency,number,4) &&
      iOpen(currency,number,5) > iClose(currency,number,5) &&
      Hour() > time1 &&
      Hour() < time2 &&
      Minute() == 0 &&
      Seconds() < 10 &&
      DayOfWeek() != 1 &&
      Upper - Lower > cp &&
      pos == 0
      )
        {Ticket = OrderSend(currency,OP_BUY,Lots,Ask,Slippage,0,0,NULL,MAGIC,0,Blue);
        };


//買い注文利確
   if(pos == 1 &&
      Bid >= (TPPoint*_Point + price)
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

//金曜夜間に自動決済
   if(pos == 1 &&
      DayOfWeek() == 5 &&
      Hour() == 20
      )
        {result = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
         //email = SendMail(subject4,text);
        };
        
};

//+-----------------------------------------------------------------------+
//|                                                 【96】merge_51buy_87sell|
//|                                                    Copyright (c) 2021 |
//+-----------------------------------------------------------------------+
#property strict                        //MT4パラメータ設定画面が変数名ではなく日本語表示される。

// マジックナンバー
#define MAGIC 96                        //マジックナンバー
#define COMMENT "【96】merge_51buy_87sell"  　       //MT4画面上左上のコメント表示

// 外部パラメータ
extern double Lots = 0.01;              //ロット数
extern int Slippage = 3;                //スリッページ

//チケット番号
int Ticket = 0;

//利確、損切幅
input int TPPoint = 600; //利確
input int SLPoint = 500; //損切

//cp
extern double cp = 0.06; //値動き幅
input int cp2 = 1000000;  //diff

input int number = 1440;  //時間足
//1,5,15,30,60,240,1440

input string currency = "EURJPY";

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
   string text = "【96】merge_51buy_87sell";
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

//移動平均線
   double MA1_1h = iMA(
                       "EURJPY",      // 通貨ペア、MT4表示中のものにする処理
                       PERIOD_H1,     // 時間軸、現在表示の時間軸で返す処理
                       5,             // 平均期間
                       0,             // 移動平均シフト
                       MODE_SMA,      // 適用価格（ローソク終値）
                       MODE_UPPER,    // ラインインデックス
                       0              // シフト:0
                       );
                   
   double MA2_1h =iMA(
                      "EURJPY",      // 通貨ペア、MT4表示中のものにする処理
                      PERIOD_H1,     // 時間軸、現在表示の時間軸で返す処理
                      25,            // 平均期間
                      0,             // 移動平均シフト
                      MODE_SMA,      // 適用価格（ローソク終値）
                      MODE_UPPER,    // ラインインデックス
                      0              // シフト:0
                      );
 
   double MA3_1h =iMA(
                      "EURJPY",      // 通貨ペア、MT4表示中のものにする処理
                      PERIOD_H1,     // 時間軸、現在表示の時間軸で返す処理
                      75,            // 平均期間
                      0,             // 移動平均シフト
                      MODE_SMA,      // 適用価格（ローソク終値）
                      MODE_UPPER,    // ラインインデックス
                      0              // シフト:0
                      );

   double MA4_1h = iMA(
                       "EURJPY",      // 通貨ペア、MT4表示中のものにする処理
                       PERIOD_H1,     // 時間軸、現在表示の時間軸で返す処理
                       5,             // 平均期間
                       0,             // 移動平均シフト
                       MODE_SMA,      // 適用価格（ローソク終値）
                       MODE_UPPER,    // ラインインデックス
                       1              // シフト:1
                       );
                   
   double MA5_1h =iMA(
                      "EURJPY",      // 通貨ペア、MT4表示中のものにする処理
                      PERIOD_H1,     // 時間軸、現在表示の時間軸で返す処理
                      25,            // 平均期間
                      0,             // 移動平均シフト
                      MODE_SMA,      // 適用価格（ローソク終値）
                      MODE_UPPER,    // ラインインデックス
                      1              // シフト:1
                      );
 
   double MA6_1h =iMA(
                      "EURJPY",      // 通貨ペア、MT4表示中のものにする処理
                      PERIOD_H1,     // 時間軸、現在表示の時間軸で返す処理
                      75,            // 平均期間
                      0,             // 移動平均シフト
                      MODE_SMA,      // 適用価格（ローソク終値）
                      MODE_UPPER,    // ラインインデックス
                      1              // シフト:1
                      );

   double MA1_4h = iMA(
                       "EURJPY",      // 通貨ペア、MT4表示中のものにする処理
                       PERIOD_H4,     // 時間軸、現在表示の時間軸で返す処理
                       5,             // 平均期間
                       0,             // 移動平均シフト
                       MODE_SMA,      // 適用価格（ローソク終値）
                       MODE_UPPER,    // ラインインデックス
                       0              // シフト:0
                       );

   double MA2_4h = iMA(
                       "EURJPY",      // 通貨ペア、MT4表示中のものにする処理
                       PERIOD_H4,     // 時間軸、現在表示の時間軸で返す処理
                       25,            // 平均期間
                       0,             // 移動平均シフト
                       MODE_SMA,      // 適用価格（ローソク終値）
                       MODE_UPPER,    // ラインインデックス
                       0              // シフト:0
                       );
   
//買いエントリ
   if(pos == 0 &&
      iOpen(currency,PERIOD_H1,1) < iClose(currency,PERIOD_H1,1) &&
      iOpen(currency,PERIOD_D1,1) < iClose(currency,PERIOD_D1,1) &&
      MA1_4h > MA2_4h &&   //1時間足で5本線が25本線より高いこと
      MA1_1h > MA2_1h &&   //4時間足でも5本線が25本線より高いこと
      MA4_1h < MA5_1h &&   //ローソク1本右にずらした平均線ではまだGクロスが起きていないこと、クロスした直後にエントリする狙い
      diff > cp &&
      Hour() > time1 &&
      Hour() < time2 &&
      Minute() == 0 &&
      Seconds() < 10      
      )
        {Ticket = OrderSend(currency,OP_BUY,Lots,Ask,Slippage,0,0,NULL,MAGIC,0,Blue);
         //email = SendMail(subject,text);
        };

//売りエントリ
   if(iOpen(currency,number,1) - cp > iClose(currency,number,1) &&
      iOpen(currency,number,2) - cp > iClose(currency,number,2) &&
      iOpen(currency,number,3) < iClose(currency,number,3) &&
      Hour() == time1 &&
      Minute() == 0 &&
      Seconds() < 10 &&
      DayOfWeek() != 1 &&
      diff > cp2 &&
      pos == 0
      )
         {Ticket = OrderSend(currency,OP_SELL,Lots,Bid,Slippage,0,0,NULL,MAGIC,0,Red);
          //email = SendMail(subject,text);
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

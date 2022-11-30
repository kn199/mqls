//+-----------------------------------------------------------------------+
//|                                                 【67】usdjpy_momentum_1h|
//|                                                    Copyright (c) 2021 |
//+-----------------------------------------------------------------------+
#property strict                       //MT4パラメータ設定画面が変数名ではなく日本語表示される。

// マジックナンバー
#define MAGIC  67                 //マジックナンバー
#define COMMENT "【67】usdjpy_momentum_1h"    //MT4画面上左上のコメント表示

// 外部パラメータ
extern double Lots = 0.01;              //ロット数の調整、1000=0.01、100000=1ロット
extern int Slippage = 3;                //スリッページの設定、楽天証券の場合小数点3桁なので１ ポイント ＝ 0. 001、3は3銭

//チケット番号
int Ticket = 0;

//利確、損切幅
input int TPPoint = 600; //利確
input int SLPoint = 600; //損切 

extern double low = 99.6; //low
extern double high = 100.5; //high

input int number = 60;  //時間足
//1,5,15,30,60,240,1440

input string currency = "USDJPY";

input int cp = 0; //diff

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
   //bool result;

//決済用変数
   double price;

//取引時間計算計算用変数
   long diff = TimeCurrent() - OrderOpenTime();

//取引時メール送信用変数
   string subject = "新規取引を開始しました";
   string text = "【67】usdjpy_momentum_1h";
   string subject2 = "利確決済しました";
   string subject3 = "損切決済しました";
   string subject4 = "金曜夜間のため決済しました";
   string subject5 = "直後逆行のため決済しました";

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
   
//モメンタム 100以上で買い、100以下で売り
   double momentum1 = iMomentum (               // モメンタム
                                 currency,      // 通貨ペア、MT4表示中のものにする処理
                                 number,        // 時間軸、現在表示の時間軸で返す処理
                                 14,            // モメンタム期間、一般的には14
                                 0,             // applied_price。終値は0
                                 1              // シフト1
                                 );

   double momentum2 = iMomentum (               // モメンタム
                                 currency,      // 通貨ペア、MT4表示中のものにする処理
                                 number,      // 時間軸、現在表示の時間軸で返す処理
                                 14,            // モメンタム期間、一般的には14
                                 0,             // applied_price。終値は0
                                 2              // シフト2
                                 );

   double momentum3 = iMomentum (               // モメンタム
                                 currency,      // 通貨ペア、MT4表示中のものにする処理
                                 number,      // 時間軸、現在表示の時間軸で返す処理
                                 14,            // モメンタム期間、一般的には14
                                 0,             // applied_price。終値は0
                                 3              // シフト3
                                 );

   double momentum4 = iMomentum (               // モメンタム
                                 currency,      // 通貨ペア、MT4表示中のものにする処理
                                 number,      // 時間軸、現在表示の時間軸で返す処理
                                 14,            // モメンタム期間、一般的には14
                                 0,             // applied_price。終値は0
                                 4              // シフト4
                                 );

   double momentum5 = iMomentum (               // モメンタム
                                 currency,      // 通貨ペア、MT4表示中のものにする処理
                                 number,      // 時間軸、現在表示の時間軸で返す処理
                                 14,            // モメンタム期間、一般的には14
                                 0,             // applied_price。終値は0
                                 5              // シフト5
                                 );

//買いエントリ
    if(iOpen(currency,number,1) < iClose(currency,number,1) &&
       Hour() > time1 &&
       Hour() < time2 &&
       Minute() == 0 &&
       Seconds() < 10 &&
       pos == 0 &&
       diff > cp &&
      (momentum1 <= low || momentum2 <= low || momentum3 <= low || momentum4 <= low || momentum5 <= low)
       )
         {Ticket = OrderSend(currency,OP_SELL,Lots,Bid,Slippage,Bid+(SLPoint*_Point),Bid-(TPPoint*_Point),NULL,MAGIC,0,Red );
         };
        
//売りエントリ
    if(iOpen(currency,number,1) > iClose(currency,number,1) &&
       Hour() > time1 &&
       Hour() < time2 &&
       Minute() == 0 &&
       Seconds() < 10 &&
       pos == 0 &&
       diff > cp &&
       (momentum1 >= high || momentum2 >= high || momentum3 >= high || momentum4 >= high || momentum5 >= high)
       )
        {Ticket = OrderSend(currency,OP_BUY,Lots,Ask,Slippage,Ask-(SLPoint*_Point),Ask+(TPPoint*_Point),NULL,MAGIC,0,Blue );
        };

                     
//金曜夜間に自動決済
   if(pos == 1 &&
      DayOfWeek() == 5 &&
      Hour() == 20
      )
       {Ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
       };

   if(pos == -1 &&
      DayOfWeek() == 5 &&
      Hour() == 20
      )
       {Ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
       };
};

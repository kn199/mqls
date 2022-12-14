//+------------------------------------------------------------------+
//|                                      【68】usdjpy_buy_1h_2down_2up |
//|                                               Copyright (c) 2021 |
//+------------------------------------------------------------------+
#property strict                        //MT4パラメータ設定画面が変数名ではなく日本語表示される。

// マジックナンバー
#define MAGIC   68                   //マジックナンバー
#define COMMENT "【68】usdjpy_buy_1h_2down_2up"          //MT4画面上左上のコメント表示

// 外部パラメータ
extern double Lots = 0.01;              //ロット数の調整、1000=0.01、100000=1ロット
extern int Slippage = 3;                //スリッページの設定、楽天証券の場合小数点3桁なので１ ポイント ＝ 0. 001、3は3銭

//チケット番号
int Ticket = 0;

//指標バッファ用の配列の宣言
double Buf[]; 

//利確、損切幅
input int TPPoint = 600; //利確
input int SLPoint = 600; //損切 

extern double cp = 0.002; //値幅

input int number = 60;  //時間足
//1,5,15,30,60,240,1440

input string currency = "USDJPY";

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
   string text = "【68】usdjpy_buy_1h_2down_2up";
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

//買いエントリ
   if(pos == 0 &&
      iOpen(currency,number,1) + cp < iClose(currency,number,1) &&
      iOpen(currency,number,2) + cp < iClose(currency,number,2) &&
      iOpen(currency,number,3) > iClose(currency,number,3) + cp &&
      iOpen(currency,number,4) > iClose(currency,number,4) + cp &&
      Hour() > time1 &&
      Hour() < time2 &&
      Minute() == 0 &&
      Seconds() < 10
      )
        {Ticket = OrderSend(currency,OP_BUY,Lots,Ask,Slippage,0,0,NULL,MAGIC,0,Blue);
        };
        
//売りエントリ
   if(pos == 0 &&
      iOpen(currency,number,1) > iClose(currency,number,1) + cp &&
      iOpen(currency,number,2) > iClose(currency,number,2) + cp &&
      iOpen(currency,number,3) + cp < iClose(currency,number,3) &&
      iOpen(currency,number,4) + cp < iClose(currency,number,4) &&
      Hour() > time1 &&
      Hour() < time2 &&
      Minute() == 0 &&
      Seconds() < 10
      )
         {Ticket = OrderSend(currency,OP_SELL,Lots,Bid,Slippage,0,0,NULL,MAGIC,0,Red);
         };

//買い注文利確
   if(pos == 1 &&
      Bid >= (TPPoint*_Point + price)
      )
        {result = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
        };

//売り注文利確
   if(pos == -1 &&
      Ask <= (price - TPPoint*_Point)
      )
        {result = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
        };

//買い注文損切
   if(pos == 1 &&
      Bid <= (price - SLPoint*_Point)
      )
        {result = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
        };

//売り注文損切
   if(pos == -1 &&
      Ask >= (SLPoint*_Point + price)
      )
        {result = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
        };

};

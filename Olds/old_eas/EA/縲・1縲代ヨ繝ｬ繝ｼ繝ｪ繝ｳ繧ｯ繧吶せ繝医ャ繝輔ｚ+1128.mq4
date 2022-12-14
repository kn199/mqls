//+------------------------------------------------------------------+
//|                                                  トレーリングストップ  |
//|                                               Copyright (c) 2021 |
//+------------------------------------------------------------------+
#property strict                        //MT4パラメータ設定画面が変数名ではなく日本語表示される。

// マジックナンバー
#define MAGIC   11                //マジックナンバー
#define COMMENT "トレーリングストップ"   //MT4画面上左上のコメント表示

// 外部パラメータ
extern double Lots = 0.01;              //ロット数の調整、1000=0.01、100000=1ロット
extern int Slippage = 3;                //スリッページの設定、楽天証券の場合小数点3桁なので１ ポイント ＝ 0. 001、3は3銭

extern double ChangePoint = 0.15;       //ローソクの変化値。設定から変更できるよう、外部パラメータ化

//チケット番号
int Ticket = 0;

//指標バッファ用の配列の宣言
double Buf[]; 

//利確、損切幅
input int SLPoint = 100; //損切り幅（ポイント） 
input int TPPoint = 100; //利食い幅（ポイント）

//トレーリングストップ幅
input double TrailingStop =50;

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
   string text = "サンプル②";
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
      Open[1] + 0.15 < Close[1] &&
      Hour() > time1 &&
      Hour() < time2 &&
      Minute() == 0
      )
        {Ticket = OrderSend(NULL,OP_BUY,Lots,Ask,Slippage,0,0,NULL,MAGIC,0,Blue);
         email = SendMail(subject,text);
        };
        
//売りエントリ
    if(pos == 0 &&
       Open[1] - 0.15 > Close[1] && 
       Hour() > time1 &&
       Hour() < time2 &&
       Minute() == 0
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
  
//トレイリングストップ   
   if( TrailingStop > 0 &&                          //トレーリングストップ発動条件①パラメーター「TrailingStop」でトレール幅を設定していること
       Bid-OrderOpenPrice()>Point*TrailingStop &&   //トレーリングストップ発動条件②現在価格から建値（OrderOpenPrice()）を引いた額がトレール幅より大きい
       OrderStopLoss()<Bid-Point*TrailingStop)      //トレーリングストップ発動条件③逆指値（OrderStopLoss）が、現在価格からトレール幅を差し引いた値よりも小さい
       
        Ticket = OrderModify(                       //トレーリングストップ機能
                    OrderTicket(),                  //チケット
                    OrderOpenPrice(),               //新しい注文
                    Ask+Point*TrailingStop,         //新しい逆指値
                    OrderTakeProfit(),              //新しい指値
                    0,                              //有効期限
                    Red);                           //色
       
   
   if( TrailingStop > 0 &&                          //トレーリングストップ発動条件①パラメーター「TrailingStop」でトレール幅を設定していること
       OrderOpenPrice()-Ask >(Point*TrailingStop) &&  ///トレーリングストップ発動条件②建値（OrderOpenPrice）から現在の価格を引いた値がトレール幅より大きい
       OrderStopLoss()> ((Ask+Point*TrailingStop)) || (OrderStopLoss()==0))   //トレーリングストップ発動条件③逆指値（OrderStopLoss）が、現在の価格にトレール幅を加えた値よりも大きい
       
        Ticket = OrderModify(                       //トレーリングストップ機能
                    OrderTicket(),                  //チケット
                    OrderOpenPrice(),               //新しい注文
                    Bid-Point*TrailingStop,         //新しい逆指値
                    OrderTakeProfit(),              //新しい指値
                    0,                              //有効期限
                    Blue);                          //色
       
   
                     
//金曜夜間に自動決済
   if(pos == 1 &&
      DayOfWeek() == 5 &&
      Hour() == 20
      )
       {Ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
       email = SendMail(subject2,text);
       };

   if(pos == -1 &&
      DayOfWeek() == 5 &&
      Hour() == 20
      )
       {Ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
       email = SendMail(subject2,text);
       };
};

//+-----------------------------------------------------------------------+
//|                                             【62】eurusd_1d_change_point|
//|                                                    Copyright (c) 2021 |
//+-----------------------------------------------------------------------+
#property strict                        //MT4パラメータ設定画面が変数名ではなく日本語表示される。

// マジックナンバー
#define MAGIC 555                        //マジックナンバー

// 外部パラメータ
extern double Lots = 0.01;              //ロット数
extern int Slippage = 3;                //スリッページ

//チケット番号
int Ticket = 0;

//利確、損切幅
input int TPPoint = 200; //利確
input int SLPoint = 200; //損切

input int number = 240;  //時間足
//1,5,15,30,60,240,1440

input string currency = "EURUSD";

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
   string text = "【62】eurusd_1d_change_point";
   string subject2 = "利確決済しました";
   string subject3 = "損切決済しました";
   string subject4 = "金曜夜間のため決済しました";
   string subject5 = "エントリ直後逆行のため決済しました";
   bool email;

//time計算
datetime order_open_time = OrderOpenTime();
datetime current_time = TimeCurrent();

int order_open_month =
//StringToIntegerで文字列を整数型に変更する。引数：datetime型のOrderOpenTime()をTimeToStrで文字列に変換
StringToInteger(
//StringGetChar：文字列の指定した位置の文字コードを返す。datetime型で月の部分だけ抽出する。
StringGetChar(
//TimeToStrでdatetime型のOrderOpenTime()を文字列に変換,TIME_DATE："yyyy.mm.dd"で出力される。//StringGetCharでは左端が0であり、mmの一字目は5、二字目は6となる。
(TimeToStr(order_open_time,TIME_DATE)),5) +
//連結
StringGetChar(
//TimeToStrでdatetime型のOrderOpenTime()を文字列に変換,TIME_DATE："yyyy.mm.dd"で出力される。//StringGetCharでは左端が0であり、mmの一字目は5、二字目は6となる。
(TimeToStr(order_open_time,TIME_DATE)),6)
//↑ここまでがStringGetCharの引数
);
//↑ここまでがStringToIntegerの引数

int order_open_day =
StringToInteger(
StringGetChar(
(TimeToStr(order_open_time,TIME_DATE)),8) +
StringGetChar(
(TimeToStr(order_open_time,TIME_DATE)),9)
);

int current_month =
StringToInteger(
StringGetChar(
(TimeToStr(current_time,TIME_DATE)),5) +
StringGetChar(
(TimeToStr(current_time,TIME_DATE)),6)
);

int current_day =
StringToInteger(
StringGetChar(
(TimeToStr(current_time,TIME_DATE)),8) +
StringGetChar(
(TimeToStr(current_time,TIME_DATE)),9)
);

bool diff;

if(current_month - order_open_month >= 1)
{diff = true;}
else if (current_month == order_open_month && current_day - order_open_day >= 20)
{diff = true;}
else
{diff = false;}

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
   if(iOpen(currency,number,1) < iClose(currency,number,1) &&
      Minute() == 0 &&
      Seconds() < 10 &&
      diff > true &&
      pos == 0
      )
        {Ticket = OrderSend(currency,OP_BUY,Lots,Ask,Slippage,0,0,NULL,MAGIC,0,Blue);
         //email = SendMail(subject,text);
        };

//売りエントリ
   if(iOpen(currency,number,1) > iClose(currency,number,1) &&
      Minute() == 0 &&
      Seconds() < 10 &&
      diff > true &&
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

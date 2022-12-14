//+-----------------------------------------------------------------------+
//|                                                     【78】usdjpy_5m_rsi|
//|                                                      Copyright (c) 7 |
//+-----------------------------------------------------------------------+
#property strict                        //MT4パラメータ設定画面が変数名ではなく日本語表示される。

// マジックナンバー
#define MAGIC 78                       //マジックナンバー
#define COMMENT "【78】usdjpy_5m_rsi" 

// 外部パラメータ
extern double Lots = 0.01;              //ロット数の調整、1000=0.01、100000=1ロット
extern int Slippage = 3;                //スリッページの設定、楽天証券の場合小数点3桁なので１ ポイント ＝ 0. 001、3は3銭

//チケット番号
int Ticket = 0;

//利確、損切幅
input int TPPoint = 360; //利食い幅（ポイント）
input int SLPoint = 150; //損切り幅（ポイント） 

//RSI数値
input int point1 = 25;
input int point2 = 75;

//cp
input int long_bar = 15;  //長時間足
input int short_bar = 5;  //短時間足
//1,5,15,30,60,240,1440

input int cp = 1000000;  //diff

int hour1;
int hour2;

//ポジション変数（変数posに0をセッティング、以後ifの状況ごとにposに値を代入し管理）
int pos = 0;

//オーダ決済用変数
bool result;

//決済用変数
double price;

//初期化関数
int OnInit()
{
  return INIT_SUCCEEDED;
}

//ティック時実行関数
void OnTick()
{

//取引時間計算計算用変数
   long diff = TimeCurrent() - OrderOpenTime();

//取引時メール送信用変数
   string subject = "新規取引を開始しました";
   string text = "【78】usdjpy_5m_rsi";
   string subject2 = "利確決済しました";
   string subject3 = "損切決済しました";
   string subject4 = "金曜夜間のため決済しました";
   string subject5 = "エントリ直後逆行のため決済しました";
   bool email;

   if(DayOfYear() > 66 &&
      DayOfYear() < 310
      )
      {hour1 = 12;
       hour2 = 24;}
   else
      {hour1 = 11;
       hour2 = 23;}

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

//RSI Dairy バンドシフト1～4
   double RSIL1 = iRSI ("USDJPY",long_bar,14,0,1);
   double RSIL2 = iRSI ("USDJPY",long_bar,14,0,2);
   double RSIL3 = iRSI ("USDJPY",long_bar,14,0,3);
   double RSIL4 = iRSI ("USDJPY",long_bar,14,0,4);

   double RSIS1 = iRSI ("USDJPY",short_bar,14,0,1);
   double RSIS2 = iRSI ("USDJPY",short_bar,14,0,2);
   double RSIS3 = iRSI ("USDJPY",short_bar,14,0,3);
   double RSIS4 = iRSI ("USDJPY",short_bar,14,0,4);

//買いエントリ
   if(pos == 0 &&
      iOpen("USDJPY",long_bar,1) > iClose("USDJPY",long_bar,1) &&
      iOpen("USDJPY",short_bar,1) > iClose("USDJPY",short_bar,1) &&
      TimeHour(TimeLocal()) > hour1 &&
      TimeHour(TimeLocal()) < hour2 &&
      TimeMinute(TimeLocal()) == 0 &&
      diff > cp &&
     (RSIS1 >= point2 || RSIS2 >= point2 || RSIS3 >= point2 || RSIS4 >= point2) &&
     (RSIL1 >= point2 || RSIL2 >= point2 || RSIL3 >= point2 || RSIL4 >= point2) 
      )
        {Ticket = OrderSend("USDJPY",OP_BUY,Lots,Ask,Slippage,0,0,NULL,MAGIC,0,Blue);
         email = SendMail(subject,text);
        };

//売りエントリ
   if(pos == 0 &&
      iOpen("USDJPY",long_bar,1) < iClose("USDJPY",long_bar,1) &&
      iOpen("USDJPY",short_bar,1) < iClose("USDJPY",short_bar,1) && 
      TimeHour(TimeLocal()) > hour1 &&
      TimeHour(TimeLocal()) < hour2 &&
      TimeMinute(TimeLocal()) == 0 &&
      diff > cp &&
     (RSIS1 <= point1 || RSIS2 <= point1 || RSIS3 <= point1 || RSIS4 <= point1) &&
     (RSIL1 <= point1 || RSIL2 <= point1 || RSIL3 <= point1 || RSIL4 <= point1)
      )
         {Ticket = OrderSend("USDJPY",OP_SELL,Lots,Bid,Slippage,0,0,NULL,MAGIC,0,Red);
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
      TimeDayOfWeek(TimeLocal()) == 6
      )
        {result = OrderClose(Ticket,Lots,Bid,Slippage,clrNONE);
         //email = SendMail(subject4,text);
         //Ticket=0;
         pos = 0;
        };
        
   if(pos == -1 &&
      TimeDayOfWeek(TimeLocal()) == 6
      )
        {result = OrderClose(Ticket,Lots,Ask,Slippage,clrNONE);
         //email = SendMail(subject4,text);
         //Ticket=0;
         pos = 0;
        };
};

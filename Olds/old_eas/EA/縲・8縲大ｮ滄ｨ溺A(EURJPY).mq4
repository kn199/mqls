//+------------------------------------------------------------------+
//|                                                    実験MA EURJPY |
//|                                               Copyright (c) 2021 |
//+------------------------------------------------------------------+
#property strict                        //MT4パラメータ設定画面が変数名ではなく日本語表示される。

// マジックナンバー
#define MAGIC   18                   //マジックナンバー
#define COMMENT "実験MA EURJPY"       //MT4画面上左上のコメント表示

// 外部パラメータ
extern double Lots = 0.01;              //ロット数の調整、1000=0.01、100000=1ロット
extern int Slippage = 3;                //スリッページの設定、楽天証券の場合小数点3桁なので１ ポイント ＝ 0. 001、3は3銭

//チケット番号
int Ticket = 0;

//指標バッファ用の配列の宣言
double Buf[]; 

//利確、損切幅
input int SLPoint = 100; //損切り幅（ポイント） 
input int TPPoint = 100; //利食い幅（ポイント）

//change point
extern double cp1 = 0.07;
extern double cp2 = 0.15;

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
   string text = "実験MA EURJPY";
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
      
//移動平均線/MA1～MA7/5,25本線/シフト1～7
   double MA1_5 = iMA(Symbol(),Period(),5,0,MODE_SMA,MODE_UPPER,1);
   double MA1_25 = iMA(Symbol(),Period(),25,0,MODE_SMA,MODE_UPPER,1);

   double MA2_5 = iMA(Symbol(),Period(),5,0,MODE_SMA,MODE_UPPER,2);
   double MA2_25 = iMA(Symbol(),Period(),25,0,MODE_SMA,MODE_UPPER,2);

   double MA3_5 = iMA(Symbol(),Period(),5,0,MODE_SMA,MODE_UPPER,3);
   double MA3_25 = iMA(Symbol(),Period(),25,0,MODE_SMA,MODE_UPPER,3);

   double MA4_5 = iMA(Symbol(),Period(),5,0,MODE_SMA,MODE_UPPER,4);
   double MA4_25 = iMA(Symbol(),Period(),25,0,MODE_SMA,MODE_UPPER,4);

   double MA5_5 = iMA(Symbol(),Period(),5,0,MODE_SMA,MODE_UPPER,5);
   double MA5_25 = iMA(Symbol(),Period(),25,0,MODE_SMA,MODE_UPPER,5);

   double MA6_5 = iMA(Symbol(),Period(),5,0,MODE_SMA,MODE_UPPER,6);
   double MA6_25 = iMA(Symbol(),Period(),25,1,MODE_SMA,MODE_UPPER,6);

   double MA7_5 = iMA(Symbol(),Period(),5,0,MODE_SMA,MODE_UPPER,7);
   double MA7_25 = iMA(Symbol(),Period(),25,0,MODE_SMA,MODE_UPPER,7);
   
//5-25 MA乖離計算結果
   double ma1 = MA1_5 - MA1_25;
   double ma2 = MA2_5 - MA2_25;
   double ma3 = MA3_5 - MA3_25;
   double ma4 = MA4_5 - MA4_25;
   double ma5 = MA5_5 - MA5_25;
   double ma6 = MA6_5 - MA6_25;
   double ma7 = MA7_5 - MA7_25;

//-数値 → +数値化
   if(ma1<0) ma1 = (MA1_5 - MA1_25)*-1;
   if(ma2<0) ma2 = (MA2_5 - MA2_25)*-1;
   if(ma3<0) ma3 = (MA3_5 - MA3_25)*-1;
   if(ma4<0) ma4 = (MA4_5 - MA4_25)*-1;
   if(ma5<0) ma5 = (MA5_5 - MA5_25)*-1;
   if(ma6<0) ma6 = (MA6_5 - MA6_25)*-1;
   if(ma7<0) ma7 = (MA7_5 - MA7_25)*-1;

//買いエントリ
   if(pos == 0 &&
      //Open[1] < Close[1] &&
     ((ma3 < cp1) || (ma4 < cp1) || (ma5 < cp1) || (ma6 < cp1) || (ma7 < cp1)) && 
     ((ma1 > cp2) || (ma2 > cp2)) &&
      MA1_5 > MA1_25 &&
      Hour() > time1 &&
      Hour() < time2 &&
      Minute() == 0 &&
      Seconds() < 10
      )
        {Ticket = OrderSend(NULL,OP_BUY,Lots,Ask,Slippage,0,0,NULL,MAGIC,0,Blue);
         email = SendMail(subject,text);
        };

//売りエントリ
   if(pos == 0 &&
      //Open[1] > Close[1] &&
     ((ma3 < cp1) || (ma4 < cp1) || (ma5 < cp1) || (ma6 < cp1) || (ma7 < cp1)) && 
     ((ma1 > cp2) || (ma2 > cp2)) &&
      MA1_5 < MA1_25 &&
      Hour() > time1 &&
      Hour() < time2 &&
      Minute() == 0 &&
      Seconds() < 10
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
        email = SendMail(subject2,text);
       };

   if(pos == -1 &&
      DayOfWeek() == 5 &&
      Hour() == 20
      )
       {result = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
        email = SendMail(subject2,text);
       };

/*
//逆クロス時に決算
   if(pos == 1 &&
      MA1_4h < MA2_4h &&
      )
       {result = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
        email = SendMail(subject2,text);
       };

   if(pos == -1 &&
      MA1_4h > MA2_4h &&
      )
       {result = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
        email = SendMail(subject2,text);
       };

*/

/*
 //エントリ直後に自動決済
   if(pos == 1 &&
      Open[1] > Close[1] &&
      diff > 3610 &&
      diff < 3620
      )
        {result = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
         email = SendMail(subject2,text2);
        };
      
   if(pos == -1 &&
      Open[1] < Close[1] &&
      diff > 3610 &&
      diff < 3620
      )
        {result = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
         email = SendMail(subject2,text2);
        };

*/

};

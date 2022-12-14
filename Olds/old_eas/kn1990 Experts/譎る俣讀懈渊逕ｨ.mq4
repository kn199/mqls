#property strict                        //MT4パラメータ設定画面が変数名ではなく日本語表示される。

// マジックナンバー
#define MAGIC 9999                        //マジックナンバー
#define COMMENT "時間検査用"  　       //MT4画面上左上のコメント表示

// 外部パラメータ
extern double Lots = 0.01;              //ロット数
extern int Slippage = 30;                //スリッページ

//チケット番号
int Ticket = 0;

//ポジション変数（変数posに0をセッティング、以後ifの状況ごとにposに値を代入し管理）
int pos = 0;

int time = 0;

bool result;

//利確、損切幅
input int TPPoint = 100; //利確
input int SLPoint = 100; //損切

input int tuning = 9;   //Land:9

//ティック時実行関数
void OnTick()
{

   if(66 < DayOfYear() < 310)
    {time = (21-tuning);}
   else
    {time = (22-tuning);}

//決済用変数
   double price;
   
//hour
   int hour = Hour() + tuning;
   

//取引時間計算計算用変数
   long diff = TimeCurrent() - OrderOpenTime();


//買いエントリ
   if(Seconds() == 30)
    {Print("hour,time,Hour(),DayofWeek", hour,time,Hour(),DayOfWeek());};

};

// 以下は一回の負けの金額、これを元にロットが決まる
input int one_time_loss = 10000; // ロット変更元になる一回の損失金額
int force_stop_price = -(one_time_loss * 2);  // 強制決済損益
input int min_account_money = 1000;           // 稼働停止証拠金

#define NO_POSITION 0
#define BUY_POSITION 1
#define SELL_POSITION -1
#define SUMMER_TIME_START_DAY 67
#define SUMMER_TIME_END_DAY 309
#define SUMMER_DAY_START_HOUR 6
#define WINTER_DAY_START_HOUR 7
#define SANDAY 0
#define MONDAY 1
#define TUESDAY 2
#define WEDNESDAY 3
#define THIRDSDAY 4
#define FRIDAY 5
#define SATURDAY 6

#define USDJPY "USDJPY"
#define EURUSD "EURUSD"
#define EURJPY "EURJPY"

#define UP 1
#define DOWN 2

input int slippage = 3; // 許容スリップ、1＝0.001円
int day;

bool is_summer;
bool email;

int day_start_hour = SUMMER_DAY_START_HOUR;

double four_hour_highs[];
double four_hour_lows[];
double four_hour_opens[];
double four_hour_closes[];

double week_highs[];
double week_lows[];
double week_opens[];
double week_closes[];

// timeframe_array[time_input]とかをコード上に仕組んで、時間足で遺伝的アルゴリズムを検証する
int timeframe_array[10] = {0,1,5,15,30,60,240,1440,10080,43200};
input int time_input = 0; // 複数時間で一度のテスト用

// current_array[current_input]とかをコード上に仕組んで、通貨で遺伝的アルゴリズムを検証する
string current_array[3] = {USDJPY,EURUSD,EURJPY};
input int current_input = 0; // 複数通貨で一度のテスト用

// 引数用に設定、定数だとエラーになるので変数
int zero = 0;
int one = 1;
int two = 2;
int three = 3;
int four = 4;
int five = 5;
int six = 6;
int seven = 7;
int eight = 8;
int nine = 9;
int ten = 10;
int eleven = 11;
int twelve = 12;
int thirteen = 13;
int fourteen = 14;
int fifteen = 15;
int sixteen = 16;
int seventeen = 17;
int eighteen = 18;
int nineteen = 19;
int twenty = 20;
int twenty_one = 21;
int twenty_two = 22;
int twenty_three = 23;
int twenty_four = 24;

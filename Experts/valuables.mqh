#define NO_POSITION 0
#define BUY_POSITION 1
#define SELL_POSITION -1
#define SUMMER_TIME_START_DAY 67
#define SUMMER_TIME_END_DAY 309
#define SUMMER_DAY_START_HOUR 6
#define WINTER_DAY_START_HOUR 7
#define MONDAY 1
#define TUESDAY 2
#define WEDNESDAY 3
#define THIRDSDAY 4
#define FRIDAY 5
#define SATURDAY 6
#define SANDAY 7

#define USDJPY "USDJPY"
#define EURUSD "EURUSD"
#define EURJPY "EURJPY"

input double input_force_stop_price = -1000000.0;
double force_stop_price = input_force_stop_price;

input double input_min_account_money = 1000.0;
double min_account_money = input_min_account_money;

input int input_slippage = 3;
int slippage = input_slippage;

int day;

int ticket = 0;
int pos = NO_POSITION;
double entry_price;
bool common_entry_conditions = false;
bool buy_conditions = false;
bool sell_conditions = false;
bool is_summer;
datetime entry_time;
int entry_start_hour;
int entry_end_hour;
bool email;
bool check_history = true;
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
input int time_input = 0;

// current_array[current_input]とかをコード上に仕組んで、通貨で遺伝的アルゴリズムを検証する
string current_array[3] = {USDJPY,EURUSD,EURJPY};
input int current_input = 0;

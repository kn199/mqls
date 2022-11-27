#property strict
#include "valuables.mqh"
#define ONE_MAGIC 1

int a1_ticket = 0;
int a1_pos = NO_POSITION;
string a1_current = USDJPY;

input int a1_min_lots_mode = true;  // ロット調整 0=通常, 1=0.01
double a1_lots = 0.5;
input double a1_normal_lots = 0.5;  // 通常ロット
input double a1_min_lots = 0.1;     // 最小ロット

input int a1_profit = 360;          // 利益ポイント
input int a1_loss = 150;            // 損失ポイント

input int a1_continue_loss = 3;     // ロット減になる失敗連続回数
// commonは0で若干成績が違う(そのせいかわからない)
input int a1_entry_interval = 1000000;    // オーダー間隔(秒)
// input int a1_entry_interval = 300;
// input int a1_entry_start_hour = 13;
// input int a1_entry_end_hour = 24;
int a1_entry_start_hour = twelve;
int a1_entry_end_hour = twenty_four;

bool a1_common_entry_conditions = false;
bool a1_open_conditions = false;
bool a1_close_conditions = false;
bool a1_buy_conditions = false;
bool a1_sell_conditions = false;

double a1_entry_price;
datetime a1_entry_time;
bool a1_check_history;

input int rsi_low_point = 25;
input int rsi_high_point = 75;

input int long_timeframe = 15;
input int short_timeframe = 5;

double rsi_long_1;
double rsi_long_2;
double rsi_long_3;
double rsi_long_4;
double rsi_short_1;
double rsi_short_2;
double rsi_short_3;
double rsi_short_4;

#property strict
#include "valuables.mqh"
#define ONE_MAGIC 1

int one_ticket = 0;
int one_pos = NO_POSITION;
string one_current = USDJPY;

input int one_min_lots_mode = true;  // ロット調整 0=通常, 1=0.01
double one_lots = 0.5;
input double one_normal_lots = 0.5;  // 通常ロット
input double one_min_lots = 0.1;     // 最小ロット

input int one_profit = 360;          // 利益ポイント
input int one_loss = 150;            // 損失ポイント

input int one_continue_loss = 3;     // ロット減になる失敗連続回数
// commonは0で若干成績が違う(そのせいかわからない)
input int one_entry_interval = 1000000;    // オーダー間隔(秒)
// input int one_entry_interval = 300;
// input int one_entry_start_hour = 13;
// input int one_entry_end_hour = 24;
int one_entry_start_hour = twelve;
int one_entry_end_hour = twenty_four;

bool one_common_entry_conditions = false;
bool one_open_conditions = false;
bool one_close_conditions = false;
bool one_buy_conditions = false;
bool one_sell_conditions = false;

double one_entry_price;
datetime one_entry_time;
bool one_check_history;

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

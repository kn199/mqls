#property strict
#include "valuables.mqh"
#define FIVE_MAGIC 5

int a5_ticket = 0;
int a5_pos = NO_POSITION;
string a5_current = USDJPY;

input int a5_min_lots_mode = true;  // ロット調整 0=通常, 1=0.01
double a5_lots = 0.9;
input double a5_normal_lots = 0.35;  // 通常ロット
input double a5_min_lots = 0.1;     // 最小ロット

input int a5_profit = 75;          // 利益ポイント
input int a5_loss = 70;            // 損失ポイント

input int a5_continue_loss = 3;     // ロット減になる失敗連続回数
// commonは0で若干成績が違う(そのせいかわからない)
input int a5_entry_interval = 216000; // オーダー間隔(秒)
// input int a5_entry_interval = 300;
// input int a5_entry_start_hour = 13;
// input int a5_entry_end_hour = 24;
int a5_entry_start_hour = zero;
int a5_entry_end_hour = twenty_four;

int a5_entry_hour = twenty_one;
int a5_entry_minute = 31;

bool a5_common_entry_conditions = false;
bool a5_open_conditions = false;
bool a5_close_conditions = false;
bool a5_buy_conditions = false;
bool a5_sell_conditions = false;

double a5_entry_price;
datetime a5_entry_time;
bool a5_check_history;
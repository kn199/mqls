#property strict
#include "valuables.mqh"
#define TWO_MAGIC 2

int a2_ticket = 0;
int a2_pos = NO_POSITION;
string a2_current = USDJPY;

input int a2_min_lots_mode = true;  // ロット調整 0=通常, 1=0.01
double a2_lots = 1.0;
input double a2_normal_lots = 1.0;  // 通常ロット
input double a2_min_lots = 0.1;     // 最小ロット

input int a2_profit = 180;          // 利益ポイント
input int a2_loss = 160;            // 損失ポイント

input int a2_continue_loss = 3;     // ロット減になる失敗連続回数
// commonは0で若干成績が違う(そのせいかわからない)
input int a2_entry_interval = 300;    // オーダー間隔(秒)
// input int one_entry_interval = 300;
// input int one_entry_start_hour = 13;
// input int one_entry_end_hour = 24;
int a2_entry_start_hour = zero;
int a2_entry_end_hour = twenty_four;

int a2_entry_hour = seven;
int a2_entry_minute = zero;

int a2_close_hour = nine;
int a2_close_minutes = 54;

bool a2_common_entry_conditions = false;
bool a2_open_conditions = true;
bool a2_close_conditions = false;
bool a2_buy_conditions = false;
bool a2_sell_conditions = false;

double a2_entry_price;
datetime a2_entry_time;
bool a2_check_history;
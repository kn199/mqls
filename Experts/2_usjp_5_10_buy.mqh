#property strict
#include "valuables.mqh"
#define TWO_MAGIC 2

int two_ticket = 0;
int two_pos = NO_POSITION;
string two_current = USDJPY;

input int two_min_lots_mode = true;  // ロット調整 0=通常, 1=0.01
double two_lots = 1.0;
input double two_normal_lots = 1.0;  // 通常ロット
input double two_min_lots = 0.1;     // 最小ロット

input int two_profit = 180;          // 利益ポイント
input int two_loss = 160;            // 損失ポイント

input int two_continue_loss = 3;     // ロット減になる失敗連続回数
// commonは0で若干成績が違う(そのせいかわからない)
input int two_entry_interval = 300;    // オーダー間隔(秒)
// input int one_entry_interval = 300;
// input int one_entry_start_hour = 13;
// input int one_entry_end_hour = 24;
int two_entry_start_hour = zero;
int two_entry_end_hour = twenty_four;

int two_entry_hour = seven;
int two_entry_minute = zero;

int two_close_hour = nine;
int two_close_minutes = 54;

bool two_common_entry_conditions = false;
bool two_open_conditions = true;
bool two_close_conditions = false;
bool two_buy_conditions = false;
bool two_sell_conditions = false;

double two_entry_price;
datetime two_entry_time;
bool two_check_history;
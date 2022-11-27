#property strict
#include "valuables.mqh"
#define FIVE_MAGIC 5

int five_ticket = 0;
int five_pos = NO_POSITION;
string five_current = USDJPY;

input int five_min_lots_mode = true;  // ロット調整 0=通常, 1=0.01
double five_lots = 0.9;
input double five_normal_lots = 0.35;  // 通常ロット
input double five_min_lots = 0.1;     // 最小ロット

input int five_profit = 75;          // 利益ポイント
input int five_loss = 70;            // 損失ポイント

input int five_continue_loss = 3;     // ロット減になる失敗連続回数
// commonは0で若干成績が違う(そのせいかわからない)
input int five_entry_interval = 216000; // オーダー間隔(秒)
// input int five_entry_interval = 300;
// input int five_entry_start_hour = 13;
// input int five_entry_end_hour = 24;
int five_entry_start_hour = zero;
int five_entry_end_hour = twenty_four;

int five_entry_hour = twenty_one;
int five_entry_minute = 31;

bool five_common_entry_conditions = false;
bool five_open_conditions = false;
bool five_close_conditions = false;
bool five_buy_conditions = false;
bool five_sell_conditions = false;

double five_entry_price;
datetime five_entry_time;
bool five_check_history;
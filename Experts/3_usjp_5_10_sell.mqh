#property strict
#include "valuables.mqh"
#define THREE_MAGIC 3

int three_ticket = 0;
int three_pos = NO_POSITION;
string three_current = USDJPY;

input int three_min_lots_mode = true;  // ロット調整 0=通常, 1=0.01
double three_lots = 0.9;
input double three_normal_lots = 0.9;  // 通常ロット
input double three_min_lots = 0.1;     // 最小ロット

input int three_profit = 200;          // 利益ポイント
input int three_loss = 120;            // 損失ポイント

input int three_continue_loss = 3;     // ロット減になる失敗連続回数
// commonは0で若干成績が違う(そのせいかわからない)
input int three_entry_interval = 300;    // オーダー間隔(秒)
// input int three_entry_interval = 300;
// input int three_entry_start_hour = 13;
// input int three_entry_end_hour = 24;
int three_entry_start_hour = zero;
int three_entry_end_hour = twenty_four;

int three_entry_hour = nine;
int three_entry_minute = 55;

bool three_common_entry_conditions = false;
bool three_open_conditions = true;
bool three_close_conditions = false;
bool three_buy_conditions = false;
bool three_sell_conditions = false;

double three_entry_price;
datetime three_entry_time;
bool three_check_history;


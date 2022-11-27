#property strict
#include "proxy.mqh"
#define THREE_MAGIC 3

int a3_ticket = 0;
int a3_pos = NO_POSITION;
string a3_current = USDJPY;

input int a3_profit = 200;          // MA3:利益ポイント
input int a3_loss = 120;            // MA3:損失ポイント

input int a3_min_lots_mode = true;  // MA3:ロット調整 0=通常, 1=0.01
double a3_lots = AdjustLotsByLossPoint(one_time_loss, a3_loss);
double a3_normal_lots = a3_lots;
input double a3_min_lots = 0.1;     // MA3:連続敗戦時の縮小ロット

input int a3_continue_loss = 3;     // MA5:ロット減になる失敗連続回数
// commonは0で若干成績が違う(そのせいかわからない)
input int a3_entry_interval = 300;    // MA5:オーダー間隔(秒)
// input int a3_entry_interval = 300;
// input int a3_entry_start_hour = 13;
// input int a3_entry_end_hour = 24;
int a3_entry_start_hour = zero;
int a3_entry_end_hour = twenty_four;

int a3_entry_hour = nine;
int a3_entry_minute = 55;

bool a3_common_entry_conditions = false;
bool a3_open_conditions = true;
bool a3_close_conditions = false;
bool a3_buy_conditions = false;
bool a3_sell_conditions = false;

double a3_entry_price;
datetime a3_entry_time;
bool a3_check_history;

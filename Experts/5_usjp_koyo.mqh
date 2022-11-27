#property strict
#include "proxy.mqh"
#define FIVE_MAGIC 5

int a5_ticket = 0;
int a5_pos = NO_POSITION;
string a5_current = USDJPY;

input int a5_profit = 75;          // MA5:利益ポイント
input int a5_loss = 70;            // MA5:損失ポイント

input int a5_min_lots_mode = true;  // MA5:ロット調整 0=通常, 1=0.01
double a5_lots = AdjustLotsByLossPoint(one_time_loss, a5_loss);
double a5_normal_lots = a5_lots;
input double a5_min_lots = 0.1;     // MA5:連続敗戦時の縮小ロット

input int a5_continue_loss = 3;     // MA5:ロット減になる失敗連続回数
// commonは0で若干成績が違う(そのせいかわからない)
input int a5_entry_interval = 216000; // MA5:オーダー間隔(秒)
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
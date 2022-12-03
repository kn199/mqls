#property strict
#include "../proxy.mqh"

#define MAGIC_S6 1006

int s6_ticket = 0;
int s6_pos = NO_POSITION;
string s6_current = USDJPY;

input int s6_profit = 50;          // s6:利益ポイント
input int s6_loss = 50;            // s6:損失ポイント

input int s6_min_lots_mode = true;  // s6:ロット調整 0=通常, 1=0.01
double s6_lots = AdjustLotsByLossPoint(s6_loss);
double s6_normal_lots = s6_lots;
double s6_min_lots = min_lots;     // s6:連続敗戦時の縮小ロット

input int s6_continue_loss = 3;     // s6:ロット減になる失敗連続回数

// !!!!!!!! entry_interval 100000以上に
int s6_entry_interval = minimum_entry_interval;

int s6_entry_start_hour = twelve;
int s6_entry_end_hour = twenty_four;

bool s6_common_entry_conditions = false;
bool s6_open_conditions = true;
bool s6_close_conditions = false;
bool s6_buy_conditions = false;
bool s6_sell_conditions = false;

double s6_entry_price;
datetime s6_entry_time;

input double s6_diff_price = 0.35;     // s6:差額

void S6Init(){
  s6_entry_time = GetLastEntryTime(MAGIC_S6);

  s6_lots = AdjustLotsByResult(s6_continue_loss, MAGIC_S6,
                               s6_normal_lots, s6_min_lots);
  if (s6_min_lots_mode) {
    s6_lots = MinLots();
  };

  NoticeLots(s6_lots, MAGIC_S6);
}

void S6Tick(){
  s6_common_entry_conditions =
    IsCommonConditon(s6_pos, s6_entry_time, s6_entry_interval);

  s6_buy_conditions = ChcekPriceDiff(60, UP, s6_diff_price, 1);
  s6_sell_conditions = ChcekPriceDiff(60, DOWN, s6_diff_price, 1);

  if (BasicCondition(s6_common_entry_conditions, s6_open_conditions)){
    OrderEntry(s6_buy_conditions, s6_sell_conditions, s6_ticket, s6_lots,
               MAGIC_S6, s6_pos, s6_entry_price, s6_entry_time, s6_entry_interval);
  };

  OrderEnd(s6_pos, s6_profit, s6_loss, s6_entry_price,
           s6_ticket, s6_close_conditions);
}
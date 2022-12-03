#property strict
#include "../proxy.mqh"

#define MAGIC_S5 1005

int s5_ticket = 0;
int s5_pos = NO_POSITION;
string s5_current = USDJPY;

input int s5_profit = 50;          // s5:利益ポイント
input int s5_loss = 50;            // s5:損失ポイント

input int s5_min_lots_mode = true;  // s5:ロット調整 0=通常, 1=0.01
double s5_lots = AdjustLotsByLossPoint(s5_loss);
double s5_normal_lots = s5_lots;
double s5_min_lots = min_lots;     // s5:連続敗戦時の縮小ロット

input int s5_continue_loss = 3;     // s5:ロット減になる失敗連続回数

// !!!!!!!! entry_interval 100000以上に
int s5_entry_interval = minimum_entry_interval;

int s5_entry_start_hour = twelve;
int s5_entry_end_hour = twenty_four;

bool s5_common_entry_conditions = false;
bool s5_open_conditions = true;
bool s5_close_conditions = false;
bool s5_buy_conditions = false;
bool s5_sell_conditions = false;

double s5_entry_price;
datetime s5_entry_time;

input double s5_diff_price = 0.2;     // s5:差額

void S5Init(){
  s5_entry_time = GetLastEntryTime(MAGIC_S5);

  s5_lots = AdjustLotsByResult(s5_continue_loss, MAGIC_S5,
                               s5_normal_lots, s5_min_lots);
  if (s5_min_lots_mode) {
    s5_lots = MinLots();
  };

  NoticeLots(s5_lots, MAGIC_S5);
}

void S5Tick(){
  s5_common_entry_conditions =
    IsCommonConditon(s5_pos, s5_entry_time, s5_entry_interval);

  s5_buy_conditions = ChcekPriceDiff(5, UP, s5_diff_price, 1);
  s5_sell_conditions = ChcekPriceDiff(5, DOWN, s5_diff_price, 1);

  if (BasicCondition(s5_common_entry_conditions, s5_open_conditions)){
    OrderEntry(s5_buy_conditions, s5_sell_conditions, s5_ticket, s5_lots,
               MAGIC_S5, s5_pos, s5_entry_price, s5_entry_time, s5_entry_interval);
  };

  OrderEnd(s5_pos, s5_profit, s5_loss, s5_entry_price,
           s5_ticket, s5_close_conditions);
}
#property strict
#include "../proxy.mqh"

#define MAGIC_S1 1001

int s1_ticket = 0;
int s1_pos = NO_POSITION;
string s1_current = USDJPY;

input int s1_profit = 50;          // S1:利益ポイント
input int s1_loss = 50;            // S1:損失ポイント

input int s1_min_lots_mode = true;  // S1:ロット調整 0=通常, 1=0.01
double s1_lots = AdjustLotsByLossPoint(s1_loss);
double s1_normal_lots = s1_lots;
double s1_min_lots = min_lots;     // S1:連続敗戦時の縮小ロット

input int s1_continue_loss = 3;     // S1:ロット減になる失敗連続回数

// !!!!!!!! entry_interval 100000以上に
int s1_entry_interval = minimum_entry_interval;

int s1_entry_start_hour = twelve;
int s1_entry_end_hour = twenty_four;

bool s1_common_entry_conditions = false;
bool s1_open_conditions = true;
bool s1_close_conditions = false;
bool s1_buy_conditions = false;
bool s1_sell_conditions = false;

double s1_entry_price;
datetime s1_entry_time;

void S1Init(){
  s1_entry_time = GetLastEntryTime(MAGIC_S1);

  s1_lots = AdjustLotsByResult(s1_continue_loss, MAGIC_S1,
                               s1_normal_lots, s1_min_lots);
  if (s1_min_lots_mode) {
    s1_lots = MinLots();
  };

  NoticeLots(s1_lots, MAGIC_S1);
}

void S1Tick(){
  s1_common_entry_conditions =
    IsCommonConditon(s1_pos, s1_entry_time, s1_entry_interval);
  s1_buy_conditions = (
                        IsUp(5, 1) &&
                        IsUp(5, 2) &&
                        IsUp(5, 3) &&
                        IsUp(5, 4) &&
                        IsUp(5, 5) &&
                        IsUp(5, 6) &&
                        IsUp(5, 7) &&
                        IsUp(5, 8) &&
                        IsUp(5, 9)
                      );

  s1_sell_conditions = (
                         IsDown(5, 1) &&
                         IsDown(5, 2) &&
                         IsDown(5, 3) &&
                         IsDown(5, 4) &&
                         IsDown(5, 5) &&
                         IsDown(5, 6) &&
                         IsDown(5, 7) &&
                         IsDown(5, 8) &&
                         IsDown(5, 9)
                        );

  if (BasicCondition(s1_common_entry_conditions, s1_open_conditions)){
    OrderEntry(s1_buy_conditions, s1_sell_conditions, s1_ticket, s1_lots,
               MAGIC_S1, s1_pos, s1_entry_price, s1_entry_time, s1_entry_interval);
  };

  OrderEnd(s1_pos, s1_profit, s1_loss, s1_entry_price,
           s1_ticket, s1_close_conditions);
}
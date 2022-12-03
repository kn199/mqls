#property strict
#include "../proxy.mqh"

#define MAGIC_S2 1002

int s2_ticket = 0;
int s2_pos = NO_POSITION;
string s2_current = USDJPY;

input int s2_profit = 50;          // S2:利益ポイント
input int s2_loss = 50;            // S2:損失ポイント

input int s2_min_lots_mode = true;  // S2:ロット調整 0=通常, 1=0.01
double s2_lots = AdjustLotsByLossPoint(s2_loss);
double s2_normal_lots = s2_lots;
double s2_min_lots = min_lots;     // S2:連続敗戦時の縮小ロット

input int s2_continue_loss = 3;     // S2:ロット減になる失敗連続回数

// !!!!!!!! entry_interval 100000以上に
int s2_entry_interval = minimum_entry_interval;

int s2_entry_start_hour = twelve;
int s2_entry_end_hour = twenty_four;

bool s2_common_entry_conditions = false;
bool s2_open_conditions = true;
bool s2_close_conditions = false;
bool s2_buy_conditions = false;
bool s2_sell_conditions = false;

double s2_entry_price;
datetime s2_entry_time;

void S2Init(){
  s2_entry_time = GetLastEntryTime(MAGIC_S2);

  s2_lots = AdjustLotsByResult(s2_continue_loss, MAGIC_S2,
                               s2_normal_lots, s2_min_lots);
  if (s2_min_lots_mode) {
    s2_lots = MinLots();
  };

  NoticeLots(s2_lots, MAGIC_S2);
}

void S2Tick(){
  s2_common_entry_conditions =
    IsCommonConditon(s2_pos, s2_entry_time, s2_entry_interval);
  s2_buy_conditions = (
                        IsUp(60, 1) &&
                        IsUp(60, 2) &&
                        IsUp(60, 3) &&
                        IsUp(60, 4) &&
                        IsUp(60, 5) &&
                        IsUp(60, 6)
                      );

  s2_sell_conditions = (
                         IsDown(60, 1) &&
                         IsDown(60, 2) &&
                         IsDown(60, 3) &&
                         IsDown(60, 4) &&
                         IsDown(60, 5) &&
                         IsDown(60, 6) 
                        );

  if (BasicCondition(s2_common_entry_conditions, s2_open_conditions)){
    OrderEntry(s2_buy_conditions, s2_sell_conditions, s2_ticket, s2_lots,
               MAGIC_S2, s2_pos, s2_entry_price, s2_entry_time, s2_entry_interval);
  };

  OrderEnd(s2_pos, s2_profit, s2_loss, s2_entry_price,
           s2_ticket, s2_close_conditions);
}
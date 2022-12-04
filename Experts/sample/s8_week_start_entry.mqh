#property strict
#include "../proxy.mqh"

#define MAGIC_S8 1007

int s8_ticket = 0;
int s8_pos = NO_POSITION;
string s8_current = USDJPY;

input int s8_profit = 50;          // s8:利益ポイント
input int s8_loss = 50;            // s8:損失ポイント

input int s8_min_lots_mode = true;  // s8:ロット調整 0=通常, 1=0.01
double s8_lots = AdjustLotsByLossPoint(s8_loss);
double s8_normal_lots = s8_lots;
double s8_min_lots = min_lots;     // s8:連続敗戦時の縮小ロット

input int s8_continue_loss = 3;     // s8:ロット減になる失敗連続回数

// !!!!!!!! entry_interval 100000以上に
int s8_entry_interval = minimum_entry_interval;

int s8_entry_start_hour = twelve;
int s8_entry_end_hour = twenty_four;

bool s8_common_entry_conditions = false;
bool s8_open_conditions = true;
bool s8_close_conditions = false;
bool s8_buy_conditions = false;
bool s8_sell_conditions = false;

double s8_entry_price;
datetime s8_entry_time;

void S8Init(){
  s8_entry_time = GetLastEntryTime(MAGIC_S8);

  s8_lots = AdjustLotsByResult(s8_continue_loss, MAGIC_S8,
                               s8_normal_lots, s8_min_lots);
  if (s8_min_lots_mode) {
    s8_lots = MinLots();
  };
}

void S8Tick(){
  s8_common_entry_conditions =
    IsCommonConditon(s8_pos, s8_entry_time, s8_entry_interval);

  if (TimeHour(TimeLocal()) == day_start_hour)
  {
    if (TimeMinute(TimeLocal()) == 0 ||
        TimeMinute(TimeLocal()) == 5 ||
        TimeMinute(TimeLocal()) == 10 ||
        TimeMinute(TimeLocal()) == 15) {
      s8_buy_conditions = true;
    };
  }

  if (BasicCondition(s8_common_entry_conditions, s8_open_conditions)){
    OrderEntry(s8_buy_conditions, s8_sell_conditions, s8_ticket, s8_lots,
               MAGIC_S8, s8_pos, s8_entry_price, s8_entry_time, s8_entry_interval);
  };

  OrderEnd(s8_pos, s8_profit, s8_loss, s8_entry_price,
           s8_ticket, s8_close_conditions);
}
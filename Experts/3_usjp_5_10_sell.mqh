#property strict
#include "proxy.mqh"
#define THREE_MAGIC 3

int a3_ticket = 0;
int a3_pos = NO_POSITION;
string a3_current = USDJPY;

input int a3_profit = 200;          // MA3:利益ポイント
input int a3_loss = 120;            // MA3:損失ポイント

input int a3_min_lots_mode = true;  // MA3:ロット調整 0=通常, 1=0.01
double a3_lots = AdjustLotsByLossPoint(a3_loss);
double a3_normal_lots = a3_lots;
input double a3_min_lots = 0.1;     // MA3:連続敗戦時の縮小ロット

input int a3_continue_loss = 3;     // MA3:ロット減になる失敗連続回数

// !!!!!!!! entry_interval 100000以上に
input int a3_entry_interval = 100000;    // MA3:オーダー間隔(秒)

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

void A3Init(){
  a3_entry_time = GetLastEntryTime(THREE_MAGIC);

  a3_lots = AdjustLotsByResult(a3_continue_loss, THREE_MAGIC,
                               a3_normal_lots, a3_min_lots);
  if (a3_min_lots_mode) {
    a3_lots = MinLots();
  };

  NoticeLots(a3_lots, THREE_MAGIC);
}

void A3Tick(){
  if (IsCheckConditionTime(a3_entry_hour, a3_entry_minute)){
    a3_common_entry_conditions =
      IsCommonConditon(a3_pos, a3_entry_time, a3_entry_interval);
    a3_sell_conditions = (
                           IsWeekDay() &&
                           IsGoToBi() &&
                           LocalHour() == a3_entry_hour &&
                           LocalMinute() == a3_entry_minute
                         );
  };

  if (IsEntryOneMinuteLater(a3_entry_hour, a3_entry_minute)){
    ChangeEntryCondition(a3_sell_conditions);
  };

  if (BasicCondition(a3_common_entry_conditions, a3_open_conditions)){
    OrderEntry(a3_buy_conditions, a3_sell_conditions, a3_ticket, a3_lots,
               THREE_MAGIC, a3_pos, a3_entry_price, a3_entry_time, a3_entry_interval);
  };

  OrderEnd(a3_pos, a3_profit, a3_loss, a3_entry_price,
           a3_ticket, a3_close_conditions);
}

#property strict
#include "proxy.mqh"
#define TWO_MAGIC 2

int a2_ticket = 0;
int a2_pos = NO_POSITION;
string a2_current = USDJPY;

input int a2_profit = 180;          // MA2:利益ポイント
input int a2_loss = 160;            // MA2:損失ポイント

input int a2_min_lots_mode = true;  // MA2:ロット調整 0=通常, 1=0.01
double a2_lots = AdjustLotsByLossPoint(one_time_loss, a2_loss);
double a2_normal_lots = a2_lots;
input double a2_min_lots = 0.1;     // MA2:連続敗戦時の縮小ロット

input int a2_continue_loss = 3;     // MA2:ロット減になる失敗連続回数

// !!!!!!!! entry_interval 500以上に
input int a2_entry_interval = 500;    // MA2:オーダー間隔(秒)
// input int one_entry_start_hour = 13;
// input int one_entry_end_hour = 24;
int a2_entry_start_hour = zero;
int a2_entry_end_hour = twenty_four;

int a2_entry_hour = seven;
int a2_entry_minute = zero;

int a2_close_hour = nine;
int a2_close_minutes = 54;

bool a2_common_entry_conditions = false;
bool a2_open_conditions = true;
bool a2_close_conditions = false;
bool a2_buy_conditions = false;
bool a2_sell_conditions = false;

double a2_entry_price;
datetime a2_entry_time;

void A2Init(){
  // entry_start_hour = EntryStartUpdate(twelve);
  // entry_end_hour = EntryEndUpdate(twenty_four);
  // entry_hour = EntryHourUpdate(entry_hour);
  a2_entry_time = SetLastEntryTime(TWO_MAGIC);

  a2_lots = AdjustLotsByResult(a2_continue_loss, TWO_MAGIC,
                               a2_normal_lots, a2_min_lots);
  MinLots(a2_min_lots_mode, a2_lots);
}

void A2Tick(){
  if (IsCheckConditionTime(a2_entry_hour, a2_entry_minute)) {
    a2_common_entry_conditions =
      IsCommonConditon(a2_pos, a2_entry_time, a2_entry_interval);
    a2_buy_conditions = (
                          IsGoToBi() &&
                          LocalHour() == a2_entry_hour &&
                          LocalMinute() == a2_entry_minute &&
                          IsSummerTime()
                        );
  };

  a2_close_conditions = (
                          LocalHour() == a2_close_hour &&
                          LocalMinute() == a2_close_minutes &&
                          a2_pos != 0 &&
                          IsSummerTime()
                        );

  if (IsEntryOneMinuteLater(a2_entry_hour, a2_entry_minute)){
    ChangeEntryCondition(a2_buy_conditions);
  };

  if (BasicCondition(a2_common_entry_conditions, a2_open_conditions)){
    OrderEntry(a2_buy_conditions, a2_sell_conditions, a2_ticket,
               a2_lots, TWO_MAGIC, a2_pos, a2_entry_price, a2_entry_time);
  };

  OrderEnd(a2_pos, a2_profit, a2_loss, a2_entry_price,
           a2_ticket, a2_close_conditions);
}
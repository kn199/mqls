#property strict
#include "proxy.mqh"
#define FIVE_MAGIC 5

int a5_ticket = 0;
int a5_pos = NO_POSITION;
string a5_current = USDJPY;

input int a5_profit = 75;          // MA5:利益ポイント
input int a5_loss = 70;            // MA5:損失ポイント

input int a5_min_lots_mode = true;  // MA5:ロット調整 0=通常, 1=0.01
double a5_normal_lots = AdjustLotsByLossPoint(a5_loss);
double a5_min_lots = min_lots;     // MA5:連続敗戦時の縮小ロット
double a5_lots = a5_normal_lots;

input int a5_continue_loss = 3;     // MA5:ロット減になる失敗連続回数

int a5_entry_interval = minimum_entry_interval; // MA5:オーダー間隔(秒)

int a5_entry_hour = twenty_one;
int a5_entry_minute = 31;

bool a5_common_entry_conditions = false;
bool a5_open_conditions = false;
bool a5_close_conditions = false;
bool a5_buy_conditions = false;
bool a5_sell_conditions = false;

double a5_entry_price;
datetime a5_entry_time;

void A5Init(){
  a5_entry_hour = EntryHourUpdate(twenty_one);
  a5_entry_time = GetLastEntryTime(FIVE_MAGIC);

  a5_lots = AdjustLotsByResult(a5_continue_loss, FIVE_MAGIC,
                               a5_normal_lots, a5_min_lots);
  if (a5_min_lots_mode) {
    a5_lots = MinLots();
  };

  NoticeLots(a5_lots, FIVE_MAGIC);
}

void A5Tick(){
  if (IsCheckConditionTime(a5_entry_hour, a5_entry_minute)) {
    a5_common_entry_conditions =
      IsCommonConditon(a5_pos, a5_entry_time, a5_entry_interval);
    a5_open_conditions = (
                            IsFirstWeek() &&
                            LocalDayOfWeek() == FRIDAY &&
                            LocalHour() == a5_entry_hour &&
                            LocalMinute() == a5_entry_minute
                          );

    a5_buy_conditions = IsUp(1, 1);
    a5_sell_conditions = IsDown(1, 1);
  };

  if (IsEntryOneMinuteLater(a5_entry_hour, a5_entry_minute)){
    ChangeEntryCondition(a5_buy_conditions);
    ChangeEntryCondition(a5_sell_conditions);
  };

  if (BasicCondition(a5_common_entry_conditions, a5_open_conditions)){
    OrderEntry(a5_buy_conditions, a5_sell_conditions, a5_ticket, a5_lots,
               FIVE_MAGIC, a5_pos, a5_entry_price, a5_entry_time, a5_entry_interval);
  };

  OrderEnd(a5_pos, a5_profit, a5_loss, a5_entry_price,
           a5_ticket, a5_close_conditions);
}
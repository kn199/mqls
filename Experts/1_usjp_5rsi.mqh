#property strict
#include "proxy.mqh"

#define ONE_MAGIC 1

int a1_ticket = 0;
int a1_pos = NO_POSITION;
string a1_current = USDJPY;

input int a1_profit = 360;          // MA1:利益ポイント
input int a1_loss = 150;            // MA1:損失ポイント

input int a1_min_lots_mode = true;  // MA1:ロット調整 0=通常, 1=0.01
double a1_lots = AdjustLotsByLossPoint(one_time_loss, a1_loss);
double a1_normal_lots = a1_lots;
input double a1_min_lots = 0.1;     // MA1:連続敗戦時の縮小ロット

input int a1_continue_loss = 3;     // MA1:ロット減になる失敗連続回数
// commonは0で若干成績が違う(そのせいかわからない)

// !!!!!!!! entry_interval 500以上に
// input int a1_entry_interval = 500;    // MA1:オーダー間隔(秒)
input int a1_entry_interval = 1000000;    // MA1:オーダー間隔(秒)

// input int a1_entry_start_hour = 13;
// input int a1_entry_end_hour = 24;
int a1_entry_start_hour = twelve;
int a1_entry_end_hour = twenty_four;

bool a1_common_entry_conditions = false;
bool a1_open_conditions = false;
bool a1_close_conditions = false;
bool a1_buy_conditions = false;
bool a1_sell_conditions = false;

double a1_entry_price;
datetime a1_entry_time;

input int rsi_low_point = 25;
input int rsi_high_point = 75;

input int long_timeframe = 15;
input int short_timeframe = 5;

double rsi_long_1;
double rsi_long_2;
double rsi_long_3;
double rsi_long_4;
double rsi_short_1;
double rsi_short_2;
double rsi_short_3;
double rsi_short_4;

void A1Init(){
  a1_entry_start_hour = EntryStartUpdate(twelve);
  a1_entry_end_hour = EntryEndUpdate(twenty_four);
  // a1_entry_hour = EntryHourUpdate(zero);
  a1_entry_time = SetLastEntryTime(ONE_MAGIC);

  a1_lots = AdjustLotsByResult(a1_continue_loss, ONE_MAGIC,
                               a1_normal_lots, a1_min_lots);
  MinLots(a1_min_lots_mode, a1_lots);
}

void A1Tick(){
  if (IsDayStartTime()) {
    a1_entry_start_hour = EntryStartUpdate(thirteen);
    a1_entry_end_hour = EntryEndUpdate(twenty_four);
    // a1_entry_hour = EntryHourUpdate(zero);
    a1_entry_time = SetLastEntryTime(ONE_MAGIC);

    MinLots(a1_min_lots_mode, a1_lots);
  };
 
  a1_common_entry_conditions =
    IsCommonConditon(a1_pos, a1_entry_time, a1_entry_interval);

  a1_open_conditions = (
    LocalHour() >= a1_entry_start_hour &&
    LocalHour() <= a1_entry_end_hour &&
    LocalMinute() == 0
  );

  if (IsFifteenTimesMinute()){
    rsi_long_1 = iRSI (a1_current, long_timeframe, 14, 0, 1);
    rsi_long_2 = iRSI (a1_current, long_timeframe, 14, 0, 2);
    rsi_long_3 = iRSI (a1_current, long_timeframe, 14, 0, 3);
    rsi_long_4 = iRSI (a1_current, long_timeframe, 14, 0, 4);
  };

  if (IsFiveTimesMinute()){
    rsi_short_1 = iRSI (a1_current, short_timeframe, 14, 0, 1);
    rsi_short_2 = iRSI (a1_current, short_timeframe, 14, 0, 2);
    rsi_short_3 = iRSI (a1_current, short_timeframe, 14, 0, 3);
    rsi_short_4 = iRSI (a1_current, short_timeframe, 14, 0, 4);
  };

  a1_buy_conditions = (
    IsDown(long_timeframe, 1) &&
    IsDown(short_timeframe, 1) &&
    (rsi_short_1 >= rsi_high_point || rsi_short_2 >= rsi_high_point || rsi_short_3 >= rsi_high_point || rsi_short_4 >= rsi_high_point) &&
    (rsi_long_1 >= rsi_high_point || rsi_long_2 >= rsi_high_point || rsi_long_3 >= rsi_high_point || rsi_long_4 >= rsi_high_point) 
  );

  a1_sell_conditions = (
    IsUp(long_timeframe, 1) &&
    IsUp(short_timeframe, 1) &&
    (rsi_short_1 <= rsi_low_point || rsi_short_2 <= rsi_low_point || rsi_short_3 <= rsi_low_point || rsi_short_4 <= rsi_low_point) &&
    (rsi_long_1 <= rsi_low_point || rsi_long_2 <= rsi_low_point || rsi_long_3 <= rsi_low_point || rsi_long_4 <= rsi_low_point)
  );

  if (BasicCondition(a1_common_entry_conditions, a1_open_conditions)){
    OrderEntry(a1_buy_conditions, a1_sell_conditions, a1_ticket,
               a1_lots, ONE_MAGIC, a1_pos, a1_entry_price, a1_entry_time);
  };

  OrderEnd(a1_pos, a1_profit, a1_loss, a1_entry_price,
           a1_ticket, a1_close_conditions);
}


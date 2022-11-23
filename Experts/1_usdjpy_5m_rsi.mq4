#property strict
#include "proxy.mqh"

#define MAGIC 1 

double lots = 0.01;
string current = USDJPY;

input double normal_lots = 1.0;
input double min_lots = 0.1;
input int profit = 360;
input int loss = 150;
input int continue_loss = 3;
// commonは0で若干成績が違う(そのせいかわからない)
input int entry_interval = 1000000;
// input int entry_interval = 300;
// input int entry_start_hour = 13;
// input int entry_end_hour = 24;

int entry_start_hour = twelve;
int entry_end_hour = twenty_four;

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

bool this_ea_open_conditions = false;
bool this_ea_close_conditions = false;

// input int entry_hour = 0;
// input int entry_minute = 0;

void OnInit(){
  EaStopCheck(current);
  WeekStartEmail(email);
  day_start_hour = DayStartHourUpdate();
  entry_start_hour = EntryStartUpdate(twelve);
  entry_end_hour = EntryEndUpdate(twenty_four);
  // entry_hour = EntryHourUpdate(zero);
  entry_time = SetLastEntryTime(MAGIC);
};

void OnTick(){
  if (IsDayStartTime()) {
    EaStopCheck(current);
    WeekStartEmail(email);
    day_start_hour = DayStartHourUpdate();
    entry_start_hour = EntryStartUpdate(thirteen);
    entry_end_hour = EntryEndUpdate(twenty_four);
    // entry_hour = EntryHourUpdate(zero);
    entry_time = SetLastEntryTime(MAGIC);
  };
 
  common_entry_conditions = IsCommonConditon(pos, entry_time, entry_interval);
  this_ea_open_conditions = (
                              LocalHour() >= entry_start_hour &&
                              LocalHour() <= entry_end_hour &&
                              LocalMinute() == 0
                            );

  if (IsFifteenTimesMinute()){
    rsi_long_1 = iRSI (current, long_timeframe, 14, 0, 1);
    rsi_long_2 = iRSI (current, long_timeframe, 14, 0, 2);
    rsi_long_3 = iRSI (current, long_timeframe, 14, 0, 3);
    rsi_long_4 = iRSI (current, long_timeframe, 14, 0, 4);
  };

  if (IsFiveTimesMinute()){
    rsi_short_1 = iRSI (current, short_timeframe, 14, 0, 1);
    rsi_short_2 = iRSI (current, short_timeframe, 14, 0, 2);
    rsi_short_3 = iRSI (current, short_timeframe, 14, 0, 3);
    rsi_short_4 = iRSI (current, short_timeframe, 14, 0, 4);
  };

  buy_conditions = (
                     iOpen(current, long_timeframe, 1) > iClose(current, long_timeframe, 1) &&
                     iOpen(current, short_timeframe, 1) > iClose(current, short_timeframe, 1) &&
                     (rsi_short_1 >= rsi_high_point || rsi_short_2 >= rsi_high_point || rsi_short_3 >= rsi_high_point || rsi_short_4 >= rsi_high_point) &&
                     (rsi_long_1 >= rsi_high_point || rsi_long_2 >= rsi_high_point || rsi_long_3 >= rsi_high_point || rsi_long_4 >= rsi_high_point) 
                   );

  sell_conditions = (
                     iOpen(current, long_timeframe, 1) < iClose(current, long_timeframe, 1) &&
                     iOpen(current, short_timeframe, 1) < iClose(current, short_timeframe, 1) &&
                     (rsi_short_1 <= rsi_low_point || rsi_short_2 <= rsi_low_point || rsi_short_3 <= rsi_low_point || rsi_short_4 <= rsi_low_point) &&
                     (rsi_long_1 <= rsi_low_point || rsi_long_2 <= rsi_low_point || rsi_long_3 <= rsi_low_point || rsi_long_4 <= rsi_low_point)
                    );

  OrderEntry(common_entry_conditions, this_ea_open_conditions,
             buy_conditions, sell_conditions, ticket,
             lots, MAGIC, pos, entry_price, entry_time);

  OrderEnd(pos, profit, loss, entry_price,
           ticket, check_history, this_ea_close_conditions);

  AdjustLots(check_history, continue_loss, MAGIC, lots, normal_lots, min_lots);
};

#property strict
#include "proxy.mqh"

#define MAGIC 7

double lots = 0.01;
string current = USDJPY;

input double normal_lots = 1.0;
input double min_lots = 0.1;
input int profit = 300;
input int loss = 150;
input int continue_loss = 3;
input int entry_interval = 300;

int entry_hour = day_start_hour;
int entry_minute = 6;

bool this_ea_open_conditions = false;
bool this_ea_close_conditions = false;

void OnInit(){
  sell_conditions = false;

  EaStopCheck(current);
  WeekStartEmail(email);
  day_start_hour = DayStartHourUpdate();
  // entry_start_hour = EntryStartUpdate(twelve);
  // entry_end_hour = EntryEndUpdate(twenty_four);
  entry_hour = EntryHourUpdate(entry_hour);
  entry_time = SetLastEntryTime(MAGIC);
};

void OnTick(){
  if (IsDayStartTime()) {
    EaStopCheck(current);
    WeekStartEmail(email);
    day_start_hour = DayStartHourUpdate();
    // entry_start_hour = EntryStartUpdate(twelve);
    // entry_end_hour = EntryEndUpdate(twenty_four);
    entry_hour = EntryHourUpdate(entry_hour);
    entry_time = SetLastEntryTime(MAGIC);
  };

  if (IsCheckConditionTime(entry_hour, entry_minute)) {
    common_entry_conditions = IsCommonConditon(pos, entry_time, entry_interval);
    this_ea_open_conditions = (
                                LocalDayOfWeek() == MONDAY &&
                                LocalHour() == entry_hour &&
                                LocalMinute() == entry_minute
                              );

    buy_conditions = iOpen(current, PERIOD_M5, 0) > iClose(current, PERIOD_M5, 1);
  };

  if (IsEntryOneMinuteLater(entry_hour, entry_minute)){
    ChangeEntryCondition(buy_conditions);
  };

  OrderEntry(common_entry_conditions, this_ea_open_conditions,
             buy_conditions, sell_conditions, ticket,
             lots, MAGIC, pos, entry_price, entry_time);

  OrderEnd(pos, profit, loss, entry_price,
           ticket, check_history, this_ea_close_conditions);

  AdjustLots(check_history, continue_loss, MAGIC, lots, normal_lots, min_lots);
}

#property strict
#include "proxy.mqh"

#define MAGIC 5

double lots = 0.01;
string current = USDJPY;

input double normal_lots = 0.01;
input double min_lots = 0.01;
input int profit = 75;
input int loss = 70;
input int continue_loss = 3;
input int entry_interval = 216000;

int entry_hour = twenty_one;
int entry_minute = 31;

bool this_ea_open_conditions = false;
bool this_ea_close_conditions = false;

void OnInit(){
  EaStopCheck(current);
  WeekStartEmail(email);
  day_start_hour = DayStartHourUpdate();
  // entry_start_hour = EntryStartUpdate(twelve);
  // entry_end_hour = EntryEndUpdate(twenty_four);
  entry_hour = EntryHourUpdate(twenty_one);
  entry_time = SetLastEntryTime(MAGIC);
};

void OnTick(){
  if (IsDayStartTime()) {
    EaStopCheck(current);
    WeekStartEmail(email);
    day_start_hour = DayStartHourUpdate();
    // entry_start_hour = EntryStartUpdate(twelve);
    // entry_end_hour = EntryEndUpdate(twenty_four);
    entry_hour = EntryHourUpdate(twenty_one);
    entry_time = SetLastEntryTime(MAGIC);
  };

  if (IsCheckConditionTime(entry_hour, entry_minute)) {
    common_entry_conditions = IsCommonConditon(pos, entry_time, entry_interval);
    this_ea_open_conditions = (
                                IsFirstWeek() &&
                                LocalDayOfWeek() == FRIDAY &&
                                LocalHour() == entry_hour &&
                                LocalMinute() == entry_minute
                              );

    buy_conditions = IsUp(1, 1);
    sell_conditions = IsDown(1, 1);
  };


  if (IsEntryOneMinuteLater(entry_hour, entry_minute)){
    ChangeEntryCondition(buy_conditions);
    ChangeEntryCondition(sell_conditions);
  };

  OrderEntry(common_entry_conditions, this_ea_open_conditions,
             buy_conditions, sell_conditions, ticket,
             lots, MAGIC, pos, entry_price, entry_time);

  OrderEnd(pos, profit, loss, entry_price,
           ticket, check_history, this_ea_close_conditions);

  AdjustLots(check_history, continue_loss, MAGIC, lots, normal_lots, min_lots);

};

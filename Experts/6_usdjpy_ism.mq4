#property strict
#include "proxy.mqh"

#define MAGIC 6

double lots = 0.01;
string current = USDJPY;

input double normal_lots = 0.01;
input double min_lots = 0.01;
input int profit = 100;
input int loss = 100;
input int continue_loss = 3;
input int entry_interval = 216000;

int entry_hour = twenty_three;
int entry_minute = 1;

bool this_ea_open_conditions = false;
bool this_ea_close_conditions = false;

int day_of_week = WEDNESDAY;

// 23時台にエントリするeaでなければ宣言不要
int entry_day_of_week = day_of_week;

void OnInit(){
  WeekStartEmail(email);
  day_start_hour = DayStartHourUpdate();
  // entry_start_hour = EntryStartUpdate(twelve);
  // entry_end_hour = EntryEndUpdate(twenty_four);
  EntryHourUpdateOverDay(entry_hour, twenty_three,
                         entry_day_of_week, WEDNESDAY);
  entry_time = SetLastEntryTime(MAGIC);
};

void OnTick(){
  if (IsDayStartTime()) {
    WeekStartEmail(email);
    EntryHourUpdateOverDay(entry_hour, twenty_three,
                           entry_day_of_week, WEDNESDAY);
    day_start_hour = DayStartHourUpdate();
    // entry_start_hour = EntryStartUpdate(twelve);
    // entry_end_hour = EntryEndUpdate(twenty_four);
    entry_time = SetLastEntryTime(MAGIC);
  };

  if (IsCheckConditionTime(entry_hour, entry_minute)) {
    common_entry_conditions = IsCommonConditon(pos, entry_time, entry_interval);
    this_ea_open_conditions = (
                                LocalHour() == entry_hour &&
                                IsFirstWeek() &&
                                LocalDayOfWeek()  == day_of_week &&
                                LocalMinute() == entry_minute
                              );

    buy_conditions = (iOpen(NULL,5,1) < iClose(NULL,5,1));
    sell_conditions = (iOpen(NULL,5,1) > iClose(NULL,5,1));
  };

  if (IsEntryOneMinuteLater(entry_hour, entry_minute)){
    ChangeEntryCondition(buy_conditions);
    ChangeEntryCondition(sell_conditions);
  };

  OrderEntry(common_entry_conditions, this_ea_open_conditions,
             buy_conditions, sell_conditions, ticket,
             lots, slippage, MAGIC, pos,
             entry_price, entry_time);

  OrderEnd(pos, profit, loss, entry_price,
           ticket, slippage, check_history,
           this_ea_close_conditions, force_stop_price);

  AdjustLots(check_history, continue_loss, MAGIC, lots, normal_lots, min_lots);
};
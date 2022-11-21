#property strict
#include "proxy.mqh"

string ea_name = "6_usdjpy_ism";

#define MAGIC 6
#define COMMENT ea_name    // max: 12

double lots = 0.01;
string current = USDJPY;

input double input_normal_lots = 0.01;
input double input_min_lots = 0.01;
input int input_profit = 100;
input int input_loss = 100;
input int input_continue_loss = 3;
input int input_entry_interval = 216000;
input int input_summer_entry_start_hour = 12;
input int input_summer_entry_end_hour = 24;

double normal_lots = input_normal_lots;
double min_lots = input_min_lots;
int profit = input_profit;
int loss = input_loss;
int continue_loss = input_continue_loss;
int entry_interval = input_entry_interval;
int summer_entry_start_hour = input_summer_entry_start_hour;
int summer_entry_end_hour = input_summer_entry_end_hour;

int entry_hour = 23;
int summer_entry_hour = entry_hour;
int entry_minute = 1;

bool this_ea_open_conditions = false;
bool this_ea_close_conditions = false;

int day_of_week = WEDNESDAY;

// 23時台にエントリするeaでなければ0にする
int entry_day_of_week = day_of_week;
int summer_entry_day_of_week = day_of_week;

void OnInit(){
  WeekStartEmail(ea_name, email);
  DayStartHourUpdate(day_start_hour);
  // EntryStartEndUpdate(entry_start_hour, entry_end_hour,
  //                     summer_entry_start_hour, summer_entry_end_hour);
  EntryHourUpdate(entry_hour, summer_entry_hour);
  SetLastEntryTime(entry_time, MAGIC);
};

void OnTick(){
  if (IsDayStartTime()) {
    WeekStartEmail(ea_name, email);
    DayStartHourUpdate(day_start_hour);
    // EntryStartEndUpdate(entry_start_hour, entry_end_hour,
    //                     summer_entry_start_hour, summer_entry_end_hour);
    EntryHourUpdate(entry_hour, summer_entry_hour);
    SetLastEntryTime(entry_time, MAGIC);
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
             entry_price, entry_time, ea_name);

  OrderEnd(pos, profit, loss, entry_price,
           ticket, slippage, check_history,
           this_ea_close_conditions, force_stop_price);

  AdjustLots(check_history, continue_loss, MAGIC, lots, normal_lots, min_lots);
};
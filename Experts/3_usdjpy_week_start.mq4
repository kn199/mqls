#property strict
#include "proxy.mqh"

string ea_name = "3_usdjpy_week_start";

#define MAGIC 3
#define COMMENT ea_name    // max: 12

double lots = 0.01;
string current = USDJPY;

input double input_normal_lots = 1.0;
input double input_min_lots = 0.1;
input int input_profit = 300;
input int input_loss = 150;
input int input_continue_loss = 3;
input int input_entry_interval = 300;
input int input_summer_entry_start_hour = 0;
input int input_summer_entry_end_hour = 24;

double normal_lots = input_normal_lots;
double min_lots = input_min_lots;
int summer_entry_start_hour = input_summer_entry_start_hour;
int summer_entry_end_hour = input_summer_entry_end_hour;
int entry_interval = input_entry_interval;
int continue_loss = input_continue_loss;
int profit = input_profit;
int loss = input_loss;

int entry_hour = day_start_hour;
int summer_entry_hour = day_start_hour;
int entry_minute = 6;

bool this_ea_open_conditions = false;
bool this_ea_close_conditions = false;

// 23時台にエントリするeaでなければ0にする
int entry_day_of_week = 0;
int summer_entry_day_of_week = 0;

void OnInit(){
  sell_conditions = false;

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
                                LocalDayOfWeek() == MONDAY &&
                                LocalHour() == entry_hour &&
                                LocalMinute() == entry_minute
                              );

    buy_conditions = iOpen(current,PERIOD_M5,0) > iClose(current,PERIOD_M5,1);
  };

  if (IsEntryOneMinuteLater(entry_hour, entry_minute)){
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
}

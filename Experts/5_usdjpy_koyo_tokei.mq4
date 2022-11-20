#property strict
#include "proxy.mqh"

string ea_name = "5_usjp_koyo";

#define MAGIC 5
#define COMMENT ea_name    // max: 12

double lots = 0.01;
string current = USDJPY;

input double input_normal_lots = 0.01;
input double input_min_lots = 0.01;
input int input_profit = 75;
input int input_loss = 70;
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
int entry_start_hour;
int entry_end_hour;
int entry_hour = 21;
int summer_entry_hour = entry_hour;
int entry_minute = 31;

bool this_ea_open_conditions = false;
bool this_ea_close_conditions = false;

void OnInit(){
  TimeUpdate(day_start_hour, is_summer, summer_entry_start_hour, summer_entry_end_hour,
             entry_start_hour, entry_end_hour, entry_time, MAGIC, true,
             summer_entry_hour, entry_hour);
};

void OnTick(){
  TimeUpdate(day_start_hour, is_summer, summer_entry_start_hour, summer_entry_end_hour,
             entry_start_hour, entry_end_hour, entry_time, MAGIC, false,
             summer_entry_hour, entry_hour);

  if (IsCheckConditionTime(entry_hour, entry_minute)) {
    common_entry_conditions = IsCommonConditon(pos, entry_time, entry_interval);
    this_ea_open_conditions = (
                                IsFirstWeek() &&
                                LocalDayOfWeek() == FRIDAY &&
                                LocalHour() == entry_hour &&
                                LocalMinute() == entry_minute
                              );

    buy_conditions = (iOpen(NULL,1,1) < iClose(NULL,1,1));
    sell_conditions = (iOpen(NULL,1,1) > iClose(NULL,1,1));
  };

  ChangeCommonCondition(entry_hour, entry_minute, common_entry_conditions);

  OrderCheck(pos, entry_time, entry_interval, common_entry_conditions, this_ea_open_conditions,
             buy_conditions, sell_conditions, entry_start_hour, entry_end_hour, ea_name, email,
             is_summer, summer_entry_start_hour, summer_entry_end_hour, ticket, current, lots,
             slippage, MAGIC, entry_price, profit, loss, check_history, continue_loss,
             normal_lots, min_lots, force_stop_price, day_start_hour, this_ea_close_conditions);
};

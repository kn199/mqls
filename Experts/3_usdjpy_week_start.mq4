<<<<<<< HEAD
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
int entry_start_hour;
int entry_end_hour;

int entry_hour = day_start_hour;
int summer_entry_hour = day_start_hour;
int entry_minute = 6;

bool this_ea_open_conditions = false;
bool this_ea_close_conditions = false;

void OnInit(){
  sell_conditions = false;
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
                                LocalDayOfWeek() == MONDAY &&
                                LocalHour() == entry_hour &&
                                LocalMinute() == entry_minute
                              );

    buy_conditions = iOpen(current,PERIOD_M5,0) > iClose(current,PERIOD_M5,1);
  };

  ChangeCommonCondition(entry_hour, entry_minute, common_entry_conditions);

  OrderCheck(pos, entry_time, entry_interval, common_entry_conditions, this_ea_open_conditions,
             buy_conditions, sell_conditions, entry_start_hour, entry_end_hour, ea_name, email,
             is_summer, summer_entry_start_hour, summer_entry_end_hour, ticket, current, lots,
             slippage, MAGIC, entry_price, profit, loss, check_history, continue_loss,
             normal_lots, min_lots, force_stop_price, day_start_hour, this_ea_close_conditions);
};
=======
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
int entry_start_hour;
int entry_end_hour;

int entry_hour = day_start_hour;
int summer_entry_hour = day_start_hour;
int entry_minute = 6;

bool this_ea_open_conditions = false;
bool this_ea_close_conditions = false;

void OnInit(){
  sell_conditions = false;
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
                                LocalDayOfWeek() == MONDAY &&
                                LocalHour() == entry_hour &&
                                LocalMinute() == entry_minute
                              );

    buy_conditions = iOpen(current,PERIOD_M5,0) > iClose(current,PERIOD_M5,1);
  };

  ChangeCommonCondition(entry_hour, entry_minute, common_entry_conditions);

  OrderCheck(pos, entry_time, entry_interval, common_entry_conditions, this_ea_open_conditions,
             buy_conditions, sell_conditions, entry_start_hour, entry_end_hour, ea_name, email,
             is_summer, summer_entry_start_hour, summer_entry_end_hour, ticket, current, lots,
             slippage, MAGIC, entry_price, profit, loss, check_history, continue_loss,
             normal_lots, min_lots, force_stop_price, day_start_hour, this_ea_close_conditions);
};
>>>>>>> 0d214ef9625c43f27888ed41f05dfc96ac965720

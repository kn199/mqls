#property strict
#include "proxy.mqh"

input string input_server_name = "kagoya_1";
input string input_company = "land";
string server_name = input_server_name;
string company = input_company;

string ea_name = "2_5_10_sell";

#define MAGIC 2

double lots = 0.01;
string current = USDJPY;

input double input_normal_lots = 1.0;
input double input_min_lots = 0.1;
input int input_profit = 200;
input int input_loss = 120;
input int input_continue_loss = 3;
input int input_entry_interval = 300;
input int input_summer_entry_start_hour = 0;
input int input_summer_entry_end_hour = 24;
input int input_hour = 
int hour = 9;
int minute = 55;

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

int day;

void OnInit(){  
  ToDoInit(day_start_hour, is_summer, summer_entry_start_hour, summer_entry_end_hour,
           entry_start_hour, entry_end_hour, entry_time, MAGIC);
}

void OnTick()
{
  if (LocalHour() == day_start_hour && LocalMinute() == 30){
    day = LocalDay();
  };

  common_entry_conditions = IsCommonConditon(pos, entry_time, entry_interval);

  this_ea_open_conditions = true;
  this_ea_close_conditions = false;

  buy_conditions = false;

  sell_conditions = (
                      IsWeekDay() &&
                      IsGoToBi() &&
                      LocalHour() == hour &&
                      LocalMinute() == minute
                    );

  ToDoTick(pos, entry_time, entry_interval, common_entry_conditions, this_ea_open_conditions,
           buy_conditions, sell_conditions, entry_start_hour, entry_end_hour, server_name, company,
           ea_name, email, is_summer, summer_entry_start_hour, summer_entry_end_hour, ticket,
           current, lots, slippage, MAGIC, entry_price, profit, loss, check_history, continue_loss,
           normal_lots, min_lots, force_stop_price, day_start_hour, this_ea_close_conditions);
}

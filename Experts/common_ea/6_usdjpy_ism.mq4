<<<<<<< HEAD
//+-----------------------------------------------------------------------+
//|                                                           6_usdjpy_ism|
//+-----------------------------------------------------------------------+
#property strict
#include "common.mqh"

string env_name = "kagoya_1";
string ea_name = "6_usdjpy_ism";

#define MAGIC 6
#define COMMENT "6_usdjpy_ism"

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
int entry_start_hour;
int entry_end_hour;
int hour = 23;
int day_of_week = 3;

void OnInit(){
  ToDoInit(day_start_hour,is_summer,summer_entry_start_hour,summer_entry_end_hour,
           entry_start_hour,entry_end_hour,entry_time,MAGIC);
};

void OnTick(){
   if(66 < DayOfYear() < 310)
    {
      hour = 23;
    }
   else
    {
      hour = 0;
    }

  common_entry_conditions = IsCommonConditon(pos,entry_time,entry_interval);
  this_ea_open_conditions = (
                              TimeHour(TimeLocal()) == hour &&
                              TimeDay(TimeLocal()) < 8 &&
                              TimeDayOfWeek(TimeLocal()) == day_of_week &&
                              TimeMinute(TimeLocal()) == 5
                            );

  buy_conditions = (
                     iOpen(NULL,5,1) < iClose(NULL,5,1)
                   );

  sell_conditions = (
                      iOpen(NULL,5,1) > iClose(NULL,5,1)
                    );

  ToDoTick(pos,entry_time,entry_interval,common_entry_conditions,this_ea_open_conditions,buy_conditions,sell_conditions,entry_start_hour,entry_end_hour,env_name,ea_name,
           email,is_summer,summer_entry_start_hour,summer_entry_end_hour,ticket,current,lots,slippage,MAGIC,entry_price,profit,loss,check_history,
           continue_loss,normal_lots,min_lots,force_stop_price,day_start_hour,this_ea_close_conditions);
};
=======
//+-----------------------------------------------------------------------+
//|                                                           6_usdjpy_ism|
//+-----------------------------------------------------------------------+
#property strict
#include "common.mqh"

string env_name = "kagoya_1";
string ea_name = "6_usdjpy_ism";

#define MAGIC 6
#define COMMENT "6_usdjpy_ism"

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
int entry_start_hour;
int entry_end_hour;
int hour = 23;
int day_of_week = 3;

void OnInit(){
  ToDoInit(day_start_hour,is_summer,summer_entry_start_hour,summer_entry_end_hour,
           entry_start_hour,entry_end_hour,entry_time,MAGIC);
};

void OnTick(){
   if(66 < DayOfYear() < 310)
    {
      hour = 23;
    }
   else
    {
      hour = 0;
    }

  common_entry_conditions = IsCommonConditon(pos,entry_time,entry_interval);
  this_ea_open_conditions = (
                              TimeHour(TimeLocal()) == hour &&
                              TimeDay(TimeLocal()) < 8 &&
                              TimeDayOfWeek(TimeLocal()) == day_of_week &&
                              TimeMinute(TimeLocal()) == 5
                            );

  buy_conditions = (
                     iOpen(NULL,5,1) < iClose(NULL,5,1)
                   );

  sell_conditions = (
                      iOpen(NULL,5,1) > iClose(NULL,5,1)
                    );

  ToDoTick(pos,entry_time,entry_interval,common_entry_conditions,this_ea_open_conditions,buy_conditions,sell_conditions,entry_start_hour,entry_end_hour,env_name,ea_name,
           email,is_summer,summer_entry_start_hour,summer_entry_end_hour,ticket,current,lots,slippage,MAGIC,entry_price,profit,loss,check_history,
           continue_loss,normal_lots,min_lots,force_stop_price,day_start_hour,this_ea_close_conditions);
};
>>>>>>> 0d214ef9625c43f27888ed41f05dfc96ac965720

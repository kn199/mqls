//+-----------------------------------------------------------------------+
//|                                                            5_usjp_koyo|
//+-----------------------------------------------------------------------+
#property strict
#include "common.mqh"

input string server_name = "kagoya_1";
input string company = "";
string ea_name = "5_usjp_koyo";

#define MAGIC 5
#define COMMENT "5_usjp_koyo"

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
int hour = 21;

void OnInit(){
  ToDoInit(day_start_hour,is_summer,summer_entry_start_hour,summer_entry_end_hour,
           entry_start_hour,entry_end_hour,entry_time,MAGIC);
};

void OnTick(){
   if(66 < DayOfYear() < 310)
    {hour = 21;}
   else
    {hour = 22;};

  common_entry_conditions = IsCommonConditon(pos, entry_time, entry_interval);
  this_ea_close_conditions = false;
  this_ea_open_conditions = (
                              TimeDay(TimeLocal()) < 8 &&
                              TimeDayOfWeek(TimeLocal()) == 5 &&
                              TimeHour(TimeLocal()) == hour &&
                              TimeMinute(TimeLocal()) == 31
                            );

  buy_conditions = (iOpen(NULL,1,1) < iClose(NULL,1,1));

  sell_conditions = (iOpen(NULL,1,1) > iClose(NULL,1,1));






  ToDoTick(pos,entry_time,entry_interval,common_entry_conditions,
              this_ea_open_conditions, buy_conditions,sell_conditions,
              entry_start_hour,entry_end_hour,server_name,ea_name,
              email,is_summer,summer_entry_start_hour,summer_entry_end_hour,
              ticket,current,lots,slippage,MAGIC,
              entry_price,
              profit,loss,check_history,continue_loss,normal_lots,
              min_lots,force_stop_price,day_start_hour,this_ea_close_conditions
             );
};

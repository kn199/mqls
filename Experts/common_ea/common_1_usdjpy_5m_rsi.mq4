//+-----------------------------------------------------------------------+
//|                                                          1_usjp_rsi5m|
//+-----------------------------------------------------------------------+
#property strict
#include "common.mqh"

string env_name = "kagoya_1";
string ea_name = "1_usjp_rsi5m"; // max: 12

#define MAGIC 1 
#define COMMENT "1_usjp_rsi5m"    // max: 12

double lots = 0.01;
string current = USDJPY;

input double input_normal_lots = 1.0;
input double input_min_lots = 0.1;
input int input_profit = 360;
input int input_loss = 150;
input int input_continue_loss = 3;
//input int input_entry_interval = 1000000;
input int input_entry_interval = 0;
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


input int rsi_low_point = 25;
input int rsi_high_point = 75;

input int long_timeframe = 15;
input int short_timeframe = 5;

double rsi_long_1;
double rsi_long_2;
double rsi_long_3;
double rsi_long_4;
double rsi_short_1;
double rsi_short_2;
double rsi_short_3;
double rsi_short_4;

void OnInit(){
  ToDoInit(day_start_hour,is_summer,summer_entry_start_hour,summer_entry_end_hour,
           entry_start_hour,entry_end_hour,entry_time,MAGIC);
};

void OnTick(){
  common_entry_conditions = IsCommonConditon(pos,entry_time,entry_interval);
  this_ea_open_conditions = (
                              LocalHour() > entry_start_hour &&
                              LocalHour() < entry_end_hour &&
                              LocalMinute() == 0
                            );

  this_ea_close_conditions = false;

  if(
      LocalMinute() == 0 ||
      LocalMinute() == 15 ||
      LocalMinute() == 30 ||
      LocalMinute() == 45
     )
     {
       rsi_long_1 = iRSI (current,long_timeframe,14,0,1);
       rsi_long_2 = iRSI (current,long_timeframe,14,0,2);
       rsi_long_3 = iRSI (current,long_timeframe,14,0,3);
       rsi_long_4 = iRSI (current,long_timeframe,14,0,4);

       rsi_short_1 = iRSI (current,short_timeframe,14,0,1);
       rsi_short_2 = iRSI (current,short_timeframe,14,0,2);
       rsi_short_3 = iRSI (current,short_timeframe,14,0,3);
       rsi_short_4 = iRSI (current,short_timeframe,14,0,4);
     };

  if(
      LocalMinute() == 5 ||
      LocalMinute() == 10 ||
      LocalMinute() == 20 ||
      LocalMinute() == 25 ||
      LocalMinute() == 35 ||
      LocalMinute() == 40 ||
      LocalMinute() == 50 ||
      LocalMinute() == 55
    )
     {
       rsi_short_1 = iRSI (current,short_timeframe,14,0,1);
       rsi_short_2 = iRSI (current,short_timeframe,14,0,2);
       rsi_short_3 = iRSI (current,short_timeframe,14,0,3);
       rsi_short_4 = iRSI (current,short_timeframe,14,0,4);
     };

  buy_conditions = (
                     iOpen(current,long_timeframe,1) > iClose(current,long_timeframe,1) &&
                     iOpen(current,short_timeframe,1) > iClose(current,short_timeframe,1) &&
                     (rsi_short_1 >= rsi_high_point || rsi_short_2 >= rsi_high_point || rsi_short_3 >= rsi_high_point || rsi_short_4 >= rsi_high_point) &&
                     (rsi_long_1 >= rsi_high_point || rsi_long_2 >= rsi_high_point || rsi_long_3 >= rsi_high_point || rsi_long_4 >= rsi_high_point) 
                   );

  sell_conditions = (
                     iOpen(current,long_timeframe,1) < iClose(current,long_timeframe,1) &&
                     iOpen(current,short_timeframe,1) < iClose(current,short_timeframe,1) &&
                     (rsi_short_1 <= rsi_low_point || rsi_short_2 <= rsi_low_point || rsi_short_3 <= rsi_low_point || rsi_short_4 <= rsi_low_point) &&
                     (rsi_long_1 <= rsi_low_point || rsi_long_2 <= rsi_low_point || rsi_long_3 <= rsi_low_point || rsi_long_4 <= rsi_low_point)
                    );

  ToDoTick(pos,entry_time,entry_interval,common_entry_conditions,this_ea_open_conditions,buy_conditions,sell_conditions,entry_start_hour,entry_end_hour,env_name,ea_name,
           email,is_summer,summer_entry_start_hour,summer_entry_end_hour,ticket,current,lots,slippage,MAGIC,entry_price,profit,loss,check_history,
           continue_loss,normal_lots,min_lots,force_stop_price,day_start_hour,this_ea_close_conditions);
};

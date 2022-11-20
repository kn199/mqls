//+------------------------------------------------------------------+
//|                                                         one_file |
//+------------------------------------------------------------------+
#property strict
#include "one_file.mqh"

string env_name = "kagoya_1";
string current = USDJPY;

// 5-10-bi-sell
#define TWO_MAGIC 2
double two_lots = 0.1;
string two_ea_name = "2_5_10_sell";

input double two_input_normal_lots = 0.1;
input double two_input_min_lots = 0.1;
input int two_input_profit = 200;
input int two_input_loss = 120;
input int two_input_continue_loss = 3;
input int two_input_entry_interval = 300;
input int two_input_summer_entry_start_hour = 0;
input int two_input_summer_entry_end_hour = 24;

double two_normal_lots = two_input_normal_lots;
double two_min_lots = two_input_min_lots;
int two_profit = two_input_profit;
int two_loss = two_input_loss;
int two_continue_loss = two_input_continue_loss;
int two_entry_interval = two_input_entry_interval;
int two_summer_entry_start_hour = two_input_summer_entry_start_hour;
int two_summer_entry_end_hour = two_input_summer_entry_end_hour;
int two_entry_start_hour;
int two_entry_end_hour;

int two_ticket = 0;
int two_pos = NO_POSITION;
double two_entry_price;
bool two_common_entry_conditions = false;
bool two_this_ea_open_conditions = false;
bool two_this_ea_close_conditions = false;
bool two_buy_conditions = false;
bool two_sell_conditions = false;
datetime two_entry_time;
bool two_email;
bool two_check_history = true;
bool two_is_summer;

// 5-10-bi-buy
#define FOUR_MAGIC 4
double four_lots = 0.1;
string four_ea_name = "4_5_10_day_buy";

input double four_input_normal_lots = 0.1;
input double four_input_min_lots = 0.1;
input int four_input_profit = 180;
input int four_input_loss = 160;
input int four_input_continue_loss = 3;
input int four_input_entry_interval = 300;
input int four_input_summer_entry_start_hour = 0;
input int four_input_summer_entry_end_hour = 24;

double four_normal_lots = four_input_normal_lots;
double four_min_lots = four_input_min_lots;
int four_profit = four_input_profit;
int four_loss = four_input_loss;
int four_continue_loss = four_input_continue_loss;
int four_entry_interval = four_input_entry_interval;
int four_summer_entry_start_hour = four_input_summer_entry_start_hour;
int four_summer_entry_end_hour = four_input_summer_entry_end_hour;
int four_entry_start_hour;
int four_entry_end_hour;

int four_ticket = 0;
int four_pos = NO_POSITION;
double four_entry_price;
bool four_common_entry_conditions = false;
bool four_this_ea_open_conditions = false;
bool four_this_ea_close_conditions = false;
bool four_buy_conditions = false;
bool four_sell_conditions = false;
datetime four_entry_time;
bool four_email;
bool four_check_history = true;
bool four_is_summer;

// koyo
#define FIVE_MAGIC 5
double five_lots = 0.1;
string five_ea_name = "koyo_usjp";

input double five_input_normal_lots = 0.1;
input double five_input_min_lots = 0.1;
input int five_input_profit = 75;
input int five_input_loss = 70;
input int five_input_continue_loss = 3;
input int five_input_entry_interval = 216000;
input int five_input_summer_entry_start_hour = 0;
input int five_input_summer_entry_end_hour = 24;

double five_normal_lots = five_input_normal_lots;
double five_min_lots = five_input_min_lots;
int five_profit = five_input_profit;
int five_loss = five_input_loss;
int five_continue_loss = five_input_continue_loss;
int five_entry_interval = five_input_entry_interval;
int five_summer_entry_start_hour = five_input_summer_entry_start_hour;
int five_summer_entry_end_hour = five_input_summer_entry_end_hour;
int five_entry_start_hour;
int five_entry_end_hour;

int five_ticket = 0;
int five_pos = NO_POSITION;
double five_entry_price;
bool five_common_entry_conditions = false;
bool five_this_ea_open_conditions = false;
bool five_this_ea_close_conditions = false;
bool five_buy_conditions = false;
bool five_sell_conditions = false;
datetime five_entry_time;
bool five_email;
bool five_check_history = true;
bool five_is_summer;


int day;
int hour;

void OnInit(){  
  ToDoInit(day_start_hour,two_is_summer,two_summer_entry_start_hour,two_summer_entry_end_hour,
           two_entry_start_hour,two_entry_end_hour,two_entry_time,TWO_MAGIC);


  ToDoInit(day_start_hour,four_is_summer,four_summer_entry_start_hour,four_summer_entry_end_hour,
           four_entry_start_hour,four_entry_end_hour,four_entry_time,FOUR_MAGIC);


  ToDoInit(day_start_hour,five_is_summer,five_summer_entry_start_hour,five_summer_entry_end_hour,
           five_entry_start_hour,five_entry_end_hour,five_entry_time,FIVE_MAGIC);

};

void OnTick()
{

  if(TimeHour(TimeLocal()) == day_start_hour && TimeMinute(TimeLocal()) == 30)
    {day = TimeDay(TimeLocal());};

   if(66 < DayOfYear() < 310)
    {hour = 21;}
   else
    {hour = 22;};

  two_common_entry_conditions = IsCommonConditon(two_pos,two_entry_time,two_entry_interval);
  four_common_entry_conditions = IsCommonConditon(four_pos,four_entry_time,four_entry_interval);
  five_common_entry_conditions = IsCommonConditon(five_pos,five_entry_time,five_entry_interval);

  two_this_ea_open_conditions = true;
  four_this_ea_open_conditions = true;
  five_this_ea_open_conditions =  (
                                    TimeDay(TimeLocal()) < 8 &&
                                    TimeDayOfWeek(TimeLocal()) == 5 &&
                                    TimeHour(TimeLocal()) == hour &&
                                    TimeMinute(TimeLocal()) == 31
                                  );


  two_this_ea_close_conditions = false;

  four_this_ea_close_conditions =  (
                                     TimeHour(TimeLocal()) == 9 &&
                                     TimeMinute(TimeLocal()) == 54
                                   );

  five_this_ea_close_conditions = false;

  two_buy_conditions = false;
  four_buy_conditions = (
                          (1 <= TimeDayOfWeek(TimeLocal()) <= 5) &&
                          ((day == 5) || (day == 10) || (day == 15) || (day == 20) || (day == 25) || (day == 30)) &&
                          TimeHour(TimeLocal()) == 7 &&
                          TimeMinute(TimeLocal()) == 0 &&
                          four_is_summer
                        );
  five_buy_conditions = (iOpen(NULL,1,1) < iClose(NULL,1,1));


  two_sell_conditions = (
                          (1 <= TimeDayOfWeek(TimeLocal()) <= 5) &&
                           ((day == 5) || (day == 10) || (day == 15) || (day == 20) || (day == 25) || (day == 30)) &&
                          TimeHour(TimeLocal()) == 9 &&
                          TimeMinute(TimeLocal()) == 55
                        );
  four_sell_conditions = false;
  five_sell_conditions = (iOpen(NULL,1,1) > iClose(NULL,1,1));

  ToDoTick(two_pos,two_entry_time,two_entry_interval,two_common_entry_conditions,two_this_ea_open_conditions,
           two_buy_conditions,two_sell_conditions,two_entry_start_hour,two_entry_end_hour,env_name,two_ea_name,
           two_email,two_is_summer,two_summer_entry_start_hour,two_summer_entry_end_hour,two_ticket,current,
           two_lots,slippage,TWO_MAGIC,two_entry_price,two_profit,two_loss,two_check_history,
           two_continue_loss,two_normal_lots,two_min_lots,force_stop_price,day_start_hour,two_this_ea_close_conditions);

  ToDoTick(four_pos,four_entry_time,four_entry_interval,four_common_entry_conditions,four_this_ea_open_conditions,
           four_buy_conditions,four_sell_conditions,four_entry_start_hour,four_entry_end_hour,env_name,four_ea_name,
           four_email,four_is_summer,four_summer_entry_start_hour,four_summer_entry_end_hour,four_ticket,current,
           four_lots,slippage,FOUR_MAGIC,four_entry_price,four_profit,four_loss,four_check_history,
           four_continue_loss,four_normal_lots,four_min_lots,force_stop_price,day_start_hour,four_this_ea_close_conditions);


  ToDoTick(five_pos,five_entry_time,five_entry_interval,five_common_entry_conditions,five_this_ea_open_conditions,
           five_buy_conditions,five_sell_conditions,five_entry_start_hour,five_entry_end_hour,env_name,five_ea_name,
           five_email,five_is_summer,five_summer_entry_start_hour,five_summer_entry_end_hour,five_ticket,current,
           five_lots,slippage,FIVE_MAGIC,five_entry_price,five_profit,five_loss,five_check_history,
           five_continue_loss,five_normal_lots,five_min_lots,force_stop_price,day_start_hour,five_this_ea_close_conditions);
};

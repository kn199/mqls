#property strict
#include "proxy.mqh"
string current = USDJPY;

#define TWO_MAGIC 2
#define THREE_MAGIC 3
#define FIVE_MAGIC 5

double two_lots = 0.01;
double three_lots = 0.01;
double five_lots = 0.01;

input double two_normal_lots = 0.01;
input double two_min_lots = 0.01;

input double three_normal_lots = 0.01;
input double three_min_lots = 0.01;

input double five_normal_lots = 0.01;
input double five_min_lots = 0.01;

input int two_profit = 180;
input int two_loss = 160;

input int three_profit = 200;
input int three_loss = 120;

input int five_profit = 75;
input int five_loss = 70;

input int two_continue_loss = 3;
input int three_continue_loss = 3;
input int five_continue_loss = 3;

input int two_entry_interval = 216000;
input int three_entry_interval = 3600;
input int five_entry_interval = 300;

int two_entry_hour = seven;
int two_entry_minute = zero;

int three_entry_hour = nine;
int three_entry_minute = 55;

int five_entry_hour = twenty_one;
int five_entry_minute = 31;

bool two_ea_open_conditions = true;
bool two_ea_close_conditions = false;

bool three_ea_open_conditions = true;
bool three_ea_close_conditions = false;

bool five_ea_open_conditions = false;
bool five_ea_close_conditions = false;

int two_ticket = 0;
int three_ticket = 0;
int five_ticket = 0;

int two_pos = 0;
int three_pos = 0;
int five_pos = 0;

datetime two_entry_time;
datetime three_entry_time;
datetime five_entry_time;

double two_entry_price;
double three_entry_price;
double five_entry_price;

bool two_common_entry_conditions = false;
bool three_common_entry_conditions = false;
bool five_common_entry_conditions = false;

bool two_close_conditions = false;
bool three_close_conditions = false;
bool five_close_conditions = false;

bool two_buy_conditions;
bool two_sell_conditions;

bool three_buy_conditions = false;
bool three_sell_conditions;

bool five_buy_conditions;
bool five_sell_conditions;

bool two_check_history;
bool three_check_history;
bool five_check_history;

void OnInit(){
  EaStopCheck(current);
  WeekStartEmail(email);
  day_start_hour = DayStartHourUpdate();

  // entry_start_hour = EntryStartUpdate(twelve);
  // entry_end_hour = EntryEndUpdate(twenty_four);

  // two_entry_hour = EntryHourUpdate(seven);
  five_entry_hour = EntryHourUpdate(twenty_one);

  two_entry_time = SetLastEntryTime(TWO_MAGIC);
  three_entry_time = SetLastEntryTime(THREE_MAGIC);
  five_entry_time = SetLastEntryTime(FIVE_MAGIC);
};

void OnTick(){
  if (IsDayStartTime()) {
    EaStopCheck(current);
    WeekStartEmail(email);
    day_start_hour = DayStartHourUpdate();

    // entry_start_hour = EntryStartUpdate(twelve);
    // entry_end_hour = EntryEndUpdate(twenty_four);

    // two_entry_hour = EntryHourUpdate(seven);
    five_entry_hour = EntryHourUpdate(twenty_one);

    two_entry_time = SetLastEntryTime(TWO_MAGIC);
    three_entry_time = SetLastEntryTime(THREE_MAGIC);
    five_entry_time = SetLastEntryTime(FIVE_MAGIC);
  };

  if (IsCheckConditionTime(two_entry_hour, two_entry_minute)) {
    two_common_entry_conditions = IsCommonConditon(two_pos, two_entry_time, two_entry_interval);

    two_buy_conditions = (
                          IsWeekDay() &&
                          IsGoToBi() &&
                          LocalHour() == two_entry_hour &&
                          LocalMinute() == two_entry_minute &&
                          IsSummerTime()
                        );
  };

  if (IsCheckConditionTime(three_entry_hour, three_entry_minute)) {
    three_common_entry_conditions = IsCommonConditon(three_pos, three_entry_time, three_entry_interval);

    three_sell_conditions = (
                              IsWeekDay() &&
                              IsGoToBi() &&
                              LocalHour() == three_entry_hour &&
                              LocalMinute() == three_entry_minute
                            );
  };

  if (IsCheckConditionTime(five_entry_hour, five_entry_minute)) {
    five_common_entry_conditions = IsCommonConditon(five_pos, five_entry_time, five_entry_interval);

    five_ea_open_conditions = (
                                IsFirstWeek() &&
                                LocalDayOfWeek() == FRIDAY &&
                                LocalHour() == five_entry_hour &&
                                LocalMinute() == five_entry_minute
                              );

    five_buy_conditions = (iOpen(NULL,1,1) < iClose(NULL,1,1));
    five_sell_conditions = (iOpen(NULL,1,1) > iClose(NULL,1,1));
  };

  OrderEntry(two_common_entry_conditions, two_ea_open_conditions,
             two_buy_conditions, two_sell_conditions, two_ticket,
             two_lots, TWO_MAGIC, two_pos, two_entry_price, two_entry_time);

  OrderEntry(three_common_entry_conditions, three_ea_open_conditions,
             three_buy_conditions, three_sell_conditions, three_ticket,
             three_lots, THREE_MAGIC, three_pos, three_entry_price, three_entry_time);

  OrderEntry(five_common_entry_conditions, five_ea_open_conditions,
             five_buy_conditions, five_sell_conditions, five_ticket,
             five_lots, FIVE_MAGIC, five_pos, five_entry_price, five_entry_time);

  OrderEnd(two_pos, two_profit, two_loss, two_entry_price,
           two_ticket, two_check_history, two_ea_close_conditions);

  OrderEnd(three_pos, three_profit, three_loss, three_entry_price,
           three_ticket, three_check_history, three_ea_close_conditions);

  OrderEnd(five_pos, five_profit, five_loss, five_entry_price,
           five_ticket, five_check_history, five_ea_close_conditions);

  AdjustLots(two_check_history, two_continue_loss, TWO_MAGIC, two_lots, two_normal_lots, two_min_lots);
  AdjustLots(three_check_history, three_continue_loss, THREE_MAGIC, three_lots, three_normal_lots, three_min_lots);
  AdjustLots(five_check_history, five_continue_loss, FIVE_MAGIC, five_lots, five_normal_lots, five_min_lots);
};

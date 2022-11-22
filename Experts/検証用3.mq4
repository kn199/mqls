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
  Print("a",WindowExpertName());
}

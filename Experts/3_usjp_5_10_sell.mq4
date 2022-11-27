#property strict
#include "proxy.mqh"
#include "3_usjp_5_10_sell.mqh"

void OnInit(){
  a3_buy_conditions = false;

  EaStopCheck(USDJPY);
  WeekStartEmail(email);
  day_start_hour = DayStartHourUpdate();
  // entry_start_hour = EntryStartUpdate(twelve);
  // entry_end_hour = EntryEndUpdate(twenty_four);
  // entry_hour = EntryHourUpdate(entry_hour);
  A3Init();
};

void OnTick(){
  if (IsDayStartTime()) {
    EaStopCheck(a3_current);
    WeekStartEmail(email);
    day_start_hour = DayStartHourUpdate();

    A3Init();
  };

  A3Tick();
}

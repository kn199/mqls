#property strict
#include "proxy.mqh"
#include "3_usjp_5_10_sell.mqh"

void OnInit(){
  EaStopCheck(USDJPY);
  WeekStartEmail(email);
  day_start_hour = DayStartHourUpdate();

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

#property strict
#include "proxy.mqh"
#include "8_usjp_ma.mqh"

void OnInit(){
  EaStopCheck(USDJPY);
  WeekStartEmail(email);
  day_start_hour = DayStartHourUpdate();

  A8Init();
};

void OnTick(){
  if (IsDayStartTime()) {
    EaStopCheck(USDJPY);
    WeekStartEmail(email);
    day_start_hour = DayStartHourUpdate();

    A8Init();
  };

  A8Tick();
};

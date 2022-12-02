#property strict
#include "proxy.mqh"
#include "1_usjp_5rsi.mqh"
#include "2_custom.mqh"
#include "3_usjp_5_10_sell.mqh"
#include "5_usjp_koyo.mqh"
#include "8_usjp_ma.mqh"

void OnInit(){
  EaStopCheck(USDJPY);
  WeekStartEmail(email);
  day_start_hour = DayStartHourUpdate();

  A1Init();
  A2Init();
  A3Init();
  A5Init();
  A8Init();
};

void OnTick(){
  if (IsDayStartTime()) {
    EaStopCheck(USDJPY);
    WeekStartEmail(email);
    day_start_hour = DayStartHourUpdate();
  
    A1Init();
    A2Init();
    A3Init();
    A5Init();
    A8Init();
  };

  A1Tick();
  A2Tick();
  A3Tick();
  A5Tick();
  A8Tick();
};

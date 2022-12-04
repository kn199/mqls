#property strict
#include "/sample/s1_5m_continue.mqh"
#include "/sample/s2_60m_continue.mqh"
#include "/sample/s3_5m_rsi.mqh"
#include "/sample/s4_5m_ma.mqh"
#include "/sample/s5_5m_price_diff.mqh"
#include "/sample/s6_60m_price_diff.mqh"
#include "/sample/s7_week_start_notice.mqh"
#include "/sample/s8_week_start_entry.mqh"

void OnInit(){
  EaStopCheck(USDJPY);
  WeekStartEmail(email);
  day_start_hour = DayStartHourUpdate();

  S1Init();
  S2Init();
  S3Init();
  S4Init();
  S5Init();
  S6Init();
  S7Init();
  S8Init();
};

void OnTick(){
  if (IsDayStartTime()) {
    EaStopCheck(USDJPY);
    WeekStartEmail(email);
    day_start_hour = DayStartHourUpdate();

    S1Init();
    S2Init();
    S3Init();
    S4Init();
    S5Init();
    S6Init();
    S7Init();
    S8Init();
  };

  S1Tick();
  S2Tick();
  S3Tick();
  S4Tick();
  S5Tick();
  S6Tick();
  S7Tick();
  S8Tick();
};

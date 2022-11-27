#property strict
#include "proxy.mqh"
#include "1_usjp_5rsi.mqh"

void OnInit(){
  EaStopCheck(USDJPY);
  WeekStartEmail(email);
  day_start_hour = DayStartHourUpdate();
  a1_entry_start_hour = EntryStartUpdate(twelve);
  a1_entry_end_hour = EntryEndUpdate(twenty_four);
  // a1_entry_hour = EntryHourUpdate(zero);
  a1_entry_time = SetLastEntryTime(ONE_MAGIC);

  MinLots(a1_min_lots_mode, a1_lots);
};

void OnTick(){
  if (IsDayStartTime()) {
    EaStopCheck(USDJPY);
    WeekStartEmail(email);
    day_start_hour = DayStartHourUpdate();
    a1_entry_start_hour = EntryStartUpdate(thirteen);
    a1_entry_end_hour = EntryEndUpdate(twenty_four);
    // a1_entry_hour = EntryHourUpdate(zero);
    a1_entry_time = SetLastEntryTime(ONE_MAGIC);

    MinLots(a1_min_lots_mode, a1_lots);
  };
 
  a1_common_entry_conditions =
    IsCommonConditon(a1_pos, a1_entry_time, a1_entry_interval);

  a1_open_conditions = (
    LocalHour() >= a1_entry_start_hour &&
    LocalHour() <= a1_entry_end_hour &&
    LocalMinute() == 0
  );

  if (IsFifteenTimesMinute()){
    rsi_long_1 = iRSI (a1_current, long_timeframe, 14, 0, 1);
    rsi_long_2 = iRSI (a1_current, long_timeframe, 14, 0, 2);
    rsi_long_3 = iRSI (a1_current, long_timeframe, 14, 0, 3);
    rsi_long_4 = iRSI (a1_current, long_timeframe, 14, 0, 4);
  };

  if (IsFiveTimesMinute()){
    rsi_short_1 = iRSI (a1_current, short_timeframe, 14, 0, 1);
    rsi_short_2 = iRSI (a1_current, short_timeframe, 14, 0, 2);
    rsi_short_3 = iRSI (a1_current, short_timeframe, 14, 0, 3);
    rsi_short_4 = iRSI (a1_current, short_timeframe, 14, 0, 4);
  };

  a1_buy_conditions = (
    IsDown(long_timeframe, 1) &&
    IsDown(short_timeframe, 1) &&
    (rsi_short_1 >= rsi_high_point || rsi_short_2 >= rsi_high_point || rsi_short_3 >= rsi_high_point || rsi_short_4 >= rsi_high_point) &&
    (rsi_long_1 >= rsi_high_point || rsi_long_2 >= rsi_high_point || rsi_long_3 >= rsi_high_point || rsi_long_4 >= rsi_high_point) 
  );

  a1_sell_conditions = (
    IsUp(long_timeframe, 1) &&
    IsUp(short_timeframe, 1) &&
    (rsi_short_1 <= rsi_low_point || rsi_short_2 <= rsi_low_point || rsi_short_3 <= rsi_low_point || rsi_short_4 <= rsi_low_point) &&
    (rsi_long_1 <= rsi_low_point || rsi_long_2 <= rsi_low_point || rsi_long_3 <= rsi_low_point || rsi_long_4 <= rsi_low_point)
  );

  if (BasicCondition(a1_common_entry_conditions, a1_open_conditions)){
    OrderEntry(a1_buy_conditions, a1_sell_conditions, a1_ticket,
               a1_lots, ONE_MAGIC, a1_pos, a1_entry_price, a1_entry_time);
  };

  OrderEnd(a1_pos, a1_profit, a1_loss, a1_entry_price,
           a1_ticket, a1_check_history, a1_close_conditions);

  AdjustLots(a1_check_history, a1_continue_loss, ONE_MAGIC,
             a1_lots, a1_normal_lots, a1_min_lots);
};

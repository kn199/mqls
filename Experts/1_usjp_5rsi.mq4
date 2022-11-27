#property strict
#include "proxy.mqh"
#include "1_usjp_5rsi.mqh"

void OnInit(){
  EaStopCheck(one_current);
  WeekStartEmail(email);
  day_start_hour = DayStartHourUpdate();
  one_entry_start_hour = EntryStartUpdate(twelve);
  one_entry_end_hour = EntryEndUpdate(twenty_four);
  // one_entry_hour = EntryHourUpdate(zero);
  one_entry_time = SetLastEntryTime(ONE_MAGIC);

  MinLots(one_min_lots_mode, one_lots);
};

void OnTick(){
  if (IsDayStartTime()) {
    EaStopCheck(one_current);
    WeekStartEmail(email);
    day_start_hour = DayStartHourUpdate();
    one_entry_start_hour = EntryStartUpdate(thirteen);
    one_entry_end_hour = EntryEndUpdate(twenty_four);
    // one_entry_hour = EntryHourUpdate(zero);
    one_entry_time = SetLastEntryTime(ONE_MAGIC);

    MinLots(one_min_lots_mode, one_lots);
  };
 
  one_common_entry_conditions =
    IsCommonConditon(one_pos, one_entry_time, one_entry_interval);

  one_open_conditions = (
    LocalHour() >= one_entry_start_hour &&
    LocalHour() <= one_entry_end_hour &&
    LocalMinute() == 0
  );

  if (IsFifteenTimesMinute()){
    rsi_long_1 = iRSI (one_current, long_timeframe, 14, 0, 1);
    rsi_long_2 = iRSI (one_current, long_timeframe, 14, 0, 2);
    rsi_long_3 = iRSI (one_current, long_timeframe, 14, 0, 3);
    rsi_long_4 = iRSI (one_current, long_timeframe, 14, 0, 4);
  };

  if (IsFiveTimesMinute()){
    rsi_short_1 = iRSI (one_current, short_timeframe, 14, 0, 1);
    rsi_short_2 = iRSI (one_current, short_timeframe, 14, 0, 2);
    rsi_short_3 = iRSI (one_current, short_timeframe, 14, 0, 3);
    rsi_short_4 = iRSI (one_current, short_timeframe, 14, 0, 4);
  };

  one_buy_conditions = (
    IsDown(long_timeframe, 1) &&
    IsDown(short_timeframe, 1) &&
    (rsi_short_1 >= rsi_high_point || rsi_short_2 >= rsi_high_point || rsi_short_3 >= rsi_high_point || rsi_short_4 >= rsi_high_point) &&
    (rsi_long_1 >= rsi_high_point || rsi_long_2 >= rsi_high_point || rsi_long_3 >= rsi_high_point || rsi_long_4 >= rsi_high_point) 
  );

  one_sell_conditions = (
    IsUp(long_timeframe, 1) &&
    IsUp(short_timeframe, 1) &&
    (rsi_short_1 <= rsi_low_point || rsi_short_2 <= rsi_low_point || rsi_short_3 <= rsi_low_point || rsi_short_4 <= rsi_low_point) &&
    (rsi_long_1 <= rsi_low_point || rsi_long_2 <= rsi_low_point || rsi_long_3 <= rsi_low_point || rsi_long_4 <= rsi_low_point)
  );

  if (BasicCondition(one_common_entry_conditions, one_open_conditions)){
    OrderEntry(one_buy_conditions, one_sell_conditions, one_ticket,
               one_lots, ONE_MAGIC, one_pos, one_entry_price, one_entry_time);
  };

  OrderEnd(one_pos, one_profit, one_loss, one_entry_price,
           one_ticket, one_check_history, one_close_conditions);

  AdjustLots(one_check_history, one_continue_loss, ONE_MAGIC,
             one_lots, one_normal_lots, one_min_lots);
};

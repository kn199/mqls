#property strict
#include "proxy.mqh"
#include "2_usjp_5_10_buy.mqh"
#include "3_usjp_5_10_sell.mqh"
#include "5_usjp_koyo.mqh"

void OnInit(){
  EaStopCheck(USDJPY);
  WeekStartEmail(email);
  day_start_hour = DayStartHourUpdate();

  a5_entry_hour = EntryHourUpdate(twenty_one);

  a2_entry_time = SetLastEntryTime(TWO_MAGIC);
  a3_entry_time = SetLastEntryTime(THREE_MAGIC);
  a5_entry_time = SetLastEntryTime(FIVE_MAGIC);

  MinLots(a2_min_lots_mode, a2_lots);
  MinLots(a3_min_lots_mode, a3_lots);
  MinLots(a5_min_lots_mode, a5_lots);
};

void OnTick(){
  if (IsDayStartTime()) {
    EaStopCheck(USDJPY);
    WeekStartEmail(email);
    day_start_hour = DayStartHourUpdate();

    a5_entry_hour = EntryHourUpdate(twenty_one);

    a2_entry_time = SetLastEntryTime(TWO_MAGIC);
    a3_entry_time = SetLastEntryTime(THREE_MAGIC);
    a5_entry_time = SetLastEntryTime(FIVE_MAGIC);

    MinLots(a2_min_lots_mode, a2_lots);
    MinLots(a3_min_lots_mode, a3_lots);
    MinLots(a5_min_lots_mode, a5_lots);
  };

  if (IsCheckConditionTime(a2_entry_hour, a2_entry_minute)) {
    a2_common_entry_conditions =
      IsCommonConditon(a2_pos, a2_entry_time, a2_entry_interval);
    a2_buy_conditions = (
                          IsGoToBi() &&
                          LocalHour() == a2_entry_hour &&
                          LocalMinute() == a2_entry_minute &&
                          IsSummerTime()
                        );
  };

  a2_close_conditions = (
                          LocalHour() == a2_close_hour &&
                          LocalMinute() == a2_close_minutes &&
                          a2_pos != 0 &&
                          IsSummerTime()
                        );

  if (IsEntryOneMinuteLater(a2_entry_hour, a2_entry_minute)){
    ChangeEntryCondition(a2_buy_conditions);
  };

  if (BasicCondition(a2_common_entry_conditions, a2_open_conditions)){
    OrderEntry(a2_buy_conditions, a2_sell_conditions, a2_ticket,
               a2_lots, TWO_MAGIC, a2_pos, a2_entry_price, a2_entry_time);
  };

  OrderEnd(a2_pos, a2_profit, a2_loss, a2_entry_price,
           a2_ticket, a2_check_history, a2_close_conditions);

  AdjustLotsByResult(a2_check_history, a2_continue_loss, TWO_MAGIC,
                     a2_lots, a2_normal_lots, a2_min_lots);


  if (IsCheckConditionTime(a3_entry_hour, a3_entry_minute)){
    a3_common_entry_conditions =
      IsCommonConditon(a3_pos, a3_entry_time, a3_entry_interval);
    a3_sell_conditions = (
                           IsWeekDay() &&
                           IsGoToBi() &&
                           LocalHour() == a3_entry_hour &&
                           LocalMinute() == a3_entry_minute
                         );
  };

  if (IsEntryOneMinuteLater(a3_entry_hour, a3_entry_minute)){
    ChangeEntryCondition(a3_sell_conditions);
  };

  if (BasicCondition(a3_common_entry_conditions, a3_open_conditions)){
    OrderEntry(a3_buy_conditions, a3_sell_conditions, a3_ticket,
               a3_lots, THREE_MAGIC, a3_pos, a3_entry_price, a3_entry_time);
  };

  OrderEnd(a3_pos, a3_profit, a3_loss, a3_entry_price,
           a3_ticket, a3_check_history, a3_close_conditions);

  AdjustLotsByResult(a3_check_history, a3_continue_loss, THREE_MAGIC,
                     a3_lots, a3_normal_lots, a3_min_lots);


  if (IsCheckConditionTime(a5_entry_hour, a5_entry_minute)) {
    a5_common_entry_conditions =
      IsCommonConditon(a5_pos, a5_entry_time, a5_entry_interval);
    a5_open_conditions = (
                            IsFirstWeek() &&
                            LocalDayOfWeek() == FRIDAY &&
                            LocalHour() == a5_entry_hour &&
                            LocalMinute() == a5_entry_minute
                          );

    a5_buy_conditions = IsUp(1, 1);
    a5_sell_conditions = IsDown(1, 1);
  };

  if (IsEntryOneMinuteLater(a5_entry_hour, a5_entry_minute)){
    ChangeEntryCondition(a5_buy_conditions);
    ChangeEntryCondition(a5_sell_conditions);
  };

  if (BasicCondition(a5_common_entry_conditions, a5_open_conditions)){
    OrderEntry(a5_buy_conditions, a5_sell_conditions, a5_ticket,
               a5_lots, FIVE_MAGIC, a5_pos, a5_entry_price, a5_entry_time);
  };

  OrderEnd(a5_pos, a5_profit, a5_loss, a5_entry_price,
           a5_ticket, a5_check_history, a5_close_conditions);

  AdjustLotsByResult(a5_check_history, a5_continue_loss, FIVE_MAGIC,
                     a5_lots, a5_normal_lots, a5_min_lots);
};

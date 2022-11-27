#property strict
#include "proxy.mqh"
#include "2_usjp_5_10_buy.mqh"
#include "3_usjp_5_10_sell.mqh"
#include "5_usjp_koyo.mqh"

void OnInit(){
  EaStopCheck(USDJPY);
  WeekStartEmail(email);
  day_start_hour = DayStartHourUpdate();

  // entry_start_hour = EntryStartUpdate(twelve);
  // entry_end_hour = EntryEndUpdate(twenty_four);

  // two_entry_hour = EntryHourUpdate(seven);
  five_entry_hour = EntryHourUpdate(twenty_one);

  two_entry_time = SetLastEntryTime(TWO_MAGIC);
  three_entry_time = SetLastEntryTime(THREE_MAGIC);
  five_entry_time = SetLastEntryTime(FIVE_MAGIC);

  MinLots(two_min_lots_mode, two_lots);
  MinLots(three_min_lots_mode, three_lots);
  MinLots(five_min_lots_mode, five_lots);

  three_buy_conditions = false;
};

void OnTick(){
  if (IsDayStartTime()) {
    EaStopCheck(USDJPY);
    WeekStartEmail(email);
    day_start_hour = DayStartHourUpdate();

    // entry_start_hour = EntryStartUpdate(twelve);
    // entry_end_hour = EntryEndUpdate(twenty_four);

    // two_entry_hour = EntryHourUpdate(seven);
    five_entry_hour = EntryHourUpdate(twenty_one);

    two_entry_time = SetLastEntryTime(TWO_MAGIC);
    three_entry_time = SetLastEntryTime(THREE_MAGIC);
    five_entry_time = SetLastEntryTime(FIVE_MAGIC);

    MinLots(two_min_lots_mode, two_lots);
    MinLots(three_min_lots_mode, three_lots);
    MinLots(five_min_lots_mode, five_lots);
  };

  if (IsCheckConditionTime(two_entry_hour, two_entry_minute)) {
    two_common_entry_conditions =
      IsCommonConditon(two_pos, two_entry_time, two_entry_interval);

    two_buy_conditions = (
                           IsWeekDay() &&
                           IsGoToBi() &&
                           LocalHour() == two_entry_hour &&
                           LocalMinute() == two_entry_minute &&
                           IsSummerTime()
                         );
  };

  if (IsCheckConditionTime(three_entry_hour, three_entry_minute)){
    three_common_entry_conditions =
      IsCommonConditon(three_pos, three_entry_time, three_entry_interval);
    three_sell_conditions = (
                        IsWeekDay() &&
                        IsGoToBi() &&
                        LocalHour() == three_entry_hour &&
                        LocalMinute() == three_entry_minute
                      );
  };

  if (IsCheckConditionTime(five_entry_hour, five_entry_minute)) {
    five_common_entry_conditions =
      IsCommonConditon(five_pos, five_entry_time, five_entry_interval);

    five_open_conditions = (
                              IsFirstWeek() &&
                              LocalDayOfWeek() == FRIDAY &&
                              LocalHour() == five_entry_hour &&
                              LocalMinute() == five_entry_minute
                            );

    five_buy_conditions = IsUp(1, 1);
    five_sell_conditions = IsDown(1, 1);
  };

  OrderEntry(two_common_entry_conditions, two_open_conditions,
             two_buy_conditions, two_sell_conditions, two_ticket,
             two_lots, TWO_MAGIC, two_pos, two_entry_price, two_entry_time);

  OrderEntry(three_common_entry_conditions, three_open_conditions,
             three_buy_conditions, three_sell_conditions, three_ticket,
             three_lots, THREE_MAGIC, three_pos, three_entry_price, three_entry_time);

  OrderEntry(five_common_entry_conditions, five_open_conditions,
             five_buy_conditions, five_sell_conditions, five_ticket,
             five_lots, FIVE_MAGIC, five_pos, five_entry_price, five_entry_time);

  OrderEnd(two_pos, two_profit, two_loss, two_entry_price,
           two_ticket, two_check_history, two_close_conditions);

  OrderEnd(three_pos, three_profit, three_loss, three_entry_price,
           three_ticket, three_check_history, three_close_conditions);

  OrderEnd(five_pos, five_profit, five_loss, five_entry_price,
           five_ticket, five_check_history, five_close_conditions);

  AdjustLots(two_check_history, two_continue_loss, TWO_MAGIC,
             two_lots, two_normal_lots, two_min_lots);

  AdjustLots(three_check_history, three_continue_loss, THREE_MAGIC,
             three_lots, three_normal_lots, three_min_lots);

  AdjustLots(five_check_history, five_continue_loss, FIVE_MAGIC,
             five_lots, five_normal_lots, five_min_lots);
};

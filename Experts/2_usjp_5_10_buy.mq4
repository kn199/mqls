#property strict
#include "proxy.mqh"
#include "2_usjp_5_10_buy.mqh"

void OnInit(){
  a2_sell_conditions = false;

  EaStopCheck(USDJPY);
  WeekStartEmail(email);
  day_start_hour = DayStartHourUpdate();
  // entry_start_hour = EntryStartUpdate(twelve);
  // entry_end_hour = EntryEndUpdate(twenty_four);
  // entry_hour = EntryHourUpdate(entry_hour);
  a2_entry_time = SetLastEntryTime(TWO_MAGIC);

  MinLots(a2_min_lots_mode, a2_lots);
};

void OnTick(){
  if (IsDayStartTime()) {
    EaStopCheck(a2_current);
    WeekStartEmail(email);
    day_start_hour = DayStartHourUpdate();
    // a2_entry_start_hour = EntryStartUpdate(twelve);
    // a2_entry_end_hour = EntryEndUpdate(twenty_four);
    // a2_entry_hour = EntryHourUpdate(two_entry_hour);
    a2_entry_time = SetLastEntryTime(TWO_MAGIC);

    MinLots(a2_min_lots_mode, a2_lots);
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
}

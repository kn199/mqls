#property strict
#include "proxy.mqh"
#include "2_usjp_5_10_buy.mqh"

void OnInit(){
  two_sell_conditions = false;

  EaStopCheck(two_current);
  WeekStartEmail(email);
  day_start_hour = DayStartHourUpdate();
  // entry_start_hour = EntryStartUpdate(twelve);
  // entry_end_hour = EntryEndUpdate(twenty_four);
  // entry_hour = EntryHourUpdate(entry_hour);
  two_entry_time = SetLastEntryTime(TWO_MAGIC);

  MinLots(two_min_lots_mode, two_lots);
};

void OnTick(){
  if (IsDayStartTime()) {
    EaStopCheck(two_current);
    WeekStartEmail(email);
    day_start_hour = DayStartHourUpdate();
    // two_entry_start_hour = EntryStartUpdate(twelve);
    // two_entry_end_hour = EntryEndUpdate(twenty_four);
    // two_entry_hour = EntryHourUpdate(two_entry_hour);
    two_entry_time = SetLastEntryTime(TWO_MAGIC);

    MinLots(two_min_lots_mode, two_lots);
  };

  if (IsCheckConditionTime(two_entry_hour, two_entry_minute)) {
    two_common_entry_conditions =
    IsCommonConditon(two_pos, two_entry_time, two_entry_interval);
    two_buy_conditions = (
                          IsGoToBi() &&
                          LocalHour() == two_entry_hour &&
                          LocalMinute() == two_entry_minute &&
                          IsSummerTime()
                         );
  };

  two_close_conditions = (
                            LocalHour() == two_close_hour &&
                            LocalMinute() == two_close_minutes &&
                            two_pos != 0 &&
                            IsSummerTime()
                          );

  if (IsEntryOneMinuteLater(two_entry_hour, two_entry_minute)){
    ChangeEntryCondition(two_buy_conditions);
  };

  OrderEntry(two_common_entry_conditions, two_open_conditions,
             two_buy_conditions, two_sell_conditions, two_ticket,
             two_lots, TWO_MAGIC, two_pos, two_entry_price, two_entry_time);

  OrderEnd(two_pos, two_profit, two_loss, two_entry_price,
           two_ticket, two_check_history, two_close_conditions);

  AdjustLots(two_check_history, two_continue_loss, TWO_MAGIC,
             two_lots, two_normal_lots, two_min_lots);
}

#property strict
#include "proxy.mqh"
#include "3_usjp_5_10_sell.mqh"

void OnInit(){
  three_buy_conditions = false;

  EaStopCheck(three_current);
  WeekStartEmail(email);
  day_start_hour = DayStartHourUpdate();
  // entry_start_hour = EntryStartUpdate(twelve);
  // entry_end_hour = EntryEndUpdate(twenty_four);
  // entry_hour = EntryHourUpdate(entry_hour);
  three_entry_time = SetLastEntryTime(THREE_MAGIC);

  MinLots(three_min_lots_mode, three_lots);
};

void OnTick(){
  if (IsDayStartTime()) {
    EaStopCheck(three_current);
    WeekStartEmail(email);
    day_start_hour = DayStartHourUpdate();
    // entry_start_hour = EntryStartUpdate(twelve);
    // entry_end_hour = EntryEndUpdate(twenty_four);
    // entry_hour = EntryHourUpdate(entry_hour);
    three_entry_time = SetLastEntryTime(THREE_MAGIC);

    MinLots(three_min_lots_mode, three_lots);
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

  if (IsEntryOneMinuteLater(three_entry_hour, three_entry_minute)){
    ChangeEntryCondition(three_sell_conditions);
  };

  OrderEntry(three_common_entry_conditions, three_open_conditions,
             three_buy_conditions, three_sell_conditions, three_ticket,
             three_lots, THREE_MAGIC, three_pos, three_entry_price, three_entry_time);

  OrderEnd(three_pos, three_profit, three_loss, three_entry_price,
           three_ticket, three_check_history, three_close_conditions);

  AdjustLots(three_check_history, three_continue_loss, THREE_MAGIC,
             three_lots, three_normal_lots, three_min_lots);
}

#property strict
#include "proxy.mqh"
#include "3_usjp_5_10_sell.mqh"

void OnInit(){
  a3_buy_conditions = false;

  EaStopCheck(USDJPY);
  WeekStartEmail(email);
  day_start_hour = DayStartHourUpdate();
  // entry_start_hour = EntryStartUpdate(twelve);
  // entry_end_hour = EntryEndUpdate(twenty_four);
  // entry_hour = EntryHourUpdate(entry_hour);
  a3_entry_time = SetLastEntryTime(THREE_MAGIC);

  MinLots(a3_min_lots_mode, a3_lots);
};

void OnTick(){
  if (IsDayStartTime()) {
    EaStopCheck(a3_current);
    WeekStartEmail(email);
    day_start_hour = DayStartHourUpdate();
    // a3_entry_start_hour = EntryStartUpdate(twelve);
    // a3_entry_end_hour = EntryEndUpdate(twenty_four);
    // a3_entry_hour = EntryHourUpdate(entry_hour);
    a3_entry_time = SetLastEntryTime(THREE_MAGIC);

    MinLots(a3_min_lots_mode, a3_lots);
  };

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
}

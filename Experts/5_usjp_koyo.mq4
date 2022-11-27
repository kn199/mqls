#property strict
#include "proxy.mqh"
#include "5_usjp_koyo.mqh"

void OnInit(){
  EaStopCheck(five_current);
  WeekStartEmail(email);
  day_start_hour = DayStartHourUpdate();
  // entry_start_hour = EntryStartUpdate(twelve);
  // entry_end_hour = EntryEndUpdate(twenty_four);
  five_entry_hour = EntryHourUpdate(twenty_one);
  five_entry_time = SetLastEntryTime(FIVE_MAGIC);

  MinLots(five_min_lots_mode, five_lots);
};

void OnTick(){
  if (IsDayStartTime()) {
    EaStopCheck(five_current);
    WeekStartEmail(email);
    day_start_hour = DayStartHourUpdate();
    // entry_start_hour = EntryStartUpdate(twelve);
    // entry_end_hour = EntryEndUpdate(twenty_four);
    five_entry_hour = EntryHourUpdate(twenty_one);
    five_entry_time = SetLastEntryTime(FIVE_MAGIC);

    MinLots(five_min_lots_mode, five_lots);
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


  if (IsEntryOneMinuteLater(five_entry_hour, five_entry_minute)){
    ChangeEntryCondition(five_buy_conditions);
    ChangeEntryCondition(five_sell_conditions);
  };

  OrderEntry(five_common_entry_conditions, five_open_conditions,
             five_buy_conditions, five_sell_conditions, five_ticket,
             five_lots, FIVE_MAGIC, five_pos, five_entry_price, five_entry_time);

  OrderEnd(five_pos, five_profit, five_loss, five_entry_price,
           five_ticket, five_check_history, five_close_conditions);

  AdjustLots(five_check_history, five_continue_loss, FIVE_MAGIC,
             five_lots, five_normal_lots, five_min_lots);
};

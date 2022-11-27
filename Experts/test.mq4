#property strict
#include "proxy.mqh"
#include "2_usjp_5_10_buy.mqh"
#include "3_usjp_5_10_sell.mqh"
#include "5_usjp_koyo.mqh"

void OnInit(){
  EaStopCheck(USDJPY);
  WeekStartEmail(email);
  day_start_hour = DayStartHourUpdate();


  a2_entry_time = SetLastEntryTime(TWO_MAGIC);

  a2_lots = AdjustLotsByResult(a2_continue_loss, TWO_MAGIC,
                               a2_normal_lots, a2_min_lots);

  MinLots(a2_min_lots_mode, a2_lots);
};

void OnTick(){
  if (IsDayStartTime()) {
    EaStopCheck(USDJPY);
    WeekStartEmail(email);
    day_start_hour = DayStartHourUpdate();


    a2_entry_time = SetLastEntryTime(TWO_MAGIC);

    a2_lots = AdjustLotsByResult(a2_continue_loss, TWO_MAGIC,
                                 a2_normal_lots, a2_min_lots);

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
           a2_ticket, a2_close_conditions);

};

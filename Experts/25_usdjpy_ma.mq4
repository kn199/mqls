#property strict
#include "proxy.mqh"

// マジックナンバー
#define MAGIC   25                   //マジックナンバー

double lots = 0.01;
string current = USDJPY;

input double input_normal_lots = 0.01;
double normal_lots = input_normal_lots;

input double input_min_lots = 0.01;
double min_lots = input_min_lots;

input int input_profit = 300;
int profit = input_profit;

input int input_loss = 120;
int loss = input_loss;

input int input_continue_loss = 3;
int continue_loss = input_continue_loss;

input int input_entry_interval = 1000000;
int entry_interval = input_entry_interval;

input int input_summer_entry_start_hour = 10;
int summer_entry_start_hour = input_summer_entry_start_hour;

input int input_summer_entry_end_hour = 22;
int summer_entry_end_hour = input_summer_entry_end_hour;

double MA1_1h;
double MA2_1h;
double MA3_1h;
double MA4_1h;
double MA5_1h;
double MA6_1h;
double MA1_4h;
double MA2_4h;

bool this_ea_open_conditions = false;
bool this_ea_close_conditions = false;

int summer_entry_hour = 0;
int entry_hour = 0;
int entry_minute = 1;

void OnInit(){
  WeekStartEmail(email);
  DayStartHourUpdate(day_start_hour);
  EntryStartEndUpdate(entry_start_hour, entry_end_hour,
                      summer_entry_start_hour, summer_entry_end_hour);
  // EntryHourUpdate(entry_hour, summer_entry_hour);
  SetLastEntryTime(entry_time, MAGIC);
};

void OnTick(){
  if (IsDayStartTime()) {
    WeekStartEmail(email);
    DayStartHourUpdate(day_start_hour);
    EntryStartEndUpdate(entry_start_hour, entry_end_hour,
                        summer_entry_start_hour, summer_entry_end_hour);
    // EntryHourUpdate(entry_hour, summer_entry_hour);
    SetLastEntryTime(entry_time, MAGIC);
  };

  common_entry_conditions = IsCommonConditon(pos, entry_time, entry_interval);

  if(LocalMinute() == 0)
    {
      MA1_1h = iMA(
                     current,       // 通貨ペア
                     PERIOD_H1,     // 時間軸、現在表示の時間軸で返す処理
                     5,             // 平均期間
                     0,             // 移動平均シフト
                     MODE_SMA,      // 適用価格（ローソク終値）
                     PRICE_OPEN,    // ラインインデックス
                     0              // シフト:0
                   );
                   
      MA2_1h = iMA(current,PERIOD_H1,25,0,MODE_SMA,PRICE_OPEN,0);
      MA3_1h = iMA(current,PERIOD_H1,75,0,MODE_SMA,PRICE_OPEN,0);
      MA4_1h = iMA(current,PERIOD_H1,5,0,MODE_SMA,PRICE_OPEN,1);
      MA5_1h = iMA(current,PERIOD_H1,25,0,MODE_SMA,PRICE_OPEN,1);
      MA6_1h = iMA(current,PERIOD_H1,75,0,MODE_SMA,PRICE_OPEN,1);
      MA1_4h = iMA(current,PERIOD_H4,5,0,MODE_SMA,PRICE_OPEN,0);
      MA2_4h = iMA(current,PERIOD_H4,25,0,MODE_SMA,PRICE_OPEN,0);
    };

  this_ea_open_conditions = (
                              LocalHour() >= entry_start_hour &&
                              LocalHour() <= entry_end_hour &&
                              LocalMinute() == 0 &&
                              LocalSecond() > 30
                            );

  buy_conditions = (
                     iOpen(current,60,1) < iClose(current,60,1) &&
                     iClose(current,60,1) > iClose(current,60,2) &&
                     iHigh(current,60,1) > iHigh(current,60,2) &&
                     iLow(current,60,1) > iLow(current,60,2) &&
                     iClose(current,30,1) > iClose(current,30,2) &&
                     iHigh(current,30,1) > iHigh(current,30,2) &&
                     iLow(current,30,1) > iLow(current,30,2) &&
                     MA1_4h > MA2_4h &&   //1時間足で5本線が25本線より高いこと
                     MA1_1h > MA2_1h &&   //4時間足でも5本線が25本線より高いこと
                     MA4_1h < MA5_1h      //ローソク1本右にずらした平均線ではまだGクロスが起きていないこと、クロスした直後にエントリする狙い
                   );

  sell_conditions = (
                      iOpen(current,60,1) > iClose(current,60,1) &&
                      iClose(current,60,1) < iClose(current,60,2) &&
                      iHigh(current,60,1) < iHigh(current,60,2) &&
                      iLow(current,60,1) < iLow(current,60,2) &&
                      iClose(current,30,1) < iClose(current,30,2) &&
                      iHigh(current,30,1) < iHigh(current,30,2) &&
                      iLow(current,30,1) < iLow(current,30,2) &&
                      MA1_4h < MA2_4h &&
                      MA1_1h < MA2_1h &&
                      MA4_1h > MA5_1h
                    );

  OrderEntry(common_entry_conditions, this_ea_open_conditions,
             buy_conditions, sell_conditions, ticket,
             lots, slippage, MAGIC, pos,
             entry_price, entry_time);

  OrderEnd(pos, profit, loss, entry_price,
           ticket, slippage, check_history,
           this_ea_close_conditions, force_stop_price);

  AdjustLots(check_history, continue_loss, MAGIC, lots, normal_lots, min_lots);
};

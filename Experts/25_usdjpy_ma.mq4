#property strict
#include "proxy.mqh"

// マジックナンバー
#define MAGIC   25                   //マジックナンバー

double lots = 0.01;
string current = USDJPY;

input double normal_lots = 0.01;
input double min_lots = 0.01;
input int profit = 300;
input int loss = 120;
input int continue_loss = 3;
input int entry_interval = 1000000;

int entry_start_hour = ten;
int entry_end_hour = twenty_two;

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

void OnInit(){
  WeekStartEmail(email);
  day_start_hour = DayStartHourUpdate();
  entry_start_hour = EntryStartUpdate(twelve);
  entry_end_hour = EntryEndUpdate(twenty_four);
  // entry_hour = EntryHourUpdate(zero);
  entry_time = SetLastEntryTime(MAGIC);
};

void OnTick(){
  if (IsDayStartTime()) {
  WeekStartEmail(email);
  day_start_hour = DayStartHourUpdate();
  entry_start_hour = EntryStartUpdate(twelve);
  entry_end_hour = EntryEndUpdate(twenty_four);
  // entry_hour = EntryHourUpdate(zero);
  entry_time = SetLastEntryTime(MAGIC);
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

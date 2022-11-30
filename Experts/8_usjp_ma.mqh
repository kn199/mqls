#property strict
#include "proxy.mqh"
#define EIGHT_MAGIC 8

int a8_ticket = 0;
int a8_pos = NO_POSITION;
string a8_current = USDJPY;

input int a8_profit = 300;          // MA8:利益ポイント
input int a8_loss = 120;            // MA8:損失ポイント

input int a8_min_lots_mode = true;  // MA8:ロット調整 0=通常, 1=0.01
double a8_normal_lots = AdjustLotsByLossPoint(a8_loss);
double a8_min_lots = min_lots;     // MA8:連続敗戦時の縮小ロット
double a8_lots = a8_normal_lots;

input int a8_continue_loss = 3;     // MA8:ロット減になる失敗連続回数

// !!!!!!!! entry_interval 100000以上に
int a8_entry_interval = minimum_entry_interval; // MA8:オーダー間隔(秒)
int a8_entry_start_hour = ten;
int a8_entry_end_hour = twenty_two;

bool a8_common_entry_conditions = false;
bool a8_open_conditions = false;
bool a8_close_conditions = false;
bool a8_buy_conditions = false;
bool a8_sell_conditions = false;

double a8_entry_price;
datetime a8_entry_time;

double MA1_1h;
double MA2_1h;
double MA3_1h;
double MA4_1h;
double MA5_1h;
double MA6_1h;
double MA1_4h;
double MA2_4h;

void A8Init(){
  a8_entry_start_hour = EntryStartUpdate(twelve);
  a8_entry_end_hour = EntryEndUpdate(twenty_four);
  a8_entry_time = GetLastEntryTime(EIGHT_MAGIC);

  a8_lots = AdjustLotsByResult(a8_continue_loss, EIGHT_MAGIC,
                               a8_normal_lots, a8_min_lots);
  if (a8_min_lots_mode) {
    a8_lots = MinLots();
  };

  NoticeLots(a8_lots, EIGHT_MAGIC);
};

void A8Tick(){
  a8_common_entry_conditions =
    IsCommonConditon(a8_pos, a8_entry_time, a8_entry_interval);

  if(LocalMinute() == 0)
    {
      MA1_1h = iMA(
                     a8_current,    // 通貨ペア
                     PERIOD_H1,     // 時間軸、現在表示の時間軸で返す処理
                     5,             // 平均期間
                     0,             // 移動平均シフト
                     MODE_SMA,      // 適用価格（ローソク終値）
                     PRICE_OPEN,    // ラインインデックス
                     0              // シフト:0
                   );
                   
      MA2_1h = iMA(a8_current,PERIOD_H1,25,0,MODE_SMA,PRICE_OPEN,0);
      MA3_1h = iMA(a8_current,PERIOD_H1,75,0,MODE_SMA,PRICE_OPEN,0);
      MA4_1h = iMA(a8_current,PERIOD_H1,5,0,MODE_SMA,PRICE_OPEN,1);
      MA5_1h = iMA(a8_current,PERIOD_H1,25,0,MODE_SMA,PRICE_OPEN,1);
      MA6_1h = iMA(a8_current,PERIOD_H1,75,0,MODE_SMA,PRICE_OPEN,1);
      MA1_4h = iMA(a8_current,PERIOD_H4,5,0,MODE_SMA,PRICE_OPEN,0);
      MA2_4h = iMA(a8_current,PERIOD_H4,25,0,MODE_SMA,PRICE_OPEN,0);
    };

  a8_open_conditions = (
                          LocalHour() >= a8_entry_start_hour &&
                          LocalHour() <= a8_entry_end_hour &&
                          LocalMinute() == 0 &&
                          LocalSecond() > 30
                        );

  a8_buy_conditions = (
                        iOpen(a8_current,60,1) < iClose(a8_current,60,1) &&
                        iClose(a8_current,60,1) > iClose(a8_current,60,2) &&
                        iHigh(a8_current,60,1) > iHigh(a8_current,60,2) &&
                        iLow(a8_current,60,1) > iLow(a8_current,60,2) &&
                        iClose(a8_current,30,1) > iClose(a8_current,30,2) &&
                        iHigh(a8_current,30,1) > iHigh(a8_current,30,2) &&
                        iLow(a8_current,30,1) > iLow(a8_current,30,2) &&
                        MA1_4h > MA2_4h &&   //1時間足で5本線が25本線より高いこと
                        MA1_1h > MA2_1h &&   //4時間足でも5本線が25本線より高いこと
                        MA4_1h < MA5_1h      //ローソク1本右にずらした平均線ではまだGクロスが起きていないこと、クロスした直後にエントリする狙い
                      );

  a8_sell_conditions = (
                         iOpen(a8_current,60,1) > iClose(a8_current,60,1) &&
                         iClose(a8_current,60,1) < iClose(a8_current,60,2) &&
                         iHigh(a8_current,60,1) < iHigh(a8_current,60,2) &&
                         iLow(a8_current,60,1) < iLow(a8_current,60,2) &&
                         iClose(a8_current,30,1) < iClose(a8_current,30,2) &&
                         iHigh(a8_current,30,1) < iHigh(a8_current,30,2) &&
                         iLow(a8_current,30,1) < iLow(a8_current,30,2) &&
                         MA1_4h < MA2_4h &&
                         MA1_1h < MA2_1h &&
                         MA4_1h > MA5_1h
                       );

  if (BasicCondition(a8_common_entry_conditions, a8_open_conditions)){
    OrderEntry(a8_buy_conditions, a8_sell_conditions, a8_ticket, a8_lots,
               EIGHT_MAGIC, a8_pos, a8_entry_price, a8_entry_time, a8_entry_interval);
  };

  OrderEnd(a8_pos, a8_profit, a8_loss, a8_entry_price,
           a8_ticket, a8_close_conditions);
};

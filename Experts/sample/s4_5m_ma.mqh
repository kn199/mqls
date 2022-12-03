#property strict
#include "../proxy.mqh"

#define MAGIC_S4 1004

int s4_ticket = 0;
int s4_pos = NO_POSITION;
string s4_current = USDJPY;

input int s4_profit = 50;          // s4:利益ポイント
input int s4_loss = 50;            // s4:損失ポイント

input int s4_min_lots_mode = true;  // s4:ロット調整 0=通常, 1=0.01
double s4_lots = AdjustLotsByLossPoint(s4_loss);
double s4_normal_lots = s4_lots;
double s4_min_lots = min_lots;     // s4:連続敗戦時の縮小ロット

input int s4_continue_loss = 3;     // s4:ロット減になる失敗連続回数

// !!!!!!!! entry_interval 100000以上に
int s4_entry_interval = minimum_entry_interval;

int s4_entry_start_hour = twelve;
int s4_entry_end_hour = twenty_four;

bool s4_common_entry_conditions = false;
bool s4_open_conditions = true;
bool s4_close_conditions = false;
bool s4_buy_conditions = false;
bool s4_sell_conditions = false;

double s4_entry_price;
datetime s4_entry_time;

int short_timeframe = 5;

double MA1_5m;
double MA2_5m;
double MA3_5m;
double MA4_5m;
double MA5_5m;
double MA6_5m;

void S4Init(){
  s4_entry_time = GetLastEntryTime(MAGIC_S4);

  s4_lots = AdjustLotsByResult(s4_continue_loss, MAGIC_S4,
                               s4_normal_lots, s4_min_lots);
  if (s4_min_lots_mode) {
    s4_lots = MinLots();
  };

  NoticeLots(s4_lots, MAGIC_S4);
}

void S4Tick(){
  s4_common_entry_conditions =
    IsCommonConditon(s4_pos, s4_entry_time, s4_entry_interval);

  if(LocalMinute() == 0)
    {
      MA1_5m = iMA(
                     NULL,    // 通貨ペア
                     short_timeframe,     // 時間軸、現在表示の時間軸で返す処理
                     5,             // 平均期間
                     0,             // 移動平均シフト
                     MODE_SMA,      // 適用価格（ローソク終値）
                     PRICE_OPEN,    // ラインインデックス
                     0              // シフト:0
                   );
                   
      MA2_5m = iMA(NULL,short_timeframe,25,0,MODE_SMA,PRICE_OPEN,0);
      MA3_5m = iMA(NULL,short_timeframe,75,0,MODE_SMA,PRICE_OPEN,0);
      MA4_5m = iMA(NULL,short_timeframe,5,0,MODE_SMA,PRICE_OPEN,1);
      MA5_5m = iMA(NULL,short_timeframe,25,0,MODE_SMA,PRICE_OPEN,1);
      MA6_5m = iMA(NULL,short_timeframe,75,0,MODE_SMA,PRICE_OPEN,1);
    };

  s4_open_conditions = (
                          LocalHour() >= s4_entry_start_hour &&
                          LocalHour() <= s4_entry_end_hour &&
                          LocalMinute() == 0 &&
                          LocalSecond() > 30
                        );

  s4_buy_conditions = (
    MA1_5m > MA2_5m && 
    MA4_5m < MA5_5m
  );

  s4_sell_conditions = (
    MA1_5m < MA2_5m && 
    MA4_5m > MA5_5m
  );

  if (BasicCondition(s4_common_entry_conditions, s4_open_conditions)){
    OrderEntry(s4_buy_conditions, s4_sell_conditions, s4_ticket, s4_lots,
               MAGIC_S4, s4_pos, s4_entry_price, s4_entry_time, s4_entry_interval);
  };

  OrderEnd(s4_pos, s4_profit, s4_loss, s4_entry_price,
           s4_ticket, s4_close_conditions);
}
#property strict
#include "../proxy.mqh"

#define MAGIC_S3 1003

int s3_ticket = 0;
int s3_pos = NO_POSITION;
string s3_current = USDJPY;

input int s3_profit = 50;          // S3:利益ポイント
input int s3_loss = 50;            // S3:損失ポイント

input int s3_min_lots_mode = true;  // S3:ロット調整 0=通常, 1=0.01
double s3_lots = AdjustLotsByLossPoint(s3_loss);
double s3_normal_lots = s3_lots;
double s3_min_lots = min_lots;     // S3:連続敗戦時の縮小ロット

input int s3_continue_loss = 3;     // S3:ロット減になる失敗連続回数

// !!!!!!!! entry_interval 100000以上に
int s3_entry_interval = minimum_entry_interval;

int s3_entry_start_hour = twelve;
int s3_entry_end_hour = twenty_four;

bool s3_common_entry_conditions = false;
bool s3_open_conditions = true;
bool s3_close_conditions = false;
bool s3_buy_conditions = false;
bool s3_sell_conditions = false;

double s3_entry_price;
datetime s3_entry_time;

int rsi_high_point = 75;
int rsi_low_point = 25;
int timeframe = 5;

double rsi_short_1;
double rsi_short_2;
double rsi_short_3;
double rsi_short_4;

void S3Init(){
  s3_entry_time = GetLastEntryTime(MAGIC_S3);

  s3_lots = AdjustLotsByResult(s3_continue_loss, MAGIC_S3,
                               s3_normal_lots, s3_min_lots);
  if (s3_min_lots_mode) {
    s3_lots = MinLots();
  };

  NoticeLots(s3_lots, MAGIC_S3);
}

void S3Tick(){
  s3_common_entry_conditions =
    IsCommonConditon(s3_pos, s3_entry_time, s3_entry_interval);

  if (IsFiveTimesMinute()){
    rsi_short_1 = iRSI (NULL, timeframe, 14, 0, 1);
    rsi_short_2 = iRSI (NULL, timeframe, 14, 0, 2);
    rsi_short_3 = iRSI (NULL, timeframe, 14, 0, 3);
    rsi_short_4 = iRSI (NULL, timeframe, 14, 0, 4);
  };


  s3_buy_conditions = (
    IsDown(timeframe, 1) &&
    (rsi_short_1 >= rsi_high_point || rsi_short_2 >= rsi_high_point || rsi_short_3 >= rsi_high_point || rsi_short_4 >= rsi_high_point)
  );

  s3_sell_conditions = (
    IsUp(timeframe, 1) &&
    (rsi_short_1 <= rsi_low_point || rsi_short_2 <= rsi_low_point || rsi_short_3 <= rsi_low_point || rsi_short_4 <= rsi_low_point)
  );

  if (BasicCondition(s3_common_entry_conditions, s3_open_conditions)){
    OrderEntry(s3_buy_conditions, s3_sell_conditions, s3_ticket, s3_lots,
               MAGIC_S3, s3_pos, s3_entry_price, s3_entry_time, s3_entry_interval);
  };

  OrderEnd(s3_pos, s3_profit, s3_loss, s3_entry_price,
           s3_ticket, s3_close_conditions);
}
#property strict
#include "../proxy.mqh"

#define MAGIC_S7 1007

int s7_ticket = 0;
int s7_pos = NO_POSITION;
string s7_current = USDJPY;

input int s7_profit = 50;          // s7:利益ポイント
input int s7_loss = 50;            // s7:損失ポイント

input int s7_min_lots_mode = true;  // s7:ロット調整 0=通常, 1=0.01
double s7_lots = AdjustLotsByLossPoint(s7_loss);
double s7_normal_lots = s7_lots;
double s7_min_lots = min_lots;     // s7:連続敗戦時の縮小ロット

input int s7_continue_loss = 3;     // s7:ロット減になる失敗連続回数

// !!!!!!!! entry_interval 100000以上に
int s7_entry_interval = minimum_entry_interval;

int s7_entry_start_hour = twelve;
int s7_entry_end_hour = twenty_four;

bool s7_common_entry_conditions = false;
bool s7_open_conditions = true;
bool s7_close_conditions = false;
bool s7_buy_conditions = false;
bool s7_sell_conditions = false;

double s7_entry_price;
datetime s7_entry_time;

void S7Init(){
  s7_entry_time = GetLastEntryTime(MAGIC_S7);

  s7_lots = AdjustLotsByResult(s7_continue_loss, MAGIC_S7,
                               s7_normal_lots, s7_min_lots);
  if (s7_min_lots_mode) {
    s7_lots = MinLots();
  };
}

bool is_email = true;

void NoticePrice() {
  Print("iClose(NULL,5,1), ", iClose(NULL,5,1));
  Print("iClose(NULL,5,2), ", iClose(NULL,5,2));
  Print("iClose(NULL,5,3), ", iClose(NULL,5,3));
  Print("iClose(NULL,60,1), ", iClose(NULL,60,1));
  Print("iClose(NULL,240,1), ", iClose(NULL,240,1));
  Print("iClose(NULL,1440,1), ", iClose(NULL,1440,1));
  Print("iClose(NULL,10080,1), ", iClose(NULL,10080,1));
  Print("iOpen(NULL,60,1), ", iOpen(NULL,60,1));
  Print("iOpen(NULL,240,1), ", iOpen(NULL,240,1));
  Print("iOpen(NULL,1440,1), ", iOpen(NULL,1440,1));
  Print("iOpen(NULL,10080,1), ", iOpen(NULL,10080,1));

  string describe1 = StringConcatenate(
                    "iClose(NULL,5,1), ", DoubleToString(iClose(NULL,5,1)),
                    ", iClose(NULL,5,2), ", DoubleToString(iClose(NULL,5,2)),
                    ", iClose(NULL,5,3), ", DoubleToString(iClose(NULL,5,3)),
                    ", iClose(NULL,60,1), ", DoubleToString(iClose(NULL,60,1)),
                    ", iClose(NULL,240,1), ", DoubleToString(iClose(NULL,240,1)),
                    ", iClose(NULL,1440,1), ", DoubleToString(iClose(NULL,1440,1)),
                    ", iClose(NULL,10080,1), ", DoubleToString(iClose(NULL,10080,1)),
                    ", iOpen(NULL,60,1), ", DoubleToString(iOpen(NULL,60,1)),
                    ", iOpen(NULL,240,1), ", DoubleToString(iOpen(NULL,240,1)),
                    ", iOpen(NULL,1440,1), ", DoubleToString(iOpen(NULL,1440,1)),
                    ", iOpen(NULL,10080,1), ", DoubleToString(iOpen(NULL,10080,1))
                  );

  SendMail("iCloseの結果", describe1);

  MakeLongCandle(60, 2, one_hour_highs, one_hour_lows, one_hour_opens, one_hour_closes);
  MakeLongCandle(240, 2, four_hour_highs, four_hour_lows, four_hour_opens, four_hour_closes);
  MakeLongCandle(1440, 2, day_highs, day_lows, day_opens, day_closes);
  MakeLongCandle(10080, 2, week_highs, week_lows, week_opens, week_closes);

  Print("one_hour_highs[0], ", one_hour_highs[0]);
  Print("one_hour_lows[0], ", one_hour_lows[0]);
  Print("one_hour_opens[0], ", one_hour_opens[0]);
  Print("one_hour_closes[0], ", one_hour_closes[0]);
  Print("one_hour_highs[1], ", one_hour_highs[1]);
  Print("one_hour_lows[1], ", one_hour_lows[1]);
  Print("one_hour_opens[1], ", one_hour_opens[1]);
  Print("one_hour_closes[1], ", one_hour_closes[1]);
  Print("four_hour_highs[0], ", four_hour_highs[0]);
  Print("four_hour_lows[0], ", four_hour_lows[0]);
  Print("four_hour_opens[0], ", four_hour_opens[0]);
  Print("four_hour_closes[0], ", four_hour_closes[0]);
  Print("four_hour_highs[1], ", four_hour_highs[1]);
  Print("four_hour_lows[1], ", four_hour_lows[1]);
  Print("four_hour_opens[1], ", four_hour_opens[1]);
  Print("four_hour_closes[1], ", four_hour_closes[1]);
  Print("day_highs[0], ", day_highs[0]);
  Print("day_lows[0], ", day_lows[0]);
  Print("day_opens[0], ", day_opens[0]);
  Print("day_closes[0], ", day_closes[0]);
  Print("day_highs[1], ", day_highs[1]);
  Print("day_lows[1], ", day_lows[1]);
  Print("day_opens[1], ", day_opens[1]);
  Print("day_closes[1], ", day_closes[1]);
  Print("week_highs[0], ", week_highs[0]);
  Print("week_lows[0], ", week_lows[0]);
  Print("week_opens[0], ", week_opens[0]);
  Print("week_closes[0], ", week_closes[0]);
  Print("week_highs[1], ", week_highs[1]);
  Print("week_lows[1], ", week_lows[1]);
  Print("week_opens[1], ", week_opens[1]);
  Print("week_closes[1], ", week_closes[1]);

  string describe2 = StringConcatenate(
                    "one_hour_highs[0], ", DoubleToString(one_hour_highs[0]),
                    ", one_hour_lows[0], ", DoubleToString(one_hour_lows[0]),
                    ", one_hour_opens[0], ", DoubleToString(one_hour_opens[0]),
                    ", one_hour_closes[0], ", DoubleToString(one_hour_closes[0]),
                    ", one_hour_highs[1], ", DoubleToString(one_hour_highs[1]),
                    ", one_hour_lows[1], ", DoubleToString(one_hour_lows[1]),
                    ", one_hour_opens[1], ", DoubleToString(one_hour_opens[1]),
                    ", one_hour_closes[1], ", DoubleToString(one_hour_closes[1]),
                    ", four_hour_highs[0], ", DoubleToString(four_hour_highs[0]),
                    ", four_hour_lows[0], ", DoubleToString(four_hour_lows[0]),
                    ", four_hour_opens[0], ", DoubleToString(four_hour_opens[0]),
                    ", four_hour_closes[0], ", DoubleToString(four_hour_closes[0]),
                    ", four_hour_highs[1], ", DoubleToString(four_hour_highs[1]),
                    ", four_hour_lows[1], ", DoubleToString(four_hour_lows[1]),
                    ", four_hour_opens[1], ", DoubleToString(four_hour_opens[1]),
                    ", four_hour_closes[1], ", DoubleToString(four_hour_closes[1]),
                    ", day_highs[0], ", DoubleToString(day_highs[0]),
                    ", day_lows[0], ", DoubleToString(day_lows[0]),
                    ", day_opens[0], ", DoubleToString(day_opens[0]),
                    ", day_closes[0], ", DoubleToString(day_closes[0]),
                    ", day_highs[1], ", DoubleToString(day_highs[1]),
                    ", day_lows[1], ", DoubleToString(day_lows[1]),
                    ", day_opens[1], ", DoubleToString(day_opens[1]),
                    ", day_closes[1], ", DoubleToString(day_closes[1]),
                    ", week_highs[0], ", DoubleToString(week_highs[0]),
                    ", week_lows[0], ", DoubleToString(week_lows[0]),
                    ", week_opens[0], ", DoubleToString(week_opens[0]),
                    ", week_closes[0], ", DoubleToString(week_closes[0]),
                    ", week_highs[1], ", DoubleToString(week_highs[1]),
                    ", week_lows[1], ", DoubleToString(week_lows[1]),
                    ", week_opens[1], ", DoubleToString(week_opens[1]),
                    ", week_closes[1], ", DoubleToString(week_closes[1])
  );
  SendMail("MakeLongCandleの結果", describe2);
};

void S7Tick(){
  if (is_email && TimeHour(TimeLocal()) == day_start_hour)
  {
    if (TimeMinute(TimeLocal()) == 5) {
      NoticePrice();
      is_email = false;
    };

    if (TimeMinute(TimeLocal()) == 30) {
      NoticePrice();
      is_email = false;
    };
  }

  if (TimeMinute(TimeLocal()) == 6 || TimeMinute(TimeLocal()) == 31) {
    is_email = true;
  };
}
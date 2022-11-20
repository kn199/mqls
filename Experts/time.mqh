#include "valuables.mqh"
#include "original_methods.mqh"

int LocalSecond() {
  return(TimeSeconds(TimeLocal()));
};

int LocalMinute() {
  return(TimeMinute(TimeLocal()));
};

int LocalHour() {
  return(TimeHour(TimeLocal()));
};

int LocalDayOfWeek() {
  return(TimeDayOfWeek(TimeLocal()));
};

int LocalDay() {
  return(TimeDay(TimeLocal()));
};

bool IsSummerTime() {
  int local_day = LocalDay();
  return(SUMMER_TIME_START_DAY <= local_day && local_day <= SUMMER_TIME_END_DAY);
}

bool IsGoToBi() {
  double mod = MathMod(LocalDay(), 5.0);
  bool result = (mod == 0);
  return(result);
}

bool IsFiveTimesMinute() {
  double mod = MathMod(LocalMinute(), 5.0);
  bool result = (mod == 0 || LocalMinute() == 0);
  return(result);
}

bool IsFifteenTimesMinute() {
  double mod = MathMod(LocalMinute(), 15.0);
  bool result = (mod == 0 || LocalMinute() == 0);
  return(result);
}

bool IsWeekDay() {
  return(1 <= TimeDayOfWeek(TimeLocal()) <= 5);
}

bool IsFirstWeek() {
  return(LocalDay() <= 7);
}

bool IsSecondWeek() {
  int day = LocalDay();
  return(8 <= day && day <= 14);
}

bool IsThirdWeek() {
  int day = LocalDay();
  return(15 <= day && day <= 21);
}

bool IsFourthWeek() {
  int day = LocalDay();
  return(22 <= day && day <= 28);
}

bool IsFifthWeek() {
  return(29 <= day);
}

void TimeUpdate(int &ag_day_start_hour, bool &ag_is_summer, int &ag_summer_entry_start_hour,
                int &ag_summer_entry_end_hour, int &ag_entry_start_hour, int &ag_entry_end_hour,
                datetime &ag_entry_time, const int ag_MAGIC, bool ag_is_init,
                int ag_summer_entry_hour, int &entry_hour)
{
  if (ag_is_init || (ag_is_init == false && LocalHour() == ag_day_start_hour && LocalMinute() == 6 )) {
    SummerTimeAdjust(ag_is_summer, ag_summer_entry_start_hour, ag_summer_entry_end_hour,
                     ag_entry_start_hour, ag_entry_end_hour, ag_day_start_hour,
                     ag_summer_entry_hour, entry_hour);
    SetLastEntryTime(ag_entry_time,ag_MAGIC);
  }
}

void ChangeCommonCondition(int entry_hour, int entry_minute, bool &common_entry_conditions) {
  if (LocalHour() == entry_hour && LocalMinute() == (entry_minute + 1)) {
    common_entry_conditions = false;
  };
}

bool IsCheckConditionTime(int entry_hour, int entry_minute) {
  bool result = (LocalHour() == entry_hour && LocalMinute() == (entry_minute));
  return(result);
}

void WeekStartProcess(const string ag_ea_name, bool &ag_email, bool &ag_is_summer,
                      const int ag_summer_entry_start_hour, const int ag_summer_entry_end_hour,
                      int &ag_entry_start_hour, int &ag_entry_end_hour, int &ag_day_start_hour)
{
  if(
      LocalDayOfWeek() == MONDAY &&
      LocalHour() == ag_day_start_hour &&
      LocalMinute() == 30
    )
    {
      if (ag_email){
        string open_email_text = StringConcatenate(AccountCompany(), ",", ag_ea_name);
        SendMail("週初めの開始連絡", open_email_text);
      };
      ag_email = false;
    };
};

void SummerTimeAdjust(bool &ag_is_summer, const int ag_summer_entry_start_hour, const int ag_summer_entry_end_hour,
                      int &ag_entry_start_hour, int &ag_entry_end_hour, int &ag_day_start_hour,
                      int ag_summer_entry_hour, int &ag_entry_hour)
{
  if (IsSummerTime()){
      ag_is_summer = true;
      ag_entry_start_hour = ag_summer_entry_start_hour;
      ag_entry_end_hour = ag_summer_entry_end_hour;
      ag_day_start_hour = SUMMER_DAY_START_HOUR;
      ag_entry_hour = ag_summer_entry_hour;
  } else {
      ag_is_summer = false;
      ag_entry_start_hour = ag_summer_entry_start_hour + 1;
      ag_entry_end_hour = ag_summer_entry_end_hour + 1;
      ag_day_start_hour = WINTER_DAY_START_HOUR;
      ag_entry_hour = ag_summer_entry_hour + 1;
      if (ag_entry_hour == 24) {
        ag_entry_hour == 0;
      };;
  };
};

void SetLastEntryTime(datetime &ag_entry_time, const int ag_MAGIC)
{
  int history_total = OrdersHistoryTotal() - 1;
  int max_loop = 100;
  int loop_count;

  if (history_total < max_loop){
    loop_count = history_total;
  } else {
    loop_count = max_loop;
  };

  bool is_insert = false;
  // OrderSelectの第一引数が大きいほど最近だろうから降順でループ
  for (int i = loop_count; 0 <= i; i--){
    if (is_insert == false){
      bool result = OrderSelect(i, SELECT_BY_POS, MODE_HISTORY);
      if (result && OrderMagicNumber() == ag_MAGIC){
        ag_entry_time = OrderOpenTime();
        is_insert = true;
      };
    };
  };
  
  // 前回エントリがないので、intervalの制限にひっかからないような時間を設定 nullはNG
  if (is_insert == false){
    ag_entry_time = D'1980.07.19 12:30:27';
  };
};

// 1w:10080, 4h:240, 1h: 60
void MakeLongCandle(const int ag_timeframe, const int ag_make_number, double &ag_highs[], double &ag_lows[],
                    double &ag_opens[], double &ag_closes[], const string ag_current)
{
  int loop_count = ag_timeframe / 60 * ag_make_number;
  int hour_unit = ag_timeframe / 60;
  ArrayResize(ag_highs,ag_make_number);
  ArrayResize(ag_lows,ag_make_number);
  ArrayResize(ag_opens,ag_make_number);
  ArrayResize(ag_closes,ag_make_number);
  ArrayInitialize(ag_highs,0.0);
  ArrayInitialize(ag_lows,0.0);
  ArrayInitialize(ag_opens,0.0);
  ArrayInitialize(ag_closes,0.0);

  // 4h 5本の場合 ag_timeframe: 240, ag_make_number: 5, hour_unit: 4
  for (int i=1; i <= loop_count; i++){
    if (i == 1){
      ag_closes[0] = iClose(ag_current,60,1);
    };

    if (i > hour_unit && MathMod(i-1,hour_unit) == 0){
      ag_closes[(i-1)/hour_unit] = iClose(ag_current,60,i);
    };

    if (i >= hour_unit && MathMod(i,hour_unit) == 0){
      ag_opens[(i/hour_unit)-1] = iOpen(ag_current,60,i);
    };

    if (ag_highs[(i-1)/hour_unit] < iHigh(ag_current,60,i)){
      ag_highs[(i-1)/hour_unit] = iHigh(ag_current,60,i);
    };

    if (ag_lows[(i-1)/hour_unit] == 0){
      ag_lows[(i-1)/hour_unit] = iLow(ag_current,60,i);
    };

    if (ag_lows[(i-1)/hour_unit] > 0 && ag_lows[(i-1)/hour_unit] > iLow(ag_current,60,i)){
      ag_lows[(i-1)/hour_unit] = iLow(ag_current,60,i);
    };
  };
};
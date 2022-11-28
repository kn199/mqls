#include "valuables.mqh"
#include "original_methods.mqh"
#include "order.mqh"
#include "valuables.mqh"

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

int LocalDayOfYear() {
  return(TimeDayOfYear(TimeLocal()));
};

bool IsSummerTime() {
  int local_day = LocalDayOfYear();
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
  int day = LocalDayOfWeek();
  bool result = (MONDAY <= day && day <= FRIDAY);
  return(result);
}

int DayStartHour() {
  int hour ;
  if (IsSummerTime()) {
    hour = SUMMER_DAY_START_HOUR;
  } else {
    hour = WINTER_DAY_START_HOUR;
  };

  return(hour);
}

bool IsDayStartTime() {
  int hour ;
  if (IsSummerTime()) {
    hour = SUMMER_DAY_START_HOUR;
  } else {
    hour = WINTER_DAY_START_HOUR;
  };

  bool result = (LocalHour() == hour && LocalMinute() == 30);

  return(result);
}

bool IsWeekStart() {
  int hour = DayStartHour();

  bool result = (
    LocalDayOfWeek() == MONDAY &&
    LocalHour() == hour &&
    LocalMinute() == 30
  );

  return(result);
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

bool IsEntryOneMinuteLater(const int entry_hour, const int entry_minute) {
  bool result = (LocalHour() == entry_hour && LocalMinute() == (entry_minute + 1) );
  return(result);
}

void ChangeEntryCondition(bool &change_conditions){
  change_conditions = false;
};

bool IsCheckConditionTime(int entry_hour, int entry_minute)
{
  bool result = (LocalHour() == entry_hour && LocalMinute() == entry_minute);
  return(result);
}

void WeekStartEmail(bool &ag_email)
{
  if(IsWeekStart()){
    if (ag_email){
      string open_email_text = StringConcatenate(AccountCompany(), ",", WindowExpertName());
      SendMail("週初めの開始連絡", open_email_text);
    };

    ag_email = false;
  };

  if(
      LocalDayOfWeek() == MONDAY &&
      LocalHour() == DayStartHour() &&
      LocalMinute() == 31 &&
      ag_email == false
    ){
      ag_email = true;
    };
}

int DayStartHourUpdate()
{
  int hour;
  if (IsSummerTime()){
    hour = SUMMER_DAY_START_HOUR;
  } else {
    hour = WINTER_DAY_START_HOUR;
  };

  return(hour);
}

int EntryStartUpdate(int &number)
{
  int hour;
  if (IsSummerTime()){
      hour = number;
  } else {
      hour = number + 1;
  };

  return(hour);
}

int EntryEndUpdate(const int number)
{
  int hour;
  if (IsSummerTime()){
    hour = number;
  } else {
    hour = number + 1;
  };

  return(hour);
}

int EntryHourUpdate(const int number)
{
  int hour;
  if (IsSummerTime()){
    hour = number;
  } else {
    hour = number + 1;
  };

  return(hour);
};

// 夏時間23時にエントリする場合、冬時間0で曜日をずらす処理を行う
void EntryHourUpdateOverDay(int &ag_entry_hour, int ag_summer_entry_hour,
                            int &ag_entry_day_of_week, int ag_summer_entry_day_of_week)
{
  if (IsSummerTime()){
    ag_entry_hour = ag_summer_entry_hour;
    ag_entry_day_of_week = ag_summer_entry_day_of_week;
  } else {
    ag_entry_hour = 0;
    ag_entry_day_of_week = ag_summer_entry_day_of_week + 1;
  };
};

datetime GetLastEntryTime(const int ag_MAGIC)
{
  datetime entry_time;

  // 決済済みの注文、無限ループの取引中注文
  datetime history_order_time;
  datetime entrying_order_time;

  int array[2] = {100, 0};
  // なぜか上で直接OrdersHistoryTotal()を代入できない。
  array[1] = OrdersHistoryTotal();
  int loop_count = array[ArrayMinimum(array, WHOLE_ARRAY, 0)];

  // OrderSelectの第一引数が大きいほど最近だろうから降順でループ
  for (int i = loop_count; 0 <= i; i--){
    if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) && OrderMagicNumber() == ag_MAGIC){
      history_order_time = OrderOpenTime();
      if(history_order_time != NULL) {
        break;
      };
    };
  };
  
  for (int n = 10; 0 <= n; n--){
    if (OrderSelect(n, SELECT_BY_POS, MODE_TRADES) && OrderMagicNumber() == ag_MAGIC){
      entrying_order_time = OrderOpenTime();
      if(entrying_order_time != NULL) {
        break;
      };
    };
  };

  // 前回エントリが直近でないので、intervalの制限にひっかからないような時間を設定 nullはNG
  if (history_order_time == NULL){
    history_order_time = D'2000.07.19 12:30:27';
  };

  if (entrying_order_time == NULL){
    entrying_order_time = D'1990.07.19 12:30:27';
  };

  // 新しいdatetimeが<で大きい方となる
  if (history_order_time < entrying_order_time) {
    entry_time = entrying_order_time;
  } else {
    entry_time = history_order_time;
  };

  return(entry_time);
};

bool IsOkContinuos(const int ag_MAGIC, const int ag_entry_interval){
  bool result = false;
  datetime last_entry_time = GetLastEntryTime(ag_MAGIC);
  int diff = (TimeCurrent() - last_entry_time);

  int interval;
  // 1日：86400秒
  if (ag_entry_interval < 1000000) {
    interval = 1000000;
  } else {
    interval = ag_entry_interval;
  }

  if (interval < diff){
    result = true;
  };

  return(result);
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
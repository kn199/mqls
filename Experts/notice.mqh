#include "time.mqh"
#include "valuables.mqh"
#include "original_methods.mqh"

void EmailStatusChangeTime(bool &ag_email) {  
  int day_start_hour;
  if (SUMMER_TIME_START_DAY <= DayOfYear() && DayOfYear() <= SUMMER_TIME_END_DAY) {
    day_start_hour = SUMMER_DAY_START_HOUR;
  } else {
    day_start_hour = WINTER_DAY_START_HOUR;
  };

  if(
      LocalDayOfWeek() == MONDAY &&
      LocalHour() == day_start_hour &&
      LocalMinute() == 31
    ){
      ag_email = true;
    };
};

void TenSecondsIntervalMail(const int ag_timeframe, const int ag_make_number, double &ag_highs[],
                            double &ag_lows[], double &ag_opens[], double &ag_closes[],
                            const string ag_current, const int ag_day_start_hour)
{
  bool condition;
  bool is_calc_hour;
  // 4時間足は0分,日と週は5分だが5に合わせる
  int calc_minutes = 5;
  bool send = false;
  int local_hour = LocalHour();
  int local_minute = LocalMinute();
  int local_day_of_week = LocalDayOfWeek();
  
  if (ag_timeframe == 240){
      int hours[];
      int count = 0;
      for(int i = ag_day_start_hour - 20; i <= ag_day_start_hour + 20; i+4){
        hours[count] = i;
        count++;
      };

      is_calc_hour = IntInclude(hours, local_hour);
      condition = (local_minute == calc_minutes && is_calc_hour);       
  } else if (ag_timeframe == 1440){
      is_calc_hour = (local_hour == ag_day_start_hour);
      condition = (                    
                    MONDAY <= local_day_of_week &&
                    local_day_of_week < SATURDAY &&
                    is_calc_hour &&
                    local_minute == calc_minutes
                  );
  } else if (ag_timeframe == 10080){
      is_calc_hour = (local_hour == ag_day_start_hour);
      condition = (
                    local_day_of_week == MONDAY &&
                    is_calc_hour &&
                    local_minute == calc_minutes
                  );
  };

  // 長時間足を作成する。30秒以降なのは、分の切り替わり直後は古い価格データになるから
  if (condition && LocalSecond() > 30) {
    MakeLongCandle(ag_timeframe, ag_make_number, ag_highs, ag_lows, ag_opens, ag_closes, ag_current);
  };

  string title = StringConcatenate(IntegerToString(ag_timeframe),",",IntegerToString(ag_make_number),"本");
  int mail_minutes = calc_minutes + 2;

  // 計算時間の1~2分後にメールする
  if (is_calc_hour && local_minute == mail_minutes && send == false){
      send = true;
      string describe;
      for (int i=0; i <= ag_make_number-1; i++){
        describe = StringConcatenate(
                    "highs",StringConcatenate(i),",",DoubleToString(ag_highs[i],3),
                    "lows",StringConcatenate(i),",",DoubleToString(ag_lows[i],3),
                    "opens",StringConcatenate(i),",",DoubleToString(ag_opens[i],3),
                    "closes",StringConcatenate(i),",",DoubleToString(ag_closes[i],3)
                  );
      };
      SendMail(title, describe);
    };

  // 計算する時間と分の1分後にメール変数をfalseにする 
  if (is_calc_hour && local_minute == mail_minutes + 1){
    send = false;
  };
};

void NoticeAccountEquity() {
  if (AccountEquity() < min_account_money){
    SendMail("設定した証拠金を下回りました。","");
  };
};
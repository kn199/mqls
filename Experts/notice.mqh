#include "time.mqh"
#include "order.mqh"
#include "valuables.mqh"
#include "original_methods.mqh"

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
      for (int number=0; number <= ag_make_number-1; number++){
        describe = StringConcatenate(
                    "highs",StringConcatenate(number),",",DoubleToString(ag_highs[number],3),
                    "lows",StringConcatenate(number),",",DoubleToString(ag_lows[number],3),
                    "opens",StringConcatenate(number),",",DoubleToString(ag_opens[number],3),
                    "closes",StringConcatenate(number),",",DoubleToString(ag_closes[number],3)
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

void NoticeLots(const double ag_lots, const int ag_MA) {
  string describe = StringConcatenate(
    "ロット ", ag_lots, ", MA ", ag_MA, "会社 ", AccountCompany()
  );

  // Print("ロット情報", describe);
  // SendMail("ロットの連絡", describe);
};
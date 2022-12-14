#property strict
#include "../proxy.mqh"
#define MAGIC_S9 1009

bool is_email = true;

void NoticePrice() {
  string describe = StringConcatenate(
                    "iClose(NULL,1,0), ", iClose(NULL,1,0),
                    ", 1分足のオープンタイム, ", TimeToStr(iTime(NULL,1,0)),

                    ", iOpen(NULL,1440,0), ", iOpen(NULL,1440,0),
                    ", 日足のオープンタイム shift_0, ", TimeToStr(iTime(NULL,1440,0)),

                    ", iOpen(NULL,1440,1), ", iOpen(NULL,1440,1),
                    ", 日足のオープンタイム shift_1, ", TimeToStr(iTime(NULL,1440,1)),

                    ", iOpen(NULL,1440,2), ", iOpen(NULL,1440,2),
                    ", 日足のオープンタイム shift_2, ", TimeToStr(iTime(NULL,1440,2)),

                    ", iOpen(NULL,1440,3), ", iOpen(NULL,1440,3),
                    ", 日足のオープンタイム shift_3, ", TimeToStr(iTime(NULL,1440,3)),

                    ", iOpen(NULL,10080,0), ", iOpen(NULL,10080,0),
                    ", 週足のオープンタイム, ", TimeToStr(iTime(NULL,10080,0))
  );
  Print(describe);

  // SendMail("TimeToStr", describe);
};

void S9Tick(){
    //if (is_email && TimeHour(TimeLocal()) == day_start_hour){
      NoticePrice();
    //  is_email = false;
    //};

  if (TimeHour(TimeLocal()) == day_start_hour + 1) {
    is_email = true;
  };
}
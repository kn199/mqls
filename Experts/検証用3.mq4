#property strict
#include "proxy.mqh"

int ticket_2 = 0;

void OnTick(){
  if(IsWeekDay() && ChcekPriceDiff(60, UP, 500, 1) && ticket_2 == 0) {
    ticket_2 = OrderSend(NULL, OP_BUY, 0.01, Ask, 30, 0, 0, "a", 1, 0, clrRed);
  }

  if (ticket_2 != 0 && LocalDayOfWeek() == SATURDAY) {
    OrderClose(ticket_2, 0.01, Bid, 30, clrBlue);
    ticket_2 = 0;
  }
};

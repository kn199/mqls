#property strict
#include "proxy.mqh"

int ticket_2 = 0;

void OnTick(){
  double result = 0.01 * (10000 / 30);
  double hoge = NormalizeDouble(result, 2);
  Print(hoge);
};

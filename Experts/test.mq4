#property strict
#include "proxy.mqh"
#include "2_usjp_5_10_buy.mqh"
#include "3_usjp_5_10_sell.mqh"
#include "5_usjp_koyo.mqh"

void OnInit(){

};

void OnTick(){
  datetime hoge = D'2000.07.19 12:30:27';
  datetime fuga = D'1990.07.19 12:30:27';
  
  bool result = (fuga < hoge);

  Print("result", ", ", result);
};

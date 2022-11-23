#include "valuables.mqh"
#include "time.mqh"
#include "notice.mqh"

bool IntInclude(int &ag_int_array[], int target) {
  bool is_include = false;

  for (int count = 0; count < ArraySize(ag_int_array) - 1; count++ ) {
    if (ag_int_array[count] == target) {
      is_include = true;
    }
  }

  return(is_include);
};

void EaStop(const string text) {
  Print("EaStop関数によりEAを停止しました。", text);
  SendMail("EaStop関数によりEAを停止しました。", text);
  ExpertRemove();
};

void EaStopCheck(const string current) {
  if (current != Symbol()){
    EaStop("設定通貨が異なります。");
  }

  if (AccountEquity() < min_account_money){
    EaStop("設定した最小証拠金を下回っています。");
  }
};
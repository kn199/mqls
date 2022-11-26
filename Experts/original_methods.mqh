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

bool ChcekPriceDiff(const int timeframe, const int direct, const int point, const int shift) {
  bool result = false;
  if (direct != UP && direct != DOWN){
    return false;
  };

  if (direct == UP){
    result = (iOpen(NULL, timeframe, shift) + point*_Point < iClose(NULL, timeframe, shift));
  } else {
    result = (iOpen(NULL, timeframe, shift) - point*_Point > iClose(NULL, timeframe, shift));
  };

  return(result);
}

bool IsUp(const int timeframe, const int shift) {
  bool result;
  result = (iOpen(NULL, timeframe, shift) < iClose(NULL, timeframe, shift));

  return(result);
}

bool IsDown(const int timeframe, const int shift) {
  bool result;
  result = (iOpen(NULL, timeframe, shift) > iClose(NULL, timeframe, shift));

  return(result);
}

bool IsHighUp(const int timeframe, const int shift) {
  bool result;
  result = (iHigh(NULL, timeframe, shift + 1) < iHigh(NULL, timeframe, shift));

  return(result);
}

bool IsHighDown(const int timeframe, const int shift) {
  bool result;
  result = (iHigh(NULL, timeframe, shift + 1) > iHigh(NULL, timeframe, shift));

  return(result);
}

bool IsLowUp(const int timeframe, const int shift) {
  bool result;
  result = (iLow(NULL, timeframe, shift + 1) < iLow(NULL, timeframe, shift));

  return(result);
}

bool IsLowDown(const int timeframe, const int shift) {
  bool result;
  result = (iLow(NULL, timeframe, shift + 1) > iLow(NULL, timeframe, shift));

  return(result);
}

bool IsOpenUp(const int timeframe, const int shift) {
  bool result;
  result = (iOpen(NULL, timeframe, shift + 1) < iOpen(NULL, timeframe, shift));

  return(result);
}

bool IsOpenDown(const int timeframe, const int shift) {
  bool result;
  result = (iOpen(NULL, timeframe, shift + 1) > iOpen(NULL, timeframe, shift));

  return(result);
}

bool IsCloseUp(const int timeframe, const int shift) {
  bool result;
  result = (iClose(NULL, timeframe, shift + 1) < iClose(NULL, timeframe, shift));

  return(result);
}

bool IsCloseDown(const int timeframe, const int shift) {
  bool result;
  result = (iClose(NULL, timeframe, shift + 1) > iClose(NULL, timeframe, shift));

  return(result);
}
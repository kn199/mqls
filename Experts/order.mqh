#include "time.mqh"
#include "valuables.mqh"
#include "notice.mqh"
#include "original_methods.mqh"

bool IsCommonConditon(const int ag_pos, const datetime ag_entry_time, const int ag_entry_interval)
{
  // 時間差を秒数に変換
  int time_diff = (TimeCurrent() - ag_entry_time);
  bool result = (
                  ag_pos == NO_POSITION &&
                  time_diff > ag_entry_interval &&
                  AccountEquity() > min_account_money &&
                  IsWeekDay()
                );
  return(result);
};

double AdjustLotsByResult(const int ag_continue_loss, const int ag_MAGIC,
                          const double ag_normal_lots, const double ag_min_lots)
{
  double lots = ag_normal_lots;

  double trade_results[];
  ArrayResize(trade_results, ag_continue_loss);
  ArrayInitialize(trade_results, 0.0);

  int count = 0;
  int histroy_total = OrdersHistoryTotal();

  if (ag_continue_loss <= histroy_total){
    for (int i = histroy_total - 1; 0 <= i; i--){
      // 直近N回のデータがたまったので抜ける
      if(ag_continue_loss <= count){
        break;
      };

      bool result = OrderSelect(i, SELECT_BY_POS, MODE_HISTORY);

      if(OrderMagicNumber() == ag_MAGIC && OrderProfit() != 0){
        trade_results[count] = OrderProfit();
        count++;
      };
    };

    int max_array_index = ArrayMaximum(trade_results, WHOLE_ARRAY, 0);
    if (ag_continue_loss <= ArraySize(trade_results) && trade_results[max_array_index] < 0){
      lots = ag_min_lots;
    };
  };

  return(lots);
};

double AdjustLotsByLossPoint(const int ag_stop_point)
{
  double result = min_lots * (one_time_loss / ag_stop_point);
  result = NormalizeDouble(result, 1);

  if (result < min_lots1){
    result = min_lots;
  }
  return(result);
}

double MinLots() {
  return(min_lots);
}

void Entry(int &ag_ticket, const int ag_opbuy_or_opsell, const double ag_lots,
           const double ag_ask_or_bid, const int ag_MAGIC, int &ag_pos,
           double &ag_entry_price, datetime &ag_entry_time)
{
  ag_ticket = OrderSend(
                         Symbol(),
                         ag_opbuy_or_opsell,
                         ag_lots,
                         ag_ask_or_bid,
                         slippage,
                         0,              //loss: no_set
                         0,              //profit: no_set
                         ag_MAGIC,       //cooment, MAGICでないとわかりにくい
                         ag_MAGIC,       //MAGIC
                         0,              //expire: no_set
                         clrRed
                       );

  if (ag_ticket != -1){
    if(ag_opbuy_or_opsell == OP_BUY){
      ag_pos = BUY_POSITION;
    } else {
      ag_pos = SELL_POSITION;
    };
    OrderSelect(ag_ticket, SELECT_BY_TICKET);
    ag_entry_price = OrderOpenPrice();
    // server time OrderOpenTimeがサーバライム
    ag_entry_time = TimeCurrent();

    string open_email_subject = StringConcatenate(AccountCompany(), ",", WindowExpertName(), ",", ag_MAGIC);
    string open_email_text = StringConcatenate("entry", ",", DoubleToString(ag_entry_price, 3), ",",
                                               "ask_or_bid", DoubleToString(ag_ask_or_bid, 3));
    SendMail(open_email_subject, open_email_text);
  } else {
    SendMail("エントリでメール本文のエラー発生", IntegerToString(GetLastError()));
  };
};

void OrderSettle(int &ag_pos, const int ag_profit, const int ag_loss,
                 const double ag_entry_price, const int ag_ticket,
                 bool &ag_this_ea_close_conditions)
{
  bool conditions_buy = ag_pos == BUY_POSITION &&
                        (
                          Bid >= (ag_profit*_Point + ag_entry_price) ||
                          Bid <= (ag_entry_price - ag_loss*_Point)
                        );

  bool conditions_sell = ag_pos == SELL_POSITION && 
                         (
                            Ask <= (ag_entry_price - ag_profit*_Point) ||
                            Ask >= (ag_loss*_Point + ag_entry_price)
                         );

  bool saturday_pos = (LocalDayOfWeek() == SATURDAY && ag_pos != 0);
  if (saturday_pos ||
      ag_this_ea_close_conditions ||
      conditions_buy ||
      conditions_sell)
  {
    bool result = OrderSelect(ag_ticket, SELECT_BY_TICKET);
    double ask_or_bid;

    if (OrderType() == OP_BUY){
      ask_or_bid = Bid;
    };

    if (OrderType() == OP_SELL){
      ask_or_bid = Ask;
    };

    result = OrderClose(ag_ticket, OrderLots(), ask_or_bid, slippage, clrBlue);

    if (result){
      ag_pos = NO_POSITION;
    } else {
      SendMail("クロースで本文のエラー発生", IntegerToString(GetLastError()));
    };
  };
};

void ForcePriceStop(const int ag_pos)
{
  if(
      LocalMinute() == 14 &&
      (ag_pos == BUY_POSITION || ag_pos == SELL_POSITION)
    )
    {
      for(int i = 0; i <= OrdersTotal() - 1; i++)
        {
          bool result = OrderSelect(i, SELECT_BY_POS);
          if (OrderProfit() < force_stop_price && OrderSymbol() == Symbol()){
            double bid_or_ask;
            if (OrderType() == OP_BUY){bid_or_ask = Bid;};
            if (OrderType() == OP_SELL){bid_or_ask = Ask;};
            result = OrderClose(OrderTicket(), OrderLots(), bid_or_ask, slippage, clrBrown);
          };

          if(result){
            NoticeAccountEquity();
          } else {
            SendMail("クローズで本文のエラー発生", IntegerToString(GetLastError()));
          };
        };
    };
};

bool BasicCondition(bool &ag_common_entry_conditions, bool &ag_this_ea_open_conditions){
  bool result = (ag_common_entry_conditions && ag_this_ea_open_conditions);
  return(result);
}

void OrderEntry(bool &ag_buy_conditions, bool &ag_sell_conditions, int &ag_ticket,
                double &ag_lots, const int ag_MAGIC, int &ag_pos,
                double &ag_entry_price, datetime &ag_entry_time, const int ag_entry_interval)
{
  bool result;
  if (ag_buy_conditions || ag_sell_conditions){
    result = IsOkContinuos(ag_MAGIC, ag_entry_interval);
  };

  if (ag_buy_conditions) {
    if (result) {
      Entry(ag_ticket, OP_BUY, ag_lots, Ask, ag_MAGIC,
            ag_pos, ag_entry_price, ag_entry_time);
    };
  };

  if (ag_sell_conditions) {
    if (result) {
      Entry(ag_ticket, OP_SELL, ag_lots, Bid, ag_MAGIC,
            ag_pos, ag_entry_price, ag_entry_time);
    };
  };
};

bool HavePosition(const int ag_pos){
  bool result = (ag_pos != NO_POSITION);
  return(result);
};

void OrderEnd(int &ag_pos, const int ag_profit, const int ag_loss, double &ag_entry_price,
              int &ag_ticket, bool &ag_close_conditions)
{
  OrderSettle(ag_pos, ag_profit, ag_loss, ag_entry_price,
              ag_ticket, ag_close_conditions);
  ForcePriceStop(ag_pos);
};

// entry_intervalが短い(特に360以下)と注文ループの恐れ、initで使用
void PreventContinueusOrder(int entry_interval) {
  if (entry_interval < 100000){
    EaStop("注文ループの恐れによりEAを停止しました。");  
  };
}
#include "time.mqh"
#include "valuables.mqh"
#include "notice.mqh"
#include "original_methods.mqh"

bool IsCommonConditon(const int ag_pos, const datetime ag_entry_time, const int ag_entry_interval)
{
  bool result = (
                  ag_pos == NO_POSITION &&
                  TimeCurrent() - ag_entry_time > ag_entry_interval &&
                  AccountEquity() > min_account_money &&
                  IsWeekDay()
                );
  return(result);
};

void AdjustLots(bool &ag_check_history, const int ag_continue_loss, const int ag_MAGIC,
                double &ag_lots, const double ag_normal_lots, const double ag_min_lots)
{
  if (ag_check_history){
    bool is_normal_lots = true;
    int histroy_total = OrdersHistoryTotal();

    if (ag_continue_loss <= histroy_total){
      is_normal_lots = false;
      int ellement = 0;
      double trade_results[];
      ArrayResize(trade_results, ag_continue_loss);
      ArrayInitialize(trade_results, 0.0);

      for (int i = histroy_total - 1; 0 <= i; i--){
        if(ag_continue_loss - 1 < ellement){
          break;
        };

        bool result = OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
        if(
            OrderMagicNumber() == ag_MAGIC &&
            OrderProfit() != 0
          )
          {
            trade_results[ellement] = OrderProfit();
            ellement++;
          };
      };

      for (int number = 0; number <= ag_continue_loss - 1; number++){
        if (0 < trade_results[number]){
          is_normal_lots = true;
        };
      };
    };

    if (is_normal_lots){
      ag_lots = ag_normal_lots;
    } else {
      ag_lots = ag_min_lots;
    };

    ag_check_history = false;
  };
};

void MinLots(const bool min_lots_mode, double &lots) {
  if (min_lots_mode == true) {
    lots = 0.01;
  };
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
                 bool &ag_check_history, bool &ag_this_ea_close_conditions)
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
      ag_check_history = true;
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
                double &ag_entry_price, datetime &ag_entry_time)
{
  if (ag_buy_conditions) {
    Entry(ag_ticket, OP_BUY, ag_lots, Ask, ag_MAGIC,
          ag_pos, ag_entry_price, ag_entry_time);
  };

  if (ag_sell_conditions) {
    Entry(ag_ticket, OP_SELL, ag_lots, Bid, ag_MAGIC,
          ag_pos, ag_entry_price, ag_entry_time);
  };
};

void OrderEnd(int &ag_pos, const int ag_profit, const int ag_loss, double &ag_entry_price,
              int &ag_ticket, bool &ag_check_history, bool &ag_this_ea_close_conditions)
{
  OrderSettle(ag_pos, ag_profit, ag_loss, ag_entry_price, ag_ticket,
              ag_check_history, ag_this_ea_close_conditions);
  ForcePriceStop(ag_pos);
};

// variables/constants
#define NO_POSITION 0
#define BUY_POSITION 1
#define SELL_POSITION -1
#define SUMMER_TIME_START_DAY 67
#define SUMMER_TIME_END_DAY 309
#define SUMMER_DAY_START_HOUR 6
#define WINTER_DAY_START_HOUR 7
#define MONDAY 1
#define SATURDAY 6
#define USDJPY "USDJPY"
#define EURUSD "EURUSD"
#define EURJPY "EURJPY"
#define MONDAY 1
#define SATURDAY 6

input double input_force_stop_price = -1000000.0;
double force_stop_price = input_force_stop_price;

input double input_min_account_money = 1000.0;
double min_account_money = input_min_account_money;

input int input_slippage = 3;
int slippage = input_slippage;

int day_start_hour = SUMMER_DAY_START_HOUR;

double four_hour_highs[];
double four_hour_lows[];
double four_hour_opens[];
double four_hour_closes[];

double day_highs[];
double day_lows[];
double day_opens[];
double day_closes[];

double week_highs[];
double week_lows[];
double week_opens[];
double week_closes[];

// timeframe_array[time_input]とかをコード上に仕組んで、時間足で遺伝的アルゴリズムを検証する
int timeframe_array[10] = {0,1,5,15,30,60,240,1440,10080,43200};
input int time_input = 0;

// current_array[current_input]とかをコード上に仕組んで、通貨で遺伝的アルゴリズムを検証する
string current_array[3] = {USDJPY,EURUSD,EURJPY};
input int current_input = 0;

// methods
int LocalSecond()
{
  int result = TimeSeconds(TimeLocal());
  return(result);
};

int LocalMinute()
{
  int result = TimeMinute(TimeLocal());
  return(result);
};

int LocalHour()
{
  int result = TimeHour(TimeLocal());
  return(result);
};

int LocalDayOfWeek()
{
  int result = TimeDayOfWeek(TimeLocal());
  return(result);
};

void WeekStartProcess(const string ag_env_name,const string ag_ea_name,bool &ag_email,bool &ag_is_summer,
                      const int ag_summer_entry_start_hour,const int ag_summer_entry_end_hour,
                      int &ag_entry_start_hour,int &ag_entry_end_hour,int &ag_day_start_hour)
{
  SummerTimeAdjust(ag_is_summer,ag_summer_entry_start_hour,ag_summer_entry_end_hour,ag_entry_start_hour,ag_entry_end_hour,ag_day_start_hour);

  if(
      LocalDayOfWeek() == MONDAY &&
      LocalHour() == ag_day_start_hour &&
      LocalMinute() == 30
    )
    {
      if(ag_email)
        {
          string open_email_text = StringConcatenate(ag_env_name,",",ag_ea_name);
          SendMail("週初めの開始連絡",open_email_text);
        };
      ag_email = false;
    };
};

void SummerTimeAdjust(bool &ag_is_summer,const int ag_summer_entry_start_hour,const int ag_summer_entry_end_hour,
                      int &ag_entry_start_hour,int &ag_entry_end_hour,int &ag_day_start_hour)
{
  if(SUMMER_TIME_START_DAY <= DayOfYear() && DayOfYear() <= SUMMER_TIME_END_DAY)
    {
      ag_is_summer = true;
      ag_entry_start_hour = ag_summer_entry_start_hour;
      ag_entry_end_hour = ag_summer_entry_end_hour;
      ag_day_start_hour = SUMMER_DAY_START_HOUR;
    }
  else
    {
      ag_is_summer = false;
      ag_entry_start_hour = ag_summer_entry_start_hour + 1;
      ag_entry_end_hour = ag_summer_entry_end_hour + 1;
      ag_day_start_hour = WINTER_DAY_START_HOUR;
    };
};

void EmailStatusChangeTime(bool &ag_email)
{
  int day_start_hour;
  
  if(SUMMER_TIME_START_DAY <= DayOfYear() && DayOfYear() <= SUMMER_TIME_END_DAY)
    {day_start_hour = SUMMER_DAY_START_HOUR;}
  else
    {day_start_hour = WINTER_DAY_START_HOUR;};

  if(
      LocalDayOfWeek() == MONDAY &&
      LocalHour() == day_start_hour &&
      LocalMinute() == 31
    )
    {ag_email = true;};
};

void SetLastEntryTime(datetime &ag_entry_time,const int ag_MAGIC)
{
  int histroy_total = OrdersHistoryTotal();
  int ellement = 0;
  for(int i = histroy_total - 1; 0 <= i; i--)
     {
       if(ellement == 1)
         {break;};

       bool result = OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
       if(OrderMagicNumber() == ag_MAGIC)
         {
           ag_entry_time = OrderOpenTime();
           ellement++;
         };
      };

  if(ellement == 0)
    // 前回エントリがないので、intervalの制限にひっかからないような時間を設定
    {ag_entry_time = D'1980.07.19 12:30:27';};
};

bool IsCommonConditon(const int ag_pos,const datetime ag_entry_time,const int ag_entry_interval)
{
  bool result = (ag_pos == NO_POSITION &&
                 TimeCurrent() - ag_entry_time > ag_entry_interval &&
                 AccountEquity() > min_account_money
                );
  return(result);
};

void NoticeAccountEquity(){
  if(AccountEquity() < min_account_money)
     {SendMail("設定した証拠金を下回りました。","");};
};

// 1w:10080, 4h:240, 1h: 60
void MakeLongCandle(const int ag_timeframe,const int ag_make_number,double &ag_highs[],double &ag_lows[],
                    double &ag_opens[],double &ag_closes[],const string ag_current)
{
  int loop_count = ag_timeframe / 60 * ag_make_number;
  int hour_unit = ag_timeframe / 60;
  ArrayResize(ag_highs,ag_make_number);
  ArrayResize(ag_lows,ag_make_number);
  ArrayResize(ag_opens,ag_make_number);
  ArrayResize(ag_closes,ag_make_number);
  ArrayInitialize(ag_highs,0.0);
  ArrayInitialize(ag_lows,0.0);
  ArrayInitialize(ag_opens,0.0);
  ArrayInitialize(ag_closes,0.0);

  for(int i=1; i <= loop_count; i++)
     {
       if(i == 1)
          {ag_closes[0] = iClose(ag_current,60,1);};

        if(i > hour_unit && MathMod(i-1,hour_unit) == 0)
           {ag_closes[(i-1)/hour_unit] = iClose(ag_current,60,i);};

        if(i >= hour_unit && MathMod(i,hour_unit) == 0)
           {ag_opens[(i/hour_unit)-1] = iOpen(ag_current,60,i);};

        if(ag_highs[(i-1)/hour_unit] < iHigh(ag_current,60,i))
          {ag_highs[(i-1)/hour_unit] = iHigh(ag_current,60,i);};

        if(ag_lows[(i-1)/hour_unit] == 0)
          {ag_lows[(i-1)/hour_unit] = iLow(ag_current,60,i);};

        if(ag_lows[(i-1)/hour_unit] > 0 && ag_lows[(i-1)/hour_unit] > iLow(ag_current,60,i))
          {ag_lows[(i-1)/hour_unit] = iLow(ag_current,60,i);};
     };
};

void TenSecondsIntervalMail(const int ag_timeframe,const int ag_make_number,double &ag_highs[],double &ag_lows[],double &ag_opens[],
                            double &ag_closes[],const string ag_current,const int ag_day_start_hour)
{
  string describe = "";
  bool condition;
  bool is_calc_hour;
  int calc_minutes;
  int mail_minutes;
  bool send;
  
  if (ag_timeframe == 240)
     {
       is_calc_hour = (
                        LocalHour() == ag_day_start_hour - 4 ||
                        LocalHour() == ag_day_start_hour ||
                        LocalHour() == ag_day_start_hour + 4 ||
                        LocalHour() == ag_day_start_hour + 8 ||
                        LocalHour() == ag_day_start_hour + 12 ||
                        LocalHour() == ag_day_start_hour + 16
                      );
       calc_minutes = 0;
       condition = (
                     LocalMinute() == calc_minutes &&
                     is_calc_hour
                   );
       
       mail_minutes = calc_minutes + 1;
     }
  else if (ag_timeframe == 1440)
     {
       is_calc_hour = (LocalHour() == ag_day_start_hour);
       calc_minutes = 5;
       mail_minutes = calc_minutes + 2;
       condition = (
                     LocalMinute() == calc_minutes &&
                     is_calc_hour &&
                     MONDAY <= LocalDayOfWeek() &&
                     LocalDayOfWeek() < SATURDAY
                   );
     }
  else if (ag_timeframe == 10080)
     {
       calc_minutes = 5;
       mail_minutes = calc_minutes + 2;
       is_calc_hour = (LocalHour() == ag_day_start_hour);
       condition = (
                     LocalMinute() == calc_minutes &&
                     is_calc_hour &&
                     LocalDayOfWeek() == MONDAY
                   );
     };

  if(
      condition &&
      LocalSecond() > 30
    )
    {
      MakeLongCandle(ag_timeframe,ag_make_number,ag_highs,ag_lows,ag_opens,ag_closes,ag_current);
    };

  string title = StringConcatenate(IntegerToString(ag_timeframe),",",IntegerToString(ag_make_number),"本");

  if(
      is_calc_hour &&
      (
        LocalMinute() == mail_minutes - 1 ||
        LocalMinute() == mail_minutes + 1
      )
    )
    {
      send = false;
    };

  if(is_calc_hour && LocalMinute() == calc_minutes + 1 && send == false)
    {
      describe = "";
      for(int i=0; i <= ag_make_number-1; i++)
         {
           describe = StringConcatenate(describe,
                                        "highs",StringConcatenate(i),",",DoubleToString(ag_highs[i],3),
                                        "lows",StringConcatenate(i),",",DoubleToString(ag_lows[i],3),
                                        "opens",StringConcatenate(i),",",DoubleToString(ag_opens[i],3),
                                        "closes",StringConcatenate(i),",",DoubleToString(ag_closes[i],3)
                                        );
         };
      SendMail(title,describe);
      send = true;
      return;
    };
};

void AdjustLots(bool &ag_check_history,const int ag_continue_loss,
                const int ag_MAGIC,double &ag_lots,const double ag_normal_lots,const double ag_min_lots)
{
  if(ag_check_history)
    {
      bool is_normal_lots = true;
      int histroy_total = OrdersHistoryTotal();

      if(ag_continue_loss <= histroy_total)
        {
          is_normal_lots = false;
          int ellement = 0;
          double trade_results[];
          ArrayResize(trade_results, ag_continue_loss);
          ArrayInitialize(trade_results, 0.0);
          for(int i = histroy_total - 1; 0 <= i; i--)
             {
               if(ag_continue_loss - 1 < ellement)
                 {break;};

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

          for(int number = 0; number <= ag_continue_loss - 1; number++)
             {
               if(0 < trade_results[number])
               {is_normal_lots = true;};
             };
        };

      if(is_normal_lots)
        {ag_lots = ag_normal_lots;}
      else
        {ag_lots = ag_min_lots;};

      ag_check_history = false;
    };
};

void OrderEntry(int &ag_ticket,const string ag_current,const int ag_opbuy_or_opsell,const double ag_lots,
                const double ag_ask_or_bid,const int ag_slippage,const int ag_MAGIC,int &ag_pos,
                double &ag_entry_price,datetime &ag_entry_time,const string ag_env_name,const string ag_ea_name)
{
  string order_comment = StringConcatenate(ag_ea_name,",",DoubleToString(Ask,3),",",DoubleToString(Bid,3));
  ag_ticket = OrderSend(
                         ag_current,
                         ag_opbuy_or_opsell,
                         ag_lots,
                         ag_ask_or_bid,
                         ag_slippage,
                         0,              //loss: no_set
                         0,              //profit: no_set
                         order_comment,  //cooment
                         ag_MAGIC,
                         0,              //expire
                         clrRed
                       );
  if(ag_ticket != -1)
    {
      if(ag_opbuy_or_opsell == OP_BUY)
        {ag_pos = BUY_POSITION;}
      else
        {ag_pos = SELL_POSITION;};
      bool result = OrderSelect(ag_ticket,SELECT_BY_TICKET);
      ag_entry_price = OrderOpenPrice();
      ag_entry_time = TimeCurrent();
      string open_email_subject = StringConcatenate(ag_env_name,",",ag_ea_name);
      string open_email_text = StringConcatenate("entry",",",DoubleToString(ag_entry_price,3),",","ask_or_bid",DoubleToString(ag_ask_or_bid,3));
      SendMail(open_email_subject,open_email_text);
    }
  else
    {SendMail("エントリで本文のエラー発生",IntegerToString(GetLastError()));};
};

void OrderCloseSetUp(int &ag_pos,bool &ag_check_history)
{
  ag_pos = NO_POSITION;
  ag_check_history = true;
  NoticeAccountEquity();
};

void OrderSettleDetail(int &ag_pos,const int ag_ticket,bool &ag_check_history,const int ag_slippage)
{
  bool result = OrderSelect(ag_ticket,SELECT_BY_TICKET);
  double ask_or_bid = Bid;

  if(OrderType() == OP_BUY)
    {ask_or_bid = Bid;};

  if(OrderType() == OP_SELL)
    {ask_or_bid = Ask;};

  result = OrderClose(ag_ticket,OrderLots(),ask_or_bid,ag_slippage,clrBlue);

  if(result)
    {OrderCloseSetUp(ag_pos,ag_check_history);}
  else
    {SendMail("クロースで本文のエラー発生",IntegerToString(GetLastError()));};
};

void OrderSettle(int &ag_pos,const int ag_profit,const int ag_loss,const double ag_entry_price,
                 const int ag_ticket,const int ag_slippage,bool &ag_check_history, bool &ag_this_ea_close_conditions)
{
  if(ag_pos == BUY_POSITION &&
     (
       Bid >= (ag_profit*_Point + ag_entry_price) ||
       Bid <= (ag_entry_price - ag_loss*_Point) ||
       LocalDayOfWeek() == SATURDAY ||
       ag_this_ea_close_conditions
     )
    )
    {OrderSettleDetail(ag_pos,ag_ticket,ag_check_history,ag_slippage);};

  if(ag_pos == SELL_POSITION &&
     (
       Ask <= (ag_entry_price - ag_profit*_Point) ||
       Ask >= (ag_loss*_Point + ag_entry_price) ||
       LocalDayOfWeek() == SATURDAY ||
       ag_this_ea_close_conditions
     )
    )
    {OrderSettleDetail(ag_pos,ag_ticket,ag_check_history,ag_slippage);};
};

void ForcePriceStop(const int ag_pos,const double ag_force_stop_price,const int ag_slippage)
{
  if(
      LocalMinute() == 14 &&
      (ag_pos == BUY_POSITION || ag_pos == SELL_POSITION)
    )
    {
      for(int i = 0; i <= OrdersTotal() - 1; i++)
        {
          bool result = OrderSelect(i,SELECT_BY_POS);
          if(OrderProfit() < ag_force_stop_price && OrderType() == OP_BUY && OrderSymbol() == Symbol())
            {result = OrderClose(OrderTicket(),OrderLots(),Bid,ag_slippage,clrBrown);};

          if(OrderProfit() < ag_force_stop_price && OrderType() == OP_SELL && OrderSymbol() == Symbol())
            {result = OrderClose(OrderTicket(),OrderLots(),Ask,ag_slippage,clrBrown);};

          if(result)
            {NoticeAccountEquity();}
          else
            {{SendMail("クロースで本文のエラー発生",IntegerToString(GetLastError()));}};
        };
    };
};

void ToDoInit(int &ag_day_start_hour,bool &ag_is_summer,int &ag_summer_entry_start_hour,int &ag_summer_entry_end_hour,
              int &ag_entry_start_hour,int &ag_entry_end_hour,datetime &ag_entry_time,const int ag_MAGIC)
{
  SummerTimeAdjust(ag_is_summer,ag_summer_entry_start_hour,ag_summer_entry_end_hour,ag_entry_start_hour,ag_entry_end_hour,ag_day_start_hour);
  SetLastEntryTime(ag_entry_time,ag_MAGIC);
};

void ToDoTick(int &ag_pos,datetime &ag_entry_time,int &ag_entry_interval,bool &ag_common_entry_conditions,bool &ag_this_ea_open_conditions,
              bool &ag_buy_conditions,bool &ag_sell_conditions,int &ag_entry_start_hour,int &ag_entry_end_hour,const string ag_env_name,const string ag_ea_name,
              bool &ag_email,bool &ag_is_summer,const int ag_summer_entry_start_hour,const int ag_summer_entry_end_hour,
              int &ag_ticket,const string ag_current,double &ag_lots,const int ag_slippage,const int ag_MAGIC,double &ag_entry_price,
              const int ag_profit,const int ag_loss,bool &ag_check_history,const int ag_continue_loss,double &ag_normal_lots,
              const double ag_min_lots,const int ag_force_stop_price,int &ag_day_start_hour,bool &ag_this_ea_close_conditions
             )
{
  ag_common_entry_conditions = IsCommonConditon(ag_pos,ag_entry_time,ag_entry_interval);

  WeekStartProcess(ag_env_name,ag_ea_name,ag_email,ag_is_summer,ag_summer_entry_start_hour,
                   ag_summer_entry_end_hour,ag_entry_start_hour,ag_entry_end_hour,ag_day_start_hour);

  EmailStatusChangeTime(ag_email);

// buy-entry
  if(
      ag_common_entry_conditions &&
      ag_this_ea_open_conditions &&
      ag_buy_conditions
    )
    {OrderEntry(ag_ticket,ag_current,OP_BUY,ag_lots,Ask,ag_slippage,ag_MAGIC,ag_pos,ag_entry_price,ag_entry_time,ag_env_name,ag_ea_name);};

// sell-entry
  if(
      ag_common_entry_conditions &&
      ag_this_ea_open_conditions &&
      ag_sell_conditions
    )
    {OrderEntry(ag_ticket,ag_current,OP_SELL,ag_lots,Bid,ag_slippage,ag_MAGIC,ag_pos,ag_entry_price,ag_entry_time,ag_env_name,ag_ea_name);};

// close
  OrderSettle(ag_pos,ag_profit,ag_loss,ag_entry_price,ag_ticket,ag_slippage,ag_check_history,ag_this_ea_close_conditions);
  ForcePriceStop(ag_pos,ag_force_stop_price,ag_slippage);

// lots
  AdjustLots(ag_check_history,ag_continue_loss,ag_MAGIC,ag_lots,ag_normal_lots,ag_min_lots);
};
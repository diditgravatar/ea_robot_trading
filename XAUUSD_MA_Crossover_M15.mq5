//+------------------------------------------------------------------+
//| Expert Advisor: XAUUSD MA Crossover (M15)                       |
//| Author Didit Farafat 
//+------------------------------------------------------------------+
#property strict

// Input variabel
input int MA_Fast = 35;
input int MA_Slow = 82;
input int SL_Pips = 50;   // Stop Loss dalam pips
input int TP_Pips = 100;  // Take Profit dalam pips
input int Entry_Distance = 200; // Jarak pip setelah persilangan
input double Lot_Size = 0.1;

// Fungsi mendapatkan harga MA
double GetMA(int period, int shift) {
    return iMA(Symbol(), PERIOD_M15, period, 0, MODE_SMA, PRICE_CLOSE, shift);
}

// Fungsi mengecek apakah ada order terbuka
bool IsOrderOpen() {
    for (int i = 0; i < PositionsTotal(); i++) {
        if (PositionGetSymbol(i) == Symbol()) {
            return true;
        }
    }
    return false;
}

// Fungsi membuka posisi
void OpenTrade(int type) {
    double price = (type == ORDER_TYPE_BUY) ? SymbolInfoDouble(Symbol(), SYMBOL_ASK) 
                                            : SymbolInfoDouble(Symbol(), SYMBOL_BID);
    double sl = (type == ORDER_TYPE_BUY) ? price - SL_Pips * _Point : price + SL_Pips * _Point;
    double tp = (type == ORDER_TYPE_BUY) ? price + TP_Pips * _Point : price - TP_Pips * _Point;
    
    MqlTradeRequest request;
    MqlTradeResult result;

    request.action = TRADE_ACTION_DEAL;
    request.symbol = Symbol();
    request.volume = Lot_Size;
    request.type = type;
    request.price = price;
    request.sl = sl;
    request.tp = tp;
    request.deviation = 10;
    request.magic = 123456;
    request.comment = "MA Crossover Trade";
    request.type_filling = ORDER_FILLING_FOK;
    request.type_time = ORDER_TIME_GTC;

    OrderSend(request, result);
}

//+------------------------------------------------------------------+
//| Expert initialization function                                  |
//+------------------------------------------------------------------+
void OnTick() {
    double MA1 = GetMA(MA_Fast, 1);
    double MA2 = GetMA(MA_Slow, 1);
    double PrevMA1 = GetMA(MA_Fast, 2);
    double PrevMA2 = GetMA(MA_Slow, 2);

    // Entry Buy
    if (PrevMA1 < PrevMA2 && MA1 > MA2 && SymbolInfoDouble(Symbol(), SYMBOL_ASK) - MA2 >= Entry_Distance * _Point && !IsOrderOpen()) {
        OpenTrade(ORDER_TYPE_BUY);
    }

    // Entry Sell
    if (PrevMA1 > PrevMA2 && MA1 < MA2 && MA2 - SymbolInfoDouble(Symbol(), SYMBOL_BID) >= Entry_Distance * _Point && !IsOrderOpen()) {
        OpenTrade(ORDER_TYPE_SELL);
    }
}

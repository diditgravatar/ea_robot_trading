//+------------------------------------------------------------------+
//| Expert Advisor: XAUUSD MA Crossover (M15)                       |
//| Author Didit Farafat
//+------------------------------------------------------------------+
#property strict

// Input variabel
input int MA_Fast = 35;
input int MA_Slow = 82;
input int SL_Pips = 300;   // Stop Loss dalam pips
input int TP_Pips = 600;  // Take Profit dalam pips
input int Entry_Distance = 200; // Jarak pip setelah persilangan
input double Lot_Size = 0.1;
 // Untuk saldo $1000 namun jika saldo $100 make Lot_Size = 0.01
// Fungsi mendapatkan harga MA
double GetMA(int period, int shift) {
    return iMA(Symbol(), PERIOD_M15, period, 0, MODE_SMA, PRICE_CLOSE, shift);
}

// Fungsi mengecek apakah ada order terbuka
bool IsOrderOpen() {
    for (int i = 0; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
                return true;
            }
        }
    }
    return false;
}

// Fungsi membuka posisi
void OpenTrade(int type) {
    double price = (type == OP_BUY) ? Ask : Bid;
    double sl = (type == OP_BUY) ? price - SL_Pips * Point : price + SL_Pips * Point;
    double tp = (type == OP_BUY) ? price + TP_Pips * Point : price - TP_Pips * Point;

    OrderSend(Symbol(), type, Lot_Size, price, 3, sl, tp, "MA Crossover Trade", 0, 0, clrBlue);
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
    if (PrevMA1 < PrevMA2 && MA1 > MA2 && Ask - MA2 >= Entry_Distance * Point && !IsOrderOpen()) {
        OpenTrade(OP_BUY);
    }

    // Entry Sell
    if (PrevMA1 > PrevMA2 && MA1 < MA2 && MA2 - Bid >= Entry_Distance * Point && !IsOrderOpen()) {
        OpenTrade(OP_SELL);
    }
}

# ea_robot_trading
Berikut adalah **robot trading otomatis** untuk **XAU/USD (Gold)** yang berjalan di **MetaTrader 4 (MT4) dan MetaTrader 5 (MT5)** pada **timeframe M15**.  

---

## **📌 Spesifikasi Robot (Expert Advisor - EA)**
1. **Indikator yang Digunakan:**  
   - **MA(35) → Fast Moving Average**  
   - **MA(82) → Slow Moving Average**  
2. **Timeframe:** **M15** (15 Menit).  
3. **Sinyal Entry:**  
   - **BUY** jika **MA(35) memotong MA(82) dari bawah ke atas** dan harga sudah naik **200 pips**.  
   - **SELL** jika **MA(35) memotong MA(82) dari atas ke bawah** dan harga sudah turun **200 pips**.  
4. **Aturan Entry:**  
   - **Hanya satu posisi aktif dalam satu waktu** (tidak ada entry baru jika masih ada order terbuka).  
5. **Manajemen Risiko:**  
   - **Stop Loss (SL) dan Take Profit (TP)** dapat disesuaikan.  
6. **Target Platform:**  
   - **MetaTrader 4 (MQL4)**  
   - **MetaTrader 5 (MQL5)**  

---

## **📌 Kode untuk MetaTrader 4 (MQL4)**
Buat file dengan ekstensi **`.mq4`**, misalnya **`XAUUSD_MA_Crossover_M15.mq4`**.

```mql4
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
```

---

## **📌 Kode untuk MetaTrader 5 (MQL5)**
Buat file dengan ekstensi **`.mq5`**, misalnya **`XAUUSD_MA_Crossover_M15.mq5`**.

```mql5
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
```

---

## **📌 Cara Menggunakan EA di MT4 & MT5**
1. **Buka MetaTrader 4 atau MetaTrader 5.**
2. **Klik `File` > `Open Data Folder` > `MQL4` (untuk MT4) atau `MQL5` (untuk MT5) > `Experts`.**
3. **Simpan file `.mq4` atau `.mq5` di dalam folder `Experts`.**
4. **Restart MetaTrader.**
5. **Buka `Navigator` > `Expert Advisors`, cari `XAUUSD_MA_Crossover_M15`, lalu seret ke chart M15.**
6. **Aktifkan trading otomatis (`Algo Trading` di MT5 atau `Auto Trading` di MT4).**

---

## **📌 Kesimpulan**
✔️ **Robot ini hanya berjalan di timeframe M15.**  
✔️ **Membuka posisi saat MA(35) dan MA(82) bersilangan dengan konfirmasi jarak 200 pips.**  
✔️ **Hanya satu order aktif dalam satu waktu.**  
✔️ **Dilengkapi Stop Loss (SL) dan Take Profit (TP).**  

Silakan coba dalam akun demo, setelah robot trading ini 80% profit maka bisa digunakan dalam akun live.

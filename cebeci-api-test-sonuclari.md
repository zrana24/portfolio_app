# Cebeci API - Canli Test Sonuclari

**Tarih:** 2026-04-03
**Ortam:** https://cebecikiymetlimadenler.com (Production)
**Test Kullanicisi:** test-flow-2026@example.com (test sonrasi silindi)

---

## 1. Canli Fiyatlar - Fark Alani

**Endpoint:** `GET /api/v1/prices`
**Durum:** BASARILI

```json
{
    "symbol": "KULCEALTIN",
    "name": "24 Ayar",
    "code": "KULCE",
    "bid": 6781.0022,
    "ask": 6908.4933,
    "high": 0,
    "low": 0,
    "changePercent": 0,
    "fark": 0.2417,
    "fark_percent": 0.0035,
    "timestamp": 1775207080893
}
```

- `fark` ve `fark_percent` alanlari tum sembollerde mevcut
- Gun acilisi satis fiyatindan mevcut zamana kadar olan fark hesaplaniyor

---

## 2. Price History Endpoint

**Endpoint:** `GET /api/v1/prices/USDTRY/history?period=1d`
**Durum:** BASARILI

```json
{
    "data": {
        "symbol": "USDTRY",
        "period": "1d",
        "chart": {
            "labels": ["12:05"],
            "datasets": [{"data": [44.5326]}]
        },
        "points": [
            {"time": "2026-04-03T12:05:52+03:00", "ask": 44.5326, "bid": 44.4645}
        ]
    }
}
```

- Chart yapisi (labels + datasets) mobil chart kutuphanelerine uyumlu
- Points dizisi detayli veri icin mevcut
- Snapshot'lar 5dk'da bir toplanarak veri artacak

**Validasyon:** `?period=invalid` -> 422 "Gecersiz periyot. Gecerli degerler: 1d, 1w, 1m, 3m"

---

## 3. Commodities Endpoint

**Endpoint:** `GET /api/v1/mobile/commodities`
**Durum:** BASARILI

```json
{
    "data": [
        {
            "symbol": "ALTIN",
            "name": "Gram Altin",
            "category": "altin",
            "bid": 6794.69,
            "ask": 6826.34,
            "daily_change": -0.04,
            "daily_change_percent": 0
        }
    ],
    "count": 49
}
```

- Toplam 49 emtia donuyor
- Kategoriler: altin (19), doviz (14), kripto (10), emtia (2), parite (4)
- `daily_change` ve `daily_change_percent` alanlari mevcut
- Public endpoint (auth gerektirmez)

---

## 4. Tam Portfolyo Akisi

### 4.1 Kullanici Kayit
**Endpoint:** `POST /api/v1/auth/register`
**Durum:** BASARILI

```json
{
    "message": "Kayit basarili.",
    "user": {"id": 2, "name": "Test Kullanici", "email": "test-flow-2026@example.com"},
    "token": "2|u3qIbqKS70kyogr5RhbX1vubwM07SgapkrbyBHox3158dfe7"
}
```

### 4.2 Giris
**Endpoint:** `POST /api/v1/auth/login`
**Durum:** BASARILI

```json
{
    "message": "Giris basarili.",
    "user": {"id": 2, "name": "Test Kullanici"},
    "token": "3|3LXICgWqsWnOSkS2ztsFRXdVUniJmh9uDCOi4ckY954be758"
}
```

### 4.3 Portfolyo Olusturma
**Endpoint:** `POST /api/v1/portfolios`
**Durum:** BASARILI

```json
{
    "data": {
        "id": 1,
        "name": "Ana Portfoyum",
        "description": "Test portfoy",
        "currency": "TRY",
        "is_default": true,
        "assets": []
    }
}
```

### 4.4 Varlik Ekleme
**Endpoint:** `POST /api/v1/portfolios/1/assets`
**Durum:** BASARILI (x2)

| Varlik | Miktar | Alis Fiyati | Tarih |
|--------|--------|-------------|-------|
| USDTRY | 1000 | 32.50 TL | 2025-12-15 |
| ALTIN | 50 gr | 3200 TL | 2025-11-01 |

### 4.5 Portfolyo Detay (PnL Hesaplamalari)
**Endpoint:** `GET /api/v1/portfolios/1`
**Durum:** BASARILI

```json
{
    "data": {
        "portfolio_id": 1,
        "name": "Ana Portfoyum",
        "total_invested": 192500,
        "total_current_value": 384197.5,
        "total_profit_loss": 191697.5,
        "total_pnl_percent": 99.58,
        "category_distribution": [
            {"category": "altin", "label": "Altin", "percentage": 88.4},
            {"category": "diger", "label": "Diger", "percentage": 11.6}
        ],
        "assets": [
            {
                "symbol": "ALTIN",
                "current_price": 6794.66,
                "invested": 160000,
                "current_value": 339733,
                "profit_loss": 179733,
                "pnl_percent": 112.33,
                "daily_change": -0.06,
                "daily_change_percent": 0,
                "direction": "down"
            },
            {
                "symbol": "USDTRY",
                "current_price": 44.4645,
                "invested": 32500,
                "current_value": 44464.5,
                "profit_loss": 11964.5,
                "pnl_percent": 36.81,
                "daily_change": -0.0003,
                "daily_change_percent": 0,
                "direction": "down"
            }
        ]
    }
}
```

### 4.6 Mobile Portfolio Summary
**Endpoint:** `GET /api/v1/mobile/portfolio/summary`
**Durum:** BASARILI

- Tum portfolyo ozeti donuyor
- Her varlikta `name`, `daily_change`, `daily_change_percent`, `direction` alanlari mevcut
- `category_distribution` ile pasta grafik verisi hazir

### 4.7 Portfolio Chart
**Endpoint:** `GET /api/v1/mobile/portfolio/1/chart?period=1d`
**Durum:** BASARILI

```json
{
    "data": {
        "ALTIN": {
            "name": "ALTIN",
            "quantity": 50,
            "purchase_price": 3200,
            "chart": {"labels": ["12:05"], "datasets": [{"data": [6826.34]}]},
            "points": [{"time": "2026-04-03T12:05:52+03:00", "ask": 6826.34, "bid": 6794.66}]
        },
        "USDTRY": {
            "name": "USDTRY",
            "quantity": 1000,
            "purchase_price": 32.5,
            "chart": {"labels": ["12:05"], "datasets": [{"data": [44.5326]}]},
            "points": [{"time": "2026-04-03T12:05:52+03:00", "ask": 44.5326, "bid": 44.4645}]
        }
    }
}
```

### 4.8 Guvenlik Testleri
| Test | Sonuc |
|------|-------|
| Auth olmadan portfolio summary | 401 "Unauthenticated" |
| Chart gecersiz period | 422 "Gecersiz periyot" |
| Baska kullanicinin portfolyosu | 404 |

### 4.9 Temizlik
| Islem | Sonuc |
|-------|-------|
| Varlik 1 sil | "Varlik silindi." |
| Varlik 2 sil | "Varlik silindi." |
| Portfolyo sil | "Portfolyo silindi." |
| Hesap sil | "Hesabiniz ve tum verileriniz kalici olarak silindi." |

---

## Ozet

| # | Test | Durum |
|---|------|-------|
| 1 | Fiyatlar fark alani | BASARILI |
| 2 | Price history endpoint | BASARILI |
| 3 | History validasyon (422) | BASARILI |
| 4 | Commodities listesi | BASARILI |
| 5 | Kullanici kayit | BASARILI |
| 6 | Kullanici giris | BASARILI |
| 7 | Portfolyo olusturma | BASARILI |
| 8 | Varlik ekleme (USD) | BASARILI |
| 9 | Varlik ekleme (ALTIN) | BASARILI |
| 10 | Portfolyo PnL hesaplama | BASARILI |
| 11 | Mobile portfolio summary | BASARILI |
| 12 | Portfolio chart data | BASARILI |
| 13 | Auth guard (401) | BASARILI |
| 14 | Period validasyon (422) | BASARILI |
| 15 | Varlik silme | BASARILI |
| 16 | Portfolyo silme | BASARILI |
| 17 | Hesap silme | BASARILI |

**Toplam: 17/17 test BASARILI**

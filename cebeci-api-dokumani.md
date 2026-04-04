# Cebeci Kiymetli Madenler - API Dokumani

**Base URL:** `https://cebecikiymetlimadenler.com/api/v1`
**Auth:** Laravel Sanctum (Bearer Token)
**Format:** JSON
**Timezone:** Europe/Istanbul

---

## Kimlik Dogrulama (Auth)

### Kayit
```
POST /auth/register
```

**Body:**
```json
{
    "name": "Ad Soyad",
    "email": "kullanici@email.com",
    "password": "SifreMin8Karakter",
    "password_confirmation": "SifreMin8Karakter",
    "phone": "05551234567"  // opsiyonel
}
```

**Yanit (201):**
```json
{
    "message": "Kayit basarili.",
    "user": {
        "id": 1,
        "name": "Ad Soyad",
        "email": "kullanici@email.com",
        "phone": null,
        "is_admin": null,
        "last_login_at": null,
        "created_at": "2026-04-03T09:00:00.000000Z"
    },
    "token": "1|abc123..."
}
```

---

### Giris
```
POST /auth/login
```

**Body:**
```json
{
    "email": "kullanici@email.com",
    "password": "SifreMin8Karakter",
    "device_name": "iPhone 15"  // opsiyonel
}
```

**Yanit (200):**
```json
{
    "message": "Giris basarili.",
    "user": { ... },
    "token": "2|xyz789..."
}
```

---

### Cikis
```
POST /auth/logout
Authorization: Bearer {token}
```

**Yanit (200):**
```json
{ "message": "Cikis yapildi." }
```

---

### Profil
```
GET  /auth/me                  -- Profil bilgisi
PUT  /auth/me                  -- Profil guncelle (name, email, phone)
POST /auth/change-password     -- Sifre degistir (current_password, password, password_confirmation)
DELETE /auth/account            -- Hesap sil (password, confirmation: "DELETE")
```

---

## Canli Fiyatlar (Public)

### Tum Fiyatlar
```
GET /prices
```

**Yanit (200):**
```json
{
    "data": [
        {
            "symbol": "KULCEALTIN",
            "name": "24 Ayar",
            "code": "KULCE",
            "bid": 6781.0022,
            "ask": 6908.4933,
            "high": 6920.00,
            "low": 6750.00,
            "changePercent": 0.5,
            "fark": 0.2417,
            "fark_percent": 0.0035,
            "timestamp": 1775207080893
        }
    ],
    "count": 54
}
```

**Alan Aciklamalari:**
| Alan | Tip | Aciklama |
|------|-----|----------|
| symbol | string | Sembol kodu |
| name | string | Turkce isim |
| code | string | Kisa kod |
| bid | number | Alis fiyati (margin uygulanmis) |
| ask | number | Satis fiyati (margin uygulanmis) |
| high | number | Gunun en yuksek fiyati |
| low | number | Gunun en dusuk fiyati |
| changePercent | number | DatShop'tan gelen degisim yuzdesi |
| **fark** | number\|null | Gun acilisindan bu yana satis fiyati farki (ask - opening_ask) |
| **fark_percent** | number\|null | Fark yuzdesi ((fark / opening_ask) * 100) |
| timestamp | number | Son guncelleme (Unix ms) |

---

### Tek Sembol
```
GET /prices/{symbol}
```

**Yanit (200):**
```json
{
    "data": {
        "symbol": "USDTRY",
        "bid": 44.46,
        "ask": 44.53,
        "high": 44.80,
        "low": 44.30,
        "changePercent": -0.2,
        "timestamp": 1775207080893
    }
}
```

**Hata (404):**
```json
{ "message": "Sembol bulunamadi." }
```

---

### Sembol Listesi
```
GET /symbols
```

**Yanit (200):**
```json
{
    "data": [
        {
            "symbol": "ALTIN",
            "name": "Gram Altin",
            "category": "altin",
            "has_price": true
        }
    ],
    "count": 49
}
```

---

## Fiyat Gecmisi (Public)

### Sembol Gecmisi (Chart Data)
```
GET /prices/{symbol}/history?period={period}
```

**Parametreler:**
| Parametre | Degerler | Varsayilan | Aciklama |
|-----------|----------|------------|----------|
| period | 1d, 1w, 1m, 3m | 1d | Zaman araligi |

**Period Detaylari:**
| Period | Zaman Araligi | Aggregasyon | Yaklasik Nokta Sayisi |
|--------|---------------|-------------|----------------------|
| 1d | Bugun | Ham (5dk aralik) | ~192 |
| 1w | Son 1 hafta | Saatlik ortalama | ~224 |
| 1m | Son 1 ay | 2 saatlik ortalama | ~240 |
| 3m | Son 3 ay | Gunluk ortalama | ~90 |

**Yanit (200):**
```json
{
    "data": {
        "symbol": "USDTRY",
        "period": "1d",
        "chart": {
            "labels": ["09:00", "09:05", "09:10", "09:15"],
            "datasets": [
                {
                    "data": [44.50, 44.52, 44.48, 44.55]
                }
            ]
        },
        "points": [
            {
                "time": "2026-04-03T09:00:00+03:00",
                "ask": 44.50,
                "bid": 44.45
            },
            {
                "time": "2026-04-03T09:05:00+03:00",
                "ask": 44.52,
                "bid": 44.47
            }
        ]
    }
}
```

**chart:** React Native chart kutuphanelerine (react-native-chart-kit, victory-native) dogrudan uyumlu format.
**points:** Detayli veri noktasi dizisi (ozel chart kutuphaneleri veya tooltip icin).

**Hata (422):**
```json
{ "message": "Gecersiz periyot. Gecerli degerler: 1d, 1w, 1m, 3m" }
```

---

## Emtia Listesi - Mobil (Public)

### Tum Emtialar
```
GET /mobile/commodities
```

Kullanicinin portfolyosune ekleyecegi emtiayi sectigi ekran icin.

**Yanit (200):**
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
        },
        {
            "symbol": "USDTRY",
            "name": "Amerikan Dolari",
            "category": "doviz",
            "bid": 44.46,
            "ask": 44.53,
            "daily_change": 0.03,
            "daily_change_percent": 0.07
        }
    ],
    "count": 49
}
```

**Kategoriler:**
| Kategori | Aciklama | Sayi |
|----------|----------|------|
| altin | Altin & Sarrafiye | 19 |
| doviz | Doviz | 14 |
| kripto | Kripto Para | 10 |
| emtia | Emtia (Petrol, Dogalgaz) | 2 |
| parite | Doviz Pariteleri | 4 |

---

## Portfolyo (Auth Gerekli)

Tum portfolyo endpointleri `Authorization: Bearer {token}` header'i gerektirir.

### Portfolyo Listesi
```
GET /portfolios
Authorization: Bearer {token}
```

**Yanit (200):**
```json
{
    "data": [
        {
            "portfolio_id": 1,
            "name": "Ana Portfoyum",
            "currency": "TRY",
            "asset_count": 2,
            "total_invested": 192500,
            "total_current_value": 384197.5,
            "total_profit_loss": 191697.5,
            "total_pnl_percent": 99.58,
            "category_distribution": [...],
            "assets": [...]
        }
    ]
}
```

---

### Portfolyo Olustur
```
POST /portfolios
Authorization: Bearer {token}
```

**Body:**
```json
{
    "name": "Ana Portfoyum",
    "description": "Yatirim portfoyum",  // opsiyonel
    "currency": "TRY",                    // TRY, USD, EUR (varsayilan: TRY)
    "is_default": true                     // opsiyonel
}
```

**Yanit (201):**
```json
{
    "data": {
        "id": 1,
        "name": "Ana Portfoyum",
        "description": "Yatirim portfoyum",
        "currency": "TRY",
        "is_default": true,
        "assets": [],
        "created_at": "2026-04-03T09:00:00.000000Z",
        "updated_at": "2026-04-03T09:00:00.000000Z"
    }
}
```

---

### Portfolyo Detay
```
GET /portfolios/{id}
Authorization: Bearer {token}
```

**Yanit (200):**
```json
{
    "data": {
        "portfolio_id": 1,
        "name": "Ana Portfoyum",
        "currency": "TRY",
        "asset_count": 2,
        "total_invested": 192500,
        "total_current_value": 384197.5,
        "total_profit_loss": 191697.5,
        "total_pnl_percent": 99.58,
        "category_distribution": [
            {
                "category": "altin",
                "label": "Altin",
                "current_value": 339733,
                "percentage": 88.4
            }
        ],
        "assets": [
            {
                "symbol": "ALTIN",
                "category": "altin",
                "quantity": 50,
                "purchase_price": 3200,
                "current_price": 6794.66,
                "invested": 160000,
                "current_value": 339733,
                "profit_loss": 179733,
                "pnl_percent": 112.33,
                "daily_change": -0.06,
                "daily_change_percent": 0,
                "direction": "down"
            }
        ]
    }
}
```

**Asset Alanlari:**
| Alan | Tip | Aciklama |
|------|-----|----------|
| symbol | string | Sembol kodu |
| category | string | Kategori (altin, doviz, kripto, emtia, parite) |
| quantity | number | Miktar |
| purchase_price | number | Alis fiyati |
| current_price | number\|null | Guncel bid fiyati |
| invested | number | Toplam yatirim (quantity * purchase_price) |
| current_value | number\|null | Guncel deger (quantity * current_price) |
| profit_loss | number\|null | Kar/Zarar (current_value - invested) |
| pnl_percent | number\|null | Kar/Zarar yuzdesi |
| **daily_change** | number\|null | Gun ici bid fiyat degisimi |
| **daily_change_percent** | number\|null | Gun ici degisim yuzdesi |
| **direction** | string\|null | Yon: "up", "down", "neutral" |

---

### Portfolyo Guncelle
```
PUT /portfolios/{id}
Authorization: Bearer {token}
```

**Body:** (sadece guncellenecek alanlar)
```json
{
    "name": "Yeni Isim",
    "description": "Yeni aciklama",
    "is_default": false
}
```

---

### Portfolyo Sil
```
DELETE /portfolios/{id}
Authorization: Bearer {token}
```

**Yanit (200):**
```json
{ "message": "Portfolyo silindi." }
```

---

### Kullanici Ozeti
```
GET /portfolios/summary
Authorization: Bearer {token}
```

**Yanit (200):**
```json
{
    "data": {
        "portfolio_count": 2,
        "total_assets": 5,
        "total_invested": 250000,
        "total_current_value": 450000,
        "total_profit_loss": 200000,
        "total_pnl_percent": 80.0,
        "category_distribution": [...],
        "portfolios": [...]
    }
}
```

---

## Varlik (Asset) Yonetimi (Auth Gerekli)

### Varlik Ekle
```
POST /portfolios/{portfolio_id}/assets
Authorization: Bearer {token}
```

**Body:**
```json
{
    "symbol": "USDTRY",
    "quantity": 1000,
    "purchase_price": 32.50,
    "purchase_date": "2025-12-15",  // opsiyonel, max: bugun
    "notes": "Dolar alimi"          // opsiyonel
}
```

**Yanit (201):**
```json
{
    "data": {
        "id": 1,
        "portfolio_id": 1,
        "symbol": "USDTRY",
        "quantity": 1000,
        "purchase_price": 32.5,
        "purchase_date": "2025-12-15",
        "notes": "Dolar alimi",
        "created_at": "2026-04-03T09:00:00.000000Z",
        "updated_at": "2026-04-03T09:00:00.000000Z"
    }
}
```

**Validasyon:**
- `symbol`: zorunlu, string
- `quantity`: zorunlu, > 0
- `purchase_price`: zorunlu, >= 0
- `purchase_date`: opsiyonel, tarih, bugunle ayni veya oncesi
- `notes`: opsiyonel, string

---

### Varlik Guncelle
```
PUT /portfolios/{portfolio_id}/assets/{asset_id}
Authorization: Bearer {token}
```

**Body:** (sadece guncellenecek alanlar)
```json
{
    "quantity": 2000,
    "purchase_price": 33.00
}
```

---

### Varlik Sil
```
DELETE /portfolios/{portfolio_id}/assets/{asset_id}
Authorization: Bearer {token}
```

**Yanit (200):**
```json
{ "message": "Varlik silindi." }
```

---

## Mobil Portfolyo Endpointleri (Auth Gerekli)

### Portfolyo Ozeti (Liste Formati)
```
GET /mobile/portfolio/summary
Authorization: Bearer {token}
```

Tum portfolyolerin ozeti. Liste gorunumune uygun, her varlikta `name` ve `direction` alanlari eklenmis.

**Yanit (200):**
```json
{
    "data": {
        "portfolio_count": 1,
        "total_assets": 2,
        "total_invested": 192500,
        "total_current_value": 384197.5,
        "total_profit_loss": 191697.5,
        "total_pnl_percent": 99.58,
        "category_distribution": [
            {"category": "altin", "label": "Altin", "current_value": 339733, "percentage": 88.4},
            {"category": "diger", "label": "Diger", "current_value": 44464.5, "percentage": 11.6}
        ],
        "portfolios": [
            {
                "portfolio_id": 1,
                "name": "Ana Portfoyum",
                "currency": "TRY",
                "asset_count": 2,
                "total_invested": 192500,
                "total_current_value": 384197.5,
                "total_profit_loss": 191697.5,
                "total_pnl_percent": 99.58,
                "assets": [
                    {
                        "symbol": "ALTIN",
                        "category": "altin",
                        "quantity": 50,
                        "purchase_price": 3200,
                        "current_price": 6794.66,
                        "invested": 160000,
                        "current_value": 339733,
                        "profit_loss": 179733,
                        "pnl_percent": 112.33,
                        "daily_change": -0.06,
                        "daily_change_percent": 0,
                        "direction": "down",
                        "name": "Gram Altin"
                    }
                ]
            }
        ]
    }
}
```

---

### Portfolyo Chart Verisi
```
GET /mobile/portfolio/{portfolio_id}/chart?period={period}
Authorization: Bearer {token}
```

**Parametreler:**
| Parametre | Degerler | Varsayilan |
|-----------|----------|------------|
| period | 1d, 1w, 1m, 3m | 1d |

**Yanit (200):**
```json
{
    "data": {
        "ALTIN": {
            "name": "ALTIN",
            "quantity": 50,
            "purchase_price": 3200,
            "chart": {
                "labels": ["09:00", "09:05", "09:10"],
                "datasets": [{"data": [6826.34, 6830.10, 6825.50]}]
            },
            "points": [
                {"time": "2026-04-03T09:00:00+03:00", "ask": 6826.34, "bid": 6794.66},
                {"time": "2026-04-03T09:05:00+03:00", "ask": 6830.10, "bid": 6798.40},
                {"time": "2026-04-03T09:10:00+03:00", "ask": 6825.50, "bid": 6793.80}
            ]
        },
        "USDTRY": {
            "name": "USDTRY",
            "quantity": 1000,
            "purchase_price": 32.5,
            "chart": {
                "labels": ["09:00", "09:05", "09:10"],
                "datasets": [{"data": [44.53, 44.55, 44.51]}]
            },
            "points": [...]
        }
    }
}
```

**Kullanim:**
- `chart.labels` ve `chart.datasets[0].data` dogrudan react-native-chart-kit'e verilebilir
- `points` dizisi ozel tooltip veya detayli grafik kutuphaneleri icin
- Her varlik icin ayri chart verisi doner

---

## Favoriler (Auth Gerekli)

### Favori Listesi
```
GET /favorites
Authorization: Bearer {token}
```

### Favori Ekle
```
POST /favorites
Authorization: Bearer {token}

Body: { "symbol": "ALTIN" }
```

### Favori Sil
```
DELETE /favorites/{symbol}
Authorization: Bearer {token}
```

---

## Haberler (Public)

### Haber Listesi
```
GET /news?page=1&per_page=20&category=altin&search=altin&tag=ekonomi
```

### Haber Detay
```
GET /news/{id}
```

### Mobil Haberler
```
GET /mobile/news?page=1&per_page=20&category=altin
GET /mobile/news/trending
GET /mobile/news/{id}
```

---

## Ayarlar (Public)

### Margin Ayarlari
```
GET  /settings/margins
POST /settings/margins   Body: { "value": { "USDTRY": { "bidMargin": 0.5, "askMargin": 0.75 } } }
```

### Gorunurluk
```
GET  /settings/visibility
POST /settings/visibility   Body: { "value": ["SEMBOL1", "SEMBOL2"] }
```

### Sembol Sirasi
```
GET  /settings/symbol-order
POST /settings/symbol-order   Body: { "value": ["KULCEALTIN", "AYAR22", ...] }
```

---

## Hata Yanitlari

| HTTP Kodu | Aciklama |
|-----------|----------|
| 401 | `{ "message": "Unauthenticated." }` - Token eksik veya gecersiz |
| 403 | `{ "message": "Bu islem icin yetkiniz yok." }` - Yetki hatasi |
| 404 | `{ "message": "Sembol bulunamadi." }` veya model bulunamadi |
| 422 | `{ "message": "...", "errors": { "field": ["hata mesaji"] } }` - Validasyon hatasi |
| 429 | Rate limit asildi (60 istek/dakika, login icin 5/dakika) |

---

## Gercek Zamanli Fiyatlar

### WebSocket (Frontend)
```
URL: wss://cebecikiymetlimadenler.com/price-ws
Transport: Socket.IO (websocket + polling)

Events:
  - "price"        : Baglantida ilk veri
  - "price_update"  : Sonraki guncellemeler
```

### SSE (Mobil)
```
GET https://cebecikiymetlimadenler.com/api/prices/stream
Content-Type: text/event-stream

data: {"USDTRY": {"symbol":"USDTRY","bid":44.46,"ask":44.53,...}, ...}
```

### REST Snapshot
```
GET https://cebecikiymetlimadenler.com/api/prices
GET https://cebecikiymetlimadenler.com/api/prices/{symbol}
```

> Not: Bu REST endpointleri Node.js proxy'den gelir (port 3001 -> nginx proxy).
> `/api/v1/prices` ise Laravel'den gelir ve margin/visibility/fark uygulanmis haldir.

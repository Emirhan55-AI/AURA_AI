# 🌟 AURA AI Backend

Modern moda asistanı için AI destekli kıyafet analizi ve kombin önerisi servisi.

## 🚀 Özellikler

- **Kıyafet Fotoğrafı Analizi**: Google Gemini Pro Vision ile kıyafetlerin kategori, renk ve desen analizi
- **Akıllı Kombin Önerileri**: Kullanıcının gardırobuna göre kişiselleştirilmiş kombin önerileri
- **Supabase Entegrasyonu**: Kullanıcı gardırop verileri için güvenli veritabanı
- **FastAPI**: Modern, hızlı ve güvenli API framework

## 🛠️ Teknolojiler

- **Backend**: FastAPI, Python 3.13+
- **AI**: Google Gemini 1.5 Flash (Vision & Text)
- **Veritabanı**: Supabase (PostgreSQL)
- **Görsel İşleme**: Pillow (PIL)

## 📋 API Endpoints

### 🔍 Kıyafet Analizi
- **POST** `/process-image/` - Kıyafet fotoğrafını analiz eder
  - Input: Kıyafet fotoğrafı (JPG, PNG, JPEG)
  - Output: Kategori, renk ve desen bilgileri

### 👗 Kombin Önerisi
- **POST** `/get-recommendation/` - Kişiselleştirilmiş kombin önerisi
  - Input: `user_id` ve `soru`
  - Output: AI destekli kombin önerisi

### 🏥 Sistem
- **GET** `/` - Ana sayfa
- **GET** `/health` - Sistem durumu kontrolü
- **GET** `/docs` - Swagger UI dokümantasyonu

## ⚙️ Kurulum

### 1. Gereksinimler
```bash
Python 3.13+
pip
```

### 2. Proje Kurulumu
```bash
# Depoyu klonlayın
git clone https://github.com/Emirhan55-AI/AURA_AI.git
cd AURA_AI

# Sanal ortam oluşturun
python -m venv venv

# Sanal ortamı aktifleştirin (Windows)
venv\Scripts\activate

# Gerekli paketleri yükleyin
pip install -r requirements.txt
```

### 3. Çevre Değişkenleri
`.env` dosyası oluşturun:
```env
# Google Gemini API Anahtarı
GOOGLE_API_KEY=your_google_api_key_here

# Supabase Yapılandırması
SUPABASE_URL=your_supabase_url_here
SUPABASE_KEY=your_supabase_anon_key_here
```

### 4. Supabase Veritabanı Kurulumu
```sql
CREATE TABLE kiyafetler (
  id SERIAL PRIMARY KEY,
  user_id TEXT NOT NULL,
  kategori TEXT,
  renk TEXT,
  desen TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

## 🚀 Çalıştırma

```bash
# Sunucuyu başlatın
uvicorn main:app --reload --host 127.0.0.1 --port 8000
```

API dokümantasyonu: http://127.0.0.1:8000/docs

## 📝 Kullanım Örnekleri

### Kıyafet Analizi
```python
import requests

# Kıyafet fotoğrafı yükle
with open("tshirt.jpg", "rb") as f:
    response = requests.post(
        "http://127.0.0.1:8000/process-image/",
        files={"file": f}
    )

print(response.json())
# {
#   "success": true,
#   "data": {
#     "kategori": "T-Shirt",
#     "renk": "Mavi",
#     "desen": "Düz"
#   },
#   "message": "Kıyafet analizi başarıyla tamamlandı"
# }
```

### Kombin Önerisi
```python
import requests

response = requests.post(
    "http://127.0.0.1:8000/get-recommendation/",
    json={
        "user_id": "user123",
        "soru": "Bugün ofise ne giysem?"
    }
)

print(response.json())
```

## 🔧 Geliştirme

### Proje Yapısı
```
aura_ai_backend/
├── main.py              # Ana FastAPI uygulaması
├── requirements.txt     # Python bağımlılıkları
├── .env                # Çevre değişkenleri (GIT'e yüklenmez)
├── .gitignore          # Git ignore kuralları
└── README.md           # Proje dokümantasyonu
```

### API Modelleri
- `RecommendationRequest`: Kombin önerisi isteği için Pydantic modeli

## 🤝 Katkıda Bulunma

1. Bu depoyu fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'i push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## 🙏 Teşekkürler

- [Google Gemini](https://ai.google.dev/) - AI modelleri için
- [Supabase](https://supabase.com/) - Veritabanı servisi için
- [FastAPI](https://fastapi.tiangolo.com/) - Web framework için

---

💡 **AURA AI** - Moda dünyasını AI ile buluşturan akıllı asistan

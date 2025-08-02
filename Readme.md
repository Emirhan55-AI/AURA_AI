# Aura - Kişisel Stil Asistanı

Aura, kullanıcıların gardıroplarını dijitalleştirerek, kişisel stil DNA'ları oluşturmak ve bu DNA'ya dayalı olarak benzersiz kıyafet ve kombin önerileri sunmak amacıyla geliştirilen bir mobil uygulamadır.

## 🚀 Başlarken

Bu talimatlar, projeyi yerel geliştirme ortamınızda çalıştırmak ve geliştirmeye başlamak için gereken adımları sağlar.

### 📋 Gereksinimler

*   Flutter SDK (Sürüm: ...)
*   Dart (Sürüm: ...)
*   Supabase CLI (Sürüm: ...)
*   Python 3.9+ (FastAPI için)
*   Docker (Opsiyonel, yerel Supabase/DB için)

### 📦 Kurulum

1.  **Depoyu klonlayın:**
    `git clone https://github.com/kullaniciadi/aura-projesi.git`
2.  **Flutter bağımlılıklarını yükleyin:**
    `cd apps/flutter_app && flutter pub get`
3.  **FastAPI bağımlılıklarını yükleyin (venv önerilir):**
    `cd ../fastapi_service && pip install -r requirements.txt`
4.  **Ortam değişkenlerini yapılandırın:**
    `cp .env.example .env` ve `.env` dosyasını düzenleyin.
5.  **(Opsiyonel) Monorepo araçlarını kurun:**
    `dart pub global activate melos && melos bootstrap`

### ▶️ Uygulamayı Çalıştırma

*   **Flutter Uygulaması:**
    `cd apps/flutter_app && flutter run`
*   **FastAPI Servisi:**
    `cd apps/fastapi_service && uvicorn main:app --reload`

## 🏗️ Mimari

Proje, Flutter (Frontend), Supabase (Temel Backend), FastAPI (Özel Servisler) ve Hibrit API yaklaşımı (GraphQL/REST/WebSocket) üzerine kurulmuştur.

Daha fazla bilgi için [Mimari Dokümantasyonuna](./docs/ARCHITECTURE.md) bakın.

## 📚 Dokümantasyon

Projenin kapsamlı dokümantasyonuna `docs/` klasöründe veya [proje dokümantasyon web sitesinde](link_varsa) ulaşabilirsiniz.

*   [Tasarım Rehberi](./docs/STYLE_GUIDE.md)
*   [Teknik Mimari](./docs/ARCHITECTURE.md)
*   [Onboarding Rehberi (Geliştirici)](./docs/ONBOARDING.md)
*   ... (Diğer önemli dokümanlara linkler)

## 🤝 Katkıda Bulunma

Katkıda bulunmadan önce lütfen [CONTRIBUTING.md](./CONTRIBUTING.md) dosyasını okuyun.

## 📄 Lisans

Bu proje ... lisansı altındadır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

## 📧 İletişim

Proje sahipleri: ...


# Supabase Bağlantı Test Rehberi

## Adım 1: Terminal'de Doğru Dizine Gidin
```bash
cd C:\Users\fower\Desktop\Aura\apps\flutter_app
```

## Adım 2: Uygulamayı Çalıştırın
```bash
flutter run -d windows
```

## Adım 3: Test Sayfasına Gidin
Uygulama açıldığında, browser'da URL'yi şu şekilde değiştirin:
```
http://localhost:port/supabase-test
```

## Adım 4: Beklenen Sonuç
Test sayfasında göreceğiniz bilgiler:
- ✅ Supabase connection durumu
- 📡 API bağlantı testi
- 🔐 Authentication durumu  
- ⚙️ Configuration detayları

## Sorun Çözme
Eğer hata alırsanız:
1. `.env` dosyasında keys'lerin doğru olduğunu kontrol edin
2. Internet bağlantınızı kontrol edin
3. Supabase projesinin aktif olduğunu kontrol edin

## Başarılı Bağlantı Sonrası
✅ Connection başarılı olduğunda:
1. Database schema'sını kuracağız
2. RLS policies'leri ekleyeceğiz  
3. İlk test kullanıcısı oluşturacağız
4. Gerçek repository'leri bağlayacağız

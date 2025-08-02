Güvenlik ve Privacy Compliance
1. GDPR/KVKK Uyumluğunu Sağlama
Mimari Öneriler: Uygulama “gizlilik by design” prensibiyle geliştirilmelidir. Yalnızca gerekli kişisel
veriler toplanmalı, fazla veri tutulmamalıdır. Kullanıcı kayıt ve oturum açma akışlarında, veri
işleme amaçları açıkça belirtilmeli ve veri sorumlusu bilgileri sunulmalıdır . Kullanıcıdan
toplanan açık rıza bilgileri (hangi amaçla hangi verilere izin verdiği, izin zamanları) veritabanında
tarih/zaman damgasıyla saklanmalıdır . Kullanıcı, istediğinde rızasını geri çekebilmeli ve bu
işlem kolayca yapılmalıdır . Uygulamada profil/ayarlar sayfasında “Gizlilik” bölümü
oluşturarak, kullanıcıya istediği zaman aydınlatma metni ve gizlilik politikasına erişim imkânı
verilmeli; ayrıca verilen rızalar yönetilebilmelidir . İzin gerektiren her eylem için (örn.
konum, bildirim, pazarlama) ayrı izin kutucukları sunulmalı, önceden işaretli kutucuk
kullanılmamalıdır .
Araçlar ve Kütüphaneler: KVKK/GDPR uyumu için özel kütüphane yoktur; ancak süreç takibi için
Backend tarafında (FastAPI) bir İzin Yönetimi ve Kullanıcı Talepleri (veri silme, ihlal bildirim)
modülü oluşturulabilir. Örneğin, kullanıcının rızalarını saklamak için bir consent tablosu, silme
talepleri için data_requests gibi tablolar eklenebilir. RLS (Row Level Security) politikaları ile
her kullanıcının yalnızca kendi verisini okuyup yazması sağlanmalıdır (supabase’da RLS etkin
olmalıdır). Kullanıcı verisi silme talepleri için FastAPI’de koruyucu bir endpoint oluşturulabilir; bu
endpoint, mevcut kullanıcıyı JWT ile doğrular ve Supabase üzerinden ilgili kaydı “silinir” veya
anonimleştirilmiş olarak işaretler. Silme işleminde kullanıcının tüm ilişkili içeriğinin (paylaşımlar,
yorumlar, beğeniler) da temizlenmesine dikkat edilmelidir. Yasal yükümlülükler gereği veri silme
kalıcı olabilir; eğer geriye dönüş gerekirse veriler bir soft delete (örn. deleted_at timestamp)
veya gerçek silme ile kaldırılabilir.
Örnek Kod Şablonu (FastAPI): Kullanıcı hesabı silindiğinde yürütülecek basit bir örnek endpoint:
from fastapi import FastAPI, Depends, HTTPException
from app.dependencies import get_current_user
from app.database import supabase_client
app = FastAPI()
@app.delete("/users/me", summary="Kullanıcı hesabını sil")
def delete_user_account(current_user=Depends(get_current_user)):
# KVKK md. 7 uyarınca kullanıcı verisi silme (ya da anonimleştirme)
supabase_client.table("users").delete().eq("id",
current_user.id).execute()
return {"detail": "Hesabınız silindi."}
Bu örnekte get_current_user bağımlılığı ile JWT doğrulanır. Gerçek uygulamada silme
işleminden önce parola veya 2FA doğrulaması istenebilir. Silme öncesi ve sonrası için uygun
loglama (Kullanıcı ID, zaman damgası) yapılmalıdır.
•
1
2
3
4 5
5 6
•
•
1
Potansiyel Sorunlar ve Çözümler: Kullanıcıdan gereksiz veri toplamak KVKK ihlalidir (özellikle
“istorimatik” gibi zorunlu olmayan veriler). Bu nedenle gerekli veri minimizasyonu uygulanmalı.
Kullanıcı izni alınamayan işlemler (örn. pazarlama) uygulamanın temel işlevselliğini
engellememelidir . İzin yönetimi karmaşıklaşabilir; bu yüzden her izin ayrı ve anlaşılır
olmalıdır . Loglama yaparken kesinlikle hassas veriler (şifre, token) saklanmamalıdır. Tüm
kritik hatalar ve kullanıcı eylemleri (giriş, rıza verme/çekme, veri silme) için merkezi log sistemi
(Sentry vb.) ile izlenebilirlik sağlanmalı; ancak loglara hiçbir zaman kullanıcı parolası veya tam
kimlik numarası gibi PII yazılmamalıdır. KVKK uyum süreçlerinin test edilebilir olması için kullanıcı
rıza yönetimini manuel ve otomasyonlu testlerle kontrol edin (örn. birim testle “onay ver ve geri
çek” senaryosu).
Performans, Bakım ve Test Önerileri: Rıza ve hukuki işlemler genelde ağırlık yaratmaz. Ancak
gizlilik logları için ek alan kullanımı doğabilir. Veritabanında consents veya
privacy_requests tabloları eklenirken bu tablolar için indekslemeyi unutmayın. Kendi
altyapımızdaki kodlar yerine Supabase’in yerleşik Auth ve Row Level Security özelliklerinden
yararlanmak, bakım maliyetini azaltır. RLS ile her kullanıcı sadece kendi verisini göreceğinden,
test aşamasında farklı kullanıcıların aynı veriye erişimi engellendiğini doğrulayın.
Metinsel Akış Şeması: Örneğin veri silme senaryosu akışı:
Uygulama (Flutter) ➔ Kullanıcı “Hesabı Sil” butonuna basar (UI)
➔ Backend (FastAPI) ➔ JWT ile kimlik doğrulama yapılır;
➔ Domain Katmanı ➔ userDeleteUseCase(id: current_user.id) çağrılır;
➔ API Katmanı ➔ Supabase’e DELETE isteği gönderilir (örneğin
supabase.from("users").delete()... )
➔ Supabase ✓ işlemi gerçekleştirir (RLS etkin)
➔ Domain ➔ “Başarılı” yanıtı alır, sonuç Backend’den UI’a döner;
➔ Uygulama ➔ Kullanıcıya onay mesajı gösterilir.
Use-Case Senaryoları:
Kullanıcı bir ürünü beğendiğinde loglama: UI’de “Beğen” butonuna basıldığında, FastAPI üzerinde
ilgili ürün ID ve kullanıcı ID’si ile bir LIKE kaydı oluşturulur. Bu sırada sunucu loglarında
yalnızca genel bilgi (ör. User X liked post Y ) tutulur, hassas veri içermez.
Çoklu dil seçimi:* KVKK bildirimi veya gizlilik politikası farklı dillerde sunulmalı. Dil değişim
yönetimi Riverpod ile yapılabilir (örn. LocaleProvider ), böylece hukuki metinler dinamik
olarak güncellenir.
Kullanıcı rızayı geri çektiğinde: Kullanıcı “SMS pazarlama iletişimi istemiyorum” opsiyonunu kapatır.
Uygulama backend’e bu değişikliği gönderir; FastAPI’de ilgili kullanıcı marketing_opt_in =
False olarak güncellenir ve aynı zamanda consents tablosunda eski “evet” kaydı işaretlenir
(zaman damgası eklenerek pasif hale getirilir). Böylece artık o kullanıcıya e-posta/SMS
gönderilmez.
Performans ve Kapasite Tahminleri: KVKK işlemleri genelde düşük bant genişliği kullanır.
Örneğin bir GDPR/EU kullanıcısı için veri silme veya ihlal bildirimleri aylık birkaç işlemle sınırlı
kalabilir. Encryption işlemleri (AES-256 vb.) çok hızlı olduğundan (<100MB/s bir CPU çekirdeğiyle)
gerçek zamanlı performansı etkilemez . Veritabanı indeksleri iyi tasarlanırsa, rıza veya
silme talepleri gibi ek sorgular alt saniye içinde tamamlanır. Yine de 10K üzeri aktif kullanıcıda
•
7
6
•
•
•
•
•
•
•
•
•
•
•
•
•
•
8 9
2
aylık “veri talebi” sayısının artabileceği göz önüne alınarak, silme işlemleri asenkron çalışan
background worker (örn. Supabase Functions veya küme dışında bir iş) ile optimize edilebilir.
2. Veri Şifreleme ve Güvenli Depolama
Mimari Öneriler: Tüm istemci–sunucu iletişimi HTTPS üzerinden yapılmalıdır. Hem REST hem de
GraphQL isteklerinde TLS sertifikası kullanılmalı, gerekiyorsa certificate pinning yapılabilir.
Android’da network_security_config.xml , iOS’ta Info.plist içinde ATS ayarları ile sadece
TLS kullanan endpoint’lere izin verin . Flutter tarafında hassas veri (örn. JWT, refresh
token) SharedPreferences gibi açık saklama yerine FlutterSecureStorage ile saklanmalıdır. Bu
paket, iOS’ta Keychain, Android’da Keystore kullanarak veriyi şifreli depolar . Uygulama
içinde lokal cache gerekiyorsa (örn. önbelleklenen feed verisi), Hive gibi şifrelemeyi destekleyen
bir NoSQL çözümü kullanılabilir (Hive’ı kurarken AES-256 anahtarı ile Box oluşturulur ).
Backend tarafında ise Supabase veritabanı zaten varsayılan olarak AES-256 şifreleme ile disk
üzerinde korunur . Ek olarak FastAPI uygulamasındaki gizli anahtarlar (JWT_SECRET, API
anahtarları) kesinlikle kaynak kodda tutulmamalı, ortam değişkenleri veya Secrets Manager ile
yönetilmelidir.
Araçlar ve Kütüphaneler: Flutter’da flutter_secure_storage kullanarak anahtar-değer
(token) çiftleri şifreli saklanabilir . Karmaşık veri türleri için önce JSON’a dönüştürüp
şifrelemek gerekebilir. Hive (veya sembolik basit bir SQLLite) seçeneği, yerel veriyi AES-256 ile
şifreleme imkânı sunar . Python/FastAPI’da kriptografi için cryptography veya passlib
paketleri kullanılabilir; JWT imzalamada PyJWT veya Authlib tercih edilebilir. İstemci–sunucu arası
kimlik doğrulama için JWT önerilir, token’lar Short-Lived (ör. 15dk) tutulmalı ve refresh işlemi API
üzerinden sağlanmalıdır. Ayrıca, mobil uygulamada biyometrik doğrulama (örn. parmak izi ile
oturum) ek bir güvenlik katmanıdır ( local_auth paketi ile entegre edilebilir).
Örnek Kod Şablonları: Flutter’da flutter_secure_storage kullanımı basittir .
Örneğin, oturum açma sonrası alınan JWT’yi şöyle saklayabilirsiniz:
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
final storage = FlutterSecureStorage();
// Token'ı güvenli depoya yaz
await storage.write(key: 'authToken', value: jwtToken);
// Gerekli yerde token'ı oku
String? token = await storage.read(key: 'authToken');
Bu kodda authToken anahtarı altında saklanan değer cihazın güvenli alanında şifrelenerek
tutulur . Silme ve güncelleme metodları da benzer şekilde delete ile yapılır. Backend’de
FastAPI ile HTTPS üzerinde iletişim için ek koda gerek yoktur; requests veya httpx
kullandığınızda varsayılan TLS kontrolü etkin gelecektir.
Potansiyel Sorunlar ve Çözümler: Cihaz kaybolduğunda bile hassas verilerin ele geçmesini
engellemek için uçtan uca şifreleme ve güvenli depolama şarttır . Root/jailbreak cihazlarda
ekstra önlemler düşünün (örn. flutter_secure_storage ek şifreleme opsiyonları). Ortam
değişkenleri içindeki gizli anahtarlar (örn. Supabase servis anahtarı) kod deposunda
bulunmamalıdır. Sunucu üzerindeki loglamada TLS trafiğinin içerikleri yer almaz; ancak özel
servis loglarında PII çıkmamasına dikkat edin. Flutter uygulaması için SSL pinning implemente
•
10 11
12 13
14
9
•
12
14
• 15 16
15 16
•
12
3
edilmezse, sahte Wi-Fi saldırıları riski vardır. Sertifika pinning ( http/io_client.dart ile) ek
güvenlik sağlar .
Performans, Bakım ve Test Önerileri: Şifreleme işlemi modern cihazlarda hızlıdır; bir AES-256
şifreleme işlemi milisaniyeler mertebesindedir. Örneğin, flutter_secure_storage yazma/
okuma tipik olarak 5–20ms aralığındadır, kullanıcı deneyimini etkilemez. Sunucuda ise TLS/HTTPS
donanım hızlandırıcıları ve optimize kütüphaneler (OpenSSL/Tink) kullanılır, gecikme genellikle
100–200ms üzerindedir. Hive şifrelemesi de yerelde hızlıdır; ancak büyük veri setlerinde
erişimlerde küçük bir yavaşlama olabilir, bu yüzden şifrelenmiş Box lar çok büyük
tutulmamalıdır. Performans testlerinde Max CPU kullanımı için e2e testler yapın; genelde AES
CPU maliyeti düşüktür, ancak yüz binlerce şifreleme işleminde sunucu üzerinde ek yük
oluşturabilir. Dolayısıyla sunucuya giren isteklerde maksimum yanıt süreleri <200ms (okuma) ve
<500ms (yazma) hedeflenebilir.
Metinsel Akış Şeması: Örneğin kullanıcı giriş akışı (kimlik bilgilerinin güvenli işlenmesi):
Kullanıcı ➔ Flutter UI’da kullanıcı adı/şifre girer ➔ “Giriş” butonuna basar.
➔ Flutter ➔ TLS (HTTPS) üzerinden FastAPI’ye POST /login isteği gönderir.
➔ FastAPI ➔ İsteği JWT ve şifre doğrulayıcıya yönlendirir.
➔ Domain ➔ Veritabanında (Supabase) kullanıcı bilgisi kontrol edilir; başarılırsa yeni bir JWT
oluşturulur.
➔ FastAPI ➔ JWT’yi JSON ile cevaplar.
➔ Flutter ➔ JWT’yi flutter_secure_storage ile güvenli depoya yazar (örn. key: authToken )
.
Sonraki her istekte Flutter, bu token’ı HTTP header’a ekleyerek (örn. Authorization: Bearer
<token> ) gönderir. Supabase API/GrafQL istekleri de HTTPS üzerinden yürütülür.
Use-Case Senaryoları:
Offline veri senkronizasyonu: Kullanıcı çevrimdışı bir modda not eklediğinde bu not lokal olarak
(örn. Hive Box) şifrelenip saklanır. İnternet bağlanınca otomatik olarak Supabase’e gönderilir.
Yerel veri şifreli olduğundan cihaz ele geçse bile okunamaz.
Token yenileme: Uygulamada uzun süreli kullanım için JWT’nin süresi dolduğunda refresh token ile
yenilenir. Refresh token da FlutterSecureStorage ’a şifreli kaydedilir ve ihtiyaç halinde aynı
şekilde güvenli okunur.
Performans ve Kapasite Tahminleri: HTTPS şifreleme/sunucu arasında ek CPU yükü azdır;
modern sunucular TLS hızlandırma yapabilir. Mobilde flutter_secure_storage kullanımı
hafiftir; bekleme süreleri milisaniyeyi geçmez. 100K kullanıcı ölçeğinde bile TLS bağlantı maliyeti
bariz büyümez; aylık 1M API çağrısı senaryosunda her çağrının TLS handshake’i ~50–100ms
alırken, persistent bağlantı (keep-alive) kullanılarak bu düşürülür. Supabase’in AES-256
şifrelemesi müşteriye şeffaftır; ek yönetim gerekmez. Supabase ile veritabanı okuma/yazma
gecikmeleri, şifreleme overhead’inden çok ağ/geographical latency ile belirlenir.
3. Üçüncü Taraf Kütüphane Güvenlik Kontrolleri
Mimari Öneriler: Tüm bağımlılıklar merkezi bir bileşende toplanmalı. Monorepo kullanıyorsanız
Flutter ve FastAPI kodları tek repoda dursa bile bağımlılık yönetimi ayrı yapılabilir; önemli olan
17
•
•
•
•
•
•
•
•
15 12
•
•
•
•
•
•
4
her kod tabanında düzenli tarama yapmaktır. CI/CD pipeline’ına statik analiz ve SCA (Software
Composition Analysis) adımları ekleyin. Örneğin, Flutter tarafı için OSV Scanner veya OWASP
Dependency-Check kullanabilir; Python için pip-audit veya GitHub Dependabot/Snyk entegre
edebilirsiniz. Pipeline örneği:
- name: Scan Flutter dependencies
run: osv-scanner -r .
- name: Scan Python dependencies
run: |
pip install pip-audit
pip-audit --progress
OWASP Mobile Güvenlik Test Rehberi de üçüncü parti kontrolü için “OWASP Dependency
Checker” kullanımını önerir . Her kod değişikliğinde veya haftalık tarama ile yeni CVE’ler
yakalanmalı. Ayrıca bağımlılıklar için lisans uyumluluğu (örn. MIT, Apache) denetimi yapılmalıdır.
Araçlar ve Kütüphaneler:
Flutter (Dart) için: OSV Scanner kullanılarak pubspec.lock taranabilir . Ayrıca [ dart
pub outdated --mode=null-safety ] ile güncel versiyonlar kontrol edilir. Geliştiriciler
Pub.dev’deki paketlerin güvenilirliğini gözden geçirmeli.
FastAPI (Python) için: pip-audit veya Safety ile requirements.txt taranabilir. GitHub
Depedabot veya Snyk entegrasyonu da tavsiye edilir.
Diğer: Docker imajları kullanıyorsanız Trivy ile imaj güvenlik taraması yapılabilir. Kod tarama için
bandit (Python), flutter analyze ve dart fix --apply (Dart) gibi araçlar devreye
sokulabilir.
Geliştirme Süreci: Library seçiminde “SPOF (Single Point of Failure)” olmamasına, aktif destek
alınıyor olmasına dikkat edin. Her bağımlılığın changelog’unu takip edin.
Örnek Kod Şablonları (CI/CD): GitHub Actions örneği:
jobs:
security_scan:
runs-on: ubuntu-latest
steps:
- uses: actions/checkout@v3
- name: Scan Dart/Flutter packages
run: |
curl -sSfL https://raw.githubusercontent.com/google/osvscanner/main/install.sh | sh
./osv-scanner -r .
- name: Audit Python dependencies
run: |
pip install pip-audit
pip-audit --fail-on 0.0
Burada OSV ve pip-audit CI akışına dahil edilmiş, hata bulunursa pipeline kırılacak şekilde
ayarlanmıştır .
18
•
• 19 20
•
•
•
•
20
5
Potansiyel Sorunlar ve Çözümler: Paket güncellemeleri bazen geriye dönük uyumsuzluk
(breaking change) getirebilir; bu yüzden güvenlik güncellemelerini entegre etmeden önce test
ortamında doğrulayın. Kütüphanelerin eski versiyonlarındaki zayıflıkları mutlaka yamayın; güncel
değilse alternatif paket arayın veya gerekiyorsa o işlevi kendiniz geliştirin. Lisans uyuşmazlığı
(örn. GPL vs iş projesi) riskine karşı, bağımlılıkların lisanslarını otomatik kontrol eden licensechecker gibi araçları da devreye alın.
Performans, Bakım ve Test Önerileri: Bağımlılık taraması pipeline’da birkaç saniye ile birkaç
dakika sürer, kritik bir zaman kaybı değildir. Örneğin yüzlerce paket taraması Trivy/pip-audit ile
~10–30 saniyede tamamlanabilir. Tarama aralıklarını projenin risk profiline göre (örneğin her PR
veya günlük) ayarlayın. Elde edilen sonuçlar bir “Security Issues” raporu olarak saklanmalı, açıklar
kapatılana kadar takip edilmelidir. Geniş bir bağımlılık ağınız varsa tarama süresi artar; CPU sınırı
(örn. CI ortamı) ve ağ gecikmesi göz önünde bulundurulmalıdır.
Metinsel Akış Şeması: Örneğin CI/CD pipeline’ında üçüncü parti kontrolü akışı:
Kod değişikliği (push/PR) yapılır.
CI/CD ➔ Kod çekilir, bağımlılıklar yüklenir.
Scan Aşaması: OSV Scanner, pip-audit gibi araçlar bağımlılıkları tarar .
Sonuç: Eğer kritik CVE varsa pipeline hata verir (build kırılır), geliştirici uyarılır; yoksa build devam
eder.
Use-Case Senaryoları:
Yeni kütüphane entegrasyonu: UX tasarımı için yeni bir grafik paketi eklenmeden önce o paketin
CVE taraması yapılır. Eğer geçmişte güvenlik açığı bildirimi almışsa alternatif paket veya güncel
sürüm seçilir.
Acil güvenlik açığı: Örneğin uygulamada kullanılan http kütüphanesi kritik bir güvenlik açığı
alırsa, Dependabot/Snyk otomatik PR oluşturur veya pipeline hata verir. Geliştirici paketi hemen
günceller veya geçici önlem alır.
Lisans uyumluluğu: Uygulama içine dahil edilen üçüncü parti SDK’ların lisans koşulları (örn. MIT,
Apache) lisans taramasıyla denetlenir. Çatışmalı bir lisans varsa proje liderine bildirilir.
Performans ve Kapasite Tahminleri: Tipik bir mobil projenin bağımlılık sayısı (Flutter, Python)
yüzleri geçebilir. Modern tarama araçları (OSV, pip-audit) her yüz paket için <1dk’da rapor
verebilir. CI kaynaklarını artırarak paralel tarama yapılabilir. Büyük kullanıcı sayısının üçüncü parti
kütüphane güvenliğine etkisi yoktur; önemli olan geliştirici ekip bu süreci otomatikleştirip sürekli
takip etsin. Örneğin OSV tarayıcısı günlük taramada yeni CVE’leri JSON formatında bildirir .
Depolama ve bellek açısından, tarama işlemleri genelde sunucuda gerçekleştiğinden mobil cihaz
yükü söz konusu değildir. Ancak tarama araçlarının veritabanları veya CVE listeleri güncel
tutulmalıdır (ör. GitHub Advisories günlük güncellemeleri çekmelidir).
Kaynaklar: KVKK/GDPR gereklilikleri ve izin yönetimi için [3],[5],[33]; mobil şifreleme pratikleri için [8],
[27],[29],[10]; üçüncü taraf güvenliği ve SCA için [17],[38],[40] kaynakları kullanılmıştır.
Mobil Uygulamalarda KVKK Uyumluluğu ve Hukuki Metinler
https://tr.linkedin.com/pulse/mobil-uygulamalarda-kvkk-uyumlulugu-ve-gizlilik-abdullah-erkam-y%C4%B1lmaz-rgrff
•
•
•
•
•
• 20
•
•
•
•
•
•
20
1 2 3 4 5 6 7
6
10 Steps to Ensure Your Mobile App Meets Gdpr Compliance Standards
https://www.mobiloud.com/blog/gdpr-compliant-mobile-app
Security at Supabase
https://supabase.com/security
OWASP Top 10 For Flutter — M5: Insecure Communication for Flutter and Dart | by Talsec |
Medium
https://medium.com/@talsec/owasp-top-10-for-flutter-m5-insecure-communication-for-flutter-and-dart-63fa4f38e0cd
Storing Data in Secure Storage in Flutter | Blog | Digital.ai
https://digital.ai/catalyst-blog/flutter-secure-storage/
Hive: The Lightning-Fast Local Storage Solution for Flutter Apps - DEV Community
https://dev.to/kalana250/hive-the-lightning-fast-local-storage-solution-for-flutter-apps-56jc
MASTG-TEST-0042: Checking for Weaknesses in Third Party Libraries - OWASP Mobile Application
Security
https://mas.owasp.org/MASTG/tests/android/MASVS-CODE/MASTG-TEST-0042/
Scan your Dart and Flutter dependencies for vulnerabilities with osv-scanner | by Yong Shean |
Medium
https://medium.com/@yshean/scan-your-dart-and-flutter-dependencies-for-vulnerabilities-with-osv-scanner-7f58b08c46f1
8
9
10 11 17
12 13 15 16
14
18
19 20
7
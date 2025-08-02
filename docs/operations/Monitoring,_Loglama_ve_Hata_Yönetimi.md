Monitoring, Loglama ve Hata Yönetimi
Mobil ve sunucu tarafında kapsamlı loglama ve monitoring, uygulama kararlılığını ve hataların hızlı
çözümünü sağlar. Hem Flutter uygulamasında (istemci) hem de FastAPI servisinde (sunucu) merkezi bir
izleme stratejisi belirlenmelidir. Bu sayede bir sorun çıktığında hızlıca nasıl ve nerede oluştuğu anlaşılır.
Örneğin Sentry ve Firebase Crashlytics gibi araçlar, çökme ve istisna raporlaması için kullanılırken; genel
hataları, performans metriklerini ve özel olayları (ör. “feed yükleme başarısız oldu”) da bu altyapılarda
veya ayrı analitik/monitoring sistemlerinde takip edebiliriz.
Aşağıda her alt başlık için mimari öneriler, kullanılacak araçlar, örnek kod şablonları, potansiyel
sorunlar ve çözümler, performans ve bakım kolaylığı açısından ipuçları, metinsel akış şeması, usecase senaryoları ve performans/kapasite tahminleri yer almaktadır. Verdiğimiz örnek akışlarda her
katmandaki loglama ve hata yönetimi dahil edilmiştir.
1. Flutter ve FastAPI için Ayrı ve Entegre Loglama
Mimari Öneriler: Flutter (istemci) ve FastAPI (sunucu) loglarını yapılandırırken ayrık katmanlar kurmaya
özen gösterin. Flutter tarafında UI, Application (Riverpod) ve Domain seviyelerinde loglama yapılabilir.
Her katmanda, önemli adım/işlem sonrası log atılarak uygulama akışı izlenmeli. FastAPI’de ise genellikle
API Katmanı, Servis Katmanı ve Veri Katmanı (Supabase sorguları) için loglama yapılır. Loglar
yapılandırılmış (JSON) formatta tutulmalı; böylece sorgulanabilir ve analiz edilebilir. Bütün bu loglara,
global bir correlation ID (ör. X-Event-ID ) ekleyerek Flutter ve backend loglarını birbirine bağlamak
mümkündür.
Flutter’da Loglama: logger gibi paketler kullanarak (Logger paketi tavsiye edilir )
uygulama içi olayları (network isteği, UI aksiyonu vs.) loglayın. Hata yakalama bloklarında
print yerine bu logger’ı veya Crashlytics/Sentry’i çağırarak log gönderin. Log seviyelerini (info,
warning, error) tutarlı kullanın . Geliştirme modunda daha ayrıntılı debug logları,
üretimde ise sadece warning ve error seviyesinde tutun .
FastAPI’de Loglama: Python’un yerleşik logging kütüphanesini veya structlog gibi
yapılandırılmış log kütüphanelerini kullanın. Örneğin şöyle bir temel konfigürasyon olabilir:
import logging
logging.basicConfig(
format='%(asctime)s %(levelname)s [%(correlation_id)s] %(name)s:%
(lineno)d - %(message)s',
level=logging.INFO
)
Uvicorn access logger’ı da özelleştirilip, her isteğe correlation_id filtre aracılığıyla otomatik
ekleme yapılabilir (bkz. ). Her endpoint veya servis katmanında önemli adımlar loglanmalı (ör.
“kullanıcı verisi çekildi”, “NoContent döndü”, vb.).
Entegre İzleme: Flutter’dan backend’e giden her istek, hem istemci hem de sunucu loglarında iz
bırakmalı. Örneğin Flutter’da bir API hatası yakalanınca (örn. feed yüklemesi başarısız), hem
• 1
2 3
4
•
5
•
1
print / logger.error ile konsola yazılabilir hem de Crashlytics’e veya Sentry’e “breadcrumb”
veya event olarak gönderilebilir. FastAPI de aynı hata bağlamında logger.error atarak
Sentry’e otomatik olarak gönderebilir. Böylece uçtan uca bir izleme zinciri kurulur.
Örnek Kod (Flutter): logger paketiyle basit bir kullanım:
import 'package:logger/logger.dart';
final logger = Logger();
...
void fetchFeed() async {
try {
final data = await apiClient.getFeed();
// Başarılı akışı logla (verbose bilgi)
logger.i("Feed başarıyla yüklendi: ${data.length} öğe");
} catch (error, stack) {
// Hataları logla
logger.e("Feed yükleme hatası", error, stack);
// Hatanın ayrıntısını monitoring servisine ilet
Sentry.captureException(error, stackTrace: stack);
FirebaseCrashlytics.instance.recordError(error, stack);
}
}
Örnek Kod (FastAPI): Basit bir FastAPI endpoint’i ve loglama:
from fastapi import FastAPI, Request
import logging, uuid
app = FastAPI()
logger = logging.getLogger("backend")
logger.setLevel(logging.INFO)
@app.middleware("http")
async def add_correlation_id(request: Request, call_next):
# Header'da gelen ID'yi al veya yenisini oluştur
cid = request.headers.get("X-Event-ID") or str(uuid.uuid4())
# Correlation ID'yi log kayıtlarına ekleyen filter'i aktif et
request.state.correlation_id = cid
response = await call_next(request)
return response
@app.get("/feed")
async def get_feed(request: Request):
cid = request.state.correlation_id
logger.info(f"Feed çekiliyor, correlation_id={cid}")
try:
# Supabase sorgusu vb.
•
•
2
items = await supabase.fetch_feed(request.user_id)
return items
except Exception as e:
logger.error(f"Feed sorgusunda hata (ID={cid}): {e}",
exc_info=True)
# Sentry otomatik: internal error yakalanıp raporlanır .
raise
Burada middleware ile her isteğe tekil bir correlation_id atanıyor. Logger formatında %
(correlation_id)s kullanılarak tüm loglara aynı ID eklenebilecek şekilde yapılandırılmalıdır.
Bu sayede Flutter tarafındaki X-Event-ID ile backend logları eşleştirilebilir.
Potansiyel Sorunlar ve Çözümler: Çok detaylı loglama (örneğin debug seviyesinde yoğun ağtrafik loglamak) performans maliyetine sebep olabilir. Bu nedenle üretimde sadece warning/
error seviyesine odaklanın ve gereksiz detayları kapatın . Gizlilikten dolayı loglanacak
verilerde kullanıcı hassas bilgilerini ayıklayın. Log formatı kararlı tutularak (örneğin her log JSON)
arama yapılabilmesi sağlanmalıdır. Flutter’da cihaz loglarını saklama (ör. lokal dosyaya yazma)
yerine uzak servis kullanmak (Crashlytics) genellikle daha pratiktir. Sunucu loglarında çok fazla
trafik olduğunda logların rotasyonunu ve toplanmasını otomatikleştirin.
Performans/Bakım/Test: Loglama kodları ayrı katmanlara (ör. servislere) mümkün olduğunca
sıkıştırılmalı; tekrar eden log yapılarını yardımcı fonksiyonlarla soyutlayın. Birimler arası
testlerde, gerçek log servisine gitmeden logger’ı mock’lamak veya kapatmak faydalıdır. Ayrıca log
filter’ları ile test ortamında ek log seviyelerini açıp kapatabilirsiniz. İdeal olarak loglama asenkron
çalışır (örn. Crashlytics logları yığın halinde işler) ve uygulama yanıt süresini engellemez.
Metinsel Akış Örneği (Hata Durumu):
[Flutter UI] Kullanıcı feed yükleme isteği (X-Event-ID=abc123
gönderildi)
 ↓
[Flutter Application] Kapsayıcı hata yönetimi altındaki API çağrısı
başladı.
 ↓
[Flutter -> FastAPI] HTTP GET /feed (Headers: X-Event-ID=abc123,
Authorization token)
 ↓
[FastAPI] Middleware correlation_id=abc123 atandı. Endpoint'e ulaşıldı.
 ↓
[FastAPI Servis] Supabase sorgusu sırasında hata oluştu.
 ↓
[FastAPI] Bu hata logger.error ile loglandı (İçerik: "Feed sorgusunda
hata, ID=abc123") ve Sentry'ye raporlandı .
 ↓
[FastAPI] Hata cevabı (500 Internal Error) Flutter'a geri döndü.
 ↓
[Flutter UI] Hata alındı, kullanıcıya mesaj gösterildi. Aynı zamanda
Sentry.captureException ve Crashlytics.recordError ile hata uzaktan
raporlandı.
6
•
4
•
•
6
3
Bu akışta hem Flutter hem FastAPI katmanlarında loglar aynı abc123 Event-ID ile işlenmiş,
izlenebilir.
Use-Case Senaryoları:
Feed yükleme başarısız: API çağrısı sırasında hata yakalanıp loglanır, kullanıcıya hata mesajı
gösterilir ve bu olay Logger.e / Crashlytics.recordError ile raporlanır.
Yorum gönderme isteği: Başarısızsa, aynı şekilde loglanır ve gerekirse performans hedeflerinin
aşımı ölçülür.
Gerçek zamanlı mesaj gönderme: WebSocket üzerinden bağlantı kopması durumunda backend log
kaydeder, Flutter’da retry mekanizması tetiklenir.
Kullanıcı oturumu açma: Başarılı/başarısız giriş denemeleri güvenlik izleme için loglanabilir (örn.
logger.i("Kullanıcı giriş yapıldı: userId=...") ).
Performans/Kapasite Öngörüleri: Günlük 10K aktif kullanıcı için dakikada yüzlerce API isteği
olabilir. Her bir istek için log atılması üzerindeki ek yük ölçülmeli. FastAPI Uvicorn ile binlerce
isteği/ saniye karşılayabilir ; loglama bu yükü çok etkilemez ama Sentry/Crashlytics gibi
servislere gönderilen olayların hızı sınırlandırılabilir (ör. Sentry’de sample rate %10–100 arasında
ayarlanabilir ). Örneğin backend için P50 cevap süresi <200ms, P99 <1s hedeflenebilir.
Flutter’da olay loglaması genellikle arka planda asenkron olduğu için kullanıcı arayüzünü
yavaşlatmaz; ancak çok sayıda hata olması durumunda batarya tüketimine dikkat edin.
2. Sentry ve Firebase Crashlytics Yapılandırması
Mimari Öneriler: Hata monitörleme için Sentry (hem Flutter hem FastAPI) ve Firebase Crashlytics (Flutter)
birlikte kullanılabilir. Crashlytics esasen uygulama çökme ve hatalarını toplarken, Sentry daha geniş
bir hata/pencemleme, performans ve event takibi sunar. Flutter uygulamasında, main() fonksiyonunu
Crashlytics ve Sentry ile sarmak (wrapping) iyi bir başlangıçtır. FastAPI’de ise sentry_sdk.init()
çağırılıp ilgili entegrasyonlar eklenmelidir. Her iki tarafta da DSN ve proje konfigürasyonuna dikkat edin;
DSN gizli bir anahtar olduğu için güvenli saklanmalı (örn. CI ortam değişkeni olarak).
Gerekli Araçlar/Kütüphaneler:
Flutter: sentry_flutter ve firebase_crashlytics paketleri (pubspec) .
FastAPI: sentry-sdk[fastapi] PyPI paketi (aydınlatma için opsiyonel: uvicorn vs).
Ayrıca performans izleme için Sentry tracing entegre edilebilir (ör. traces_sample_rate
ayarı).
Kod Örnekleri (Flutter Sentry): Flutter’ın main.dart ’ında Sentry’yi başlatın:
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
Future<void> main() async {
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp();
// Crashlytics - Flutter hata yakalama
FlutterError.onError =
•
•
•
•
•
•
7
8 9
•
• 10 11
•
•
•
4
FirebaseCrashlytics.instance.recordFlutterError;
// Sentry initialize
await SentryFlutter.init(
(options) {
options.dsn = 'https://examplePublicKey@o0.ingest.sentry.io/0';
options.sendDefaultPii = true;
options.environment = 'production';
options.tracesSampleRate = 0.2; // Örnek: %20 traza katıl
},
appRunner: () => runZonedGuarded(() {
runApp(MyApp());
}, (error, stack) {
// Flight zamanı (zone) hatalarını Crashlytics/Sentry ile raporla
FirebaseCrashlytics.instance.recordError(error, stack, fatal:
true);
Sentry.captureException(error, stackTrace: stack);
}),
);
}
Bu örnekte FlutterError.onError ile Flutter çerçevesi hataları Crashlytics’e yönlendiriliyor
. runZonedGuarded içinde yakalanan hatalar hem Crashlytics’a hem Sentry’ye iletiliyor .
Sentry init kodunda DSN, ortam ve örnekleme oranları belirtiliyor .
Kod Örnekleri (FastAPI Sentry): FastAPI uygulamasında Sentry’yi başlatın:
import sentry_sdk
from sentry_sdk.integrations.fastapi import FastApiIntegration
from sentry_sdk.integrations.logging import LoggingIntegration
from fastapi import FastAPI
# Sentry logging entegrasyonu: INFO üzerinde breadcrumb, ERROR event.
sentry_logging = LoggingIntegration(
level=logging.INFO, # bilgi seviye ve üzerini breadcrumb
event_level=logging.ERROR # hata seviye logları event olarak bildir
)
# Sentry başlatma
sentry_sdk.init(
dsn="https://examplePublicKey@o0.ingest.sentry.io/0",
integrations=[FastApiIntegration(), sentry_logging],
traces_sample_rate=0.1, # performans izleme oranı
send_default_pii=True
)
app = FastAPI()
@app.get("/crash")
def trigger():
1/0 # intentional crash to test Sentry
11 12
10 13
•
5
Yukarıda FastApiIntegration otomatik istisna izlemeyi sağlar . LoggingIntegration
ile Python logging.error çağrıları Sentry’de etkinlik olarak toplanır . Unhandled exception
“/crash” çağrıldığında otomatik olarak Sentry’ye gönderilir.
Potansiyel Sorunlar ve Çözümleri:
DSN yönetimi: DSN’yi kod içine sabitlemeyin; CI/CD veya gizli konfigürasyonla yükleyin. Eğer
SDK’yı yanlış yapılandırırsanız (örn. eksik entegrasyon), hatalar gözükmeyebilir.
Volüm ve Maliyet: Sentry/Crashlytics çok fazla event alırsa maliyet artar ve veritabanı hızla dolar.
Bu yüzden özellikle performans örneklemesi ( traces_sample_rate ) ayarlayın ve gereksiz log
seviyelerini azaltın .
Bağlantı Sorunları: Bazen cihaz internet yokken Crashlytics raporlamayı erteler; bu normaldir.
Arka planda Crashlytics verileri yollamayı deneyerek uygulama performansını engellemez.
Platform Farklılıkları: Crashlytics doğal olarak mobil odaklıdır; iOS/Android’ya özgü hataları
yakalar. FastAPI (sunucu) için Crashlytics yoktur, onun yerine Sentry veya Prometheus/Grafana
gibi araçlara yönelirsiniz.
Performans/Bakım/Test: Crashlytics ve Sentry SDK’ları genellikle asenkron çalışır; hatalar
uygulama akışını durdurmaz. Örneğin SentryFlutter.init’de tracesSampleRate ’ı düşük tutmak
gereksiz yavaşlamaları önler. Unit/integration testlerde Sentry/Crashlytics bazlı kodları izole
etmek için ortam değişkeni veya mock kullanabilirsiniz. İzleme çözümlerinde CI aşamasında
dummy hatalar göndererek setup’ın doğruluğunu test edin (örn. Sentry için yukarıdaki /crash
endpoint).
Metinsel Akış Örneği (Hata Kayıt):
[Flutter UI] Uygulama açılır; main içinde Sentry ve Crashlytics
başlatıldı.
 ↓
[Flutter] Büyük bir hata oluştu (ör. null de-referans).
[FlutterError.onError] otomatik çalıştı ve hatayı FirebaseCrashlytics'e
iletti .
 ↓
[SentryFlutter] Aynı hata Sentry.captureException ile Sentry'ye
gönderildi .
 ↓
[Firebase Crashlytics Dashboard] Kırık yığın ve custom log mesajları
toplanır.
[Sentry Dashboard] Hata detayı ve stack trace görünür, performance
skorları varsa bağlantılı.
Use-Case Senaryoları:
Unhandled Flutter Hatası: Örneğin beklenmeyen bir widget hatası. FlutterError.onError
otomatik Crashlytics raporu ve Sentry olayına dönüşür. Geliştirici konsolunda ilgili Crashlytics
olayı incelenir.
6
14
•
•
•
8 9
•
•
•
•
11
15
•
•
6
FastAPI İçinde Exception: Kullanıcı geçersiz bir parametre gönderdiğinde HTTPException(400)
atılabilir. Sentry otomatik olarak 5xx hataları yakalar , ancak 400’ü raporlamak için
failed_request_status_codes ek ayarı yapılabilir.
Middleware ile Test: Kasti bir /debug endpoint’i oluşturup içinde 1/0 yaparak, testi çalıştırıp
Sentry üzerinden logların düştüğünden emin olun. Böylece prod ortamına geçiş öncesi hata kayıt
zincirini doğrulamış olursunuz.
Performans/Kapasite Öngörüleri: Sentry gibi bulut çözümlerinin planı event/saat sınırı
koyabilir. Örneğin günlük 10K kullanıcı ve %1 hata oranı, ayda 3M event demektir ki plan
limitlerini aşabilir. Bu durumda olay örnekleme (sampling) uygular veya hataları kategorize
ederek kritik olanları kaydederiz. Sentry için hedef P50 error raporlama latenysi <200ms olabilir.
Crashlytics arka planda batch ile çalıştığından kullanıcı boyutuna göre GB’larca veri gönderebilir;
aşırı log durumunda uygulama boyutuna dikkat edilmeli.
3. Takip Edilmesi Gereken Event’ler
Mimari Öneriler: Hangi olayların izleneceği uygulama gereksinimine göre belirlenir. İzleme
katmanında hataların, uyarıların ve önemli iş akışı olaylarının kaydı yapılmalıdır. Örneğin: feed yükleme
başarısız oldu, öneri alınamadı, kullanıcı oturumu süresi doldu, mesaj iletimi tamamlandı, bildirim alınamadı
gibi kritik işlevler takip edilir. Hata takip araçları (Sentry, Crashlytics) genelde otomatik olarak çökme ve
yakalanmamış istisnaları toplar; bunlara ek olarak uygulama içinde yakaladığınız özel hataları da
manuel olarak raporlayabilirsiniz. Ayrıca performans durumlarını (yavaş API, render süresi, vb.) metric
olarak kaydeden (Sentry Performans, Prometheus vs.) yapılar kurulabilir.
Gerekli Araçlar/Kütüphaneler:
Sentry: Otomatik hata yakalama yanı sıra elle olay (message/event) gönderme imkânı. Örneğin
Sentry.captureMessage("Feed yüklenemedi: 404") .
Crashlytics: Hata öncesi logları (“breadcrumb”) saklar.
FirebaseCrashlytics.instance.log("Feed yüklenemedi") gibi.
Firebase Analytics (opsiyonel): İş birimi metrik ve özel event’ler için (örn. kullanıcı etkileşim
istatistikleri).
Prometheus/Grafana: API yanıt süreleri, bellek kullanımı gibi sunucu metrikleri için.
Kod Örnekleri:
try {
final feed = await api.fetchFeed();
} catch (error, stack) {
// Hata tipi ve detay
Sentry.captureException(error, stackTrace: stack);
FirebaseCrashlytics.instance.log("Feed yükleme hatası: $
{error.toString()}");
}
// Öneri API'si başarısız olursa:
if (!response.success) {
FirebaseCrashlytics.instance.log("Öneri servisi başarısız: code $
{response.code}");
}
•
6
•
•
•
•
•
•
•
•
7
Veya Flutter içinde, hata durumunda doğrudan assert veya throw ederek Crashlytics’i
devreye sokabilirsiniz. FastAPI’de ise:
@app.post("/suggest")
async def suggest(request: Request):
try:
result = await ai_service.get_suggestion(request.user_id)
return result
except ApiError as e:
logger.warning(f"Öneri alınamadı: {e.code}", extra={"user":
request.user_id})
raise HTTPException(status_code=502, detail="Öneri servisi hata
verdi")
Potansiyel Sorunlar: Hangi olayın değerli olduğu bazen belirsizdir. Çok fazla “önemsiz” olayı
loglamak alert gürültüsüne neden olur. Bu nedenle kritik olayları önceliklendirin. Örneğin sadece
kullanıcıya etkileşim raporu gerektiren durumları (500 Internal Error, kullanıcı işlem hataları)
gönderin; sıradan bilgi loglarını düşük seviyede tutun. Yanlış önceliklendirme olursa önemli bir
hata gözden kaçabilir. Otomatik bildirim (alert) sistemlerinde sadece belirli “ihlal” durumlarında
(örn. auth token hatası, 503 response) uyarı verin, her 404’te e-posta atmayın.
Performans/Bakım/Test: Olay takibini test etmek için uygulamayı beklenen hata durumlarına
zorlayın (örneğin geçersiz JWT ile auth isteği gönderip 401 alın, hatayı Crashlytics ve Sentry’de
görün). Yük altında özel event göndermek log kayıt sisteminizi yavaşlatmaz; çünkü bu servisler
asenkrondır. Ancak yine de kritik iş akışı olayları (login, payment, post) için zaman damgalı
event’ler atarak performans metreleri hesaplayabilirsiniz.
Metinsel Akış Örneği (Feed Hatası):
[Flutter] Kullanıcı sayfayı çekmek için istek gönderiyor.
[Flutter→FastAPI] GET /feed isteği.
[FastAPI] API, Supabase’den sonuç alamadı (ör. DB hatası).
[FastAPI] `logger.error("Feed alınamadı: DB bağlantı hatası")`.
[Sentry] Bu hata otomatik raporlandı (ID, user-agent vb. ekli).
[FastAPI] 500 hatası döndü.
[Flutter] Hata alındı, kullanıcıya “Tekrar deneyin” mesajı gösterildi.
 `Crashlytics.log("Feed: 500 hatası")` ve
`Sentry.captureMessage` çağrıldı.
Use-Case Senaryoları:
Feed gelmedi: Backend’de SQL hatası veya boş data. Kaynak API hatası bile olsa, hem hata
durumunu (ör. Sentry) hem de kullanıcı aksiyonunu (ör. UI’da retry butonuna basma) loglamak
faydalıdır.
Öneri başarısız: Bir makine öğrenimi servisi zaman aşımına uğruyorsa, bu durum warning veya
error olarak loglanmalı. Bu hatayı Sentry dashboard’da “işleme limiti aşıldı” gibi
gruplayabilirsiniz.
Auth token süresi doldu: Aşağıda detaylı senaryoda işlenecek.
Performans/Kapasite Tahminleri: Takip edilen event sayısını en başta tahmin edin. Örneğin her
kullanıcı etkileşiminin bir log kaydı olduğu bir uygulamada, 10K kullanıcı/gün * 20 etkileşim =
200K event/gün olur. Sentry ve Crashlytics limitlerini bu ölçüde düşünün. Genelde event_size
< 1KB , saniyede binlerce log hızı beklenebilir, ancak alert eylemleri (e-posta, SMS) sınırlıdır
•
•
•
•
•
•
•
•
8
(SPAM olmaması için). Örnek: API response time P50 <200ms, P95 <500ms hedeflenir .
Geciken veya 5xx hatalar basit metrik olarak izlenmeli (ör. %95≥200ms, hata oranı <%1).
4. Logları Aynı Event ID ile İlişkilendirme
Mimari Öneriler: Uçtan uca izlenebilirlik için her iş akışı öğesine tekil bir Event/Correlation ID atayın.
Flutter’da önemli bir işlem başladığında (örn. “feed yükle”), UUID üreterek bunu HTTP header’a (örn.
X-Event-ID ) ekleyin. FastAPI’de bu ID’yi karşılayıp tüm loglara aktarın. Böylece hem Flutter hem
FastAPI katmanında aynı ID’li log kayıtları oluşur. Sentry’de ek bilgi (tag) olarak bu ID’yi kaydedin;
Crashlytics’te ise gerekirse setUserIdentifier veya log mesajına ekleyebilirsiniz.
Gerekli Araçlar/Kütüphaneler:
Flutter: uuid paketi (event ID üretmek için), HTTP/GraphQL istemcisi (başlık eklemek için).
FastAPI: asgi-correlation-id gibi middleware (otomatik ID yönetimi için) veya kendi
middleware’iniz.
Kod Örnekleri:
import 'package:uuid/uuid.dart';
final uuid = Uuid();
void fetchFeed() async {
String eventId = uuid.v4();
final response = await http.get(
Uri.parse('https://api.example.com/feed'),
headers: {
'X-Event-ID': eventId,
'Authorization': 'Bearer $token',
},
);
// Sentry breadcrumb olarak da ekleyebilirsiniz
Sentry.configureScope((scope) {
scope.setTag("event_id", eventId);
});
}
FastAPI’de middleware örneği (önceki bölümde gösterildi). asgi-correlation-id kullanmak
isterseniz:
from asgi_correlation_id import CorrelationIdMiddleware
app.add_middleware(CorrelationIdMiddleware)
ve logging filter konfigürasyonu:
from asgi_correlation_id import correlation_id_filter
console_handler = logging.StreamHandler()
console_handler.addFilter(correlation_id_filter(uuid_length=8)())
16 17
•
•
•
•
9
logging.basicConfig(handlers=[console_handler],
format='%(levelname)s [%(correlation_id)s] %
(message)s')
Bu yapı her log satırına [correlation_id] ekler .
Potansiyel Sorunlar: Tüm isteklerde bu header’ın taşınmasını sağlamak önemlidir; GraphQL
veya WebSocket gibi iletişimlerde manuel adım gerekebilir. Event ID üretiminde çakışma
olmaması için iyi bir UUID kütüphanesi tercih edin. Ayrıca kopya header’lar veya eksik header’lar
(örneğin Sentry gibi mobil SDK’ları kendi ID üretebilir) senkronizasyon sorununa yol açabilir.
Supabase sorgularında ise bu ID otomatik taşınmaz; özel API endpoint’lerinden loglamalısınız.
Performans/Bakım/Test: Event ID eklemenin yükü çok düşüktür. Ancak çok sık ID oluşturmak
gereksizse, bir iş akışı boyunca sabit ID kullanabilirsiniz (ör. tüm sayfa yükleme işlemleri için aynı
ID). Testlerde, iki uçta da aynı ID ile loglar arası ilişki kurulabildiğini doğrulayın (örn. backend
loglardaki ID’nin Crashlytics veya Sentry dashboard’unda göründüğünü kontrol edin).
Metinsel Akış Örneği (Oturum Zaman Aşımı):
[Flutter] Uygulama şifresini yenilemek için istek gönderiyor (token
süresi dolmuş).
Flutter ürettiği eventId=zyx456’yı HTTP başlığına ekliyor.
 ↓
[FastAPI] Gelen istek, middleware correlation_id=zyx456 atadı.
FastAPI token kontrol etti, JWT expired.
FastAPI logladı: "Token süresi dolmuş (ID=zyx456)".
 ↓
[FastAPI] Hata (401 Unauthorized) döndü.
 ↓
[Flutter] 401 alındı, otomatik logout/yeniden giriş iş akışı başladı.
Flutter: `Sentry.captureMessage("Token expired", tags: {"event_id":
"zyx456"})`.
Kullanıcı yönlendirildi ve bu kritik olay Crashlytics.log ile
raporlandı.
Bu akışta hem Flutter hem backend loglarında zyx456 ID’si kullanılarak işlem takip edilmiştir.
Use-Case Senaryoları:
Multi-Call İşlem: Birden fazla ardışık API çağrısı tek bir işlevsel işlem için yapılıyorsa (örn. kullanıcı
profilini güncelleme), aynı event_id tüm çağrılarda kullanılabilir. Bu şekilde tüm loglar tek bir
işlem hattı olarak birleştirilebilir.
Gerçek Zamanlı Mesaj: WebSocket üzerinden gelen bir sohbet mesajı için bağlantı başlatıldığında
ID alınır, mesaj yollanırken bu ID loglara eklenir. Böylece aynı sohbet olayının istemci ve sunucu
tarafı logları eşleştirilir.
Performans/Kapasite Öngörüleri: ID taşınması çok hafiftir (bir string header veya bir field).
Ancak log kaynağı artabileceği için yüksek trafikte ID’li log aranması hafızada indekslenmelidir.
Örneğin 100K kullanıcı/gün ve her birinin ~10 işlem başlatması halinde (~1M event), log yönetim
sistemi saniyede on binlerce ID araması yapmalıdır. Sentry/Crashlytics bu tür büyük hacmi
18
•
•
•
•
•
•
•
10
rahatça idare edecek şekilde tasarlanmıştır, ancak sorgu/filtrelemeyi optimize etmek için logların
indekslenmesine dikkat edin.
Katmanlar Arası Veri Akışı Örneği (Hata Durumu)
Senaryo: Kullanıcı feed yüklerken bir hata oluştu. Verilerin UI’dan FastAPI’ye, oradan Supabase’e ve
loglama sistemlerine kadar akışı:
[Flutter UI] Kullanıcı yenile butonuna bastı.
 → [Application Layer] Riverpod Provider 'loadFeed' çağrıldı.
 → [Domain Layer] Use-case 'GetFeed' çalıştı.
 → [API Katmanı] GraphQL query gönderiliyor (HTTP GET /feed).
 → [FastAPI] API giriş noktasına ulaştı (correlation_id=abc123).
 → [FastAPI] Supabase query yapıldı.
 → [Supabase] Veri getirilemedi (DB hatası).
 ← [FastAPI] Hata yakalandı, `logger.error` ile “Feed yüklenemedi,
ID=abc123” loglandı .
 → [FastAPI → Flutter] 500 Internal Error dönüldü.
 ← [Flutter] hata cevabı alındı.
 → [Flutter] `Sentry.captureException(error, stack)` ve
`Crashlytics.recordError` ile hata rapor edildi.
Bu akışta her katmanda loglama yapılmış ve aynı abc123 event ID ile takip sağlanmıştır.
Use-Case: Auth Token Süresi Dolması
Senaryo: Kullanıcının JWT token’ı süresi dolmuştur. Uygulama bu durumu nasıl ele alır:
Flutter’dan FastAPI’ye İstek: Flutter, eski token ile istek yapar (ör. profil güncelleme). İstek
başlığında correlation_id=tok12345 gönderilir.
FastAPI’de Yakalama: FastAPI, middleware’de tok12345 ID’sini alır. JWT doğrulaması sırasında
ExpiredSignatureError fırlatılır.
Hata Loglama: FastAPI loglar: logger.warning("Token süresi dolmuş",
extra={"event_id": "tok12345", "user": user_id}) . Sentry konfigürasyonu, 401
hatası için özel ayarlı değilse manual kayıt gerekebilir (ör.
sentry_sdk.capture_message("Token expired") ).
Hata Dönüşü: FastAPI 401 Unauthorized cevabı gönderir.
Flutter’da İşyönetimi: Flutter 401 kodunu alır, kullanıcıyı login sayfasına yönlendirir. Bu kritik
olay FirebaseCrashlytics.instance.log("Token expired, kullanıcı çıkış
yapıldı") ve Sentry.captureMessage("Token expired", tags: {"event_id":
"tok12345"}) ile raporlanır.
Sonuç: Geliştirici konsolunda hem backend hem frontend loglarında tok12345 ile işaretlenmiş
bir token-expire olayı görülür. Bu sayede bu sorun takip edilebilir.
6
1.
2.
3.
4.
5.
6.
11
Performans ve Kapasite Tahminleri
Sentry/Crashlytics Olay Oranı: Varsayalım günlük 100K aktif kullanıcı, her biri 10 önemli işlem
(login, feed, mesaj vb.) yapıyor. Bu, günlük ~1M işlem ve belki %0.1 hata oranı = 1.000 hata olayı
demektir. Sentry bu oranları rahatlıkla işleyebilir; Crashlytics otomatik toplar. Özel event’ler (ör.
“feed hatası”) da sayılacak olursa 10.000’ler mertebesine çıkabilir. Sentry ve Crashlytics’in
ücretsiz/standart plan limitlerini kontrol edin. (Örneğin Sentry 100K event/ay limitinde aşım
maliyet getirebilir.)
API Yanıt Süreleri: Gerçek zamanlı bir kullanıcı deneyimi için tipik hedefler P50 <200ms, P95
<500ms civarındadır . Backend üzerinde time to first byte 100–300ms arası
idealdir. FastAPI (Starlette/Uvicorn) ile bu hedeflere ulaşmak mümkündür; benchmark’larda en
hızlı Python çözümlerinden biridir . Ağ gecikmesi ve JSON işleme ek yük getirir, bu nedenle
Sentry Performance (trace) ile sınır noktalarını izlemek faydalıdır.
Logging Overhead: Loglama işlemi genel olarak I/O (diske veya ağa) bağımlıdır. En verimli
senaryo, logları asenkron tamponda tutup batch olarak göndermektir. Crashlytics ve Sentry de
böyle çalışır. Örnek olarak, bir hata oluştuğunda uygulama ana thread’i bloke olmadan olayı
kaydeder. Belirli bir endpoint için log süresi, genelde milisaniyeler mertebesindedir ve API
yanıtını etkilemez. Çok yüksek trafik altında (dakikada binlerce olay), log toplama sistemini (ör.
ELK, Datadog) yatay ölçekleyin. Örneğin Uvicorn için birkaç worker ve konfigüre edilmiş load
balancer ile 1000+ concurrent isteğe yatay ölçeklenebilir kapasite sağlanabilir.
Veri Tabanı ve RLS Performansı: Supabase’da milyonlarca kayıt varsa sorgu süreleri uzar.
Örneğin feed tablosu 1M+ kayıt içeriyorsa partitioning veya indexed arama kullanın. RLS (Row
Level Security) politikasının karmaşıklığı da sorgu performansını etkiler; karmaşık izin kontrolleri
uygulamak yerine mümkün olduğunca basit ve indeksli alanlar kullanın.
CDN/Cache Stratejisi: Sık değişmeyen içerikler (ör. statik profil resimleri, reklam afişleri) CDN
üzerinden servis edilip geri gelen loglatılabilir (örn. CDN’de 30dk cache, log hatası durumunda
Toast ile uyarı).
Ölçek Planlama: 1K, 10K, 100K kullanıcı senaryolarında log hacmi katlanarak artacaktır. Örneğin
100K kullanıcıda dakikada 500 API çağrısı ve 50 hata meydana geliyorsa, dakikada 550 log
işlenecektir. Bu durumda Sentry'i sample rate %50’lere çekip sadece rastgele yarısını toplamak ağ
maliyetini yarı yarıya düşürebilir. Ayrıca Uvicorn worker sayısını otomatik ölçekleyerek (kod
değişikliği olmadan) backend’in kapasitesi artırılabilir. Birden fazla FastAPI instance’ı Sentry
loglarını merkezi olarak toplayacaktır.
Özet: Monitoring ve loglama mimarisi, şeffaflık ve koordinasyon üzerine kurulmalıdır. Flutter tarafında
Crashlytics ve Sentry ile kullanıcının gördüğü hataları yakalayıp raporlayın; FastAPI tarafında Python
logları ve Sentry ile sunucu hatalarını takip edin. Tüm ilgili olaylara benzersiz ID atayarak uçtan uca
izlenebilirlik sağlayın . Bu yaklaşım, hataları hızlıca tespit etmeyi, düzeltilmesini ve sistem
kapasitesini öngörmeyi kolaylaştırır.
Kaynaklar: Flutter ve Sentry entegrasyonu için resmi dökümantasyon ve topluluk kaynakları ;
FastAPI ve Sentry entegrasyonu hakkında Sentry Docs ; Flutter ve Crashlytics setup rehberleri
; genel loglama ve event takip önerileri ; performans hedefleri için sektör ölçekleri .
Flutter logging best practices - LogRocket Blog
https://blog.logrocket.com/flutter-logging-best-practices/
Setting up request ID logging for your FastAPI application | Medium
https://medium.com/@sondrelg_12432/setting-up-request-id-logging-for-your-fastapi-application-4dc190aac0ea
•
•
16 17
7
•
•
•
•
19 20
21 10
6 11
12 2 20 16 17
1 2 3 4
5 18 20
12
FastAPI | Sentry for Python
https://docs.sentry.io/platforms/python/integrations/fastapi/
Benchmarks - FastAPI
https://fastapi.tiangolo.com/benchmarks/
Monitoring Errors in Flutter Apps with Sentry | by Jamiu Okanlawon | Medium
https://medium.com/@developerjamiu/monitoring-errors-in-flutter-apps-with-sentry-d8f5fb178ae8
Flutter | Sentry for Flutter
https://docs.sentry.io/platforms/dart/guides/flutter/
Using Firebase Crashlytics | FlutterFire
https://firebase.flutter.dev/docs/crashlytics/usage/
Logging | Sentry for Python
https://docs.sentry.io/platforms/python/integrations/logging/
Odown Blog | API Response Time Standards: What's Good, Bad, and Unacceptable
https://odown.com/blog/api-response-time-standards/
What is the X-REQUEST-ID http header? - Stack Overflow
https://stackoverflow.com/questions/25433258/what-is-the-x-request-id-http-header
6
7
8 10 15
9 13 21
11 12
14
16 17
19
13
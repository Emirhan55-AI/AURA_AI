Merkezi Hata Yönetimi (Centralized Error
Handling)
Flutter uygulamasında hataları tek bir noktada toplamak, beklenmeyen çöküşleri önlemek ve kullanıcıya
kestirme çözümler sunmak için global hata yönetimi çok önemlidir. Örneğin main() fonksiyonunu
aşağıdaki gibi sarmalayarak tüm uncaught (yakalanmamış) hataları yakalayabilirsiniz:
void main() {
// Flutter çerçevesi içi hataları yakala
FlutterError.onError = (FlutterErrorDetails details) {
// Örneğin bir Error Screen sayfasına yönlendir
// veya hatayı Sentry/Crashlytics'e logla
};
// Flutter çerçevesi dışı tüm asenkron hataları yakala
runZonedGuarded(
() => runApp(MyApp()),
(error, stackTrace) {
debugPrint('Yakalanan hata: $error');
// Hatanın kullanıcıya gösterilmesi veya loglanması
},
);
}
Yukarıdaki kod, framework kaynaklı hataları FlutterError.onError ile, çerçeve dışı (ör. network,
database) asenkron hataları ise runZonedGuarded ile toplar . Böylece merkezi hata işleyici
oluşturulmuş olur.
Araçlar: FlutterError.onError , runZonedGuarded , özel Exception sınıfları (örneğin
AuthExpiredException ) ve hata loglama servisleri (Sentry/Crashlytics).
Kod Örneği:
FlutterError.onError = (details) {
// Kullanıcıyı hata ekranına yönlendir veya Snackbar göster
Navigator.of(navigatorKey.currentContext!).pushNamed('/error');
};
runZonedGuarded(() => runApp(MyApp()), (err, st) {
Sentry.captureException(err, stackTrace: st);
});
Potansiyel Sorun: Tüm hataları tek potada toplamak, debug yapmayı zorlaştırabilir. Örneğin UI
akışı içinde atılan hataların anında yakalanması bazen sorunlara yol açabilir. Hatanın kullanıcıya
nasıl iletileceğine dikkat edilmeli (ör. teknik mesajlardan kaçınılmalı).
1 2
•
•
•
1
Performans & Test Edilebilirlik: Global hata yönetimi, testlerde hatanın çeşitli katmanlardan
çıkıp çıktığını doğrulamayı kolaylaştırır. Performans olarak, bir hatanın anında gösterilmesi yerine
kullanıcıya önceden hazırlanmış bir “Hata Ekranı” veya Snackbar ile bildirim yapılmalıdır.
Dosya Yapısı Örneği:
lib/
├── main.dart
├── src/
│ ├── core/
│ │ ├── error/
│ │ │ ├── global_error_handler.dart // runZonedGuarded burada
kullanılır
│ │ │ └── app_error_view.dart // Ortak hata widget'ı
│ │ └── utils/
│ │ └── exceptions.dart // Özel Exception sınıfları
│ └── presentation/
│ └── widgets/
│ └── error_widget.dart // UI için yeniden
kullanılabilir hata widget'ı
└── ...
Şema (Akış):
UI (Widget) → Domain (UseCase/Service) → API (GraphQL/REST) → Backend
(FastAPI/Supabase)
 ↑<───────────── Hata döndürür ─────────────┘
 ↓ AsyncValue.error aracılığıyla UI'ye ulaşır
Örneğin bir feed yükleme sırasında Network hatası: UI’dan gelen istek Sunucu’da (Supabase)
işlenir, hata döner; AsyncValue.error olarak katmanları geri geçip, UI’da bir ErrorView ile
gösterilir.
Use-case (Senaryo): Kullanıcının oturumu süresi dolarsa (örneğin, FastAPI’den gelen 401
Unauthorized). Uygulama, repository katmanında bu 401’ı AuthExpiredException gibi bir özel
hataya dönüştürür. Bunun üst katmanında, global hata yönetimi veya Auth provider bunu yakalar ve
kullanıcıyı otomatik olarak giriş ekranına yönlendirir veya token yenileme sürecini başlatır. Böylece
kullanıcı teknik hata yerine “Oturumunuz zaman aşımına uğradı, lütfen tekrar giriş yapın” mesajı görür.
Kullanıcı Dostu Hata Mesajları (User-friendly Error Messages)
Hataları yakaladıktan sonra kullanıcıya gösterilen mesajların anlaşılır ve dostane olması gerekir.
Teknik detaylar yerine basit ifadeler kullanılmalı; örneğin “Sunucuya bağlanılamadı. Lütfen internet
bağlantınızı kontrol edin” gibi. Hata mesajları genellikle uygulamanın diline göre lokalize edilmelidir.
Mimari Öneri: Model katmanında/servis katmanında oluşabilecek hata türlerini tanımlayıp, her
biri için kullanıcıya yönelik bir mesaj eşleyin. Örneğin, NetworkException ,
•
•
•
1 2
•
2
TimeoutException , UnauthorizedException gibi sınıflarınız olsun. Bu exception’ları UI’ya
iletirken lokalizasyon (ör. AppLocalizations.of(context).networkError ) kullanarak
gösterin.
Araçlar/Kütüphaneler: flutter_localizations (veya intl ) ile çeviri desteği;
özelleştirilmiş hata widget’ları (örn. ErrorView widget’ı); hata yönetimi için merkezi sınıflar.
Ayrıca ErrorWidget.builder kullanarak, Flutter’ın varsayılan kırmızı ekran yerine özel bir
hata ekranı (örneğin MyErrorWidget ) yazabilirsiniz .
Kod Örneği:
// Örnek AsyncNotifier içinde hata fırlatma
Future<void> fetchData() async {
state = const AsyncValue.loading();
try {
final result = await apiService.getData();
state = AsyncValue.data(result);
} on NetworkException {
state = AsyncValue.error('Lütfen internet bağlantınızı kontrol
edin');
} catch (e) {
state = AsyncValue.error('Bir hata oluştu, lütfen tekrar deneyin');
}
}
// UI: Hata mesajını kullanıcıya göster
final state = ref.watch(dataNotifierProvider);
return state.when(
loading: () => CircularProgressIndicator(),
error: (err, _) => Center(child: Text(err.toString())),
data: (data) => DataView(data: data),
);
Potansiyel Sorunlar: Hata mesajlarını doğrudan exception’dan oluşturmak yerine, önceden
belirlenmiş, kısa ve açıklayıcı metinler kullanın. Detaylı loglar arka planda tutulmalı, kullanıcıya
sadece ihtiyacı olan bilgi verilmeli. Türkçe uygulamalarda teknik İngilizce mesajlardan kaçının.
Ayrıca dikkat edin; aynı mesaj her zaman en uygun çözüm olmayabilir (örn. “Oturumunuzun
süresi doldu, lütfen tekrar giriş yapın” gibi özel durumlar için farklı mesajlar gerekebilir).
Performans & Test: Hata ekranları basit olduğu için performans yükü düşük olacaktır. Ancak
mesajların doğru yüklendiği ve lokalizasyon dosyalarında yer aldığından emin olun. Widget
test’lerinde farklı hatalar için doğru mesajların gösterildiğini kontrol edin. Centralized Exception
mapping sayesinde bu testler daha kolay yazılır.
Şema Örneği (Flow):
Application Katmanı (UseCase) → API çağrısı → Hata (ör:
TimeoutException)
 ↑ Hata AsyncValue.error ile yakalanır
UI (Widget) hata durumunu görür → Kullanıcıya dostane mesajlı hata
ekranı gösterir.
Use-case Senaryoları:
•
3
•
•
•
•
•
3
Network Hatası: Kullanıcı uygulamayı internet olmadan açtığında veriler yüklenemez. UI
“İnternet bağlantınız yok” şeklinde uyarır.
Form Doğrulama: Kullanıcı boş alan bıraktığında veya yanlış format girdiğinde, form seviyesinde
hemen “Bu alan boş bırakılamaz” gibi açıklayıcı hata mesajı gösterilir.
Yetkilendirme Hatası: JSON Web Token (JWT) süresi dolduysa, “Oturumunuzun süresi
dolmuştur. Lütfen yeniden giriş yapın.” gibi yönlendirici mesaj verilir.
Tekrar Deneme Düğmeleri ve Yükleniyor Durumları (Retry &
Loading States)
Her asenkron işlem için yükleniyor (loading) durumu ve hata sonrası yeniden deneme mekanizması
olmalıdır. Riverpod AsyncValue sınıfı, bu üç durumu (data/loading/error) temsil etmeyi kolaylaştırır
. Örneğin bir FutureProvider veya AsyncNotifier ile veri çekerken hata alınırsa, ekranda
bir “Tekrar Dene” butonu gösterebilirsiniz. Kullanıcı bu butona bastığında aynı provider yeniden
tetiklenir.
Mimari Öneri: State’i AsyncValue<T> ile yönetmek, loading ve error durumlarını
standartlaştırır. Hata anında UI’da basit bir hata görünümü ( AppErrorView ) ile hata mesajını
ve “Retry” butonunu gösterin. Butona basıldığında ref.invalidate(provider) veya
ref.refresh(provider) ile provider’ı temizleyip yeniden çağırın .
Araçlar/Kütüphaneler: Riverpod (StateNotifier/AsyncNotifier/AsyncValue), pull_to_refresh
gibi paketler veya RefreshIndicator widget’ı. Connectivity paketi ile çevrimdışı kontrolü.
Kod Örneği:
// Provider
final feedProvider = FutureProvider<List<Post>>((ref) async {
final api = ref.read(apiServiceProvider);
return api.fetchFeed(); // hata fırlatabilir
});
// UI (ConsumerWidget)
class FeedPage extends ConsumerWidget {
@override
Widget build(BuildContext context, WidgetRef ref) {
final feedState = ref.watch(feedProvider);
return feedState.when(
loading: () => Center(child: CircularProgressIndicator()),
error: (err, _) => AppErrorView(
message: err.toString(),
onRetry: () => ref.invalidate(feedProvider), // yeniden deneme
),
data: (posts) => ListView.builder(
itemCount: posts.length,
itemBuilder: (_, i) => PostWidget(posts[i]),
),
);
•
•
•
3
4 5
•
6
•
•
4
}
}
Potansiyel Sorunlar: Kullanıcı ard arda çok kez “yeniden dene” tuşuna basarsa, gereksiz
network çağrıları olabilir. Bunu önlemek için butonu loading durumunda devre dışı bırakın.
Ayrıca uzun bekleme durumlarında CircularProgressIndicator gibi bir yükleniyor
animasyonu gösterin. Otomatik retry mekanizmalarında aşırı istek göndermemek için
exponentiyel backoff (artan süreli bekleme) uygulayabilirsiniz.
Bakım ve Test: AsyncValue.guard kullanarak hata yakalama işlemini koda gömülü hale
getirin . Testlerde hata durumunu simüle edip, onRetry fonksiyonunun provider’ı
gerçekten yenilediğini kontrol edin. Otomatik testlerde ref.invalidate ile provider’ın
yenilenmesi kolaydır. Kodun temiz olması için AsyncValue.guard kullanımı, try/catch ’ten
daha güvenli ve özet bir yapı sağlar.
Şema (Akış):
UI (FeedPage)
 → ref.watch(feedProvider) (loading, gösteriliyor)
 → feedProvider AsyncNotifier ödev alır
 → API çağrısı (GraphQL)
 ↳ Başarılıysa: asyncData (List<Post>)
 ↳ Hataysa: AsyncValue.error
UI AsyncValue.error'u görür → AppErrorView (mesaj + Retry)
Kullanıcı "Retry" tuşuna basar → ref.invalidate(feedProvider) ile tekrar
çağır.
Use-case Senaryoları:
Feed Yenileme: Kullanıcı ana sayfayı açtığında feed yüklenirken network hatası oldu. Ekranda
“Yüklenirken hata oluştu” mesajı ve “Tekrar Dene” butonu gösterilir. Kullanıcı butona bastığında
feed yeniden çekilir.
Ayar Güncelleme: Profil güncelleme başarısız olursa (“Veriler kaydedilemedi”), bir hata dialog’u
veya Snackbar ile mesaj verip kullanıcıya tekrar deneme seçeneği sunulur. Örneğin “Kaydetme
işlemi başarısız oldu. Lütfen tekrar deneyin.” ve “Tekrar Dene” düğmesi.
Mesaj Gönderme: Çevrimdışı iken mesaj yazılırsa, mesaj kuyruğa alınır ve gönderme denemesi
yapılır. Başarısızsa kullanıcıya “Mesaj gönderilemedi. Tekrar deneyiniz.” butonlu bir uyarı
gösterilir. Bağlantı geri geldiğinde otomatik yeniden deneme veya manuel “Tekrar Gönder”
butonu sunulur.
Snackbar, Dialog ve Geri Bildirim Mekanizmaları (Feedback
Mechanisms)
Hatalara veya önemli olaylara hızlı yanıt vermek için Snackbar ve Dialog gibi UI elemanları kullanılır.
Örneğin bir beğeni, yorum veya mesaj gönderme işlemi başarılı olduğunda kullanıcıya kısa bir onay
•
•
7
•
•
•
•
•
7 6
5
metni (Snackbar) gösterebilir; hata durumunda ise uyarı çubuğu veya açılır pencereyle (Dialog) bilgi
verebilirsiniz.
Mimari Öneri: UI katmanında hataya tepki olarak
ScaffoldMessenger.of(context).showSnackBar(...) veya showDialog(...) çağırın.
Hata widget’ları (örn. AppErrorView ) içinde bu çağrıyı ref.listen() ile de
tetikleyebilirsiniz. Örneğin bir StateNotifier durumunu dinleyerek oluşan hatayı Snackbar
ile ekranda gösterebilirsiniz .
Araçlar/Kütüphaneler: Yerleşik SnackBar , AlertDialog ; üçüncü taraf paketler (ör.
another_flushbar ). flutter_localizations ile Hata mesajlarının çoklu dil desteği.
Riverpod ile ref.listen veya Listener widget’ı, belirli hatalarda otomatik Snackbar
tetikleme için kullanılabilir.
Kod Örneği:
// AsyncValue hatayı algılayıp snackbar gösteren örnek dinleyici
ref.listen<AsyncValue<void>>(saveProvider, (prev, curr) {
curr.whenOrNull(
error: (error, _) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text(error.toString())),
);
},
);
});
// Basit bir hata dialogu gösterimi
Future<void> _showErrorDialog(BuildContext context, String message) {
return showDialog(
context: context,
builder: (_) => AlertDialog(
title: Text('Hata'),
content: Text(message),
actions: [TextButton(onPressed: () => Navigator.pop(context),
child: Text('Tamam'))],
),
);
}
Potansiyel Sorunlar: ScaffoldMessenger kullanırken geçerli bir BuildContext
( Scaffold altında) sağlanmalı. Aksi halde görünmeyebilir. Aynı hatayı birden fazla kez
göstermemeye dikkat edin (ör. hatayı sadece ilk seferde Snackbar ile bildirin). Dialog’lar tüm
ekranı kapladığı için bilgiyi kaybetmemek için kritik durumlarla sınırlayın; basit uyarılar için
SnackBar tercih edin.
Performans & Test: SnackBar ve Dialog kullanımı UI ağırlığını etkilemez; hafif geri bildirim
mekanizmalarıdır. E2E veya widget testlerinde, hata anında doğru widget’ın görünüp
görünmediğini kontrol edin. Örneğin, bir hata durumunda ScaffoldMessenger üzerinde
beklenen mesajın görüntülendiği test edilebilir.
Şema Örneği (Akış):
•
8
•
•
•
•
•
6
Hata Oluştu → UI Katmanında Yakala
 → SnackBar: Kısa bir bilgilendirme mesajı
 veya
 → AlertDialog: Kritik hata için açılır pencere
 veya
 → ErrorView: Tam ekran hata widget'ı
Use-case Senaryoları:
Gönderim Başarısı: Yeni bir moda gönderisi paylaştığında “Paylaşımınız başarıyla gönderildi”
mesajını Snackbar’da gösterin.
Gönderim Hatası: Fotoğraf yüklemede hata olursa “Fotoğraf yüklenemedi. Lütfen tekrar
deneyin.” şeklinde bir hata dialog’u açılabilir.
Kritik Uyarı: Ödeme esnasında işlem onaysızsa kullanıcıya “İşlem başarısız oldu, kredi kartınızı
kontrol edin.” diyalog penceresi ile gösterilebilir.
Katmanlar Arası Hata Akışı (Örnekler)
Aşağıda, hata durumunda katmanlar arası veri akışını anlatan örnek akışlar verilmiştir:
Feed Yükleme Hatası:
UI (FeedScreen)
 → UseCase.fetchFeed()
 → Repository.getFeed()
 → GraphQL.query()
 → Supabase'den hata döner (örneğin 500)
 ← Hata AsyncValue.error olarak üst katmanlara iletilir
 ← UI AsyncValue.error uyarısını alır, AppErrorView ile "Feed
yüklenemedi" mesajı ve yeniden dene butonu gösterir.
Profil Güncelleme (REST API) Hatası:
UI (SettingsPage)
 → UseCase.updateSettings()
 → API (REST) çağrısı (FastAPI)
 → 401 Unauthorized (token geçersiz)
 ← catch -> AuthExpiredException fırlatılır
 → Global Error Handler devreye girer
 → Kullanıcıya "Oturumunuzun süresi dolmuştur" mesajı ile giriş
sayfasına yönlendirme.
Gerçek Zamanlı Mesaj Hatası:
•
•
•
•
8 9
•
•
•
7
UI (ChatPage)
 → Service.sendMessage()
 → Supabase Realtime (WebSocket)
 → Mesaj gönderimi sırasında bağlantı kayboldu (timeout/connection
lost)
 ← Yakalama: Mesaj queue'ya alınır, UI "Mesaj gönderilemedi"
uyarısını gösterir
 ← Bağlantı sağlandığında otomatik retry veya kullanıcı "Tekrar Gönder"
düğmesi ile işlem tekrar denenir.
Bu akışlar hata durumunda nasıl tepki verileceğini gösterir. Tüm katmanlar arasındaki hatalar,
application/domain katmanlarında özel istisnalara dönüştürülüp, en nihayetinde UI’da uygun mesajlarla
kullanıcıya iletilir.
Performans ve Kapasite Tahminleri
Hata yönetiminde performans ve ölçeklenebilirlik için bazı hedef ve öngörüler:
API Yanıt Süreleri: Mümkünse başarılı API çağrılarında yanıt <200ms, yazma/işlem çağrılarında
<500ms. Hatalı istekler de hızlıca sonuçlanmalı (timeout ayarları: 5-10sn).
Cache TTL Önerileri:
Feed verileri için (okuma yoğun) cache TTL ~5 dakika olabilir. Bu sürede hata alındığında eski
önbellek gösterilebilir.
Kullanıcı profili gibi statik veri için 1 saat önbellekleme yapılabilir. Yükleme sırasında hata olursa
önceden önbelleğe alınan veri gösterilebilir.
Hata Günlüğü (Logging) Kapasitesi: Diyelim günde 10.000 hata kaydı bekleniyorsa (örn. büyük
kullanıcı kitlesi). Sentry/Crashlytics gibi servislerin bu hacme göre planlanması gerekebilir. Hata
akışını throttling (ör. saniyede 10-100 kısıtlama) ile kontrol etmek, aşırı yüklenmeyi önler. Kritiklik
derecesine göre hata seviyesi ayrımı (error/warning) yapılmalıdır.
Önlem ve Uyarılar: Sürekli hata üreten endpoint’ler için alert konfigürasyonu kurulmalı (ör. 1
saat içinde bir API 100 kez 500 hatası verdiyse ekip uyarılır).
Oturum Süresi ve Token Yenileme: JWT gibi token’lar için "refresh token" stratejisi kullanılmalı;
süresi dolanlar arka planda yenilenmeli. Aynı anda 1K, 10K, 100K kullanıcıyı desteklemek için load
balancer’da oturum tutma (sticky session) yerine token geçerlilik süresi yönetimi önerilir.
Hafıza Kullanımı: AsyncValue ile yönetilen state’ler kolayca temizlenebilir (autoDispose) veya
uzun ömürlü tutulabilir. Hatalı veriyi bellekle tutmaktan kaçının; örneğin çok büyük metin hatalar
yerine, kod + mesaj gösterin.
Ölçeklenebilirlik Senaryoları: Yüksek trafikte (örneğin 100K kullanıcı) API ve hata kayıt
sisteminizin yatay ölçeklenebilir olması gerekir. Örneğin FastAPI sunucularını Docker
konteynerlerde çalıştırıp Kubernetes ile yatay genişletme yapılabilir. Supabase Realtime
hatalarını karşıdan proxy ile load-balance etmek de düşünülebilir.
Tüm bu önlemler, uygulamanın yüksek trafikli veya kötü koşullarda dahi kullanıcıya makul hatalar
göstermesini sağlar.
•
•
•
•
•
•
•
•
•
8
Error Handling in Flutter Using runZonedGuarded and Global Error Catching
https://www.dbestech.com/tutorials/error-handling-in-flutter-using-runzonedguarded-and-global-error-catching
Error Handling in Flutter: Practical Examples for Building Robust Apps | by Sumaiya Mollika |
Medium
https://medium.com/@smollika998/error-handling-in-flutter-practical-examples-for-building-robust-apps-15979ba07510
How to handle loading and error states with StateNotifier & AsyncValue in Flutter
https://codewithandrea.com/articles/loading-error-states-state-notifier-async-value/
Flutter Riverpod: How to trigger FutureProvider after first execution fail? - Stack Overflow
https://stackoverflow.com/questions/66968194/flutter-riverpod-how-to-trigger-futureprovider-after-first-execution-fail
Use AsyncValue.guard rather than try/catch inside your AsyncNotifier subclasses
https://codewithandrea.com/tips/async-value-guard-try-catch/
Effective Error Handling in Flutter with Bloc and Repository Patterns | by Kiran Kulkarni | nonstopio
https://blog.nonstopio.com/effective-error-handling-in-flutter-with-bloc-and-repository-patterns-de55f6f847bc?
gi=c1023db08057
Display a snackbar | Flutter
https://docs.flutter.dev/cookbook/design/snackbars
1 2
3
4 5
6
7
8
9
9
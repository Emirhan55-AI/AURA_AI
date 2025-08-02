Aura Projesi: Hibrit Mimari Uygulama Rehberi - Flutter
Uygulama Mimarisi
Bu rapor, modern bir Flutter projesi olan Aura'nın frontend katmanı için ölçeklenebilir
ve sürdürülebilir bir hibrit mimari kurma amacını taşımaktadır. Odak noktası, orta
seviye Flutter geliştiricileri ve startup teknik liderleri için kullanıcı etkileşiminin yoğun
olduğu, gerçek zamanlı içeriklerin ön planda olduğu bir sosyal moda uygulaması
senaryosu üzerinden kapsamlı bir rehber sunmaktır.
1. Katman Ayrımı ve Sorumluluklar
Aura projesi gibi karmaşık iş mantığına, yoğun kullanıcı etkileşimine ve gerçek zamanlı
içerik gereksinimlerine sahip uygulamalar için Clean Architecture prensiplerine dayalı
katmanlı bir yapı önerilmektedir. Bu mimari yaklaşım, uygulamanın modülerliğini,
ölçeklenebilirliğini ve test edilebilirliğini önemli ölçüde artırır.
1 Bu stratejik mimari
seçimi, projenin sadece mevcut geliştirme hızını değil, aynı zamanda uzun vadeli
sürdürülebilirliğini ve gelecekteki adaptasyon yeteneğini de doğrudan etkiler. Örneğin,
kullanıcı arayüzü çerçevesi (Flutter) veya arka uç teknolojisi (Supabase/FastAPI)
gelecekte değişmek zorunda kalırsa, uygulamanın çekirdek iş mantığının bu
değişikliklerden minimum düzeyde etkilenmesi sağlanır, bu da teknik borcun
birikmesini engeller.
Clean Architecture'da katmanlar, bağımlılık kurallarına (Dependency Rule) göre
düzenlenir: dış katmanlar iç katmanlara bağımlı olabilirken, iç katmanlar dış
katmanlardan bağımsız kalır. Bu, iş mantığının ve çekirdek verilerin, kullanıcı arayüzü
veya veritabanı teknolojisi gibi dışsal değişikliklerden izole edilmesini sağlar.
Katman Yapısı:
● Presentation (UI) Katmanı: Bu katman, kullanıcı arayüzünü oluşturan Widget'ları
ve ekranları içerir. Aynı zamanda, UI durumunu yöneten ve kullanıcı etkileşimlerine
tepki veren View/ViewModel veya Riverpod Notifier/Controller mantığını barındırır.
Presentation katmanının temel sorumluluğu, uygulama verilerini kullanıcıya
sunmak ve kullanıcı girdilerini (örneğin, dokunma olayları, form girişleri) almak,
ardından bu olayları işlemek üzere bir sonraki katmana iletmektir. Bu katman,
doğrudan iş kuralları veya veri erişim mantığı içermemelidir.
2
● Application/Domain (İş Mantığı) Katmanı: Uygulamanın temel iş kurallarını ve
kullanım senaryolarını (Use Cases/Interactors) barındıran çekirdek katmandır. Bu
katman, Presentation katmanından gelen istekleri işler, veri katmanından (Data
Layer) gerekli verileri alır, iş kurallarını uygular ve ardından Presentation katmanına
uygun formatta geri döndürür. Bu katman, Flutter'dan veya herhangi bir dış
çerçeveden bağımsız, saf Dart kodu olmalıdır.
2 Use Case'ler, karmaşık iş mantığını
veya birden fazla repository'den veri birleştirmeyi gerektiren senaryoları kapsüller.
3
● Data (Veri) Katmanı: Uygulamanın dış dünya ile etkileşimini yönetir. Bu katman,
API servisleri (Supabase, FastAPI), yerel veritabanları (Hive, Shared Preferences)
ve veri modellerini (DTO'lar ve Domain modelleri arası dönüşüm) içerir. Repository
arayüzleri Domain katmanında tanımlanır ve Data katmanında uygulanır. Data
katmanı, önbellekleme, hata işleme ve veri yenileme gibi iş mantığını da barındırır.
2
Katmanlar Arası Veri Akışı Örnekleri:
Aşağıdaki metinsel şema, katmanlar arası veri akışının genel yapısını göstermektedir:
UI (Widgets, Views)
↓ (Kullanıcı Olayları, UI Durumu)
Application/Domain (Use Cases, Entities)
↓ (İş Mantığı, Repository Arayüzleri)
Data (Repositories, Veri Kaynakları: API, Yerel VT)
↓ (Harici Servisler: Supabase, FastAPI, GraphQL, REST)
Bu akışta, kullanıcı etkileşimleri UI katmanında başlar. UI, bu olayları
Application/Domain katmanındaki ilgili Use Case'lere iletir. Use Case'ler, iş kurallarını
uyguladıktan sonra, gerekli verileri almak veya göndermek için Data katmanındaki
Repository'leri kullanır. Repository'ler ise veriyi API'ler (GraphQL, REST) veya yerel
veritabanları aracılığıyla dış kaynaklardan çeker veya dış kaynaklara gönderir. Veri,
Data katmanında Domain katmanının anlayacağı modellere dönüştürülür ve zincir
boyunca geri akarak UI'ın güncellenmesini sağlar.
Potansiyel Sorunlar ve Çözümleri:
● Katmanlar Arası Sızıntı (Layer Leakage): UI katmanının doğrudan API
servislerini çağırması veya iş mantığının Widget'lar içinde yer alması gibi durumlar,
kodun test edilebilirliğini zorlaştırır, kod tekrarına yol açar ve uygulamanın bakımını
karmaşıklaştırır.
2 Bu durum, Clean Architecture'ın temel prensiplerine aykırıdır.
○ Çözüm: Katı bağımlılık kurallarına uyulması esastır. UI katmanının yalnızca Use
Case'leri çağırması ve Use Case'lerin Repository arayüzlerini kullanması
sağlanmalıdır. Linter kuralları ve düzenli kod incelemeleri ile bu prensip zorunlu
kılınabilir.
6
● Şişmiş Widget'lar (Bloated Widgets): Tüm iş mantığının veya veri çekme
operasyonlarının doğrudan Widget'lar içinde yapılması, UI katmanının
sorumluluklarını aşmasına neden olur ve karmaşıklığı artırır.
2
○ Çözüm: İş mantığının Use Case'lere, veri yönetiminin ise Repository'lere
taşınması gerekmektedir. Widget'lar sadece kullanıcı arayüzünü göstermek ve
kullanıcı olaylarını uygun katmanlara iletmekle sorumlu olmalıdır.
2
Güvenlik Önlemleri:
Katman ayrımı, hassas iş mantığının ve veri erişim kurallarının kullanıcı arayüzünden
izole edilerek daha güvenli bir şekilde yönetilmesine olanak tanır. Örneğin, Row Level
Security (RLS) politikaları gibi veritabanı seviyesindeki güvenlik kuralları, Data
katmanında uygulanmalı ve UI katmanının bu kuralları atlaması engellenmelidir.
7 Bu,
yetkisiz veri erişimini veritabanı seviyesinde önleyerek ek bir güvenlik katmanı sağlar.
Dosya Yapısı ve İsimlendirme Örnekleri:
Aura projesi gibi birden fazla, bağımsız ve büyüyen özelliğe sahip büyük uygulamalar
için özellik odaklı (feature-first) bir dosya yapısı şiddetle tavsiye edilir.
5 Bu yaklaşım,
ilgili tüm kodun (UI, iş mantığı, veri) belirli bir özelliğin altında toplanmasını sağlar. Bu
organizasyon, özellikle birden fazla geliştiricinin aynı anda çalıştığı bir startup
ortamında, takımların birbirinin koduna takılmasını engeller. Her özelliğin kendi içinde
Presentation, Domain ve Data katmanlarını barındırması, geliştiricilerin belirli bir özellik
üzerinde izole bir şekilde çalışmasına olanak tanır. Bu izolasyon, bir özellikteki
değişikliklerin başka bir özelliği bozma olasılığını azaltır ve birleşme çakışmalarını
düşürür.
5 Ayrıca, yeni ekip üyelerinin tüm uygulamayı anlamaya çalışmak yerine, belirli
bir özelliğin klasörüne odaklanarak hızla adapte olmasını sağlar.
● lib/
○ core/ (Uygulama genelinde kullanılan temel yapılar, yardımcılar, hata modelleri,
paylaşılan servis arayüzleri)
■ errors/
■ utils/
■ resources/
■ network/ (Dio client, interceptors)
○ features/ (Özellik odaklı organizasyon)
■ auth/
■ presentation/ (login_screen.dart, auth_controller.dart)
■ domain/ (user_entity.dart, auth_repository.dart, login_usecase.dart)
■ data/ (auth_model.dart, auth_repository_impl.dart,
auth_remote_datasource.dart)
■ wardrobe/
■ presentation/
■ domain/
■ data/
■ social_feed/
■ presentation/
■ domain/
■ data/
○ app.dart (GoRouter konfigürasyonu, tema)
○ main.dart (Uygulama başlangıcı, ProviderScope)
İsimlendirme Kuralları ve En İyi Uygulamalar:
● Dosya Adları: snake_case kullanılmalıdır (örn. wardrobe_home_screen.dart,
clothing_item_card.dart).
6
● Sınıf Adları: PascalCase kullanılmalıdır (örn. WardrobeHomeScreen,
ClothingItemCard, WardrobeController, GetClothingItemsUseCase).
6
● Değişken ve Metot Adları: camelCase kullanılmalıdır (örn. loadItems, isGridView,
toggleFavorite).
6
● Açıklayıcı İsimler: Değişken, fonksiyon ve sınıf isimleri, amaçlarını açıkça
belirtmelidir. Örneğin, x yerine itemCount, foo() yerine fetchData() gibi daha
açıklayıcı isimler tercih edilmelidir.
6
● Sabitler: const anahtar kelimesi ile tanımlanan sabitler için
SCREAMING_SNAKE_CASE kullanılabilir (örn. API_BASE_URL).
Monorepo Kullanımına Dair Mimari Öneri:
Monorepo yaklaşımı, tek bir versiyon kontrol deposunda (örneğin Git) birden fazla
projenin (örn. Flutter mobil uygulaması, FastAPI backend, web paneli) barındırılması
anlamına gelir.
10
Polyrepo ise her projenin kendi ayrı deposunda barındırılmasıdır.
10
Aura projesi, Flutter frontend ve FastAPI backend'i arasında güçlü bir entegrasyon ve
paylaşılan kod ihtiyacı barındırdığı için monorepo yaklaşımı başlangıç için oldukça
uygun ve avantajlıdır. Bu, sadece teknik bir kod organizasyonu kararı değil, aynı
zamanda bir organizasyonun geliştirici iş akışını ve ekip işbirliği kültürünü doğrudan
etkileyen stratejik bir karardır.
11
● Avantajları (Aura Projesi İçin):
○ Kod Paylaşımı: Frontend (Flutter) ve Backend (FastAPI) arasında ortak
Dart/Python modelleri, doğrulama mantığı veya yapılandırma dosyaları gibi
kodları kolayca paylaşma imkanı sunar.
10 Bu, özellikle
ClothingItem gibi modellerin hem Flutter'da hem de FastAPI'de tutarlı olmasını
sağlar.
○ Atomik Commit'ler: Frontend ve Backend'i etkileyen bir özellik değişikliği
(örneğin, yeni bir API endpoint'i ve bunu kullanan UI) tek bir commit ile
yapılabilir, bu da tutarlılığı artırır.
11
○ Basitleştirilmiş Bağımlılık Yönetimi: Frontend ve backend arasındaki
bağımlılıkları yönetmek daha kolaydır.
11
○ Birleşik CI/CD: Codemagic gibi araçlarla tek bir pipeline üzerinden hem
Flutter uygulamasını hem de FastAPI servisini derlemek, test etmek ve
dağıtmak daha kolay olabilir.
11
○ Geliştirici Deneyimi: Geliştiricilerin farklı projeler arasında geçiş yapmasını
kolaylaştırır, çünkü tüm kod tek bir yerde bulunur.
10
● Dezavantajları:
○ Boyut ve Performans: Depo büyüdükçe Git işlemleri (klonlama, fetch)
yavaşlayabilir. Çok büyük depolarda özel araçlar (örn. Bazel, Nx, Lerna)
gerekebilir.
10 Aura projesi başlangıçta bu boyuta ulaşmasa da, gelecekte
düşünülmesi gereken bir konudur.
○ Karmaşık CI/CD: Tek bir pipeline'da birden fazla projenin yönetimi, doğru
yapılandırılmazsa karmaşıklaşabilir.
11
○ Zihinsel Yük: Çok fazla proje tek bir depoda olduğunda, genel bir bakış açısı
sağlamak zorlaşabilir.
10
Aura Projesi için Uygunluk: Aura projesi, başlangıçta ek soyutlama maliyetine
katlanarak, uzun vadede daha az teknik borç biriktireceği ve pazar koşullarına daha
hızlı adapte olabileceği anlamına gelir. Bu, özellikle startup'lar için ürün-pazar uyumu
arayışında esneklik sağlar. Monorepo, başlangıçta küçük ve entegre ekipler için yüksek
verimlilik sunarken, büyüdükçe uzmanlaşmış araçlar ve dikkatli koordinasyon
gerektirebilir.
10 Bu, Aura'nın gelecekteki büyüme planları için mimari adaptasyonları ve
teknik liderliğin rolünü vurgular.
Performans, Bakım Kolaylığı ve Test Edilebilirlik Önerileri:
● Performans: Katmanlar arası net sınırlar, UI katmanının yalnızca gerekli verileri
işlemesini ve gereksiz yeniden oluşturmaları azaltmasını sağlar. İş mantığı UI
thread'inden ayrıldığından, UI takılmaları (jank) azalır.
12
● Bakım Kolaylığı: Her katmanın belirli bir sorumluluğu olması, kodun
okunabilirliğini ve anlaşılabilirliğini artırır. Bir hatanın kaynağını bulmak veya yeni bir
özellik eklemek daha kolay hale gelir.
1
● Test Edilebilirlik: Her katman bağımsız olarak test edilebilir. Örneğin, Domain
katmanındaki Use Case'ler UI veya veri katmanına bağımlı olmadan saf Dart
testleri ile test edilebilir.
1
Tablo: Katman Sorumlulukları ve Örnekleri
Katman Adı Sorumluluklar Aura Projesi Örnekleri
Presentation (UI) Kullanıcı arayüzünü gösterme,
kullanıcı etkileşimlerini
yakalama, UI durumunu
yönetme, Use Case'leri
çağırma.
WardrobeHomeScreen
(kıyafetleri gösterir, filtreleme
olayını tetikler),
WardrobeController (UI
durumunu yönetir, loadItems
Use Case'ini çağırır).
Application/Domain Uygulama iş kurallarını ve
kullanım senaryolarını (Use
Cases) tanımlama, Repository
arayüzlerini kullanma, veri
dönüşümleri.
GetClothingItemsUseCase
(filtreleme ve sıralama
mantığını uygular),
ClothingItem (saf Dart
modeli), WardrobeRepository
(arayüz).
Data Dış veri kaynaklarıyla (API,
yerel DB) iletişim kurma,
Repository arayüzlerini
uygulama, DTO'ları Domain
modellerine dönüştürme,
önbellekleme, hata işleme.
WardrobeRepositoryImpl (API
çağrılarını yapar),
SupabaseApiService
(Supabase ile iletişim),
ClothingItemDto (API'den
gelen veri modeli).
2. Riverpod v2 Durum Yönetimi
Riverpod, Flutter'da durum yönetimi, önbellekleme ve bağımlılık enjeksiyonu için güçlü
ve derleme zamanı güvenli bir çözüm sunar.
14 Aura projesi için karmaşık ve gerçek
zamanlı durumları yönetmede ideal bir tercihtir. Riverpod'ın derleme zamanı güvenliği
14 ve
BuildContext bağımsızlığı
15 gibi özellikleri, geleneksel durum yönetimi çözümlerinin
bazı zayıflıklarını giderir. Özellikle
BuildContext bağımsızlığı, UI katmanı ile iş mantığı arasındaki ayrımı güçlendirir ve
yanlış yerleştirilmiş context'ten kaynaklanan hataları azaltır.
15 Bu, Aura gibi karmaşık bir
sosyal moda uygulamasında, geliştirme sırasında ortaya çıkabilecek yaygın hataları
proaktif olarak önleyerek daha istikrarlı bir kod tabanı sağlar. Ayrıca, bu ayrım birim
testlerini kolaylaştırır
15
, çünkü iş mantığı Flutter widget ağacından bağımsız olarak test
edilebilir.
Riverpod v2 ile Provider Hiyerarşisi ve Kullanım Senaryoları:
● Temel Provider Türleri:
○ StateProvider: Basit, tekil değerleri (örneğin, bir sayaç, bir boolean flag)
yönetmek için kullanılır.
14 Aura projesinde, kullanıcının onboarding sürecini
görüp görmediğini takip eden
hasSeenOnboardingProvider gibi durumlar için idealdir.
17
○ Provider: Sabit değerleri veya diğer provider'ları okuyan değerleri sağlamak
için kullanılır. Genellikle servis veya repository instance'larını sağlamak için
idealdir.
○ StateNotifierProvider (veya yeni NotifierProvider): Değişebilir, karmaşık
durumları ve bu durumu değiştiren iş mantığını (controller'lar/view model'lar)
yönetmek için kullanılır.
14 Aura'da
WardrobeController veya AuthController gibi yapılar için mükemmeldir.
StateNotifier sınıfı, durumun değişmez (immutable) olmasını zorunlu kılar, bu
da hataları azaltır.
18
○ AsyncNotifierProvider (veya FutureProvider/StreamProvider): Asenkron verileri
(API çağrıları, veritabanı işlemleri) yönetmek ve UI'a AsyncValue (loading, data,
error) olarak sunmak için kullanılır.
14 Örneğin,
wardrobeControllerProvider'ın kıyafet listesini çekmesi gibi işlemler bu tür
provider'lar ile yönetilir.
17
● Provider Hiyerarşisi: Provider'lar birbirine bağımlı olabilir. Örneğin, bir
WardrobeController bir WardrobeRepository'e bağımlı olabilir. Bu bağımlılıklar
ref.read veya ref.watch ile yönetilir.
AutoDispose ve KeepAlive Kararları: Bellek Yönetimi ve Performans Etkileri:
● autoDispose: Varsayılan olarak kod üretimi ile oluşturulan provider'lar, dinleyici
kalmadığında otomatik olarak yok edilir. Bu, bellek sızıntılarını önler ve kaynakları
verimli kullanır.
19 Özellikle parametre alan
family provider'lar için bu çok önemlidir, aksi takdirde her parametre
kombinasyonu için bir durum bellekte kalabilir ve bellek sızıntılarına yol açabilir.
19
Aura'da dinamik olarak yüklenen listeler (örn.
WardrobeController'ın filtreli listeleri) veya detay sayfaları için idealdir.
● keepAlive: true: Bir provider'ın durumu, dinleyicisi kalmasa bile bellekte
tutulmasını sağlar.
19 Bu, sık erişilen ancak sürekli dinlenmeyen veriler (örn. kullanıcı
profili, uygulama ayarları) veya belirli bir süre önbellekte kalması istenen veriler için
kullanışlıdır. Ancak dikkatli kullanılmalıdır, aksi takdirde bellek sızıntılarına yol
açabilir.
19
● ref.keepAlive(): autoDispose etkinleştirilmiş bir provider'da, belirli bir koşul
altında (örneğin, başarılı bir ağ isteği sonrası) durumu manuel olarak canlı tutmak
için kullanılabilir.
19 Bu, ağ hatalarında önbellekleme yapmamak gibi ince ayar
senaryoları için faydalıdır.
● Performans Etkileri: Yanlış keepAlive kullanımı, uygulamanın gereksiz yere bellek
tüketmesine ve performans sorunlarına yol açabilir. autoDispose ise kaynakların
serbest bırakılmasını sağlayarak uygulamanın daha hafif çalışmasına yardımcı
olur.
21
autoDispose (varsayılan) ve keepAlive (manuel kontrol) arasındaki seçim doğrudan
uygulamanın bellek tüketimi ve kullanıcı deneyimi (UX) arasındaki dengeyi
yansıtır.
19
autoDispose bellek verimliliği sağlarken, keepAlive veya ref.keepAlive() ile belirli
verilerin önbellekte tutulması
19
, kullanıcıların sıkça eriştiği veya anında
görüntülemesi beklenen içerikler (örneğin, son görüntülenen gardırop öğeleri veya
sosyal feed'deki gönderiler) için anında gösterim sağlar. Aura gibi gerçek zamanlı
ve yoğun etkileşimli bir uygulamada, kullanıcıların feed'i veya gardırobu hızlıca
yenilemesi beklenir. Eğer her ekran geçişinde veya filtre değişikliğinde verinin
yeniden yüklenmesi gerekirse, bu takılmalara ve kötü bir kullanıcı deneyimine yol
açabilir. Bu nedenle, kritik ve sık erişilen veriler için stratejik
keepAlive kullanımı, performans ve kullanıcı deneyimi hedeflerini destekler. Bu
durum, sadece teknik bir karar olmaktan öte, ürünün kullanıcı deneyimi hedeflerini
doğrudan etkileyen bir mimari tercihtir.
Veri Kaynağının Orkestrasyonu: Riverpod ile Repository ve Use-Case
Entegrasyonu:
Riverpod, bağımlılık enjeksiyonunu kolaylaştırarak katmanlar arası iletişimi düzenler.
14
Akış genellikle şu şekildedir: UI katmanındaki bir widget,
ref.watch veya ref.read kullanarak bir StateNotifierProvider (örneğin,
wardrobeControllerProvider) dinler. WardrobeController, iş mantığını (örneğin,
filtreleme, sıralama) uygulamak için WardrobeRepository arayüzünü kullanan bir Use
Case'i (örneğin, GetClothingItemsUseCase) çağırır. WardrobeRepositoryImpl (Data
katmanında), veriyi Supabase API'sinden çeker ve ClothingItem modellerine
dönüştürür. Bu veri daha sonra WardrobeController'a, oradan da UI'a akar.
customCategoriesProvider
17 gibi basit veriler için
Provider, authController
17 gibi kimlik doğrulama durumu için
AsyncNotifierProvider veya StateNotifierProvider kullanımı bu orkestrasyonun
örnekleridir.
Kullanılacak Araçlar ve Kütüphaneler:
● flutter_riverpod: Riverpod framework'ünün ana paketi.
● riverpod_generator: Kod üretimi ile provider'ları daha güvenli ve az boilerplate ile
tanımlamak için.
● freezed / built_value: Değişmez (immutable) veri modelleri oluşturmak için. Bu,
StateNotifier ile çalışırken state'in güvenli bir şekilde güncellenmesini sağlar.
18
● flutter_secure_storage: Kullanıcı oturum token'ı (JWT) gibi hassas verilerin güvenli
bir şekilde saklanması için kullanılır.
17
● shared_preferences: hasSeenOnboarding flag'i gibi küçük, hassas olmayan
kullanıcı tercihlerinin saklanması için kullanılır.
17
Örnek Kod Şablonları:
Basit Durum (Onboarding Durumu):
Dart
// lib/features/onboarding/domain/providers/onboarding_providers.dart
@Riverpod(keepAlive: true) // Onboarding durumu uygulamanın genelinde kalıcı olmalı
class HasSeenOnboarding extends _$HasSeenOnboarding {
late final PreferencesService _preferencesService;
@override
bool build() {
_preferencesService = ref.read(preferencesServiceProvider);
return _preferencesService.getBool('hasSeenOnboarding')?? false;
}
void setSeen() {
state = true;
_preferencesService.setBool('hasSeenOnboarding', true);
}
}
// lib/features/onboarding/presentation/onboarding_screen.dart
class OnboardingScreen extends ConsumerWidget {
@override
Widget build(BuildContext context, WidgetRef ref) {
return Scaffold(
body: Center(
child: ElevatedButton(
onPressed: () {
ref.read(hasSeenOnboardingProvider.notifier).setSeen();
// GoRouter ile LoginScreen'e yönlendirme
GoRouter.of(context).go('/login');
},
child: Text('Giriş Yap / Hesap Oluştur'),
),
),
);
}
}
Asenkron Veri (Gardırop Listesi):
Dart
// lib/features/wardrobe/domain/repositories/wardrobe_repository.dart
abstract class WardrobeRepository {
Future<List<ClothingItem>> getItems(int page, int limit, {String? searchTerm, List<String>?
categoryIds, List<String>? seasons, bool showOnlyFavorites = false, String? sortBy});
//... diğer CRUD işlemleri
}
// lib/features/wardrobe/data/repositories/wardrobe_repository_impl.dart
class WardrobeRepositoryImpl implements WardrobeRepository {
final ApiService _apiService; // Dio veya Supabase client
WardrobeRepositoryImpl(this._apiService);
@override
Future<List<ClothingItem>> getItems(int page, int limit, {String? searchTerm, List<String>?
categoryIds, List<String>? seasons, bool showOnlyFavorites = false, String? sortBy}) async {
// API çağrısı ve DTO'dan Domain modeline dönüşüm
final response = await _apiService.get('/wardrobe/items', queryParameters: {
'page': page,
'limit': limit,
'search': searchTerm,
//... diğer filtreler
});
return (response.data as List).map((json) => ClothingItem.fromJson(json)).toList();
}
//...
}
// lib/features/wardrobe/domain/usecases/get_clothing_items_usecase.dart
class GetClothingItemsUseCase {
final WardrobeRepository _repository;
GetClothingItemsUseCase(this._repository);
Future<List<ClothingItem>> call({int page = 1, int limit = 20, String? searchTerm,
Set<String>? categories, Set<String>? seasons, bool showOnlyFavorites = false, String?
sortBy}) {
return _repository.getItems(page, limit, searchTerm: searchTerm, categoryIds:
categories?.toList(), seasons: seasons?.toList(), showOnlyFavorites:
showOnlyFavorites, sortBy: sortBy);
}
}
// lib/features/wardrobe/presentation/controllers/wardrobe_controller.dart
@Riverpod(keepAlive: false) // Genellikle ekranın ömrüyle sınırlı
class WardrobeController extends _$WardrobeController {
late final GetClothingItemsUseCase _getClothingItemsUseCase;
int _currentPage = 1;
bool _hasReachedMax = false;
@override
WardrobeState build() {
_getClothingItemsUseCase = ref.read(getClothingItemsUseCaseProvider);
loadItems(); // İlk yükleme
return WardrobeInitial();
}
Future<void> loadItems({bool isRefresh = false}) async {
if (isRefresh) {
_currentPage = 1;
_hasReachedMax = false;
} else if (_hasReachedMax) {
return;
}
state = WardrobeLoading(); // Yükleniyor durumunu göster
try {
final items = await _getClothingItemsUseCase(
page: _currentPage,
limit: 20,
searchTerm: (state is WardrobeLoaded? (state as WardrobeLoaded).searchTerm :
null), // Mevcut state'ten filtreleri al
//... diğer filtreler
);
_currentPage++;
_hasReachedMax = items.isEmpty; // Daha fazla öğe yoksa
state = WardrobeLoaded(
items: isRefresh? items :),...items],
hasReachedMax: _hasReachedMax,
//... diğer filtre durumları
);
} catch (e, st) {
state = WardrobeError(e.toString());
// Hata izleme aracıyla loglama (Sentry/Crashlytics)
}
}
//... arama, filtreleme, favori değiştirme gibi diğer metotlar
}
Potansiyel Sorunlar ve Çözümleri:
● Gereksiz Yeniden Oluşturmalar (Unnecessary Rebuilds): Provider'ın tüm
state'i değiştiğinde, onu dinleyen tüm widget'lar yeniden oluşturulur. Bu,
performans sorunlarına yol açabilir.
12
○ Çözüm: ref.select kullanarak widget'ların sadece ihtiyaç duydukları belirli bir
state parçacığını dinlemesini sağlamak. const anahtar kelimesini değişmez
(immutable) widget'larda kullanmak, Flutter'a bu widget'ların yeniden
oluşturulmasına gerek olmadığını bildirir, bu da performansı artırır.
6
● Bellek Sızıntıları (Memory Leaks): autoDispose kullanılmayan provider'lar veya
dispose edilmeyen controller'lar/stream'ler bellekte kalabilir.
19
○ Çözüm: Çoğu provider için autoDispose kullanmak. StateNotifier veya
AsyncNotifier içinde açılan stream'ler veya timer'lar için ref.onDispose
kullanarak temizlik yapmak.
19
● Karmaşık Provider Grafiği: Çok sayıda provider'ın iç içe geçmesi, bağımlılıkları
takip etmeyi zorlaştırabilir.
○ Çözüm: Riverpod'un family modifikatörünü kullanarak parametre alan
provider'ları gruplamak. Provider'ları özellik bazında organize etmek
(yukarıdaki dosya yapısı örneği gibi).
Tablo: Riverpod AutoDispose vs. KeepAlive Senaryoları
Senaryo Provider Tipi autoDispose /
keepAlive Kararı
Gerekçe Aura Projesi
Örneği
Kullanıcı Profili
Verisi
AsyncNotifierPr
ovider<User>
keepAlive: true Kullanıcı profil
verisi sıkça
erişilen ve
uygulamanın
genelinde tutarlı
userProfileProvi
der
olması gereken
bir veridir.
Sürekli yeniden
yüklemek yerine
bellekte tutmak
kullanıcı
deneyimini
iyileştirir.
Geçici Form
Durumu
StateNotifierPro
vider<FormState
>
autoDispose Formlar
genellikle tek
kullanımlıktır.
Ekran
kapatıldığında
durumun
temizlenmesi
bellek verimliliği
sağlar.
AddClothingIte
mController'ın
form durumu
Dinamik Liste
Verisi (Filtreli)
AsyncNotifierPr
ovider.family<Lis
t<Item>,
FilterParams>
autoDispose
(varsayılan)
Filtre
parametreleri
değiştikçe yeni
instance'lar
oluşur.
Kullanılmayan
filtre
kombinasyonları
nın bellekte
kalması bellek
sızıntısına yol
açar.
wardrobeContro
llerProvider
(filtreli kıyafet
listesi)
Gerçek
Zamanlı
Sohbet
Mesajları
StreamProvider<
List<ChatMessa
ge>>
ref.keepAlive()
(koşullu)
Sohbet ekranı
aktifken canlı
tutulur. Kullanıcı
sohbetten
çıktığında
otomatik olarak
dispose edilmeli,
ancak son
mesajlar kısaca
önbellekte
tutulabilir.
chatMessagesPr
ovider
Uygulama StateNotifierPro keepAlive: true Uygulama appSettingsProv
Ayarları vider<AppSettin
gs>
ayarları (dil,
tema vb.) global
ve kalıcıdır.
Sürekli erişildiği
için bellekte
tutulması
mantıklıdır.
ider
3. Kod Organizasyonu ve Dosya Yapısı
Bu konu, "1. Katman Ayrımı ve Sorumluluklar" bölümünde "Dosya Yapısı ve
İsimlendirme Örnekleri" ve "Monorepo Kullanımına Dair Mimari Öneri" başlıkları altında
detaylı olarak ele alınmıştır. Aura projesi için özellik odaklı bir dosya yapısı ve monorepo
yaklaşımının avantajları ve dezavantajları bu bölümde açıklanmıştır.
4. Test Edilebilirlik, Performans ve Bakım Kolaylığı
Uygulama geliştirme sürecinde testler, kod kalitesini, güvenilirliğini ve bakım kolaylığını
sağlamak için kritik öneme sahiptir.
6 Aura projesi için kapsamlı bir test stratejisi
benimsenmelidir. Test edilebilirlik ve kod kalitesi prensipleri, başlangıçta ek zaman ve
çaba gerektirse de, uzun vadede hataların erken aşamada yakalanmasını sağlayarak
6
ve kod değişikliklerinde güveni artırarak
6
teknik borcun birikmesini engeller. Özellikle
bir startup'ta hızlı iterasyon ve yeni özelliklerin sürekli eklenmesi, teknik borcun hızla
artmasına neden olabilir. Kapsamlı birim, widget ve entegrasyon testleri
23
ile
Riverpod'un test kolaylığı
14 birleştiğinde, geliştiriciler kodda değişiklik yaparken veya
refactoring yaparken daha az endişe duyar. Bu, geliştirme hızını düşürmek yerine, uzun
vadede daha sürdürülebilir bir hız sağlar. Testler, sadece hataları bulmakla kalmaz, aynı
zamanda kodun beklenen davranışını belgeleyerek
6 yeni geliştiricilerin projeye
adaptasyonunu kolaylaştırır.
Test Stratejileri: Unit, Widget ve Integration Testleri (Riverpod ile Test
Yaklaşımları):
● Unit Testleri:
○ Amaç: Kodun en küçük, izole parçalarını (fonksiyonlar, metotlar, saf Dart
sınıfları) test etmek.
23
İş mantığı (Domain/Application katmanı) için idealdir.
○ Riverpod ile: ProviderContainer.test() kullanarak provider'ları izole bir şekilde
test edebilir ve bağımlılıkları (örneğin repository'leri) mock'layabiliriz.
16
○ Örnek: GetClothingItemsUseCase'in doğru veriyi döndürüp döndürmediğini
test etmek.
● Widget Testleri:
○ Amaç: Tek tek widget'ların kullanıcı arayüzünü ve işlevselliğini doğrulamak,
kullanıcı etkileşimlerine nasıl tepki verdiklerini kontrol etmek.
23
○ Riverpod ile: ProviderScope ile test edilecek widget'ı sarmalayarak Riverpod
provider'larına erişim sağlayabiliriz.
16
tester.pumpWidget, find.text, tester.tap gibi metotlar kullanılır.
23
○ Örnek: ClothingItemCard'ın favori ikonuna tıklandığında durumunun değişip
değişmediğini test etmek.
● Integration Testleri:
○ Amaç: Uygulamanın bir bütün olarak veya birden fazla bileşenin birlikte doğru
çalıştığını doğrulamak. Gerçek kullanıcı akışlarını simüle eder.
23
○ Riverpod ile: IntegrationTestWidgetsFlutterBinding.ensureInitialized() ve
app.main() kullanarak tüm uygulamayı başlatır ve kullanıcı akışlarını test
ederiz.
23
○ Örnek: Kullanıcının giriş yapma, gardırop ekranına gitme ve bir kıyafet ekleme
akışının baştan sona doğru çalıştığını test etmek.
● Test Kapsamı: Özellikle kritik işlevsellik ve kenar durumlar için yüksek test
kapsamı hedeflenmelidir.
23
Performans Optimizasyonu Teknikleri:
Aura'nın kullanıcı etkileşiminin yoğun olduğu, gerçek zamanlı içeriklerin ön planda
olduğu bir mobil uygulama olması nedeniyle, yüksek FPS (saniyede kare sayısı) ve hızlı
yükleme süreleri doğrudan kullanıcı memnuniyetini etkiler. Düşük FPS'nin titrek veya
gecikmeli etkileşimlere yol açtığı ve uygulama terkine neden olabileceği göz önüne
alındığında, performans optimizasyonu sadece teknik bir gereklilik değil, aynı zamanda
kullanıcı tutma ve olumlu yorumlar gibi iş metrikleri üzerinde doğrudan bir etkiye
sahiptir.
13
● Widget Yeniden Oluşturma Optimizasyonları:
○ const Anahtar Kelimesi: Değişmez (immutable) widget'lar için const
constructor'lar kullanmak, Flutter'a bu widget'ların yeniden oluşturulmasına
gerek olmadığını bildirir, bu da performansı önemli ölçüde artırır.
6
○ ConsumerWidget/ConsumerStatefulWidget ve ref.select: Riverpod ile
widget'ların sadece ihtiyaç duydukları belirli bir state parçacığını dinlemesini
sağlayarak gereksiz tüm widget ağacının yeniden oluşturulmasını engeller.
22
○ RepaintBoundary: Kullanıcı arayüzünün belirli bölümlerinin diğerlerinden
bağımsız olarak yeniden çizilmesini sağlayarak gereksiz yeniden çizim alanını
sınırlar.
6
○ Küçük ve Yeniden Kullanılabilir Widget'lar: Widget'ları küçük ve tek
sorumluluğa sahip parçalara ayırmak, yeniden oluşturma maliyetini düşürür ve
yönetimi kolaylaştırır.
6
● Büyük Liste Yönetimi (ListView.builder, Pagination):
○ ListView.builder veya GridView.builder gibi "lazy loading" widget'ları, yalnızca
görünürdeki öğeleri oluşturarak bellek kullanımını ve yükleme süresini optimize
eder.
12
○ Pagination (Sayfalama): Büyük veri setlerini (örneğin, sosyal feed, gardırop
listesi) sunucudan parça parça çekmek (infinite_scroll_pagination paketi
gibi).
12 Kullanıcı listenin sonuna yaklaştığında yeni veriler yüklenmelidir.
17
○ itemExtent: ListView.builder'da sabit öğe yükseklikleri tanımlamak, kaydırma
performansını artırır.
12
● Görsel Önbellekleme ve Yükleme Optimizasyonları:
○ cached_network_image: Ağdan yüklenen görselleri önbelleğe almak için
kullanılır, bu da tekrarlayan yüklemeleri önler ve performansı artırır.
12
○ Görsel Boyutlandırma ve Sıkıştırma: Sunucuya yüklemeden önce görsellerin
boyutunu küçültmek ve sıkıştırmak (ImageUploadService içinde).
17 Cihazda
gösterilecek boyuta uygun görseller kullanmak.
21
○ Doğru Görsel Formatı: WebP gibi daha verimli formatları tercih etmek (daha
küçük dosya boyutu, daha hızlı render).
25
○ Placeholder ve Hata Widget'ları: Görsel yüklenirken veya hata oluştuğunda
kullanıcıya geri bildirim sağlamak (CachedNetworkImage'in placeholder ve
errorWidget parametreleri).
17
○ precachelmage: Kritik görselleri önceden belleğe yükleyerek UI'ın daha hızlı
görünmesini sağlamak.
17
Bellek Yönetimi ve Memory Leak Önleme Teknikleri:
Dart'ın çöp toplama (garbage collection) mekanizması olsa da, yanlış kullanımlar bellek
sızıntılarına yol açabilir.
21
● Kaynakların Doğru Şekilde dispose() Edilmesi: TextEditingController,
AnimationController, StreamSubscription gibi kaynakların StatefulWidget'ların
dispose() metotlarında veya Riverpod'da ref.onDispose ile serbest bırakıldığından
emin olun.
21
● DevTools ile Bellek Profilleme: Flutter DevTools'un "Memory" sekmesi
kullanılarak bellek sızıntıları ve yüksek bellek tüketimi tespit edilebilir.
12
● Gereksiz Veri Tutmaktan Kaçınma: Kullanılmayan veya geçici verilerin bellekte
gereksiz yere tutulmasını önlemek.
Bakım Kolaylığı için Kod Kalitesi Standartları:
● Linter Kuralları: flutter_lints gibi araçlarla tutarlı kodlama standartları ve en iyi
uygulamalar zorunlu kılınmalıdır.
6 Özel linter kuralları tanımlanabilir.
● Kod İnceleme (Code Review) Süreçleri: Ekip üyeleri arasında düzenli kod
incelemeleri, hataların erken tespit edilmesini, kod kalitesinin artırılmasını ve bilgi
paylaşımını teşvik eder.
6
● Test Kapsamı Hedefleri: Özellikle kritik iş mantığı için belirli bir test kapsamı
yüzdesi hedeflenmelidir.
● CI Pipeline'da Quality Gate'ler: Otomatik testlerin ve linter kontrollerinin CI/CD
sürecine dahil edilmesi, kodun ana branch'e birleşmeden önce belirli kalite
standartlarını karşılamasını sağlar.
23
Potansiyel Sorunlar ve Çözümleri:
● UI Takılmaları (Jank): Ağır hesaplamaların veya senkronize API çağrılarının ana UI
thread'ini bloke etmesi.
13
○ Çözüm: Asenkron operasyonlar (async/await) kullanmak ve yoğun
hesaplamaları compute fonksiyonu veya Isolate'ler aracılığıyla arka plan
thread'lerine taşımak.
12
● Yüksek Bellek Tüketimi: Büyük görsellerin veya veri setlerinin optimize edilmeden
yüklenmesi.
12
○ Çözüm: Yukarıda belirtilen görsel ve liste optimizasyon tekniklerini uygulamak,
DevTools ile düzenli profil çıkarma.
12
Tablo: Flutter Test Türleri ve Odak Alanları
Test Türü Odak Alanı Riverpod
Entegrasyonu
Örnek Senaryo (Aura)
Unit Testleri İş mantığı, bireysel
fonksiyonlar/metotlar,
veri dönüşümleri.
ProviderContainer.tes
t() ile provider'lar
izole test edilir,
bağımlılıklar
mock'lanır.
AuthService.login()
metodunun doğru
JWT token'ı
döndürüp
döndürmediği.
Widget Testleri Tekil UI bileşenleri,
widget'ların kullanıcı
etkileşimlerine
tepkisi, UI durumu.
ProviderScope ile
widget sarmalanır,
tester ile etkileşim
simüle edilir.
LoginScreen'deki
e-posta ve şifre giriş
alanlarının doğru
çalışıp çalışmadığı,
buton tıklamasıyla
loading state'in
görünmesi.
Integration Testleri Uygulamanın uçtan
uca akışları, birden
fazla bileşenin
entegrasyonu, gerçek
kullanıcı senaryoları.
IntegrationTestWidge
tsFlutterBinding.ensu
reInitialized(),
app.main() ile tüm
uygulama başlatılır.
Kullanıcının başarılı
bir şekilde giriş yapıp
HomeScreen'e
yönlendirilmesi ve
WardrobeHomeScree
n'in yüklenmesi.
5. Katmanlar Arası Veri Akışı
Aura projesinin çeşitli veri etkileşim ihtiyaçlarını en verimli şekilde karşılaması için hibrit
bir API stratejisi benimsenmiştir. Bu yaklaşım, tek bir API paradigmasına bağlı kalmak
yerine, her birinin güçlü yönlerini kullanarak performans ve esneklik arasında optimal
bir denge kurar. GraphQL, karmaşık ve iç içe geçmiş veri yapılarını tek bir istekte
verimli bir şekilde çekmek için idealdir, bu da ağ isteklerinin sayısını azaltır.
26 REST ise,
belirli bir kaynağın durumunu değiştiren eylemler için basit ve anlaşılır bir yöntem
sunar.
28 Gerçek zamanlılık için WebSocket/Supabase Realtime kullanımı, anlık
etkileşimler (mesajlaşma, bildirimler) için düşük gecikme sağlar.
29 Bu hibrit yaklaşım,
hem geliştirme kolaylığı hem de uygulamanın performansı ve ölçeklenebilirliği
açısından önemli avantajlar sunar.
Detaylı Akış Senaryoları:
● Senaryo 1: Kullanıcı Feed Yüklerken (Okuma İşlemi - GraphQL):
○ Akış: UI (SocialFeedScreen) → Application (SocialFeedController) → Domain
(GetSocialFeedUseCase) → Data (SocialFeedRepositoryImpl) → API
(GraphQL Client) → Backend (Supabase PostgREST/pg_graphql).
○ Açıklama:
1. SocialFeedScreen (UI Katmanı), kullanıcı feed'i yenilediğinde veya ilk
yüklendiğinde SocialFeedController'daki (Presentation Katmanı)
loadPosts() metodunu çağırır.
2. SocialFeedController, GetSocialFeedUseCase'i (Application/Domain
Katmanı) çağırır. Bu Use Case, feed'in filtrelenmesi, sıralanması gibi iş
mantığını içerir.
3. GetSocialFeedUseCase, veriyi almak için SocialFeedRepository arayüzünü
(Domain Katmanı) kullanır.
4. SocialFeedRepositoryImpl (Data Katmanı), GraphQLClient aracılığıyla
Supabase'in GraphQL API'sine (Backend Katmanı) bir sorgu gönderir.
GraphQL, karmaşık ve iç içe geçmiş veri yapılarını tek bir istekte verimli bir
şekilde çekmek için idealdir.
26
5. Supabase, RLS (Row Level Security) politikalarını uygulayarak kullanıcının
erişim yetkisine göre veriyi filtreler.
7
6. Alınan veri (JSON), SocialFeedRepositoryImpl tarafından SocialPost
Domain modellerine dönüştürülür ve zincir boyunca
SocialFeedController'a geri döner.
7. SocialFeedController, bu veriyi SocialFeedState'e (Riverpod AsyncValue
içinde) kaydeder ve SocialFeedScreen'in UI'ı güncellenir.
● Senaryo 2: Kullanıcı Ayarlarını Güncellerken (Yazma İşlemi - REST):
○ Akış: UI (PrivacySettingsScreen) → Application (UserProfileController) →
Domain (UpdateUserSettingsUseCase) → Data (UserRepositoryImpl) → API
(REST Client) → Backend (FastAPI).
○ Açıklama:
1. PrivacySettingsScreen (UI Katmanı), kullanıcının bir ayar switch'ini
değiştirmesi gibi bir etkileşimde UserProfileController'daki (Presentation
Katmanı) updateSetting() metodunu çağırır.
2. UserProfileController, UpdateUserSettingsUseCase'i (Application/Domain
Katmanı) çağırır. Bu Use Case, ayar değişikliklerinin doğrulanması gibi iş
mantığını içerebilir.
3. UpdateUserSettingsUseCase, UserRepository arayüzünü (Domain
Katmanı) kullanarak ayarı kalıcı hale getirme isteğini başlatır.
4. UserRepositoryImpl (Data Katmanı), RESTClient aracılığıyla FastAPI
backend'ine (Backend Katmanı) bir PATCH veya PUT isteği gönderir. REST,
belirli bir kaynağın durumunu değiştiren eylemler için basit ve anlaşılır bir
yöntem sunar.
5. FastAPI, gelen isteği işler, gerekli doğrulamaları yapar ve Supabase
veritabanında ilgili kullanıcı ayarlarını günceller. FastAPI, özel iş mantığı ve
AI servisleri için kullanılır.
6. İşlem sonucu (başarı/hata), zincir boyunca UserProfileController'a geri
döner.
7. UserProfileController, UI'da "iyimser güncelleme" (optimistic update)
yaparak ayarın hemen değiştiğini gösterir ve arka planda sunucuya
kaydeder. Eğer kaydetme başarısız olursa, UI eski haline döner ve
kullanıcıya hata mesajı gösterilir.
17
Gerçek Zamanlı Senaryolar için Örnek Akışlar:
Gerçek zamanlı özelliklerin entegrasyonu, uygulamanın güvenlik yüzeyini genişletir. Bu
nedenle, geliştirme sürecinin başından itibaren güvenlik (özellikle RLS) birincil öncelik
olmalı ve düzenli olarak denetlenmelidir. Bu, Aura'nın kullanıcı verilerini koruma ve
güvenilir bir platform olma taahhüdünü yansıtır. Supabase Realtime'ın kullanımıyla
birlikte, Broadcast authorization RLS policies
30 ve genel RLS
7 vurgulanması, gerçek
zamanlı veri akışlarında yetkilendirmenin kritik olduğunu gösterir.
● Senaryo 3: Gerçek Zamanlı Mesajlaşma (Supabase Realtime):
○ Akış: UI (PreSwapChatScreen) → Application (PreSwapChatController) →
Data (MessagingRepositoryImpl) → Supabase Realtime (WebSocket).
○ Açıklama:
1. PreSwapChatScreen (UI Katmanı), yeni bir mesaj gönderildiğinde
PreSwapChatController'daki (Presentation Katmanı) sendMessage()
metodunu çağırır.
2. PreSwapChatController, MessagingRepository arayüzünü (Domain
Katmanı) kullanarak mesajı gönderme isteğini başlatır.
3. MessagingRepositoryImpl (Data Katmanı), Supabase Realtime servisine
(WebSocket üzerinden) mesajı gönderir. Supabase Realtime, Broadcast
veya Postgres Changes mekanizmalarıyla çalışabilir.
29
4. Mesaj veritabanına kaydedildiğinde, Supabase Realtime, ilgili sohbet
kanalına abone olan tüm istemcilere yeni mesajın geldiğini bildirir.
29
5. PreSwapChatScreen, StreamProvider aracılığıyla bu kanalı dinler ve yeni
mesaj geldiğinde UI'ı otomatik olarak günceller.
6. Güvenlik: Mesajlaşma için RLS politikaları, kullanıcıların yalnızca dahil
oldukları sohbet konularına abone olabilmesini sağlamalıdır.
7
● Senaryo 4: Gerçek Zamanlı Bildirim Güncelleme (Supabase Realtime / FCM):
○ Akış: Backend (FastAPI) → Supabase Realtime (Postgres Changes/Broadcast)
/ Firebase Cloud Messaging → Flutter App.
○ Açıklama:
1. Bir kullanıcı bir gönderiyi beğendiğinde veya yorum yaptığında, FastAPI
backend'i (özel iş mantığı) Supabase veritabanındaki ilgili tabloyu
günceller.
2. Supabase'deki bir TRIGGER veya Postgres Changes yayını (publication),
bu veritabanı değişikliğini algılar.
30
3. Supabase Realtime, bu değişikliği ilgili kullanıcının cihazına WebSocket
üzerinden gönderir (uygulama açıksa).
4. Aynı zamanda, FastAPI veya bir Supabase Edge Function, Firebase Cloud
Messaging (FCM) servisini kullanarak ilgili kullanıcıya anlık bildirim (push
notification) gönderebilir.
32 Bu, uygulama kapalıyken veya arka plandayken
bile bildirimlerin ulaşmasını sağlar.
5. Flutter uygulaması, FCM mesajını alır ve local_notifications paketi gibi bir
araçla kullanıcıya bildirimi gösterir.
6. Notification Permission Handling: Uygulama başlatıldığında veya
bildirim gerektiren bir özelliğe ilk kez erişildiğinde, kullanıcının bildirim
izinleri kontrol edilmeli ve gerekirse istenmelidir.
7. Güvenlik: RLS ve JWT kimlik doğrulaması, yalnızca yetkili kullanıcıların ilgili
bildirimleri almasını sağlar.
7
6. Use-Case Senaryoları
Aura projesinin dinamik ve etkileşimli yapısı göz önüne alındığında, belirli gerçek dünya
senaryoları üzerinden mimari uygulamaların detaylandırılması, pratik rehberlik
sağlayacaktır.
● Senaryo 1: Kullanıcı Bir Ürünü Beğendiğinde Event Loglama Akışı
○ Amaç: Kullanıcının bir ClothingItemCard'daki kalp ikonuna tıklayarak bir
kıyafeti beğenmesi durumunda, bu eylemi hem backend'de kalıcı hale
getirmek hem de analitik için loglamak.
○ Akış:
1. UI (WardrobeHomeScreen/ClothingItemCard): Kullanıcı kalp ikonuna
tıklar.
2. Presentation (WardrobeController): toggleFavorite(itemId) metodu
çağrılır. Bu metod, UI'da hemen "iyimser güncelleme" yaparak kalp
ikonunun durumunu değiştirir (örneğin, içi dolu hale gelir).
3. Application/Domain (ToggleFavoriteUseCase): WardrobeController,
ToggleFavoriteUseCase'i çağırır. Bu Use Case, iş kuralını (örneğin,
kullanıcının zaten beğenip beğenmediğini kontrol etme) uygulayabilir.
4. Data (WardrobeRepositoryImpl): ToggleFavoriteUseCase,
WardrobeRepository'nin toggleFavorite(itemId) metodunu çağırır.
WardrobeRepositoryImpl, FastAPI backend'ine (REST API) bir PATCH/POST
isteği gönderir.
5. Backend (FastAPI): FastAPI, isteği alır, kullanıcının JWT token'ını doğrular
(kimlik doğrulama) ve Supabase veritabanında ilgili kıyafetin favori
durumunu günceller. RLS politikaları, kullanıcının yalnızca kendi favorilerini
yönetebilmesini sağlar.
6. Analitik (Firebase Analytics): WardrobeController veya
ToggleFavoriteUseCase içinde, AnalyticsService.logEvent('item_favorited',
{'item_id': itemId, 'category': itemCategory}) gibi bir çağrı yapılır. Bu,
Firebase Analytics'e (veya Amplitude gibi başka bir analitik servisine)
event'i gönderir.
17 Bu event, kullanıcının davranışını anlamak ve
kişiselleştirilmiş öneriler sunmak için kullanılır.
7. Hata Yönetimi: Eğer backend çağrısı başarısız olursa, WardrobeController
UI'daki iyimser güncellemeyi geri alır ve kullanıcıya bir hata mesajı
(snackbar) gösterir.
● Senaryo 2: Offline Durumda Yapılan İşlemlerin Senkronizasyonu
○ Amaç: Kullanıcının internet bağlantısı olmadığında (offline) yaptığı belirli
işlemlerin (örneğin, bir kombini favorilere ekleme, bir kıyafeti silme) yerel
olarak kaydedilmesi ve internet bağlantısı geri geldiğinde otomatik olarak
senkronize edilmesi.
○ Akış:
1. UI: Kullanıcı offline iken bir kıyafeti favorilere ekler.
2. Presentation (WardrobeController): toggleFavorite(itemId) çağrılır.
3. Application/Domain (ToggleFavoriteUseCase): Mevcut ağ durumu
kontrol edilir (ConnectivityService).
4. Data (WardrobeRepositoryImpl):
■ Offline Durumda: WardrobeRepositoryImpl, işlemi doğrudan
backend'e göndermek yerine, yerel bir "bekleyen değişiklikler"
kuyruğuna (örneğin, Hive veya Sqflite ile) kaydeder. İlgili kıyafetin yerel
cache'teki durumu güncellenir. Kullanıcıya işlemin offline'da
kaydedildiği bilgisi verilebilir.
■ Online Durumda: ConnectivityService, internet bağlantısının geri
geldiğini algılar.
5. Arka Plan Senkronizasyonu: Uygulama tekrar online olduğunda
(AppLifecycleListener ile resume durumu veya periyodik kontrol),
SyncService (veya WardrobeController içindeki bir metot) devreye girer.
6. SyncService, bekleyen değişiklikler kuyruğundaki işlemleri alır ve sırayla
FastAPI backend'ine gönderir (REST API).
7. Çakışma Yönetimi: Eğer senkronizasyon sırasında backend'de bir
çakışma (conflict) oluşursa (örneğin, aynı kıyafet başka bir cihazdan
silinmişse), backend uygun bir hata kodu döndürür. Uygulama, bu
çakışmayı yönetmeli (örneğin, kullanıcıya bilgi vererek manuel çözüm
sunma veya son değişikliği kabul etme).
8. Veri Bütünlüğü: Başarılı senkronizasyondan sonra, yerel kuyruktaki işlem
temizlenir ve yerel cache güncellenir.
○ Supabase ile Offline Sync Mekanizması: Supabase'in kendisi Firebase gibi
yerleşik bir offline senkronizasyon mekanizmasına sahip değildir.
35 Bu nedenle,
"offline-first" yetenekleri için
Hive, sqflite gibi yerel veritabanları veya Replicache, WatermelonDB gibi 3.
parti senkronizasyon kütüphaneleri ile özel bir çözüm geliştirilmesi
gerekmektedir.
35 Bu durum, uygulamanın offline yetenekleri için özel bir
geliştirme (yerel veritabanı, senkronizasyon kuyruğu, çakışma çözümü)
gerektireceği anlamına gelir. Bu ek çaba, uygulamanın internet erişiminin
seyrek olduğu veya kullanıcının temel işlevselliğe her zaman erişmek istediği
senaryolarda kritik bir rekabet avantajı sağlar. Offline-first, sadece teknik bir
özellik değil, aynı zamanda kullanıcı deneyimi ve pazar stratejisi açısından
önemli bir farklılaştırıcıdır.
● Senaryo 3: Gerçek Zamanlı Bildirimlerin Kullanıcıya Gösterilmesi
○ Amaç: Kullanıcının bir kombini beğenilmesi veya bir sohbet mesajı alması gibi
durumlarda anlık bildirimlerin (hem uygulama içi hem de push notification)
gösterilmesi.
○ Akış:
1. Backend (FastAPI/Supabase Trigger): Bir kullanıcı bir kombini
beğendiğinde veya bir mesaj gönderdiğinde, FastAPI bu durumu işler ve
Supabase veritabanını günceller.
2. Supabase Realtime (Postgres Changes/Broadcast): İlgili veritabanı
tablosundaki değişiklikler (örneğin, likes tablosuna yeni bir beğeni
eklendiğinde veya messages tablosuna yeni bir mesaj eklendiğinde)
Supabase Realtime tarafından algılanır.
29
3. WebSocket Bağlantısı: Kullanıcının uygulaması açıksa ve ilgili kanala
abone ise (örneğin, user_notifications kanalı veya chat_thread_<id> kanalı),
Realtime servisi WebSocket üzerinden bu değişikliği istemciye anında iletir.
4. Flutter Uygulaması (StreamProvider): Uygulama içinde, StreamProvider
kullanarak bu Realtime kanalını dinleyen bir NotificationController veya
ChatController bulunur.
5. Uygulama İçi Bildirim: NotificationController, gelen Realtime verisini işler
ve UI'da bir Snackbar, Toast veya Dialog göstererek kullanıcıya anlık geri
bildirim sağlar. Örneğin, "X kullanıcısı kombininizi beğendi!"
6. Push Notification (Firebase Cloud Messaging - FCM): Eğer kullanıcı
uygulamada değilse veya uygulama arka plandaysa, FastAPI (veya bir
Edge Function) aynı zamanda Firebase Cloud Messaging (FCM) API'sini
çağırarak kullanıcıya bir push notification gönderir.
32
7. Notification Permission Handling: Uygulama başlatıldığında veya
bildirim gerektiren bir özelliğe ilk kez erişildiğinde, kullanıcının bildirim
izinleri kontrol edilmeli ve gerekirse istenmelidir.
8. Güvenlik: RLS ve JWT kimlik doğrulaması, yalnızca yetkili kullanıcıların ilgili
bildirimleri almasını sağlar.
7
● Senaryo 4: Çoklu Dil Desteğinin Dinamik Olarak Yönetilmesi
○ Amaç: Kullanıcının uygulama dilini ayarlar ekranından değiştirebilmesi ve UI'ın
anında güncellenmesi, ayrıca sağdan sola (RTL) dil desteği.
○ Akış:
1. UI (SettingsScreen/LanguageSettingsScreen): Kullanıcı "Ayarlar"
ekranında dil seçeneğini değiştirir.
2. Presentation (AppSettingsController): changeLanguage(newLocale)
metodu çağrılır.
3. Application/Domain (UpdateLanguageSettingUseCase):
AppSettingsController, UpdateLanguageSettingUseCase'i çağırır. Bu Use
Case, seçilen dilin geçerliliğini kontrol edebilir.
4. Data (PreferencesService): UpdateLanguageSettingUseCase,
PreferencesService (shared_preferences) kullanarak seçilen dil tercihini
yerel olarak kaydeder.
5. Riverpod Locale Observer: appLocalizationsProvider (veya benzeri bir
provider) bir WidgetsBindingObserver (örneğin, _LocaleObserver)
kullanarak cihazın veya uygulamanın locale değişikliklerini dinler.
38
6. UI Güncellemesi: appLocalizationsProvider, locale değiştiğinde yeniden
oluşturulur ve onu dinleyen tüm metin widget'ları otomatik olarak yeni dile
göre güncellenir.
38
7. RTL Desteği: Flutter'ın yerleşik RTL desteği (Directionality widget'ı ve
TextDirection.rtl) kullanılır. MaterialApp'in localizationsDelegates ve
supportedLocales özellikleri doğru yapılandırılmalıdır.
39 Dinamik metinler
için
.arb dosyaları kullanılır.
39
7. Performans ve Kapasite Tahminleri
Performans ve kapasite tahminleri, Aura projesinin büyüme hedefleri doğrultusunda
teknik altyapının nasıl adapte edilmesi gerektiğini anlamak için kritik öneme sahiptir.
Supabase'in PostgreSQL tabanlı olması
36
, karmaşık sorgular, join'ler ve ilişkisel veri için
güçlü bir temel sunarken, analitik için optimize edilmediği
42 ve satır odaklı bir
veritabanı olduğu uyarısı, özellikle
WardrobeAnalyticsScreen gibi özellikler için büyük veri ve gerçek zamanlı analitik
ihtiyaçlarında ek çözümler (örneğin, Tinybird gibi ayrı bir analitik backend)
gerektirebileceğini göstermektedir.
42 Bu, mimari kararların her zaman bir denge
meselesi olduğunu ve belirli niş ve yoğun veri işleme gereksinimleri için ek, özelleşmiş
çözümlerin düşünülmesi gerektiğini ortaya koyar.
Flutter UI Performans Metrikleri ve Hedefleri:
● FPS (Frames Per Second): Hedef, çoğu senaryoda 60 FPS'i tutarlı bir şekilde
korumaktır.
13 Daha yeni cihazlarda 90 Hz veya 120 Hz ekranlar için 90/120 FPS
hedeflenebilir, ancak 60 FPS akıcı bir deneyim için temeldir.
13
○ Ölçüm: Flutter DevTools'un "Performance Overlay" ve "Performance" sekmesi
kullanılarak FPS, kare oluşturma süreleri (frame rendering times) ve atlanan
kareler (dropped frames) izlenmelidir.
13
● Soğuk Başlangıç Süresi (Cold Startup Time): Uygulamanın sıfırdan başlatılma
süresi. Kullanıcı deneyimi için kritik bir metriktir. Hedef, <2 saniye olmalıdır.
● Sıcak Başlangıç Süresi (Warm Startup Time): Uygulamanın arka plandan ön
plana gelme süresi. Soğuk başlangıçtan daha hızlı olmalıdır.
24
● CPU Kullanımı: Uygulamanın CPU kaynaklarını ne kadar kullandığı. Verimli kod,
daha düşük CPU yükü ve daha iyi pil ömrü sağlar.
24
● Bellek Kullanımı: Uygulamanın tükettiği RAM miktarı. Düşük bellek kullanımı,
özellikle sınırlı kaynaklara sahip cihazlarda çökmeleri ve yavaşlamaları önler.
21
○ Hedef: Bellek sızıntılarını önlemek ve makul bir bellek ayak izi sağlamak (örn.
250 MB görsel önbellek limiti).
12
● Widget Yeniden Oluşturma Performansı: Widget'ların durum değişikliklerine ne
kadar verimli tepki verdiği. Gereksiz yeniden oluşturmalar minimize edilmelidir.
24
● Kaydırma Performansı: Listeler veya diğer kaydırılabilir widget'larda akıcılık ve
yanıt verme. Akıcı kaydırma, kullanıcı deneyimini artırır.
24
● Hata Oranı: Çalışma zamanı hatalarının veya çökmelerin sıklığı. Daha düşük hata
oranı, daha kararlı ve güvenilir bir uygulamayı gösterir.
24
Riverpod Cache Bellek Limitleri ve Optimizasyon Önerileri:
Riverpod'ın kendisi doğrudan bir "cache bellek limiti" sunmaz; daha ziyade
autoDispose mekanizmasıyla kullanılmayan state'i otomatik olarak temizler.
19
● Optimizasyon Önerileri:
○ Akıllı autoDispose Kullanımı: Çoğu provider için autoDispose varsayılan
olarak kullanılmalı.
○ ref.keepAlive() ile İnce Ayar: Yalnızca kritik, sık erişilen ve anında
gösterilmesi gereken veriler için ref.keepAlive() kullanılmalı. Örneğin, bir
kullanıcının gardırobunda en son görüntülediği 4-5 günün verisi gibi.
20
○ ListView.builder ve cacheExtent: Büyük listelerde, ListView.builder'ın
cacheExtent özelliğini artırarak, görünür alanın dışındaki öğelerin de bir miktar
önbellekte tutulmasını sağlayabiliriz. Bu, hızlı kaydırmalarda verinin yeniden
yüklenmesini önler.
20
○ Görsel Önbelleği Yönetimi: cached_network_image gibi kütüphanelerin
kendi cache yönetim mekanizmaları vardır. Bunların boyut limitleri ve
temizleme stratejileri (örn. 250 MB üst limit) yapılandırılmalıdır.
12
○ Bellek Profilleme: Düzenli olarak Flutter DevTools ile bellek profillemesi
yaparak, gereksiz bellek tüketimini veya sızıntılarını tespit etmek ve gidermek.
12
Ölçeklenebilirlik Planlaması: 1K, 10K, 100K Kullanıcı için Flutter Uygulama
Mimarisi Adaptasyonları:
Flutter uygulaması, backend'in ölçeklenebilirliği ile birlikte ölçeklenir. Kullanıcı arayüzü
performansı, backend'in yanıt süresi ve veri hacmiyle doğrudan ilişkilidir. Supabase'in
kullanım tabanlı fiyatlandırma modeli
43
, başlangıçta uygun maliyetli olsa da,
büyüdükçe maliyetlerin artabileceği anlamına gelir.
36 Özellikle aylık aktif kullanıcı sayısı
(MAU), veritabanı boyutu, bant genişliği ve compute kredileri
44 gibi metrikler,
doğrudan maliyetleri etkiler. Bu, teknik liderlerin sadece teknik ölçeklenebilirlik
planlaması yapmakla kalmayıp, aynı zamanda maliyet tahminleri ve bütçe yönetimi
konusunda da proaktif olmaları gerektiğini gösterir.
● 1K Kullanıcı (MVP/Erken Aşama):
○ Mevcut mimari (Clean Architecture, Riverpod, Supabase, FastAPI) bu kullanıcı
sayısını rahatlıkla kaldıracaktır.
40
○ Odak noktası: Temel özelliklerin istikrarlı çalışması, hızlı iterasyon, kullanıcı geri
bildirimlerini toplama.
○ Supabase'in ücretsiz veya Pro planı yeterli olacaktır.
43
● 10K Kullanıcı (Büyüme Aşama):
○ Backend: Supabase'in Pro veya Team planlarına geçiş, daha yüksek bağlantı
limitleri ve daha fazla compute kaynağı sağlayacaktır.
40 FastAPI için daha güçlü
sunucular veya container'lar (Docker) gerekebilir.
○ Veritabanı Optimizasyonu: Supabase (PostgreSQL) üzerinde sorgu
performansını iyileştirmek için indeksleme (CREATE INDEX) ve potansiyel
olarak basit partitioning (PARTITION BY RANGE) stratejileri
değerlendirilmelidir.
42
○ API Optimizasyonu: Daha fazla caching (CDN kullanımı, API yanıt
önbellekleme) ve API rate limiting (FastAPI'de) uygulanabilir.
○ Flutter Tarafı: Lazy loading (pagination) ve görsel optimizasyonları daha da
önem kazanır. autoDispose kararları daha titizlikle incelenmelidir.
● 100K+ Kullanıcı (Büyük Ölçekli Uygulama):
○ Backend (Supabase/FastAPI):
■ Veritabanı Sharding: Supabase'in PostgreSQL tabanı, çok büyük veri
setleri için veritabanı sharding (yatay bölümlendirme) ihtiyacını ortaya
çıkarabilir.
42 Bu, veriyi birden fazla sunucuya dağıtarak ölçeklenebilirliği
artırır. Ancak sharding, ek karmaşıklık getirir ve dikkatli planlama
gerektirir.
46
■ Load Balancing: FastAPI servisleri için yük dengeleyiciler (load balancers)
kullanılarak gelen trafik birden fazla sunucuya dağıtılmalıdır.
■ CDN (Content Delivery Network): Görsel ve statik içeriklerin (CSS, JS)
CDN üzerinden sunulması, yükleme sürelerini azaltır ve backend üzerindeki
yükü hafifletir.
■ Read Replicas: Yoğun okuma trafiği olan tablolar için PostgreSQL read
replica'ları kullanılabilir.
42
○ Realtime/WebSocket: Supabase Realtime'ın 10K-30K+ eş zamanlı istemciyi
kaldırabildiği belirtiliyor.
36 100K+ kullanıcı için daha gelişmiş Realtime çözümleri
(örn. özel WebSocket sunucuları veya daha yüksek kapasiteli Supabase
planları) veya sharding stratejileri gerekebilir.
36
○ Flutter Tarafı: Uygulama içi önbellekleme stratejileri (Hive, Shared
Preferences ile offline-first) daha da kritik hale gelir. Performans izleme ve
hata yönetimi (Sentry, Crashlytics) sürekli ve proaktif olmalıdır.
Potansiyel Performans Engelleri ve Çözümleri:
● Engel: Veritabanı sorgularının yavaşlaması (özellikle karmaşık join'ler veya büyük
veri setleri üzerinde).
42
○ Çözüm: Kapsamlı indeksleme, sorgu optimizasyonu, materialized view'lar
(önceden hesaplanmış özetler) ve gerekirse veritabanı sharding.
42
● Engel: API yanıt sürelerinin artması.
24
○ Çözüm: Backend optimizasyonu (FastAPI), caching (CDN, API Gateway), load
balancing.
● Engel: Çok sayıda eş zamanlı bağlantı nedeniyle backend'in tıkanması.
40
○ Çözüm: Supabase'de daha yüksek compute add-on'ları, connection pooling
(Supavisor), istemci tarafında bağlantı limitlerinin yapılandırılması.
44
Tablo: Flutter Uygulama Performans Metrikleri ve Hedefleri
Metrik Tanım Hedef Ölçüm Aracı Aura Projesi İçin
Önemi
FPS
(Kare/Saniye)
Uygulamanın bir
saniyede ekrana
çizdiği kare
sayısı.
≥ 60 FPS (çoğu
senaryoda)
Flutter DevTools
(Performance
Overlay), Sentry
Akıcı
animasyonlar,
hızlı kullanıcı
etkileşimi, genel
kullanıcı
memnuniyeti.
Soğuk
Başlangıç
Süresi
Uygulamanın
sıfırdan
başlatılma
süresi.
< 2 saniye Flutter DevTools,
Firebase
Performance
Monitoring
İlk izlenim,
kullanıcı tutma.
Bellek
Kullanımı
Uygulamanın
RAM tüketimi.
Sızıntı yok,
makul seviye
(örn. <250MB
cache)
Flutter DevTools
(Memory
Profiler)
Düşük-uç
cihazlarda
stabilite, çökme
önleme.
Ağ Gecikmesi API çağrılarının
yanıt süresi.
Okuma:
<200ms, Yazma:
<500ms
Flutter DevTools
(Network tab),
Sentry
Hızlı veri
yükleme, anlık
geri bildirim.
Widget
Yeniden
Oluşturma
Widget'ların
gereksiz yere
yeniden
oluşturulma
sıklığı.
Minimize
edilmeli
Flutter DevTools
(Track Widget
Builds)
UI akıcılığı, CPU
verimliliği.
Kaydırma
Akıcılığı
Listeler ve
kaydırılabilir
alanlarda
takılma
olmaması.
Akıcı Flutter DevTools
(Performance
Overlay)
Sosyal feed ve
gardırop gibi
yoğun listelerde
kullanıcı
deneyimi.
Sonuç
Aura projesi için önerilen Flutter mimarisi, Clean Architecture prensiplerini Riverpod
v2'nin güçlü durum yönetimi yetenekleriyle birleştirerek, ölçeklenebilir, sürdürülebilir ve
yüksek performanslı bir temel sunmaktadır. Özellik odaklı dosya yapısı ve monorepo
yaklaşımı, geliştirme hızını ve ekip işbirliğini artırırken, test odaklı geliştirme ve sürekli
performans optimizasyonu, uygulamanın uzun vadeli kalitesini ve kullanıcı
memnuniyetini garanti altına alacaktır. Özellikle gerçek zamanlı etkileşimler ve yoğun
veri akışları için hibrit API stratejisi ve Supabase Realtime kullanımı, Aura'nın dinamik
sosyal moda uygulaması hedeflerine ulaşmasında kritik rol oynayacaktır. Gelecekteki
büyüme ve kullanıcı sayısındaki artışla birlikte ortaya çıkabilecek potansiyel
performans ve maliyet engelleri için şimdiden planlama yapılması, projenin başarılı bir
şekilde ölçeklenmesini sağlayacaktır.
Alıntılanan çalışmalar
1. Flutter Clean Architecture | Medium, erişim tarihi Temmuz 29, 2025,
https://medium.com/@semihaltin99/flutter-clean-architecture-8759ad0213dd
2. Effective Layered Architecture in Large Flutter Apps | by Md. Al-Amin | Jul, 2025 |
Medium, erişim tarihi Temmuz 29, 2025,
https://medium.com/@alaminkarno/effective-layered-architecture-in-large-flutter
-apps-e4ccd3b15ac3
3. Guide to app architecture - Flutter Documentation, erişim tarihi Temmuz 29, 2025,
https://docs.flutter.dev/app-architecture/guide
4. UI layer case study - Flutter Documentation, erişim tarihi Temmuz 29, 2025,
https://docs.flutter.dev/app-architecture/case-study/ui-layer
5. Scaling Flutter Apps with Feature-First Folder Structures - DEV Community, erişim
tarihi Temmuz 29, 2025,
https://dev.to/alaminkarno/scaling-flutter-apps-with-feature-first-folder-structur
es-547f
6. Flutter clean code and best practices - droidcon, erişim tarihi Temmuz 29, 2025,
https://www.droidcon.com/2024/08/22/flutter-clean-code-and-best-practices/
7. Row Level Security - Supabase Docs - Vercel, erişim tarihi Temmuz 29, 2025,
https://docs-ewup05pxh-supabase.vercel.app/docs/guides/auth/row-level-securi
ty
8. Mastering Supabase RLS - "Row Level Security" as a Beginner - DEV Community,
erişim tarihi Temmuz 29, 2025,
https://dev.to/asheeshh/mastering-supabase-rls-row-level-security-as-a-beginne
r-5175
9. Flutter Daily : Leveling Up Your Project Structure | by Vorrawut Judasri - Medium,
erişim tarihi Temmuz 29, 2025,
https://medium.com/@vortj/leveling-up-your-flutter-project-structure-fcb7099a
3930
10. Monorepo vs. polyrepo: architecture for source code management (SCM) version
control systems (VCS) - GitHub, erişim tarihi Temmuz 29, 2025,
https://github.com/joelparkerhenderson/monorepo-vs-polyrepo
11. Monorepo vs Polyrepo: Which Repository Strategy is Right for Your Team? -
Aviator, erişim tarihi Temmuz 29, 2025,
https://www.aviator.co/blog/monorepo-vs-polyrepo/
12. Making Flutter Apps Faster: How to Improve Your App's Performance — Part 2,
erişim tarihi Temmuz 29, 2025,
https://mumin-ahmod.medium.com/making-flutter-apps-faster-how-to-improve
-your-apps-performance-part-2-9f9a8e569602
13. What is FPS in Flutter? - Insight, erişim tarihi Temmuz 29, 2025,
https://insight.vayuz.com/insight-detail/what-is-fps-in-flutter-/bmV3c18xNzM0ND
EzMDk4ODUy
14. Flutter State Management Made Simple: Why Riverpod Should Be Your Next
Choice (Part 1), erişim tarihi Temmuz 29, 2025,
https://dev.to/tyu1996/flutter-state-management-made-simple-why-riverpod-sh
ould-be-your-next-choice-part-1-193n
15. How to Use Riverpod for State Management: An Advanced Flutter Guide -
Medium, erişim tarihi Temmuz 29, 2025,
https://medium.com/@ugamakelechi501/how-to-use-riverpod-for-state-manage
ment-an-advanced-flutter-guide-4741cc8dd9eb
16. Testing your providers - Riverpod, erişim tarihi Temmuz 29, 2025,
https://riverpod.dev/docs/essentials/testing
17. AURA PROJESİ - NİHAİ TASARIM VE STRATEJİ DÖKÜMANI (V3.0 - Tam
Metin).docx
18. StateNotifierProvider - Riverpod, erişim tarihi Temmuz 29, 2025,
https://riverpod.dev/docs/providers/state_notifier_provider
19. Clearing cache and reacting to state disposal - Riverpod, erişim tarihi Temmuz 29,
2025, https://riverpod.dev/docs/essentials/auto_dispose
20. Limit modifier · Issue #466 · rrousselGit/riverpod - GitHub, erişim tarihi Temmuz
29, 2025, https://github.com/rrousselGit/river_pod/issues/466
21. Efficient Memory Management in Flutter for Low-End Devices - Vibe Studio,
erişim tarihi Temmuz 29, 2025,
https://vibe-studio.ai/in/insights/efficient-memory-management-in-flutter-for-lo
w-end-devices
22. Flutter Performance Optimization: Best Practices for Faster Apps - DEV
Community, erişim tarihi Temmuz 29, 2025,
https://dev.to/nithya_iyer/flutter-performance-optimization-best-practices-for-fa
ster-apps-3dcd
23. A Complete Guide to Testing in Flutter: Unit, Widget, and Integration Tests - Ravi
Patel's Blog, erişim tarihi Temmuz 29, 2025,
https://ravipatel.hashnode.dev/a-complete-guide-to-testing-in-flutter-unit-widge
t-and-integration-tests
24. Flutter App Performance Benchmarks - JustAcademy, erişim tarihi Temmuz 29,
2025,
https://www.justacademy.co/blog-detail/flutter-app-performance-benchmarks
25. Optimizing image formats for faster Flutter app performance - ACA Group, erişim
tarihi Temmuz 29, 2025,
https://acagroup.be/en/blog/optimizing-image-formats-for-faster-flutter-app-pe
rformance/
26. GraphQL | Supabase Docs, erişim tarihi Temmuz 29, 2025,
https://supabase.com/docs/guides/graphql
27. pg_graphql, erişim tarihi Temmuz 29, 2025, https://supabase.github.io/pg_graphql/
28. Simplifying back-end complexity with Supabase Data APIs, erişim tarihi Temmuz
29, 2025, https://supabase.com/blog/simplify-backend-with-data-api
29. Realtime | Supabase Docs, erişim tarihi Temmuz 29, 2025,
https://supabase.com/docs/guides/realtime
30. Subscribing to Database Changes | Supabase Docs, erişim tarihi Temmuz 29,
2025,
https://supabase.com/docs/guides/realtime/subscribing-to-database-changes
31. Postgres Triggers | Supabase Docs, erişim tarihi Temmuz 29, 2025,
https://supabase.com/docs/guides/database/postgres/triggers
32. Push notifications using Supabase - FlutterFlow Community, erişim tarihi Temmuz
29, 2025,
https://community.flutterflow.io/ask-the-community/post/push-notifications-usin
g-supabase-ZPjFSRSTj4MhtAI
33. JWT Signing Keys | Supabase Docs, erişim tarihi Temmuz 29, 2025,
https://supabase.com/docs/guides/auth/signing-keys
34. Introducing JWT Signing Keys - Supabase, erişim tarihi Temmuz 29, 2025,
https://supabase.com/blog/jwt-signing-keys
35. Using Supabase offline #357 - GitHub, erişim tarihi Temmuz 29, 2025,
https://github.com/orgs/supabase/discussions/357
36. Real-Time Collaboration Tools: Supabase vs. Firebase - Propelius Technologies,
erişim tarihi Temmuz 29, 2025,
https://propelius.tech/blogs/real-time-collaboration-tools-supabase-vs-firebase
37. Supabase Competitors & Alternatives Choosing the Right BaaS | MetaCTO, erişim
tarihi Temmuz 29, 2025,
https://www.metacto.com/blogs/supabase-competitors-alternatives-a-compreh
ensive-guide
38. How to Read Localized Strings Outside the Widgets using Riverpod - Code With
Andrea, erişim tarihi Temmuz 29, 2025,
https://codewithandrea.com/articles/app-localizations-outside-widgets-riverpod/
39. Internationalizing Flutter apps - Flutter Documentation, erişim tarihi Temmuz 29,
2025,
https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization
40. Supabase vs. Firebase for MVP Scaling - Propelius Technologies, erişim tarihi
Temmuz 29, 2025,
https://propelius.tech/blogs/supabase-vs-firebase-for-mvp-scaling
41. Supabase | The Postgres Development Platform., erişim tarihi Temmuz 29, 2025,
https://supabase.com/
42. Can I use Supabase for analytics? - Tinybird, erişim tarihi Temmuz 29, 2025,
https://www.tinybird.co/blog-posts/can-i-use-supabase-for-user-facing-analytic
s
43. Supabase Pricing vs Codehooks: Complete Comparison Guide 2025 -
Automations, integrations, and backend APIs made easy, erişim tarihi Temmuz 29,
2025, https://codehooks.io/docs/alternatives/supabase-pricing-comparison
44. Pricing & Fees - Supabase, erişim tarihi Temmuz 29, 2025,
https://supabase.com/pricing
45. Performance Tuning | Supabase Docs, erişim tarihi Temmuz 29, 2025,
https://supabase.com/docs/guides/platform/performance
46. Database Sharding: How It Works and Its Benefits - Chat2DB, erişim tarihi
Temmuz 29, 2025, https://chat2db.ai/resources/blog/database-sharding
47. Sharding vs. partitioning: What's the difference? - PlanetScale, erişim tarihi
Temmuz 29, 2025,
https://planetscale.com/blog/sharding-vs-partitioning-whats-the-difference
48. Benchmarks | Supabase Docs, erişim tarihi Temmuz 29, 2025,
https://supabase.com/docs/guides/realtime/benchmarks
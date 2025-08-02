Aura Projesi: Hibrit Mimari Uygulama Rehberi
Bölüm I: Temel Mimari
Kısım 1: Birleşik Sistem Mimarisi ve Monorepo Stratejisi
1.1. Üst Düzey Mimari Vizyonu
Aura projesi, modern bir sosyal moda uygulamasının gerektirdiği dinamizm,
ölçeklenebilirlik ve geliştirme hızı ihtiyaçlarını karşılamak üzere tasarlanmış hibrit bir
mimari üzerine inşa edilmiştir. Bu mimari, üç temel sütun üzerine kuruludur: Flutter ile
geliştirilmiş istemci uygulaması, standart backend operasyonları için bir Hizmet Olarak
Arka Uç (BaaS) platformu olan Supabase ve özel iş mantığı ile yapay zekâ servisleri için
bir mikroservis olan FastAPI.
Bu modelin temel felsefesi, "standart operasyonlar için Supabase, özelleşmiş zekâ için
FastAPI" olarak özetlenebilir. Supabase, kullanıcı kimlik doğrulaması (Authentication),
veri tabanı (PostgreSQL), dosya depolama (Storage) ve gerçek zamanlı (Realtime)
yetenekler gibi bir uygulamanın temel yapı taşlarını hazır ve ölçeklenebilir bir şekilde
sunarak geliştirme sürecini önemli ölçüde hızlandırır.
1 Bu yaklaşım, Aura projesindeki
"Gardırop Yönetimi", "Kombin Oluşturma" ve "Sosyal Akış" gibi standart CRUD (Create,
Read, Update, Delete) operasyonları ağırlıklı özellikler için idealdir.
2
Diğer yandan, FastAPI mikroservisi, Aura'yı rakiplerinden ayıran ve yoğun hesaplama
gerektiren özellikler için devreye girer. Python'un zengin yapay zekâ ve veri bilimi
ekosisteminden faydalanan FastAPI, "Stil Asistanı" gibi doğal dil işleme (NLP) tabanlı
sohbet özellikleri veya "Paket Listesi Hazırlayıcı" gibi öneri motorları için esnek ve
yüksek performanslı bir ortam sağlar.
2
Bu hibrit yapı, bir startup'ın en değerli iki kaynağı olan zaman ve mühendislik eforunu
optimize eder. Geliştirici ekibi, standart backend görevlerine zaman harcamak yerine,
doğrudan kullanıcıya değer katan özgün özelliklere odaklanabilir. Mimari, hem hızlı bir
MVP (Minimum Viable Product) çıkışını destekler hem de gelecekteki büyüme ve özellik
setinin genişlemesi için sağlam bir temel sunar.
1.2. Monorepo Tavsiyesi ve Gerekçelendirmesi
Aura projesinin Flutter istemcisi ve FastAPI backend'ini içeren kod tabanının yönetimi
için kesin surette bir monorepo (tek bir depoda çoklu proje) yapısı tavsiye
edilmektedir. Bu karar, yalnızca bir kod organizasyon tercihi değil, projenin yaşam
döngüsü boyunca verimliliği, tutarlılığı ve bakım kolaylığını doğrudan etkileyen stratejik
bir mimari karardır.
4
Gerekçelendirme:
1. Basitleştirilmiş Bağımlılık Yönetimi: Flutter uygulaması ve FastAPI servisi, ortak
veri modellerini ve doğrulama kurallarını paylaşacaktır. Monorepo yapısı, bu
paylaşılan mantığı packages/shared_models gibi tek bir pakette toplamayı ve her
iki uygulama tarafından doğrudan referans alınmasını sağlar. Polyrepo (çoklu
depo) yaklaşımında ise bu paylaşılan paketlerin ayrı bir depoda yönetilmesi,
versiyonlanması ve her iki projeye ayrı ayrı dahil edilmesi gerekir ki bu da
karmaşıklığı ve hata potansiyelini artırır.
6
2. Atomik Değişiklikler (Atomic Commits): Bir özellikte hem frontend hem de
backend değişikliği gerektiğinde (örneğin, "Swap Market" özelliğine yeni bir filtre
eklenmesi), monorepo bu değişikliklerin tek bir "commit" ile yapılmasını sağlar.
8
Bu, kod tabanının her zaman tutarlı bir durumda kalmasını garantiler. Polyrepo'da
ise iki ayrı depoya commit atılması ve bu commit'lerin senkronize bir şekilde
deploy edilmesi gerekir, bu da entegrasyon sorunlarına yol açabilir.
3. Kolaylaştırılmış Kod Yeniden Yapılandırma (Refactoring): Bir veri modelinde
yapılacak bir değişiklik (örneğin, ClothingItem modeline carbonFootprintKg
alanının eklenmesi)
2
, hem Flutter kodunu hem de FastAPI kodunu etkileyecektir.
Monorepo içinde, modern IDE'ler bu tür refactoring işlemlerini tüm kod tabanında
güvenli bir şekilde gerçekleştirebilir.
4. Merkezi ve Verimli CI/CD Süreçleri: Monorepo'nun en büyük zorluklarından biri,
her küçük değişikliğin tüm projelerin yeniden build edilmesini tetikleyerek CI/CD
süreçlerini yavaşlatmasıdır.
8 Ancak bu sorun, seçilen teknoloji yığını ile etkin bir
şekilde çözülebilmektedir.
melos gibi bir araç, monorepo içindeki paketleri ve script'leri yönetmek için
kullanılırken
9
, Codemagic CI/CD platformu
changeset veya when:changeset: gibi yol tabanlı tetikleyicileri destekler.
10 Bu
sayede, yalnızca
apps/fastapi_service/ dizininde bir değişiklik yapıldığında FastAPI pipeline'ı
tetiklenir ve Flutter uygulamasının gereksiz yere build edilmesi engellenir. Bu, bir
startup için kritik olan CI/CD maliyetlerini ve bekleme sürelerini önemli ölçüde
azaltan stratejik bir avantajdır.
Sonuç olarak, monorepo yapısı, Aura gibi birbirine sıkı sıkıya bağlı frontend ve backend
bileşenleri olan bir proje için geliştirme hızını, kod tutarlılığını ve ekip içi iş birliğini
maksimize ederken, modern CI/CD araçları sayesinde en büyük dezavantajı olan
verimsiz pipeline'lar sorununu ortadan kaldırmaktadır.
1.3. Önerilen Monorepo Dizin Yapısı
Aura projesinin monorepo yapısı, melos aracıyla yönetilecek şekilde, uygulamaları ve
paylaşılabilir paketleri net bir şekilde ayıracak şekilde organize edilmelidir.
9
/aura-monorepo
├──.github/
│ └── workflows/ # GitHub Actions (kalite kontrol kapıları için)
├── apps/
│ ├── flutter_app/ # Ana Flutter uygulaması
│ │ ├── android/
│ │ ├── ios/
│ │ ├── lib/
│ │ └── pubspec.yaml
│ └── fastapi_service/ # FastAPI mikroservisi
│ ├── app/
│ ├── tests/
│ ├── Dockerfile
│ └── requirements.txt
├── packages/
│ ├── ui_kit/ # Paylaşılan Flutter UI bileşenleri (Design System)
│ │ ├── lib/
│ │ └── pubspec.yaml
│ └── shared_models/ # Paylaşılan veri modelleri ve doğrulama mantığı
│ ├── lib/
│ └── pubspec.yaml
├── scripts/ # CI/CD ve yardımcı betikler
├── melos.yaml # Melos konfigürasyon dosyası
├── analysis_options.yaml # Kök Linter kuralları
└── README.md
● apps/: Dağıtılabilir ana uygulamaları içerir. flutter_app ve fastapi_service bu dizin
altında yer alır.
● packages/: Uygulamalar arasında paylaşılan kodları barındırır. ui_kit, Aura'nın
tasarım sistemini ve yeniden kullanılabilir widget'larını içerirken; shared_models,
hem Flutter hem de FastAPI tarafından kullanılabilecek Pydantic/Dart veri
sınıflarını (veya en azından bu sınıfların temelini oluşturan şemaları) barındırabilir.
● melos.yaml: Monorepo'nun kalbidir. Paketleri birbirine bağlamak, tüm projelerde
aynı anda komut çalıştırmak (flutter test, flutter analyze vb.) ve versiyonlamayı
yönetmek için kullanılır.
9
1.4. Uçtan Uca İstek Yaşam Döngüsü (Metinsel Akış Diyagramları)
Projenin hibrit yapısını ve katmanlar arası iletişimi netleştirmek için üç temel senaryo
üzerinden veri akışı aşağıda metinsel olarak diyagramlaştırılmıştır.
Senaryo 1: Kullanıcı Gardırop Akışını Yükler (GraphQL Okuma)
Bu senaryo, veri okuma operasyonlarının verimliliği için GraphQL'in nasıl kullanıldığını gösterir.
|
V
|
V
|
V
|
V
[GraphQL Client (graphql_flutter)] -> Oluşturulan GraphQL Sorgusu
|
V
-> GraphQL (PostgREST Eklentisi)
|
V
-> Veri Çekilir ve Döner
Senaryo 2: Kullanıcı Profil Ayarlarını Günceller (REST Eylem)
Bu senaryo, özel iş mantığı gerektiren bir yazma (eylem) operasyonunun FastAPI üzerinden
REST ile nasıl yönetildiğini gösterir.
|
V
|
V
|
V
|
V
-> PUT /api/v1/users/settings
|
V
|
V
-> İş Mantığı Uygulanır
|
V
-> Supabase Client (Service Role Key ile)
|
V
-> Veri Güncellenir
Senaryo 3: Yeni Bir Beğeni Bildirimi Gelir (Gerçek Zamanlı Güncelleme)
Bu senaryo, veritabanındaki bir değişikliğin anlık olarak istemciye nasıl yansıtıldığını gösterir.
|
V
-> 'likes' tablosuna yeni kayıt eklenir
|
V
-> Değişiklik Yakalanır
|
V
-> Değişikliği RLS politikalarına göre filtreler ve ilgili istemcilere yayınlar
|
V
-> Olayı Dinler
|
V
[Application Katmanı: NotificationsController] -> Olayı işler ve state'i günceller
|
V
-> Yeni bildirim olduğunu gösteren bir 'badge' ile güncellenir
Kısım 2: Flutter Frontend Mimarisi: Temiz Bir Yaklaşım
2.1. 4 Katmanlı Temiz Mimari (Clean Architecture) Yaklaşımı
Aura'nın Flutter uygulaması, ölçeklenebilirliği, test edilebilirliği ve bakım kolaylığını en
üst düzeye çıkarmak için 4 katmanlı bir Temiz Mimari (Clean Architecture) prensibine
dayanmalıdır.
13 Bu yaklaşım, sorumlulukların net bir şekilde ayrılmasını sağlayarak kod
tabanının karmaşıklığını yönetir.
1. Presentation/UI (Sunum/Arayüz) Katmanı: Kullanıcının gördüğü ve etkileşimde
bulunduğu her şeyi içerir. Bu katman widget'lar, ekranlar ve animasyonlardan
oluşur. Kesinlikle iş mantığı içermemeli, yalnızca Application katmanından gelen
durumu (state) yansıtmalı ve kullanıcı etkileşimlerini (tıklama, kaydırma vb.)
Application katmanına iletmelidir.
16
○ Aura Örneği: WardrobeHomeScreen içindeki WardrobeGridView ve
ClothingItemCard widget'ları bu katmanın bir parçasıdır.
2
2. Application (Uygulama) Katmanı: UI ve Domain katmanları arasında bir köprü
görevi görür. UI'ın durumunu yönetir ve kullanıcı eylemlerine yanıt olarak Domain
katmanındaki iş mantığını tetikler. Riverpod Notifier veya StateNotifier sınıfları bu
katmanda yaşar.
15
○ Aura Örneği: WardrobeController (bir AsyncNotifier), kullanıcının arama
terimini, uygulanan filtreleri ve gardırop verilerinin yüklenme durumunu
(AsyncValue olarak) yönetir.
2
3. Domain (İş Mantığı) Katmanı: Uygulamanın kalbidir. Hiçbir framework'e (Flutter,
Riverpod vb.) bağımlılığı olmayan, saf Dart kodu içerir. Uygulamanın temel iş
kurallarını, varlıklarını (Entities) ve bu varlıklar üzerinde çalışan kullanım
senaryolarını (Use Cases) barındırır. Bu katman, Data katmanından veriye nasıl
ulaşıldığını bilmez, sadece bir arayüz (Repository Interface) üzerinden iletişim
kurar.
13
○ Aura Örneği: ClothingItem ve CustomCategory veri modelleri (Entities),
WardrobeRepository arayüzü ve GetFilteredClothingItemsUseCase sınıfı bu
katmanda yer alır.
2
4. Data/API (Veri/API) Katmanı: Dış dünya ile iletişimi yönetir. Domain katmanında
tanımlanan Repository arayüzlerini uygular. Supabase, FastAPI veya diğer harici
servislerle olan tüm etkileşimler (HTTP istekleri, veritabanı sorguları, WebSocket
bağlantıları) bu katmanda soyutlanır.
15
○ Aura Örneği: WardrobeRepositoryImpl sınıfı, WardrobeRepository arayüzünü
uygular ve Supabase GraphQL endpoint'ine gerçek ağ çağrılarını yapar.
2
Bu katmanlı yapı, her bir bileşenin bağımsız olarak test edilmesini sağlar. Örneğin,
Domain katmanı, hiçbir Flutter veya ağ bağımlılığı olmadan saf Dart unit testleri ile test
edilebilir.
2.2. Özellik Odaklı (Feature-First) Kod Organizasyonu
Proje büyüdükçe kod tabanında gezinmeyi ve yeni geliştiricilerin adaptasyonunu
kolaylaştırmak için, katman odaklı (/lib/presentation, /lib/domain vb.) bir yapı yerine
özellik odaklı (feature-first) bir dizin yapısı benimsenmelidir.
18 Bu modelde,
uygulamayla ilgili tüm kodlar, ait oldukları özelliğin (feature) altında gruplanır.
Bu yapı, Aura'nın modüler doğasıyla mükemmel uyum sağlar. "Gardırop", "Stil Asistanı",
"Sosyal Akış" gibi özellikler kendi kendine yeten modüller haline gelir. Bir geliştirici
"Swap Market" üzerinde çalışırken, ihtiyaç duyduğu tüm UI, state yönetimi ve veri
erişim kodlarını tek bir dizin altında bulabilir, bu da bilişsel yükü azaltır ve geliştirme
hızını artırır.
20
Örnek Dizin Yapısı:
/flutter_app/lib/
├── features/
│ ├── auth/ # Kimlik doğrulama özelliği
│ │ ├── application/
│ │ ├── domain/
│ │ ├── presentation/
│ │ └── data/
│ ├── wardrobe/ # Gardırop özelliği
│ │ ├── application/
│ │ │ └── wardrobe_controller.g.dart
│ │ │ └── wardrobe_controller.dart
│ │ ├── domain/
│ │ │ ├── entities/
│ │ │ │ └── clothing_item.dart
│ │ │ └── repositories/
│ │ │ └── wardrobe_repository.dart
│ │ ├── presentation/
│ │ │ ├── screens/
│ │ │ │ └── wardrobe_home_screen.dart
│ │ │ └── widgets/
│ │ │ └── clothing_item_card.dart
│ │ └── data/
│ │ └── wardrobe_repository_impl.dart
│ ├── style_assistant/ # Stil Asistanı özelliği
│ │ └──...
│ └── social_feed/ # Sosyal Akış özelliği
│ └──...
├── core/ # Tüm özellikler tarafından paylaşılan kodlar
│ ├── api/ # Merkezi API istemcileri (Dio, GraphQLClient)
│ ├── theme/ # Uygulama teması, renkler, fontlar (Design System)
│ ├── common_widgets/ # Genel amaçlı widget'lar (örn: PrimaryButton)
│ ├── navigation/ # GoRouter konfigürasyonu
│ ├── services/ # Cihaz servisleri (örn: AnalyticsService)
│ └── utils/ # Yardımcı fonksiyonlar, extension'lar
└── main.dart # Uygulama giriş noktası
● features/: Uygulamanın her bir ana özelliğini barındıran dizin. Her alt dizin, kendi
içinde 4 katmanlı mimariyi barındırır.
● core/: Özellikler arasında paylaşılan ve uygulamaya özgü olmayan temel
bileşenleri içerir. Bu, kod tekrarını önler ve tutarlılığı sağlar.
2.3. Riverpod v2 ile Durum Yönetimi Stratejisi
Riverpod v2, kod üretimi (riverpod_generator) desteği ile hem basit hem de karmaşık
durum yönetimi senaryoları için güçlü, derleme zamanı güvenli (compile-time safe) ve
test edilebilir bir çözüm sunar.
21 Aura projesinde Riverpod, state yönetiminin bel kemiği
olacaktır.
Provider Stratejisi:
Aşağıdaki tablo, Aura uygulamasındaki farklı durum türleri için hangi Riverpod
provider'ının kullanılacağına dair bir rehber sunmaktadır. Bu standartlaşma, kodun
okunabilirliğini ve bakımını kolaylaştıracaktır.
Durum
Açıklaması
Aura'dan Örnek Önerilen
Provider
Yaşam Döngüsü Gerekçe
Asenkron
sunucu verisi ve
iş mantığı
Gardırop verileri,
sosyal akış
gönderileri,
kullanıcı profili
AsyncNotifierPr
ovider
autoDispose
(varsayılan)
Sunucudan veri
çeken,
filtreleme/arama
gibi iş mantığı
içeren karmaşık
durumlar için
idealdir.
AsyncValue ile
yükleme, hata ve
veri durumlarını
zarifçe yönetir.
22
Basit, geçici UI
durumu
HomeScreen'de
ki aktif sekme
indeksi, arama
çubuğundaki
metin, bir
Switch'in
açık/kapalı
durumu
StateProvider autoDispose
(varsayılan)
Sadece UI'da
anlık bir durumu
tutmak için
kullanılır.
Karmaşık mantık
gerektirmez.
Notifier sınıfı
yazma yükünü
ortadan
kaldırır.
24
Değişmeyen,
enjekte edilebilir
servisler
WardrobeReposi
tory,
AnalyticsService
, Dio istemcisi
Provider keepAlive
(varsayılan)
Sınıfların
örneklerini
(instance)
oluşturup
uygulamanın
farklı yerlerinden
erişilmesini
sağlar. Durum
tutmaz, sadece
bağımlılık
enjeksiyonu için
kullanılır.
23
Uygulama
genelinde kalıcı
durum
Kullanıcının
kimlik
doğrulama
durumu, seçilen
dil (Locale),
tema (Açık/Koyu
Mod)
NotifierProvider
veya
AsyncNotifierPr
ovider
keepAlive: true Kullanıcı
oturumu
boyunca veya
uygulama
kapatılıp açılsa
bile korunması
gereken global
durumlar için
kullanılır.
keepAlive ile
state'in
kaybolması
engellenir.
25
autoDispose ve keepAlive Karar Mekanizması:
● .autoDispose (Varsayılan): Bir provider'ı dinleyen hiçbir widget kalmadığında,
provider'ın durumunu (state) hafızadan temizler.
25 Bu, bellek sızıntılarını önlemek
için varsayılan ve en güvenli seçenektir. Aura'da, bir ekrana özel veriler (örneğin,
WardrobeAnalyticsScreen
2 veya arama sonuçları) için kullanılmalıdır. Kullanıcı o
ekrandan ayrıldığında, veriye artık ihtiyaç kalmaz ve hafıza boşaltılabilir.
● @Riverpod(keepAlive: true): Provider'ı dinleyen kimse kalmasa bile durumunu
hafızada tutar.
25 Bu, uygulama boyunca sürekli olarak ihtiyaç duyulan global
durumlar için kritik öneme sahiptir. Örneğin, kullanıcının kimlik doğrulama durumu
(
authControllerProvider) veya seçilen dil (localeProvider) gibi durumlar, kullanıcı
farklı ekranlar arasında gezinirken bile korunmalıdır. Bu provider'ların autoDispose
olması, kullanıcının her ekran değiştirdiğinde yeniden giriş yapması gibi
istenmeyen durumlara yol açardı.
AsyncValue.when ile Kullanıcı Deneyimini Garanti Altına Alma:
Aura proje dökümanları, veri yükleme (WardrobeLoadingView), hata
(WardrobeErrorView) ve boş durum (EmptyWardrobeView) gibi farklı UI durumları için
özel widget'lar tanımlamaktadır.
2 Riverpod'un
AsyncValue sınıfı ve .when metodu, bu gereksinimleri karşılamak için mimari bir temel
taşıdır.
Geleneksel bir yaklaşımda, bir StatefulWidget içinde isLoading, hasError, data gibi
birden fazla değişkeni yönetmek, build metodu içinde karmaşık if/else bloklarına yol
açar. Bu hem okunması zor hem de hata yapmaya açık bir yapıdır.
AsyncNotifier ise asenkron işlemi kendi içinde yönetir ve durumunu tek bir AsyncValue
nesnesi olarak dışarıya sunar. AsyncValue, AsyncLoading, AsyncData ve AsyncError
olmak üzere üç alt duruma sahip bir sealed class'tır.
26
.when metodu, geliştiriciyi bu üç durumu da ele almaya zorlayarak derleme zamanında
olası hataları önler. Bu sayede, UI kodu şu şekilde deklaratif ve güvenli bir yapıya
kavuşur:
Dart
// WardrobeHomeScreen'in build metodu içinde
ref.watch(wardrobeControllerProvider).when(
loading: () => const WardrobeLoadingView(),
error: (error, stackTrace) => WardrobeErrorView(
message: error.toString(),
onRetry: () => ref.invalidate(wardrobeControllerProvider),
),
data: (wardrobeState) {
if (wardrobeState.items.isEmpty) {
return const EmptyWardrobeView();
}
return WardrobeGridView(items: wardrobeState.items);
},
)
Bu yapı, state ile UI arasında doğrudan, sağlam ve okunabilir bir bağ kurar.
ref.invalidate kullanımı, "Tekrar Dene" butonu gibi kullanıcı dostu hata kurtarma
mekanizmalarını
2 uygulamayı son derece basitleştirir.
Kısım 3: Hibrit Backend Mimarisi: Supabase & FastAPI
3.1. Hibrit Backend Rollerının Tanımlanması
Hibrit backend mimarisi, "hız" ve "esneklik" arasında bir denge kurar. Bu modelde roller
net bir şekilde ayrılmıştır:
● Supabase (Kayıt Sistemi - System of Record): Kullanıcı verileri, gardırop
öğeleri, kombinler, sosyal gönderiler gibi uygulamanın temel verilerinin tutulduğu,
güvenli ve ölçeklenebilir birincil platformdur.
1 Supabase, PostgreSQL veritabanı,
kimlik doğrulama, dosya depolama ve gerçek zamanlı yetenekleri ile standart
backend ihtiyaçlarını karşılar. Aura'daki
UserProfileScreen, WardrobeHomeScreen, MyCombinationsScreen gibi özellikler
doğrudan Supabase'in sunduğu altyapıyı kullanır.
2
● FastAPI (Zekâ Sistemi - System of Intelligence): Supabase'in standart BaaS
yeteneklerinin dışına çıkan, özel iş mantığı, yoğun hesaplama veya üçüncü parti
entegrasyonlar gerektiren özellikler için kullanılır.
3 FastAPI, Aura'nın "Stil Asistanı"
sohbet botu için gereken doğal dil işleme (NLP) modellerini çalıştırmak, "Paket
Listesi Hazırlayıcı" için öneri algoritmalarını uygulamak veya karmaşık analitik
verileri işlemek gibi görevleri üstlenir.
2
Bu ayrım, her platformun en güçlü olduğu alanda kullanılmasını sağlar: Supabase ile
hızlı geliştirme ve güvenli veri yönetimi, FastAPI ile ise sınırsız esneklik ve performans.
3.2. Supabase Veritabanı ve Auth Tasarımı
Tablo Tasarımı ve İlişkiler:
Veritabanı şeması, ilişkisel veritabanı tasarımının en iyi pratiklerine uygun olarak
tasarlanmalıdır. İsimlendirmelerde snake_case kullanılmalı ve birincil anahtarlar (primary keys)
için UUID tipi tercih edilmelidir. Bu, hem tutarlılık sağlar hem de gelecekte dağıtık sistemlere
geçişi kolaylaştırır.27
Aşağıda Aura'nın temel varlıkları için önerilen SQL şemaları bulunmaktadır:
SQL
-- Kullanıcıların genel profil bilgileri (herkese açık olabilir)
CREATE TABLE public.profiles (
id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
display_name TEXT NOT NULL,
avatar_url TEXT,
bio TEXT,
aura_score INT NOT NULL DEFAULT 0,
updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
-- Gardıroptaki her bir kıyafet
CREATE TABLE public.clothing_items (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
name TEXT NOT NULL,
image_url TEXT NOT NULL,
category TEXT NOT NULL,
color TEXT,
season TEXT,
is_favorite BOOLEAN DEFAULT FALSE NOT NULL,
created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
last_worn_date TIMESTAMPTZ
);
-- Kullanıcıların oluşturduğu kombinler
CREATE TABLE public.combinations (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
name TEXT NOT NULL,
cover_image_url TEXT,
is_public BOOLEAN DEFAULT FALSE NOT NULL,
created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
-- Bir kombin içinde hangi kıyafetlerin olduğunu belirten birleştirme tablosu (çoktan-çoğa ilişki)
CREATE TABLE public.combination_items (
id BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
combination_id UUID NOT NULL REFERENCES public.combinations(id) ON DELETE
CASCADE,
clothing_item_id UUID NOT NULL REFERENCES public.clothing_items(id) ON DELETE
CASCADE,
UNIQUE(combination_id, clothing_item_id)
);
-- Sosyal akış gönderileri (bir kombin paylaşımı)
CREATE TABLE public.social_posts (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
combination_id UUID NOT NULL REFERENCES public.combinations(id) ON DELETE
CASCADE,
caption TEXT,
created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
-- Gönderilere yapılan beğeniler
CREATE TABLE public.likes (
id BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
post_id UUID NOT NULL REFERENCES public.social_posts(id) ON DELETE CASCADE,
user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
UNIQUE(post_id, user_id)
);
Auth Entegrasyonu:
Supabase Auth, kimlik doğrulama sürecini yönetir. Bir kullanıcı kaydolduğunda, auth.users
tablosunda bir kayıt oluşturulur. Yukarıdaki profiles tablosu, bu auth.users tablosundaki id'yi
birincil ve yabancı anahtar (foreign key) olarak kullanarak, kimlik doğrulama verileri ile genel
profil verilerini güvenli bir şekilde birbirinden ayırır. Bu, yaygın ve güvenli bir desendir.28
Satır Seviyesi Güvenlik (Row Level Security - RLS):
RLS, Supabase'in en güçlü güvenlik özelliğidir ve verilerinize kimin, hangi koşullar altında
erişebileceğini doğrudan veritabanı seviyesinde tanımlamanızı sağlar.29 Bu, istemci tarafında
unutulan bir
where sorgusunun bile hassas verileri sızdırmasını engeller. Aura için RLS politikaları,
uygulamanın temel güvenlik katmanını oluşturmalıdır.
Aura için Örnek RLS Politikaları:
1. Kullanıcılar sadece kendi profillerini güncelleyebilir ve silebilir:
SQL
-- Önce tablo için RLS'i aktif et
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
-- Herkesin profilleri okumasına izin ver (eğer profiller herkese açıksa)
CREATE POLICY "Profiles are viewable by everyone."
ON public.profiles FOR SELECT
USING ( true );
-- Sadece kullanıcının kendisinin güncellemesine izin ver
CREATE POLICY "Users can update their own profile."
ON public.profiles FOR UPDATE
USING ( auth.uid() = id )
WITH CHECK ( auth.uid() = id );
Burada USING ifadesi mevcut satır üzerinde, WITH CHECK ise yeni yazılacak veri
üzerinde kontrol sağlar.
29
2. Kullanıcılar sadece kendi kıyafetlerini görebilir, ekleyebilir, güncelleyebilir ve
silebilir:
SQL
ALTER TABLE public.clothing_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage their own clothing items."
ON public.clothing_items FOR ALL
USING ( auth.uid() = user_id )
WITH CHECK ( auth.uid() = user_id );
3. Kullanıcılar herkese açık kombinleri görebilir, ancak sadece kendi
kombinlerini düzenleyebilir:
SQL
ALTER TABLE public.combinations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public combinations are viewable by authenticated users."
ON public.combinations FOR SELECT
TO authenticated
USING ( is_public = true OR auth.uid() = user_id );
CREATE POLICY "Users can manage their own combinations."
ON public.combinations FOR UPDATE, DELETE
USING ( auth.uid() = user_id );
4. Kullanıcılar bir gönderiyi sadece bir kez beğenebilir ve sadece kendi
beğenilerini geri alabilir:
SQL
ALTER TABLE public.likes ENABLE ROW LEVEL SECURITY;
-- Tüm beğenilerin okunmasına izin ver (örneğin beğeni sayısını göstermek için)
CREATE POLICY "Likes are viewable by everyone."
ON public.likes FOR SELECT
USING ( true );
-- Kullanıcının kendi adına beğeni eklemesine izin ver
CREATE POLICY "Users can insert their own likes."
ON public.likes FOR INSERT
WITH CHECK ( auth.uid() = user_id );
-- Kullanıcının sadece kendi beğenisini silmesine izin ver
CREATE POLICY "Users can delete their own likes."
ON public.likes FOR DELETE
USING ( auth.uid() = user_id );
3.3. FastAPI Servis Tasarımı ve Güvenli Supabase Entegrasyonu
FastAPI için Katmanlı Mimari:
FastAPI mikroservisi, kodun düzenli ve test edilebilir kalması için kendi içinde de katmanlı bir
mimariyi benimsemelidir: API Katmanı (Routers) → Servis Katmanı (İş Mantığı) → Repository
Katmanı (Veri Erişimi).30 Bu yapı, iş mantığını HTTP istek/cevap döngüsünden ayırır.
Güvenli Supabase Erişimi ve Güven Sınırı (Trust Boundary):
FastAPI'nin Supabase ile iletişiminde güvenlik en öncelikli konudur. Supabase iki tür API
anahtarı sunar: anon_key ve service_role_key.
● anon_key: İstemci tarafında (Flutter uygulamasında) kullanılan, RLS politikalarına
tabi olan anahtardır.
● service_role_key: RLS politikalarını bypass etme yetkisine sahip, son derece
hassas bir anahtardır. Bu anahtar ASLA istemci tarafında bulunmamalıdır.
32
FastAPI servisi, Supabase'e erişirken yalnızca service_role_key'i kullanmalıdır. Bu
anahtar, Docker container'ına bir ortam değişkeni (environment variable) olarak
güvenli bir şekilde sağlanmalıdır.
Bu ayrım, mimaride bir güven sınırı oluşturur. Supabase, RLS ile korunan ve doğrudan
istemciye açık olan "güvenilmeyen" (untrusted) dış sınırdır. FastAPI ise
service_role_key ile tam yetkiye sahip olan "güvenilir" (trusted) iç sınırdır. Bu nedenle,
birden fazla kullanıcının verisine erişim gerektiren veya RLS'in ötesinde yetkilendirme
mantığına ihtiyaç duyan tüm operasyonlar (örneğin, admin paneli işlemleri, tüm
kullanıcıların verilerini analiz eden bir AI servisi) Supabase RPC'lerinde değil, mutlaka
FastAPI servisinde gerçekleştirilmelidir.
FastAPI'de JWT Doğrulaması:
Flutter uygulamasından gelen her istek, Authorization: Bearer <SUPABASE_JWT> başlığını
içermelidir. FastAPI, bu JWT'yi doğrulamalı ve içindeki sub (kullanıcı ID'si) alanını kullanarak
isteği yapan kullanıcıyı tanımalıdır.
Supabase'in auth.getUser() endpoint'ini her istekte çağırmak yerine, JWT'yi lokal
olarak doğrulamak çok daha performanslıdır. Bu, SUPABASE_JWT_SECRET ortam
değişkeni kullanılarak PyJWT kütüphanesi ile yapılabilir.
34
Aşağıda, bu doğrulamayı yapan yeniden kullanılabilir bir FastAPI "dependency" örneği
verilmiştir:
Python
# app/security.py
import os
import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
# SUPABASE_JWT_SECRET'ı ortam değişkenlerinden güvenli bir şekilde al
JWT_SECRET = os.environ.get("SUPABASE_JWT_SECRET")
if not JWT_SECRET:
raise ValueError("SUPABASE_JWT_SECRET ortam değişkeni ayarlanmamış.")
# HTTPBearer, 'Authorization: Bearer <token>' başlığını ayrıştırır
reusable_bearer = HTTPBearer()
def validate_supabase_jwt(
auth: HTTPAuthorizationCredentials = Depends(reusable_bearer)
) -> dict:
"""
Supabase tarafından verilen JWT'yi lokal olarak doğrular ve payload'ı döndürür.
Hatalı veya süresi geçmiş token'lar için HTTPException fırlatır.
"""
try:
token = auth.credentials
payload = jwt.decode(
token,
JWT_SECRET,
algorithms=,
audience="authenticated"
)
return payload
except jwt.ExpiredSignatureError:
raise HTTPException(
status_code=status.HTTP_401_UNAUTHORIZED,
detail="Token has expired"
)
except jwt.InvalidTokenError:
raise HTTPException(
status_code=status.HTTP_401_UNAUTHORIZED,
detail="Invalid token"
)
except Exception:
raise HTTPException(
status_code=status.HTTP_401_UNAUTHORIZED,
detail="Could not validate credentials"
)
# Endpoint'lerde kullanım örneği
# from app.security import validate_supabase_jwt
#
# @router.post("/generate-style-suggestion")
# async def generate_suggestion(payload: dict = Depends(validate_supabase_jwt)):
# user_id = payload.get("sub")
# #... user_id'ye göre iş mantığını çalıştır
Bu validate_supabase_jwt dependency'si, korumalı endpoint'lere eklendiğinde, her
isteğin geçerli bir kullanıcı oturumuna ait olduğunu garanti eder ve user_id'yi güvenli
bir şekilde servis katmanına iletir.
Kısım 4: Çok Protokollü API Katmanı Tasarımı
4.1. Hibrit API Stratejisinin Gerekçelendirilmesi
Aura projesi için tek bir API protokolü yerine GraphQL, REST ve WebSocket/Realtime'ı
bir arada kullanan hibrit bir yaklaşım benimsenmiştir. Bu, aşırı mühendislik
(over-engineering) değil, her bir görevin doğasına en uygun aracı seçerek hem
performansı hem de geliştirici deneyimini optimize eden bilinçli bir mimari karardır.
API Protokolü Karar Matrisi
Özellik / Kullanım
Senaryosu
Protokol Gerekçe Performans ve
Geliştirici Deneyimi
Faydaları
Sosyal Akış Yükleme
(SocialFeedScreen)
GraphQL (Okuma) Akış,
kombinasyonları,
kombinasyon içindeki
kıyafetleri, yazar
profil bilgilerini ve
beğeni/yorum
sayılarını tek bir
istekte getirmelidir.
REST ile bu, birden
fazla endpoint'e (örn.
/posts, /users/{id},
/combinations/{id}/ite
ms) çağrı gerektirir
(under-fetching).
GraphQL, tek bir
sorgu ile tüm bu ilişkili
verileri getirebilir.
35
Performans: Ağ
gidiş-dönüş sayısını
(round-trips) en aza
indirir, mobil
cihazlarda veri
kullanımını ve
gecikmeyi azaltır.
Geliştirici Deneyimi:
Frontend, ihtiyacı
olan verinin şeklini
kendisi belirler,
backend'de yeni
endpoint'ler
oluşturma ihtiyacını
azaltır.
Profil Ayarlarını
Güncelleme
REST (Eylem) Bu, tek bir kaynağı
(kullanıcı ayarları)
güncelleyen, atomik
ve net bir eylemdir.
REST'in PUT veya
PATCH gibi HTTP
fiilleri ve 200 OK veya
Performans: Basit
eylemler için
GraphQL'in sorgu
ayrıştırma (parsing)
yükü olmadan daha
hafiftir. Geliştirici
Deneyimi: Eylemlerin
400 Bad Request gibi
standart durum
kodları, bu tür durum
değiştiren
operasyonlar için
evrensel ve anlaşılır
bir sözleşme sunar.
37
(command) doğası
gereği basit ve
tahmin edilebilirdir.
Caching ve güvenlik
politikaları endpoint
bazlı daha kolay
uygulanabilir.
Yeni Kıyafet Ekleme
(AddClothingItemScr
een)
REST (Eylem) Bir görselin
yüklenmesi ve
ardından bir
veritabanı kaydının
oluşturulması gibi
adımları içeren bir
işlemdir. REST,
multipart/form-data
gibi standartlarla
dosya yüklemeyi
doğal olarak
destekler. İşlem
sonucu nettir: başarı
(201 Created) veya
hata.
Performans: Dosya
yükleme gibi işlemler
için optimize edilmiş
HTTP
standartlarından
faydalanır. Geliştirici
Deneyimi: Süreç
nettir ve hata
yönetimi HTTP durum
kodları ile basittir.
Stil Asistanı Sohbeti
(StyleAssistantScreen
)
WebSocket /
Supabase Realtime
(Gerçek Zamanlı)
Kullanıcı ve AI
arasında çift yönlü,
düşük gecikmeli
iletişim gerektirir.
Kullanıcı mesaj
gönderir, AI
"yazıyor..." durumu
bildirir ve ardından
yanıtını parçalar
halinde (streaming)
gönderebilir.
HTTP'nin istek-cevap
modeli bu senaryo
için verimsizdir.
39
Performans: Düşük
gecikme ve
sunucu-istemci
arasında kalıcı bir
bağlantı sayesinde
anlık bir sohbet
deneyimi sunar.
Geliştirici Deneyimi:
Gerçek zamanlı
etkileşimleri
yönetmek için
tasarlanmış bir
protokol kullanmak,
sürekli yoklama
(polling) gibi karmaşık
çözümleri ortadan
kaldırır.
Yeni Gönderi
Bildirimleri
WebSocket /
Supabase Realtime
(Gerçek Zamanlı)
Takip edilen bir
kullanıcı yeni bir
kombin paylaştığında
Performans: Cihaz
pilini ve ağ
kaynaklarını tüketen
veya bir gönderiye
yorum yapıldığında,
kullanıcının anında
bilgilendirilmesi
gerekir. Bu, sunucu
tarafından başlatılan
(server-push) bir
iletişim gerektirir.
40
periyodik HTTP
yoklamalarına gerek
kalmaz. Geliştirici
Deneyimi: Olay
güdümlü
(event-driven) bir
mimari kurmayı
kolaylaştırır.
4.2. Flutter İstemci Konfigürasyonu
GraphQL İstemcisi (graphql_flutter):
GraphQL sorgularını yönetmek için graphql_flutter paketi kullanılacaktır. İstemci, uygulama
başlatıldığında bir kez oluşturulmalı ve GraphQLProvider aracılığıyla tüm widget ağacına
sağlanmalıdır. Yapılandırma, kalıcı önbellekleme (caching) için HiveStore ve her isteğe otomatik
olarak kimlik doğrulama token'ı eklemek için AuthLink içermelidir.35
Dart
// core/api/graphql_client.dart
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:aura/core/services/auth_service.dart'; // Supabase JWT'yi sağlayan servis
ValueNotifier<GraphQLClient> createGraphQLClient(AuthService authService) {
// Hive'ı Flutter için başlat (main.dart içinde çağrılmalı)
// await initHiveForFlutter();
final httpLink = HttpLink('https://<project_ref>.supabase.co/graphql/v1');
final authLink = AuthLink(
getToken: () async {
final session = authService.currentUserSession;
if (session == null) return null;
return 'Bearer ${session.accessToken}';
},
);
final link = authLink.concat(httpLink);
// Kalıcı önbellekleme için HiveStore kullan
final cache = GraphQLCache(store: HiveStore());
return ValueNotifier(
GraphQLClient(
link: link,
cache: cache,
),
);
}
// main.dart içinde
//...
// final authService = ref.watch(authServiceProvider);
// final graphQLClient = createGraphQLClient(authService);
//
// return GraphQLProvider(
// client: graphQLClient,
// child: MaterialApp(...)
// );
REST İstemcisi (dio):
RESTful endpoint'lerle iletişim için dio paketi, interceptor'lar, global yapılandırma ve sağlam
hata yönetimi gibi gelişmiş özellikleri nedeniyle tercih edilmelidir.44 İstemci, uygulama
genelinde tek bir örnek (singleton) olarak yönetilmelidir. Bir interceptor, her isteğe Supabase
JWT'sini ve dağıtık izleme (distributed tracing) için bir
X-Request-ID başlığını otomatik olarak eklemek üzere yapılandırılmalıdır.
44
Dart
// core/api/dio_client.dart
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'package:aura/core/services/auth_service.dart';
class DioClient {
final Dio _dio;
final AuthService _authService;
DioClient(this._authService)
: _dio = Dio(BaseOptions(
baseUrl: 'https://<your_fastapi_url>/api/v1',
connectTimeout: const Duration(seconds: 10),
receiveTimeout: const Duration(seconds: 10),
headers: {'Content-Type': 'application/json'},
)) {
_dio.interceptors.add(
InterceptorsWrapper(
onRequest: (options, handler) async {
// Her istek için benzersiz bir Trace ID oluştur
options.headers = const Uuid().v4();
// Geçerli bir session varsa, Authorization başlığını ekle
final session = _authService.currentUserSession;
if (session!= null) {
options.headers['Authorization'] = 'Bearer ${session.accessToken}';
}
return handler.next(options);
},
onError: (DioException e, handler) async {
// 401 Unauthorized hatası durumunda token yenileme mantığı eklenebilir
if (e.response?.statusCode == 401) {
// Token yenileme servisini çağır...
// Başarılı olursa, isteği yeni token ile tekrarla.
// Başarısız olursa, hatayı devam ettir.
}
return handler.next(e);
},
),
);
// Geliştirme ortamında loglama için
_dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
}
Dio get instance => _dio;
}
4.3. Supabase Realtime ile Gerçek Zamanlı Mimari
Supabase Realtime, PostgreSQL veritabanındaki değişiklikleri dinleyerek (Postgres
Changes) veya doğrudan istemciler arası mesajlaşma (Broadcast) sağlayarak
WebSocket üzerinden gerçek zamanlı yetenekler sunar.
40 Aura'da bu, bildirimler ve
canlı sohbet gibi özellikler için kullanılacaktır.
Veritabanı Değişikliklerini Dinleme Adımları:
1. Replication'ı Aktif Etme: Supabase projesinde, dinlenmek istenen tablolar için
veritabanı replikasyonunun aktif edilmesi gerekir. Bu, Supabase arayüzünden
"Database" -> "Replication" sekmesinden yapılır.
2. İstemci Tarafında Abonelik: Flutter uygulamasında, supabase_flutter paketi
kullanılarak belirli bir tablodaki INSERT, UPDATE veya DELETE olaylarına abone
olunur.
40
3. RLS Politikalarının Rolü: Gerçek zamanlı yayınlar, veritabanının RLS politikalarına
tabidir. Bir istemci, yalnızca SELECT yetkisi olan bir satırda değişiklik olduğunda bu
değişikliğe dair bir bildirim alır.
47 Bu, güvenliği otomatik olarak sağlasa da,
karmaşık senaryolar için dikkatli bir RLS tasarımı gerektirir.
Aura Uygulama Senaryosu: Sosyal Akışta "Yeni Gönderiler" Bildirimi
Kullanıcı SocialFeedScreen'deyken, takip ettiği kişilerden yeni bir gönderi geldiğinde
bunu anlık olarak bildiren bir mekanizma kurulabilir.
Dart
// features/social_feed/application/social_feed_realtime_notifier.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
part 'social_feed_realtime_notifier.g.dart';
@riverpod
class HasNewPostsNotifier extends _$HasNewPostsNotifier {
RealtimeChannel? _postsChannel;
@override
bool build() {
final client = Supabase.instance.client;
_postsChannel = client
.channel('public:social_posts')
.on(
RealtimeListenTypes.postgresChanges,
ChannelFilter(event: 'INSERT', schema: 'public', table: 'social_posts'),
(payload, [ref]) {
// Burada, gelen yeni gönderinin yazarının
// mevcut kullanıcının takip ettiği biri olup olmadığını
// kontrol eden bir mantık eklenmelidir.
// Eğer öyleyse, state'i true yap.
print('New post detected: ${payload['new']}');
state = true;
},
)
.subscribe();
// Notifier dispose edildiğinde abonelikten çık
ref.onDispose(() {
if (_postsChannel!= null) {
client.removeChannel(_postsChannel!);
}
});
return false; // Başlangıç durumu
}
// Kullanıcı butona tıkladığında state'i sıfırla
void acknowledgeNewPosts() {
state = false;
}
}
// UI Tarafında Kullanım
//...
// final hasNewPosts = ref.watch(hasNewPostsNotifierProvider);
//
// if (hasNewPosts) {
// ElevatedButton(
// onPressed: () {
// ref.read(hasNewPostsNotifierProvider.notifier).acknowledgeNewPosts();
// ref.invalidate(socialFeedProvider); // Akışı yeniden yükle
// },
// child: Text('Yeni Gönderileri Gör'),
// )
// }
Bu örnekte, social_posts tablosuna yeni bir kayıt eklendiğinde (INSERT olayı),
HasNewPostsNotifier'ın durumu true olarak güncellenir. UI bu durumu dinleyerek
kullanıcıya "Yeni Gönderileri Gör" gibi bir buton gösterebilir. Kullanıcı bu butona
tıkladığında, akış yeniden yüklenir ve bildirim durumu sıfırlanır. Bu, hem verimli hem de
kullanıcı dostu bir gerçek zamanlı deneyim sunar.
Bölüm II: Çekirdek Uygulama Rehberleri
Kısım 5: "Aura" Tasarım Sisteminin İnşası
Bir tasarım sistemi (Design System), bir uygulamanın görsel ve etkileşimsel tutarlılığını
sağlayan, yeniden kullanılabilir bileşenler ve standartlar bütünüdür. Aura için tutarlı bir
kullanıcı deneyimi sunmak, marka kimliğini güçlendirmek ve geliştirme sürecini
hızlandırmak amacıyla merkezi bir tasarım sistemi oluşturulması kritik öneme sahiptir.
Bu sistem, Flutter'ın ThemeData mekanizması üzerine inşa edilecek ve packages/ui_kit
monorepo paketi içinde yaşayacaktır.
5.1. Tema Yönetimi: ThemeData ile Açık ve Koyu Mod
Uygulamanın genel görünümü, MaterialApp widget'ına sağlanan ThemeData nesneleri
ile merkezi olarak yönetilmelidir. Bu, renkler, tipografi, düğme stilleri gibi temel görsel
öğelerin uygulama genelinde tutarlı olmasını sağlar.
48 Aura projesi, hem açık (
light) hem de koyu (dark) temaları desteklemelidir.
Mimari Öneriler:
1. Merkezi Tema Dosyası: Tüm tema tanımlamaları,
packages/ui_kit/lib/src/theme/app_theme.dart gibi tek bir dosyada toplanmalıdır.
Bu dosya, lightTheme ve darkTheme adında iki ThemeData nesnesi ihraç etmelidir.
2. ColorScheme.fromSeed Kullanımı: Material 3'ün en iyi pratiklerinden biri olan
ColorScheme.fromSeed kullanılarak, tek bir ana renkten yola çıkarak uyumlu bir
renk paleti (birincil, ikincil, yüzey, hata renkleri vb.) otomatik olarak oluşturulabilir.
Bu, tema oluşturma sürecini basitleştirir ve görsel uyumu garantiler.
48
3. Tipografi Yönetimi: google_fonts paketi kullanılarak zengin bir tipografi yelpazesi
kolayca entegre edilebilir. textTheme özelliği, başlık (headline), alt başlık (subtitle),
gövde metni (body) gibi farklı metin stillerini merkezi olarak tanımlamak için
kullanılmalıdır.
4. Bileşen Temaları (Component Themes): ThemeData içindeki
elevatedButtonTheme, cardTheme, inputDecorationTheme gibi özellikler
kullanılarak standart widget'ların görünümleri uygulama genelinde
özelleştirilmelidir. Bu, her seferinde widget'ları manuel olarak stillendirme ihtiyacını
ortadan kaldırır.
Örnek Kod Şablonu (app_theme.dart):
Dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class AppTheme {
static const _seedColor = Colors.purple;
static ThemeData get lightTheme {
final colorScheme = ColorScheme.fromSeed(
seedColor: _seedColor,
brightness: Brightness.light,
);
return ThemeData(
colorScheme: colorScheme,
fontFamily: GoogleFonts.inter().fontFamily,
textTheme: _textTheme,
elevatedButtonTheme: _elevatedButtonTheme(colorScheme),
// Diğer bileşen temaları...
);
}
static ThemeData get darkTheme {
final colorScheme = ColorScheme.fromSeed(
seedColor: _seedColor,
brightness: Brightness.dark,
);
return ThemeData(
colorScheme: colorScheme,
fontFamily: GoogleFonts.inter().fontFamily,
textTheme: _textTheme,
elevatedButtonTheme: _elevatedButtonTheme(colorScheme),
// Diğer bileşen temaları...
);
}
static final TextTheme _textTheme = TextTheme(
displayLarge: GoogleFonts.playfairDisplay(fontSize: 57, fontWeight:
FontWeight.bold),
titleLarge: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold),
bodyMedium: GoogleFonts.inter(fontSize: 14),
labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
);
static ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme colorScheme)
{
return ElevatedButtonThemeData(
style: ElevatedButton.styleFrom(
backgroundColor: colorScheme.primary,
foregroundColor: colorScheme.onPrimary,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
textStyle: _textTheme.labelLarge,
),
);
}
}
5.2. Yeniden Kullanılabilir UI Kütüphanesi Oluşturma
Tasarım sistemi, sadece renk ve fontlardan ibaret değildir; aynı zamanda uygulamanın
yapı taşlarını oluşturan yeniden kullanılabilir widget'ları da içerir. Bu bileşenler,
packages/ui_kit/lib/src/widgets/ dizini altında geliştirilmelidir. Bu yaklaşım, kod tekrarını
azaltır, geliştirmeyi hızlandırır ve gelecekte yapılacak bir tasarım değişikliğinin tek bir
yerden tüm uygulamaya yansıtılmasını sağlar.
Atomik Tasarım (Atomic Design) Prensibi:
UI kütüphanesi, Atomik Tasarım metodolojisinden ilham alarak yapılandırılabilir.49
● Atoms (Atomlar): En temel yapı taşlarıdır. PrimaryButton, StyledTextField,
AppIcon gibi tekil ve bölünemez bileşenler.
● Molecules (Moleküller): Atomların bir araya gelerek oluşturduğu daha karmaşık
bileşenlerdir. WardrobeSearchBar (bir TextField ve bir IconButton'dan oluşur) veya
ProfileStatsRow (birden fazla Text ve Icon'dan oluşur) gibi.
2
● Organisms (Organizmalar): Moleküllerin ve atomların birleşimiyle oluşan, ekranın
daha büyük ve bağımsız bölümleridir. WardrobeFilterBottomSheet veya
CombinationCard gibi bileşenler bu kategoriye girer.
2
Örnek Dosya Yapısı (packages/ui_kit/lib/):
/ui_kit/lib/
├── src/
│ ├── theme/
│ │ └── app_theme.dart
│ ├── widgets/
│ │ ├── atoms/
│ │ │ ├── primary_button.dart
│ │ │ └── styled_text_field.dart
│ │ ├── molecules/
│ │ │ └── search_bar.dart
│ │ └── organisms/
│ │ └── item_card.dart
│ └── utils/
│ └──...
└── ui_kit.dart # Paket içindeki tüm bileşenleri ihraç eden ana dosya
Örnek Kod Şablonu (primary_button.dart):
Dart
import 'package:flutter/material.dart';
class PrimaryButton extends StatelessWidget {
const PrimaryButton({
super.key,
required this.onPressed,
required this.text,
this.isLoading = false,
});
final VoidCallback? onPressed;
final String text;
final bool isLoading;
@override
Widget build(BuildContext context) {
return ElevatedButton(
onPressed: isLoading? null : onPressed,
child: isLoading
? const SizedBox(
height: 24,
width: 24,
child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
)
: Text(text),
);
}
}
Bu PrimaryButton widget'ı, ThemeData'da tanımlanan stili otomatik olarak alır ve ek
olarak bir isLoading durumu yönetir. Bu, uygulama genelindeki tüm ana butonların aynı
görünmesini ve davranmasını sağlar.
5.3. Duyarlı Tasarım (Responsive Design) Uygulamaları
Aura'nın farklı ekran boyutlarına sahip cihazlarda (küçük telefonlar, büyük telefonlar,
tabletler) tutarlı bir deneyim sunması için duyarlı tasarım prensipleri uygulanmalıdır.
Stratejiler:
1. LayoutBuilder ve MediaQuery: Bir widget'ın, ebeveyninin sağladığı kısıtlamalara
(LayoutBuilder) veya ekranın genel boyutlarına (MediaQuery) göre farklı bir layout
çizmesi sağlanabilir. Örneğin, bir tablette GridView daha fazla sütun gösterebilir.
2. Esnek Widget'lar: Expanded, Flexible, FractionallySizedBox gibi widget'lar,
arayüz elemanlarının mevcut alana orantılı olarak yayılmasını sağlar.
3. Kırılma Noktaları (Breakpoints): Farklı ekran genişlikleri için (örn: < 600px mobil,
600-900px tablet, > 900px masaüstü) belirli layout değişikliklerinin tetiklendiği
kırılma noktaları tanımlanabilir. Bu, özellikle gelecekte web ve masaüstü desteği
düşünülüyorsa önemlidir.
Use-case: Gardırop Izgarasının Duyarlı Hale Getirilmesi
WardrobeHomeScreen'deki ızgara görünümü, ekran genişliğine göre sütun sayısını dinamik
olarak ayarlamalıdır.
Dart
import 'package:flutter/material.dart';
class ResponsiveGridView extends StatelessWidget {
const ResponsiveGridView({super.key, required this.itemCount, required this.itemBuilder});
final int itemCount;
final Widget Function(BuildContext, int) itemBuilder;
@override
Widget build(BuildContext context) {
return LayoutBuilder(
builder: (context, constraints) {
// Kırılma noktalarına göre sütun sayısını belirle
final double width = constraints.maxWidth;
int crossAxisCount;
if (width > 900) {
crossAxisCount = 5;
} else if (width > 600) {
crossAxisCount = 4;
} else {
crossAxisCount = 2;
}
return GridView.builder(
itemCount: itemCount,
gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount: crossAxisCount,
crossAxisSpacing: 16,
mainAxisSpacing: 16,
childAspectRatio: 0.75,
),
itemBuilder: itemBuilder,
);
},
);
}
}
Bu ResponsiveGridView widget'ı, LayoutBuilder kullanarak mevcut genişliği ölçer ve bu
genişliğe göre en uygun sütun sayısını belirleyerek GridView'i oluşturur. Bu, farklı
cihazlarda optimum bir kullanıcı deneyimi sağlar.
Kısım 6: Gelişmiş Durum ve Veri Yönetimi
6.1. Çevrimdışı Öncelikli (Offline-First) ve Önbellekleme (Caching) Stratejileri
Kullanıcıların ağ bağlantısının zayıf olduğu veya hiç olmadığı durumlarda bile
uygulamanın kullanılabilir ve hızlı hissedilmesi, modern mobil uygulamalar için kritik bir
kullanıcı deneyimi faktörüdür. Aura, temel işlevlerini çevrimdışı olarak da sunabilmek
için katmanlı bir önbellekleme stratejisi benimsemelidir.
Mimari Öneriler:
1. Riverpod ile Hafıza (In-Memory) Önbellekleme: AsyncNotifierProvider'lar,
varsayılan olarak veriyi hafızada önbellekler. Bir ekrandan ayrılıp geri
dönüldüğünde, eğer provider autoDispose edilmemişse, veri yeniden ağdan
çekilmek yerine hafızadaki önbellekten anında yüklenir. Bu, hızlı ve akıcı bir
gezinme deneyimi sağlar.
23
○ Senaryo: Kullanıcı WardrobeHomeScreen'den bir kıyafetin detayına gider ve
geri döner. wardrobeControllerProvider keepAlive olarak ayarlanmışsa,
gardırop listesi anında yeniden gösterilir, bir yükleme ekranı görülmez.
2. Disk (On-Disk) Önbellekleme: Uygulama kapatılıp açıldığında veya hafızadaki
önbellek temizlendiğinde verinin korunması için disk tabanlı bir önbellek
mekanizması gereklidir. Bu, uygulamanın internet olmadan ilk açılışta bile veri
gösterebilmesini sağlar.
○ Kullanılacak Araç: Hive paketi, hızı ve basitliği nedeniyle bu iş için idealdir.
graphql_flutter istemcisi, HiveStore kullanarak GraphQL yanıtlarını otomatik
olarak diske önbellekleyebilir.
50 REST istekleri için ise, Repository katmanında
özel bir mantık ile
Dio'dan gelen yanıtlar Hive'a yazılabilir.
3. Veri Senkronizasyon Stratejisi: Çevrimdışı yapılan değişikliklerin (örn. bir kıyafeti
favorilere ekleme) yönetimi için bir senkronizasyon kuyruğu oluşturulmalıdır.
○ Akış:
1. Kullanıcı çevrimdışıyken bir eylem gerçekleştirir (örn. toggleFavorite).
2. Application katmanı (örn. WardrobeController), bu eylemi hem lokal Hive
veritabanına anında yansıtır (optimistic update) hem de "senkronize
edilecek eylemler" kuyruğuna ekler.
3. Ağ bağlantısı geri geldiğinde, bir SyncService bu kuyruktaki eylemleri
sırayla ilgili API'lere (REST/GraphQL) gönderir.
4. Başarılı olan her eylem kuyruktan silinir.
Örnek Kod Şablonu (GraphQL Caching):
graphql_flutter istemcisini HiveStore ile yapılandırmak, GraphQL sorgularının otomatik olarak
diske önbelleklenmesini sağlar.
Dart
// core/api/graphql_client.dart
import 'package:graphql_flutter/graphql_flutter.dart';
Future<GraphQLCache> createGraphQLCache() async {
// Bu fonksiyon main.dart içinde uygulama başlamadan önce çağrılmalı
await initHiveForFlutter();
return GraphQLCache(store: HiveStore());
}
// İstemci oluşturulurken:
// final cache = await createGraphQLCache();
// final client = GraphQLClient(link: link, cache: cache);
Potansiyel Sorunlar ve Çözümleri:
● Sorun: Önbellekteki veri eskiyebilir (stale data).
● Çözüm: "Stale-while-revalidate" stratejisi uygulanmalıdır. UI, her zaman önce
önbellekteki veriyi gösterir. Aynı anda arka planda ağdan taze veri çekilir. Yeni veri
geldiğinde, UI sessizce güncellenir. ref.refresh(provider) metodu bu deseni
uygulamak için kullanılabilir. Ayrıca, belirli veri türleri için TTL (Time-to-Live)
süreleri tanımlanabilir (örn. sosyal akış 5 dakika, kullanıcı profili 1 saat).
6.2. Ağ Durumu İzleme ve Yeniden Deneme (Retry) Mekanizmaları
Uygulama, cihazın ağ durumundaki (online/offline) değişikliklere proaktif olarak tepki
vermelidir. Başarısız olan ağ istekleri, özellikle geçici hatalarda (transient errors),
kullanıcı müdahalesi olmadan otomatik olarak yeniden denenmelidir.
Kullanılacak Araçlar ve Kütüphaneler:
● Ağ Durumu İzleme: connectivity_plus paketi, Wi-Fi, mobil veri veya bağlantı yok
gibi durum değişikliklerini dinlemek için kullanılır.
● Yeniden Deneme Mantığı: dio'nun Interceptor mekanizması, başarısız olan REST
isteklerini yakalayıp yeniden denemek için mükemmel bir yerdir. dio_smart_retry
gibi paketler bu işlevi hazır olarak sunar.
Mimari Öneriler:
1. Global Ağ Durumu Provider'ı: Uygulama genelinde ağ durumunu dinleyen ve
mevcut durumu (ConnectivityStatus) sunan bir StreamProvider oluşturulmalıdır.
Dart
// core/services/network_status_provider.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'network_status_provider.g.dart';
@riverpod
Stream<ConnectivityResult> networkStatus(NetworkStatusRef ref) {
return Connectivity().onConnectivityChanged;
}
2. UI'da Ağ Durumuna Tepki Verme: Widget'lar, bu provider'ı dinleyerek ağ
bağlantısı olmadığında kullanıcıya bir SnackBar ile bilgi verebilir veya çevrimdışı
modda çalıştığını belirten bir banner gösterebilir.
3. Dio için Akıllı Yeniden Deneme Interceptor'ı: DioClient'a eklenecek bir
Interceptor, ağ ile ilgili hataları (SocketException, TimeoutException) veya sunucu
taraflı geçici hataları (5xx durum kodları) yakalamalıdır. Hata yakalandığında,
"exponential backoff" (her denemede bekleme süresini katlayarak artırma)
stratejisi ile isteği belirli bir sayıda (örn. 3 kez) yeniden denemelidir.
52
Örnek Kod Şablonu (Dio Retry Interceptor):
Dart
// core/api/retry_interceptor.dart
import 'dart:io';
import 'package:dio/dio.dart';
class RetryInterceptor extends Interceptor {
final Dio dio;
final int maxRetries;
RetryInterceptor({required this.dio, this.maxRetries = 3});
@override
Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
if (_shouldRetry(err)) {
int retryCount = err.requestOptions.extra['retry_count']?? 0;
if (retryCount < maxRetries) {
retryCount++;
err.requestOptions.extra['retry_count'] = retryCount;
// Exponential backoff
int delay = 1 << retryCount; // 2, 4, 8 saniye
await Future.delayed(Duration(seconds: delay));
try {
final response = await dio.fetch(err.requestOptions);
return handler.resolve(response);
} on DioException catch (e) {
return handler.next(e);
}
}
}
return handler.next(err);
}
bool _shouldRetry(DioException err) {
return err.type == DioExceptionType.connectionTimeout ||
err.type == DioExceptionType.sendTimeout ||
err.type == DioExceptionType.receiveTimeout ||
err.error is SocketException ||
(err.response?.statusCode!= null && err.response!.statusCode! >= 500);
}
}
Bu interceptor, DioClient'a eklendiğinde, ağ hatalarına karşı uygulamayı çok daha
dayanıklı hale getirecektir.
Kısım 7: Yerelleştirme ve Uluslararasılaştırma (i18n)
Aura'nın küresel bir kitleye hitap etme potansiyeli göz önünde bulundurularak, çoklu dil
desteği ve farklı kültürel formatlara uyum (uluslararasılaştırma) mimarinin temel bir
parçası olmalıdır. Flutter'ın yerleşik intl paketi ve flutter_localizations bu sürecin
temelini oluşturacaktır.
54
7.1. Çok Dilli Uygulama Desteği ve Çeviri Dosyaları
Mimari Öneriler:
1. ARB (Application Resource Bundle) Dosya Formatı: Çeviri metinleri için
Flutter'ın standart formatı olan .arb dosyaları kullanılmalıdır. Bu dosyalar, lib/l10n
dizini altında saklanmalıdır. app_en.arb (İngilizce - ana/şablon dosya), app_tr.arb
(Türkçe), app_ar.arb (Arapça) gibi her dil için ayrı bir dosya oluşturulmalıdır.
54
2. Kod Üretimi: flutter_lints paketinin generate: true ayarı ile flutter gen-l10n
komutu, bu .arb dosyalarından otomatik olarak Dart sınıfları üretecektir. Bu,
metinlere tip-güvenli (type-safe) bir şekilde erişim sağlar ve "sihirli dizgeleri"
(magic strings) ortadan kaldırır.
3. Dosya Yapısı:
/flutter_app/
├── lib/
│ └── l10n/
│ ├── app_en.arb // İngilizce (şablon)
│ ├── app_tr.arb // Türkçe
│ └── app_ar.arb // Arapça
└── l10n.yaml // l10n yapılandırma dosyası
4. l10n.yaml Yapılandırması: Bu dosya, kod üretimi aracını yapılandırır.
YAML
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
Örnek app_en.arb İçeriği:
JSON
{
"@@locale": "en",
"wardrobeTitle": "My Wardrobe",
"@wardrobeTitle": {
"description": "Title for the wardrobe screen"
},
"itemCount": "{count,plural, =0{No items} =1{1 item} other{{count} items}}",
"@itemCount": {
"description": "A message showing the number of items in the wardrobe.",
"placeholders": {
"count": {
"type": "int"
}
}
}
}
Bu yapı, basit metinlerin yanı sıra çoğul (plural) ve parametreli metinleri de destekler.
55
7.2. Riverpod ile Dil Değişikliğinin Yönetimi
Uygulama içinde kullanıcının dil tercihini dinamik olarak değiştirebilmesi için bu
durumun Riverpod ile yönetilmesi gerekir.
Mimari Öneriler:
1. LocaleProvider Oluşturma: Seçili Locale nesnesini tutan bir NotifierProvider
oluşturulmalıdır. Bu provider keepAlive: true olarak işaretlenmelidir, çünkü dil
tercihi uygulama genelinde kalıcı bir durumdur.
2. SharedPreferences ile Kalıcılık: Kullanıcının dil tercihi, uygulama kapatılıp
açıldığında kaybolmamalıdır. Bu nedenle, dil değiştirildiğinde seçilen Locale'in dil
kodu shared_preferences kullanılarak cihaza kaydedilmelidir. Uygulama
başlatıldığında, bu değer okunarak LocaleProvider'ın başlangıç durumu
ayarlanmalıdır.
3. MaterialApp'i Dinleyici Yapma: MaterialApp widget'ı, Consumer veya
ConsumerWidget ile sarılarak LocaleProvider'ı dinlemelidir. Provider'ın durumu
değiştiğinde, MaterialApp'in locale parametresi güncellenir ve Flutter tüm arayüzü
yeni dile göre yeniden çizer.
Örnek Kod Şablonu:
Dart
// core/localization/locale_provider.dart
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'locale_provider.g.dart';
@Riverpod(keepAlive: true)
class LocaleNotifier extends _$LocaleNotifier {
static const _localePrefKey = 'app_locale';
@override
Locale build() {
// Uygulama başlarken kayıtlı dili yükle
final prefs = ref.watch(sharedPreferencesProvider);
final languageCode = prefs.getString(_localePrefKey);
if (languageCode!= null) {
return Locale(languageCode);
}
// Kayıtlı dil yoksa sistem dilini veya varsayılanı kullan
return const Locale('en');
}
Future<void> setLocale(Locale locale) async {
if (state == locale) return;
final prefs = ref.read(sharedPreferencesProvider);
await prefs.setString(_localePrefKey, locale.languageCode);
state = locale;
}
}
// SharedPreferences için basit bir provider
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(SharedPreferencesRef ref) {
// Bu provider'ın başlangıçta asenkron olarak başlatılması gerekir.
throw UnimplementedError();
}
Dart
// main.dart
//...
final locale = ref.watch(localeNotifierProvider);
return MaterialApp(
locale: locale,
supportedLocales: AppLocalizations.supportedLocales,
localizationsDelegates: AppLocalizations.localizationsDelegates,
//...
);
// Dil değiştirme butonu içinde
// ref.read(localeNotifierProvider.notifier).setLocale(const Locale('tr'));
7.3. RTL (Sağdan Sola) Desteği
Arapça, İbranice gibi sağdan sola yazılan dilleri desteklemek için arayüzün yatay olarak
"aynalanması" gerekir. Flutter, bu desteği büyük ölçüde otomatik olarak sağlar, ancak
dikkat edilmesi gereken bazı noktalar vardır.
56
En İyi Pratikler:
1. Yönelimsel Widget'lar (Directional Widgets): padding, margin, alignment gibi
özelliklerde left ve right yerine start ve end kullanan yönelimsel alternatifler tercih
edilmelidir.
○ EdgeInsets.only(left: 8) yerine EdgeInsetsDirectional.only(start: 8)
○ Alignment.centerLeft yerine AlignmentDirectional.centerStart
○ BorderRadius.only(topLeft:...) yerine BorderRadiusDirectional.only(topStart:...)
Bu widget'lar, mevcut TextDirection'a göre start ve end'i otomatik olarak left
veya right'a çevirir.57
2. Row ve Column: Bu widget'ların mainAxisAlignment ve crossAxisAlignment
özellikleri zaten start ve end değerlerini kullandığı için doğal olarak RTL
uyumludurlar.
3. İkonların Aynalanması: Yön belirten ikonlar (örn. Icons.arrow_back) Flutter
tarafından otomatik olarak aynalanır. Ancak, aynalanmaması gereken ikonlar (örn.
bir logo) veya özel ikonlar için dikkatli olunmalıdır. Transform.scale widget'ı ile
manuel aynalama yapılabilir.
4. Metin Yönelimi: Karışık diller içeren metinlerde ("Bu ürün 100 س.ل
ma maliyetindedir ), T xt widget'ın tn textDirect on elzellini ni met in irierine ne ge
re dina ik ola ak ayarla ak gerekebil
Bu pratikler, MaterialApp'in locale'i Arapça gibi bir RTL diline ayarlandığında,
uygulamanın tüm layout'unun otomatik olarak doğru şekilde adapte olmasını
sağlayacaktır.
Bölüm III: Operasyonlar, Kalite ve Gözlemlenebilirlik
Kısım 8: Codemagic ile CI/CD Süreci
Sürekli Entegrasyon (CI) ve Sürekli Dağıtım (CD), modern yazılım geliştirmenin temel
taşlarıdır. Bu süreçler, kod değişikliklerinin otomatik olarak test edilmesini, derlenmesini
ve dağıtılmasını sağlayarak geliştirme döngüsünü hızlandırır ve insan hatasını azaltır.
Aura projesinin monorepo yapısı için, hem Flutter uygulamasını hem de FastAPI
backend'ini yönetebilen çoklu pipeline (iş akışı) desteği sunan Codemagic, ideal bir
CI/CD platformudur.
58
8.1. Çoklu Pipeline Mimarisi (codemagic.yaml)
Monorepo içindeki Flutter ve FastAPI projelerinin bağımsız olarak build ve deploy
edilebilmesi için codemagic.yaml dosyasında iki ayrı iş akışı (workflow) tanımlanmalıdır.
Bu iş akışları, hangi dizinlerde değişiklik yapıldığına bağlı olarak tetiklenmelidir (when:
changeset:), böylece gereksiz build'lerin önüne geçilir.
11
codemagic.yaml Örnek Yapısı:
YAML
workflows:
flutter-app-pipeline:
name: Aura Flutter App CI/CD
instance_type: mac_mini_m2
working_directory: apps/flutter_app # Bu iş akışının çalışma dizini
triggering:
events:
- pull_request
- push
branch_patterns:
- pattern: 'main'
include: true
- pattern: 'develop'
include: true
when:
changeset:
includes:
- apps/flutter_app/**
- packages/**
excludes:
- "**.md"
# --- Flutter Build, Test, Deploy Adımları ---
scripts:
- name: Flutter Analyze & Test
script: |
flutter analyze.
flutter test --coverage
- name: Build Android App Bundle
script: |
flutter build appbundle --release
- name: Build iOS IPA
script: |
flutter build ipa --release
artifacts:
- build/app/outputs/bundle/release/*.aab
- build/ios/ipa/*.ipa
publishing:
#... TestFlight ve Google Play yayınlama konfigürasyonu
fastapi-service-pipeline:
name: Aura FastAPI Service CI/CD
instance_type: linux # Docker için Linux makinesi yeterlidir
working_directory: apps/fastapi_service # Bu iş akışının çalışma dizini
triggering:
events:
- push
branch_patterns:
- pattern: 'main'
include: true
when:
changeset:
includes:
- apps/fastapi_service/**
- packages/shared_models/** # Paylaşılan modeller değişirse de tetikle
excludes:
- "**.md"
# --- FastAPI Docker Build & Deploy Adımları ---
scripts:
- name: Login to Docker Hub
script: |
echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
- name: Build and Push Docker Image
script: |
docker build -t your_docker_repo/aura-fastapi:latest.
docker push your_docker_repo/aura-fastapi:latest
- name: Trigger Deployment
script: |
# Sunucuya (örn. Kubernetes, AWS, vb.) deploy'u tetikleyen bir webhook veya script çağrısı
curl -X POST $DEPLOYMENT_WEBHOOK_URL
environment:
groups:
- docker_credentials # DOCKER_USERNAME, DOCKER_PASSWORD şifrelenmiş değişkenleri
- deployment_secrets # DEPLOYMENT_WEBHOOK_URL
● flutter-app-pipeline: Bu iş akışı, apps/flutter_app veya paylaşılan packages
dizinlerinde bir değişiklik olduğunda tetiklenir. Flutter testlerini çalıştırır, Android
(.aab) ve iOS (.ipa) için release build'leri alır ve bunları ilgili uygulama mağazalarına
dağıtır.
● fastapi-service-pipeline: Bu iş akışı ise apps/fastapi_service veya
packages/shared_models dizinlerinde bir değişiklik olduğunda çalışır. FastAPI
uygulamasını içeren bir Docker imajı oluşturur, bunu bir container registry'ye (örn.
Docker Hub, AWS ECR) push'lar ve ardından sunucuya dağıtımı tetikleyen bir
webhook'u çağırır.
61
8.2. Docker ile Dağıtım (Deployment)
FastAPI uygulamasının sunucu ortamından bağımsız, tutarlı ve ölçeklenebilir bir şekilde
çalışabilmesi için Docker ile container'ize edilmesi en iyi pratiktir.
62
Dockerfile Örneği (apps/fastapi_service/Dockerfile):
Dockerfile
# 1. Base Image: Resmi Python 3.11 slim imajını kullan
FROM python:3.11-slim
# 2. Ortam Değişkenleri
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
# 3. Çalışma Dizini
WORKDIR /app
# 4. Bağımlılıkları Kopyala ve Yükle (Koddan önce)
# Bu sıralama, kod değiştiğinde bağımlılıkların yeniden yüklenmesini önleyerek
# Docker build cache'inden faydalanmayı sağlar.
COPY requirements.txt.
RUN pip install --no-cache-dir -r requirements.txt
# 5. Uygulama Kodunu Kopyala
COPY./app./app
# 6. Uygulamayı Çalıştırma Komutu
# Gunicorn, production ortamı için Uvicorn'u yöneten bir process manager'dır.
# --workers: CPU çekirdek sayısına göre ayarlanmalıdır.
CMD
Bu Dockerfile, FastAPI uygulamasını production'a hazır bir şekilde paketler.
62
8.3. Build → Test → Deploy Süreçleri
Her pipeline, standart bir "Build, Test, Deploy" akışını takip etmelidir.
Flutter Pipeline Akışı:
1. Checkout: İlgili branch'teki kodu çeker.
2. Setup: Flutter SDK'sını ve melos'u kurar, melos bootstrap ile monorepo
bağımlılıklarını birbirine bağlar.
3. Test:
○ flutter analyze: Statik kod analizi yapar.
○ flutter test --coverage: Unit ve widget testlerini çalıştırır ve kod kapsama
raporu (lcov.info) oluşturur.
4. Build:
○ Android: flutter build appbundle ile imzalı bir App Bundle oluşturur. İmza
anahtarları (keystore), Codemagic'in şifreli ortam değişkenlerinde güvenli bir
şekilde saklanmalıdır.
64
○ iOS: flutter build ipa ile bir IPA dosyası oluşturur. Kod imzalama için sertifikalar
ve provisioning profilleri, Codemagic'in App Store Connect entegrasyonu
aracılığıyla yönetilir.
65
5. Deploy (Publishing):
○ Oluşturulan .aab dosyasını Google Play Console'un belirtilen bir kanalına (örn.
internal, alpha) yükler.
64
○ Oluşturulan .ipa dosyasını App Store Connect'e yükler ve TestFlight'taki belirli
test gruplarına dağıtır.
67
FastAPI Pipeline Akışı:
1. Checkout: Kodu çeker.
2. Setup: Docker ortamını hazırlar.
3. Test: Python pytest ile unit ve entegrasyon testlerini çalıştırır.
4. Build: Dockerfile'ı kullanarak FastAPI uygulamasının Docker imajını oluşturur.
5. Push: Oluşturulan imajı, versiyon etiketiyle (örn. git commit hash'i) birlikte
container registry'ye push'lar. Codemagic, Docker Hub, Google Container
Registry, AWS ECR gibi popüler registry'lerle entegre olabilir.
69
6. Deploy: Sunucu ortamına (örn. bir Kubernetes cluster'ı veya bir PaaS hizmeti) yeni
imajı çekip çalıştırması için bir sinyal gönderir. Bu genellikle bir webhook çağrısı
veya bir kubectl apply gibi bir komutun SSH üzerinden çalıştırılmasıyla yapılır.
Bu otomatikleştirilmiş süreçler, geliştiricilerin kod yazmaya odaklanmasını sağlarken,
uygulamanın her zaman test edilmiş ve dağıtıma hazır bir sürümünün bulunmasını
garantiler.
Kısım 9: Gözlemlenebilirlik: İzleme, Loglama ve Hata Yönetimi
Gözlemlenebilirlik (Observability), bir sistemin iç durumunu dış çıktılarından (loglar,
metrikler, izler) anlama yeteneğidir. Aura gibi dağıtık bir yapıda (Flutter istemcisi +
FastAPI servisi), bir sorunun kaynağını hızlıca bulabilmek ve kullanıcı deneyimini
proaktif olarak iyileştirebilmek için güçlü bir gözlemlenebilirlik stratejisi şarttır. Bu
strateji üç temel üzerine kuruludur: Hata İzleme (Error Tracking), Merkezi Loglama
(Centralized Logging) ve Dağıtık İzleme (Distributed Tracing).
9.1. Sentry ve Firebase Crashlytics Yapılandırması
Hem Sentry hem de Firebase Crashlytics, kilitlenme (crash) ve hata raporlama için
endüstri standardı araçlardır. Her ikisinin de kendine özgü avantajları vardır ve birlikte
kullanılmaları, en kapsamlı hata izleme çözümünü sunar.
Karşılaştırma ve Strateji:
● Firebase Crashlytics: Özellikle mobil platformlar (iOS, Android) için optimize
edilmiştir. Gerçek zamanlı ve detaylı kilitlenme raporları sunar. Firebase
ekosistemiyle (Analytics, Remote Config vb.) derin entegrasyonu vardır. Flutter için
kurulumu firebase_crashlytics paketi ile oldukça basittir.
71
● Sentry: Sadece kilitlenmeleri değil, aynı zamanda yakalanan hataları (caught
exceptions), performans sorunlarını (yavaş işlemler, UI donmaları) ve daha
fazlasını izleyen daha kapsamlı bir uygulama izleme platformudur. Hem frontend
(Flutter) hem de backend (FastAPI) desteği sunması, onu Aura'nın hibrit mimarisi
için ideal kılar. Bu sayede, tüm sistemdeki hatalar tek bir platformda görülebilir.
71
Tavsiye Edilen Strateji: İkisini Birlikte Kullanmak
Crashlytics, özellikle işletim sistemi seviyesindeki (native) kilitlenmeler için birincil araç olarak
kullanılabilirken, Sentry, Dart/Python seviyesindeki hatalar, performans izleme ve
frontend-backend arası hata takibi için kullanılmalıdır.74
Yapılandırma Adımları:
1. Bağımlılıkları Ekleme: pubspec.yaml dosyasına sentry_flutter ve
firebase_crashlytics paketleri eklenir. FastAPI projesine ise sentry-sdk[fastapi]
eklenir.
75
2. main.dart'ta Başlatma: Her iki servis de uygulamanın başlangıcında, runApp'ten
önce başlatılmalıdır. Hataların her iki servise de gönderilmesi için global bir hata
yakalayıcı (global error handler) kurulmalıdır.
Örnek Kod Şablonu (main.dart):
Dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
Future<void> main() async {
// runZonedGuarded, uygulama seviyesindeki tüm senkron ve asenkron hataları yakalar.
await runZonedGuarded<Future<void>>(
() async {
WidgetsFlutterBinding.ensureInitialized();
// Firebase'i başlat
await Firebase.initializeApp(
// options: DefaultFirebaseOptions.currentPlatform,
);
// Flutter framework tarafından yakalanan hataları yönlendir
FlutterError.onError = (errorDetails) {
FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
Sentry.captureException(errorDetails.exception, stackTrace: errorDetails.stack);
};
// Sentry'yi başlat
await SentryFlutter.init(
(options) {
options.dsn = 'YOUR_SENTRY_DSN';
options.tracesSampleRate = 1.0; // Performans izleme için
},
appRunner: () => runApp(const MyApp()),
);
},
(error, stack) {
// runZonedGuarded tarafından yakalanan hataları yönlendir
FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
Sentry.captureException(error, stackTrace: stack);
},
);
}
Bu yapılandırma, hem Flutter framework'ünün kendi içinde yakaladığı hataları
(FlutterError.onError) hem de Dart Zone'u tarafından yakalanan tüm diğer hataları her
iki servise de güvenilir bir şekilde gönderir.
76
9.2. Flutter ve FastAPI için Merkezi Loglama
Loglama, bir hata oluştuğunda veya beklenmedik bir davranış gözlemlendiğinde, olayın
öncesinde ve sırasında sistemde neler olduğunu anlamak için kritik öneme sahiptir.
Flutter için Loglama:
logger paketi, geliştirme sırasında konsola renkli ve okunabilir loglar basmak için mükemmeldir.
Production ortamında ise, bu logların Sentry gibi bir platforma "breadcrumb" (adım izi) olarak
gönderilmesi, hataların bağlamını anlamayı kolaylaştırır.
● LogOutput Entegrasyonu: logger paketi, logların nereye gönderileceğini
belirleyen LogOutput sınıflarını destekler. Sentry'ye breadcrumb göndermek için
özel bir SentryLogOutput oluşturulabilir.
FastAPI için Loglama:
Python'un standart logging modülü, yapılandırılabilir ve güçlü bir çözümdür. Production
ortamında, logların JSON formatında basılması, log yönetim sistemleri (örn. Datadog, ELK
Stack) tarafından kolayca ayrıştırılmasını (parse) sağlar.77
● Yapılandırma: logging.config.dictConfig kullanılarak log formatı, seviyesi ve
handler'ları merkezi olarak yapılandırılmalıdır.
● En İyi Pratikler:
○ Log seviyelerini (DEBUG, INFO, WARNING, ERROR) doğru kullanmak.
77
○ Hassas verileri (şifreler, API anahtarları) loglamaktan kaçınmak için filtreler
kullanmak.
78
○ Her log mesajına, isteğin takibini sağlayan bir request_id eklemek (aşağıda
detaylandırılmıştır).
9.3. Olay Takibi ve Log İlişkilendirme (Dağıtık İzleme)
Bir kullanıcının Flutter uygulamasında yaptığı bir eylem, FastAPI servisine bir istek
gönderebilir ve bu servis de Supabase veritabanına birden fazla sorgu yapabilir. Bu
dağıtık sistemde bir sorun olduğunda, bu adımların hepsini birbirine bağlayabilmek
hayati önem taşır. Bu, dağıtık izleme (distributed tracing) ile sağlanır.
Mimari Uygulama:
1. Trace ID (İzleme ID'si) Oluşturma: Flutter'daki DioClient interceptor'ı, her giden
REST isteği için benzersiz bir ID (örn. bir UUID) üretir. Bu ID, X-Request-ID adında
bir HTTP başlığına eklenir.
79
Dart
// Dio Interceptor içinde
options.headers = const Uuid().v4();
2. FastAPI'de Trace ID'yi Yakalama: FastAPI tarafında bir middleware, gelen
isteklerdeki X-Request-ID başlığını okur. Eğer başlık yoksa, yeni bir tane oluşturur.
Bu ID, isteğin yaşam döngüsü boyunca erişilebilir olmalıdır.
80
3. ContextVar ile Trace ID'yi Taşıma: FastAPI asenkron bir framework olduğu için,
request_id'yi global bir değişkende saklamak güvenli değildir. Bunun yerine,
Python'un contextvars modülü kullanılmalıdır. Middleware, request_id'yi bir
ContextVar'a atar. Bu sayede, aynı istek içinde çalışan tüm fonksiyonlar (servisler,
repository'ler) bu ID'ye güvenli bir şekilde erişebilir.
81
4. Loglara Trace ID'yi Ekleme: Python'un logging modülü için özel bir Filter
yazılarak, her log kaydına o anki ContextVar'dan okunan request_id otomatik
olarak eklenir.
83
5. Sentry'ye Trace ID'yi Ekleme: Sentry SDK, loglara eklenen bu request_id'yi bir
"tag" olarak yakalayacak şekilde yapılandırılabilir.
Örnek FastAPI Middleware ve Logging Filter:
Python
# app/middleware.py
import uuid
from contextvars import ContextVar
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
REQUEST_ID_CTX_VAR = ContextVar('request_id', default=None)
class RequestIdMiddleware(BaseHTTPMiddleware):
async def dispatch(self, request: Request, call_next):
request_id = request.headers.get('X-Request-ID') or str(uuid.uuid4())
REQUEST_ID_CTX_VAR.set(request_id)
response = await call_next(request)
response.headers = request_id
return response
# app/logging_config.py
import logging
from.middleware import REQUEST_ID_CTX_VAR
class RequestIdFilter(logging.Filter):
def filter(self, record):
record.request_id = REQUEST_ID_CTX_VAR.get()
return True
#... logging.dictConfig içinde filter'ı ve format'ı yapılandır
# 'format': '[%(asctime)s][%(levelname)s][%(request_id)s] %(message)s'
Bu yapı sayesinde, Sentry veya başka bir log yönetim sisteminde, belirli bir
request_id'ye göre filtreleme yaparak, bir kullanıcı eyleminin Flutter'dan başlayıp
FastAPI üzerinden veritabanına kadar olan tüm yolculuğunu adım adım izleyebilirsiniz.
Bu, hata ayıklama süresini dakikalara indirgeyebilir.
Bölüm IV: Kullanıcı Odaklı Özellikler ve Uyumluluk
Kısım 10: Performans Optimizasyonu ve Bellek Yönetimi
Yüksek performanslı ve akıcı bir kullanıcı deneyimi, Aura gibi görsel açıdan zengin ve
etkileşimli bir uygulama için başarının anahtarıdır. Performans optimizasyonu, tek
seferlik bir görev değil, geliştirme yaşam döngüsünün her aşamasında dikkate alınması
gereken sürekli bir süreçtir. Bu bölüm, Flutter özelinde widget yeniden oluşturmalarını
(rebuilds), büyük listelerin yönetimini, görsel önbelleklemeyi ve bellek sızıntılarını
önleme tekniklerini ele almaktadır.
10.1. Widget Yeniden Oluşturma (Rebuild) Optimizasyonları
Flutter'ın deklaratif yapısında, state (durum) değiştiğinde UI yeniden oluşturulur. Ancak
gereksiz yeniden oluşturmalar, uygulamanın yavaşlamasına ve "jank" olarak bilinen
takılmalara neden olabilir. Amaç, state değişikliklerinden sadece etkilenen en küçük
widget alt ağacının yeniden oluşturulmasını sağlamaktır.
85
Stratejiler:
1. const Kullanımı: Değişmeyen widget'lar ve değerler için const anahtar kelimesini
kullanmak, Flutter'ın bu widget'ları yeniden oluşturma adımını tamamen atlamasını
sağlayan en etkili ve en basit optimizasyondur. flutter_lints paketinin
prefer_const_constructors gibi kuralları, bu pratiği teşvik eder.
86
2. Widget'ları Ayırma: Büyük bir build metoduna sahip tek bir widget yerine, UI'ı
daha küçük, mantıksal widget'lara bölmek gerekir. Bu, bir setState veya ref.watch
çağrısının sadece ilgili küçük widget'ı yeniden oluşturmasını sağlar, tüm ekranı
değil.
85
○ Aura Senaryosu: WardrobeHomeScreen'de, arama çubuğu, filtre butonu ve
ızgara listesi ayrı widget'lar olmalıdır. Arama çubuğuna metin girildiğinde
sadece arama çubuğu widget'ının yeniden oluşturulması (eğer kendi lokal
state'ini yönetiyorsa), tüm ekranın yeniden çizilmemesi hedeflenmelidir.
3. Riverpod'da select Kullanımı: Bir provider'dan gelen nesnenin tamamı yerine
sadece belirli bir özelliğini dinlemek için ref.watch(provider.select((value) =>
value.someProperty)) kullanılabilir. Bu, sadece izlenen özellik değiştiğinde
widget'ın yeniden oluşturulmasını sağlar, nesnenin diğer özellikleri değiştiğinde
değil. Bu, özellikle karmaşık state nesneleriyle çalışırken çok etkilidir.
4. RepaintBoundary Kullanımı: Karmaşık animasyonlar veya sık güncellenen UI
parçaları (örneğin, bir zamanlayıcı) gibi, diğer statik UI elemanlarından bağımsız
olarak sürekli yeniden çizilen widget'ları bir RepaintBoundary ile sarmak, bu
yeniden çizim işlemini kendi katmanına izole eder. Bu, Flutter'ın tüm ekranı yeniden
boyamasını (repaint) engeller.
87
10.2. Büyük Liste Yönetimi ve Sayfalama (Pagination)
Aura'nın "Gardırop", "Sosyal Akış" ve "Kombinlerim" gibi ekranları potansiyel olarak
yüzlerce, hatta binlerce öğe içerebilir. Tüm bu veriyi tek seferde yüklemek ve render
etmek, hem başlangıç yükleme süresini artırır hem de aşırı bellek tüketimine yol açar.
88
En İyi Pratikler:
1. ListView.builder / GridView.builder Kullanımı: Bu widget'lar, listeyi "tembel"
(lazy) bir şekilde oluşturur. Yani, sadece ekranda görünür olan veya görünmek
üzere olan öğeleri render ederler. Bu, büyük listeler için standart ve en verimli
yaklaşımdır.
89
2. API Seviyesinde Sayfalama: Backend (Supabase/FastAPI), veriyi küçük
"sayfalar" halinde (örn. her sayfada 20 öğe) döndürmelidir. Flutter uygulaması,
başlangıçta sadece ilk sayfayı ister.
3. Sonsuz Kaydırma (Infinite Scrolling): Kullanıcı listenin sonuna yaklaştığında, bir
sonraki veri sayfası otomatik olarak istenir ve mevcut listeye eklenir. Bu, kesintisiz
bir gezinme deneyimi sunar.
○ Uygulama: Bir ScrollController kullanılarak kullanıcının kaydırma pozisyonu
dinlenir. controller.position.pixels >= controller.position.maxScrollExtent * 0.9
gibi bir koşul sağlandığında ve yeni bir sayfa yüklenmiyorsa, loadNextPage()
fonksiyonu tetiklenir.
88
4. Riverpod ile Sayfalama Yönetimi: Sayfalama mantığı, bir AsyncNotifier içinde
yönetilmelidir. Bu Notifier, mevcut olarak yüklenmiş öğelerin listesini, bir sonraki
sayfanın numarasını ve daha fazla veri olup olmadığını (hasReachedMax) içeren
bir state nesnesi tutmalıdır.
○ Aura Senaryosu (WardrobeController): WardrobeController'ın loadItems
metodu bir page parametresi almalı ve state'i yeni gelen öğelerle
birleştirmelidir. WardrobeLoaded state sınıfı, List<ClothingItem> items ve bool
hasReachedMax alanlarını içermelidir.
2
○ Paket Önerisi: riverpod_infinite_scroll_pagination gibi paketler, AsyncNotifier
ile sonsuz kaydırma mantığını bir mixin aracılığıyla basitleştirerek çok daha az
standart kod (boilerplate) ile bu işlevselliği eklemeyi sağlar.
90
10.3. Görsel Önbellekleme ve Yükleme Optimizasyonları
Görseller, Aura gibi bir moda uygulamasının en önemli parçasıdır. Görsellerin verimli bir
şekilde yüklenmesi ve yönetilmesi, algılanan performans üzerinde büyük bir etkiye
sahiptir.
Stratejiler:
1. cached_network_image Paketi: Bu paket, ağdan indirilen görselleri hem
hafızada (memory) hem de diskte (disk) otomatik olarak önbellekler. Bu sayede,
aynı görsel tekrar istendiğinde ağa gitmek yerine doğrudan önbellekten hızla
yüklenir. Ayrıca, görsel yüklenirken bir placeholder (yer tutucu) ve hata
durumunda bir errorWidget gösterme gibi temel UX özelliklerini de kolayca sağlar.
2
2. Yükleme Öncesi Önbellekleme (precacheImage): Kullanıcının bir sonraki
ekranda göreceği görseller önceden tahmin edilebiliyorsa (örn. bir listenin ilk
birkaç öğesi), precacheImage fonksiyonu kullanılarak bu görseller arka planda
önbelleğe alınabilir. Bu, kullanıcı o ekrana geçtiğinde görsellerin anında
görünmesini sağlar.
3. Görsel Boyutlarını Optimize Etme: Cihaza, gösterileceği alandan çok daha
büyük çözünürlükte görseller indirmek, bant genişliğini ve belleği boşa harcar.
Supabase Storage veya özel bir CDN (İçerik Dağıtım Ağı) kullanarak, cihazın ekran
boyutuna ve yoğunluğuna uygun, farklı boyutlarda görseller sunulmalıdır. Örneğin,
bir ListView içindeki küçük bir thumbnail için tam çözünürlüklü bir görsel yerine
150x150 piksel boyutunda bir versiyonu istenmelidir.
4. Görsel Formatı: WebP gibi modern ve verimli görsel formatları, JPEG ve PNG'ye
göre daha iyi sıkıştırma sunarak dosya boyutlarını ve dolayısıyla yükleme sürelerini
azaltır.
10.4. Bellek Sızıntılarını (Memory Leaks) Önleme Teknikleri
Bellek sızıntıları, artık ihtiyaç duyulmayan nesnelerin hafızadan temizlenmemesi
sonucu uygulamanın zamanla yavaşlamasına ve hatta çökmesine neden olabilir.
En İyi Pratikler:
1. dispose() Metodunu Doğru Kullanma: StatefulWidget'ların State nesneleri
içinde oluşturulan StreamSubscription, ScrollController, AnimationController gibi
nesneler, widget ağaçtan kaldırıldığında dispose() metodu içinde mutlaka
sonlandırılmalıdır (cancel(), dispose()).
2. Riverpod'da autoDispose: Daha önce de belirtildiği gibi, geçici durumlar için
autoDispose kullanmak, provider'ın durumunun otomatik olarak temizlenmesini
sağlayarak bellek sızıntılarını önlemenin en etkili yollarından biridir.
25
3. Statik Referanslardan Kaçınma: Bir BuildContext'e veya bir State nesnesine
statik bir referans tutmak, bu nesnelerin çöp toplayıcı (garbage collector)
tarafından temizlenmesini engelleyerek ciddi bellek sızıntılarına yol açabilir.
4. Flutter DevTools Kullanımı: Geliştirme sırasında Flutter DevTools'un "Memory"
sekmesi, bellek kullanımını izlemek, nesnelerin nasıl tahsis edildiğini görmek ve
potansiyel sızıntıları tespit etmek için paha biçilmez bir araçtır.
Kısım 11: Hata Yönetimi ve Kullanıcı Deneyimi
Sağlam bir hata yönetimi mimarisi, sadece uygulamanın çökmesini engellemekle
kalmaz, aynı zamanda bir şeyler ters gittiğinde kullanıcıya net, anlaşılır ve eyleme
geçirilebilir geri bildirimler sunarak güven oluşturur. Hata yönetimi, teknik bir gereklilik
olduğu kadar bir kullanıcı deneyimi (UX) tasarımı konusudur.
11.1. Merkezi Hata Yönetimi Mimarisi
Hataları her yerde ayrı ayrı try-catch blokları ile yönetmek yerine, hataları yakalamak,
loglamak ve kullanıcıya sunmak için merkezi bir mekanizma kurulmalıdır. Bu, tutarlılık
sağlar ve kod tekrarını azaltır.
Mimari Öneriler:
1. ProviderObserver ile Global Hata Yakalama: Riverpod, ProviderObserver sınıfı
aracılığıyla tüm provider yaşam döngüsü olaylarını dinleme imkanı sunar.
providerDidFail metodu override edilerek, bir provider'ın state'i oluşturulurken
veya güncellenirken oluşan tüm hatalar tek bir yerden yakalanabilir. Bu, hataları
merkezi bir loglama servisine (Sentry, Crashlytics) göndermek için ideal bir
noktadır.
92
Dart
// core/observers/app_provider_observer.dart
class AppProviderObserver extends ProviderObserver {
@override
void providerDidFail(
ProviderBase provider,
Object error,
StackTrace stackTrace,
ProviderContainer container,
) {
// Hataları burada Sentry veya Crashlytics'e gönder
debugPrint('PROVIDER FAILED: $error\n$stackTrace');
}
}
// main.dart içinde ProviderScope'a eklenir:
// ProviderScope(observers: [AppProviderObserver()], child: MyApp())
2. Repository Katmanında Hata Soyutlama: Data katmanından gelen ham hatalar
(örn. DioException, PostgrestException) doğrudan UI veya Application katmanına
sızmamalıdır. Repository katmanı, bu platforma özgü hataları yakalayıp,
NetworkFailure, ServerFailure, CacheFailure gibi Domain katmanında tanımlanmış
daha genel ve anlaşılır hata türlerine dönüştürmelidir. Bu, üst katmanların veri
kaynağının detaylarından soyutlanmasını sağlar.
3. AsyncValue.error ile UI'a Hata Taşıma: AsyncNotifier'lar, yakaladıkları hataları
state = AsyncValue.error(error, stackTrace) şeklinde kendi durumlarına
yansıtmalıdır. Bu, UI katmanının .when metodu ile bu hata durumunu zarifçe ele
almasına olanak tanır.
93
11.2. Kullanıcı Dostu Hata Mesajları ve Geri Bildirim Mekanizmaları
Kullanıcıya "Bir hata oluştu" gibi genel bir mesaj göstermek yerine, hatanın ne olduğu
ve ne yapabilecekleri konusunda rehberlik eden mesajlar sunulmalıdır.
En İyi Pratikler:
1. Anlaşılır Mesajlar: Teknik jargon içermeyen, basit ve net bir dil kullanılmalıdır.
Örneğin, "SocketException" yerine "Lütfen internet bağlantınızı kontrol edin."
mesajı gösterilmelidir. Bu çeviriler, merkezi bir ErrorHandler servisi tarafından
yapılabilir.
2. SnackBar ve Dialog Kullanımı:
○ SnackBar: Geçici ve daha az kritik hatalar için (örn. "Favorilere eklenemedi,
tekrar deneyin.") uygundur.
○ Dialog: Kullanıcının onayını veya dikkatini gerektiren kritik hatalar için (örn.
"Oturumunuzun süresi doldu, lütfen tekrar giriş yapın.") kullanılmalıdır. Aura
proje dökümanları, silme gibi kritik işlemler için Dialog kullanımını özellikle
belirtmektedir.
2
3. Boş ve Hata Durumları için Özel Widget'lar: WardrobeErrorView ve
EmptyWardrobeView gibi, Aura dökümanlarında belirtilen özel widget'lar,
kullanıcıya sadece bir hata mesajı göstermekle kalmaz, aynı zamanda bir sonraki
adımı (örn. "Tekrar Dene" butonu veya "İlk Kıyafetini Ekle" butonu) sunarak
kullanıcıyı yönlendirir.
2
11.3. Yükleme Durumları (Loading States) ve Yeniden Deneme (Retry) Butonları
Bir işlem devam ederken veya veri yüklenirken kullanıcıyı bilgilendirmek, uygulamanın
donduğu veya çalışmadığı izlenimini engeller.
Stratejiler:
1. İskelet Yükleyiciler (Shimmer Effect): Verinin geleceği yerin şeklini taklit eden
iskelet animasyonları (shimmer efekti), basit bir CircularProgressIndicator'dan
daha iyi bir kullanıcı deneyimi sunar. shimmer paketi bu amaçla kullanılabilir. Aura
dökümanları, WardrobeLoadingView için bu tekniği önermektedir.
2
2. İşlem Butonlarında Yükleme Göstergesi: Bir butona tıklandığında başlayan bir
işlem sırasında (örn. "Kaydet"), butonun kendisi devre dışı bırakılıp içinde bir
yükleme göstergesi gösterilmelidir. Bu, kullanıcının aynı eylemi tekrar tekrar
tetiklemesini engeller.
3. Yeniden Deneme (Retry) İşlevselliği: Bir ağ hatası oluştuğunda, hata mesajının
yanında mutlaka bir "Tekrar Dene" butonu sunulmalıdır. Bu buton, ilgili Riverpod
provider'ını geçersiz kılmalı (ref.invalidate(provider)) ve bu da verinin yeniden
çekilmesini tetiklemelidir. AsyncValue.when'in error callback'i, bu işlevselliği
uygulamak için mükemmel bir yerdir.
95
Örnek Kod Şablonu (Hata Widget'ı):
Dart
import 'package:flutter/material.dart';
class AppErrorView extends StatelessWidget {
const AppErrorView({
super.key,
required this.message,
this.onRetry,
});
final String message;
final VoidCallback? onRetry;
@override
Widget build(BuildContext context) {
return Center(
child: Padding(
padding: const EdgeInsets.all(16.0),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children:,
),
),
);
}
}
Bu AppErrorView widget'ı, uygulama genelinde tutarlı bir hata gösterimi sağlar ve
yeniden deneme işlevselliğini opsiyonel olarak sunar.
Kısım 12: Analitik ve Kullanıcı Davranışı Takibi
Kullanıcıların uygulama içinde ne yaptığını anlamak, hangi özelliklerin popüler
olduğunu, nerelerde zorlandıklarını ve genel etkileşim düzeylerini ölçmek, ürün
geliştirme sürecini veri odaklı bir hale getirmek için zorunludur. Firebase Analytics, bu
amaçla kullanılabilecek güçlü ve Flutter ile kolayca entegre edilebilen bir araçtır.
12.1. Firebase Analytics Entegrasyonu
Kurulum ve Yapılandırma:
1. Firebase Projesi: Aura için bir Firebase projesi oluşturulmalı ve Flutter uygulaması
bu projeye flutterfire_cli kullanılarak bağlanmalıdır.
96
2. Bağımlılık Ekleme: pubspec.yaml dosyasına firebase_analytics paketi
eklenmelidir.
3. Otomatik Ekran Takibi: firebase_analytics paketi, FirebaseAnalyticsObserver
aracılığıyla standart Navigator geçişlerini otomatik olarak loglayabilir. Ancak, Aura
projesinde go_router kullanıldığı için, ekran geçişlerini loglamak amacıyla özel bir
GoRouterObserver oluşturulmalıdır.
Örnek GoRouterObserver ile Otomatik Ekran Görüntüleme Loglaması:
go_router'ın observers listesine eklenecek özel bir Observer, her sayfa geçişinde
(didPush, didPop vb.) otomatik olarak bir screen_view olayı gönderebilir.
97
Dart
// core/navigation/analytics_observer.dart
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
class AnalyticsObserver extends NavigatorObserver {
@override
void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
super.didPush(route, previousRoute);
_logScreenView(route);
}
@override
void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
super.didPop(route, previousRoute);
_logScreenView(previousRoute);
}
@override
void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
_logScreenView(newRoute);
}
void _logScreenView(Route<dynamic>? route) {
final screenName = route?.settings.name;
if (screenName!= null) {
FirebaseAnalytics.instance.logScreenView(screenName: screenName);
debugPrint('Analytics: Screen view logged: $screenName');
}
}
}
// go_router yapılandırmasında:
// final _router = GoRouter(
// observers: [AnalyticsObserver()],
// routes: [...]
// );
12.2. Özel Olay (Custom Event) Takibi
Ekran görüntülemelerinin ötesinde, kullanıcıların gerçekleştirdiği önemli eylemlerin de
özel olaylar olarak loglanması gerekir. Bu, özelliklerin kullanım metriklerini ve kullanıcı
hunilerini (funnels) oluşturmayı sağlar.
Mimari Öneriler:
1. Merkezi AnalyticsService: Tüm analitik çağrıları, soyut bir AnalyticsService
arayüzü ve onun FirebaseAnalytics'i kullanan somut bir implementasyonu
üzerinden yapılmalıdır. Bu, gelecekte analitik sağlayıcısını değiştirme esnekliği
sunar ve testlerde kolayca mock'lanabilir.
2. Standart Olay İsimlendirme: Olay isimleri ve parametreleri için tutarlı bir
isimlendirme şeması belirlenmelidir (örn. eylem_nesne, item_favorited).
Aura için İzlenmesi Gereken Temel Özel Olaylar:
● login, signup, logout
● wardrobe_item_added (parametreler: category, source: 'ai' | 'manual')
● wardrobe_item_deleted
● item_favorited, item_unfavorited (parametre: item_id)
● combination_created (parametre: item_count)
● combination_shared (parametre: platform: 'instagram' | 'other')
● style_assistant_query (parametre: query_length)
● swap_item_listed, swap_interest_shown
Örnek Kod Şablonu (AnalyticsService):
Dart
// core/services/analytics_service.dart
import 'package:firebase_analytics/firebase_analytics.dart';
abstract class AnalyticsService {
Future<void> logEvent(String name, {Map<String, Object>? parameters});
Future<void> setUserId(String id);
}
class FirebaseAnalyticsService implements AnalyticsService {
final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
@override
Future<void> logEvent(String name, {Map<String, Object>? parameters}) {
return _analytics.logEvent(name: name, parameters: parameters);
}
@override
Future<void> setUserId(String id) {
return _analytics.setUserId(id: id);
}
}
// Riverpod ile sağlanması
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
return FirebaseAnalyticsService();
});
Kullanım Senaryosu: Kullanıcı Bir Kıyafeti Favorilediğinde
WardrobeController içinde, toggleFavorite metodu analitik olayını tetiklemelidir.
Dart
// features/wardrobe/application/wardrobe_controller.dart
//...
Future<void> toggleFavorite(String itemId, bool isFavorite) async {
//... favoriye ekleme/çıkarma API çağrısı
// Analitik olayını logla
final analyticsService = ref.read(analyticsServiceProvider);
analyticsService.logEvent(
isFavorite? 'item_favorited' : 'item_unfavorited',
parameters: {'item_id': itemId},
);
}
12.3. Kullanıcı Davranış Analizi ve A/B Testi Hazırlığı
Toplanan analitik veriler, kullanıcı davranışlarını anlamak için kullanılır. Firebase konsolu,
olay sayıları, kullanıcı segmentleri ve dönüşüm hunileri gibi temel analizler sunar.
A/B Testi için Mimari Hazırlık:
Gelecekte A/B testleri (örn. farklı bir "Kıyafet Ekle" butonu renginin dönüşüme etkisini ölçmek)
yapmak için mimarinin buna hazır olması gerekir.
1. Firebase Remote Config: A/B testlerinin değişkenleri (örn. button_color: 'purple'
| 'green') Firebase Remote Config ile yönetilmelidir. Uygulama, başlangıçta bu
konfigürasyonları çeker.
2. Özellik Bayrakları (Feature Flags): Remote Config'den gelen değerler, bir
FeatureFlagService aracılığıyla uygulama koduna sunulur. UI, bir rengi veya bir
metni doğrudan kodlamak yerine bu servisten gelen değere göre kendini
yapılandırır.
3. Analitik Entegrasyonu: A/B testinin bir parçası olan kullanıcılar, Firebase
Analytics'te bir "kullanıcı özelliği" (user property) ile etiketlenmelidir (örn.
experiment_button_color: 'purple'). Bu, Firebase konsolunda her bir varyantın (A
ve B grupları) başarı metriklerini (örn. wardrobe_item_added olay sayısı)
karşılaştırmayı mümkün kılar.
Bu yapı, ürün ekibinin yeni fikirleri kod değişikliği ve yeni bir uygulama sürümü
yayınlamadan hızlıca test etmesine olanak tanır.
Bölüm V: Güvenlik, Dokümantasyon ve Geleceğe Yönelik
Ölçeklenme
Kısım 13: Karanlık Mod ve Erişilebilirlik (a11y)
Modern bir mobil uygulama, sadece estetik ve işlevsel olmakla kalmamalı, aynı
zamanda tüm kullanıcılar için erişilebilir ve konforlu bir deneyim sunmalıdır. Bu, farklı
aydınlatma koşullarına uyum sağlayan bir karanlık mod ve engelli kullanıcıların
uygulamayı rahatça kullanabilmesini sağlayan erişilebilirlik (accessibility - a11y)
özelliklerini içerir.
13.1. Sistem Teması ile Uyumlu Karanlık Mod
Kullanıcıların çoğu, işletim sistemi seviyesinde tercih ettikleri bir temaya (açık veya
koyu) sahiptir. Uygulamanın bu tercihe otomatik olarak uyum sağlaması, tutarlı ve
beklenen bir kullanıcı deneyimi sunar.
Mimari Öneriler:
1. ThemeData Tanımlamaları: Kısım 5'te detaylandırıldığı gibi, AppTheme sınıfı
içinde hem lightTheme hem de darkTheme adında iki ayrı ThemeData nesnesi
tanımlanmalıdır. Bu temalar, Material 3 ColorScheme'ini kullanarak hem açık hem
de koyu mod için uyumlu renk paletleri sağlamalıdır.
2. MaterialApp Yapılandırması: MaterialApp widget'ı, bu iki temayı ve sistem
temasını nasıl kullanacağını belirleyen üç temel özellikle yapılandırılmalıdır:
○ theme: Uygulamanın varsayılan (açık) temasını belirtir.
○ darkTheme: Cihaz karanlık moda geçtiğinde kullanılacak temayı belirtir.
○ themeMode: Temanın nasıl seçileceğini belirler. ThemeMode.system olarak
ayarlandığında, uygulama otomatik olarak cihazın tema ayarını takip eder.
3. Kullanıcıya Özel Tema Seçimi: Kullanıcıya uygulama ayarlarından temayı manuel
olarak (Açık, Koyu, Sistem Varsayılanı) seçme imkanı sunulmalıdır. Bu tercih, bir
Riverpod provider'ı (themeModeProvider) ile yönetilmeli ve SharedPreferences ile
cihaza kaydedilmelidir. MaterialApp'in themeMode özelliği bu provider'ı
dinlemelidir.
Örnek Kod Şablonu (main.dart):
Dart
//...
// theme_provider.dart içinde bir StateProvider<ThemeMode> tanımlı
final themeMode = ref.watch(themeModeProvider);
return MaterialApp(
title: 'Aura',
theme: AppTheme.lightTheme,
darkTheme: AppTheme.darkTheme,
themeMode: themeMode, // Provider'dan gelen değeri kullan
//...
);
13.2. Erişilebilirlik (a11y) Destekleri ve Kontrol Listesi
Erişilebilirlik, uygulamanın görme, işitme veya motor becerilerinde kısıtlamaları olan
kullanıcılar tarafından da kullanılabilir olmasını sağlamaktır. Flutter, Semantics widget'ı
aracılığıyla bu konuda güçlü bir temel sunar.
98
Aura için Erişilebilirlik Kontrol Listesi:
Aşağıdaki tablo, geliştirme sürecinde takip edilmesi gereken temel erişilebilirlik
standartlarını ve Flutter'daki karşılıklarını özetlemektedir.
Kılavuz Açıklama Flutter'da Uygulama Doğrulama Yöntemi
Anlamsal Etiketler
(Semantic Labels)
Ekranda metin
içermeyen interaktif
elemanların (ikon
butonları gibi) ne işe
yaradığını ekran
okuyuculara
bildirmek.
IconButton gibi
widget'ların tooltip
veya semanticsLabel
özelliklerini
kullanmak. Semantics
widget'ı ile özel
etiketler eklemek.
TalkBack (Android)
veya VoiceOver (iOS)
ile test etme. Etiketsiz
butonlar "isimsiz
düğme" olarak
okunur.
99
Dokunma Hedefi
Boyutu (Tap Target
Size)
Tüm tıklanabilir
öğelerin, motor
becerileri kısıtlı
kullanıcılar için
yeterince büyük
Öğelerin minimum
48x48 mantıksal
piksel boyutunda
olmasını sağlamak.
Gerekirse SizedBox
Flutter Inspector'da
"Highlight Tappable
Areas" seçeneğini
kullanmak. flutter test
ile
olmasını sağlamak. veya Padding ile
dokunma alanını
genişletmek.
androidTapTargetGui
deline kontrolünü
çalıştırmak.
100
Metin Kontrast
Oranı
Metnin arka plan
rengiyle yeterli
kontrasta sahip
olarak görme
bozukluğu olan
kullanıcılar için
okunabilir olmasını
sağlamak.
W3C standartlarına
göre küçük metinler
için en az 4.5:1, büyük
metinler için en az
3.0:1 kontrast oranı
hedeflemek.
ThemeData'daki
renklerin bu oranları
karşıladığından emin
olmak.
Flutter DevTools'da
"Highlight Oversized
Images" altında
kontrast sorunları
görülebilir. Online
kontrast denetleyici
araçlar kullanmak.
Dinamik Font
Boyutu
Kullanıcının cihaz
ayarlarında belirlediği
font boyutuna
uygulamanın uyum
sağlaması.
Layout'ların, metin
boyutu büyüdüğünde
taşma (overflow)
yapmayacak şekilde
Expanded, Flexible
gibi esnek
widget'larla
tasarlanması.
Cihazın Ayarlar >
Ekran > Yazı Tipi
Boyutu menüsünden
en büyük boyutu
seçerek UI'ı test
etmek.
100
13.3. Ekran Okuyucu Optimizasyonları
Ekran okuyucular, UI'ı doğrusal bir şekilde okur. Bu nedenle, anlamsal ağacın
(semantics tree) mantıksal bir sırada olması önemlidir.
● Semantics Widget'ı: Belirli bir widget alt ağacının nasıl okunacağını özelleştirmek
için kullanılır. Örneğin, bir ListTile'daki birden fazla Text widget'ını tek bir mantıksal
birim olarak birleştirmek için MergeSemantics kullanılabilir. Bir widget'ı anlamsal
ağaçtan tamamen çıkarmak (dekoratif görseller gibi) için ise ExcludeSemantics
kullanılır.
98
● Focus Yönetimi: Bir Dialog veya BottomSheet açıldığında, ekran okuyucunun
odağının otomatik olarak bu yeni elemana taşınması gerekir. Bu, FocusScope ve
Autofocus widget'ları ile yönetilebilir.
Bu pratiklerin düzenli olarak test edilmesi, Aura'nın geniş bir kullanıcı kitlesi tarafından
erişilebilir olmasını sağlayacak ve uygulamanın kalitesini artıracaktır.
Kısım 14: Kod Kalitesi ve Statik Analiz
Yüksek kod kalitesi, bir projenin uzun vadeli sağlığı, bakım kolaylığı ve yeni
geliştiricilerin adaptasyon hızı için hayati önem taşır. Kod kalitesi, sadece "çalışan kod"
yazmak değil, aynı zamanda okunabilir, tutarlı, test edilebilir ve standartlara uygun kod
yazmaktır. Bu, linter kuralları, kod gözden geçirme (code review) süreçleri ve CI
pipeline'ına entegre edilen kalite kapıları (quality gates) ile sağlanır.
14.1. Linter Kuralları ve Özel Yapılandırma
Statik analiz araçları (linter'lar), kod daha çalıştırılmadan potansiyel hataları, stil
ihlallerini ve "code smell" olarak adlandırılan kötü pratikleri tespit eder. Dart ve Flutter
ekosisteminde bu, analysis_options.yaml dosyası üzerinden yönetilir.
Mimari Öneriler:
1. flutter_lints Paketini Temel Alma: Aura projesi, Flutter ekibi tarafından önerilen
ve flutter create ile varsayılan olarak gelen flutter_lints paketini temel almalıdır. Bu
paket, iyi kodlama alışkanlıklarını teşvik eden geniş bir kural seti içerir.
101
2. Daha Sıkı Kurallar Ekleme: flutter_lints'in üzerine, projenin kalitesini daha da
artırmak için ek kurallar etkinleştirilmelidir. lints veya pedantic gibi paketlerden
daha sıkı kurallar benimsenebilir.
3. Özel Kurallar Tanımlama: Proje genelinde tutarlılığı sağlamak için
analysis_options.yaml dosyasında ek kurallar zorunlu hale getirilmelidir.
Örnek analysis_options.yaml Yapılandırması:
YAML
include: package:flutter_lints/flutter.yaml
analyzer:
# Hatalı tipleri ve null atamalarını daha sıkı kontrol et
strong-mode:
implicit-casts: false
implicit-dynamic: false
# Belirli dosyaları analizden çıkar (örn: üretilmiş dosyalar)
exclude:
- '**/*.g.dart'
- '**/*.freezed.dart'
linter:
rules:
# flutter_lints'ten gelen kurallara ek olarak...
# Stil Kuralları
- prefer_single_quotes: true
- prefer_relative_imports: true
- always_specify_types: true
- lines_longer_than_80_chars: true # Satır uzunluğunu 80 karakterle sınırla
# Kod Kalitesi ve Hata Önleme Kuralları
- avoid_print: true # Production kodunda print() kullanımını engelle
- avoid_redundant_argument_values: true
- avoid_returning_null_for_void: true
- no_logic_in_create_state: true
- prefer_final_locals: true
- require_trailing_commas: true # Kod formatlamada tutarlılık sağlar
# Özel Lint Kuralları (custom_lint paketi ile eklenebilir)
# - custom_rule_for_riverpod_provider_naming: true
Bu yapılandırma, tüm geliştiricilerin aynı kodlama standartlarına uymasını sağlar ve
potansiyel hataları erkenden yakalar.
14.2
Alıntılanan çalışmalar
1. Supabase | The Postgres Development Platform., erişim tarihi Temmuz 30, 2025,
https://supabase.com/
2. sayfalar ve detayları.pdf
3. FastAPI - The Good, the bad and the ugly. - DEV Community, erişim tarihi Temmuz
30, 2025, https://dev.to/fuadrafid/fastapi-the-good-the-bad-and-the-ugly-20ob
4. Monorepo vs. Polyrepo: How to Choose Between Them | Buildkite, erişim tarihi
Temmuz 30, 2025,
https://buildkite.com/resources/blog/monorepo-polyrepo-choosing/
5. Monorepo vs Polyrepo: Which One Should You Choose in 2025? - DEV
Community, erişim tarihi Temmuz 30, 2025,
https://dev.to/md-afsar-mahmud/monorepo-vs-polyrepo-which-one-should-you
-choose-in-2025-g77
6. Monorepo vs Polyrepo for micro-service architecture. | by Jaspreet Singh |
Medium, erişim tarihi Temmuz 30, 2025,
https://medium.com/@jassi23/monorepo-vs-polyrepo-for-micro-service-architec
ture-e258a6e550d7
7. Part 1: Flutter Monorepos, The Why and How Melos Can Help | by David Cobbina |
Medium, erişim tarihi Temmuz 30, 2025,
https://medium.com/@davidLegend47/part-1-flutter-monorepos-the-why-and-h
ow-melos-can-help-9032f22513de
8. Benefits and challenges of monorepo development practices - CircleCI, erişim
tarihi Temmuz 30, 2025, https://circleci.com/blog/monorepo-dev-practices/
9. How to manage your Flutter monorepos | by Codemagic - Medium, erişim tarihi
Temmuz 30, 2025,
https://medium.com/flutter-community/how-to-manage-your-flutter-monorepos
-b307cdc9399a
10. How to manage your Flutter monorepos - Codemagic Blog, erişim tarihi Temmuz
30, 2025, https://blog.codemagic.io/flutter-monorepos/
11. Starting builds automatically with codemagic.yaml, erişim tarihi Temmuz 30, 2025,
https://docs.codemagic.io/yaml-running-builds/starting-builds-automatically/
12. Flutter & Monorepo — Power of Scalability | by Muhammad Hamza - Stackademic,
erişim tarihi Temmuz 30, 2025,
https://blog.stackademic.com/flutter-monorepo-power-of-scalability-e191a80d5
293
13. Clean Architecture in Flutter: A Comprehensive Guide (2024 Edition ..., erişim
tarihi Temmuz 30, 2025,
https://medium.com/@ajit.cool008/clean-architecture-in-flutter-a-comprehensiv
e-guide-2024-edition-8a5a97861626
14. Flutter Architecture Guide: Everything You Need to Know - TriState Technology,
erişim tarihi Temmuz 30, 2025,
https://www.tristatetechnology.com/blog/flutter-architecture-guide
15. Effective Layered Architecture in Large Flutter Apps | by Md. Al-Amin | Jul, 2025 |
Medium, erişim tarihi Temmuz 30, 2025,
https://medium.com/@alaminkarno/effective-layered-architecture-in-large-flutter
-apps-e4ccd3b15ac3
16. Effective Layered Architecture in Large Flutter Apps - DEV Community, erişim
tarihi Temmuz 30, 2025,
https://dev.to/alaminkarno/effective-layered-architecture-in-large-flutter-apps-2
n48
17. Common architecture concepts - Flutter Documentation, erişim tarihi Temmuz
30, 2025, https://docs.flutter.dev/app-architecture/concepts
18. Scaling Flutter Apps with Feature-First Folder Structures - DEV Community, erişim
tarihi Temmuz 30, 2025,
https://dev.to/alaminkarno/scaling-flutter-apps-with-feature-first-folder-structur
es-547f
19. Best practices for building scalable Flutter applications - Very Good Ventures,
erişim tarihi Temmuz 30, 2025,
https://verygood.ventures/blog/scalable-best-practices
20. Building a Scalable Folder Structure in Flutter Using Clean Architecture +
BLoC/Cubit, erişim tarihi Temmuz 30, 2025,
https://dev.to/alaminkarno/building-a-scalable-folder-structure-in-flutter-using-cl
ean-architecture-bloccubit-530c
21. Flutter Riverpod Clean Architecture: The Ultimate Production-Ready ..., erişim
tarihi Temmuz 30, 2025,
https://dev.to/ssoad/flutter-riverpod-clean-architecture-the-ultimate-production
-ready-template-for-scalable-apps-gdh
22. Riverpod State Management in Flutter | by Ajit Sharma - Medium, erişim tarihi
Temmuz 30, 2025,
https://medium.com/@ajit.cool008/riverpod-state-management-in-flutter-e6d88
96d1dba
23. Flutter Riverpod 2.0: The Ultimate Guide - Code With Andrea, erişim tarihi
Temmuz 30, 2025,
https://codewithandrea.com/articles/flutter-state-management-riverpod/
24. StateProvider - Riverpod, erişim tarihi Temmuz 30, 2025,
https://riverpod.dev/docs/providers/state_provider
25. Clearing cache and reacting to state disposal | Riverpod, erişim tarihi Temmuz 30,
2025, https://riverpod.dev/docs/essentials/auto_dispose
26. Riverpod AsyncValue.when is not triggering the error builder - Stack Overflow,
erişim tarihi Temmuz 30, 2025,
https://stackoverflow.com/questions/79501857/riverpod-asyncvalue-when-is-not
-triggering-the-error-builder
27. Tables and Data | Supabase Docs, erişim tarihi Temmuz 30, 2025,
https://supabase.com/docs/guides/database/tables
28. Web Developers: 7-Establishing Table Relationships in Supabase with Foreign
Keys, erişim tarihi Temmuz 30, 2025,
https://www.youtube.com/watch?v=oX_xHLkNRns&pp=0gcJCfwAo7VqN5tD
29. Row Level Security | Supabase Docs, erişim tarihi Temmuz 30, 2025,
https://supabase.com/docs/guides/database/postgres/row-level-security
30. Layered Architecture & Dependency Injection: A Recipe for Clean and Testable
FastAPI Code - DEV Community, erişim tarihi Temmuz 30, 2025,
https://dev.to/markoulis/layered-architecture-dependency-injection-a-recipe-for
-clean-and-testable-fastapi-code-3ioo
31. How to structure FastAPI app so logic is outside routes - Reddit, erişim tarihi
Temmuz 30, 2025,
https://www.reddit.com/r/FastAPI/comments/1b55e8q/how_to_structure_fastapi_
app_so_logic_is_outside/
32. Implementing Supabase Auth in FastAPI | by Phil Harper | Medium, erişim tarihi
Temmuz 30, 2025,
https://phillyharper.medium.com/implementing-supabase-auth-in-fastapi-63d9d
8272c7b
33. REST API | Supabase Docs, erişim tarihi Temmuz 30, 2025,
https://supabase.com/docs/guides/api
34. Validating a Supabase JWT locally with Python and FastAPI - DEV ..., erişim tarihi
Temmuz 30, 2025,
https://dev.to/zwx00/validating-a-supabase-jwt-locally-with-python-and-fastapi59jf
35. GraphQL vs REST API: Which Integration Method Delivers Better ..., erişim tarihi
Temmuz 30, 2025, https://www.netguru.com/blog/grapghql-vs-rest
36. GraphQL vs REST API - Difference Between API Design Architectures - AWS,
erişim tarihi Temmuz 30, 2025,
https://aws.amazon.com/compare/the-difference-between-graphql-and-rest/
37. GraphQL vs. REST: Top 4 Advantages & Disadvantages ['25] - AIMultiple, erişim
tarihi Temmuz 30, 2025, https://research.aimultiple.com/graphql-vs-rest/
38. When to choose Graphql over REST - Software Engineering Stack Exchange,
erişim tarihi Temmuz 30, 2025,
https://softwareengineering.stackexchange.com/questions/422144/when-to-cho
ose-graphql-over-rest
39. Realtime - Broadcast | Supabase Features, erişim tarihi Temmuz 30, 2025,
https://supabase.com/features/realtime-broadcast
40. Realtime | Supabase Docs, erişim tarihi Temmuz 30, 2025,
https://supabase.com/docs/guides/realtime
41. Easy real-time notifications with Supabase Realtime - Code Cry Repeat, erişim
tarihi Temmuz 30, 2025,
https://codecryrepeat.hashnode.dev/easy-real-time-notifications-with-supabase
-realtime
42. Guided tutorial on how to use GraphQL with Flutter - Hygraph, erişim tarihi
Temmuz 30, 2025, https://hygraph.com/blog/flutter-graphql
43. graphql_flutter | Flutter package - Pub.dev, erişim tarihi Temmuz 30, 2025,
https://pub.dev/packages/graphql_flutter
44. How to Use REST APIs in Flutter with Dio? - Technaureus, erişim tarihi Temmuz 30,
2025,
https://www.technaureus.com/blog-detail/how-to-use-rest-api-in-flutter-with-di
o
45. Advanced REST Communication with Dio and Retrofit in Flutter - Vibe Studio,
erişim tarihi Temmuz 30, 2025,
https://vibe-studio.ai/insights/advanced-rest-communication-with-dio-and-retrof
it
46. Real-Time Data Sync with Supabase in Flutter | by Nandhu Raj ..., erişim tarihi
Temmuz 30, 2025,
https://medium.com/@nandhuraj/real-time-data-sync-with-supabase-in-flutter-2
4183dc9fcae
47. why i ditched supabase's realtime and built my own | by Khushi Diwan | Jul, 2025 |
Medium, erişim tarihi Temmuz 30, 2025,
https://medium.com/@khushidiwan953/why-i-ditched-supabases-realtime-and-b
uilt-my-own-a6fc20c542d4
48. Use themes to share colors and font styles - Flutter Documentation, erişim tarihi
Temmuz 30, 2025, https://docs.flutter.dev/cookbook/design/themes
49. Flutter Design System | Flutter Blog by Alexander Thiele, erişim tarihi Temmuz 30,
2025, https://thiele.dev/blog/flutter-design-system/
50. graphql-flutter/packages/graphql/README.md at main - GitHub, erişim tarihi
Temmuz 30, 2025,
https://github.com/zino-hofmann/graphql-flutter/blob/main/packages/graphql/RE
ADME.md
51. graphql_flutter changelog | Flutter package - Pub.dev, erişim tarihi Temmuz 30,
2025, https://pub.dev/packages/graphql_flutter/changelog
52. How to Implement a Retry Interceptor in Flutter with Dio - Medium, erişim tarihi
Temmuz 30, 2025,
https://medium.com/@jdavifranco/how-to-implement-a-retry-interceptor-in-flutt
er-with-dio-26ab3c157483
53. Retrying requests in Flutter with Dio | by Ilya Nixan - Medium, erişim tarihi Temmuz
30, 2025,
https://medium.com/@nixan/retrying-requests-in-flutter-with-dio-0c26aa0546b1
54. Internationalizing Flutter apps - Flutter Documentation, erişim tarihi Temmuz 30,
2025,
https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization
55. Flutter ARB file (.arb) - Localizely, erişim tarihi Temmuz 30, 2025,
https://localizely.com/flutter-arb/
56. Right to Left (RTL) in Flutter Apps: The Developer's Guide - LeanCode, erişim tarihi
Temmuz 30, 2025, https://leancode.co/blog/right-to-left-in-flutter-app
57. Flutter and Directionality - by Carlo Lucera (HatDroid) - Medium, erişim tarihi
Temmuz 30, 2025,
https://medium.com/@carlolucera/flutter-and-directionality-d9ac42197fb8
58. Codemagic - CI/CD for Android, iOS, Flutter and React Native projects, erişim
tarihi Temmuz 30, 2025, https://codemagic.io/start/
59. Introducing support for monorepos on Codemagic, erişim tarihi Temmuz 30,
2025, https://blog.codemagic.io/codemagic-monorepo/
60. Monorepo apps - Codemagic Docs, erişim tarihi Temmuz 30, 2025,
https://docs.codemagic.io/partials/monorepo-apps/
61. Integrate the HTTP / Webhook API with the Codemagic API - Pipedream, erişim
tarihi Temmuz 30, 2025,
https://pipedream.com/apps/http/integrations/codemagic
62. FastAPI in Containers - Docker - FastAPI, erişim tarihi Temmuz 30, 2025,
https://fastapi.tiangolo.com/deployment/docker/
63. Deploying FastAPI with Docker. A Complete Guide to Containerizing and… -
Joël-Steve N., erişim tarihi Temmuz 30, 2025,
https://jnikenoueba.medium.com/deploying-fastapi-with-docker-e31c986068d7
64. Publish your Flutter app to Google Play Store with Codemagic CI/CD, erişim tarihi
Temmuz 30, 2025,
https://blog.codemagic.io/publishing-flutter-apps-to-playstore/
65. Publish your Flutter app to App Store with Codemagic CI/CD - Medium, erişim
tarihi Temmuz 30, 2025,
https://medium.com/flutter-community/publish-your-flutter-app-to-app-store-wi
th-codemagic-ci-cd-3db654042de5
66. App Store Connect publishing using Flutter workflow editor - Codemagic Docs,
erişim tarihi Temmuz 30, 2025,
https://docs.codemagic.io/flutter-publishing/publishing-to-app-store/
67. App Store Connect publishing using codemagic.yaml, erişim tarihi Temmuz 30,
2025, https://docs.codemagic.io/yaml-publishing/app-store-connect/
68. Flutter apps - Codemagic Docs, erişim tarihi Temmuz 30, 2025,
https://docs.codemagic.io/yaml-quick-start/building-a-flutter-app/
69. Build and push container images to the container registry - GitLab Docs, erişim
tarihi Temmuz 30, 2025,
https://docs.gitlab.com/user/packages/container_registry/build_and_push_images
/
70. Build and push images · Container registry · Packages · User · Help - Sign in ·
GitLab, erişim tarihi Temmuz 30, 2025,
https://git.math.duke.edu/gitlab/help/user/packages/container_registry/build_and_
push_images.md
71. Sentry vs Crashlytics - Features, Pricing Comparison & Best Alternative - UXCam,
erişim tarihi Temmuz 30, 2025, https://uxcam.com/blog/sentry-vs-crashlytics/
72. Flutter Crashlytics - Integration Guide for Your Mobile Apps - UXCam, erişim tarihi
Temmuz 30, 2025, https://uxcam.com/blog/flutter-crashlytics/
73. Sentry or Crashlytics? : r/FlutterDev - Reddit, erişim tarihi Temmuz 30, 2025,
https://www.reddit.com/r/FlutterDev/comments/1iwye4g/sentry_or_crashlytics/
74. Flutter Crash Handling with Sentry + Firebase - Geekle Events, erişim tarihi
Temmuz 30, 2025,
https://event.geekle.us/video/flutter-crash-handling-with-sentry-firebase
75. FastAPI | Sentry for Python, erişim tarihi Temmuz 30, 2025,
https://docs.sentry.io/platforms/python/integrations/fastapi/
76. Error Reporting With Sentry - Flutter (v4) Chat Messaging Docs - GetStream.io,
erişim tarihi Temmuz 30, 2025,
https://getstream.io/chat/docs/sdk/flutter/v4/guides/error_reporting_with_sentry/
77. How to Get Started with Logging in FastAPI | Better Stack Community, erişim
tarihi Temmuz 30, 2025,
https://betterstack.com/community/guides/logging/logging-with-fastapi/
78. [Backend] Logging in Python and Applied to FastAPI | by Kuan Yu Chen | Medium,
erişim tarihi Temmuz 30, 2025,
https://medium.com/@v0220225/backend-logging-in-python-and-applied-to-fas
tapi-7b47118d1d92
79. Flutter Dio Tutorial: The Ultimate HTTP Client for Flutter Development - Mobisoft
Infotech, erişim tarihi Temmuz 30, 2025,
https://mobisoftinfotech.com/resources/blog/flutter-development/flutter-dio-tut
orial-http-client
80. Custom Middleware in FastAPI: From Logging to Header Validation - Shift Asia,
erişim tarihi Temmuz 30, 2025,
https://shiftasia.com/community/custom-middleware-in-fastapi-from-logging-toheader-validation/
81. Context-Aware FastAPI Responses: Adding Errors and Warnings with ContextVar,
erişim tarihi Temmuz 30, 2025, https://samredai.com/blog/context-aware-fastapi/
82. How to access request_id defined in fastapi middleware in function - Stack
Overflow, erişim tarihi Temmuz 30, 2025,
https://stackoverflow.com/questions/67804122/how-to-access-request-id-define
d-in-fastapi-middleware-in-function
83. How can I implement a Correlation ID middleware? · Issue #397 - GitHub, erişim
tarihi Temmuz 30, 2025, https://github.com/fastapi/fastapi/issues/397
84. ASGI Correlation ID middleware, erişim tarihi Temmuz 30, 2025,
https://pypi.org/project/asgi-correlation-id/0.1.6/
85. How do you reduce widget rebuild in flutter? | by Chetankumar Akarte - Medium,
erişim tarihi Temmuz 30, 2025,
https://medium.com/@chetan.akarte/how-do-you-reduce-widget-rebuild-in-flutt
er-dc558958339a
86. Performance best practices - Flutter Documentation, erişim tarihi Temmuz 30,
2025, https://docs.flutter.dev/perf/best-practices
87. Optimizing Flutter App Performance - Effective Strategies to Overcome Common
Challenges, erişim tarihi Temmuz 30, 2025,
https://moldstud.com/articles/p-optimizing-flutter-app-performance-effective-st
rategies-to-overcome-common-challenges
88. How to Implement Pagination in Flutter? Code Sample Included | Relia Software,
erişim tarihi Temmuz 30, 2025,
https://reliasoftware.com/blog/pagination-in-flutter
89. Implement Effective Pagination in the Flutter ListView in Just 4 Steps! -
Syncfusion, erişim tarihi Temmuz 30, 2025,
https://www.syncfusion.com/blogs/post/effective-flutter-listview-pagination/amp
90. riverpod_infinite_scroll_pagination | Flutter package - Pub.dev, erişim tarihi
Temmuz 30, 2025, https://pub.dev/packages/riverpod_infinite_scroll_pagination
91. riverpod_infinite_scroll_pagination 1.0.2 | Flutter package - Pub.dev, erişim tarihi
Temmuz 30, 2025,
https://pub.dev/packages/riverpod_infinite_scroll_pagination/versions/1.0.2
92. Logging and error reporting - Riverpod, erişim tarihi Temmuz 30, 2025,
https://riverpod.dev/docs/essentials/provider_observer
93. Error Handling in Riverpod: Best Practices, erişim tarihi Temmuz 30, 2025,
https://tillitsdone.com/blogs/error-handling-in-riverpod-guide/
94. Effective Exception Handling in Flutter: try-catch vs AsyncValue.guard - Medium,
erişim tarihi Temmuz 30, 2025,
https://medium.com/@ajju_jaihind/effective-exception-handling-in-flutter-try-cat
ch-vs-asyncvalue-guard-e0ad42204bd2
95. Loading data with Riverpod: an AsyncValue story - Sharpnado, erişim tarihi
Temmuz 30, 2025, https://sharpnado.com/loading-data-with-riverpod/
96. Add Firebase to your Flutter app, erişim tarihi Temmuz 30, 2025,
https://firebase.google.com/docs/flutter/setup
97. Flutter | Log Automatically Firebase Analytics Navigation Events with GoRouter |
by Samed Harman | AYT Technologies | Jul, 2025 | Medium, erişim tarihi Temmuz
30, 2025,
https://medium.com/ayt-technologies/flutter-log-automatically-firebase-analytic
s-navigation-events-with-gorouter-9807ef5753ab
98. Accessibility widgets - Flutter Documentation, erişim tarihi Temmuz 30, 2025,
https://docs.flutter.dev/ui/widgets/accessibility
99. Accessibility - FlutterFlow Documentation, erişim tarihi Temmuz 30, 2025,
https://docs.flutterflow.io/concepts/accessibility/
100. Accessibility - Flutter Documentation, erişim tarihi Temmuz 30, 2025,
https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility
101. Introducing package:flutter_lints - Flutter Documentation, erişim tarihi
Temmuz 30, 2025,
https://docs.flutter.dev/release/breaking-changes/flutter-lints-package
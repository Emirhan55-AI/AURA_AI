Flutter Uygulama Mimarisi
Katmanlar (Domain, Uygulama, UI, API): Modern Flutter uygulamalarında katmanlı mimari yaygın bir
yaklaşımdır. Genellikle üç ana katman önerilir:
UI (Sunum) Katmanı: Kullanıcı arayüzünü temsil eder. Görünümler (Views) ve ViewModel’lerden
oluşur. Görünümler, Flutter widget’larından oluşturulur ve yalnızca veriyi gösterme ile kullanıcı
etkileşimlerini ViewModel’e iletme sorumluluğuna sahiptir . Örneğin bir ekran, ilgili
ViewModel sınıfına bağlıdır.
Domain (İş/Use-Case) Katmanı: Karmaşık iş mantığı ve uygulama akışlarını kapsar.
Gerektiğinde ViewModel’lerdeki tekrar eden veya ağır mantığı burada kapsülleyerek yeniden
kullanılabilir hale getirmek için kullanılır . Flutter belgelerine göre bu katman
opsiyoneldir; yalnızca uygulama mantığı çok karmaşıksa veya farklı view model’ler arasında ortak
işlem gerekiyorsa eklenmelidir . Use-case sınıfları genellikle birden fazla repository’den
gelen verileri birleştirir, karmaşık işlemleri yönetir veya farklı ekranlarda ortak kullanılır.
Veri/API Katmanı: Veri erişiminden sorumludur. Burada repository ve service sınıfları yer alır.
Repository sınıfları, veri kaynağı servislerini çağırarak ham veriyi domain model biçimine
dönüştüren “gerçeklik kaynağı”dır . Örneğin bir UserRepository , kullanıcı verisini REST/
GraphQL’dan çekip User modeline dönüştürür. Service sınıfları ise alt katmanda API çağrılarını/
sorgularını yönetir (örneğin GraphQL query veya REST endpoint’leri) ve Future/Stream olarak
sonuç döner . Her veri türü için genellikle bir repository sınıfı oluşturulur . Bu katman,
veritabanı veya harici API’larla iletişim kurar.
Bu katmanlar arasındaki bağımlılıklar tek yönlüdür: UI katmanı sadece Domain veya Veri katmanına,
Veri katmanı sadece altyapı servislerine bakar . Örneğin, bir haber akışı yüklenirken UI (ekran) →
ViewModel → Repository → Service → GraphQL / REST şeklinde bir akış olabilir. Flutter dokümanları da
katmanlı mimariyi destekler; UI katmanı görünüm ve ViewModel’lerden, veri katmanı repository ve
servislere, seçenekli Domain katmanı ise iş kurallarını içeren use-case’lere ayrılmalıdır .
Riverpod v2 ile Durum Yönetimi: Riverpod 2, güçlü bir state management ve veri önbellekleme
altyapısı sunar. Kod jenerasyonu ([@riverpod] notasyonu) önerilir, böylece Future/Stream gibi asenkron
tipler otomatik yönetilir . Provider hiyerarşisi: Riverpod, global ve lokal kapsamlar oluşturmayı
destekler. Örneğin ProviderScope içindeki üst düzey provider’lar uygulama genelinde kullanılırken,
widget bazlı ConsumerWidget içinde tanımlanan provider’lar o widget’ın yaşam döngüsüne uyar.
Riverpod “scoped” provider desteği sayesinde (ProviderContainer’lar veya ProviderScope ile)
uygulamanın farklı bölümlerinde bağımsız durum yönetimi yapılabilir . Aşağıdakiler kullanılabilir:
- Family Provider: Parametreli provider’lar ( .family ) oluşturur. Örneğin, belirli userId ’ye göre veri
isteyen bir FutureProvider.family tanımlanabilir. - Scoped Provider: Farklı widget alt ağacı için ayrı
provider örneği oluşturur, böylece aynı provider farklı verilere bağlanabilir . - AutoDispose ve
KeepAlive: .autoDispose ile işaretlenen provider’lar, artık dinleyici kalmadığında otomatik olarak yok
edilir . Bu, örneğin bir sayfa kapandığında gereksiz kaynak kullanımını önler. Öte yandan,
ref.keepAlive() çağrısı ile bir provider’ın durumunun dinleyici olmasa bile korunması sağlanabilir
. Örneğin:
final postsProvider = FutureProvider.autoDispose<List<Post>>((ref) async {
final posts = await repository.fetchPosts();
•
1
•
2 3
2 3
•
4
5 4
6
1 2
7
8 9
9
10
11
1
ref.keepAlive(); // Başarılı yükleme sonrası durumu sakla
return posts;
});
Bu sayede bir kez başarılı veri alındığında, sayfa yeniden açıldığında tekrar istek yapılmaz . İşlem
başarılı olmazsa provider’ın otomatik olarak dispose edilmesi, bellek yönetimini kolaylaştırır.
- Veri Kaynağı Orkestrasyonu: Farklı kaynaklardan gelen veriler use-case veya provider düzeyinde
birleştirilebilir. Örneğin, bir Riverpod provider içinde ref.watch(anotherProvider) ile bir
repository ya da diğer bir provider’dan gelen veri alınabilir. KodWithAndrea örneğinde,
postsRepositoryProvider adında bir repository Provider tanımlanmış, bir fetchPostsProvider
ise ref.watch(postsRepositoryProvider).fetchPosts() kullanarak liste verisi çekmektedir
. Bu sayede katmanlar arası bağımlılık türü açıkça belirtilir ve veri akışı kontrol edilir.
Kod Organizasyonu (Ekranlar, Bileşenler, Use-Case’ler, Modeller): Flutter kodlarını genellikle özelliğe
göre (feature-first) veya tip/eşyaya göre (layer-first) düzenleyebilirsiniz . Flutter’ın önerisi karma
bir yaklaşım kullanmaktır: UI katmanındaki her özellik bir klasörde toplanırken (her özelliğin kendine ait
screen , widget’ları ve view_model ’i olur), veri katmanı dosyaları ortak kullanıldığı için türlerine göre
gruplanır . Örneğin:
lib/
├─ ui/
│ ├─ core/ // Temel widget’lar ve tema
│ └─ feed/ // “Feed” özelliği
│ ├─ view_model/
│ │ └─ feed_view_model.dart
│ └─ widgets/
│ ├─ feed_screen.dart
│ └─ post_card.dart
├─ data/
│ ├─ repositories/
│ │ ├─ feed_repository.dart
│ │ └─ user_repository.dart
│ ├─ services/
│ │ ├─ feed_api_service.dart
│ │ └─ user_api_service.dart
│ └─ models/
│ ├─ feed_model.dart
│ └─ user_model.dart
├─ domain/
│ └─ models/
│ └─ user.dart
└─ main.dart
Bu yapıda her bir özellik klasörü ( feed , profile vb.) kendi View ve ViewModel’ini içerir. data/
klasöründe ise tüm özelliklerin ortak kullandığı repository ve service sınıfları ile (örneğin API modelleri)
tutulur. Flutter kılavuzuna göre “data” klasörü tür bazında, “ui” klasörü ise özellik bazında organize
edilmelidir . Dosya ve sınıf isimlerini ise mimari bileşene uygun yazmak (örn. HomeViewModel ,
UserRepository , SettingsScreen ) kodun okunabilirliğini artırır .
11 12
13
14
15 16
16
17
2
Test Edilebilirlik, Performans ve Bakım Kolaylığı: Katmanlı mimari ve açık sorumluluk ayrımı, test
yazmayı kolaylaştırır. Her katman kendi başına test edilebilir:
Birim testleri: Her service, repository ve ViewModel sınıfı için ayrı birim testleri yazılmalıdır .
Örneğin bir FeedRepository ’nin API çağrıları ve hata durumları test edilebilir;
FeedViewModel ise sahte (mock) bir FeedRepository ile test edilerek UI durum
dönüşümleri doğrulanır .
Widget testleri: Ekranların (View’lerin) doğru şekilde render edildiği ve ViewModel’lerin
çağrıldığı test edilir. Yönlendirme (navigation) ve bağımlılık enjeksiyonu (örneğin
ProviderScope ) testleri de bu aşamada yapılır .
Test stratejileri: Sahte (fake/mock) sınıflar kullanarak bağımlılıkları izole edin . Bu yaklaşım,
her birimin dışarıya bağımlı olmayan, giriş-çıkışa (input-output) odaklı, modüler kod yazılmasını
teşvik eder.
Performans için şu yaklaşımlar önerilir:
Uzun listeler: Çok sayıda öğe içeren listeler için ListView.builder kullanın. Bu yöntem, tüm
liste öğelerini birden oluşturmak yerine, sayfalandırarak görünür öğeleri inşa eder . Örneğin:
ListView.builder(
itemCount: posts.length,
itemBuilder: (context, index) {
return PostItemCard(post: posts[index]);
},
);
Widget yeniden oluşturma: Mümkün olduğunca widget’ları küçük parçalara bölün ve const
yapıcılar kullanarak yeniden oluşturmayı azaltın. Riverpod ile, sadece bağımlı provider’lar
değiştiğinde ilgili widget yeniden çizilir, bu da gereksiz yeniden yapımı önler .
Kaynak yönetimi: Görüntüler için önbellekleme (ör. CachedNetworkImage ), liste öğeleri için
“prototypeItem” veya “itemExtent” kullanımı gibi tekniklerle bellek ve CPU yükünü azaltabilirsiniz
.
Kod kalitesi: Statik analiz araçları ve lint kuralları ( flutter_lints vb.) ile kod tutarlılığını
sağlayın . Anlamlı isimlendirme ve temiz kod standartları bakım maliyetini düşürür.
Sonuç olarak, katmanlı mimari sayesinde Flutter uygulamanızın test edilebilirliği, bakım kolaylığı ve
performansı artar. Her bir katman ve bileşen için net sorumluluklar tanımlanmalı, Riverpod v2 gibi
modern state yönetim araçlarıyla verilere erişim düzenli hale getirilmeli ve kod yapısı özellik bazlı
organize edilerek ekip içi çalışmalar hızlandırılmalıdır .
Kaynak: Flutter resmi dokümantasyonu ve Riverpod rehberleri ışığında yukarıdaki öneriler derlenmiştir
.
Architecture guide | Flutter
https://docs.flutter.dev/app-architecture/guide
Architecture concepts | Flutter
https://docs.flutter.dev/app-architecture/concepts
• 18
18 19
•
18
• 20
•
21
•
8
•
21
•
17
1 22
1 4 2 11 9 16 22 21
1 2 4 5 19
3 6
3
About code generation | Riverpod
https://riverpod.dev/docs/concepts/about_code_generation
Flutter State Management: Exploring RiverPod and BLoC | by Reme Le Hane | Medium
https://remelehane.medium.com/flutter-state-management-exploring-riverpod-and-bloc-1463a0f5e5ba
Riverpod Data Caching and Providers Lifecycle: Full Guide
https://codewithandrea.com/articles/flutter-riverpod-data-caching-providers-lifecycle/
.autoDispose | Riverpod
https://riverpod.dev/docs/concepts/modifiers/auto_dispose
Architecture case study | Flutter
https://docs.flutter.dev/app-architecture/case-study
Architecture recommendations | Flutter
https://docs.flutter.dev/app-architecture/recommendations
Work with long lists | Flutter
https://docs.flutter.dev/cookbook/lists/long-lists
7
8 9
10 13
11 12
14 15 16
17 18 20 22
21
4
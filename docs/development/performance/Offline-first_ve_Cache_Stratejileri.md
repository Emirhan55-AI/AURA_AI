Offline-first ve Cache Stratejileri
Riverpod ile Cache Yönetimi
Mimari Önerileri: Offline-first mimaride, veriler için öncelikle yerel kaynağa (örneğin SQLite/
Hive) bakacak bir repository katmanı oluşturulur. Riverpod’da her veri talebi bir
AsyncNotifier veya FutureProvider üzerinden sağlanabilir. Bu Notifier’lar önce yerel
önbelleği döner, arka planda ise API’den yeni veriyi getirip hem UI hem de yerel depoyu
günceller. Bu yaklaşım Flutter’ın offline mimari rehberindeki “Repository, yerel ve uzak kaynakları
bir araya getirir” kuralına uygundur . Örneğin bir PostsNotifier sınıfı build()
metodunda önce SQLite’dan makul sayıda gönderi okuyup state = AsyncData(localData)
ile sağlayabilir, ardından GraphQL ile güncel veriyi çekip veritabanına kaydederek state
değerini güncelleyebilir. Provider’lar için autoDispose kullanarak gereksiz bellek tüketimini
önleyip, aktif değilken state’leri serbest bırakabiliriz .
Araçlar ve Kütüphaneler: Riverpod (v2 ile kod-jeneratörlü AsyncNotifier /
NotifierProvider kullanımı), Hive veya SQLite (örn. hive_flutter , sqflite ) gibi kalıcı
depolar, shared_preferences (küçük veri için). Riverpod 3’ün deneysel offline persistence
özelliği ile @Persisted annotation’ı ve riverpod_sqflite gibi paketlerle sağlayıcı state’leri
SQLite’a yazmak mümkün .
Örnek Kod:
@riverpod
class PostsNotifier extends _$PostsNotifier {
@override
Future<List<Post>> build() async {
// 1) Yerel veriyi oku
final localPosts = await LocalDb.getPosts();
if (localPosts.isNotEmpty) {
state = AsyncData(localPosts);
}
// 2) Yeni veriyi API'den getir
final remotePosts = await fetchPostsFromApi();
// 3) Yerel veriyi güncelle
await LocalDb.savePosts(remotePosts);
return remotePosts;
}
Future<void> addPost(Post post) async {
// Önbelleğe al ve API'ye ekle
await LocalDb.insertPost(post);
state = AsyncData([...state.value!, post]); // state güncelle
try {
await postToApi(post);
} catch (e) {
// Hata durumunda yerelde flag işaretlenip sinhronizasyon
bekletilebilir
}
•
1
2
•
3 4
•
1
}
}
Potansiyel Sorunlar ve Çözümler: autoDispose sağlayıcılar ekrandan ayrılınca state’i siler, bu
durumda ekrana tekrar dönüldüğünde yeniden yükleme yapılır (maliyetli olabilir); gerektiğinde
keepAlive: true ile gecikmeli bellekte tutma tercih edilebilir. Büyük veri kümeleri bellek veya
disk üzerinde sorun çıkartabilir; liste veri yapıları ( ListView.builder , sayfalama) ve uygun
sorgu sınırlandırmaları ile yönetilmeli. AsyncNotifier kullanırken, birden fazla çağrı aynı
anda yapılırsa yarış durumları olabilir; ref.watch / ref.read yerine
ref.watch(provider.future) gibi tekil future ile senkronize etmek gerekebilir. Ayrıca,
Riverpod 3 offline persistence özelliği deneyseldir; kullansanız bile uygulama güncellemelerinde
veri model uyumsuzluklarına dikkat edin .
Performans/Bakım/Test: State yönetimini sağlayıcılar üzerinden yaptığımızda birim testler
kolaydır (provider test utils ile). autoDispose ile aktif olmayan modüller bellekten
kalkacağından, aktif bellek kullanımı kontrol edilebilir. Büyük veri yükleri ( List ) için
ListView.builder , PagedData vb. kullanımı performansı artırır. State güncelliği için gerekli
ise pull-to-refresh ile önbellek temizlenip yeniden çekme uygulanabilir. Testlerde offline mod
simüle ederek (ör. PlatformDispatcher.instance.onConnectivityChanged mock’lama)
davranış doğrulanmalı. Provider’lardaki build() metodu hızlı çalışmalı; ağır işlerde arka
planda opsiyonel compute kullanılabilir.
Akış Şeması: Kullanıcı bir listeyi görüntülerken: UI → PostsNotifier.build() (Provider) →
Yerel Veritabanı (SQLite/Hive) → [Cache’e döndür] → arka planda: Provider → API (GraphQL) →
sunucudan veri → Provider günceller → UI güncellenir. Veri eklerken: UI →
PostsNotifier.addPost() → Yerel Veritabanı’na kaydet (sıralı kuyruk oluştur) → Eş zamanlı
olarak UI değişikliği → Ağ varsa REST/GraphQL ile gönder, hata ise sinhronizasyon bekle.
Use-Case Senaryoları: Örneğin kullanıcı offline durumda gönderi beğenisi yaparsa,
LikeService -> veriyi SQLite’taki pending_likes tablosuna kaydeder ve UI anında
güncellenir; bağlantı geri gelince bu tablo işlenip Supabase’e REST/GraphQL ile gönderilir. Aynı
şekilde yorum ekleme veya profil güncelleme offline saklanıp, bağlantı ile senkronize edilir.
Cache temizleme: Önbellek aşırı büyürse eski veriler autoDispose veya belirli TTL (örn. feed
için 5dk) ile silinebilir.
Performans/Kapasite: Örneğin bir sayfadaki feed içeriği en fazla birkaç yüz öğe tutulmalı; daha
fazlası sayfalama ile çekilmeli. Hedef olarak sunucu cevap süreleri: okunmada <200ms, yazmada
<500ms. Cache TTL önerileri: sık değişmeyen kullanıcı verisi için 1 saat, feed/anasayfa için 5dk.
Riverpod’ın cache boyutu kendi içinde sınırlıdır; çok büyük veri yerine sayfalama tavsiye edilir.
Test edilebilirlik için sağlayıcılardaki iş mantığı izole ve küçük parçalarda yazılmalı. Uygulama
10K-100K kullanıcıya ulaştığında, veritabanı indeksi, kayıt silme veya arşivleme (örn. 1M+ satırda
partitioning) dikkate alınmalıdır.
Supabase ile Offline Sync Mekanizması
Supabase’in kendisinde yerleşik offline desteği yoktur, bu nedenle Brick veya PowerSync gibi çözümler
öne çıkar. Brick, Supabase tablosunu yerel bir SQLite veritabanıyla eşler ve sorguları otomatik olarak
çevrimdışı modda çalıştırır . Uygulama, Brick’in repository nesnesine (ör. Repository() ) istek
gönderir ve bu, verinin önce SQLite cache’inden dönmesini, ağ bağlantısı olduğunda ise Supabase’e
sorgu gönderip sonucu cache’ine yazmasını sağlar . PowerSync ise Supabase ile entegre çalışan,
yerel SQLite’a yayan bir katman sunar; kullanıcı yazmaları lokal DB’ye yapılır, bağlantı geri geldiğinde
kuyruktaki veriler sunucuya yüklenir .
- Mimari Önerileri: Offline-first mimaride bir repository katmanı kurun. Tüm veri erişimleri önce bu
repository’ye gider. Repository, bir yandan Supabase/Sanal API ile etkileşim kurarken, diğer yandan
•
3 4
•
•
•
•
5 6
7 6
8 6
2
yerelde SQLite cache’ini yönetir. Yazma işlemleri (örneğin Supabase’e REST isteği) öncelikle local DB’ye
işlenip flag işareti (örn. senkronize mi?) eklenir, ardından ağ olduğunda queue’dan sunucuya gönderilir
. Brick veya PowerSync kullanılmıyorsa, manuel olarak SQFlite/Isar ile local cache oluşturup,
background task veya bağlantı geri geldiğinde senkronizasyon başlatılmalıdır. Ayrıca Row Level Security
uygularken offline durumların izinlerini (örn. kullanıcı kendi verisini görebilsin) göz önünde tutun.
- Araçlar ve Kütüphaneler:
- Brick (Offline First with Supabase): Kod jeneratörü ile Supabase modellerinden SQLite adaptörleri
oluşturur .
- PowerSync: Supabase Partner çözümü; senkronizasyon kurallarıyla veriyi local SQLite’a anlık yansıtır
.
- SQFlite/Isar: Özel senkronizasyonla basit cache yönetimi için.
- Riverpod/Provider: Repository’yi saglamak için (örneğin Final repository = Repository(); ).
- Örnek Kod: (Brick kullanımı için)
// Model tanımı
@ConnectOfflineFirstWithSupabase(
supabaseConfig: SupabaseSerializable(tableName: 'users')
)
class User extends OfflineFirstWithSupabaseModel {
final String name;
@Supabase(unique: true)
@Sqlite(index: true, unique: true)
final String id;
// ...
}
// Repository yapılandırma
class Repository extends OfflineFirstWithSupabaseRepository {
factory Repository() => _instance!;
static Future<void> configure(DatabaseFactory dbFactory) async {
final (client, queue) = OfflineFirstWithSupabaseRepository.clientQueue(
databaseFactory: dbFactory,
);
await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey,
httpClient: client);
final provider = SupabaseProvider(
Supabase.instance.client,
modelDictionary: supabaseModelDictionary,
);
_instance = Repository._(
supabaseProvider: provider,
sqliteProvider: SqliteProvider('app.sqlite', databaseFactory:
dbFactory, modelDictionary: sqliteModelDictionary),
migrations: migrations,
offlineRequestQueue: queue,
memoryCacheProvider: MemoryCacheProvider(),
);
}
// ...
}
9 10
5 6
8
3
// App başlatma
void main() async {
await Repository.configure(databaseFactory);
await Repository().initialize();
runApp(MyApp());
}
// Veri okuma/yazma
final users = await Repository().get<User>(query: Query.where('age',
Where.exact('>20')));
await Repository().upsert<User>(data: User(name: 'Alice'));
- Potansiyel Sorunlar ve Çözümler: Supabase kendi başına offline destek vermediği için, SQL
fonksiyonlar, tetikleyiciler gibi özelliklerin offline replikasyonunu doğrudan yapmak zordur . Veri
çakışmalarında (örneğin aynı kaydı hem sunucu hem de cihaz değiştirirse) bir çatışma çözüm
mekanizması sağlanmalı. Brick kullanıyorsanız, her modelde “updated_at” gibi alanlar ekleyip otomatik
çakışma yönetimi sağlayabilirsiniz. Çok büyük tablolar (milyonlarca satır) için local cache saklamak pratik
olmayabilir; sadece gerekli verileri (ör. aktif kullanıcı, son postlar) indirin. Ayrıca offline değişiklikler
sırasında verinin tutarlılığını sağlamak için her veri sınıfında “synchronized” flag’i tutmak ve başarılı
gönderim sonrası bunu güncellemek önerilir .
- Performans/Bakım/Test: Yerel veritabanı sorguları hızlı olmalıdır; gerektiğinde indeks kullanın. Brick
veya PowerSync kod jenerasyonlarına aşina olun, versiyon değiştiğinde kod tekrar derlenmeli. Birim
testlerde çevrimdışı senaryoları taklit etmek için lokal depo karşılığı mock edin. Performans için veri
senkronizasyon işlemleri arka planda (örn. Workmanager veya periyodik Timer ) çalıştırılmalı ve
bağlantı kontrolü ( connectivity_plus ) ile sadece internet varken tetiklenmeli . Test edilebilirlik
için repository katmanındaki metotlar basit, yan etkisiz olmalı. Bakım için mimaride repository/servis
katmanları ayrık tutulmalı.
- Akış Şeması: Offline veri ekleme: UI (Gönderi Paylaş) → Uygulama Katmanı (ViewModel) → Domain
(UseCase: sharePostOffline ) → Repository → Yerel DB (Yeni gönderi, “pending” flag ile kaydedilir)
→ UI güncellenir (optimistic). İnternet geri geldiğinde: Repository senkronizasyon → API (REST/
GraphQL) çağrısı → Supabase’e post eklenir → Yereldeki “pending” flag kaldırılır.
- Use-Case Senaryoları: Örneğin kullanıcı metrodayken yeni bir ürün ekler (satırgiyimi uygulamaya
ekleme) ve daha sonra internete bağlandığında bu ürün sunucuya eşlenir. Aynı şekilde, offline moda
alınan beğeniler ve yorumlar otomatize kuyrukla daha sonra gönderilir. Eğer bağlanırken sunucudaki
veri güncellenmişse, Brick bunu anlayıp önce gelen son kayıtı yerelde birleştirebilir. Ayrıca “auto-sync”
seçeneğiyle cihaz internete bağlandığında arka planda tanımlı aralıklarla sync() çalıştırabilir .
- Performans/Kapasite: Cihaz başına cache boyutu sınırlıdır; genelde sadece son örneğin binlerce kayıt
saklanır (ör. feed için son 1000 post). Çoklu kullanıcı senaryolarında, her kullanıcı kendi veri setini
senkronize etmelidir. Sunucu tarafında 1K/10K kullanıcı için tek bir PostgreSQL yeterli iken, 100K+ için
read-replica veya sharding gerekebilir. Önbellek güncelleme hedefleri: çevrimiçi moda geçince hemen
senkron, arka planda her 5-15 dakika bir yeniden doğrulama; uzun süre offline kalınırsa kullanıcıyı
uyarma. Supabase RLS kullanan tablolar ~1M satırı geçtiğinde performans düşebilir; bu durumda sorgu
kısıtları veya arşivleme düşünülmeli.
GraphQL Cache Yönetimi
Mimari Önerileri: GraphQL sorgularını graphql_flutter paketi ile kullanıyorsanız,
GraphQLCache yapılandırmasını iyi yapmak gerekir. Uygulama açıldığında await
initHiveForFlutter(); ile Hive başlatın ve GraphQLClient(cache:
11
12 13
14
15
16
•
4
GraphQLCache(store: HiveStore()), link: ...) şeklinde tanımlayın . Bu sayede
yapılan sorgu sonuçları HiveDB’de saklanır ve uygulama yeniden başlatıldığında bile kullanılabilir.
Önbellek stratejisi için sorgu politika şemaları kullanın: sık değişmeyen verilerde cacheFirst
veya cacheAndNetwork , güncel veri gereken yerde networkOnly . Örneğin kullanıcı profili
gibi veri bir saat boyunca önbellekte tutulabilirken, feed için daha kısa TTL tercih edin.
Araçlar ve Kütüphaneler:
graphql_flutter: GraphQLClient , Query widget.
Hive: Kalıcı cache için (HiveStore).
graphql_flutter’ın default InMemory cache’i kapatmak için GraphQLCache(store:
HiveStore()) kullanımı.
shared_preferences: Küçük hacimli veri için manuel cache (geri dönüş yoksa
SharedPreferences’a JSON kaydetmek bir çözüm olabilir ). Ancak büyük veri için Hive tercih
edilir.
Örnek Kod:
await initHiveForFlutter(); // Hive için gerekli başlangıç
final link = HttpLink('https://api.example.com/graphql');
final client = GraphQLClient(
cache: GraphQLCache(store: HiveStore()),
link: link,
);
// sorgu örneği:
final result = await client.query(QueryOptions(
document: gql(r'''
 query GetFeed($limit: Int!) { feed(limit: $limit) { id, title,
content } }
 '''),
variables: {'limit': 20},
fetchPolicy: FetchPolicy.cacheFirst, // önce cache dene
));
Potansiyel Sorunlar ve Çözümler: Cache’te tutulan veri güncelliği sorun olabilir; örneğin
sunucuda yeni postlar varsa, cache eski içerikleri gösterebilir. Bunu azaltmak için
cacheAndNetwork politikası kullanılarak arkaplanda yenileme yapılabilir. Çok büyük query
sonuçlarını önbellekte saklamak cihazda yer tüketir; önbellek kısıtları ( HiveStore varsayılan
2.5MB) aşıldığında hataya neden olabilir. (Genelde; biri tek key’te, HiveStore sınırlaması ~1.5MB
). Bu durumda sorguları sayfalayıp saklamak veya LRU mekanizması uygulamak gerekir.
Ayrıca shared_preferences çok sınırlı boyutlu olduğundan (yaklaşık 1-5MB) JSON saklamaya
uygun değildir .
Performans/Bakım/Test: GraphQL cache, tekrar eden sorguları ağ çağrısı yapmadan hızlı
cevaplamaya yardımcı olur (UI tepkisi <50ms). Hive tabanlı cache’e erişim anlık değilse (10-20ms)
gecikme ekler; önemlise önce hafıza cache’i ( MemoryCache ) kullanılabilir. Kod tarafında
FetchPolicy ’ları test edin; offline modda doğru şekilde cacheFirst dönüyor mu kontrol
edin. UI testlerinde internet kapalı durumda cache’in yanıt verdiği doğrulanmalıdır. Performans
için büyük sorgular yerine sadece gerekli alanları sorgulayıp saklayın. Bakım açısından, GraphQL
şeması değişirse cache zaten yeni sorgu name’leriyle uyumsuz hale gelebilir, o yüzden tip güvenli
kod üretimi (codegen) önerilir.
Akış Şeması: Veri çekme: UI → graphql_flutter Query Widget → GraphQLCache (Hive);
öncelikle local cache’e bakar, eğer bağlantı varsa API’dan veri alır ve cache’e yazar. Örnek: Kullanıcı
17
•
•
•
•
•
18
•
•
19
19
•
•
5
feed açtığında önce yerel Hive’daki listeleri göster, sonra fetchMore ile yeni içerik çekilip listeye
ekle.
Use-Case Senaryoları: Örneğin kullanıcı uygulamayı çevrimdışında açarsa, GraphQL sorgusu
cacheFirst ile önbellekteki son sonuçları getirir (tek satırlık JSON değil, model objesi olarak).
Daha sonra bağlantı ile refetch() yapıldığında güncel içerik alınır ve yerel cache güncellenir.
Başka bir senaryo, kötü bağlantıda sayfalar arası geçiş: her seferinde hızlı olması için sayfa
sayfa cache’den veri okunur. Veya senkron içerik güncelleme: UI’da bir gönderi beğenildiğinde
GraphQL optimistik güncelleme kullanılarak liste güncellenebilir, sonra network mutasyon
gönderilir.
Performans/Kapasite: Önbellek kullanım hedefi: sık kullanılan veri için <5 dakika cache, statik
profil/veri için 1 saat cache ideal olabilir. Bellek üst sınırı cihaz başına birkaç yüz MB, Hive için
proje bazlı sınırlı. 10K kayıtlık sorgular hafızayı zorlar, bu yüzden sayfalama/lokal filtre
uygulanmalı. GraphQL yanıt süreleri hedef olarak 200ms’in altında, cache hit durumlarında
<50ms olmalıdır.
Network Durumu İzleme ve Retry Mekanizmaları
Mimari Önerileri: Uygulama ağ durumunu izleyerek offline/online geçişlerini yönetmeliyiz.
Bunun için connectivity_plus paketi ile ağ bağlantısı değişimlerini
( Connectivity().onConnectivityChanged ) izleyip, offline durumlarda API çağrılarını
erteleyebilir, online döndüğünde kuyruktaki istekleri işleyebiliriz . Her ağ isteğine retry
mekanizması eklemek için retry paketi kullanılabilir; geçici hatalarda otomatik yeniden
deneme yapmak kullanıcı deneyimini artırır . Örneğin RetryOptions(maxAttempts: 3)
ile bağlantı sorunlarına karşı geri çekilme gecikmeli tekrarlar uygulanabilir. Ayrıca, timeout
ayarları (örn. http.get(...).timeout(Duration(seconds:5)) ) ile uzun süreli beklemeler
önlenmelidir.
Araçlar ve Kütüphaneler:
connectivity_plus: Ağ durumu değişimlerini dinlemek için (WiFi, mobil veri, yok). Örneğin
StreamProvider<ConnectivityResult> connectivityProvider =
StreamProvider.autoDispose((ref) => Connectivity().onConnectivityChanged); .
Uyarı: Bu paket gerçek internet erişimini değil sadece ağ türünü bildirir ; bağlantı olup
olmadığını InternetAddress.lookup gibi ek testlerle doğrulamak gerekebilir.
internet_connection_checker: Belirli bir siteye ping atarak gerçekten internet erişimi olup
olmadığını kontrol eder.
retry: HTTP isteklerini tekrar denemek için (exponential backoff destekli) . Örnek:
final r = RetryOptions(maxAttempts: 4, delayFactor: Duration(seconds:
2));
final response = await r.retry(
() => http.get(Uri.parse(url)).timeout(Duration(seconds: 5)),
retryIf: (e) => e is SocketException || e is TimeoutException,
);
GraphQL/REST client retry: Bazı HTTP client paketleri (örn. http_retry ) veya GraphQL
paketindeki otomatik retry (Riverpod v3’te) da kullanılabilir.
Örnek Kod:
// Connectivity takibi (Riverpod StreamProvider ile)
final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
•
•
•
20 15
21
•
•
20
•
• 21 22
•
•
6
return Connectivity().onConnectivityChanged;
});
// Bağlantı değiştiğinde senkronizasyon başlatma
ref.listen(connectivityProvider, (previous, next) {
if (next == ConnectivityResult.none) {
print('Offline');
} else {
print('Online');
// Kuyruktaki işlemleri gönder
repository.syncPendingRequests();
}
});
// HTTP isteğine retry ekleme
final r = RetryOptions(maxAttempts: 5);
Future<http.Response> fetchWithRetry(Uri uri) {
return r.retry(
() => http.get(uri).timeout(Duration(seconds: 5)),
retryIf: (e) => e is SocketException || e is TimeoutException,
);
}
Potansiyel Sorunlar ve Çözümler: connectivity_plus her cihaz ve platformda bazen hatalı
sonuç verebilir (örneğin Wi-Fi bağlı ama internet yok). Bu nedenle ağ kontrolünü aşamalı yapmak
önemli: önce ConnectivityResult ile genel durumu kontrol et, sonra küçük bir HTTP
isteğiyle erişim test et. Ayrıca, sürekli bağlantı denemeleri batarya tüketir; bu yüzden debounce
(örneğin her 5 saniye’de bir) veya arka planda çalışan task (WorkManager) kullanılabilir .
retry paketinde çok yüksek deneme sayısı belirlemek sunucuya yük bindirebilir; genellikle 3-5
deneme yeterlidir . Gerçek zamanlı bağlantı (WebSocket) için otomatik yeniden bağlanma
( autoReconnect: true ) ayarlanabilir.
Performans/Bakım/Test: Ağ durumuna bağlı state değişiklikleri UI’da anında yansıtılmalı (ör.
“Bağlantı yok” Snackbar’ı). Ancak her küçük durum değişiminde gereksiz yeniden yüklemeler
önlenmeli. retry aralığı (exponential backoff) başlangıçta kısa (2sn) başlayıp maksimumta
uzun tutulmalı. Testlerde farklı senaryolar (uçak modu, düşük hız) ile deneyin. Performans için
büyük resimleri cached_network_image ile önbelleğe alın; network dinlemeyi basit tutup
fazla sıklıkta database okumasından kaçının.
Akış Şeması: Offline işlem ve senkronizasyon: UI’da bir işlem (ör: beğeni) başlatılır → Application
katmanı (ViewModel/Provider) → İş mantığı (Domain) bu isteği önce Local DB’ye yazar
( pending olarak işaretler) → UI anında güncellenir. Daha sonra cihaz internete bağlanır →
connectivity_plus uyarısı tetiklenir → Repository senkronizasyon metodu çağrılır → Yerel
pending kayıtlar API’ye (GraphQL/REST) gönderilir → Başarılı olunca local kayıt “sync”
işaretlenir veya silinir.
Use-Case Senaryoları: Örneğin kullanıcı offline modda bir ürünü favorilere eklediğinde, bu
işlem local bir “favori_pending” tablosuna kaydedilir. Kullanıcı tekrar online olduğunda uygulama
bu tabloyu tarayıp arka planda REST isteğiyle sunucuya favori ekler. Zayıf ağda mesaj
gönderme: Kullanıcı mesaj yazıp “gönder” deyince önce local kuyruk oluşur, UI’a anında eklenir;
bağlantı stabil olunca WebSocket veya Realtime ile mesaj gönderilir. Çoklu dil değişikliği: Dil
ayarı offline değiştirildiğinde sadece cihaz belleğinde tutulur (Riverpod ile state), internet
olduğunda ayar servisine gönderilebilir.
•
14 15
21
•
•
•
7
Performans/Kapasite: Bağlantı kontrolü temel olarak sistem olaylarına bağlıdır; her dakika
check yapmaktansa onConnectivityChanged tercih edin. Uygulama başlangıcında kısa bir
internet testi yapılabilir (<200ms). Eşzamanlı kaç istek yapılacağına dair örnek: aynı anda en fazla
3-5 retry denemesi yapın (toplam ~15 saniyeye ulaşmadan vazgeç). Cihaz başına bekleyen işlem
kuyruğu binlerce kaydı aşmamalı; çok uzun süre offline kalırsa eski kayıtları temizleme veya
kullanıcının müdahalesini gerektiren bir uyarı sunun. Metrik olarak, 99% request’lerin <1sn içinde
tamamlanması hedeflenebilir, bağlantı gecikmesi durumunda işlem 3-5 saniyede yanıtlanmalı.
Kaynaklar: Flutter offline-first rehberi , Riverpod dokümantasyonu , Supabase Brick ve
PowerSync çözümleri , GraphQL Flutter örnekleri , bağlantı ve retry stratejileri . Bu
kaynaklar, yukarıdaki önerilerin temelini oluşturmaktadır.
Offline-first support | Flutter
https://docs.flutter.dev/app-architecture/design-patterns/offline-first
Performing side effects | Riverpod
https://riverpod.dev/docs/essentials/side_effects
What's new in Riverpod 3.0 | Riverpod
https://riverpod.dev/docs/whats_new
Building offline-first mobile apps with Supabase, Flutter and Brick
https://supabase.com/blog/offline-first-flutter-apps
PowerSync | Works With Supabase
https://supabase.com/partners/integrations/powersync
Using Supabase offline · supabase · Discussion #357 · GitHub
https://github.com/orgs/supabase/discussions/357
graphql_flutter | Flutter package
https://pub.dev/packages/graphql_flutter
Implementing the offline first database using the GraphQL API - Back4app Backend
https://www.back4app.com/docs/flutter/graphql/offline-first-database
Making a connection: Handling network issues in Flutter | by Maksim Lin | Medium
https://medium.com/@mksl/making-a-connection-handling-network-issues-in-flutter-217e7cfd30e9
Retry Package in Flutter: A Comprehensive Guide with Examples - Easy Techstack
https://easytechstack.com/retry-package-in-flutter/
•
1 9 2 3
5 8 17 18 21 15
1 9 10 12 13 14 15 16
2
3 4
5 6 7
8
11
17
18 19
20 21
22
8
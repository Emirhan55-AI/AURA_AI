API Katmanı
API katmanında GraphQL ve REST arasında karar verirken her iki paradigmanın güçlü ve zayıf yönleri
göz önünde bulundurulmalı, genellikle hibrit bir yapı tercih edilmelidir. Örneğin, okuma (read)
operasyonları için GraphQL, istemci tarafında ihtiyaç duyulan verileri tam olarak çekme imkânı
sunduğundan tercih edilir. Bu sayede iç içe ilişkili veriler (örneğin bir kullanıcı profilinin, yorumların ve
beğenilerin bir arada sorgulanması) tek istekle alınabilir ve gereksiz veri transferi azaltılır . Öte
yandan yazma (write) ve eylem (mutation) işlemleri için REST basitliği, standartlaşmış HTTP fiilleri
(POST, PATCH, DELETE vb.) ve Supabase’in PostgREST altyapısı sayesinde güçlü kimlik doğrulama/izin
kontrolü (Row Level Security) ile uyumu sebebiyle pratiktir .
Mimari Öneriler: Karmaşık veriyi (nested sorgular) tek adımda çeken sosyal besleme, detay
sayfaları gibi senaryolarda GraphQL; tekil CRUD işlemlerinde REST kullanılabilir. Örneğin, bir
“feed” sorgusunda GraphQL ile kullanıcı ve ilişkili içeriklerin birlikte getirilmesi, REST’te birden
fazla isteğin tek bir GraphQL çağrısına indirgenmesiyle performans kazanımı sağlar .
REST API ise hafif olduğu için binlerce eş zamanlı istek altında bile çok hızlı dönüş verebilir .
Genel mimaride, Flutter uygulamasında hem bir GraphQL istemci (ör. graphql_flutter
paketini kullanarak) hem de bir REST istemci ( supabase_flutter veya http / dio )
konfigüre edilmelidir. Böylece okuma ihtiyaçlarında GraphQL endpoint’i (Supabase GraphQL:
https://<proje>.supabase.co/graphql/v1 ) ve yazma ihtiyaçlarında REST
endpoint’leri (Supabase PostgREST: https://<proje>.supabase.co/rest/v1/ ) birlikte
kullanılabilir.
Araçlar & Kütüphaneler: REST için Flutter’da supabase_flutter , http ya da dio ;
GraphQL için graphql_flutter , graphql ve Apollo benzeri kütüphaneler tercih edilir.
Örneğin, supabase için pub.dev ’deki resmi paket olan supabase_flutter ile veritabanı
sorguları yapmak mümkündür . GraphQL için ise graphql_flutter kullanarak bir
GraphQLClient oluşturulur; bu istemci bir HttpLink ile Supabase GraphQL uç noktasına
bağlanır ve JWT veya API anahtarı AuthLink olarak eklenir .
Örnek Kod: Aşağıda, Flutter’da REST ve GraphQL istemci yapılandırmasına ilişkin örnekler
görülebilir:
// Supabase REST istemcisi ile veri sorgulama (supabase_flutter paketi)
final supabase = Supabase.instance.client;
final response = await supabase.from('users').select().eq('active',
true).execute();
final users = response.data; // Query sonucu
// GraphQL istemcisi oluşturma (graphql_flutter paketi)
await initHiveForFlutter(); // önbellek için Hive deposunu başlat
final HttpLink httpLink = HttpLink('https://<PROJECT_REF>.supabase.co/
graphql/v1');
final AuthLink authLink = AuthLink(getToken: () async => 'Bearer <JWT>');
final GraphQLClient client = GraphQLClient(
link: authLink.concat(httpLink),
1 2
3 4
•
5 2
4
6
•
7
8
•
1
cache: GraphQLCache(store: HiveStore()),
);
final QueryResult result = await client.query(
QueryOptions(
document: gql(r'''
 query GetUserPosts($userId: ID!) {
 userByPk(id: $userId) {
 id
 username
 posts {
 id title content
 }
 }
 }
 '''),
variables: { 'userId': 123 },
)
);
final userPosts = result.data?['userByPk'];
Bu örnekte REST sorgusu Supabase istemcisi üzerinden tablo adıyla ( from('users') ) yapılırken,
GraphQL sorgusu GraphQLClient aracılığıyla tek bir uç noktaya gönderilmiştir .
Potansiyel Sorunlar & Çözümler: GraphQL sunucu tarafında karmaşık sorguları işlemek daha
fazla işlem gücü gerektirebilir; sorgu derinliğine sınır koymak veya istek boyutunu sınırlamak
çözüm olabilir. Ayrıca farklı sorgular cache’lenmesi zor olduğundan istemci önbelleklemesi
( GraphQLCache , hive) ve network politikaları kullanılmalıdır. REST’te ise aşırı veri transferi
(overfetch) ve birden çok uç noktaya yapılan çağrılar performansı düşürebilir; bu durumda
gerekirse JOIN’li view’lar veya fonksiyonlar kullanılabilir. Her iki tarafta da test edilebilirlik için
izole unit testler oluşturulmalı, GraphQL sorgular için örnek mock sonuçlar kullanılabilir.
Performans, Bakım & Test: Supabase REST API’si Postgres üzerine çok ince bir katman
koyduğundan yüksek throughput sağlayabilir ve “binlerce eşzamanlı isteği” karşılayabilir .
GraphQL ise tek seferde çoklu tablo sorgulamasına izin vererek istemcideki ek işlem yükünü
azaltır . Kod bakımında, REST uç nokteleri daha öngörülebilirken, GraphQL’da şema değişikliği
istemci tarafını etkileyebilir; bu yüzden versiyonlama ve şema düzenlemeleri dikkatle
yönetilmelidir. Test etmeye gelince, REST endpoint’lerini Postman veya entegre testlerle kolayca
kontrol ederken, GraphQL sorguları ise metinsel sorgularla test edilip beklenen JSON çıktıları
doğrulanabilir.
Metinsel Şema/Akış: Örneğin, bir Flutter uygulaması veri çekmek istediğinde:
Flutter Uygulaması
 ├─(GraphQL isteği)─> Supabase GraphQL Endpoint (/graphql/v1) ─>
PostgreSQL
 └─(REST isteği)─> Supabase REST Endpoint (/rest/v1/table) ─>
PostgreSQL
7 9
•
•
4
2
•
2
Bu akışta istemci GraphQL istemcisi veya REST istemcisi üzerinden Supabase’e istek yapar.
Supabase API katmanı gelen isteği SQL’e çevirir, veritabanından veri çekip JSON olarak döner.
Use-Case Senaryoları: Örneğin bir sosyal medya feed’inde “kullanıcı + beğenileri + yorumları”
tek GraphQL sorgusuyla çekilebilirken, REST’te ayrı uç noktalara istek gerekebilir. Öte yandan
“profil güncelleme” gibi tek tabloyu değiştiren basit bir işlem REST üzerinden PATCH ile yapılabilir.
Chat uygulamasında yeni mesajlar için GraphQL aboneliği (subscription) kullanılabilir ya da
doğrudan WebSocket/Realtime kanalına geçilebilir (aşağıdaki bölüm).
Performans/Kapasite Tahminleri: Örneğin Supabase Realtime altyapısı için 10.000 eşzamanlı
istemci, saniyede 2.500 kanal girişi ve 2.500 mesaj işleme sınırları bildirilmiştir . REST API
açısından ise “Firebase’den %300 daha hızlı” yanıt verildiği ve binlerce eşzamanlı isteğe çıkabildiği
belirtilmektedir . Uygulama ihtiyaçlarına göre, örneğin günlük 1 milyon etkin kullanıcıya sahip
bir senaryoda sunucular yatay ölçeklenebilir; ancak çok yüksek hız gereksinimleri için özel
sunucular veya managed GraphQL çözüm(ler)i düşünülmelidir.
Flutter’da GraphQL ve REST İstemcisi Yapılandırması
Flutter uygulamasında hem REST hem de GraphQL API’lerini kullanmak için uygun istemci
kütüphaneleri konfigüre edilmelidir.
Mimari Öneriler: Genellikle supabase_flutter paketi uygulamayı veritabanına bağlamak ve
basit CRUD işlemleri yapmak için kullanılır. Bu paket aracılığıyla
Supabase.instance.client.from('table').select() gibi çağrılarla doğrudan REST API
çağrıları yapılabilir . Öte yandan graphql_flutter paketi bir GraphQL istemcisi sunar; bu
istemci, Flutter uygulamasının uygun yerlerinde (genellikle uygulama başlangıcında)
GraphQLClient ile başlatılıp bir GraphQLProvider (ya da GraphQLConsumer ) içinde
kullanılabilir.
Araçlar & Kütüphaneler: REST tarafında supabase_flutter (veya doğrudan
supabase_dart ), http , dio , hatta Retrofit benzeri çözümler kullanılabilir. GraphQL
tarafında graphql_flutter ve alt paketleri (gql, graphql) yaygındır. Kurulum için
pubspec.yaml dosyasına örneğin supabase_flutter: ^X.Y.Z , graphql_flutter:
^X.Y.Z eklenebilir. Kullanıcı kimlik doğrulaması ile birlikte Supabase’e bağlanmak için
Supabase.initialize(url: ..., anonKey: ...) fonksiyonuyla yapılandırma yapılır .
GraphQL istemcisi içinse aşağıdaki kod örneğinde görüldüğü gibi bir HttpLink ve AuthLink
yapılandırılır:
// Supabase REST istemcisi kurulumu
await Supabase.initialize(
url: 'https://<PROJECT_REF>.supabase.co',
anonKey: '<ANON_KEY>'
);
// GraphQL istemcisi kurulumu
await initHiveForFlutter();
final HttpLink httpLink = HttpLink('https://<PROJECT_REF>.supabase.co/
graphql/v1');
final AuthLink authLink = AuthLink(getToken: () async => 'Bearer <JWT>');
•
•
10
4
•
7
•
7
3
final GraphQLClient gqlClient = GraphQLClient(
link: authLink.concat(httpLink),
cache: GraphQLCache(store: HiveStore()),
);
Bu konfigürasyonlar yapılınca REST istekleri supabase.from('users').select() gibi yöntemlerle,
GraphQL sorguları ise gqlClient.query() veya Query/Mutation widget’larıyla gerçekleştirilebilir
.
Örnek Kod Şablonları: Yukarıdaki temel yapılandırmaya ek olarak, Flutter arayüzünde veriyi
çekmek için FutureBuilder veya StreamBuilder ile gelen veriler görselleştirilebilir.
Örneğin:
// REST ile veri çekme örneği
Future<List<Map<String, dynamic>>> fetchItems() async {
final response = await Supabase.instance.client
.from('items')
.select()
.eq('status', 'active')
.execute();
return List<Map<String, dynamic>>.from(response.data);
}
// GraphQL ile veri çekme örneği
Future<dynamic> fetchGraphQLData() async {
final QueryOptions options = QueryOptions(
document: gql(r'''
 query GetItems {
 items {
 id name description
 }
 }
 '''),
);
final result = await gqlClient.query(options);
return result.data?['items'];
}
Bu şablonlar, veri çeken fonksiyonların nasıl yazılacağını ve UI’da nasıl kullanılacağını göstermektedir.
Potansiyel Sorunlar ve Çözümler: REST API ile çalışırken CORS, kimlik doğrulama token süreleri
veya ağ hatalarıyla karşılaşılabilir; try/catch , yeniden deneme (retry) mekanizmaları ve
Flutter’ın connectivity_plus paketleri ile bağlantı kontrolü çözümdür. GraphQL tarafında ise
şema değişiklikleri istemcinin çökeğine sebep olabileceğinden, sorguları yeniden test etmek ve
yeni sorgular geliştirmek gerekir. Ayrıca, GraphQL sorgu sonucu olarak dönen
QueryResult ’daki hatalar mutlaka kontrol edilmelidir. Her iki durumda da test edilebilirlik
için sorgu/mutation fonksiyonları bağımsız sınıflarda yazılarak unit testler ile mock yanıtlar
kullanılabilir.
7 8
•
•
4
Performans, Bakım Kolaylığı & Test: REST istekleri genellikle SupabaseClient gibi tekil bir
nesne üzerinden yapıldığından testlerde mocklamak kolaydır. GraphQL sorguları ise metinsel
sorgu yapıları içerdiğinden, test için GraphQL mock servisleri veya graphql_flutter ’ın test
desteği kullanılabilir. GraphQL önbellekleme ( GraphQLCache ) ile aynı sorgunun tekrarından
kaçınılabilir. Ekip bakımında, REST uç nokteleri soyut sınıflarla yönetilerek (Örn. her tablo için bir
DAO/desen) düzen sağlanabilir; GraphQL’da ise sorgu şemalarının yönetimi (örneğin .graphql
dosyaları) ve tip güvenli Flutter nesnelere dönüştürülmesi (codegen) işleri vardır.
Akış Diyagramı: Flutter istemcisinin çalıştırdığı örnek bir işlem şöyle olabilir:
Kullanıcı arabirime gelir.
REST ile supabase.from('instruments').select() veya GraphQL ile
gqlClient.query(...) çağrılır.
İstek Supabase API katmanına ulaşır, istenen SQL çalıştırılır.
Postgres’ten dönen JSON yanıt Flutter’a gönderilir.
UI bu verilerle güncellenir.
Bu akışlar hem REST hem de GraphQL için benzer olup tek veya çoklu uç noktaya göre değişir.
Use-Case Senaryoları: Örneğin bir e-ticaret uygulamasında, ürün detay sayfası GraphQL ile
ürün bilgilerini, yorumları ve stok durumunu tek sorguda getirebilir. Bir API Key doğrulama, kayıt
veya şifre sıfırlama işlemi ise REST üzerinden basit POST istekleriyle halledilebilir. Başka bir
senaryoda, bir raporlama ekranı çok büyük SQL sorguları gerektirdiğinde REST (PostgREST)
yerine direkt özelleştirilmiş bir arka uç servisi (FastAPI vb.) kullanılabilir.
Performans/Kapasite Tahminleri: Tipik bir mobil uygulamada saniyede onlarca sorgu yapılması
olağandır. Örneğin temel okuma API isteklerinde Supabase’in saniyede binlerce isteğe dayanacak
kadar ölçekli olması ve Firebase’den %300 daha hızlı olması gösterilmiştir . GraphQL
sorgularının ise her istekte tek endpoint’e gönderilmesi, ağ trafiği ve istemci yanıt işlemlerini
azaltır ancak sunucu iş yükünü arttırabilir. Uygulama kullanım senaryosuna göre, öngörülen
eşzamanlı istemci sayıları ve istek hızları bu tür benchmark değerleriyle karşılaştırılarak (örn.
10.000 kullanıcı, 500 rps) sunucu kapasitesi planlanmalıdır.
WebSocket ile Gerçek Zamanlı Güncellemeler
Gerçek zamanlı güncellemeler için WebSocket tabanlı çözümler kullanmak en yaygın yaklaşımdır.
Flutter’da WebSocket desteği yerleşik olarak gelir (ör. web_socket_channel paketiyle) . Daha üst
düzeyde ise pub/sub özellikli altyapılar tercih edilir.
Mimari Öneriler: Sürekli veri akışı gerektiren özellikler (chat, canlı skorlar, bildirimler) için
WebSocket kullanmak idealdir. Supabase, Postgres trigger’larıyla entegre bir Realtime servisi
sağlar; supabase_flutter ’ın .channel() API’si aracılığıyla kanallara (topic) abone
olunabilir. Öte yandan GraphQL dünyasında subscription mekanizması (Apollo, Hasura)
WebSocket üzerinden çalışır. Bir GraphQL Subscription altyapısı kullanılmıyorsa, WebSocket
katmanını ayrı bir mikroservis veya üçüncü parti (Pusher, Ably vb.) üzerinden de eklemek
mümkündür.
Araçlar & Kütüphaneler: Supabase Realtime için Flutter’da supabase_flutter paketi
içindeki channel() metodu kullanılır . Örneğin:
•
•
•
•
•
•
•
•
•
4
11
•
•
12
5
final channel = supabase.channel('public:countries');
channel.onPostgresChanges(
event: PostgresChangeEvent.insert,
schema: 'public',
table: 'countries',
callback: (payload) {
print('Yeni kayıt: $payload');
}
).subscribe();
Bu kodla countries tablosuna yeni eklenen satırlar anında dinlenebilir . Alternatif olarak
genel WebSocket için web_socket_channel veya üçüncü parti SDK’lar (ör.
pusher_channels_flutter , ably_flutter ) kullanılabilir. GraphQL abonelikleri için
graphql_flutter paketindeki Subscription widget’ları veya benzeri kullanılır.
Örnek Kod: Yukarıdaki Supabase örneğine ek olarak, genel bir WebSocket bağlantısı kodu şöyle
olabilir:
import 'package:web_socket_channel/io.dart';
final channel = IOWebSocketChannel.connect('wss://echo.websocket.org');
channel.stream.listen((message) {
print('Sunucudan gelen mesaj: $message');
});
channel.sink.add('Merhaba sunucu!');
Ya da Pusher’da:
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
final pusher = PusherChannelsFlutter.getInstance();
await pusher.init(
apiKey: 'KEY',
cluster: 'eu',
);
await pusher.subscribe(channelName: 'my-channel', onEvent: (event) {
print('Pusher olayı: ${event.data}');
});
await pusher.connect();
Bu kodda Pusher ile bir kanala bağlanıp olaylar dinlenmiştir (haberleşme onEvent ile sağlanır).
Potansiyel Sorunlar ve Çözümler: WebSocket bağlantısının kopması durumunda yeniden
bağlanma (reconnect) stratejileri uygulanmalıdır. Mobilde arkaplan kısıtlamaları, uzaklaşma
sonrası düşen bağlantılar sorun olabilir; heartbeat mesajlarıyla bağlantıyı canlı tutma veya
offline destek için fallback (ör. kısa periyotta API sorgusu) mekanizması eklenmelidir. Supabase
Realtime’da sadece at most once teslim garantisi vardır; kritik veriler için idempotent işlemler
veya uygulama düzeyinde tekrar kontrol eklenebilir . Güvenlik açısından WebSocket
URL’lerinde JWT kullanımı (Supabase’da wss://<proje>.supabase.co/realtime/v1/
websocket?apikey=<API_KEY> ) ile kimlik doğrulama yapılır .
12
•
•
13
14
6
Performans, Bakım ve Test: Gerçek zamanlı kanallar nispeten hafiftir, ancak fazla istemci ve
mesaj durumunda sunucu yükü artar. Supabase Realtime, “kanal join” ve “mesaj” boyutu
bildirilen limitler dahilinde ölçeklenebilir . Test için bir test WebSocket sunucusu veya mock
kanal kurulabilir, stream.listen akışları unit testlerde simüle edilebilir. Uygulama yanıt hızı
için süzme/işleme maliyetleri değerlendirilmeli; örneğin göçebe kullanıcılar için varlık (presence)
yönetimi maliyeti ek yük getirebilir.
Akış Diyagramı: Örneğin bir sohbet odasında mesaj akışı:
[Kullanıcı A Flutter App] ───> (WebSocket) ───> [Realtime Sunucusu] ───>
(WebSocket) ───> [Kullanıcı B Flutter App]
Burada Supabase Realtime ya da benzer bir sunucu, A’nın gönderdiği mesajı broadcast veya
postgres_changes kanalından dinleyen B’ye iletir. Supabase iç mimaride her istemci bir “Phx”
kanalına katılır ve sunucu Postgres trigger’ları ile değişimi diğer istemcilere yayınlar.
Use-Case Senaryoları: Canlı sohbet uygulaması, oyun içi skor güncellemeleri, takip sistemi
(location tracking) veya bir editörde çok kullanıcılı iş birliği gibi senaryolarda WebSocket
vazgeçilmezdir. Örneğin bir mobil anket uygulamasında, cevapları gönderdikten sonra diğer
kullanıcıların canlı sonuçlarına abone olunabilir. GraphQL’un Subscription desteği
olmadığında Supabase veya Pusher kullanmak, mevcut altyapıyı kullanarak real-time sağlar.
Performans/Kapasite Tahminleri: Daha önce belirtildiği gibi Supabase Realtime tek seferde on
binlerle ifade edilen eşzamanlı bağlanmayı ve binlerce mesaj/saniye trafiğini destekleyebilir .
Örneğin Pro planında 500 eşzamanlı kullanıcıya ve saniyede 500 mesaja izin verir . Çözüm
alternatifleri göz önünde bulundurularak, yüksek trafiğe çıkılacaksa özel gerçek zamanlı
sunucular (Örn. AWS AppSync, Ably) tercih edilmeli; bu servisler 99.999% SLA ve milyonlarca
istemci kapasitesi sunar .
Supabase Realtime’dan Diğer Altyapılara Geçiş Planlaması
Supabase Realtime altyapısından daha özel veya ölçeklenebilir gerçek zamanlı çözümlere geçiş
gerekebilir.
Mimari Öneriler: Uygulamayı modüler tutarak gerçek zamanlı katmanı soyutlamak önemlidir.
Örneğin, uygulama mimarisinde bir RealtimeService arayüzü tanımlanıp, başta Supabase
implementation kullanılırken ileride Pusher/Ably implementation’ı eklenebilir. Böylece kodda
büyük değişiklik yapmadan altyapı değiştirilebilir. Ayrıca multi-region ihtiyacı doğarsa, global
PoP’lara sahip servisler (Ably, PubNub) veya kendi coğrafi birden çok veri merkezi mimarileri
planlanmalıdır.
Araçlar & Kütüphaneler: Supabase ötesinde yaygın seçenekler şunlardır: Pusher Channels
(Flutter’da pusher_channels_flutter paketi) ve Ably Realtime (Flutter için
ably_flutter ), AWS’nin AppSync veya WebSocket API Gateway, Google’ın Firebase Realtime DB veya Cloud Firestore (websocket bazlı). Her biri farklı ölçek ve fiyat modelleri sunar.
Örneğin Pusher’ın “Plus” planında 20.000 eşzamanlı bağlantı ve 60 milyon mesaj/gün
desteklenirken , Ably ücretsiz planda 200 kanal, 200 bağlantı sunar .
•
10
•
•
•
10
15
16 15
•
•
17 16
7
Örnek Kod: Örneğin Pusher ile bir Flutter uygulamasında kanal abone olma ve olay dinleme
şöyle olabilir:
final pusher = PusherChannelsFlutter.getInstance();
await pusher.init(apiKey: 'KEY', cluster: 'eu');
await pusher.subscribe(channelName: 'chat-room', onEvent: (event) {
final data = jsonDecode(event.data);
print('Yeni mesaj: ${data['text']}');
});
await pusher.connect();
Bu kod snippet’i, dış kaynak olarak Pusher Channels’a bağlanmayı göstermektedir. Ably için
benzer şekilde:
import 'package:ably_flutter/ably_flutter.dart';
final realtime = Realtime(options: ClientOptions(key: 'API_KEY'));
final channel = realtime.channels.get('updates');
await channel.subscribe().listen((ably.Message message) {
print('Ably mesajı: ${message.data}');
});
Her iki örnek de websockets üzerinden mesaj almayı kurar.
Potansiyel Sorunlar ve Çözümler: Taşıma işlemi sırasında, eski gerçek zamanlı kanal isimlerinin
yeni altyapıda eşlenmesi, kullanıcı kimlik doğrulamasının adaptasyonu ve mesaj formatı (JSON
şeması) uyumluluğu kontrol edilmelidir. Ayrıca veri çoğaltma (örneğin geçmiş mesajların
aktarımı) gerekiyorsa bu ayrı bir geçiş süreci olmalıdır. Bütçe açısından, Pusher/Ably gibi
hizmetlerin maliyeti işlem hacmine bağlıdır; Supabase’ın kullanıcı başına fiyatlamasıyla
kıyaslanarak hesaplama yapılmalıdır.
Performans, Bakım ve Test: Yeni altyapı seçildiğinde uç noktaları (endpoint’leri) yeniden
yapılandırmak ve test etmek gerekir. Mock servislerle entegrasyon testleri, benzer gerçek
zamanlı yük testleri planlanmalıdır. Sürekli teslimat (CI/CD) süreçlerine Ably veya Pusher
ayarlarını eklemek için ilgili SDK’ların CLI araçları veya Terraform modülleri kullanılabilir.
Uyumluluk için, eski Supabase Realtime verilerini dinleyen kodu kademeli olarak yeni kodla
güncellerken, sistemler paralel çalıştırılarak A/B testi yapılabilir.
Use-Case Senaryoları: Geçiş örneği olarak, “küresel ölçekli canlı sohbet” ihtiyaçlarında Pusher
veya Ably gibi hizmetlere geçilebilir. Veya “gerçek zamanlı çok kullanıcılı çizim uygulaması” gibi
yüksek veri akışına sahip senaryoda Ably’nin sunduğu multi-protokol (WebSocket, MQTT) ve
yüksek SLA fayda sağlayabilir . Ayrıca “anlık bildirim sistemi” gibi salt push mesaj
senaryolarında Firebase Cloud Messaging veya SNS de değerlendirilebilir.
Performans/Kapasite Tahminleri: Supabase’ın Pro planındaki (500 kullanıcı, 500 msg/s) limitleri
aşılması durumunda Pusher’ın Enterprise planları (ör. 20k bağlantı, 60M mesaj/24saat ) veya
Ably’nin ölçekli çözümleri ile karşılaştırma yapılmalı; bu karşılaştırmada gecikme, teslim garantisi
(sıra, tekrar gönderme desteği) gibi parametreler göz önüne alınmalıdır. Örneğin, Pusher
“Startup” paketi 1M mesaj/ gün sunarken, Supabase ücretsiz sınırlarda 100 msg/s ile sınırlıdır
; ihtiyaç arttıkça daha üst paket veya tam yönetimli servisler gerekli olabilir.
•
•
•
•
16
•
17
18
8
Kaynaklar: Yukarıdaki öneriler ve bilgiler [Supabase belgeleri] , geliştirici blogları ve
karşılaştırma makaleleri temel alınarak derlenmiştir . Bu kaynaklar, GraphQL/REST
avantajları ve Supabase Realtime’ın limitleri hakkında sayısal veriler sağlamaktadır.
GraphQL vs. REST APIs: What’s the difference between them - LogRocket Blog
https://blog.logrocket.com/graphql-vs-rest-apis/
GraphQL vs REST API - Difference Between API Design Architectures - AWS
https://aws.amazon.com/compare/the-difference-between-graphql-and-rest/
REST API | Supabase Docs
https://supabase.com/docs/guides/api
GraphQL | Supabase Docs
https://supabase.com/docs/guides/graphql
Use Supabase with Flutter | Supabase Docs
https://supabase.com/docs/guides/getting-started/quickstarts/flutter
graphql_flutter | Flutter package
https://pub.dev/packages/graphql_flutter
Socket.IO vs Supabase Realtime: which should you choose in 2025?
https://ably.com/compare/socketio-vs-supabase
Building realtime apps with Flutter and WebSockets: client-side considerations
https://ably.com/topic/websockets-flutter
Flutter: Subscribe to channel | Supabase Docs
https://supabase.com/docs/reference/dart/subscribe
Realtime Protocol | Supabase Docs
https://supabase.com/docs/guides/realtime/protocol
Pusher vs Supabase Realtime: which should you choose in 2025?
https://ably.com/compare/pusher-vs-supabase
Supabase Competitors & Alternatives Choosing the Right BaaS | MetaCTO
https://www.metacto.com/blogs/supabase-competitors-alternatives-a-comprehensive-guide
4 19 7 12
1 3 10 18 16
1 3 5
2
4
6 9 19
7
8
10 13
11
12
14
15 17 18
16
9
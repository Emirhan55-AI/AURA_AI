FastAPI Uygulaması
Entity/Use-Case Organizasyonu
FastAPI servisinde kod temizliği ve sürdürülebilirlik için katmanlı mimari (Clean/Hexagonal Architecture)
benimsenebilir. Örneğin, Domain/Entity katmanı (veri modelleri) uygulamanın çekirdek iş kurallarını
taşır. Use-case (Application) katmanı ise her iş akışını (örneğin “ihale açma”, “teklif verme” gibi)
yöneten sınıfları içerir. Her use-case, ihtiyaç duyduğu repository arayüzlerini (adaptörleri) bağımlılık
olarak alır; böylece veri erişim detayı soyutlanır ve test edilebilirlik artar. Son olarak Controller/Router
katmanı HTTP isteklerini alır, uygun use-case’i çağırır ve yanıt döner. Bu şekilde “entity, use case,
adapter (repository), controller” gibi katmanlara ayrılmış bir yapı, kodun bakımı ve genişletilmesini
kolaylaştırır .
Domain Modelleri (Entity): Uygulamanın iş nesneleri, Pydantic modelleri veya dataclass’lar ile
tanımlanır. Örneğin bir Kullanıcı , Sipariş gibi nesneler iş kurallarını taşır.
Use-Case Sınıfları: Her iş akışı (ör. kullanıcı kaydı, sipariş onayı) bir sınıfta toplanır. Bu sınıflar iç iş
mantığını (ör. koşulların kontrolü, işlemlerin gerçekleştirilmesi) yönetir ve veri erişim arayüzlerini
kullanır.
Repository/Adapter: Veri kaynağına erişim (Supabase API çağrıları) burada tanımlanır.
Repository arayüzleri use-case’lere enjekte edilir; böylece uygulama çekirdeği veritabanından
bağımsız olur. İleride farklı bir veri kaynağına geçiş kolaylaşır.
Controller/Router: FastAPI’nin endpoint’leri, HTTP isteğini alıp uygun use-case’i çağırır. Bu
katman sadece istek/yanıt dönüşümü ile ilgilenir, iş kurallarını içermez.
Bu katmanlı yapı sayesinde uygulama modüler, test edilebilir ve kolay genişletilebilir hâle gelir .
Flutter ile JWT Kimlik Doğrulama
Flutter uygulaması Supabase Auth servisiyle kullanıcı oturumu açtığında bir JWT (access token) alır. Bu
token Flutter tarafında güvenli bir şekilde saklanıp (ör. Flutter Secure Storage) sonraki isteklerde
Authorization: Bearer <token> başlığında FastAPI’ye gönderilir. FastAPI tarafında ise gelen
isteklerdeki token, Supabase tarafından doğrulanabilir. Örneğin, bir verify_token bağımlılık
fonksiyonu yazarak gelen token’ı Supabase’in /auth/v1/user endpoint’ine istek atarak kontrol
edebilirsiniz . Geçerliyse endpoint, token’a karşılık gelen kullanıcı bilgilerini JSON olarak döner ve
FastAPI rotasında Depends ile bu kullanıcı bilgisini alabilirsiniz. Böylece her iki katmanda da aynı JWT
kullanılmış ve güvenli bir doğrulama sağlanmış olur. Özetle:
Flutter’da Supabase Auth ile oturum açılır, elde edilen JWT her istekle FastAPI’ye gönderilir.
FastAPI’de bir Depends fonksiyonu ile gelen JWT’i Supabase Auth servisi üzerinde doğrulatılır
(ör: requests.get("https://<proje>.supabase.co/auth/v1/user") gibi) .
Doğrulanan token’dan dönüt olarak kullanıcı bilgisi (ör. user_id , rol) alınır ve rota işleyicisine
iletilir. Böylece rota bazlı yetkilendirme yapılabilir.
Gerekirse Flutter’da yenileme token akışıyla yeni JWT alınır ve güncel token tekrar backend’e
iletilir.
Bu sayede, hem Flutter hem FastAPI katmanları tutarlı bir kimlik doğrulama mekanizması kullanır ve
Supabase’in RLS politikaları etkin şekilde çalışır.
1
•
•
•
•
1
2
•
•
2
•
•
1
Supabase Verisi ile Çalışan Servislerde Güvenlik ve Hız
FastAPI – Supabase iletişiminde veri güvenliği için HTTPS kullanımı esastır; Supabase API çağrıları SSL ile
şifreli kanalda yapılır. Supabase’in Row Level Security (RLS) kuralları sayesinde her kullanıcı yalnızca
yetkili olduğu satırları görebilir. Buna bağlı olarak, FastAPI katmanında JWT doğrulandıktan sonra rol/ID
bilgisi Supabase’e aktarılır ve RLS devreye girer. RLS koşullarında kullanılan sütunlara (ör. user_id )
mutlaka indeks eklenmelidir; bu, büyük tablolar için sorgu performansını kat kat artırır . Ayrıca,
sorgularınızda RLS politikasına paralel filtreleme de eklemek, gereksiz taramaları önleyerek hızı
iyileştirir (örn. .eq("user_id", current_user_id) kullanmak) .
Performans için ise şunlar önerilir:
- FastAPI’den Supabase’in REST/GraphQL API’sine asenkron HTTP istemcisiyle bağlanın (ör.
httpx.AsyncClient ), böylece her istekte diğer işlemler bloklanmaz .
- Benzer sorguları veya statik verileri önbelleğe alın. Örneğin Redis ile sık erişilen veri veya sonuçları
önbelleğe yazmak, sonraki istekleri hızlandırır .
- Büyük veri çekmek yerine ihtiyaç duyulan alan ve kayıtları sınırlandırın; gereksiz tüm verilerin
transferinden kaçının.
- Ağ gecikmesini azaltmak için Supabase sorgularında toplu işlemler veya GraphQL kullanılabilir.
Bu önlemlerle FastAPI – Supabase arasındaki ek ağ yükü dengelebilir, güvenlikten ödün vermeden yanıt
sürelerini kısaltabilirsiniz .
FastAPI Performans ve Ölçeklenebilirlik Önerileri
FastAPI, Python’un asyncio tabanlı yapısı ile IO-bound işlemlerde yüksek verim sağlar. İşlemler
asenkron yazıldığında aynı anda birden çok istek işlenebilir; örneğin await httpx.get(...) gibi
çağrılar diğer istekleri bloke etmeden yürür . Veritabanı veya harici API çağrıları için uygun indeksler,
bağlantı havuzu ve async sürücüler (ör. asyncpg ) kullanmak sorgu hızını artırır. Aynı zamanda
önbellekleme (cache) stratejileri kritik öneme sahiptir; sık kullanılan yanıtları Redis gibi bir ara
katmanda tutarak uygulama yükünü azaltabilirsiniz .
Üretimde FastAPI uygulamasını ölçeklendirmek için şu yaklaşımlar kullanılabilir:
- ASGI Sunucuları: Uvicorn (veya Hypercorn) gibi yüksek performanslı ASGI sunucusu altında, Gunicorn
ile birden çok işçi (worker) kullanın. Örneğin
gunicorn -w 4 -k uvicorn.workers.UvicornWorker app:app komutu dört işçi ile talepleri
paralel karşılar .
- Ters Proxy: Nginx gibi bir ters-proxy konfigürasyonu, SSL sonlandırma ve statik dosya servisi yaparak
yükü azaltır.
- Yatay Ölçeklendirme: Uygulamayı Docker/Kubernetes gibi araçlarla birden çok kopya (replica) olarak
çalıştırıp bir load balancer arkasına almak, talepleri dağıtarak kapasiteyi artırır .
- Performans İzleme: Prometheus, Grafana gibi araçlarla uygulama metriklerini (gecikme, hata oranı
vb.) izleyip darboğazları tespit edin .
- Rate Limiting: fastapi-limiter gibi kütüphanelerle IP veya kullanıcı bazlı istek sınırlandırma
uygulayarak servislerin aşırı yüklenmesi engellenebilir.
Unutmayın ki FastAPI “hızlı” bir framework olsa da gerçek ölçeklenebilirlik doğru konfigürasyon ve
testlerle sağlanır. Uygulamanızı yük testlerinden geçirin ve gerçek zamanlı metrikler ile kaç işçi
gerektiği, donanım kaynak kullanımı gibi kararları verin . Bu önerilerle FastAPI servisiniz
yüksek trafikte dahi dengeli ve hızlı çalışabilir.
3
4
5
6
3 4
5
6
7 8
9 8
10
11 12
2
Kaynaklar: FastAPI ve Supabase dokümanları ile topluluk kaynakları incelenmiştir .
Clean Architecture example in python and PostgreSQL | by Mohamed Rasvi | DevOps.dev
https://blog.devops.dev/clean-architecture-exaplme-python-and-postgresql-59a95bcf8d56?gi=db4102e5d7ec
Building an API with FastAPI and Supabase | by Lior Amsalem | Medium
https://medium.com/@lior_amsalem/building-an-api-with-fastapi-and-supabase-c61a74d4e2f4
Supabase Docs | Troubleshooting | RLS Performance and Best Practices
https://supabase.com/docs/guides/troubleshooting/rls-performance-and-best-practices-Z5Jjwv
Optimizing FastAPI for High Performance: A Comprehensive Guide | by Tom |
Medium
https://tomtalksit.itsupportpro.uk/optimizing-fastapi-for-high-performance-a-comprehensive-guide-1e08c16924b3?
gi=af16a0454efd
FastAPI Best Practices: A Condensed Guide with Examples - DEV Community
https://dev.to/devasservice/fastapi-best-practices-a-condensed-guide-with-examples-3pa5?context=digest
FastAPI Under Fire: Load Testing and Scaling With Gunicorn & Uvicorn Workers | by Nikulsinh Rajput
| Jul, 2025 | Medium
https://medium.com/@hadiyolworld007/fastapi-under-fire-load-testing-and-scaling-with-gunicorn-uvicorn-workersb6362550bff8
1 2 3 5 7
1
2
3 4
5 6 7 9 10 12
8
11
3
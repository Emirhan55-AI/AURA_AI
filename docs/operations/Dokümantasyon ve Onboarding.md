Dokümantasyon ve Onboarding
Teknik dokümantasyon projenin tüm paydaşları (geliştiriciler, ekipler vs.) için tek bir gerçek kaynak
(single source of truth) olarak tasarlanmalıdır. Bunun için projede docs/ gibi bir klasör altında veya
doğrudan monorepo kökünde tüm teknik belgeler Markdown formatında tutulur. Belgeler versiyon
kontrolüne eklenmeli, böylece her sürümde güncel kalması sağlanmalı . Dokümantasyonu
yazarken yapılandırılmış yazarım modeli ve single-sourcing stratejisi kullanılmalıdır; örneğin aynı
bilgiyi tek bir yerde tutup gerektiğinde referans vermek en iyi yaklaşımdır . Dokümanlarda kod
örnekleri, diyagramlar ve akış şemaları yer almalı, aranan bilgilerin kolay bulunması için net başlıklar ve
içerik haritası (TOC) eklenmelidir. Belgeler dokümantasyon-as-code yaklaşımıyla ele alınarak MkDocs,
Docusaurus veya Sphinx gibi statik site jeneratörleriyle bir web sitesine dönüştürülebilir .
Örneğin MkDocs konfigürasyonunda site_name , nav gibi ayarlar yapılarak içindekiler belirlenir ve
mkdocs build ile statik site üretilir. Teknik dokümanlar için aşağıdaki örnek yapı kullanılabilir:
Monorepo Dosya Yapısı Örneği (Metinsel):
/README.md (Proje genel tanıtımı)
/CONTRIBUTING.md (Katkı kuralları)
/docs/ (Genel dokümantasyon: kılavuzlar, mimari,
onboarding vb.)
/docs/arch.md (Mimari genel bakış belgesi)
/docs/onboarding.md (Yeni geliştirici rehberi)
/frontend/ (Flutter uygulaması kodu ve kendi README’i)
/backend/ (FastAPI kodu ve kendi README’i)
/supabase/ (Supabase şemaları, fonksiyonlar)
/adr/ (Mimari Karar Kayıtları - ADR dosyaları)
mkdocs.yml (MkDocs yapılandırma dosyası)
Mimari Öneriler: Belgeleri monorepo içinde merkezi olarak tutun (örneğin /docs veya kök
dizin README). Tanımların tekrar etmemesine dikkat edin; örneğin bir API açıklamasını hem
kodda hem belgeden ayrı ayrı yazmak yerine OpenAPI spec’i tek kaynak yapın . Belge
klasörleri net isimlendirmeli ve hiyerarşik olmalıdır (örn. “Mimari”, “Kurulum”, “API Referansı”
gibi). Yüksek seviyeli diyagramlar projeyi özetlemeli; örneğin bir mimari şema (deployment
diyagramı) hem kod modüllerini hem kullanılan altyapıyı göstererek geneli kavramayı sağlar .
Bu belgeler, geliştiricilerin projedeki katmanları (Flutter, FastAPI, veritabanı, real-time servisler)
hızla anlamasına yardımcı olur. Monorepo ortamında kurallar ve sürec dokümantasyonu hayati
önemdedir; Microsoft örneğinde olduğu gibi ekip, “ne nereye yazılır” rehberleri ve demo
uygulamalarla kaotik bir yapıyı önlemiştir .
Kullanılacak Araçlar ve Kütüphaneler: Markdown formatında yazmak ve versiyon kontrolü
sağlamak için GitHub/GitLab en uygunudur . Stok statik site jeneratörleri arasında MkDocs
(Python, kolay yapılandırma) öne çıkar . Bunun yanında Docusaurus veya Sphinx (özellikle
Python tarafı için) de kullanılabilir. CI/CD entegrasyonu için MkDocs, Docsify veya GitHub Pages
benzeri araçlarla dokümantasyon otomatik olarak yayınlanabilir . Kod örnekleri ve
diyagramlar için ayrıca PlantUML veya Mermaid gibi araçlarla belgelere entegre şemalar
1 2
3 4
2 5
•
•
4
6
7 8
•
9
2
5 2
1
oluşturabilirsiniz. Ayrıca, lint/CI araçlarıyla belgeleri kontrol edebilir (örneğin MkDocs link
kontrolü) ve README gibi ana giriş belgelerini güncel tutacak kod inceleme kuralları
koyabilirsiniz.
Örnek Kod Şablonları: Örneğin mkdocs.yml yapılandırması:
site_name: "Aura Proje Dokümantasyon"
docs_dir: docs
theme: readthedocs
nav:
- Anasayfa: index.md
- Mimari: arch.md
- Onboarding: onboarding.md
- API Referansı: api_ref.md
Bu, /docs altındaki Markdown dosyalarını statik site olarak derleyecektir. Benzer şekilde, her
projenin kendi README.md’sine “Nasıl Başlanır” bölümü ekleyin; örneğin Flutter ve FastAPI
dizinleri içine temel kurulum adımları koyun.
Potansiyel Sorunlar ve Çözümler:
Eskiyen belgeler: Dokümantasyonu kodla birlikte ele alın (docs-as-code) ve CI’da her PR’da derleyip
kontrol edin. Kod güncellemesi yapıldığında mutlaka belgelere de doküman kodunu ekleyen bir
zorunluluk (merge gate) koyun.
Çok sayıda doküman: Belgeleri modüler tutun, ana indeksi ve arama özelliğini (MkDocs arama)
kullanın.
Kaynak karışıklığı: Tek bir kaynak/pratik kural belirleyin (örneğin OpenAPI spec için tek YAML
dosya tutun) . Kodda anotasyonlarla dökümantasyon üretimi veya tasarım-önce (design-first)
yöntemleriyle tutarlılığı sağlayın .
Dil ve güncelleme yönetimi: Belgeleri kolay okunur, anlaşılır basit dille yazın. Sürekli revize edilmesi
için süreç belirleyin; bir problem çözüldüğünde rehberi güncelleyen madde gibi.
Performans, Bakım ve Test: Statik dokümanlar sunucu yükü minimaldir; önemli olan derleme
süreci ve güncelliğidir. MkDocs gibi araçlar birkaç saniyede siteyi oluşturabilir. Örneğin 50 sayfalık
bir dokümantasyon sitesi ~5–10 saniyede inşa edilebilir (CI’da test edilebilir). Gösterimler CDN
üzerinden sunularak sayfa açılışları çok hızlı olur. Yazılan kod parçacıkları (örn. terminal
komutları) ayrı dosya blokları olarak kolay kopyalanabilir olmalı; CI’da bu komutların çalıştırılması
(örneğin make setup ) test senaryosu gibi eklenebilir. Link kırılmalarına karşı kontroller (lint,
link checker) ve yazım denetimi (spellcheck) pipeline’a entegre edilebilir. Belgelerin bakımını
kolaylaştırmak için aynı kategorideki içerikleri ortak sayfalar altında toplayın ve değişiklik
yapmayı revizyon kontrolünden takip edin.
Akış Şeması (Örnek):
[Döküman Yazarı] → Markdown Şeklinde Belge Hazırlar → Git’e Commit’ler
 → (CI/CD) → MkDocs ile statik siteye çevirir → Ekip Belgeleri
İnceler
•
•
•
•
•
1
10 1
•
•
•
2
Bu basit akışta belgeler kod ortamıyla eş zamanlı geliştirilir. Belgeler versiyon kontrolüyle
tarihçelendirilir ve CI/CD üzerinden sürekli güncel siteye dönüştürülür.
Use-Case Senaryoları:
Yeni Özellik Ekleme: Geliştirici projeye yeni bir modül eklerken (örn. yeni REST endpoint veya
GraphQL sorgusu), ilgili dokümantasyon maddesini de günceller. Bu güncelleme PR inceleme
sürecine dahil edilir. Böylece yeni kod ile belge eş zamanlı güncel kalır.
Mimari Değişim: Örneğin projedeki veri yönetimi değişirse (Supabase’ten GraphQL’e geçme gibi),
bu önemli karar ADR olarak kaydedilip dokümanlarda güncellenir. Ekip üyeleri belgelere bakarak
yapılacak değişikliklerin gerekçesini görür.
Performans/Kapasite Tahminleri: Belgelerin statik sunumu, örneğin bir S3 veya GitHub Pages
sunucusundan çok hızlı (ilk byte <100ms) yanıt verecek şekilde ölçeklenir. MkDocs derleme
süresi, içerik büyüklüğüne bağlı olarak değişir; hedef birkaç on saniyenin altında tutulmalıdır.
Örneğin 100 sayfa, bazı resim ve kod bloğu içeren bir döküman birkaç saniyede derlenebilir.
Dosya boyutları genellikle küçük (kilobyte’lar düzeyinde) olacağından bant genişliği yükü
düşüktür. Arama ve indeksleme kabiliyeti de statik dosyalarda yerleşik olarak sağlanır veya
eklenti ile eklenebilir. Çok dilli destek gerekiyorsa her dil için ayrı klasörler oluşturun ve docs/
locale/ gibi bir yapı kullanın; bu, payload’ı bölerek her dil versiyonunu ayrı tutmanıza izin verir.
Monorepo yapısının üst dizin hiyerarşisine bir örnek. Projedeki Flutter uygulaması, FastAPI servisi,
dokümantasyon ve diğer bileşenler tek bir depoda toplanır. Monorepo, tüm katmanların bir arada
görülmesini sağladığından ortak standartları benimsemeyi ve sistemin genel haritasını anlamayı
kolaylaştırır .
Yeni Geliştirici Onboarding Süreci
Yeni bir geliştiricinin projeye katılımı adım adım planlanmalı ve belgelerle desteklenmelidir. Başarılı bir
onboarding rehberi açık, özlü ve izlenebilir olmalıdır; mümkün olduğunda Docker veya betikler
(Makefile, script) kullanarak ortam kurulumunu otomatikleştirin . Öncelikle README.md ve /docs/
onboarding.md gibi belgeleri okuyarak projeyi ve klasör yapısını anlamalıdır. Örneğin bir monorepo’da
temel dizinler ( /frontend , /backend , /supabase vb.) ile ilgili kısa açıklamalar ve örnek komutlar
bulunmalıdır. Gerekli adımlar şunlardır:
Kurulum Adımları (Örnek): Geliştirici projeyi klonlar, make setup veya benzeri bir komutla
bağımlılıkları yükler, bir .env.example dosyasını kopyalayıp gerekli çevresel değişkenleri
( SUPABASE_URL , FASTAPI_SECRET_KEY gibi) tanımlar. Ardından flutter pub get ve
pip install -r requirements.txt komutlarıyla hem Flutter hem Python bağımlılıkları
indirilir. En son adımda make test veya flutter test , pytest gibi test komutlarıyla her
şeyin doğru kurulduğu doğrulanır.
Kullanılacak Araçlar: Docker/Docker Compose ile geliştirme ortamı oluşturulabilir (örneğin
lokal Supabase başlatma). VSCode Remote Containers veya devcontainer.json kullanarak önyüz
ve arka uç için önceden tanımlı bir konteyner ortamı sağlanabilir. Proje için Makefile veya
justfile gibi görev dosyaları oluşturup tek komutla tüm hazırlığı yapabilirsiniz. Gizli
anahtarlar için 1Password veya git-crypt gibi araçlarla güvenli paylaşımlar yapılmalı, örn.
.env.example dosyası ve çevresel değişken yönergeleri README’de belirtilmelidir . Ayrıca
“CONTRIBUTING.md” dosyası yeni geliştiricinin ekleyebileceği kod standartlarını, PR süreçlerini
ve kod inceleme kurallarını içerir.
•
•
•
•
8 7
11
•
•
11
3
Örnek Komut Şablonları: Monorepo kökünde bir Makefile örneği:
setup:
cd backend && pip install -r requirements.txt
cd frontend && flutter pub get
cp .env.example .env
 # Ortam değişkenlerini tanıtın
test:
cd backend && pytest
cd frontend && flutter test
Bu sayede tek bir make setup tüm hazırlığı yapar, make test ise hem backend hem
frontend testlerini çalıştırır.
Potansiyel Sorunlar ve Çözümleri:
Ortam Değişkenleri Eksikliği: Gerekli tüm değişkenler .env.example içinde dokümante edilmeli
ve onboarding belgesinde açıklanmalıdır. Gerçek anahtarlar asla repo’ya push edilmemeli; bunun
yerine gizli yöneticileri üzerinden (örn. Vault) sağlanmalı.
Çok Bilgi Verilmesi: İlk aşamada kritik adımları ve araçları önceliklendirin. Yeni geliştiricinin
çalışmayan bir ortamla boğulmaması için ileri detayları daha sonraki adımlara bırakın. Adım
adım rehberi ve checkbox’lı kontrol listeleri kullanarak bilgi yükünü azaltabilirsiniz.
Sistem Uyumsuzlukları: Geliştiriciler farklı işletim sistemleri kullanabilir. Ortamı Docker ile standart
hale getirmek veya ihtiyaç duyulan yazılım sürümlerini .tool-versions (asdf) ya da .nvmrc
gibi dosyalarla belirtmek faydalıdır. Her ortam kurulumu sonrası geliştirme ortamının doğru
çalıştığından emin olmak için kapsamlı testleri kullanın.
Doküman Eksikliği: [21]’de belirtildiği gibi, bir sorun çözülürse bu bilgi onboarding rehberine
eklenmelidir . Eğer onboarding rehberi yoksa sorunun çözümünü belgeleyip proje reposuna
ekleyin. Bu şekilde doküman sürekli güncel kalır.
Performans, Bakım ve Test: Onboarding süreci hedefi, yeni geliştiricinin ilk günde çalışır bir
geliştirme ortamına sahip olmasıdır (örneğin 1–2 saat içinde uygulamayı çalıştırabilmeli). Bunun
için hazırlanacak dökümantasyonun net ve kısa olması önemlidir. Geliştirici ortama ait komutları
CI ile test ederek (“Dokümanlarda yazan make setup adımı hatasız çalışıyor mu?”) belgelerin
doğruluğu sağlanabilir. Kapsamlı kontroller (ör. make ci ) ile ortamın tamamen kurulup
kurulmadığı otomatik kontrol edilebilir. Ayrıca onboarding belgelerinde belirtilen komutlar ve
adımlar birleştirilerek bir rehber sayfası veya video olarak da sunulabilir.
Akış Şeması (Onboarding):
[Yeni Geliştirici]
 ↓
 Proje Depoyu Klonla
 ↓
 README.md / Onboarding Belgelerini Oku
 ↓
 Ortam Değişkenlerini Yapılandır (.env)
 ↓
 Bağımlılıkları Yükle (`make setup`)
 ↓
 Testleri Çalıştır (`make test`)
•
•
•
•
•
•
12
•
•
4
 ↓
 Geliştirmeye Başla
Use-Case Senaryoları:
İlk Gün Senaryosu: Ayşe, projeyi öğrendiği gün README.md ve onboarding belgelerini okuyarak
işe başlar. Belgelerde anlatıldığı gibi make setup komutunu çalıştırır, ardından kısa bir deneme
uygulaması çalıştırarak ortamının doğru kurulduğunu kontrol eder. Geliştirme yapacağı alanın
yerini belirlemek için /frontend ve /backend klasörlerine göz atar.
Ortam Güncellemesi: Projede büyük bir güncelleme sonrası (örn. Supabase versiyon yükseltmesi)
bilgiyi onboarding sayfasına eklemek gerekir. Geliştirici, yaşadığı kuruluma dair problemi çözerek
bunu belgelere ekler, böylece bir sonraki katılan kişi aynı hatayı yaşamaz.
Performans ve Kapasite Tahminleri: Onboarding dokümanları genellikle metin odaklı olduğu
için çok büyük olmaz (küçük birkaç MB). Depoyu klonlama ve kurulum süresi donanıma bağlı
olmakla birlikte, iyi yapılandırılmış scriptlerle ilk kurulum genellikle 5–15 dakika arasında
tamamlanmalıdır. Belgelerin bulunabilirliği için statik bir site ya da PDF versiyon sağlanabilir;
örneğin MkDocs kullanarak HTML site oluşturmak ~5 saniye sürer. Belgelerde yer alan kod ve
komut bloklarının, geliştirme ortamının farklı konfigürasyonlarında da çalıştığını doğrulamak için
zaman zaman farklı işletim sistemlerinde deneme yapmak gerekebilir.
API Dokümantasyonu (Swagger/OpenAPI)
REST API dokümantasyonu için OpenAPI (Swagger) kullanmak, geliştiricilere etkileşimli ve standart
bir arayüz sunar. FastAPI gibi araçlar, kodu yorumlayarak otomatik OpenAPI şeması üretir ve yerleşik
Swagger UI sunar . Örneğin FastAPI’de aşağıdaki gibi bir uygulama yazmak http://localhost/
docs ’da otomatik bir dokümantasyon sayfası oluşturur:
from fastapi import FastAPI
from pydantic import BaseModel
app = FastAPI(
title="Örnek API",
version="1.0",
description="Bu API, Swagger UI ile dokümante edilmiştir."
)
class Item(BaseModel):
name: str
price: float
@app.post("/items/", response_model=dict)
async def create_item(item: Item):
return {"message": "Item alındı", "item": item}
Bu kodda FastAPI, item giriş/çıkış şemasını OpenAPI’ye otomatik ekler ve Swagger UI ile etkileşimli bir
kullanıcı arayüzü sağlar . GraphQL API’lerinde ise şemaya dayalı introspeksiyon kullanılır; GraphQL
sunucusu şemasını sorgulayarak (örneğin Apollo Server ile) geliştiriciler GraphQL Playground veya
•
•
•
•
13
13
5
GraphiQL üzerinden sorguları test edebilir. GraphQL introspeksiyon özellikleri, API şemasını öğrenmeyi
ve dokümantasyon araçlarını beslemeyi sağlar .
Mimari Öneriler: API’yi belgelemenin en kritik adımlarından biri tek bir kaynakta OpenAPI
spesifikasyonu tutmaktır . Mümkünse design-first yaklaşımı benimseyerek önce API tanımı
yapılır, sonra kodu yazarsınız . REST için /docs (Swagger UI) ve /redoc (ReDoc UI) gibi
otomatik URL’ler kullanılabilir. GraphQL tarafında tüm sorgu ve tip bilgisi şemaya dahil olduğu
için ek bir dokümantasyon oluşturmadan araçların şemadan okumasını sağlayın. Örneğin Apollo
Server’da playground: true ve introspection: true ayarları ile otomatik doküman
sunulur.
Araç ve Kütüphaneler: FastAPI (veya Flask + Flask-RESTX gibi) ile OpenAPI ve Swagger UI/Redoc
kullanın. FastAPI’nin sağladığı otomatik döküman mekanizmasını aktif hale getirmek yeterlidir
. Swagger UI harici popüler araçlardan SwaggerHub veya Redocly kullanılabilir. GraphQL için
Apollo Server, Hasura veya Supabase GraphQL modülleri ile kendinden dokümantasyonlu bir
yapı elde edebilirsiniz. API istemcileri için OpenAPI Generator, Prisma veya GraphQL code
generator gibi kod üreticileri entegre edilerek tip güvenli client kütüphaneleri oluşturulabilir.
Örneğin Frontend tarafı için openapi-generator ile TypeScript veya Dart client otomatik
üretilir.
Örnek Kod Şablonları: FastAPI örneği yukarıda verilmiştir. GraphQL tarafı için basit bir Apollo
Server örneği (Node.js) ekleyelim:
const { ApolloServer, gql } = require('apollo-server');
const typeDefs = gql`
 type Query {
 hello: String
 }
`;
const resolvers = { Query: { hello: () => 'Merhaba Dünya!' } };
const server = new ApolloServer({ typeDefs, resolvers });
server.listen().then(({ url }) => {
console.log(` Sunucu ${url} üzerinde çalışıyor`);
});
Bu kod, http://localhost:4000/graphql adresinde GraphQL Playground açar ve şemayı
introspection ile ortaya çıkarır. Geliştiriciler bu arayüzde sorgular denemek için interaktif olarak
kullanabilir.
Potansiyel Sorunlar ve Çözümler:
Senkronsuz Dokümantasyon: Kod ile dokümantasyon farklı kaynaklarda tutulmamalı . Örneğin
Swagger spesifikasyonunu ve kodu farklı yerlerde güncellemek yerine kodun üzerinden otomatik
üretim tercih edilmelidir.
Yenilenen API Sürümü: API değiştiğinde (ör. yeni endpoint, parametre güncellemesi) OpenAPI
tanımını ve dokümanı hemen güncelleyin. Bu nedenle CI’da openapi.json ’un çıktısının kodla
eşleşip eşleşmediği otomatik test edilebilir .
14
•
1
10
•
13
•
•
• 1
•
1
6
Erişim Kontrolleri: Hem belge hem kod tarafında kimlik doğrulama kurallarını açıkça belirtin.
Swagger tanımında güvenlik şemalarını (JWT vs) tanımlayın. GraphQL’de ise şema dokümanı
kapsamlı olduğundan, erişim kontrollerini kodda ve metin yorumlarında açıklayın.
Doğrulama Eksikliği: API response örnekleri ve hata durumları için açıklamalar ekleyin. Swagger
UI otomatik belgeleme sağlasa da geliştiricilere yardım edecek açıklayıcı description ,
examples ekleri yazın.
Performans, Bakım ve Test: OpenAPI belgesi genellikle JSON/YAML formatında hafif bir
dosyadır (örneğin 50 endpoint’li API için birkaç yüz KB). Otomatik Swagger UI sayfası tarayıcı
üzerinde hızlı yüklenir. Büyük şemalar için sayfa yükleme bir saniyeyi geçmemelidir. Sürekli
entegrasyonda, yeni endpoint eklenirken oluşan openapi.json değişiklikleri otomatik test
edilebilir. GraphQL şeması için de benzer CI testleri yazılabilir. Belgelerdeki kod örnekleri (ör. REST
endpoint çağrıları) otomatik testlerle kontrol edilebilir. Ayrıca API için load test hedefleri
koyabilirsiniz (örn. <200ms yanıt süresi) ve bunları izleyerek performans düşüşlerini engelleyin.
Örneğin kısa süreli cache (TTL) stratejileri belirleyerek aşırı yük altında bile API yanıt sürelerinin
kabul edilebilir kalmasını sağlayabilirsiniz.
Akış Şeması (API Dokümantasyonu):
(FastAPI Kod)
 ↓
Otomatik OpenAPI JSON Oluşturulur
 ↓
Swagger UI (/docs) veya ReDoc (/redoc) Sayfası
 ↓
Geliştirici İnteraktif API Kaynaklarını Keşfeder
Use-Case Senaryoları:
REST API Kullanımı: Mobil uygulama geliştiricisi yeni bir kullanıcı kaydı endpoint’i kullanmak
istiyor. Swagger UI’den /users POST metodunun gereken parametrelerini ve örnek gövdesini
görerek doğru isteği yapar. Böylece hatalı istek gönderme olasılığı azalır.
GraphQL Sorgusu Testi: Frontend ekibi grafik öğelerini doldurmak için bir GraphQL sorgusu
yazıyor. GraphQL Playground’da şemayı inceleyip users tipinin alanlarını görür ve canlı sorgu
deneyerek beklenen veriyi alır. Sonuçları referans dokümanına ekleyerek diğerlerine de örnek
paylaşır.
Performans ve Kapasite Tahminleri: Örneğin 100 endpoint’li bir OpenAPI belgesi ~500–700 KB
olur ve tipik olarak <200ms içinde tarayıcıya yüklenebilir. Swagger UI tek sayfa uygulama
olduğundan client-side’da çalışır; bu nedenle sunucu yanıt süresi minimaldir. GraphQL API’da çok
büyük şema varsa introspection sorgusu gecikebilir; bu durumda gereksiz alanları gözden
geçirip şemayı modularize edin. İleride API büyüdükçe Swagger arayüzünde gezinme zorluğu
olabilir; bu durumda arama ve kategori destekli bir API portalı (SwaggerHub, Redocly)
kullanmayı planlayabilirsiniz.
•
•
•
•
•
•
•
•
7
Mimari Karar Kayıtları (ADR)
Mimari Karar Kayıtları (Architecture Decision Records) projenin önemli mimari tercihlerini
belgelemek için kullanılır . Her ADR; alınan kararın ne olduğu, neden alındığı, düşünülen
alternatifler ve sonuçları içerir . Bu sayede yeni katılan bir geliştirici veya ekip üyesi projenin
geçmiş mimari seçimlerini kolayca görebilir (bu da onboarding sürecine katkı sağlar) . Önerilen
uygulamalar ve örnekler şu şekildedir:
Mimari Öneriler: ADR’leri proje deposunda adr/ veya docs/adr/ gibi bir klasörde
Markdown dosyası olarak saklayın . Her ADR’e tarih ve sıra numarası vererek
( ADR-001-... ), anlaşılır kısa bir başlık ekleyin. Karar durumunu (Önerildi, Kabul Edildi,
Reddedildi, Kullanımdan Kaldırıldı vb.) belirtin. Örneğin:
# ADR-001: API Belgeleme Aracı Seçimi
## Durum
Kabul Edildi
## Bağlam
Projemizde kullanıcıların API’yi nasıl kullanacağını anlaması için bir
dokümantasyon aracı gerekli...
## Karar
Swagger UI (OpenAPI) kullanmaya karar verdik çünkü:
- Otomatik interaktif doküman üretiyor.
- FastAPI ile entegre, ek konfigürasyon gerektirmiyor.
## Düşünülen Alternatifler
- ReDoc: Modern tema ama ek çaba gerektiriyor.
- Statik Markdown: Zaman alıcı, ek araç gerektirecek.
## Sonuçlar
- FastAPI bağımlılığı olarak `fastapi[all]` eklenmeli.
- Geliştiriciler `/docs` adresinden dokümantasyona erişecek.
Yukarıdaki örnekte bir kararın formatı gösterilmektedir (bkz. [1]’de benzer örnek) .
Araç ve Süreçler: GitHub/GitLab depo içindeki Markdown ADR’leri en uygunu . adr-tools
gibi yardımcı komut satırı araçları veya GitHub şablonları kullanabilirsiniz. ADR’leri Confluence
yerine depo içinde tutmak, sürüm kontrolü ve CI entegrasyonu sağlar . Örneğin ADR
dosyaları MkDocs ile dokümantasyon sitenize de entegre edilebilir . Karar alınan konular için
takımlar arası tartışma yapıp, son kararı bu kayıtlarda topluca tutun. Kararın dayandığı ticket
veya PR’leri ADR içinde referans vererek izlenebilirlik sağlayın.
Potansiyel Sorunlar ve Çözümler:
ADR yığılması: Sürekli her küçük değişikliği kaydetmek yorucu olabilir . Bunun yerine önemli
mimari değişiklikleri (yeni bir teknoloji seçimi, büyük yapılandırma değişikliği vb.) belgeleyin.
Diğer küçük değişiklikler için ADR değil, kısa notlar veya commit mesajı yeterli olabilir.
15 16
15 17
16
•
9 18
19 20
• 9
18 5
5
•
• 21
8
Güncelleme Zorluğu: Bir kararın sonradan değişmesi durumunda ADR’nin Durum kısmını
(örneğin “Geçersiz kılındı”) güncelleyin. Unutulan veya eski ADR dosyaları için periyodik gözden
geçirme yapın.
Başlık Karmaşıklığı: ADR sayısı arttıkça ihtiyaç duyulan bir arama/dizinleme mekanizması önem
kazanır. Net ve kısa başlıklar kullanın. Örneğin “Veritabanı Seçimi” yerine “ADR-002: PostgreSQL
vs MongoDB Kararı” şeklinde detaylandırın.
Ortaklaşa Karar: Tüm ekibin katılımını sağlayın; ADR tek kişinin tekelinde olmamalıdır. Kod
inceleme sürecinde ilgili ADR’e link verilerek ekibe hatırlatılabilir.
Bakım ve Test: ADR’leri de kod gibi inceleme ve onay sürecine dahil edin. adr/ klasöründeki
dosyalar için PR açarken ilgili takımı etiketleyin. Belgelerle benzer şekilde, ADR Markdown
dosyalarının bütünlüğünü sağlamak için CI araçları (Markdown lint, link kontrolü) ekleyebilirsiniz.
ADR’ler çok fazla değildir, ancak çok sayıda ise web sayfası haline getirip arama sunmak yararlıdır.
Örneğin MkDocs ile ADR’lerden statik bir sözlük oluşturulabilir. Karar kayıtlarını düzenli tutmak,
karar geçmişine erişimi kolaylaştırır ve projede sürdürülmesi gereken teknik borç kararlarını
gelecekte engeller.
Akış Şeması (Karar Süreci):
Karar Gerekçesi → ADR Taslağı Oluşturma → Ekip Değerlendirmesi
(Tartışma)
 ↓ ↑
(Alternatifleri Belirtme) (Gözden Geçirme ve Onay)
 ↓ ↓
Karar Verildi → ADR Dosyasını Git’e Ekle → Uygulamaya Geçirme
Use-Case Senaryoları:
Teknoloji Seçimi: Diyelim proje e-posta servisi olarak hangi üçüncü tarafı kullanacağına karar
veriyor. ADR-010: “E-posta Servisi Sağlayıcısı Seçimi” olarak açılır, SendGrid, Mailgun gibi
seçenekler değerlendirilir ve gerekçeleriyle birlikte sonuçlandırılır. Böylece ileride “Neden
Mailgun kullanıyoruz?” sorusuna yanıt bulunur.
Mimari Dönüşüm: Monorepo’dan mikroservis mimarisine geçiş düşünülüyorsa, bu büyük çaplı
değişim ADR ile belgelendirilir. ADR’de hem geçiş gerekçesi (ölçeklenebilirlik vb.) hem de
alternatif (“Şimdilik tek depo yeterli” gibi) ele alınır. Karar alındıktan sonra ilgili projeler yeniden
yapılandırılır.
Performans ve Kapasite Tahminleri: ADR’ler küçük metin dosyalarıdır; performans yükü yoktur.
Ancak sayısı arttıkça erişim kolaylığı için indekslemeye ihtiyaç duyulabilir (örn. MkDocs arama).
Küçük projelerde ADR sayısı 5–10 civarında kalırken, büyük projelerde onlarcasına çıkabilir. Her
bir ADR dosyası sadece birkaç yüz kelimedir; toplamda birkaç MB’lık markdown dokümanı bile
çok hızlı açılır. Önemli olan karar sayısını makul tutmak ve gereksiz tekrarları önlemektir . ADR
yönetimi ek yük getirse de faydaları (şeffaflık, yeni gelenlere hızlandırıcı, tartışmaların yeniden
edilmemesi) bu yönetimi haklı çıkarır .
Kaynakça: Dokümantasyon ve onboarding ile ilgili en iyi uygulamalar, resmi dokümantasyon (FastAPI,
OpenAPI, MkDocs) ve deneyim raporları üzerine yazılmış makaleler ışığında önerilmiştir .
•
•
•
•
•
•
•
•
•
21
22 21
11 23 16 1
9
Best Practices | OpenAPI Documentation
https://learn.openapis.org/best-practices.html
MkDocs
https://www.mkdocs.org/
The Essential Guide to Effective Technical Documentation
https://paligo.net/blog/how-to/the-essential-guide-to-effective-technical-documentation/
Architecture Decision Record: How And Why Use ADRs? - Scrum-Master·Org
https://scrum-master.org/en/architecture-decision-record-how-and-why-use-adrs/
Technical Documentation and Developer Onboarding | by Jonathan Holloway | Medium
https://jonathan-holloway.medium.com/technical-documentation-and-developer-onboarding-79e6ea45563b
Working with a Monorepo - ISE Developer Blog
https://devblogs.microsoft.com/ise/working-with-a-monorepo/
Generate Clients - FastAPI
https://fastapi.tiangolo.com/advanced/generate-clients/
Introspection | GraphQL
https://graphql.org/learn/introspection/
Architecture Decision Records (ADR): Documenting Your Project’s Decisions - DEV
Community
https://dev.to/wallacefreitas/architecture-decision-records-adr-documenting-your-projects-decisions-5ac8
Step-by-Step Guide to Writing Better Documentation to Improve Developer Onboarding | by
Richardson Dackam | Medium
https://richardsondx.medium.com/step-by-step-guide-to-writing-better-documentation-to-improve-developeronboarding-376a4a9181d
1 4 10
2
3
5 9 18 21 22
6 11 12
7 8
13
14
15 16 17 19 20
23
10
CI/CD Süreci
Bu bölümlerde Flutter frontend ve FastAPI backend için Codemagic kullanarak çok aşamalı (build/test/
deploy) bir CI/CD pipeline tasarımı ele alacağız. Örneğin bir PR açıldığında veya main dalına commit
yapıldığında otomatik derleme, test ve deploy adımları çalıştırılacak. Ayrıca Docker tabanlı FastAPI
dağıtımı ile Flutter uygulamasının bu servisi kullanması nasıl organize edilir, adım adım inceleyeceğiz.
Codemagic ile Çoklu Build/Test Pipeline
Mimari önerisi: Flutter uygulaması ve FastAPI servisi ayrı iş akışları (workflow) olarak ele
alınabilir. Örneğin flutter-ci (macOS) ve backend-ci (Linux) adında iki farklı workflow
oluşturulur. Bu sayede iOS/Android derleme işlemleri macOS sanal makinede, Python testleri ve
Docker imajı yapımı Linux makinede paralel veya bağımsız yürütülebilir. Monorepo
kullanıyorsanız “path filter” ile hangi değişiklikte hangi pipeline’ın tetikleneceğini kısıtlayın (ör.
frontend veya backend dosyaları değiştiğinde sadece ilgili workflow çalışsın). Tekil repoda
çalışıyorsanız, Flutter projesini apps/flutter_app/ , backend’i backend/ gibi dizinlere
koyarak when: changeset koşulları tanımlayabilirsiniz . Örneğin:
workflows:
flutter-ci:
name: Flutter CI
triggering:
events: [pull_request, push]
branch_patterns: ['main']
environment:
flutter: stable
xcode: latest
when:
changeset:
includes: ['apps/flutter_app/**']
scripts:
- name: Install Flutter deps
script: flutter pub get
- name: Run Flutter tests
script: flutter test --coverage
backend-ci:
name: Backend CI
triggering:
events: [push]
branch_patterns: ['main']
environment:
# Linux ortamında Python kuruludur
flutter: none
when:
changeset:
includes: ['backend/**']
•
1
1
scripts:
- name: Install Python deps
script: pip install -r backend/requirements.txt
- name: Run Backend tests
script: pytest backend/tests
Bu örnekte flutter-ci workflow’u sadece Flutter kod değiştiğinde, backend-ci ise sadece
backend değiştiğinde koşacaktır. Gerekirse her workflow içinde Flutter’ın Melos veya FVM gibi araçlarla
sürüm yönetimi de yapılabilir. (Tekil repo yerine ayrı repolar tercih edilirse her bir proje kendi
codemagic.yaml dosyasına sahip olabilir.)
Araçlar/Kütüphaneler: Codemagic CI, Flutter SDK, Xcode (iOS için), Python 3 (FastAPI için), pip/
pytest, Docker CLI, AWS CLI (veya hedef servis CLI’ları). Ortam değişkenleri (ör. API anahtarı,
Xcode signing) Codemagic Secrets/Environment Groups olarak yönetilir. Cachleme için Flutter’da
~/.pub-cache gibi yollar ayarlanabilir . Testler için Codecov veya SonarCloud
entegrasyonu kullanılabilir.
Örnek codemagic.yaml : Yukarıdaki yapıdaki gibi, her workflow için instance_type ,
tetikleyici, environment ve scripts bölümleri tanımlanır. Örneğin:
workflows:
flutter-workflow:
name: Flutter CI (PR ve Main)
instance_type: mac_mini_m2
environment:
flutter: stable
triggering:
events: [push, pull_request]
branch_patterns: ['main']
scripts:
- name: Get packages
script: flutter pub get
- name: Run tests
script: flutter test --coverage
backend-workflow:
name: FastAPI CI/Deploy
instance_type: ubuntu_linux
environment:
# Python için özel bir config yok
vars:
AWS_ACCESS_KEY_ID: $AWS_KEY
AWS_SECRET_ACCESS_KEY: $AWS_SECRET
triggering:
events: [push]
branch_patterns: ['main']
scripts:
- name: Install deps
script: pip install -r backend/requirements.txt
- name: Run tests
script: pytest backend/tests
•
2
•
2
- name: Build Docker image
script: |
cd backend
docker build -t myapp:latest .
- name: Push to Registry
script: |
aws ecr get-login-password --region $AWS_REGION | docker login --
username AWS --password-stdin $ECR_URL
docker tag myapp:latest $ECR_URL/myapp:$CM_BUILD_ID
docker push $ECR_URL/myapp:$CM_BUILD_ID
Bu yapı ile kod değiştikçe ilgili script’ler otomatik çalışır.
Olası Sorunlar & Çözümleri:
Ortam Farklılıkları: iOS derlemesi için macOS, backend için Linux makine kullanılması gerekir.
Örneğin Flutter’ın iOS kurulumu için instance_type: mac_mini seçin.
Cachleme/Kütüphane Yönetimi: Kütüphane yükleme süreleri uzun olabilir. Pub paketleri için cache
yolu tanımlayın . Python’da da pip install önbelleğini kullanın.
Paralel Build Maliyetleri: Ücretsiz planda sadece bir eşzamanlı derleme vardır. Çoklu PR’da kuyruk
oluşabilir. Gerektiğinde ek concurrency satın alın veya gerekli iş yüklerini ayırın.
Gizli Bilgiler: Kod kaynağında hiçbir zaman doğrudan anahtar/şifre gibi özel veri bulundurmayın.
Codemagic Secret Manager kullanılmalı.
Yol Koşulları: Monorepo’da değişmeyen alt projeler için CI’yi pas geçin (örneğin sadece doküman
değiştiğinde). Yukarıda gösterilen when: changeset bölümü bu amaçla kullanılabilir .
Performans ve Bakım Kolaylığı: Pipeline’ları küçük parçalara ayırın (ör. flutter-test ,
flutter-build gibi). Mümkünse testler paralel çalışsın. Gereksiz ağır script’ler kod farkı
yokken atlanmalı. Build sürelerini kısaltmak için Flutter’da FVM kullanabilir, belirli sürüm
cache’lerini tutabilirsiniz. Her workflow’da kod kalitesi analizleri (lint, codemetrics) eklemek test
edilebilirliği artırır. Yaygın hatalar için Slack ya da e-posta entegrasyonu ile bildirim alınması
tavsiye edilir.
Akış Diyagramı (Metinsel): Örnek akış: "Geliştirici main branşına kod gönderdiğinde,
Codemagic tetiklenir. Önce flutter-ci workflow’u çalışır (Flutter paketlerini indirir ve testleri
koşar). Ardından backend-ci workflow’u çalışır (FastAPI birim testleri ve docker imajını
hazırlar). CI adımları başarıyla geçerse, release kanalı için deploy iş akışı devreye girebilir (örn.
Docker imajı ECR’e gönderilir, Flutter build Store’a yüklenir).*
Use-Case Senaryoları:
Özellik Geliştirme PR’ı: Yeni bir özellik için PR açıldığında sadece ilgili testler çalıştırılır. Örneğin
tasarım katmanı değişmişse flutter test , API katmanında değişiklik varsa pytest
tetiklenir.
Ana Dal Güncellemesi: main dalına kod merge edilince tam CI çalışır; tüm testler geçerse
staging ortamına deploy yapılabilir. Örneğin yeni bir sürüm çıkışı öncesi otomatik sürüm artışı ve
artefakt upload tetiklenir.
•
•
•
2
•
•
•
1
•
•
•
•
•
3
Hotfix Süreci: Acil bir düzeltme için hotfix branşı açıldığında, genellikle hızlıca CI koşulur
(testler vs.), başarılıysa aynı branch’ten üretime small deployment yapılabilir.
Bağımsız Backend İyileştirme: Sadece backend kodu değiştiğinde, Flutter derlemesi atlanır;
bunun yerine backend-ci hızlıca Docker imajı oluşturur ve test eder.
Performans ve Kapasite Tahminleri:
Build Süreleri: Tipik Flutter derlemesi (Android APK) ~5-10 dk, iOS derleme ~10-15 dk sürebilir.
Python testleri genelde <1-2 dk’dır. Docker imajı oluşturma ~2-3 dk alır.
Pipeline Süresi: Tek bir PR pipeline’ı ~10-20 dk içinde tamamlanmalı. Gereğinden uzun sürüyorsa
cache ve paralelleştirmeyi gözden geçirin.
Donanım Kaynakları: Codemagic’ın Linux makinesi 8 CPU/32GB bellek, Mac mini M2 ise 8
çekirdek/8GB RAM’tir . Özellikle macOS için bellek sınırlamasına dikkat edin (büyük projelerde
OOM riski).
Eşzamanlılık: Ücretsiz planda yalnızca 1 build eşzamanlıdır (500 dk ücretsiz ayda). Birden fazla
PR’da beklemeyi önlemek için gerektiğinde paralel concurrency satın alın.
Cache Bekleme Süreleri: Pub-cache ~200MB, Python pip cache birkaç yüz MB olabilir; bunlar yerel
diskte (156GB) tutulur .
Docker ile Backend Dağıtımı
Mimari önerisi: FastAPI servisini Docker konteyneri olarak paketleyin. Böylece AWS ECS/Fargate,
Kubernetes veya Fly.io/Railway gibi altyapılara kolayca taşıyabilirsiniz. Örneğin AWS’de ECR’e imaj
gönderip ECS Fargate ile ölçeklendirebilirsiniz. Veya Fly.io kullanarak Dockerfile üzerinden hızlı
deploy yapabilirsiniz. Flutter uygulaması bu backend’e REST çağrıları yapacağından, Flutter’ın
yapılandırmasında API URL’sini (örn. .env veya kod içi konfigürasyon) ortam değişkeni olarak
yönetmelisiniz.
Araçlar/Kütüphaneler: Docker (veya Podman), FastAPI, Uvicorn/Gunicorn gibi WSGI/ASGI
sunucusu, AWS CLI/Terraform (ECS için), Railway CLI veya Fly.io CLI gibi dağıtım araçları. CI
aşamasında Docker Hub, AWS ECR veya benzeri bir container registry kullanılır. Ayrıca Sentry,
New Relic gibi monitoring eklentileri konteyner içine eklenebilir.
Örnek Dockerfile: FastAPI resmi dokümanlarından basit bir örnek alınabilir :
FROM python:3.9
WORKDIR /app
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt
COPY ./app /app/app
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]
Bu Dockerfile’da önce Python imajı kullanılır, bağımlılıklar yüklenir ve uygulama /app içine
kopyalanarak uvicorn ile çalıştırılır . Gerçek projede Gunicorn veya uvicorn çok iş
parçacıklı gibi daha gelişmiş bir server konfigürasyonu tercih edilebilir.
Dağıtım: Oluşturulan imaj CI’dan sonra örneğin AWS ECR’e push edilir. Ardından AWS ECS
Fargate servis güncellenir (AWS CLI ile update-service veya Terraform/CDK ile). Railway veya
•
•
•
•
•
•
3
•
•
4
•
•
• 5
5
•
4
Fly.io kullanılıyorsa, bu platformların otomatik Docker deploy özellikleri veya CLI script’leri
tetiklenir. Örneğin Codemagic’da:
- name: Build and Push Backend Image
script: |
cd backend
docker build -t myapp:latest .
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS
--password-stdin $ECR_URL
docker tag myapp:latest $ECR_URL/myapp:$CM_BUILD_ID
docker push $ECR_URL/myapp:$CM_BUILD_ID
- name: Deploy to AWS ECS
script: |
aws ecs update-service --cluster my-cluster --service my-service --forcenew-deployment
Bu akışta önce imaj hazırlanır ve ECR’ye yollanır, ardından ECS servisi yeni imajı kullanacak şekilde
güncellenir.
Olası Sorunlar & Çözümleri:
Environment Değişkenleri: Veritabanı bağlantı zincirleri, API anahtarları vs. Docker’a inject edilmeli
(örn. AWS Secrets Manager, .env ). Kodda sert halde bırakmayın.
Yaşayan Veriler: Docker konteyner imajları statik olduğundan, veritabanı ve yük durumunu
korumak için gerekli ayarları yapın. Supabase kullanıyorsanız veritabanı bağımsızdır.
Cold Start Süreleri: Fargate gibi sunucusuz konteyner altyapıları ilk açılışta ısınma gecikmesi
yaşayabilir. Kritik rotalar için FastAPI’da ufak bir yan uygulama çalıştırarak “heartbeat” atan
uygulama tutabilirsiniz.
Ağ ve Güvenlik: Uygulama Amazon VPC içinde ise Flutter tarafında doğru güvenlik grupları
ayarlanmalı. API gateway veya load balancer kullanıyorsanız TLS sertifikası, WAF gibi ek güvenlik
önlemleri alınmalıdır.
Docker Hataları: Güncellenmiş Python sürümüyle kütüphaneler uyumsuz olabilir.
requirements.txt içindeki versiyon kısıtlarını sabitleyin. Büyük imaj boyutları için çok
aşamalı (multi-stage) Dockerfile veya --no-cache bayrağı ekleyin.
Performans ve Bakım Kolaylığı:
İmaj boyutunu küçük tutmak için python:3.9-slim gibi daha hafif baz imajlar tercih edilebilir.
Ayrıca FastAPI uygulamasında asenkron işlemler (async/await) ve Uvicorn işçi sayısı
( --workers ) ayarlanarak istek başına düşük gecikme hedeflenir.
Mikro hizmet ölçeklendirirken, AWS ECS’de min/max görev sayısı ayarlanmalı (örn. sürücü artış
anlarında dinamik olarak 2→10 kapsayıcı gibi).
Loglama için STDOUT a yazıp Codemagic veya CloudWatch üzerinden toplayın. Sentry entegre
edildiyse hataların detaylı takibi yapılabilir.
Güncelleme işlemlerinde sıfır kesinti (rolling update) stratejisi kullanın: yeni görev dağıtılırken
eski görev yavaşça devre dışı bırakılır. AWS’de bu ayar default olarak etkindir.
Hızlı hata yakalama için entegre testler (Smoke test) ekleyin: CI’da imaj deploy edildikten sonra
bir küçük HTTP isteği atılarak “uygulama cevap veriyor mu” kontrolü yapılabilir.
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
5
Use-Case Senaryoları:
Kod Güncellemesi → Yeni API Sürümü: Geliştirici /users API’sinde bir endpoint ekleyip
main’e push yaptığında, Codemagic backend-ci workflow’u tetiklenir. Image oluşturulur, ECR’e
gönderilir ve ECS güncellenir. Yeni Flutter sürümü bu API’yi kullanmak üzere güncellenir.
Performans Artışı: Yük testi esnasında bir endpoint çok yavaş kalıyorsa, Dockerfile’a uvicorn
--workers 4 gibi parametre eklenerek çoklu worker kullanımı denenir. Güncelleme yine CI’da
imaj güncellemesi ve yeniden deploy ile yapılır.
Platform Değişimi: Gerektiğinde AWS yerine Fly.io’a geçiş kararı alınırsa, aynı Dockerfile’ı
kullanarak Codemagic’dan Fly.io CLI ile deploy edilebilir. Böylece altyapı değişse bile CI akışı
büyük ölçüde korunur.
Performans ve Kapasite Tahminleri:
Docker İmaj Boyutu: Temel Python imajları ~100MB iken uygulama ve kütüphanelerle imaj
200-300MB’a çıkabilir. Bu boyutu göz önünde bulundurarak imaj gönderme süresi ~30 sn–1 dk
sürer (internet hızına göre).
İstek Yönetimi: Örneğin Fargate ile 1 vCPU/2GB bellek kullanılıyorsa, sınırlı eşzamanlı istek (~50
RPS) kaldırabilir. Yoğunluk için 2x2GB instans önerilebilir.
Hız Hedefleri: Kritik uç noktalar için API yanıt süresi <200ms hedeflenebilir. Codemagic pipeline’ın
tamamlanma süresi ise (backend test+build) genelde ~5 dakika civarındadır.
Hata Toleransı: Minimum 2 replikasyon (task) ile yüksek kullanılabilirlik sağlanmalıdır. Eğer 1M’dan
fazla satır içeren veriler varsa, veritabanında shard veya partition uygulanmalıdır (Supabase
PostgreSQL kullanıyorsanız büyük tablolar için pg_partman vb.).
Build → Test → Deploy Süreçleri
Mimari önerisi: Kodun her aşamasının (derleme, test, dağıtım) birbirini takip ettiği tutarlı bir
zincir kurun. Codemagic’da genellikle tek bir workflow içinde sıralı scripts adımları kullanılır:
önce build ( flutter build , pytest ), sonra test ( flutter test , pytest ), en sonunda
deploy adımları (apka yükleme, Docker push, servis güncelleme). Alternatif olarak bağımsız iş
akışları (ör. “CI” ve “CD” ayrımı) da kurulabilir: PR’larda sadece CI çalışır, main daki her commit
otomatik deploy’ı tetikler.
Araçlar/Kütüphaneler: Flutter (CLI), pytest, Docker CLI, Fastlane veya codemagic CLI (mobil
dağıtımlar için), AWS CLI/Azure CLI/GCloud (sunucu dağıtım için), Firebase CLI (beta dağıtımlar
için), ve sürüm yönetimi için otomatik git tag oluşturan paketler. Semantik versiyonlama
( x.y.z ) araçları (ör. git-chglog , lerna ) kullanılabilir. Artefakt saklama için AWS S3 veya
Codemagic Artefact kullanın.
Örnek Pipeline Adımları: Codemagic YAML içindeki script dizisi şöyle olabilir:
workflows:
ci-and-deploy:
name: Flutter ve Backend CI/CD
triggering:
events: [push]
branch_patterns: ['main']
environment:
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
6
flutter: stable
scripts:
# Flutter Build
- name: Flutter Pub Get
script: flutter pub get
- name: Flutter Build APK
script: flutter build apk --release
# Flutter Test
- name: Flutter Tests
script: flutter test
# Backend Build ve Test
- name: Backend Pip Install
script: pip install -r backend/requirements.txt
- name: Backend Tests
script: pytest backend/tests
# Artefaktları Push / Deploy
- name: Upload APK to S3
script: |
aws s3 cp build/app/outputs/flutter-apk/app-release.apk s3://
mybucket/myapp.apk
- name: Build & Push Docker
script: |
docker build -t myapp:latest backend
aws ecr get-login-password | docker login --username AWS --
password-stdin $ECR_URL
docker tag myapp:latest $ECR_URL/myapp:$CM_BUILD_ID
docker push $ECR_URL/myapp:$CM_BUILD_ID
- name: Deploy Backend
script: aws ecs update-service --cluster mycluster --service
myservice --force-new-deployment
Bu zincirde öncelikle Flutter APK derlenip test edilip S3’e yükleniyor, sonra backend derlenip Docker
Hub/ECR’e yollanıyor ve ECS servisi yenileniyor. Adımlar birbiri ardına çalışır; birinde hata olursa sonraki
aşama tetiklenmez.
Olası Sorunlar & Çözümler:
Hatalı Halde Devam Etmemek: Bir adım başarısız olursa pipeline’ı iptal edin. Örneğin pytest
başarısızsa deploy aşamasını atlayın. Codemagic script’lerinde set -e ile hata kodu
yakalanmalı.
Aşırı Uzun Aşamalar: Tüm adımları tek workflow’a almak uzun sürebilir. Büyük projelerde
cached_reuse veya parallel workflow kullanın. Örneğin flutter build ayrı, Docker
aşamaları ayrı workflow’lar olabilir.
Senkronizasyon: Flutter build sonucu ortaya çıkan versiyon numarası ile backend versiyonu
eşleşmeli. Artefakt isimlendirmeyi standartlaştırın ( $CM_BUILD_ID ya da git tag).
Zincirleme Gecikmeler: Her adımın sürelerini gözleyin; eğer build çok uzunsa önce test adımlarını
ayırın ve sadece test geçince build’e geçin (örneğin Codemagic prmergebuild özelliği).
Güvenlik: Deploy aşamasında kimlik bilgilerini kimseyle paylaşmayın. AWS IAM rolleri veya GitHub
Actions ise OIDC token kullanın.
Performans ve Bakım Kolaylığı:
•
•
•
•
•
•
•
7
Artifacts (örn. APK, Docker imajı) bir sonraki aşamaya devredilebilir veya harici storage’a
konulabilir. Codemagic içinde artifact upload yapıp download ederek zinciri kısaltabilirsiniz.
Paralel yürütme: Flutter’ın birleştirilmiş APK/AAB üretimini diğer script’lerle aynı anda değil, sıralı
yapın. Ancak Python testlerini Flutter testleri biter bitmez başlatabilirsiniz (aynı workflow’da &
ile arkaplana alma veya ayrı workflow).
Kısa feedback süresi: Testleri optimize edin, ağır entegrasyon testleri ayrı pipeline’da koşturun.
Kod kapsama ölçümlerini CI’a ekleyin.
Kolay bakım için: Kod imza ve dağıtımı (App Store, Play Store) adımlarını fastlane gibi
araçlarla otomatikleştirin. Codemagic, Fastlane’i entegre şekilde destekler.
Pipeline şablonu kullanın: codemagic.yaml içinde anchor/alias özelliklerini kullanarak sık
tekrarlanan bölümleri tek noktada tutabilirsiniz .
Akış Diyagramı (Metinsel): Örnek bir zincir: "Geliştirici kodu dev branşına gönderdi. Codemagic,
dev için tanımlı CI workflow’unu tetikledi. Adım 1: Flutter paketleri indirildi, tüm testler çalıştırıldı.
Adım 2: Backend için Python bağımlılıkları yüklendi, pytest testleri koşuldu. Her şey doğru çalışırsa
Adım 3: Flutter APK derlenip S3’e yüklendi; Adım 4: Docker imajı oluşturulup ECR’e gönderildi ve ECS
servisi güncellendi. Böylece üretim ortamı otomatik güncellenmiş oldu."
Use-Case Senaryoları:
PR İçin CI: Bir geliştirici PR açınca sadece testler koşulur (kod deploy edilmez). Bu sayede hatalar
erkenden yakalanır. PR onaylandığında merge yapılır.
Özellik Dalından Yayına: Yeni bir özellik feature/x dalında tamamlanınca önce kod review
sonrası merge . main güncellendiğinde otomatik olarak testler ve derleme yapılır. Sonra belki
öncelikle staging ortamına deploy edilir (manuel onaylı), onay gelince prod’a geçilir.
Haftalık Release: Her hafta release/* dalından bir tag atılır ( v1.2.3 ). Bu olay pipeline’da
sürüm artışı ve app store’a yükleme adımlarını tetikleyebilir.
Entegrasyon Testleri: Frontend ile backend etkileşimi kritikse, pipeline’ın sonunda küçük bir
entegrasyon testi koşun: Flutter test ortamında mocked API’den ziyade gerçek ECS’deki servise
istek yaparak uçtan uca bir kullanıcı hikayesini test edin.
Performans ve Kapasite Tahminleri:
Pipeline Süresi: Tüm aşamaların (derleme, test, deploy) bitmesi ~10–15 dk arasında olmalıdır.
Günlük 10–20 build üst limiti düşünüldüğünde aylık build süresi hedefi ~300–600 dk yapılabilir.
(Codemagic’ın ücretsizde 500dk limiti var .)
Cache TTL: Build cache’leri (örn. pub ve pip) her 12 saatte bir yenilenebilir. Sıklıkla değişmeyen
bağımlılıklar için uzun tutulabilir.
Parallelism: Eğer ek kullanıcıya ulaşırsanız 2–3 eşzamanlı derlemeye çıkacak ek concurrency seçin.
Hata Durumu: Pipeline başarısızlığı hedefi sıfıra yakın tutun. Testsiz (sadece build) geçişler
tamamlanma oranı %95, test geçme oranı ise %85+ olmalıdır.
Sistem Kaynakları: AWS ECS Fargate’da her görevin ortalama 0.25–0.5vCPU kullandığını
varsayarsak, 100 eşzamanlı görev için 50vCPU’luk kapasite gerekir. Build makineler de benzer
şekilde, Flutter build için 8 CPU/8GB (mac), backend Docker için 4 CPU/8GB (Linux) yeterlidir.
Kaynaklar: Codemagic’ın YAML dökümantasyonunda çoklu workflow desteği ve cache kullanımı
örnekleniyor . FastAPI dökümanında ise Dockerfile örneği yer alıyor . Codemagic
ücretlendirme ve makine özellikleri sayfasında ise Linux/Mac VM’lerin CPU/RAM bilgileri veriliyor
. Bu rehberdeki yapılandırma önerileri bu güncel bilgilere dayanarak hazırlanmıştır.
•
•
•
•
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
•
•
•
•
8 2 5
3
9
8
How to manage your Flutter monorepos | Codemagic Blog
https://blog.codemagic.io/flutter-monorepos/
Using codemagic.yaml - Codemagic Docs
https://docs.codemagic.io/yaml-basic-configuration/yaml-getting-started/
Pricing - Codemagic Docs
https://docs.codemagic.io/billing/pricing/
Ubuntu 20.04 (default) - Codemagic Docs
https://docs.codemagic.io/specs-linux/ubuntu-20.04/
FastAPI in Containers - Docker - FastAPI
https://fastapi.tiangolo.com/deployment/docker/
Flutter apps - Codemagic Docs
https://docs.codemagic.io/yaml-quick-start/building-a-flutter-app/
1
2 6
3 7
4 9
5
8
9
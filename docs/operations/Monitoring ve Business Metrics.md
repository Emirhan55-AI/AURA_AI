Monitoring ve Business Metrics
Monitoring ve iş-metrikleri katmanlı olarak planlanmalı. Örneğin uygulama içinde önemli kullanıcı
etkileşimleri (beğeni, paylaşım vb.) Firebase Analytics gibi bir analitik motoruna, sistem performans
metrikleri ise Sentry/Prometheus gibi izleme çözümlerine gönderilebilir. Supabase Projesi,
Prometheus–uyumlu metrik uç noktası ile temel altyapı sağladığı için bu metrikleri Grafana/
Prometheus ile toplayabilir . Ayrıca, BI araçları (örneğin Metabase, Looker Studio) doğrudan
Supabase’in Postgres’ine ya da BigQuery’le entegre edilerek üst düzey iş raporlarına dönüştürülebilir
. Her metrik akışı, aşağıdaki gibi katmanlı bir yol izleyebilir:
Örnek akış: “Kullanıcı bir içeriği beğendiğinde” – UI → Uygulama (UseCase) → Domain → API
(GraphQL) → FastAPI/Supabase – burada olay hem veritabanına yazılır hem de analiz için
loglanır.
Örnek akış: “Uygulama açılış süresi ölçümü” – UI (başlangıç) → Performance SDK (Firebase/
Sentry) otomatik olarak app-start verisi toplar.
Her metrik katmanında monitörleme ajanları entegre edilmeli (örn. firebase_performance ,
sentry_flutter , Prometheus client). Elde edilen veriler hem geliştirici konsollarında (Firebase
Console, Sentry, Grafana) hem de iş zekası panellerinde (Metabase, Looker, Superset vs.)
görselleştirilebilir. Aşağıda her başlık için detaylı öneriler ve akışlar bulunmaktadır.
1. Custom Metric Tanımlama
Mimari: Uygulama kodunda önemli olaylar (örneğin bir ürünü beğenme, sipariş tamamlama)
tetiklendiğinde FirebaseAnalytics veya Sentry gibi kütüphaneleri kullanarak bu olayları
loglayın. Backend katmanında da (FastAPI) önemli iş mantığı olaylarını izleyip kaydeden servisler
oluşturun. Örneğin FastAPI’de bir @app.post("/like") endpoint’i içinde beğeni sayısını
güncellerken aynı anda bir log servisine “like” olayı gönderebilirsiniz.
Araç/Kütüphane: Flutter için firebase_analytics (önerilen) veya Google Analytics, Sentry
SDK (olay takibi için). Backend’de ise log to playload (örn. Loki, ELK) veya Kafka aracılığıyla metrik
kanalı. Supabase projesinde ayrıca Logflare üzerinden log sorgulama imkânı var .
Örnek Kod:
// Flutter: ürün beğenildiğinde Firebase Analytics ile event gönderme
await FirebaseAnalytics.instance.logEvent(
name: "product_like",
parameters: {"product_id": id, "user_id": userId},
);
// FastAPI: beğeni endpoint'i
@app.post("/like")
async def like_product(payload: LikePayload):
like_count = update_like_in_db(payload.product_id)
# Log iş-metrik olayı (ör. Kafka, log dosyası, analitik API)
send_event("product_liked", {"product_id": payload.product_id,
1
2 3
•
•
•
•
4
•
1
"user_id": payload.user_id})
return {"likes": like_count}
Potansiyel Sorunlar & Çözümler: Çok sayıda event gönderimi performansı etkileyebilir. Bunu
önlemek için örnekleme (sampling) veya batching uygulanabilir. Metrik loglarının network
gecikmesine takılmaması için asenkron kuyruğa yazın (örn. Kafka, RabbitMQ, Redis Queue). Aşırı
event yükü durumunda sunucu tarafında kuyruk doldurma sorunları yaşanabilir; bu nedenle
yığın sınırları ve geri basınç (backpressure) önemlidir.
Performans/Maintainability: Her event türüne özgü kod parçaları yerine genel
logEvent(name, params) kullanan soyutlamalar yapın. Böylece yeni metrik eklemek
kolaylaşır. Log kütüphaneleri (FirebaseAnalytics gibi) genellikle hafif etkindir ve arka planda toplu
gönderim yapar. Test edilebilirlik için log fonksiyonunu mock’layıp birimler testinde gerçekten
gönderim olmamasını sağlayabilirsiniz.
Akış Diyagramı (metinsel): UI (Beğen Butonu) → Application (UseCase: likeProduct) → Domain
(ProductsAggregate) → API (GraphQL mutation veya REST /like çağrısı) → Backend (FastAPI)
→ Metrik Sistemi (event queue / analytics DB).
Use-case Senaryosu: “Kullanıcı bir ürünü beğendiğinde event nasıl loglanmalı?” Senaryoda, UI’de
like tuşu basıldığında öncelikle dokunmatik tepki gösterilir, sonra ProductLikeUseCase ile
backend çağrısı yapılır. FastAPI'de DB güncellemesi yapılırken aynı anda FirebaseAnalytics
veya dahili bir metrik servisine “like” olayı kaydedilir. Bu olay daha sonra iş zekâsında “günlük
beğeni sayısı” gibi grafiklerde kullanılır.
Performans/Kapasite: Örneğin 100K kullanıcıdan günlük ortalama 10K beğeni geleceğini
varsayarsak bu ~10K event/gün demektir. Firebase Analytics bu miktarı rahatça işler (limit yoktur,
sadece 500 tür sınırı vardır ). Kafka veya benzer bir sistemle 1K olay/saniyeye kadar
ölçeklenebilir altyapı planlanabilir. Supabase Logflare, günde milyarlarca log işleyebilir .
2. Performans İzleme (FPS, Başlangıç Süresi)
Mimari: Uygulama performansını izlemek için Sentry ve Firebase Performance SDK’ları
kullanılabilir. Sentry Flutter SDK otomatik olarak app start sürelerini (soğuk/ılık başlatma) ve
yavaş/kilitlenen frame sayılarını toplar . Firebase Performance Monitoring ise otomatik olarak
uygulama başlangıcı ve ağ isteklerini ölçer . İsteğe bağlı olarak önemli işlemler için özel
“trace”ler tanımlanarak ölçüm yapılabilir.
Araç/Kütüphane: sentry_flutter (SDK 6.11+ ile performans verisi) ,
firebase_performance (FlutterFire) . Ayrıca backend için Prometheus (FastAPI metrics) ve
Grafana; mobilde Firebase’den Crashlytics ve real-time datalarını toplayan Sentry.
Örnek Kod:
// Firebase Performance: özel trace örneği
final performance = FirebasePerformance.instance;
final Trace trace = performance.newTrace('load_feed_trace');
await trace.start();
// ... feed verisi yükleniyor ...
await trace.stop();
// Sentry: performans ölçümü etkinleştirme
await SentryFlutter.init(
(options) {
options.dsn = 'https://public@sentry.io/12345';
•
•
•
•
•
5
4
•
6
7 8
• 6
9
•
2
options.tracesSampleRate = 1.0; // %100 örnekleme (test için)
},
appRunner: () => runApp(MyApp()),
);
Sentry, otomatik olarak cold/warm start ve yavaş frame sayısını toplar . Örneğin, bir işlem için
custom ölçüm:
final span = Sentry.getCurrentHub().getSpan();
span?.setMeasurement('dbQueryTime', queryDurationMillis, unit:
SentryMeasurementUnit.millisecond);
Potansiyel Sorunlar & Çözümler: Performans izleme kütüphaneleri uygulamaya ek yük
getirebilir. tracesSampleRate düşük tutularak örnekleme yapılabilir. Özellikle frame izleme,
çok sık metrik toplarsa GPU yükünü artırabilir; genelde SDK’lar bunu arka planda verimli yapar.
Ekran çizim FPS’ini ölçmek için Sentry otomatik olarak slow/frozen frame yakalar . Ancak tam
FPS görünümü gerekiyorsa, gereksiz widget rebuild’leri optimize edilmeli.
Performans/Maintainability: Otomatik koleksiyonlar (app start, HTTP istekleri) kullanmak
işletim yükünü minimize eder . Özel trace’leri yalnızca kritik işlemler için kullanmak, bakım
kolaylığı sağlar. Testlerde başlangıç süresi veya yavaş frame üreten senaryoları simüle etmek için
PerformanceOverlay veya Flutter WidgetTester kullanılabilir.
Akış Diyagramı (metinsel): UI (App başlatılır) → Flutter engine → FirebasePerformance/Sentry
SDK otomatik trace başlar → Application katmanı yüklenir → Trace sonlanır ve sonuç gönderilir →
Monitoring Sistemi (Firebase Console, Sentry) verileri işler.
Use-case Senaryoları:
“Uygulama startup süresi eşiği aştığında nasıl alert üretilir?” Senaryoda, firebase_performance
SDK’sı soğuk açılış süresini alır. Bu veri BigQuery’e veya Sentry’ye aktarılıp, sorguyla “süre > 5s
olanlar” tespit edilir. Belirli sayıda uzun açılış varsa Slack/PagerDuty bildirimi gönderilir.
“Feed yüklenirken yavaş frame algılama”: Kullanıcı feed ekranında ağır işlemler/animasyon varsa
Sentry hızını (frozen frame) sayısını izler. Belirli oranda yavaş frame olursa geliştiricilere uyarı
verir.
Performans/Kapasite: Yüzbinlerce kullanıcıda, örneğin 100K aktif cihaz günde ~10M
performans olayı üretebilir. Bu nedenle izleme altyapısı (Firebase ve Sentry bulut hizmetleri veya
self-host Prometheus) ölçeklendirilmelidir. Firebase/BigQuery entegrasyonu ile bu veriler aylık
terabaytlarla saklanabilir . Sunucu tarafı için Prometheus, yüksek çekirdek sayısı ve özellikle
süzgeçlenen metrikler ile binlerce işlem/sn kapasite sağlar.
Kaynak: Sentry Flutter SDK otomatik olarak cold/warm app start ve slow frame ölçer ; Firebase
Performance SDK ise app başlangıcını ve ağ isteklerini toplar .
3. Business Intelligence Entegrasyonu
Mimari: Uygulama ve backend’den toplanan iş metrikleri (kullanıcı sayıları, etkileşimleri, satışlar
vb.) merkezi bir analitik veri ambarında (örneğin BigQuery, Snowflake veya Supabase DB)
birleştirilmelidir. Flutter içinde önemli kullanıcı aksiyonları Firebase Analytics ile takip
edilip BigQuery’ye aktarılabilir . Backend olayları (örneğin yeni sipariş, kullanıcı kaydı)
doğrudan Postgres’te saklanıyorsa, bunlar da BI araçlarıyla sorgulanabilir. Ayrıca Supabase
Logflare SQL endpoint’leri kullanılarak uygulama loglarından da rapor üretilebilir .
Araç/Kütüphane:
Veri Katmanı: Google BigQuery (Firebase Analytics verileri için), Supabase Postgres (kullanıcı ve
içerik istatistikleri için), Kafka/ClickHouse gibi hızlı analitik veri mağazaları.
6
•
6
•
10
•
•
•
•
•
3
• 6
8 9
•
11 3
4
•
•
3
BI Araçları: Metabase (açık kaynak) , Redash, Grafana (grafik ve sorgu panelleri), Looker
Studio (Google Free BI), Apache Superset. For example, Metabase doğrudan Supabase Postgres’e
bağlanabilir .
ETL/Veri Entegrasyon: Firebase → BigQuery (otomatik), Supabase → BigQuery veya benzeri.
Apache Airflow veya dbt ile ETL boru hatları oluşturulabilir.
Örnek Kod:
-- Metabase veya Grafana’da örnek bir SQL sorgu:
SELECT date_trunc('day', created_at) as tarih,
count(*) FILTER (WHERE event = 'product_view') as gorsel,
count(*) FILTER (WHERE event = 'product_like') as begeni
FROM analytics.events
WHERE user_id IS NOT NULL
GROUP BY 1 ORDER BY 1;
Flutter/Backend: Firebase Analytics event’leri BigQuery’ye export edildikten sonra, bu SQL ile
günlük beğeni ve görüntüleme sayıları hesaplanabilir. Metabase üzerinde bu sorgu gösterge
tablosuna dönüştürülür.
Potansiyel Sorunlar & Çözümler: Veri tekrarları (double-counting) ve gecikme sorunlarına
dikkat edin. Örneğin bir “like” olayı hem Flutter hem FastAPI tarafından kaydediliyorsa, BI
tarafında eşsiz sayım yapılmalı. Gerçek zamanlı iş zekası zordur; çoğu BI sistemi saatlik/günlük
batch güncelleme ile çalışır. Gerçek-zamanlı ihtiyaçlar için Grafana ve Prometheus + real-time
paneller tercih edilebilir. Ölçek büyüdüğünde (100K kullanıcı), sorgu optimizasyonu ve
indekslemeye özen gösterin.
Performans/Maintainability: Metrik sorgularını önceden tanımlı görünümler (views) veya
materia-lized view’lar ile optimize edin. Örnek: günlük raporları bir günlük tabloya yazmak gibi.
Supabase ve BigQuery’ye uygun şema (örneğin tarih/olay bazlı) seçin. Test edilebilirlik için fake
event verileriyle BI panellerini doğrulayın. Veri kaybı riskine karşı veritabanı yedeklemeleri
yapılmalı (Supabase otomatik snapshot’ları var).
Akış Diyagramı (metinsel): UI → (Analytics SDK) → Firebase Analytics → (otomatik) BigQuery
→ DB → BI Aracı (Metabase/Grafana). Veya: FastAPI → (yeni kayıt) → Supabase Postgres → BI
Aracı.
Use-case Senaryoları:
“Ürün beğenme oranı grafiği”: Her product_like event’i Firebase Analytics’e gönderilir ve
BigQuery’ye yazılır. Metabase’da ilgili zaman dilimindeki beğeni sayıları grafiğe dökülür. Müşteri
yöneticisi bu grafiğe bakıp kampanya başarısını değerlendirebilir.
“Kullanıcı kaybı analizi”: Kullanıcının son aktif olduğu tarih bilgisi Supabase’de tutulur. BI sorgusu
ile aktif/pasif kullanıcı segmentleri oluşturulur. Veriler Looker Studio veya Superset ile
raporlanarak, ürün ekibi karar alır.
Performans/Kapasite: Büyük veri iş için planlama şart. Örnek olarak; Firebase Analytics günde
10M etkinlik gönderirse, BigQuery bunun işlenmesi için yeterli donanıma sahip. Metabase gibi
araçlar yüzbinlerce satırı görselleştirebilir, ancak sorguları filitreleyip özet tablolarla
sınırlandırmak gerekir. 100K kullanıcı için genellikle dakikada 500-1000 sorgu/s ve tps en fazla
1000 hedefi uygun olabilir. Gerçek-zamanlı KPI izleme için Grafana + Prometheus kuralları
(örneğin saniyede QPS artışını izle) önerilir.
4. Uyarı Sistemi ve Olay Yönetimi (Alerting & Incident Response)
Mimari: Kritik hatalar veya metrik sapmaları için otomatik uyarı sistemleri kurulmalıdır. Örneğin
Sentry’de belirli bir hata sayısı aşılırsa ya da performans metrikleri threshold değerini geçerse
• 2
12
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
4
alarm gönderilir. Sunucu tarafında Prometheus Alertmanager ile CPU, bellek veya HTTP hata
oranı için kurallar oluşturun. Bu uyarılar Slack, e-posta, SMS veya PagerDuty üzerinden ilgili ekibe
iletilir. Uyarıları bir incident management sistemine (Opsgenie, PagerDuty, Jira Service
Management) entegrasyonla takip edin.
Araç/Kütüphane:
Uyarı Kuralları: Sentry Alerts (ör. hata/adet eşiği), Firebase Crashlytics Alerts (ilk hata,
regressiyon), Prometheus + Alertmanager (metrik eşiği), Grafana Alerting.
Bildirim Kanalları: Slack/Teams entegrasyonu, e-posta, SMS, PagerDuty, Opsgenie. Sentry’yi
PagerDuty ile entegre etmek kolaydır . Grafana veya Alertmanager için Slack webhook, eposta, OpsGenie adaptor kullanılabilir.
Incident Yönetimi: Opsgenie, PagerDuty veya Jira Service Desk; seçilen olaya göre otomatik
çağrı/köngü talebi oluşturabilir.
Örnek Kod/ Konfigürasyon:
# Prometheus Alertmanager örneği (Grafana üzerinden de benzer kural
eklenebilir)
groups:
- name: fastapi_alerts
rules:
- alert: HighErrorRate
expr: rate(http_requests_total{job="fastapi",status=~"5.."}[1m]) >
0.05
for: 5m
labels:
severity: critical
annotations:
summary: "FastAPI'de 5xx hata oranı yüksek!"
description: "Son 5 dakikada 5xx hatası %5'in üzerinde. Kontrol
edin."
// Sentry: belirli performans sapması için manuel tetikleme (opsiyonel)
if (appStartupTimeMs > 5000) {
Sentry.captureMessage("App startup süresi kritik: ${appStartupTimeMs}
ms");
}
Potansiyel Sorunlar & Çözümler: Çok sayıda uyarı alert fatigue yaratabilir . Bu yüzden
eşikleri dikkatle belirleyin, yanlış pozitifleri azaltın. Örneğin başlangıçta sadece fatal seviyedeki
hataları bildirin; gerisi toplu rapor olarak günlük e-posta ile versin. Uyarıları gruplayarak
yönetmek (aynı tip hataları tek bildirimde toplamak) önemli. Atlassian’a göre akıllı eşikler
belirlemek, duplikasyonları önlemek ve öncelik seviyeleri atamak en iyi pratiktir . Örneğin,
kritik bir iş hatası değilse geliştirici gece uyandırılmasın; daha az acil uyarılar kanban panosuna
not olarak düşsün. Ayrıca uyarıların sebebi ve alınacak aksiyon net olmalıdır; Atlassian bu
bağlamda uyarılara “chart, log, runbook” gibi ek bilgi eklenmesini önerir .
Performans/Maintainability: Uyarı kurallarını versiyon kontrollü (YAML/Terraform) tutun.
Otomasyon (örneğin bir alarm geldiğinde sunucu restart) kullanırken çok dikkatli olun. Uyarı
sistemini düzenli test edin (test alarmları göndererek ekibin süreçleri çalıştığından emin olun).
Ayrıca, bir uyarının geçmişi ve kim tarafından onaylandığı kayıt altına alınmalıdır (opsiyonel bir
on-call sistemi ile).
•
•
•
13
•
•
• 14
14 15
15
•
5
Akış Diyagramı (metinsel): UI/Backend → Monitoring Sistemi (Sentry/Prometheus) → Trigger
(eşiğin aşılması) → Alert Gateway (Alertmanager/Sentry Alert) → Bildirim Kanalı (Slack/
PagerDuty) → On-Call Mühendisi → Incident Response (swap roller, post-mortem).
Use-case Senaryoları:
“Uygulama açılış süresi 5s’yi aştığında nasıl alert üretilir?” Senaryoda Firebase Performance veya
custom trace ile ölçülen açılış zamanları backend tarafında BigQuery’de bir tabloya yazılır. Belirli
bir periyotta ortalama veya %95 açılış süresi 5000ms’yi aşarsa, bir cron job bu durumu kontrol
eder ve Sentry’ye özel bir durum (issue) veya Slack’te kritik uyarı gönderir. Opsgenie’de otomatik
on-call döngüsü başlatılabilir.
“Kritik hata: newthread katmanındaki exception”: FastAPI loglarında beklenmedik bir exception
yakalanır, Sentry’ye bildirilir. Sentry üzerinden Slack entegrasyonuyla ilgili geliştirme kanalına
bildirim gider. Eğer aynı hata 5 defa gelirse PagerDuty devreye girer.
Performans/Kapasite: Ölçek büyüdükçe (10K → 100K kullanıcı), metrik olay yükü ve uyarı trafiği
de artar. Bu nedenle rate limiting yapın; aynı problemin ardı arkası kesilmezse tek bir olayın
birden çok bildirim üretmesini engelleyin. Örneğin saniyede 1000 hata oluşuyorsa, tek bir toplu
uyarı gönderip geri sayım koymak faydalı olabilir. Uyarı gecikmesi genelde saniyelerle sınırlıdır
(Prometheus 1-minik scrape, ek bildirim gecikmesi). Kritik sistemler için hedef; bir sorun tespit
edilip 1 dakikadan kısa sürede bildirim gitmesidir.
Kaynakça: Flutter/Firebase ile olay ve performans takibi için dokümanlar , Supabase içgörüler ve
Metabase entegrasyonu , ve uyarı/operasyonel en iyi pratikler için Atlassian rehberi gibi
kaynaklar kullanıldı.
Metrics | Supabase Docs
https://supabase.com/docs/guides/telemetry/metrics
Connecting to Metabase | Supabase Docs
https://supabase.com/docs/guides/database/metabase
Export project data to BigQuery  |  Firebase Documentation
https://firebase.google.com/docs/projects/bigquery-export
Logs & Analytics | Supabase Features
https://supabase.com/features/logs-analytics
Log events | FlutterFire
https://firebase.flutter.dev/docs/analytics/events/
Performance Metrics | Sentry for Flutter
https://docs.sentry.io/platforms/dart/guides/flutter/tracing/instrumentation/performance-metrics/
Performance Monitoring | FlutterFire
https://firebase.flutter.dev/docs/performance/usage/
Get started with Performance Monitoring for Flutter  |  Firebase Performance Monitoring
https://firebase.google.com/docs/perf-mon/flutter/get-started
Proactively Wrangle Events Using Sentry's Alert Rules | Product Blog
https://blog.sentry.io/proactive-alert-rules/
Guide to IT alerting: practices and tools | Atlassian
https://www.atlassian.com/incident-management/on-call/it-alerting
•
•
•
•
•
5 6
2 1 14 15
1
2 12
3
4
5 11
6
7 9 10
8
13
14 15
6
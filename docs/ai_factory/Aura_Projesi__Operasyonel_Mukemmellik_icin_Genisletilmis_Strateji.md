Aura Projesi: Operasyonel Mükemmellik için Genişletilmiş
Strateji
Bölüm 1: "Yapay Zeka Kod Üretim Fabrikası" için Operasyonel
Plan: Araç Seçimi ve Akış Yönetimi
Sorun: "Yapay Zeka Kod Üretim Fabrikası" ve "Böl ve Yönet Orkestrasyonu" kavramları
stratejik bir vizyon sunsa da, bu akışları yönetecek somut bir "iş akışı motoru" veya
"orkestrasyon aracı" seçimi eksiktir. Bu durum, "prompt kaosu" riskini beraberinde
getirmektedir.
Çözüm ve Yol Haritası: Bu operasyonel boşluğu doldurmak için, projenin olgunluk
seviyesine göre evrilecek iki aşamalı bir orkestrasyon aracı stratejisi önerilmektedir.
Bu yaklaşım, hızlı prototipleme ile üretim sınıfı güvenilirliği dengelemeyi hedefler.
1.1. Aşama 1: Hızlı Prototipleme ve Akış Keşfi (Flowise Kullanımı)
Projenin başlangıç aşamasında, temel hedef farklı ajan iş akışlarını hızla test etmek ve
en verimli süreçleri keşfetmektir. Bu aşamada kod karmaşıklığına boğulmak yerine,
görsel bir araç kullanmak "prompt kaosunu" önleyecektir.
● Araç Seçimi: Flowise. Flowise, LangChain.js üzerine inşa edilmiş, sürükle-bırak
arayüzü sunan açık kaynaklı bir araçtır.
1 Geliştirici olmayan paydaşların bile akışları
anlamasını ve katkıda bulunmasını sağlar.
1
● Uygulama:
○ Farklı uzman ajanlar (UI, Backend, Güvenlik, Test) arasındaki etkileşimler,
Flowise kanvası üzerinde görsel olarak tasarlanır.
○ Hangi ajanın hangi bilgiyi ne zaman alacağı, hangi araçları kullanacağı ve
çıktısını nereye yönlendireceği net bir şekilde haritalanır.
○ Bu görselleştirme, "prompt zincirlerinin" karmaşık ve doğrusal olmayan yapısını
anlaşılır kılarak, ekibin ortak bir anlayış geliştirmesini sağlar.
● Neden Bu Yaklaşım? Bu aşamada amaç, mükemmel kodu yazmak değil,
mükemmel süreci tasarlamaktır. Flowise, bu süreci kodlama yükü olmadan
tasarlamamıza, test etmemize ve yinelememize olanak tanır, bu da hızlı
prototipleme için idealdir.
1
1.2. Aşama 2: Üretim Sınıfı Orkestrasyon (LangGraph ve Özel Kod Entegrasyonu)
Prototipleme aşamasında kanıtlanmış ve optimize edilmiş iş akışları, daha fazla kontrol,
güvenilirlik ve ölçeklenebilirlik sunan kod tabanlı bir çerçeveye taşınmalıdır.
● Araç Seçimi: LangGraph. LangChain'in bir uzantısı olan LangGraph, özellikle
döngüler ve karmaşık kontrol akışları içeren çoklu ajan sistemlerini bir "grafik"
olarak modellemek için tasarlanmıştır.
3 Bu, CrewAI gibi daha üst düzey çerçevelere
kıyasla daha fazla esneklik ve alt düzey kontrol sağlar.
3
● Uygulama:
○ Flowise'da tasarlanan ve doğrulanan mantıksal akışlar, LangGraph kullanılarak
Python kodunda yeniden oluşturulur.
○ Her uzman ajan bir "düğüm" (node), ajanlar arası geçişler ise "kenarlar" (edge)
olarak tanımlanır. Bu yapı, ajanlar arası kontrol akışını programatik olarak
yönetmeyi sağlar.
○ LangChain'in ekosisteminden tam olarak faydalanılarak, LangSmith gibi
araçlarla gözlemlenebilirlik ve hata ayıklama yetenekleri en üst düzeye çıkarılır.
3
● Neden Bu Yaklaşım? LangChain ve LangGraph, üretim ortamları için daha fazla
esneklik, daha iyi hata yönetimi ve mevcut altyapılarla daha derin entegrasyon
yetenekleri sunar.
5 Flowise'da kanıtlanmış bir mantığı LangGraph'e taşımak, "en iyi
süreci" "en iyi teknolojiyle" birleştirmemizi sağlar.
Bölüm 2: Ekipler Arası İşbirliği Modeli: Bütünleşik MLOps Yaşam
Döngüsü
Sorun: Flutter/Backend ve AI/ML ekipleri arasındaki işbirliği modeli ve sorumluluk
dağılımı net değildir. Bu durum, AI servislerinin ana geliştirme döngüsüne
entegrasyonunda belirsizlik yaratabilir.
Çözüm ve Yol Haritası: Geleneksel yazılım geliştirme yaşam döngüsünü (SDLC),
makine öğrenmesi yaşam döngüsüyle birleştiren Bütünleşik bir MLOps (Makine
Öğrenmesi Operasyonları) çerçevesi oluşturulmalıdır. Bu çerçeve, iki ekibin ayrı
silolarda değil, tek bir üretim hattının farklı istasyonlarında çalıştığı bir model sunar.
2.1. Rollerin ve Sorumlulukların Netleştirilmesi
Etkili bir işbirliği, her ekibin kendi uzmanlık alanına odaklanmasını ve diğer ekibin
ihtiyaç duyduğu "sözleşmeleri" (contracts) sağlamasını gerektirir.
● Flutter/Backend Ekibi (Uygulama Geliştiricileri):
○ Sorumluluk: AI servislerinin tüketicisidir. Bir özelliğin ihtiyaç duyduğu AI
yeteneğini tanımlar ve bu yeteneğin nasıl bir arayüzle (API endpoint, girdi/çıktı
formatları) sunulması gerektiğini belirleyen API Sözleşmesini oluşturur.
○ Çıktı: AI_SERVICE_CONTRACT.md gibi belgeler ve API test senaryoları.
● AI/ML Ekibi (Model Geliştiricileri):
○ Sorumluluk: API Sözleşmesini karşılayan AI modelinin ve FastAPI servisinin
uygulayıcısıdır. Modelin eğitimi, doğruluğu, performansı ve güvenli bir şekilde
bir API olarak sunulmasından sorumludur.
○ Çıktı: API Sözleşmesine uygun, test edilmiş ve dağıtıma hazır FastAPI servisi.
● "Yapay Zeka Teknik Lideri" Rolü:
○ Sorumluluk: İki ekip arasında köprü görevi görür. Uygulama ekibinin
ihtiyaçlarını AI ekibinin anlayacağı teknik görevlere çevirir ve AI servisinin genel
"fabrika" mimarisine ve CI/CD süreçlerine entegrasyonunu denetler.
2.2. Bütünleşik Geliştirme ve Dağıtım Akışı (CI/CD for ML)
AI servisleri, ana uygulamanın bir parçası olarak aynı CI/CD boru hattına entegre
edilmelidir.
1. Planlama: Her iki ekip bir araya gelerek özellik gereksinimlerini ve API
sözleşmesini tanımlar.
2. Geliştirme ve Versiyonlama: AI ekibi modeli ve servisi geliştirir. Bu süreçte
sadece kod değil, aynı zamanda veri setleri ve eğitilmiş modeller de versiyonlanır
(örn. Git, DVC, MLflow kullanarak).
3. Bütünleşik Test: AI servisi bir hazırlık (staging) ortamına dağıtılır. CI boru hattı,
hem AI ekibinin birim testlerini hem de Flutter/Backend ekibinin API sözleşmesine
karşı yazdığı entegrasyon testlerini otomatik olarak çalıştırır.
4. Dağıtım ve İzleme: Testler başarılı olduğunda, AI servisi üretim ortamına dağıtılır.
Dağıtım sonrası izleme iki yönlüdür: AI ekibi model performansını (veri kayması,
doğruluk), uygulama ekibi ise API performansını (gecikme, hata oranları) izler.
Öneri: Bu işbirliği modelini ve bütünleşik akışı resmileştirmek için
AI_SERVICES_INTEGRATION_GUIDE.md adında yeni bir belge oluşturulmalıdır. Bu
belge, roller, sorumluluklar, API sözleşme standartları ve ortak CI/CD süreçlerini
detaylandırarak ekipler arası koordinasyon belirsizliğini ortadan kaldıracaktır.
Bölüm 3: Tasarımda Derinlik: "Sıcak" ve Erişilebilir Bir Karanlık
Mod Deneyimi
Sorun: Mevcut tasarım rehberleri teknik uyumluluğa odaklanmış durumda, ancak
Aura'nın "kişisel ve sıcak" marka kimliğinin karanlık modda nasıl korunacağına dair
duygusal ve estetik bir çerçeve eksik.
Çözüm ve Yol Haritası: Sadece teknik olarak erişilebilir değil, aynı zamanda duygusal
olarak erişilebilir bir karanlık mod deneyimi yaratmak için aşağıdaki UI/UX ilkeleri
benimsenmelidir. Bu ilkeler, markanın sıcaklığını korurken göz yorgunluğunu azaltmayı
hedefler.
● 1. Saf Siyah ve Beyazdan Kaçının:
○ İlke: Göz yorgunluğunu azaltmak için yüksek kontrasttan kaçının. Saf siyah
(#000000) bir arka plan üzerinde saf beyaz (#FFFFFF) metin, özellikle uzun
süreli okumalarda rahatsız edici olabilir.
○ Uygulama: Ana yüzey rengi olarak Google Material Design'ın önerdiği gibi
koyu bir gri tonu (örneğin, #121212) kullanın. Metinler için ise saf beyaz yerine
%87 opaklığa sahip bir beyaz tonu tercih edin. Bu, kontrastı yumuşatır ve daha
"sıcak" bir his verir.
● 2. Marka Kimliğini Renklerle Yansıtın:
○ İlke: Karanlık mod, markanın renk paletini yok etmemeli, aksine onu zarif bir
şekilde yansıtmalıdır.
○ Uygulama: Ana yüzey rengi olan koyu grinin üzerine, Aura'nın birincil marka
rengini çok düşük bir opaklıkta (örneğin, %8) bir katman olarak ekleyin. Bu,
arka plana markanın kimliğini yansıtan hafif bir renk tonu katarak arayüzü daha
"kişisel" ve "sıcak" hale getirir.
● 3. Doygun Renkleri Azaltın (Desaturasyon):
○ İlke: Parlak ve doygun renkler, karanlık bir arka plan üzerinde "titreşim"
yaparak gözü yorar ve okunabilirliği düşürür.
○ Uygulama: Vurgu renkleri (accent colors) için marka paletinizdeki renklerin
daha az doygun (desaturated) versiyonlarını kullanın. Bu, hem WCAG
erişilebilirlik kontrast oranlarını (en az 4.5:1) karşılamayı kolaylaştırır hem de
daha sakin ve göz dostu bir deneyim sunar.
● 4. Derinliği Işıkla İfade Edin, Gölgeyle Değil:
○ İlke: Karanlık yüzeylerde gölgeler etkili bir şekilde görünmez. Bu nedenle,
katmanlar arasındaki hiyerarşi ve derinlik hissi farklı bir yöntemle sağlanmalıdır.
○ Uygulama: Z ekseninde daha "yukarıda" olan bir bileşenin yüzey rengini,
altındaki katmandan marjinal olarak daha açık yapın. Örneğin, bir diyalog
kutusu, arkasındaki karartılmış ana ekrandan daha açık bir gri tonuna sahip
olmalıdır. Bu, gölge kullanmadan zarif bir derinlik algısı yaratır.
Öneri: Bu ilkeler, STYLE_GUIDE.md dosyasına "Duygusal Erişilebilirlik ve Karanlık Mod"
başlığı altında, görsel "Yapılması ve Yapılmaması Gerekenler" örnekleriyle birlikte
eklenmelidir. Bu, tasarım ve geliştirme ekiplerine somut ve uygulanabilir bir rehber
sunacaktır.
Bölüm 4: Çevrimdışı Stratejinin Genişletilmesi: AI Destekli
Asistanlık için Katmanlı Yaklaşım
Sorun: Mevcut çevrimdışı strateji, temel veri senkronizasyonunu kapsıyor ancak
Aura'nın ana değeri olan AI destekli "asistanlık" deneyiminin çevrimdışı durumda nasıl
çalışacağını ele almıyor.
Çözüm ve Yol Haritası: AI işlevselliğinin çevrimdışı davranışını yönetmek için üç
katmanlı bir çevrimdışı AI stratejisi tasarlanmalıdır. Bu strateji, kullanıcı deneyiminin
kesintisizliğini sağlamak için zarif bir şekilde yeteneklerini azaltan (graceful
degradation) bir yapı sunar.
● Katman 1: Önbelleğe Alma ve Kuyruğa Ekleme (Temel Çevrimdışı Deneyim):
○ İlke: En yaygın AI tabanlı sonuçları önbelleğe al ve çevrimdışı yapılan işlemleri
senkronizasyon için kuyruğa ekle.
○ Uygulama:
■ Öneri Önbellekleme: Kullanıcı çevrimiçiyken, kişiselleştirilmiş stil önerileri
gibi AI tarafından üretilen sonuçlar periyodik olarak alınır ve yerel
veritabanına (Isar/Hive) kaydedilir. Kullanıcı çevrimdışı olduğunda,
uygulama bu önbelleğe alınmış verileri sunar ve arayüzde bu verilerin
güncel olmayabileceğine dair ince bir bildirim gösterir.
■ İstek Kuyruğu: Kullanıcının yeni bir kıyafet eklemesi gibi sunucu tarafında
AI analizi gerektiren bir eylem gerçekleştirmesi durumunda, bu istek tüm
verileriyle birlikte yerel bir kuyruğa kaydedilir. workmanager gibi bir arka
plan hizmeti, bağlantı yeniden kurulduğunda bu kuyruğu otomatik olarak
işler ve sunucuya gönderir.
● Katman 2: Cihaz Üzerinde Çıkarım (On-Device Inference) (Gelişmiş
Çevrimdışı Deneyim):
○ İlke: Temel ve kritik AI görevleri için, sunucuya ihtiyaç duymadan doğrudan
cihaz üzerinde çalışabilen basitleştirilmiş modeller kullanın.
○ Uygulama:
■ Model Seçimi: Görüntüden temel nesne tanıma (örneğin, "bu bir gömlek
mi, pantolon mu?") gibi basit sınıflandırma görevleri için optimize edilmiş
bir TensorFlow Lite (TFLite) modeli oluşturulur.
■ Entegrasyon: Bu TFLite modeli, uygulamanın içine gömülür. Flutter kodu,
platform kanalları (platform channels) aracılığıyla bu yerel modele veri
gönderir ve anında bir sonuç alır. Bu, kullanıcıya internet bağlantısı
olmadan bile anlık "akıllı" geri bildirim sağlar.
● Katman 3: Akıllı Senkronizasyon ve Çatışma Çözümü:
○ İlke: Bağlantı yeniden kurulduğunda, çevrimdışı üretilen verileri akıllı bir şekilde
sunucuyla senkronize et ve olası çakışmaları çöz.
○ Uygulama:
■ Kuyruktaki istekler (Katman 1) sunucuya gönderilir.
■ Cihaz üzerinde yapılan çıkarımların (Katman 2) sonuçları, sunucudaki daha
güçlü model tarafından doğrulanabilir. Bir çakışma durumunda (örneğin,
TFLite "gömlek" derken, sunucu modeli "bluz" olarak tanımlarsa),
sunucunun sonucu "nihai doğru" olarak kabul edilir ve yerel veritabanı
güncellenir. Bu, "son yazan kazanır" (last write wins) ilkesinin daha akıllı bir
versiyonudur.
Öneri: Bu katmanlı yaklaşımı detaylandıran OFFLINE_AI_STRATEGY.md adında yeni bir
teknik belge oluşturulmalıdır. Bu belge, hangi AI özelliklerinin önbelleğe alınacağını,
hangi modellerin TFLite ile cihaz üzerinde çalıştırılacağını ve senkronizasyon/çatışma
çözümü mantığını net bir şekilde tanımlayacaktır.
Alıntılanan çalışmalar
1. LangChain Vs LlamaIndex Vs Flowise: Top LLM Frameworks Compared, erişim
tarihi Temmuz 31, 2025,
https://www.howtobuysaas.com/blog/langchain-vs-llamaindex-vs-flowise/
2. 31 Best LangChain Alternatives Developers Love for Faster AI Builds, erişim tarihi
Temmuz 31, 2025, https://blog.lamatic.ai/guides/langchain-alternatives-guide/
3. LangGraph: Multi-Agent Workflows - LangChain Blog, erişim tarihi Temmuz 31,
2025, https://blog.langchain.com/langgraph-multi-agent-workflows/
4. Building AI Workflows with Multi-Agent Frameworks - Botpress, erişim tarihi
Temmuz 31, 2025, https://botpress.com/blog/multi-agent-framework
5. LangChain Alternatives | IBM, erişim tarihi Temmuz 31, 2025,
https://www.ibm.com/think/insights/langchain-alternatives
6. 25 LangChain Alternatives You MUST Consider In 2025 - Akka, erişim tarihi
Temmuz 31, 2025, https://akka.io/blog/langchain-alternatives
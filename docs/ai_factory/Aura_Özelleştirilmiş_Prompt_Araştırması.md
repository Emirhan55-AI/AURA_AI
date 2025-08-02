Aura Projesi: Gelişmiş Yapay Zeka Kod Üretim Akışı için
Stratejik Çerçeve
Bölüm 1: Yönetici Özeti: Aura Yapay Zeka Kod Üretim Fabrikasının
Mimarisi
Stratejik Vizyon
Bu rapor, Aura projesinin yapay zeka destekli geliştirme süreçlerinde stratejik bir
dönüşümün ana hatlarını çizmektedir. Mevcut anlık ve tek seferlik prompt (istem)
kullanımından, sistematik, test odaklı ve sürekli kendini iyileştiren bir "Yapay Zeka Kod
Üretim Fabrikası" oluşturmaya yönelik bir geçişi hedeflemektedir.
Temel Dayanaklar
Bu dönüşüm, en ileri düzey araştırmalar ve en iyi uygulamalardan türetilen üç temel
dayanak üzerine inşa edilmiştir:
1. Prompt Mühendisliğinden Akış Mühendisliğine Geçiş: Büyük Dil Modellerini
(LLM'ler) her şeyi bilen birer kahin olarak değil, daha büyük ve otomatikleştirilmiş
bir sürecin bileşenleri olarak ele alan çok aşamalı, hesaplamalı iş akışlarının
benimsenmesi.
1
2. Bileşik Yapay Zeka Sistemleri Mimarisi: Aura teknoloji yığınının belirli alanlarında
(Kullanıcı Arayüzü, Arka Uç, Güvenlik) uzmanlaşmış, her biri kendi alanında
optimize edilmiş çoklu ve özelleşmiş yapay zeka modellerini yöneten bir "böl ve
yönet" stratejisinin kullanılması.
1
3. Test Odaklı Geri Besleme ve Adaptasyon: Yapay zeka tarafından üretilen kodun
otomatik olarak yürütüldüğü, test edildiği ve eleştirildiği kapalı döngü sistemlerinin
uygulanması. Bu, sistemin kendi hatalarından öğrenmesini ve hem çıktılarını hem
de iç süreçlerini sürekli olarak iyileştirmesini sağlar.
1
Beklenen Sonuçlar
Bu çerçevenin uygulanması; daha yüksek kod kalitesi, artırılmış geliştirme hızı,
geliştirilmiş güvenlik ve performans ile kod inceleme ve hata düzeltme için gereken
manuel çabanın önemli ölçüde azalmasıyla sonuçlanacaktır. Bu yaklaşım, geliştiricinin
rolünü basit bir kod yazıcıdan, bir yapay zeka sistemleri mimarına ve doğrulayıcısına
dönüştürmektedir.
Bölüm 2: Kod Üretiminde Yeni Ufuk: İstemlerden Süreçlere
Bu bölüm, basit etkileşimlerin ötesine geçerek sağlam ve mühendislik odaklı sistemlere
doğru ilerleyen modern yapay zeka kod üretiminin teorik temelini oluşturmaktadır.
2.1. Olgunlaşma Eğrisi: Konuşmadan Hesaplamaya
LLM'ler ile kod üretimi için etkileşim kurma süreci, yapılandırılmamış konuşmalardan
mühendislik hesaplamalarına doğru bir evrim geçirmektedir. Bu olgunlaşma, verimlilik
ve güvenilirlik için zorunlu bir adımdır.
● Başlangıç Durumu (Konuşma): İlk etkileşimler, basit ve konuşma diline dayalı
sorularla gerçekleşir. Bu yaklaşım, yapı ve bağlam eksikliği nedeniyle modelin
görevi tam olarak anlamasını engeller, bu da verimsizliğe, çok sayıda tekrar
gerektirmesine ve hataya açık bir sürece yol açar.
1
● İlk Soyutlama (Kalıplar): Bu verimsizliği gidermek için "Persona", "Tarif" ve
"Şablon" gibi yeniden kullanılabilir "prompt kalıpları" ortaya çıkmıştır. Bu kalıplar,
geleneksel yazılım mühendisliğindeki tasarım kalıplarına benzer şekilde,
tekrarlayan sorunlara kanıtlanmış ve yapılandırılmış çözümler sunarak sürece bir
düzen getirir.
1
● Nihai Durum (Hesaplama ve Akış Mühendisliği): Kurumsal düzeyde kod üretimi
gibi karmaşık ve yüksek riskli görevler için paradigma, Akış Mühendisliği'ne
(Flow Engineering) kaymalıdır. Bu noktada odak, mükemmel bir tekil prompt
hazırlamaktan, çok adımlı, durum bilgisi olan ve yinelemeli bir hesaplama süreci
tasarlamaya geçer. Bu paradigmada LLM, daha büyük bir algoritmik iş akışı içinde
çağrılabilen bir alt yordam olarak ele alınır.
1 AlphaCodium makalesinin yazarlarının
zamanlarının yaklaşık %95'ini "akış mühendisliği" ve yalnızca %5'ini "prompt
mühendisliği" için harcadıklarını belirtmeleri, bu paradigma kaymasının önemini
vurgulayan kilit bir kanıttır.
1
2.2. Aura için Gelişmiş Prompt Kalıplarının Taksonomisi
Bu alt bölüm, araştırmalarda tanımlanan temel prompt kalıplarını ve bunların Aura
projesi içindeki stratejik uygulamalarını detaylandırmaktadır.
● Persona (Rol Atama): LLM'e "Kıdemli Arka Uç Güvenlik Uzmanı" veya "Bulut
Güvenlik Mimarı" gibi bir uzman rolü atanmasıdır. Bu teknik, modelin çıktısını o role
özgü kalite, standartlar ve en iyi uygulamalara odaklamasını sağlar. Özellikle
güvenlik açısından hassas veya yüksek uzmanlık gerektiren görevler için oldukça
etkilidir.
1
● Tarif (Adım Adım Talimatlar): LLM'e izlemesi için sıralı bir plan veya adım listesi
sunulmasıdır. Bu kalıp, algoritmik kod üretimi veya karmaşık, çok adımlı süreçlerin
uygulanmasında öne çıkarak mantıksal, şeffaf ve öngörülebilir bir iş akışı sağlar.
1
● Şablon (Yapılandırılmış Çıktı): LLM'in çıktısını YAML veya JSON gibi belirli,
önceden tanımlanmış bir formatla sınırlandırmaktır. Bu, özellikle otomasyon için
kritik öneme sahiptir, çünkü belirsizliği azaltır ve modelin çıktısını sistemin diğer
bölümleri tarafından programatik olarak ayrıştırılabilir hale getirir.
1
● Akış (Zincirleme Yönlendirme): Bir LLM çağrısının çıktısının bir sonrakinin girdisi
haline geldiği çok aşamalı, etkileşimli süreçler oluşturmaktır. Düşünce Zinciri
(Chain-of-Thought - CoT) gibi teknikleri içerir ve bir sonraki bölümde ele alınacak
olan daha gelişmiş çerçevelerin kavramsal temelini oluşturur.
1
2.3. Modern Yapay Zeka İş Akışlarının Mimari Üçlüsü
Bu kısımda, araştırmalarda tanımlanan en önemli üç gelişmiş iş akışı mimarisi
incelenmektedir.
● AlphaCodium (Test Odaklı Üretim): Bu çok aşamalı akış, problemin ve genel
testlerin (public tests) "yansıtılması" (reflection) ile başlar, ardından kod üretir ve
bu kodu hem genel hem de yapay zeka tarafından üretilen ek testlere karşı
yinelemeli olarak doğrular. GPT-4'ün doğruluğunu CodeContests veri setinde
%19'dan %44'e çıkarması, bir modelin kendi köşe durumlarını öngörmeye ve
kapsamaya zorlanmasının gücünü kanıtlamaktadır.
1
● RCI (Gözden Geçir-Eleştir-İyileştir): Bu kendi kendini düzeltme döngüsü, LLM'i
önce kod üretmeye, ardından kendi çıktısını kusurlar (örneğin, güvenlik veya
performans sorunları) açısından eleştirmeye ve son olarak bu eleştiriye dayanarak
kodu iyileştirmeye yönlendirir. Güvenlik açıklarını azaltmadaki belgelenmiş etkinliği,
bu tekniğin önemini göstermektedir.
1
● SED (Sentezle-Yürüt-Hata Ayıkla): Bu, en temel ve gerekli geri besleme
döngüsü olarak sunulmaktadır. Model kodu sentezler, harici bir sistem kodu
yürütür (örneğin, bir testi çalıştırır) ve bir hata oluşursa, sonuçtaki hata mesajı
modeli hata ayıklamaya yönlendirmek için geri beslenir. Bu döngü, modeli kodunun
gerçek dünya sonuçlarıyla yüzleşmeye zorlayarak teorik üretim ile pratik doğruluk
arasındaki boşluğu kapatır.
1
2.4. Temel Çıkarım: Test Odaklı Geri Besleme Döngüsü Pazarlığa Açık Değildir
Tüm gelişmiş çerçeveleri (AlphaCodium, RCI, SED) birbirine bağlayan temel ilke, kapalı
geri besleme döngüsüdür. LLM'ler doğaları gereği güvenilmezdir ve doğru gibi
görünen ancak anlamsal olarak kusurlu kodlar üreten "kıl payı kaçırma sendromuna"
(near miss syndrome) eğilimlidir.
1 Tek seferlik istemler gibi açık döngü sistemleri, bu
temel sorunu çözemez. Güvenilirliği garanti etmenin tek yolu, üretilen kodu
yürüterek ve sonuçları (başarılı, başarısız, hata mesajı, performans metriği) bir sonraki
yineleme için geri besleme sinyali olarak kullanarak döngüyü kapatmaktır.
Bu durumun altında yatan mantık zinciri şöyledir:
1. Temel Sorun: LLM'ler, akla yatkın ancak genellikle yanlış veya hatalı kodlar üretir.
1
Bu, onları üretimde kullanmanın merkezindeki zorluktur.
2. Teşhis Sinyali: Kodun doğruluğu hakkındaki en güvenilir ve nesnel gerçek
kaynağı, başka bir LLM'in görüşü değil, kodun fiili olarak yürütülmesidir. Geçen bir
test veya bir çökme, belirsizliğe yer bırakmayan bir geri bildirim sağlar.
3. Mimari Çözüm: Bu nedenle, herhangi bir sağlam yapay zeka kod üretim sistemi,
LLM'in çıktısını bir yürütme ortamına (bir test çalıştırıcısı veya bir profil oluşturucu
gibi) mimari olarak bağlamalıdır. Bu, bir kendi kendini düzeltme mekanizması
yaratır.
4. Deneysel Kanıt: AlphaCodium 1
, RCI
1 ve diğer ajan tabanlı sistemler
1
için
belirtilen çarpıcı performans artışları, bu yürütme-geri besleme döngüsünü
kapatmanın doğrudan ve öngörülebilir sonuçlarıdır.
Aura için stratejik çıkarım şudur: Aura'nın yapay zeka iş akışı için birincil mimari hedef,
yalnızca kod üretmekten, otomatik bir üret ve doğrula sistemi inşa etmeye kaymalıdır.
Bu, yatırımın sadece prompt kütüphanesine veya model seçimine değil, test, yürütme
ve geri besleme altyapısına öncelik verilmesi gerektiği anlamına gelir.
Bölüm 3: Aura için Bileşik Yapay Zeka Sistemleri Mimarisi
Bu bölüm,
1
'deki akademik araştırmalardan elde edilen üst düzey stratejik kavramları,
Aura projesi için özel, çoklu ajanlı bir yapay zeka mimarisi tasarlamak üzere
uygulamaktadır.
3.1. "İş Bölümü" İlkesi: Çoklu Model, Çoklu Ajan Stratejisi
Bu strateji, Berkeley AI Research tarafından formüle edilen "Modellerden Bileşik Yapay
Zeka Sistemlerine Geçiş" felsefesini resmi olarak benimsemektedir.
1 Tek, monolitik,
genel amaçlı bir LLM'e güvenmek yerine, her biri kendi alanında uzman olan çok sayıda
daha küçük, özelleşmiş yapay zeka ajanını yöneten bir sistem inşa edilecektir.
Aura'nın Uzmanlaşmış Ajan Kadrosu:
● Flutter UI Ajanı: Bu ajan, sunum katmanı için yüksek kaliteli, deyimsel (idiomatic)
Flutter kodu üretme konusunda uzmanlaşacaktır. UI/UX gereksinimleri, widget
özellikleri ve projenin yerleşik mimari kalıpları ile yönlendirilecektir. Bu ajan için
ideal model, UI/Ön uç görevlerindeki gücü ve tüm proje dosyalarını devasa bağlam
penceresinde işleyebilme yeteneği ile bilinen Claude olabilir.
1
● FastAPI Arka Uç Ajanı: Bu ajanın uzmanlığı, güvenli ve performanslı Python arka
uç mantığı üretmektir. API sözleşmeleri, veri modelleri ve iş mantığı gereksinimleri
ile yönlendirilecektir. Burada tercih edilecek model, mantık, algoritmalar ve test
odaklı geliştirmede öne çıkan GPT-4o veya Qwen olabilir.
1
● Supabase Güvenlik Ajanı: Supabase Satır Düzeyinde Güvenlik (RLS) politikaları
için hassas ve optimize edilmiş SQL üretmekle görevli, yüksek düzeyde
uzmanlaşmış bir ajandır. Erişim kontrol kuralları ve şema tanımları ile
yönlendirilecektir; bu, hassasiyetin ve mantıksal doğruluğun çok önemli olduğu bir
görevdir.
● Kalite Güvence ve Test Ajanı: Bu ajan, geri besleme döngüsünü kapatmak için
kritik öneme sahiptir. Uzmanlığı, birim testleri, entegrasyon testleri oluşturmak ve
test başarısızlık raporlarını (yığın izleri, hata mesajları) analiz ederek eyleme
geçirilebilir geri bildirim sağlamaktır. Test ve düzeltmeye doğası gereği odaklanan
Qwen gibi bir model, bu rol için güçlü bir adaydır.
1
3.2. Orkestrasyon Katmanının Tasarımı: "Yapay Zeka Teknik Lideri"
GPT-4 veya Claude gibi güçlü bir muhakeme modelinden güç alan merkezi bir
"Orkestratör", Kod Üretim Fabrikası'nın "Yapay Zeka Teknik Lideri" olarak görev
yapacaktır.
1
Temel Sorumlulukları:
1. Görev Ayrıştırma: "Çevrimdışı destekli kullanıcı girişi uygula" gibi üst düzey bir
özellik talebini alacak ve projenin Özellik Odaklı (Feature-First) mimarisine
referansla
2
, bunu uzman ajanlar için bir dizi somut alt göreve ayıracaktır.
2. İş Akışı Yönetimi: Görevler arasındaki karmaşık bağımlılıkları yönetecek, örneğin
Supabase tablosu ve RLS politikalarının, onlara dayanan FastAPI uç noktasından
önce oluşturulmasını sağlayacaktır.
3. Bağlam Yayılımı: Bir ajanın çıktılarının (örneğin, FastAPI ajanından gelen API uç
noktası URL'si) doğru şekilde biçimlendirilmesini ve başka bir ajana (örneğin,
API'yi çağırması gereken Flutter UI ajanı) bağlam olarak aktarılmasını
sağlayacaktır.
4. Sentez ve Birleştirme: Son olarak, tüm ajanlardan gelen kod eserlerini, projenin
tanımlanmış Özellik Odaklı yapısına göre doğru dizinlere yerleştirerek tutarlı ve
işlevsel bir özellik halinde birleştirecektir.
Bu karmaşık orkestrasyon, LangChain gibi yerleşik çerçeveler veya bu tür çok adımlı,
araç kullanan yapay zeka iş akışlarını oluşturmak için özel olarak tasarlanmış
smol-agents veya OpenHands gibi daha modern ajan çerçeveleri kullanılarak
uygulanabilir.
1
3.3. Aura Geliştiricisinin Gelişen Rolü: Kod Yazıcıdan Mimara
Bu yeni paradigma, geliştiricinin rolünü temelden yeniden tanımlar. Rol, satır satır kod
yazmaktan, yapay zeka Kod Üretim Fabrikası'nın kendisini tasarlamaya, denetlemeye
ve iyileştirmeye doğru kayar.
1
Geliştiricinin Yeni Temel Sorumlulukları:
● Sistem Tasarımcısı: Üst düzey uygulama mimarisini ve yapay zekanın
uygulayacağı karmaşık özellikler için "tarifleri" tanımlamak.
● Prompt ve Akış Mühendisi: Yapay zeka ajanlarını yönlendiren üst düzey istemleri
ve çok adımlı iş akışlarını oluşturmak ve iyileştirmek.
● Döngüdeki Doğrulayıcı: Yapay zekanın çıktısını incelik, iş mantığı doğruluğu ve
mimari tutarlılık açısından eleştirel bir şekilde inceleyerek, sistemin kendi başına
üretemeyeceği kritik insan geri bildirimini sağlayan son kalite kapısı olarak hareket
etmek.
● Uzman Hata Ayıklayıcı: Otomatik geri besleme döngüleri doğru bir çözüme
ulaşamadığında karmaşık veya yeni sorunları çözmek için müdahale etmek.
Tablo 1: Aura Projesi için LLM Uzmanlık Matrisi
Bu tablo, geliştirme ekibi ve Yapay Zeka Orkestratörü için verimliliği ve çıktı kalitesini en
üst düzeye çıkarmak amacıyla hangi görev için hangi yapay zeka modelinin kullanılması
gerektiğini gösteren, bir bakışta anlaşılır ve net bir referans görevi görecektir. Bu,
"Bileşik Yapay Zeka Sistemleri" stratejisinin operasyonel planıdır. Farklı LLM'lerin farklı
görevlerde belirgin ve özelleşmiş güçlere sahip olduğu açıktır.
1 Tek bir genel amaçlı
modele güvenmek yerine, Aura geliştirme iş akışındaki belirli görevleri, o görev için en
uygun LLM ile resmi olarak eşleştiren stratejik bir "iş bölümü" gereklidir. Sağlanan
araştırma, model yeteneklerinin net bir dökümünü sunar: Claude, geniş bağlam
penceresi ve UI üretimi ile öne çıkar; GPT-4o, mantık ve algoritmalarda üstündür;
Gemini, gerçek zamanlı web erişimi gerektiren görevler için en iyisidir; ve Qwen, test ve
hata ayıklamaya güçlü bir şekilde odaklanmıştır.
1 Bu bilgiyi resmi bir matriste
sentezleyerek, Orkestrasyon Katmanına programlanabilecek ve insan geliştiriciler
tarafından bilinçli kararlar almak için kullanılabilecek eyleme geçirilebilir bir kılavuz
oluşturulur.
Alan/Görev Önerilen LLM(ler) Gerekçe (Kanıtlarla)
UI/UX Üretimi (Flutter) Claude 3 Opus/Sonnet Detaylı, yaratıcı UI/ön uç
görevlerinde öne çıkar ve
devasa bağlam penceresi
içinde tüm proje dosyalarını
işleyebilir, bu da onu bağlama
duyarlı UI üretimi için ideal
kılar.
1
Arka Uç Mantığı ve
Algoritmalar (FastAPI)
GPT-4o, Qwen3-Coder Güçlü mantıksal ve algoritmik
akıl yürütme yeteneklerine
sahiptir. Qwen, özellikle uzun,
çok adımlı görevler için
tasarlanmıştır ve test ve hata
ayıklamaya yerleşik bir
odaklanmaya sahiptir.
1
Güvenlik Politikası Üretimi
(Supabase RLS)
GPT-4o Bu görev, GPT-4o'nun temel
bir gücü olan yüksek
hassasiyet ve katı mantıksal
doğruluk gerektirir.
Yaratıcılıktan çok kuralların
titizlikle uygulanmasıyla
ilgilidir.
1
Test Üretimi ve Analizi Qwen3-Coder, GPT-4 Qwen, test ve düzeltmeye açık
bir odaklanmaya sahiptir.
GPT-4, yığın izleri ve
günlüklerden hataları teşhis
etmede olağanüstü iyidir, bu
da onu "eleştiri" aşaması için
ideal kılar.
1
Üst Düzey Orkestrasyon ve
Planlama
GPT-4, Claude 3 Opus Bu rol, üstün soyut akıl
yürütme ve genellikle belirsiz
olan karmaşık insan
gereksinimlerini anlama ve
somut adımlara ayırma
yeteneği gerektirir.
1
Bölüm 4: Aura Teknoloji Yığını için Alana Özgü Prompt
Mühendisliği
Bu bölüm, üst düzey stratejiden taktiksel bir oyun kitabına geçiş yapar. Kapsamlı web
araştırması parçacıklarında belirlenen en iyi uygulamaları sentezleyerek, Aura'nın belirli
teknolojilerine göre uyarlanmış somut, eyleme geçirilebilir prompt stratejileri sunar.
4.1. Riverpod ile Yüksek Performanslı ve Sürdürülebilir Flutter UI Üretimi
LLM'ler, geniş ve çeşitli bir genel kod külliyatı üzerinde eğitildikleri için, Riverpod
sağlayıcıları arasında sıkı bir bağ oluşturmak veya geçici UI durumu için sağlayıcıları
yanlış kullanmak gibi yaygın ancak zararlı anti-desenleri kolayca üretebilirler.
3 Strateji,
sadece ne yapılacağını değil, daha da önemlisi ne yapılmayacağını belirten "mimari
korkuluklar" olarak işlev gören "Tarif" ve "Şablon" istemlerini kullanmaktır. Bu istemler,
en iyi uygulamaları doğrudan üretim talebine yerleştirir. Bu bağlamda istemin birincil
işlevi sadece kod talep etmek değil, aynı zamanda
kötü kodu önlemektir. Araştırmada
3 belirlenen yaygın tuzaklar, isteme dahil edilmesi
gereken negatif kısıtlamaların bir kontrol listesi haline gelir. Örneğin, Riverpod güçlü
olmasına rağmen,
ref.watch'ı bir sağlayıcının build metodu içinde kullanmak gibi ince tuzakları vardır ve
bu sıkı bir bağ oluşturur.
4 Genel amaçlı bir LLM, bu deseni çevrimiçi örneklerde
gördüğü için muhtemelen yeniden üretecektir. Bu durumu, açıkça "YAPMA" talimatları
ekleyerek ve istemin içine bir "iyi uygulama" şablonu sağlayarak proaktif bir şekilde
önleyebiliriz. Böylece istem, LLM'i yaygın hatalardan aktif olarak uzaklaştıran ve
projenin istenen, yüksek kaliteli mimari desenlerine yönlendiren bir "korkuluk" formuna
dönüşür.
Riverpod için "Korkuluk" Prompt Örneği:
Kod snippet'i
# Persona
Riverpod 2.0 kullanarak performanslı ve sürdürülebilir uygulamalar konusunda
uzmanlaşmış bir Kıdemli Flutter Geliştiricisi olarak hareket et.
# Görev
Bir `ProductRepository`'den ürün listesi getiren bir `ProductListNotifier` için kod üret.
# Tarif ve Kısıtlamalar (Korkuluklar)
1. `AsyncNotifier` desenini kullan. `StateNotifier` veya `ChangeNotifierProvider` gibi
eski sağlayıcıları KESİNLİKLE kullanmamalısın. [3, 6]
2. `build` metodu, başlangıç verilerini getirmekten sorumlu olmalıdır.
3. Duruma yeni bir ürün ekleyen `addProduct(newProduct)` adında bir genel metot
sağla.
4. **KRİTİK MİMARİ KISITLAMA:** Gevşek bağlılığı sağlamak için, `ProductRepository`
bağımlılığı, Notifier'ın metotları içinde `ref.read(productRepositoryProvider)`
kullanılarak alınmalıdır, `build` metodunda `ref.watch` ile DEĞİL. [4]
5. UI, performans için `ref.watch(productNotifierProvider.select((state) =>
state.value.products))` kullanacaktır. Üretilen koda, bu `select` optimizasyonunun
gereksiz widget yeniden oluşturmalarını nasıl önlediğini açıklayan bir yorum
KESİNLİKLE eklemelisin. [7]
6. Notifier dosyası, projemizin Özellik Odaklı mimarisine uygun olarak
`lib/features/products/application/` dizinine yerleştirilmelidir. [2]
# Çıktı Şablonu
Gerekli tüm importları ve kritik mimari kararlar için açıklayıcı yorumları içeren
`product_list_notifier.dart` adlı tam Dart dosyasını sağla.
4.2. Güvenli ve Sağlam FastAPI Uç Noktaları Oluşturma
LLM'ler, işlevsel olarak doğru ancak güvensiz olan veya hataları kötü bir şekilde
yöneterek dahili ayrıntıları açığa çıkaran kodlar üretebilir.
8 Strateji, her API uç noktası
için standart, varsayılan olarak güvenli bir yapıyı zorunlu kılan bir "Şablon" istemi
kullanmaktır.
FastAPI için "Güvenli Şablon" Prompt Örneği:
Kod snippet'i
# Persona
API güvenliği ve sağlam, üretim sınıfı hata yönetimi konularında derin bir odaklanmaya
sahip bir FastAPI uzmanı olarak hareket et.
# Görev
Bir kullanıcının profil bilgilerini güncellemek için bir FastAPI uç noktası üret.
# Şablon ve Gereksinimler
`PUT /users/me` uç noktası için aşağıdaki güvenli yapıya sıkı sıkıya bağlı bir Python
fonksiyonu oluştur:
1. **Bağımlılıklar:** Mevcut kimliği doğrulanmış kullanıcı nesnesini ve veritabanı
oturumunu almak için FastAPI'nin Bağımlılık Enjeksiyonu sistemini kullan. [8]
2. **Giriş Doğrulaması:** İstek gövdesini doğrulamak için `UserProfileUpdate` adında
bir Pydantic modeli kullan.
3. **İş Mantığı:** Veritabanındaki kullanıcı modelini güncellemek için temel mantığı bu
bölüme yerleştir.
4. **Hata Yönetimi:** Tüm mantık bloğu KESİNLİKLE bir `try...except` bloğu içine
alınmalıdır.
- Belirli iş mantığı istisnalarını yakalamalı ve uygun bir 4xx durum kodu ve kullanıcı
dostu bir detay mesajı ile bir `fastapi.HTTPException` yükseltmelisin. [9, 10]
- Ham veritabanı hatalarının veya diğer beklenmedik istisnaların istemciye
döndürülmesine KESİNLİKLE izin vermemelisin. Bunları hata ayıklama için günlüğe
kaydet ve genel bir 500 Dahili Sunucu Hatası döndür.
5. **Yanıt Modeli:** Başarılı yanıtın yapısını tanımlamak için `UserProfileResponse`
adında bir Pydantic modeli kullan.
# Çıktı
Uç nokta için tam, üretime hazır Python kodunu sağla.
4.3. RLS Politikası Üretimi ile Supabase Güvenliğini Otomatikleştirme
LLM'lerin, Supabase'de sorgu planlamasını iyileştirmek için auth.uid()'yi bir select
ifadesi içine sarmak gibi bariz olmayan, platforma özgü performans
optimizasyonlarından haberdar olmaları pek olası değildir.
11 Strateji, iki adımlı bir RCI
(Gözden Geçir-Eleştir-İyileştir) akışıdır. İlk adım, doğruluk için politikayı üretir ve ikinci
adım, performans optimizasyonu için bir inceleme ister. Doğruluk ve performans
endişelerini iki ayrı yapay zeka güdümlü adıma ayırarak, her aşamada LLM için görevi
basitleştiririz, bu da daha güvenilir ve optimize edilmiş bir nihai sonuca yol açar. Bu,
Bileşik Yapay Zeka Sistemleri ilkesinin mikro bir uygulamasıdır. Mantık şöyledir: doğru
bir RLS politikası oluşturmak bir bilişsel görevdir.
Performanslı bir RLS politikası oluşturmak ise, bariz olmayan bir sözdizimi içeren ayrı,
daha özel bir görevdir.
11 Bir LLM'den her iki görevi aynı anda yapmasını istemek,
karmaşıklığı ve başarısızlık olasılığını artırır. İki adımlı bir süreç daha sağlamdır. Adım 1:
"X erişim kuralını doğru bir şekilde uygulayan bir politika oluştur." Adım 2: "Şimdi, bu
doğru politikayı al ve
auth.uid()'yi sarmak ve dizinler önermek gibi Supabase'e özgü performans
optimizasyonlarını uygula." Bu yaklaşım, problemi parçalara ayırır, LLM'i önce temel
üretim için, sonra da bu modellerin bilinen bir gücü olan desen tabanlı bir dönüşüm
için kullanır.
İki Adımlı RLS Akış Örneği:
● Prompt 1 (Doğruluk): 'documents' tablosu için bir Supabase RLS politikası
oluştur. Politika, bir kullanıcının yalnızca 'auth.uid()'den alınan kimliğinin 'owner_id'
sütunundaki değerle eşleştiği satırları SEÇMESİNE izin vermelidir.
● Prompt 2 (Performans Eleştirisi ve İyileştirme): Aşağıdaki RLS politikasını
incele. 'auth.uid()' çağrılarını bir '(select auth.uid())' alt sorgusu içine sararak
Supabase performans en iyi uygulamalarını uygula. Bu, sorgu planlayıcı
önbelleklemesini etkinleştirmek için gereklidir. Tamamen optimize edilmiş SQL
kodunu sağla.
4.4. Dirençli bir Çevrimdışı Öncelikli Strateji Uygulama
Tam bir çevrimdışı öncelikli (offline-first) uygulama, tek bir fonksiyon değil, karmaşık
bir dağıtık sistemdir. Yerel bir veritabanı, bir uzak API istemcisi, başarısız istekler için bir
kuyruk ve bir senkronizasyon motoru gerektirir.
12 Strateji, yapay zekayı sistemin her bir
gerekli bileşeninin mantıksal bir sıra içinde üretilmesi için yönlendiren bir "Akış
Mühendisliği" yaklaşımı kullanmaktır.
Çok Adımlı Çevrimdışı Öncelikli Akış Örneği:
1. Prompt 1 (Yerel Model): Flutter için Isar veritabanı paketini kullanarak,
'QueuedRequest' adında bir @Collection sınıfı oluştur. Bu sınıf, başarısız API
çağrılarını saklamak için kullanılacaktır. 'url' (String), 'method' (String), 'payload'
(String), 'headers' (String), 'timestamp' (DateTime) ve 'retry_count' (int) alanlarını
içermelidir.
14
2. Prompt 2 (Depo Mantığı): 'SyncRepository' adında bir Dart sınıfı oluştur.
'makeRequest(url, method, payload)' adında bir asenkron metot oluştur. Bu metot,
önce isteği bir uzak API istemcisi kullanarak göndermeyi denemelidir. Ağla ilgili bir
hata nedeniyle başarısız olursa, istek ayrıntılarını daha sonra işlenmek üzere
'QueuedRequest' Isar koleksiyonuna kaydetmelidir.
12
3. Prompt 3 (Arka Plan Çalışanı): 'workmanager' paketini kullanarak, periyodik bir
arka plan görevi tanımlamak ve zamanlamak için gerekli kodu oluştur. Bu görev,
'QueuedRequest' Isar koleksiyonunu sorgulamalı, kuyruktaki her isteği yeniden
göndermeyi denemeli ve yalnızca başarılı bir iletim üzerine girişi koleksiyondan
silmelidir.
16
4. Prompt 4 (Çakışma Çözümü Taslağı): 'SyncRepository' içinde, 'Future<void>
resolveConflict(Map<String, dynamic> localData, Map<String, dynamic>
remoteData)' adında bir taslak fonksiyon oluştur. Bu fonksiyonun, bir insan
geliştiricinin projenin belirli iş mantığını (örneğin, Son Yazılan Kazanır, birleştirme
veya kullanıcıya sorma) uygulaması gereken bir yer tutucu olduğunu açıklayan
ayrıntılı bir yorum ekle.
18
Bölüm 5: Sürekli Öğrenme ve Adaptasyon Mekanizması
Bu bölüm, Yapay Zeka Kod Üretim Fabrikası'nın çıktılarından öğrenmesini ve zamanla
kendi süreçlerini iyileştirmesini sağlayan bir meta-sistem tasarımını
detaylandırmaktadır.
5.1. Bir Öğrenme Döngüsünün Anatomisi: İçgörü için Günlük Kaydı
Üretim sürecinin her adımı—ilk istem, üretilen kod, üretilen testler, bu testlerin
sonuçları, performans metrikleri ve herhangi bir insan geri bildirimi—yapılandırılmış bir
veritabanına (örneğin, bir vektör veritabanı veya JSON alanlarına sahip bir ilişkisel
veritabanı) kaydedilir.
Yakalanacak Anahtar Veri Noktaları:
● session_id: Tüm üretim iş akışı için benzersiz bir kimlik.
● step_id: Akış içindeki her adım için bir kimlik (örneğin, initial_generation,
test_generation, security_critique, fix_iteration_1).
● prompt_template_id: Kullanılan istem şablonunun tanımlayıcısı.
● input_variables: İstem şablonuna sağlanan belirli girdiler.
● llm_model_used: Kullanılan belirli model (örneğin, gpt-4o-2024-05-13).
● generated_output: LLM tarafından üretilen tam kod veya metin.
● validation_result: Otomatik testlerden net bir Başarılı/Başarısız durumu.
● validation_details: Hata mesajları, güvenlik açığı raporları veya performans sayıları
gibi doğrulayıcılardan gelen ham çıktı.
● human_feedback_score: Bir insan kodu incelerse basit bir derecelendirme
(örneğin, 1-5) ve nitel notlar.
● final_outcome: Oturum için Başarılı, Başarısız veya İnsanMüdahalesiGerektirir gibi
nihai bir durum.
5.2. Analizden Otomatik Optimizasyona
Yapılandırılmış günlük verileri, meta-optimizasyon için değerli bir varlıktır. Bu verileri
sistematik olarak analiz ederek, sistem tekil kod hatalarını düzeltmenin ötesine geçerek
zamanla tüm üretim sürecini iyileştirebilir. Mantık şöyledir: Başlangıçtaki yapay zeka iş
akışı, insanlar tarafından tasarlanan bir dizi statik kural ve isteme dayanır ve bunlar
muhtemelen en uygun düzeyde değildir. Farklı istemlerin, modellerin ve iş akışlarının
tarihsel performansını nesnel sonuçlara (test sonuçları) karşı analiz ederek, hangi
stratejilerin en etkili olduğunu ampirik olarak belirleyebiliriz. Periyodik bir analiz işi,
istatistiksel olarak anlamlı korelasyonları bulmak için günlük veritabanı üzerinde çalışır.
Örneğin: "'Kıdemli Güvenlik Mimarı' personası, FastAPI uç noktalarında 'Kıdemli
Geliştirici' personasına kıyasla istatistiksel olarak anlamlı derecede daha düşük bir
güvenlik açığı oranına yol açıyor mu?" veya "Riverpod notifier'ları için hangi istem
şablonu en yüksek ilk geçiş başarı oranına sahip?" Sistem, bu veriye dayalı bulguları
kendi yapılandırmasını otomatik olarak güncellemek için kullanır. Bu, bir tür
meta-öğrenme veya otomatik süreç optimizasyonudur.
Otomatik Adaptasyon Mekanizmaları:
● İstem Şablonu A/B Testi ve Yükseltme: Sistem, istem şablonlarının
varyasyonlarını otomatik olarak test edebilir ve en yüksek başarı oranına sahip
olanı belirli bir görev için yeni varsayılan olarak yükseltebilir.
● Dinamik LLM Yönlendirme: Gerçek dünya performans verilerine dayanarak,
Orkestratör belirli alt görevleri en iyi performans gösteren LLM'e yönlendirmeyi
öğrenebilir, böylece dinamik, kendi kendini optimize eden bir "Bileşik Yapay Zeka
Sistemi" oluşturur.
● Başarısızlık Deseni Tanıma: Sistem, tekrarlayan başarısızlık desenlerini (örneğin,
Flutter'da belirli bir tür null güvenlik hatası) tanımlayabilir ve gelecekte bu hatayı
açıkça kontrol etmek için ilgili iş akışına otomatik olarak yeni bir "korkuluk" veya
belirli bir RCI adımı ekleyebilir.
5.3. Döngüyü Kapatmak: Kendi Kendini İyileştirme Üzerine Bir Vaka Çalışması
Bu alt bölüm, tüm öğrenme döngüsünü adım adım gösteren bir örnek sunacaktır.
1. Olay: FastAPI ajanı, SQL Enjeksiyonuna karşı savunmasız bir uç nokta üretir.
2. Tespit: Geri besleme döngüsüne entegre edilmiş otomatik SAST aracı, güvenlik
açığını tespit eder ve derlemeyi başarısız kılar. Başarısızlık, savunmasız kod ve onu
üreten istem, hepsi günlüğe kaydedilir.
3. Düzeltme: RCI döngüsü tetiklenir. LLM'e güvenlik açığı raporu beslenir, kendi
kodunu bir sorguda dize biçimlendirme kullandığı için eleştirir ve parametreli
sorgular kullanarak düzeltilmiş bir sürüm üretir. Düzeltme testi geçer. Bu başarılı
etkileşimin tamamı da günlüğe kaydedilir.
4. Analiz (Daha Sonra): Periyodik analiz işi, "veritabanı erişimi" ile ilgili istemlerin
%15 oranında SQLi güvenlik açıkları ürettiğini tespit eder.
5. Adaptasyon: Sistem, tüm FastAPI veritabanı ile ilgili görevler için varsayılan
"Şablon" istemini otomatik olarak güncelleyerek yeni ve açık bir talimat ekler:
**KRİTİK GÜVENLİK GEREKSİNİMİ:** Tüm veritabanı sorguları, SQL Enjeksiyonu
güvenlik açıklarını önlemek için parametreli ifadeler veya bir ORM
KULLANMALIDIR. Yanıtınızda güvenli bir sorgu örneği sağlayın.
6. Sonuç: Gelecekte üretilen tüm veritabanı kodlarının temel kalitesi ve güvenliği
kalıcı olarak iyileştirilir. Bu özel başarısızlığın tekrarlanma olasılığı büyük ölçüde
azalır. Sistem, hatasından ders çıkarmış ve kendi sürecini güçlendirmiştir.
Tablo 2: NFR Test Odaklı Geri Besleme Döngüsü Çerçevesi
Bu tablo, İşlevsel Olmayan Gereksinimlerin (NFR) test edilmesini doğrudan
otomatikleştirilmiş yapay zeka iş akışına entegre etmek için somut, operasyonel bir
çerçeve sağlamayı amaçlamaktadır. Performans ve güvenlik gibi NFR'ler genellikle
basit kod üretiminde göz ardı edilir. Etkili olabilmeleri için sistematik ve otomatik olarak
test edilmeleri gerekir. Bu nedenle, neyin test edileceğini, nasıl test edileceğini ve test
sonuçlarının LLM'in anlayabileceği ve üzerinde hareket edebileceği bir formata nasıl
çevrileceğini kesin olarak tanımlamamız gerekir. Yapılandırılmış bir tablo, bu süreci hem
geliştirme ekibi için hem de yapay zeka iş akışının mantığını programlamak için
belgelemenin en açık yoludur.
NFR Kategorisi Anahtar Metrik /
Hedef
Test Aracı / Yöntemi LLM için Örnek Geri
Bildirim İstemcisi
Güvenlik SAST taramasında
sıfır Yüksek/Kritik
güvenlik açığı
SonarQube, Snyk
veya benzeri SAST
aracı
Snyk taraması,
üretilen HTML
şablonunda bir
'Siteler Arası Komut
Dosyası Çalıştırma
(XSS)' güvenlik açığı
bildirdi. Sağlanan
kodu analiz et,
güvenlik açığının
temel nedenini açıkla
ve uygun çıktı
kodlaması/temizleme
si kullanan düzeltilmiş
bir sürüm üret.
1
Performans (API) Yük altında p95 yanıt
süresi < 150ms
k6, Locust (Otomatik
Yük Testi)
Yük testi, bu uç
noktanın p95 yanıt
süresinin 500
eşzamanlı kullanıcı
altında 800ms
olduğunu gösteriyor
ve 150ms hedefimizi
karşılıyor. Performans
darboğazı veritabanı
sorgusunda
görünüyor. Sorguyu
ve şemayı analiz et ve
performans için
optimize et.
1
Performans (Flutter
UI)
Kare oluşturma süresi
sürekli < 16ms (60fps)
Flutter DevTools
(Performans
Profilcisi)
Performans profilcisi,
aşırı widget yeniden
oluşturmalarının kare
düşüşlerine neden
olduğunu gösteriyor.
Sorun, build
metodunda tüm bir
User nesnesini
izlemekten
kaynaklanıyor. Kodu,
yalnızca 'userName'
alanını dinlemek için
'ref.watch(provider.sel
ect(...))' kullanacak
şekilde yeniden
düzenle.
7
Kod
Sürdürülebilirliği
Döngüsel Karmaşıklık
< 10; Kod Tekrarı < %3
Statik analiz araçları
(ör. Pylint, Dart
Analyzer)
Statik analiz,
'process_order'
fonksiyonu için 15'lik
bir döngüsel
karmaşıklık bildiriyor.
Bu, proje
standardımızı ihlal
ediyor. Okunabilirliği
ve sürdürülebilirliği
artırmak için bu
fonksiyonu daha
küçük, daha
yönetilebilir özel
metotlara yeniden
düzenle.
Bölüm 6: Stratejik Öneriler ve Uygulama Yol Haritası
Bu son bölüm, Aura proje ekibinin bu gelişmiş yapay zeka güdümlü geliştirme
paradigmasını benimsemesi için net, aşamalı bir uygulama planı sunmaktadır.
6.1. Aşama 1: Temel İyileştirmeler (0-3 Ay)
● Eylemler:
○ Yaygın görevler için standartlaştırılmış "Korkuluk" istem şablonlarının (Bölüm
4'te tanımlandığı gibi) merkezi, sürüm kontrollü bir kütüphanesini oluşturun.
○ Geri besleme döngüsünün ilk katmanını entegre edin: mevcut CI/CD boru hattı
içinde tüm yapay zeka tarafından üretilen kod için kod yürütme ve birim testini
otomatikleştirin.
○ Geliştirme ekibi için gelişmiş prompt mühendisliği ilkeleri (Persona, Tarif,
Şablon, RCI) üzerine zorunlu eğitim düzenleyin.
● Başarı Metrikleri: İlk yapay zeka tarafından üretilen kodda önemsiz hatalarda ve
mimari anti-desenlerde ölçülebilir bir azalma; tüm yeni yapay zeka tarafından
üretilen fonksiyonların %80'inden fazlasının, otomatik olarak çalıştırılan yapay zeka
tarafından üretilen birim testleriyle birlikte gelmesi.
6.2. Aşama 2: Yapay Zeka Kod Üretim Fabrikasını İnşa Etme (3-9 Ay)
● Eylemler:
○ LangChain gibi bir çerçeve veya özel bir çözüm kullanarak çekirdek
Orkestrasyon Katmanını geliştirin.
○ Uzmanlaşmış yapay zeka ajanlarını (Flutter, FastAPI, Supabase, KG)
orkestrasyon çerçevesi içinde ayrı, çağrılabilir hizmetler veya modüller olarak
uygulayın.
○ NFR test araçlarını (SAST, performans testi) otomatik geri besleme döngüsüne
entegre edin, böylece başarısızlıklar RCI sürecini tetikleyebilir.
● Başarı Metrikleri: Tek bir üst düzey komut aracılığıyla basit ama eksiksiz bir
özelliğin (örneğin, UI, arka uç ve güvenliğe sahip bir "Yapılacaklar" listesi) uçtan
uca üretimini gösterme; üretilen kodda bir güvenlik açığının ilk otomatik tespitini ve
işaretlenmesini başarma.
6.3. Aşama 3: Öğrenme Mekanizmasını Etkinleştirme (9+ Ay)
● Eylemler:
○ Bölüm 5.1'de tanımlandığı gibi tüm iş akışı verilerini yakalamak için
yapılandırılmış günlük veritabanını uygulayın.
○ İstem şablonlarını ve LLM yönlendirmesini iyileştiren periyodik analiz ve
otomatik adaptasyon işlerini geliştirin ve dağıtın.
○ İnsan geliştiricilerin yapay zekanın performansını gözden geçirmesi ve
yapılandırılmış geri bildirim sağlaması için resmi bir süreç oluşturun; bu geri
bildirim daha sonra öğrenme sistemi tarafından alınır.
● Başarı Metrikleri: 3 aylık bir süre boyunca kod üretiminin ilk geçiş başarı oranında
kanıtlanabilir, veriye dayalı bir iyileşme; sistemin, tarihsel performans verilerinin
analizine dayanarak en az bir çekirdek istem şablonunu otomatik olarak
iyileştirmesi.
Tablo 3: Aşamalı Uygulama Yol Haritası
Bu tablo, üst düzey stratejiyi net aşamalar, görevler ve ölçülebilir sonuçlarla somut,
eyleme geçirilebilir bir proje planına dönüştürmeyi amaçlamaktadır. Aura proje liderliği
için ileriye dönük net bir yol sunar.
Aşama Anahtar Görevler Sorumlu Roller Başarı Metrikleri
Aşama 1: Temel
İyileştirmeler (0-3
1. Merkezi "Korkuluk"
prompt kütüphanesi
AI/ML Ekibi, DevOps,
Geliştirme Liderleri
- İlk kodda trivial
hatalarda %50
Ay) oluşturma. 2.
CI/CD'ye otomatik
birim testi
entegrasyonu. 3.
Geliştirici ekibine
prompt mühendisliği
eğitimi.
azalma. - AI üretimi
fonksiyonların >%80'i
test kapsamına sahip.
Aşama 2: AI
Kod-Üretim
Fabrikası (3-9 Ay)
1. Orkestrasyon
Katmanını geliştirme
(LangChain vb.). 2.
Uzmanlaşmış AI
ajanlarını (Flutter,
FastAPI, Supabase)
uygulama. 3. NFR
testlerini (SAST, yük
testi) geri besleme
döngüsüne entegre
etme.
AI/ML Ekibi, Kıdemli
Geliştiriciler, Güvenlik
Ekibi
- Basit bir özelliğin
(UI, backend,
güvenlik) tek komutla
uçtan uca üretimi. -
İlk otomatik güvenlik
açığı tespiti ve RCI ile
düzeltilmesi.
Aşama 3: Öğrenme
Mekanizması (9+
Ay)
1. Yapılandırılmış
günlük veritabanını
kurma. 2. Otomatik
analiz ve adaptasyon
işlerini dağıtma. 3.
İnsan geri bildirim
döngüsü için resmi
bir süreç oluşturma.
AI/ML Ekibi, Veri
Analistleri, Geliştirme
Liderleri
- Kod üretiminin ilk
geçiş başarı oranında
3 ayda %20 artış. -
Sistemin en az bir
temel prompt
şablonunu otomatik
olarak iyileştirmesi.
Alıntılanan çalışmalar
1. Üst Düzey Yapay Zeka Promptu Hazırlama Rehberi_.pdf
2. Mastering Flutter Architecture: From CLEAN to Feature-First for Faster, Scalable
Development - DEV Community, erişim tarihi Temmuz 31, 2025,
https://dev.to/princetomarappdev/mastering-flutter-architecture-from-clean-to-f
eature-first-for-faster-scalable-development-4605
3. What NOT to do with Riverpod ? : r/FlutterDev - Reddit, erişim tarihi Temmuz 31,
2025,
https://www.reddit.com/r/FlutterDev/comments/1ktnx1d/what_not_to_do_with_riv
erpod/
4. Riverpod's Flaws: A Critical Perspective - Michael Lazebny, erişim tarihi Temmuz
31, 2025, https://lazebny.io/riverpod/
5. DO/DON'T | Riverpod, erişim tarihi Temmuz 31, 2025,
https://riverpod.dev/docs/essentials/do_dont
6. Best Practices for Riverpod Providers: What's the Optimal Approach? :
r/FlutterDev - Reddit, erişim tarihi Temmuz 31, 2025,
https://www.reddit.com/r/FlutterDev/comments/1fry8ah/best_practices_for_riverp
od_providers_whats_the/
7. Optimizing performance - Riverpod, erişim tarihi Temmuz 31, 2025,
https://riverpod.dev/docs/advanced/select
8. 10 Common Mistakes to Avoid When Using FastAPI to Build Python ..., erişim tarihi
Temmuz 31, 2025,
https://academicnesthub.weebly.com/blog/10-common-mistakes-to-avoid-when
-using-fastapi-to-build-python-web-apis
9. Handling Errors - FastAPI, erişim tarihi Temmuz 31, 2025,
https://fastapi.tiangolo.com/tutorial/handling-errors/
10. FastAPI: Mastering Error Handling with Examples - Orchestra, erişim tarihi
Temmuz 31, 2025,
https://www.getorchestra.io/guides/fastapi-mastering-error-handling-with-exam
ples
11. Troubleshooting | RLS Performance and Best ... - Supabase Docs, erişim tarihi
Temmuz 31, 2025,
https://supabase.com/docs/guides/troubleshooting/rls-performance-and-best-pr
actices-Z5Jjwv
12. Offline-first app: How bad is it to build one | by Felipe Emídio | Medium, erişim
tarihi Temmuz 31, 2025,
https://felipeemidio.medium.com/offline-first-app-how-bad-is-it-to-build-one-e
ce1ffff4777
13. Offline-first support - Flutter Documentation, erişim tarihi Temmuz 31, 2025,
https://docs.flutter.dev/app-architecture/design-patterns/offline-first
14. A Practical Guide to Using Isar Database in Your Flutter App - DhiWise, erişim
tarihi Temmuz 31, 2025,
https://www.dhiwise.com/post/isar-database-flutter-guide
15. Build Offline-First Flutter Apps with Hive and Isar | by Dhruv Manavadaria -
Medium, erişim tarihi Temmuz 31, 2025,
https://medium.com/@dhruvmanavadaria/build-offline-first-flutter-apps-with-hiv
e-and-isar-d5d2a5fd9d74
16. Handling Background Tasks with WorkManager in Flutter - Vibe Studio, erişim
tarihi Temmuz 31, 2025,
https://vibe-studio.ai/in/insights/handling-background-tasks-with-workmanager
17. fluttercommunity/flutter_workmanager: A Flutter plugin which allows you to
execute code in the background on Android and iOS. - GitHub, erişim tarihi
Temmuz 31, 2025, https://github.com/fluttercommunity/flutter_workmanager
18. Offline First Approach With Flutter | by Punith S Uppar - Medium, erişim tarihi
Temmuz 31, 2025,
https://medium.com/@punithsuppar7795/offline-first-approach-with-flutter-346
8906eb01a
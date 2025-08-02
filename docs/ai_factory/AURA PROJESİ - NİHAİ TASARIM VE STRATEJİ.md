AURA PROJESİ - NİHAİ TASARIM VE STRATEJİ DÖKÜMANI (V3.0 - Tam Metin)
Giriş
Bu döküman, "Aura" projesinin başlangıçtaki 16 sayfalık teknik spesifikasyonuna ek olarak, yapılan ortak beyin fırtınaları sonucunda ortaya çıkan tüm yeni özellikleri, global iyileştirmeleri, mimari prensipleri ve kenar durumlarını içermektedir. Amacı, projenin geliştirme sürecine rehberlik edecek, eksiksiz ve en detaylı "tek kaynak" (single source of truth) olmaktır.
BÖLÜM 1: EKLENEN YENİ ÖZELLİKLER VE GLOBAL İYİLEŞTİRMELER
1. Global Arama
●	Sayfa Adı ve Amacı:
○	GlobalSearchScreen: Uygulamanın tamamında (kıyafetler, kombinler, sosyal gönderiler, kullanıcılar, takas ilanları) tek bir arayüzden arama yapılmasını sağlayan merkezi ekrandır. Amacı, uygulama içi gezinmeyi hızlandırmak ve içeriğin keşfedilebilirliğini artırmaktır.
●	Ana Bileşenler (Widget/Class Adları):
○	GlobalSearchScreen (ConsumerWidget)
○	GlobalSearchBar (Custom Widget - Debounced arama çubuğu)
○	SearchResultsTabView (Custom Widget - Sonuçları sekmelerle ayıran yapı)
○	ClothingSearchResultTile, CombinationSearchResultTile, SocialPostSearchResultTile, UserSearchResultTile (Custom Widget'lar)
○	RecentSearchesView (Custom Widget)
○	GlobalSearchController (Riverpod StateNotifier)
○	SearchRepository (Interface)
●	Veri Modeli & State Yönetimi:
○	GlobalSearchState: searchTerm, isLoading, error, clothingResults, combinationResults, postResults, userResults, recentSearches alanlarını içerir.
○	GlobalSearchController: search(term), clearSearch(), loadRecentSearches() gibi metotları barındırır.
●	Kullanıcı Akışı (Interaction Flow):
1.	Kullanıcı AppBar'daki arama ikonuna tıklar.
2.	GlobalSearchScreen açılır, klavye odaklanır ve geçmiş aramalar gösterilir.
3.	Kullanıcı yazmaya başlayınca (debounce ile) search() metodu tetiklenir.
4.	Yükleme durumu gösterilir.
5.	API'den gelen sonuçlar sekmeli bir yapıda (SearchResultsTabView) listelenir.
6.	Sonuca tıklandığında ilgili detay ekranına yönlendirilir.
●	API/Servis Çağrıları (Girdi/Çıktı):
○	SearchRepository -> ApiService: Future<Map<String, dynamic>> searchAll({String query, int limit}) metodu ile tek bir endpoint üzerinden tüm kategorilerde arama yapar.
●	UX Detayları & Kenar Durumlar:
○	Performans: Her arama sekmesi kendi içinde sonsuz kaydırma (infinite scroll) ile paginasyon yapmalıdır. Aramalar debounce ile tetiklenmelidir.
○	API Limiti: Sunucudan 429 Too Many Requests hatası alınırsa, kullanıcıya bir uyarı gösterilip kısa bir bekleme sonrası otomatik yeniden deneme yapılmalıdır.
○	Arama Zekası: Backend tarafında eş anlamlı kelime, kök bulma ve yazım hatası toleransı (fuzzy matching) özellikleri olmalıdır. Arama terimi sonuçlarda vurgulanmalıdır.
○	Yetki & Gizlilik: Arama sonuçları, kullanıcının erişim yetkilerine göre filtrelenmelidir. Özel içerikler listelenmemelidir.
○	Çevrimdışı Durum: İnternet yokken arama çubuğu pasif olmalı ve "İnternet bağlantısı gerekli" uyarısı gösterilmelidir.
○	Özel Karakter Desteği: Türkçe karakterler veya emojiler içeren aramalar, backend'de doğru şekilde işlenmelidir.
2. Ayarlar Ekranı Mimarisi
●	Sayfa Adı ve Amacı:
○	SettingsScreen, NotificationSettingsScreen, PrivacySettingsScreen, AccountSettingsScreen: Kullanıcının bildirimler, gizlilik, hesap güvenliği, veri kullanımı ve diğer uygulama tercihlerini yönettiği merkezi kontrol panelidir.
●	Ana Bileşenler (Widget/Class Adları):
○	SettingsScreen (Diğer ayar ekranlarına yönlendirme listesi)
○	NotificationSettingsScreen (ConsumerWidget)
○	PrivacySettingsScreen (ConsumerWidget)
○	AccountSettingsScreen (ConsumerWidget)
○	SettingsTile, SettingsSwitchTile (Custom Widget'lar)
○	UserProfileController, UserRepository (Mevcut)
●	Veri Modeli & State Yönetimi:
○	Mevcut User modelindeki settings alanı (Map<String, dynamic>) kullanılır.
○	UserProfileController: updateSetting(key, value), deleteAccount() gibi metotları içerir.
●	Kullanıcı Akışı (Interaction Flow):
1.	Kullanıcı UserProfileScreen'den "Ayarlar"a tıklar.
2.	SettingsScreen üzerinden ilgili kategoriye (örn: "Gizlilik") gider.
3.	PrivacySettingsScreen'de toggle'lar veya seçeneklerle ayarlarını değiştirir.
4.	Değişiklik, UserProfileController aracılığıyla anında UI'a yansır (optimistic update) ve arka planda sunucuya kaydedilir.
5.	Hesap silme gibi kritik işlemler için ek onay Dialog'u gösterilir.
●	API/Servis Çağrıları (Girdi/Çıktı):
○	UserRepository -> ApiService: updateUserSettings(Map settings) ve deleteUserAccount() metotları kullanılır.
●	UX Detayları & Kenar Durumlar:
○	Dayanıklılık: Bir ayar kaydedilemezse, sadece ilgili toggle eski haline dönmeli ve kullanıcı bilgilendirilmelidir (Partial Fail & Rollback).
○	Eş Zamanlı Güncelleme: Ayarlar başka bir cihazda güncellenirse, mevcut ekranda "Ayarlar güncellendi, yenileyin" uyarısı gösterilmelidir.
○	Oturum Yönetimi: Ayar güncellemesi sırasında token süresi dolarsa, silent refresh denenmeli, olmazsa kullanıcı Login ekranına yönlendirilmelidir.
○	Çevrimdışı Durum: Çevrimdışı iken tüm ayar kontrolleri pasif olmalı ve uyarı gösterilmelidir.
○	Veri Yönetimi: "Yalnızca Wi-Fi'da Görüntü İndir" ve "Önbelleği Temizle" gibi seçenekler sunulmalıdır.
○	Dil/Tema Değişikliği: Uygulama dil veya tema değişikliğini tüm ekranlarda anında ve performanslı bir şekilde yansıtmalıdır.
○	Schema Evolution: Uygulamanın eski versiyonları, yeni eklenen ayar alanları yüzünden hata almamalıdır; backend varsayılan değerler döndürmelidir.
3. Özellik Tanıtımı (Feature Onboarding)
●	Özellik Adı ve Amacı:
○	Feature Onboarding / Coach Marks: Belirli ekranlara entegre edilen, kullanıcı karmaşık bir özelliği ilk kez ziyaret ettiğinde arayüz elemanlarını vurgulayarak onu eğiten bir özelliktir.
●	Ana Bileşenler (Widget/Class Adları):
○	showcaseview gibi bir 3. parti paket.
○	FeatureTourService (Hangi turların görüldüğünü yönetir).
○	TourTriggerWidget (Turu tetikleme mantığını içerir).
●	Veri Modeli & State Yönetimi:
○	PreferencesService (SharedPreferences) kullanılarak seen_feature_tour_planner_v2: true gibi versiyonlu bir anahtarla hangi turların tamamlandığı bilgisi saklanır.
●	Kullanıcı Akışı (Interaction Flow):
1.	Kullanıcı bir ekrana ilk kez girer.
2.	FeatureTourService bu turu daha önce görüp görmediğini kontrol eder.
3.	Görmediyse, ekran yüklendikten sonra tur başlar.
4.	Widget'lar sırayla vurgulanır ve açıklamalar gösterilir.
5.	Kullanıcı turu tamamladığında veya atladığında, ilgili flag true olarak işaretlenir.
●	API/Servis Çağrıları (Girdi/Çıktı):
○	Bu özellik tamamen istemci tarafında çalıştığı için API çağrısı gerektirmez.
●	UX Detayları & Kenar Durumlar:
○	Dinamik UI: Tur, ekran döndürme, yeniden boyutlandırma veya geç yüklenen (lazy loading) içeriklere karşı dayanıklı olmalıdır.
○	Kullanıcı Kontrolü: Tur her an atlanabilmeli veya iptal edilebilmelidir.
○	Tekrarlanabilirlik: Ayarlar ekranından turların yeniden başlatılmasına imkan tanınmalıdır.
○	Erişilebilirlik (a11y): Tur açıklamaları ve vurguları ekran okuyucularla tam uyumlu olmalı ve semanticsLabel içermelidir.
○	Tur Versiyonlama: Özellik güncellendiğinde tur da değişirse, versiyonlu flag sayesinde kullanıcıların yeni turu görmesi sağlanmalıdır.
○	Uluslararasılaştırma (i18n): Tur metinleri, uygulamanın dil dosyalarından gelmelidir.
4. Stil Mücadeleleri (Style Challenges)
●	Sayfa Adı ve Amacı:
○	StyleChallengesScreen, ChallengeDetailScreen: Kullanıcılara belirli temalar etrafında kombinler oluşturup paylaştığı, topluluk etkileşimini ve içerik üretimini artırmayı hedefleyen oyunlaştırılmış bir alandır.
●	Ana Bileşenler (Widget/Class Adları):
○	StyleChallengesScreen (ConsumerWidget - Aktif, Gelecek, Geçmiş mücadeleleri sekmelerle gösterir)
○	ChallengeCard (Custom Widget)
○	ChallengeDetailScreen (ConsumerWidget)
○	SubmissionsGridView (Custom Widget)
○	ChallengeController (Riverpod StateNotifier)
○	ChallengeRepository (Interface)
●	Veri Modeli & State Yönetimi:
○	StyleChallenge Model: id, title, description, startTime, votingStartTime, endTime, status, prizeDescription alanlarını içerir.
○	ChallengeSubmission Model: id, challengeId, combinationId, userId, voteCount alanlarını içerir.
○	ChallengeDetailState: isLoading, error, challenge, submissions, userSubmission alanlarını içerir.
●	Kullanıcı Akışı (Interaction Flow):
1.	Kullanıcı StyleChallengesScreen'e gelir ve aktif bir mücadeleye tıklar.
2.	ChallengeDetailScreen'de detayları ve diğer gönderileri görür.
3.	"Kombinini Gönder" butonu ile kendi kombinlerinden birini seçerek gönderir.
4.	Oylama periyodu başladığında diğer gönderilere oy verir.
5.	Mücadele bitince kazananlar ilan edilir.
●	API/Servis Çağrıları (Girdi/Çıktı):
○	ChallengeRepository -> ApiService: Mücadeleleri, detayları ve gönderileri çekmek; yeni gönderi oluşturmak ve oy kullanmak için metotlar içerir.
●	UX Detayları & Kenar Durumlar:
○	Zaman Senkronizasyonu: Geri sayım sayaçları, kullanıcının cihaz saatinden bağımsız, sunucu saatine göre çalışmalıdır.
○	Ağ Yönetimi: Gönderim veya oy kullanma sırasında ağ koparsa, işlem kuyruğa alınıp bağlantı geldiğinde yeniden denenmelidir.
○	Durum Çakışmaları: Kullanıcı oy verirken gönderi silinirse veya oylama kapanırsa, UI'da uygun hata gösterilmelidir. Mükerrer gönderimler sunucu tarafında engellenmelidir.
○	Adil Oylama: Kullanıcı kendi gönderisine oy verememeli ve her gönderiye sadece bir oy hakkı olmalıdır.
○	Performans: Çok fazla katılım olan mücadelelerde, katılımcı listesi de kademeli olarak yüklenmelidir.
5. Paket Listesi Hazırlayıcı (Packing List Generator)
●	Sayfa Adı ve Amacı:
○	PackingListGeneratorScreen, PackingListDetailScreen: Kullanıcının seyahat detaylarını girerek, mevcut gardırobundan ve hava durumu verilerinden faydalanarak otomatik bir seyahat bavulu listesi oluşturmasını sağlayan bir araçtır.
●	Ana Bileşenler (Widget/Class Adları):
○	PackingListGeneratorScreen (ConsumerWidget)
○	PackingListDetailScreen (ConsumerWidget)
○	SuggestedItemCard, MissingItemCard (Custom Widget'lar)
○	PackingListController (Riverpod StateNotifier)
○	PackingListRepository, WeatherService
●	Veri Modeli & State Yönetimi:
○	PackingList Model: id, destination, startDate, endDate, includedClothingItemIds, customAddedItems alanlarını içerir.
○	PackingListState: isLoading, error, generatedList alanlarını içerir.
●	Kullanıcı Akışı (Interaction Flow):
1.	Kullanıcı destinasyon ve tarih girerek "Liste Oluştur" butonuna basar.
2.	Controller, hava durumu verisini çeker.
3.	Hava durumuna ve kullanıcının gardırobuna göre bir liste oluşturulur.
4.	PackingListDetailScreen'de sonuçlar gösterilir, kullanıcı listeyi düzenleyebilir ve kaydedebilir.
●	API/Servis Çağrıları (Girdi/Çıktı):
○	WeatherService: getForecastForLocation(...)
○	PackingListRepository: generateList(...), savePackingList(...)
●	UX Detayları & Kenar Durumlar:
○	Zaman Dilimi Yönetimi: Tüm tarih işlemleri UTC üzerinden yapılmalı, sadece gösterim sırasında lokal saate çevrilmelidir.
○	API Hataları: Hava durumu servisi çalışmazsa veya limit aşılırsa, kullanıcıya bilgi verilmeli ve genel, mevsime uygun bir liste oluşturulmalıdır (Fallback).
○	Uzun Listeler: Çok uzun seyahatler için oluşturulan listelerin belirli bir gün veya parça sayısı ile sınırlandırılması önerilmelidir.
○	Manuel Düzenleme Hafızası: Kullanıcının listeden çıkardığı bir öğe, liste yeniden oluşturulduğunda tekrar eklenmemelidir.
6. Topluluklar/Gruplar (Communities)
●	Sayfa Adı ve Amacı:
○	CommunitiesHubScreen, CommunityDetailScreen: Kullanıcıların ilgi alanlarına göre gruplar oluşturup katılabildiği, daha niş ve ilgili içerik akışları yaratan bir sosyal katmandır.
●	Ana Bileşenler (Widget/Class Adları):
○	CommunitiesHubScreen (ConsumerWidget - "Keşfet" ve "Katıldıklarım" sekmeleri)
○	CommunityCard (Custom Widget)
○	CommunityDetailScreen (ConsumerWidget)
○	CreateCommunityScreen (StatefulWidget)
○	CommunityController, CommunityRepository
●	Veri Modeli & State Yönetimi:
○	Community Model: id, name, description, coverImageUrl, isPublic, ownerId alanlarını içerir.
○	CommunityDetailState: isLoading, error, community, posts, isJoined alanlarını içerir.
●	Kullanıcı Akışı (Interaction Flow):
1.	Kullanıcı CommunitiesHubScreen'de toplulukları keşfeder.
2.	Bir topluluğun detay sayfasına girip "Katıl" butonuna basar.
3.	Katıldığı topluluklara özel gönderi paylaşabilir.
4.	Kendi topluluğunu oluşturabilir.
●	API/Servis Çağrıları (Girdi/Çıktı):
○	CommunityRepository: Toplulukları ve detaylarını çekmek, katılmak/ayrılmak ve yeni topluluk oluşturmak için metotlar içerir.
●	UX Detayları & Kenar Durumlar:
○	Self-Moderation: Kullanıcılar, kurallara aykırı gönderileri raporlayabilmelidir. Belirli sayıda rapor alan içerik otomatik olarak gizlenip moderatör onayına düşmelidir. Doğru raporlama yapan kullanıcılar "Güvenilir Moderatör" gibi rozetler kazanabilir.
○	Özel Topluluklar: isPublic: false olan topluluklara katılım, topluluk sahibinin onayı ile gerçekleşmeli ve istek durumu ("beklemede") kullanıcıya gösterilmelidir.
○	Topluluk Silinmesi: Bir topluluk kapatıldığında, üyeler bilgilendirilmeli ve ilgili sayfalara erişimleri engellenmelidir.
○	Detaylı Bildirimler: Kullanıcılar, her topluluk için ayrı ayrı bildirim (yeni gönderi, yorum vb.) tercihi yapabilmelidir.
BÖLÜM 2: SİSTEMİK VE STRATEJİK PRENSİPLER
2.1. Dayanıklılık ve Operasyonel Mükemmellik (Resilience & Operational Excellence)
●	Prensip Adı: Çoklu Oturum ve State Senkronizasyonu (Multi‑Session & State Sync)
○	Amaç: Kullanıcı birden fazla cihazda oturum açtığında, kritik uygulama durumlarının (aktif sohbet, tamamlanan feature turu, bildirimler vb.) tüm cihazlarda eş zamanlı ve tutarlı kalmasını sağlamak.
○	Ana Bileşenler: SessionSyncService (Service), WebSocketManager / RealtimeDBListener, GlobalStateProvider (Riverpod).
○	Veri Modeli: UserSessionState { activeChatThreadId, completedTours, unreadNotificationCounts }
○	Akış: Uygulama ön plana geldiğinde SessionSyncService.fetchLatest() çağrılır. WebSocket veya Realtime DB üzerinden gelen her "state change" bildirimi anında işlenir ve GlobalStateProvider güncellenir.
○	Kenar Durumlar: Socket bağlantısı kesilirse otomatik yeniden bağlanma stratejisi devreye girmelidir. Aynı anda iki cihazdan çakışan güncelleme gelirse, sunucu timestamp karşılaştırması yaparak en son olanı kabul etmelidir.
●	Prensip Adı: Third‑Party Servislerde “Circuit‑Breaker” Mekanizması
○	Amaç: Sürekli hata veren bir harici servisin (AI, Hava Durumu vb.) tüm uygulamanın performansını düşürmesini ve yavaşlamasını engellemek.
○	Ana Bileşenler: Her harici servis çağrısını sarmalayan bir CircuitBreaker servisi.
○	Akış: Belirli bir eşikte (örn: 5 başarısız denemede 3 hata) hata alındığında, CircuitBreaker "açılır" ve belirli bir süre (örn: 30sn) boyunca o servise giden tüm istekleri anında reddeder. Bu sürede kullanıcıya "Şu anda AI önerileri geçici olarak kullanılamıyor" gibi bir mesaj gösterilir. Süre dolunca CircuitBreaker "yarı-açık" konuma geçer, tek bir deneme isteğine izin verir, başarılı olursa tekrar "kapanır".
○	Kenar Durumlar: Farklı servisler için farklı hata eşikleri ve bekleme süreleri tanımlanabilmelidir.
●	Prensip Adı: Acil Durum “Kill‑Switch” ve Backup Plan
○	Amaç: Kritik bir bug veya güvenlik açığı keşfedildiğinde, ilgili özelliği (AI, sosyal feed, takas sohbeti vb.) anında ve tüm kullanıcılarda, yeni bir versiyon yayınlamadan devre dışı bırakabilmek.
○	Ana Bileşenler: Sunucu tarafında tutulan bir FeatureFlag veya KillSwitch endpoint'i (/api/feature-flags). Uygulama her açıldığında veya periyodik olarak bu konfigürasyonu çeker.
○	Akış: Acil bir durumda, sunucudaki disable_swap_market flag'i true yapılır. Tüm istemciler bu bilgiyi alır ve ilgili özelliği arayüzden gizler veya "Bu özellik geçici olarak devre dışıdır" ekranı gösterir.
○	Kenar Durumlar: Kritik durumlar için ekip içi Slack veya operasyonel bildirim kanallarına otomatik alarm tetiklenmelidir. Sunucuya ulaşılamazsa, en son bilinen flag durumu lokalde saklanmalıdır.
●	Prensip Adı: Hata İzleme & İnteraktif Kullanıcı Destek Akışı
○	Amaç: Crash ve performans sorunlarını otomatik olarak yakalayıp, kullanıcıdan ek bağlam alarak hızlı ve etkili müdahale sağlamak.
○	Ana Bileşenler: CrashlyticsService / SentryService, UserFeedbackDialog, SupportTicketModel.
○	Akış: Uygulama bir hata yakaladığında veya çöktüğünde, teknik detaylar (cihaz modeli, app versiyonu, breadcrumbs) otomatik olarak raporlanır. Aynı anda kullanıcıya "Bir hata oluştu, ekibimiz bilgilendirildi. Detay paylaşmak ister misiniz?" şeklinde bir diyalog gösterilir. Kullanıcının girdisi, ilgili hata raporuyla ilişkilendirilerek destek ekibine iletilir.
○	Kenar Durumlar: Çok kısa sürede tekrarlanan crash'ler algılanırsa (örn: 3 saniyede 3 crash), uygulama "Güvenli Mod"da açılabilir veya genel bir "Bakım Modu" banner'ı gösterebilir. Ekran yükleme süreleri gibi performans metrikleri de düzenli olarak izlenmelidir.
●	Prensip Adı: Depolama Alanı Yönetimi
○	Amaç: Uygulamanın, cihazda aşırı cache veya veri biriktirerek cihazın genel performansını düşürmesini ve depolama alanını doldurmasını engellemek.
○	Ana Bileşenler: CacheManager (örn: cached_network_image konfigürasyonu), StorageMonitorService.
○	Akış: Görsel cache'i için makul bir üst limit (örn: 250 MB) belirlenir. Bu limit aşıldığında, en eski ve en az erişilen öğeler otomatik olarak silinir. Büyük bir indirme işleminden (örn: tüm gardırop verisini ilk kez çekme) önce, StorageMonitorService.checkFreeSpace() çağrılır. Cihazda 100 MB'tan az boş alan varsa kullanıcı uyarılır.
○	Kenar Durumlar: Ayarlar ekranında kullanıcıya "Önbelleği Temizle" butonu sunulmalıdır.
●	Prensip Adı: Sistem Seviyesi Kesintiler (System-Level Interruptions)
○	Amaç: Telefon çağrısı, alarm gibi işletim sistemi kaynaklı olaylar sırasında uygulamanın kararlı kalmasını sağlamak.
○	Ana Bileşenler: Ses odağı (audio focus), uygulama yaşam döngüsü (app lifecycle) olaylarını dinleyen servisler.
○	Akış: Uygulama, ses odağını kaybettiğinde (örn: telefon çalınca) sesli komut gibi işlemleri otomatik olarak duraklatmalıdır. Olay bittiğinde, akışa kaldığı yerden devam etmeye çalışmalı veya kullanıcıyı bilgilendirmelidir.
○	Kenar Durumlar: Düşük pil moduna geçildiğinde, pil tüketen animasyonlar ve arka plan görevleri otomatik olarak azaltılmalıdır.
2.2. Veri Yönetimi, Gizlilik ve Yaşam Döngüsü
●	Prensip Adı: Granüler Veri Gizliliği ve Kullanıcı İzinleri
○	Amaç: Kullanıcının, verisinin hangi amaçlarla ("sosyal feed", "AI eğitimi", "anonim analitik" vb.) kullanılacağına dair ayrı ayrı ve şeffaf bir şekilde izin vermesini sağlamak.
○	Ana Bileşenler: PrivacySettingsScreen'de amaç bazlı toggle'lar, DataUsageConsent modeli, UserRepository.updateConsents() metodu.
○	Akış: Kullanıcı Ayarlar > "Veri Kullanım İzinleri" ekranına girer. Her kategori için onay/ret switch'leri bulunur. Değişiklik anında updateConsents() çağrılır ve optimistic UI ile arayüz güncellenir.
○	Kenar Durumlar: Uygulamanın çalışması için zorunlu olan izinler (örn: temel oturum) disabled olarak gösterilir ve değiştirilemez.
●	Prensip Adı: Veri Saklama ve Arşivleme Politikası
○	Amaç: Zamanla büyüyen veritabanının performansını korumak ve depolama maliyetlerini optimize etmek.
○	Ana Bileşenler: "Soğuk Depolama" (örn: Amazon S3 Glacier) servisi, DataArchivingService.
○	Akış: 1 yıldan eski ve aktif olarak kullanılmayan veriler (örn: 6 aydır dokunulmamış kombinler, eski sohbet geçmişleri) periyodik olarak ana veritabanından daha ekonomik bir arşiv deposuna taşınır. Bu verilere erişim hala mümkün olabilir ancak daha yavaş olacaktır.
○	Kenar Durumlar: Kullanıcıya, eski verilerini periyodik olarak temizleme veya arşivleme seçeneği de sunulmalıdır.
●	Prensip Adı: Veri Geçişi ve Şema Evrimi (Data Migration & Schema Evolution)
○	Amaç: Lokal veritabanı şeması güncellemelerinde kullanıcı verisinin kaybolmadan veya uygulamanın çökmeden yeni versiyona uyum sağlamasını garantilemek.
○	Ana Bileşenler: MigrationService, LocalDbSchemaVersion (int), HiveMigrationScripts / SqfliteMigration script'leri.
○	Akış: Uygulama açıldığında MigrationService.checkVersion() çalışır. Lokaldeki versiyon ile koddaki versiyon farklıysa, migrate_<from>_to_<to>() script'leri sırayla devreye girer. İşlem tamamlandığında yeni şema versiyonu kaydedilir ve UI yüklenir.
○	Kenar Durumlar: Her bir migrasyon script'i bir transaction içinde çalışmalıdır; hata alınırsa işlem geri alınmalıdır (rollback). Büyük veri setleri için kullanıcıya bir "Verileriniz güncelleniyor..." ekranı gösterilmelidir.
●	Prensip Adı: GDPR / KVKK Veri Portabilitesi & Silme
○	Amaç: Kullanıcının "verilerimi indir" (veri taşınabilirliği) ve "unutulma hakkı" gibi yasal taleplerini eksiksiz ve güvenilir bir şekilde karşılamak.
○	Ana Bileşenler: DataExportService (JSON formatında ZIP paketi oluşturur), AccountDeletionService (veriyi anonimleştirir veya tamamen siler).
○	Akış: "Verilerimi İndir" butonu DataExportService.generate() metodunu tetikler ve kullanıcıya bir indirme linki gönderir. "Hesabı Sil" onayı alındıktan sonra AccountDeletionService.purge() çalışır.
○	Kenar Durumlar: Yasal olarak saklanması gereken kayıtlar (örn: takas geçmişi) tamamen silinmek yerine, kişisel bilgilerden arındırılarak (pseudonymization) saklanır. Kullanıcıya işlemin geri alınamaz olduğuna dair net bir uyarı gösterilir.
●	Prensip Adı: Veri Bütünlüğü: Gardırop‑Kombin Tutarlılığı
○	Amaç: Gardıroptan bir kıyafet silindiğinde, o kıyafeti referans eden kombin ve takvim planı gibi bağlı kayıtların tutarlı kalmasını sağlamak, "yetim" veri oluşumunu engellemek.
○	Ana Bileşenler: SoftDeleteService (isDeleted flag'i ile silme), ReferentialIntegrityChecker (Arka plan servisi).
○	Akış: Kullanıcı bir kıyafeti silmek istediğinde, kayıt veritabanından fiziksel olarak silinmez, isDeleted=true olarak işaretlenir. Bu kıyafeti içeren kombinler, arayüzde "Eksik parça içeriyor" şeklinde bir uyarı ile gösterilir.
○	Kenar Durumlar: Kullanıcıya silme işlemi öncesi "Bu kıyafet X kombinde kullanılıyor, yine de silmek istiyor musunuz?" uyarısı gösterilmelidir. Fiziksel silme (Hard Delete) sadece admin paneli gibi kontrollü bir arayüzden yapılmalıdır.
●	Prensip Adı: Stil Asistanı Bağlam Yönetimi (Entity Linking)
○	Amaç: Sohbetteki "mavi ceket" gibi genel ifadeleri, ClothingItem.id gibi somut varlıklarla ilişkilendirerek AI'ın konuşma bağlamını korumasını ve daha akıllı yanıtlar vermesini sağlamak.
○	Ana Bileşenler: ChatMessage modeline relatedEntityId ve entityType alanları eklenir. EntityLinkerService.
○	Akış: Kullanıcı bir kıyafeti sohbette paylaştığında veya AI bir ürün önerdiğinde, bu mesajda ilgili varlığın ID'si de saklanır. Gelecek mesajlarda "o ceketle ilgili..." gibi bir ifade kullanıldığında, AI hangi ceketten bahsedildiğini net olarak bilir.
○	Kenar Durumlar: Aynı mesajda birden fazla varlığa referans olabilir; bu durumda bir liste tutulmalıdır. Referans verilen varlık silinmişse, AI "Bahsettiğiniz öğe artık mevcut değil" şeklinde yanıt vermelidir.
2.3. Geliştirme, Büyüme ve Topluluk Stratejileri
●	Prensip Adı: API Versiyonlama Stratejisi
○	Amaç: API’da yapılan “breaking change”lerin eski istemcileri etkilemeden, yeni versiyonların geriye dönük uyumlulukla çalışmasını sağlamak.
○	Ana Bileşenler: URL‑bazlı versiyonlama (/api/v1/...), ApiClient sınıfı (X-App-Version header'ı ekler), AppVersionService.
○	Akış: İstemci her istekte versiyonunu header ile bildirir. Sunucu, eski versiyonları v1 altında yanıtlar. Yeni özellikler v2'de geliştirilir. Çok eski bir versiyon kullanılırsa sunucu 426 Upgrade Required döner ve istemci kullanıcıyı mağazaya yönlendirir.
○	Kenar Durumlar: API response'larına bir Deprecation uyarısı header'ı eklenerek, endpoint'in ne zaman kullanımdan kalkacağı bildirilebilir.
●	Prensip Adı: Kullanıcı Geri Besleme Döngüsü (Feedback‑for‑AI)
○	Amaç: AI önerilerinin kalitesini artırmak için, kullanıcının beğeni/beğenmeme gibi geri bildirimlerini modele gerçek zamanlı olarak iletmek ve sistemi sürekli öğrenen bir yapıya kavuşturmak.
○	Ana Bileşenler: FeedbackController (Riverpod StateNotifier), UserFeedback Modeli ({ suggestionId, isPositive, timestamp }), AiRecommendationService.submitFeedback().
○	Akış: AI tarafından üretilen her önerinin yanında “👍 / 👎” ikonları gösterilir. Kullanıcı tıkladığında FeedbackController.send() tetiklenir ve bu bilgi, AI modelini yeniden eğitmek üzere POST /feedback endpoint'i ile sunucuya gönderilir.
○	Kenar Durumlar: Aynı öneriye tekrarlı geri bildirim gönderilmesi engellenmelidir (cooldown süresi). Gönderim ağ hatası nedeniyle başarısız olursa, istek lokal bir kuyruğa alınıp daha sonra yeniden denenmelidir.
●	Prensip Adı: Self‑Moderation & Rozet Sistemleri
○	Amaç: Topluluk içi bayraklama (flagging) ve güvenilir moderatör rozetleriyle, sosyal içeriğin merkezi bir ekibe ihtiyaç duymadan, kendi kendini düzenlemesini ve temizlemesini sağlamak.
○	Ana Bileşenler: ModerationController, FlaggedContentQueue, UserReputationModel.
○	Akış: Her gönderi kartında bir "Rapor Et / Bayrakla" butonu bulunur. Bir gönderi belirli bir eşiğin (örn: 5 farklı kullanıcı) üzerinde bayraklandığında, otomatik olarak genel akıştan gizlenir ve moderatör onay kuyruğuna düşer. Doğru ve faydalı raporlamalar yapan kullanıcılara "Güvenilir Moderatör" gibi rozetler ve itibar puanları verilir.
○	Kenar Durumlar: Kötü niyetli ve tekrarlı bayraklama (spam) yapan kullanıcılar engellenmelidir (dakika başına rapor limiti). İnceleme sonucunda raporun haksız olduğu anlaşılırsa, raporlayan kullanıcının itibar puanı düşürülebilir.
●	Prensip Adı: Sistem Suistimali ve Ani Aktivite Tespiti (Anti-Abuse)
○	Amaç: AuraScore gibi oyunlaştırma sistemlerini suistimal eden (bot, spam yaratma vb.) davranışları sunucu tarafında tespit edip engellemek.
○	Ana Bileşenler: AbuseDetectionService (Rate limiting & anomali tespiti), ActionCountRepository.
○	Akış: Puan kazandıran her aksiyon (kombin oluşturma, beğeni vb.) öncesi AbuseDetectionService.check(actionType) çağrılır. Eğer kullanıcı belirli bir zaman diliminde o eylem için limitini aştıysa, işlem engellenir ve "Çok sık işlem yapıyorsunuz, lütfen biraz bekleyin" hatası gösterilir.
○	Kenar Durumlar: Aynı IP adresinden gelen aşırı istekler (potansiyel bot saldırısı) tespit edilip engellenebilir. Her eylem türü için kullanıcı bazında günlük ve saatlik üst limitler tanımlanabilir.
●	Prensip Adı: Uzun Vadeli Ölçüm ve Başarı Metrikleri (KPIs)
○	Amaç: Geliştirilen yeni özelliklerin (Stil Mücadeleleri, Paket Listesi vb.) gerçekten kullanılıp kullanılmadığını, kullanıcıya değer katıp katmadığını ve iş hedeflerine hizmet edip etmediğini objektif verilerle ölçmek.
○	Ana Bileşenler: Analitik servisi (Firebase Analytics, Amplitude vb.), şirket içi Dashboard (örn: Metabase, Looker).
○	Akış: Her büyük özellik için net ve ölçülebilir KPI'lar (Anahtar Performans Göstergeleri) tanımlanır. Örneğin: "Stil Mücadelelerine aylık aktif kullanıcıların katılım oranı %X olmalı", "Paket Listesi özelliğini kullanan kullanıcıların %Y'si listeyi kaydetmeli" gibi. Bu metrikler periyodik olarak (haftalık/aylık) ürün ekibi tarafından incelenir ve gelecekteki geliştirmelere yön verir.
●	Prensip Adı: AI Servisleri Kota & Maliyet Yönetimi
○	Amaç: STT/TTS ve öneri motorları gibi harici API'lerin kullanımından kaynaklanan maliyetleri ve kotaları kontrol altında tutmak.
○	Ana Bileşenler: AiQuotaService (Kullanıcı bazlı veya global kota takibi).
○	Akış: Maliyetli bir AI çağrısından önce AiQuotaService.checkQuota() yapılır. Eğer kota tükenmişse, istek engellenir ve kullanıcıya "Aylık AI asistan kullanım limitinize ulaştınız. Yeni ayda tekrar görüşmek üzere!" gibi bir mesaj gösterilir.
○	Kenar Durumlar: Kota her ayın başında sıfırlanır. Gelecekte, abonelik modeli ile premium kullanıcılara daha yüksek kotalar tanımlanabilir.
BÖLÜM 3: GELİŞTİRME SÜRECİ VE ÜRÜN STRATEJİSİ
●	Prensip Adı: Konfigürasyon ve Ortam Yönetimi
○	Amaç: Geliştirme (development), test (staging) ve canlı (production) ortamlarının birbirinden tamamen izole ve güvenli bir şekilde yönetilmesini sağlamak.
○	Gereksinimler: Tüm ortama özel anahtar ve değişkenler (API_KEY, BASE_URL vb.) .env dosyalarında tutulmalı, asla kod içine yazılmamalıdır. main_dev.dart, main_prod.dart gibi farklı başlangıç noktaları oluşturularak ortamlar ayrılmalıdır.
●	Prensip Adı: State Management Disiplini
○	Amaç: Riverpod kullanımında tutarlılığı sağlamak, kodun okunabilirliğini ve bakımını kolaylaştırmak.
○	Gereksinimler: Proje için bir "Riverpod Kullanım Kılavuzu" oluşturulmalıdır. "Basit UI durumları için StateProvider", "Karmaşık iş mantığı ve metotlar içeren durumlar için StateNotifierProvider", "Tek seferlik asenkron veri çekme işlemleri için FutureProvider" gibi net kurallar belirlenmelidir.
●	Prensip Adı: Bağımlılık (Dependency) Yönetimi
○	Amaç: Projeye eklenen üçüncü parti paketlerin güvenilir, güncel ve performanslı olmasını sağlamak.
○	Gereksinimler: Projeye yeni bir paket eklenmeden önce; popülerliği (like, pub points), son güncelleme tarihi, açık olan issue sayısı ve null-safety desteği gibi kriterlere göre kısa bir değerlendirme yapılmalıdır.
●	Prensip Adı: Varlık (Asset) Yönetimi
○	Amaç: Projedeki ikon, görsel, animasyon ve font dosyalarını organize ve hatasız bir şekilde yönetmek.
○	Gereksinimler: assets klasörü altında images, icons, animations, fonts gibi alt klasörler oluşturulmalıdır. Bu varlıklara kod içinden sihirli dizgelerle ('assets/images/logo.png') erişmek yerine, tüm yolları içeren bir sınıf otomatik olarak oluşturulmalıdır.
●	Prensip Adı: MVP ve Aşamalı Yaygınlaştırma Stratejisi
○	Amaç: Projenin tamamını tek seferde inşa etmek yerine, kullanıcıya en temel değeri sunacak çekirdek özelliklerle başlayarak hızlıca pazara çıkmak ve geri bildirim almak.
○	Gereksinimler: Bu dökümandaki özellikler önceliklendirilmelidir.
■	Faz 1 (MVP): Temel Gardırop Yönetimi (WardrobeHomeScreen, AddClothingItemScreen, ClothingItemDetailScreen), Temel Kombin Yönetimi (MyCombinationsScreen, CreateCombinationScreen), Temel Kullanıcı Profili ve Oturum Yönetimi.
■	Faz 2: Sosyal Özellikler ve Stil Asistanı (SocialFeedScreen, StyleAssistantScreen, FavoritesScreen).
■	Faz 3: İleri Seviye ve Oyunlaştırma Özellikleri (WardrobePlannerScreen, StyleChallenges, SwapMarketScreen, WardrobeAnalyticsScreen).
■	Bu fazlama, ürün ve iş stratejisine göre esneklik gösterebilir.

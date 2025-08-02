Uygulama Özellikleri (Tam Metin)
1. Nihai Özellik: Temel Uygulama İskeleti ve Ana Navigasyon
● Sayfa Adı ve Amacı:
○ MainScreen: Uygulamanın kök widget'ı. Uygulama ilk açıldığında çalışan ilk
ekrandır. Kullanıcının daha önce uygulamayı açıp açmadığına (onboarding) ve
oturum durumuna göre yönlendirme yapar.
■ Oturum açık ve token geçerliyse: HomeScreen'e yönlendirir.
■ Oturum kapalıysa:
■ hasSeenOnboarding false ise: OnboardingScreen'e yönlendirir.
■ hasSeenOnboarding true ise: LoginScreen'e yönlendirir.
○ SplashScreen: Uygulama başlatıldığında, MainScreen ile yönlendirme
kararları verilene kadar gösterilen geçiş ekranıdır. Burada kısa bir bekleme
süresi olabilir veya token'ın geçerliliği, uygulama versiyonu gibi hızlı kontroller
yapılır.
○ OnboardingScreen: Uygulamayı ilk kez açan kullanıcıya uygulamanın
sunduğu hizmetleri tanıtan slayt benzeri ekranlar ve sonunda "Hesap Oluştur"
veya "Giriş Yap" butonları bulunur.
○ LoginScreen: Kayıtlı kullanıcıların kimlik bilgilerini girdiği ve oturum açtığı
ekrandır.
○ HomeScreen: Kimlik doğrulaması yapıldıktan sonra kullanıcıyı karşılayan ve
ana navigasyonu (BottomNavigationBar) barındıran ekran. Kullanıcının
uygulama içinde dolaşmasını sağlar.
○ Amaç: Uygulamanın temel yapı taşlarını ve kullanıcıların uygulama içinde nasıl
dolaşacağını tanımlamak. Kullanıcı deneyimini akışkan, sezgisel ve güvenli hale
getirmek.
● Ana Bileşenler (Widget/Class Adları):
○ MainScreen (StatelessWidget veya ConsumerWidget)
○ SplashScreen (StatelessWidget)
○ OnboardingScreen (StatefulWidget veya PageView içeren yapı)
○ LoginScreen (StatefulWidget - Form state'i içerir)
○ HomeScreen (StatefulWidget - BottomNavigationBar state'ini yönetir)
○ WardrobeHomeScreen (Placeholder)
○ StyleAssistantScreen (Placeholder)
○ InspireMeScreen (Placeholder)
○ FavoritesScreen (Placeholder)
○ ProfileScreen (Placeholder)
○ BottomNavigationBar (Flutter Widget)
○ GoRouter (veya başka bir yönlendirici) - Uygulama genelinde sayfa
yönlendirmesi için.
○ NoTransitionPage (GoRouter ile route animasyonlarını engellemek için)
○ AppVersionService (Uygulama versiyon kontrolü için servis)
● Veri Modeli & State Yönetimi:
○ Kimlik Doğrulama State'i: authController (örneğin, Riverpod
AsyncNotifier<AuthState>). AuthState enum'u (initial, unauthenticated,
authenticated, loading, error) gibi durumları içerebilir.
○ Onboarding Durumu: onboardingController veya
hasSeenOnboardingProvider (örneğin, Riverpod StateProvider<bool>).
Kullanıcının onboarding'i görüp görmediğini takip eder.
○ Depolama Servisleri:
■ SecureStorageService (örneğin, flutter_secure_storage paketi): Kullanıcı
oturum token'ı (JWT) gibi hassas verilerin saklanması için kullanılır.
■ PreferencesService (örneğin, shared_preferences paketi):
hasSeenOnboarding flag'i gibi küçük, hassas olmayan kullanıcı
tercihlerinin saklanması için kullanılır.
○ MainScreen, authController ve hasSeenOnboardingProvider'ı dinleyerek
kullanıcıyı uygun ekrana yönlendirir.
○ Navigasyon State'i: HomeScreen içinde _selectedIndex adında bir int state'i
tutulur (örneğin, Riverpod StateProvider<int> veya HomeScreen'in kendi State
objesinde). Bu, BottomNavigationBar'ın hangi sekmenin aktif olduğunu
anlaması için kullanılır.
○ Riverpod Provider'ları: Her bir alt ekran (WardrobeHomeScreen,
StyleAssistantScreen, vb.) için kendi özel provider'ları olacaktır (ileride
tanımlanacak).
● Kullanıcı Akışı (Interaction Flow):
1. Uygulama başlatılır.
2. SplashScreen yüklenir.
3. SplashScreen, AppVersionService.checkForUpdate() çağrısı yapar.
■ Zorunlu Güncelleme Gerekliyse: Kullanıcıyı App Store/Play Store'a
yönlendiren bir ekran gösterilir. Uygulama kapanır.
■ İsteğe Bağlı/Güncelleme Yoksa: 4. adıma geçilir.
4. MainScreen yüklenir.
5. MainScreen, authController ve hasSeenOnboardingProvider durumlarını
kontrol eder.
■ Oturum açık ve token geçerliyse, HomeScreen'e yönlendirilir (GoRouter:
/home).
■ Oturum kapalıysa:
■ hasSeenOnboarding false ise, OnboardingScreen'e yönlendirilir
(GoRouter: /onboarding).
■ hasSeenOnboarding true ise, LoginScreen'e yönlendirilir (GoRouter:
/login).
6. OnboardingScreen'den "Hesap Oluştur" veya "Giriş Yap" butonuna
basıldığında, LoginScreen'e yönlendirilir.
7. LoginScreen'de kimlik bilgileri girilir ve giriş yapılır.
8. Kimlik doğrulama başarılı olursa, HomeScreen'e yönlendirilir.
9. HomeScreen yüklenir ve varsayılan olarak WardrobeHomeScreen gösterilir.
10. Kullanıcı alttaki BottomNavigationBar'daki sekmelerden birine tıklar.
11. HomeScreen, _selectedIndex state'ini günceller.
12. IndexedStack veya benzeri bir widget, yeni seçilen indekse karşılık gelen
ekranı (StyleAssistantScreen, ProfileScreen, vb.) gösterir.
13. Kullanıcı cihazın "geri" tuşuna basarsa, HomeScreen bu işlemi ele alır (back
button intercept). Eğer aktif sekme WardrobeHomeScreen değilse, oraya
yönlendirilir. Eğer zaten oradaysa, uygulama çıkış uyarısı gösterilebilir.
● API/Servis Çağrıları (Girdi/Çıktı):
○ authController: Kimlik doğrulama işlemleri için backend API'lerini çağırır
(örneğin, AuthService.login(), AuthService.register(),
AuthService.validateToken()).
■ Girdi: Kullanıcı adı/şifre, e-posta, token.
■ Çıktı: Oturum token'ı, kullanıcı profili verisi, hata mesajı.
○ onboardingController: hasSeenOnboarding durumunu PreferencesService'e
kaydeder veya ordan okur.
■ Girdi: bool (true/false).
■ Çıktı: bool.
○ AppVersionService: Uygulama mağazasındaki en son sürüm bilgisini çeker.
■ Girdi: Mevcut uygulama sürümü (build number/string).
■ Çıktı: En son sürüm bilgisi, zorunlu güncelleme flag'i.
● UX Detayları & Kenar Durumlar:
○ Tasarım: BottomNavigationBar, Material Design 3'e uygun olacak. İkonlar ve
etiketler net ve anlaşılır olacak. semanticLabel ile erişilebilirlik sağlanacak.
Renk kontrastı WCAG standartlarına uygun olacak.
○ Varsayılan Ekran: Uygulama açıldığında WardrobeHomeScreen gösterilir.
○ Navigasyon Performansı: Ekranlar IndexedStack veya lazy loading ile
yönetilerek, kullanıcı geçiş yaptığında hızlı yüklenmeleri sağlanır. GoRouter'da
NoTransitionPage kullanılarak HomeScreen altındaki sekmeler arası geçişlerde
animasyon engellenir.
○ Deep Link Desteği: GoRouter konfigürasyonunda
myapp://style-assistant?topic=date-night gibi derin linkler için route
tanımlanır. HomeScreen, bu linklere göre yönlendirme yapar.
○ Kenar Durumları:
■ Ağ Hatası: Kimlik doğrulama sırasında veya splash ekranında ağ hatası
oluşursa, kullanıcıya uygun bir hata mesajı ve "Tekrar Dene" butonu
gösterilir.
■ Geçersiz Giriş: Kullanıcı geçersiz kimlik bilgileriyle giriş yapmaya çalışırsa,
hata mesajı gösterilir.
■ Yükleniyor: Kimlik kontrolü veya splash işlemleri yapılırken bir "shimmer"
veya loading göstergesi (Lottie) gösterilir.
■ Token Süresi Dolmuşsa: Splash ekranında token validasyonu yapılır.
Süresi dolmuşsa, kullanıcı LoginScreen'e yönlendirilir.
■ Zorunlu Güncelleme: App Store/Play Store'da zorunlu bir güncelleme
varsa, kullanıcı bilgilendirilir ve mağazaya yönlendirilir.
■ Analitik: HomeScreen yüklendiğinde
AnalyticsService.logPageView('HomeScreen') gibi çağrılar yapılır.
■ Offline Durum: Uygulama, temel navigasyonu offline durumda da
desteklemelidir (örneğin, daha önce açılmış ekranlar cache'den
yüklenebilir).
2. Güncellenmiş ve Netleştirilmiş Özellik: WardrobeHomeScreen
● Sayfa Adı ve Amacı:
○ WardrobeHomeScreen: Kullanıcının dijital gardırobunun görüntülenip
yönetildiği ana ekrandır. Kullanıcı burada kıyafetlerini görebilir, detaylı arama ve
filtreleme (kategori, mevsim, özel etiketler, favori durumu) yapabilir, yeni
kıyafetler ekleyebilir, favorilerini işaretleyebilir ve toplu işlemler başlatabilir.
Uygulama açıldığında kullanıcıyı karşılayan ilk ana ekrandır.
● Ana Bileşenler (Widget/Class Adları):
○ WardrobeHomeScreen (StatelessWidget veya ConsumerWidget - Riverpod ile
state dinler)
○ AppBar (Flutter Widget - Başlık ("My Wardrobe") ve kullanıcı profiline kısayol
içerir)
○ WardrobeSearchBar (Custom Widget - Metin araması ve filtreleme butonunu
barındırır)
○ WardrobeFilterBottomSheet (Custom Widget - Kategori, mevsim, favori gibi
filtrelerin çoklu seçilebildiği bir alttan kayan panel)
○ WardrobeGridView (Custom Widget - ClothingItemCard'ları ızgaralar halinde
gösterir)
○ WardrobeListView (Custom Widget - ClothingItemCard'ları liste halinde
gösterir - kullanıcı seçebilir)
○ ClothingItemCard (Custom Widget - Tek bir kıyafetin görselini, adını ve temel
bilgilerini gösterir. Üzerinde favori ikonu ve uzun basma ile multiselect
başlatma işlevi vardır)
○ EmptyWardrobeView (Custom Widget - Kullanıcının gardırobunda hiç kıyafet
olmadığında gösterilir)
○ WardrobeErrorView (Custom Widget - Gardırop verisi çekilirken hata
oluştuğunda gösterilir)
○ WardrobeLoadingView (Custom Widget - Gardırop verisi yüklenirken gösterilir)
○ FloatingActionButton (Flutter Widget - AddClothingItemScreen'e yönlendirir)
○ WardrobeMultiSelectToolbar (Custom Widget - Çoklu seçim modundayken
üstte görünen toolbar (seçilen öğe sayısı, sil, taşı gibi butonlar))
○ WardrobeController (Riverpod StateNotifier - Gardırop verisi, yükleme durumu,
filtreler, arama terimi, çoklu seçim durumu gibi state'leri yönetir)
○ WardrobeRepository (Interface - Gardırop verisi ile ilgili işlemleri tanımlar)
○ WardrobeRepositoryImpl (Implementation - WardrobeRepository'nin gerçek
uygulaması, örneğin API veya local veriyle iletişim kurar)
○ customCategoriesProvider (Riverpod Provider<List<CustomCategory>> -
Kullanıcının özel kategorilerini sağlar)
● Veri Modeli & State Yönetimi:
○ ClothingItem (Model - Tek bir kıyafetin verisini tanımlar):
class ClothingItem {
final String id;
final String name;
final String imageUrl;
final String category; // Varsayılan kategori veya CustomCategory id
final List<String> tags; // AI'dan gelen etiketler
final List<String> userTags; // Kullanıcının eklediği özel etiketler
final String color;
final String season; // "İlkbahar", "Yaz", "Sonbahar", "Kış"
final DateTime createdAt;
final DateTime? lastWornDate; // Algoritmik gardırop temizliği için
final bool isFavorite; // Favori durumu
}
○ CustomCategory (Model - Kullanıcının oluşturduğu özel kategori):
class CustomCategory {
final String id;
final String name;
final Color? color;
final IconData? icon;
}
○ WardrobeState (WardrobeController'ın yönettiği state):
abstract class WardrobeState {}
class WardrobeInitial extends WardrobeState {}
class WardrobeLoading extends WardrobeState {}
class WardrobeLoaded extends WardrobeState {
final List<ClothingItem> items;
final bool hasReachedMax; // Pagination için
final String searchTerm;
final Set<String> selectedCategories; // Varsayılan ve CustomCategory id'leri
final Set<String> selectedSeasons;
final bool showOnlyFavorites;
final String sortBy; // "date", "name", "category"
final bool isGridView; // true: grid, false: list
final bool isMultiSelectMode; // Çoklu seçim modu aktif mi?
final Set<String> selectedItemsInMultiSelect; // Çoklu seçimde seçilen item
id'leri
WardrobeLoaded({
required this.items,
required this.hasReachedMax,
this.searchTerm = '',
this.selectedCategories = const {},
this.selectedSeasons = const {},
this.showOnlyFavorites = false,
this.sortBy = 'date',
this.isGridView = true,
this.isMultiSelectMode = false,
this.selectedItemsInMultiSelect = const {},
});
WardrobeLoaded copyWith({...}); // State güncellemeleri için
}
class WardrobeError extends WardrobeState {
final String message;
WardrobeError(this.message);
}
○ WardrobeController (Riverpod StateNotifier<WardrobeState>):
■ state: Mevcut WardrobeState.
■ loadItems({bool isRefresh = false}): Gardırop verisini yükler (ilk yükleme
veya yenileme). Filtreleri ve arama terimini backend çağrısına dahil eder.
■ searchItems(String term): Arama terimini state'e kaydeder ve arama
tetikler.
■ openFilterBottomSheet(): WardrobeFilterBottomSheet'i açar.
■ applyFilters(Set<String> categories, Set<String> seasons, bool
showOnlyFavorites): Filtreleri state'e kaydeder ve filtreleme tetikler.
■ sortItems(String sortBy): Sıralama kriterini state'e kaydeder ve yeniden
sıralama tetikler.
■ toggleView(): isGridView state'ini değiştirir (Grid <-> List).
■ deleteItem(String itemId): Bir kıyafeti silme işlemini başlatır.
■ toggleFavorite(String itemId): Bir kıyafetin favori durumunu değiştirir.
■ enterMultiSelectMode(): isMultiSelectMode state'ini true yapar.
■ exitMultiSelectMode(): isMultiSelectMode ve selectedItemsInMultiSelect
state'lerini sıfırlar.
■ toggleItemSelectionInMultiSelect(String itemId): Çoklu seçimde bir item'ın
seçilme durumunu değiştirir.
■ deleteSelectedItems(): selectedItemsInMultiSelect listesindeki tüm
item'ları siler ve moddan çıkar.
○ Riverpod Providers:
■ wardrobeControllerProvider: WardrobeController'ı sağlayan
StateNotifierProvider.
■ clothingItemsProvider: WardrobeController'ın state'inden
WardrobeLoaded durumundaki items listesini okuyan Provider.
■ customCategoriesProvider: Kullanıcının özel kategorilerini sağlayan
Provider<List<CustomCategory>>.
● Kullanıcı Akışı (Interaction Flow):
1. Kullanıcı HomeScreen'de Wardrobe sekmesine tıklar.
2. WardrobeHomeScreen yüklenir.
3. WardrobeController, WardrobeRepository aracılığıyla kullanıcının gardırop
verisini çeker (filtreler ve arama terimi dahil).
4. Yükleniyor Durumu: Veri çekilirken WardrobeLoadingView gösterilir.
5. Hata Durumu: Veri çekilirken hata oluşursa WardrobeErrorView gösterilir.
Kullanıcı "Tekrar Dene" butonuna basabilir.
6. Veri Geldiğinde (WardrobeLoaded):
■ Kullanıcı WardrobeSearchBar'daki metin kutusuna yazarak kıyafetleri
arayabilir (searchItems).
■ Kullanıcı WardrobeSearchBar'daki "Filtreler" butonuna basar.
■ WardrobeFilterBottomSheet açılır. Burada:
■ Varsayılan kategoriler ve customCategoriesProvider ile gelen özel
kategoriler FilterChip olarak listelenir. Kullanıcı çoklu seçim yapabilir.
■ Mevsimler (FilterChip) çoklu seçilebilir.
■ "Sadece Favoriler" adında bir Switch veya FilterChip vardır.
■ "Uygula" butonuna basıldığında, seçilen filtreler applyFilters ile state'e
kaydedilir ve liste yeniden çekilir.
■ Kullanıcı sıralama seçeneğini değiştirebilir (sortItems).
■ Kullanıcı görünüm modunu değiştirebilir (Grid/List - toggleView).
■ Kullanıcı bir ClothingItemCard'taki kalp ikonuna basarak favori durumunu
değiştirebilir (toggleFavorite).
■ Kullanıcı bir ClothingItemCard'a tıklayarak detay sayfasına
(ClothingItemDetailScreen) gidebilir.
■ Kullanıcı bir ClothingItemCard'a uzun basarak çoklu seçim moduna girer
(enterMultiSelectMode). Diğer item'lara da tıklayarak seçebilir.
WardrobeMultiSelectToolbar görünür olur. Buradan silme veya taşıma gibi
işlemler başlatılabilir (deleteSelectedItems).
■ Kullanıcı sağ alt köşedeki FloatingActionButton'a basarak
AddClothingItemScreen'e gider.
7. Boş Gardırop Durumu (WardrobeLoaded ama items boş):
EmptyWardrobeView gösterilir.
● API/Servis Çağrıları (Girdi/Çıktı):
○ WardrobeRepository -> WardrobeRepositoryImpl -> ApiService:
■ Future<List<ClothingItem>> getItems(int page, int limit, {String?
searchTerm, List<String>? categoryIds, List<String>? seasons, bool
showOnlyFavorites = false, String? sortBy}): Kıyafet listesini çeker.
■ Girdi: Sayfa, limit, opsiyonel arama terimi, kategori ID'leri listesi
(varsayılanlar ve özel kategoriler), mevsimler listesi, sadece favoriler mi,
sıralama.
■ Çıktı: List<ClothingItem> veya Failure.
■ Future<void> deleteItem(String itemId): Bir kıyafeti siler.
■ Future<void> toggleFavorite(String itemId): Bir kıyafetin favori durumunu
değiştirir (backend ve local state güncellenir).
■ Future<void> deleteItems(List<String> itemIds): Çoklu silme işlemi.
○ WardrobeController, bu servis çağrılarını yönetir ve sonuçlara göre kendi
state'ini günceller.
● UX Detayları & Kenar Durumlar:
○ Tasarım: Material Design 3 prensiplerine uygun. Izgara (Grid) ve liste (List)
görünümü arasında geçiş yapılabilir. ClothingItemCard'lar, görsel ve metin
bilgileriyle kullanıcıya net bir şekilde kıyafeti tanıtmalı. AppBar'da kullanıcı
profiline hızlı erişim sağlar.
○ Arama ve Filtreleme: WardrobeSearchBar, AppBar'ın altında yer almalı. Metin
araması doğrudan kutuya yazılır. Filtreler için ayrı bir "Filtreler" butonu,
tıklandığında WardrobeFilterBottomSheet açılır. Bu panelde FilterChip'ler
kullanılır ve çoklu seçim desteklenir. Filtreler uygulandığında, backend çağrısı
tüm aktif filtreleri içerir.
○ CustomCategory Entegrasyonu: WardrobeFilterBottomSheet içinde,
customCategoriesProvider'dan gelen özel kategoriler, varsayılan kategorilerle
birlikte FilterChip olarak listelenir.
○ Boş Durum (EmptyWardrobeView): Kullanıcı dostu mesaj ve
AddClothingItemScreen'e yönlendirme butonu içerir.
○ Hata Durumu (WardrobeErrorView): Anlaşılır hata mesajı ve "Tekrar Dene"
butonu.
○ Yükleniyor Durumu (WardrobeLoadingView): Shimmer efekti veya Lottie
animasyonu.
○ Favori İşaretleme: ClothingItemCard'ın köşesinde bir kalp ikonu
(Icons.favorite_border/Icons.favorite). Tıklanabilir. toggleFavorite çağrısı yapılır.
○ Çoklu Seçim (Bulk Operations): ClothingItemCard'a uzun basmak çoklu
seçim modunu başlatır. WardrobeMultiSelectToolbar görünür olur. Seçilen
item'lar ClothingItemCard'da görsel olarak vurgulanır. Toolbar'da "Sil", "Taşı"
gibi butonlar olabilir.
○ Gardırop Temizliği Vurgusu: ClothingItemCard'da, lastWornDate 6 aydan
eskiyse, görselin köşesine küçük, dikkat çekici olmayan bir "⚠️" veya "!" ikonu
eklenebilir. (Bu, kullanıcıyı bilgilendirir ama UI'ı karmaşıklaştırmaz).
○ Kenar Durumları:
■ Ağ Hatası: Kıyafet listesi çekilirken ağ hatası oluşursa WardrobeErrorView
gösterilir.
■ Silme/Favori Onayı: Kullanıcı bir kıyafeti silmek istediğinde veya toplu
silme yaptığında, onay için bir Dialog gösterilmeli.
■ Çok Sayıda Kıyafet: WardrobeGridView/WardrobeListView için lazy
loading (infinite_scroll_pagination paketi gibi) uygulanmalı. Scroll listener,
listenin sonuna yaklaştığında loadItems'ı isRefresh=false ile çağırır.
■ Çevrimdışı:
■ Uygulama, daha önce yüklenmiş gardırop verisini local cache'ten (Hive
gibi) gösterebilmeli.
■ Offline durumda filtreleme yapılmaya çalışılırsa, local cache üzerinde
filtreleme yapılmalı veya "Offline filtreleme desteklenmiyor" mesajı
gösterilmeli. (En iyi senaryo: local cache yeterince zenginse, basit
filtreler offline çalışabilir).
■ Performans: cached_network_image ve precacheImage kullanılır.
Placeholder olarak basit bir ikon veya gri kutu kullanılır. Görsel yükleme
hatasında farklı bir placeholder gösterilebilir.
■ Placeholder & Yedek Görseller: CachedNetworkImage'ın placeholder ve
errorWidget parametreleri kullanılır. errorWidget için örneğin
Icon(Icons.error_outline) veya özel bir "Görsel Yok" widget'ı kullanılabilir.
3. Güncellenmiş ve Netleştirilmiş Özellik: AddClothingItemScreen
● Sayfa Adı ve Amacı:
○ AddClothingItemScreen: Kullanıcının gardırobuna yeni bir kıyafet eklemesini
sağlayan ekrandır. Bu ekran, kıyafetin görselinin seçilmesi, AI tarafından (veya
mock olarak) etiketlenmesi ve kullanıcı tarafından bu etiketlerin
onaylanması/düzenlenmesi adımlarını içerir. Amacı, kullanıcıya kıyafet ekleme
sürecini mümkün olduğu kadar sorunsuz ve hızlı bir şekilde sunmaktır.
● Ana Bileşenler (Widget/Class Adları):
○ AddClothingItemScreen (StatefulWidget - Form state ve yükleme durumlarını
yönetir)
○ AppBar (Flutter Widget - Başlık ("Add Clothing Item") ve geri navigasyon içerir)
○ ImagePickerWidget (Custom Widget - Galeri/kamera erişimi sağlar)
○ ImageCropperWidget (Custom Widget - Seçilen görseli kırpma ve döndürme
imkanı sunar. image_cropper gibi bir paket kullanılabilir)
○ ImagePreviewWidget (Custom Widget - Seçilen görseli gösterir)
○ AiTaggingLoadingView (Custom Widget - AI analizi yapılırken gösterilen
yükleme ekranı - shimmer/lottie)
○ AiTaggingErrorView (Custom Widget - AI analizi başarısız olursa gösterilen
hata ekranı)
○ ClothingDetailsForm (Custom Widget - AI/mock etiketlerin ve kullanıcı
girdilerinin bulunduğu form)
○ CategoryDropdown (Custom Widget - Kategori seçimi için dropdown menü)
○ ChipsInput (Custom Widget - AI ve kullanıcı etiketlerini göstermek/girmek için)
○ AddCustomCategoryDialog (Custom Widget - Yeni özel kategori oluşturmak
için dialog)
○ SaveClothingItemButton (Custom Widget - Formu onaylayıp kıyafeti
gardırobuna ekleyen buton)
○ AddClothingItemController (Riverpod StateNotifier - Bu ekranın state'ini
(görsel, etiketler, yükleme durumu, hata) yönetir)
○ WardrobeRepository (Interface - Gardırop verisi ile ilgili işlemleri tanımlar)
○ WardrobeRepositoryImpl (Implementation - WardrobeRepository'nin gerçek
uygulaması)
○ ImageUploadService (Service - Seçilen görsli lokalde resize etme ve sunucuya
yükleme işlemlerini yapar)
○ AiTaggingService (Service - Placeholder. Gelecekte AI etiketleme servisini
çağıracak)
● Veri Modeli & State Yönetimi:
○ AddClothingItemState (AddClothingItemController'ın yönettiği state):
class AddClothingItemState {
final File? selectedImage; // Seçilen yerel dosya
final String? uploadedImageUrl; // Sunucuya yüklendikten sonraki URL
final bool isImageUploading; // Görsel sunucuya yükleniyor mu?
final bool isAiTagging; // AI analiz ediliyor mu?
final List<String> aiGeneratedTags; // AI/mock tarafından üretilen etiketler
final Map<String, dynamic> extractedAttributes; // AI/mock'tan gelen
yapılandırılmış veri (kategori, renk, mevsim)
final Set<String> userTags; // Kullanıcının eklediği özel etiketler
final String? selectedCategoryId; // Seçilen kategori (varsayılan veya özel)
final String? name; // Kullanıcının verdiği isim (opsiyonel)
final bool isSaving; // Kıyafet veritabanına kaydediliyor mu?
final Object? error; // Hata durumunda hata objesi
AddClothingItemState({
this.selectedImage,
this.uploadedImageUrl,
this.isImageUploading = false,
this.isAiTagging = false,
this.aiGeneratedTags = const [],
this.extractedAttributes = const {},
this.userTags = const {},
this.selectedCategoryId,
this.name,
this.isSaving = false,
this.error,
});
AddClothingItemState copyWith({...}); // State güncellemeleri için
}
○ AddClothingItemController (Riverpod StateNotifier<AddClothingItemState>):
■ state: Mevcut AddClothingItemState.
■ pickImage(): ImagePickerWidget aracılığıyla kullanıcıdan görsel seçer.
Seçilen File'ı state.selectedImage'a atar.
■ uploadImage(): ImageUploadService'i kullanarak state.selectedImage'ı
sunucuya yükler. isImageUploading state'ini yönetir. Başarılı olursa
state.uploadedImageUrl'i günceller.
■ triggerAiTagging(): AiTaggingService'i çağırarak (state.uploadedImageUrl
kullanarak) AI analizini başlatır. isAiTagging state'ini yönetir. Başarılı olursa
aiGeneratedTags ve extractedAttributes'i günceller.
■ addUserTag(String tag): state.userTags set'ine yeni bir etiket ekler.
■ removeUserTag(String tag): state.userTags set'inden bir etiket çıkarır.
■ selectCategory(String categoryId): state.selectedCategoryId'yi günceller.
■ changeName(String newName): state.name'i günceller.
■ saveItem(): Tüm verileri bir ClothingItem objesinde toplar ve
WardrobeRepository aracılığıyla sunucuya kaydeder. isSaving state'ini
yönetir. Başarılı olursa kullanıcı WardrobeHomeScreen'e yönlendirilir.
■ retryAiTagging(): AI etiketleme hatası durumunda işlemi yeniden başlatır.
■ retryImageUpload(): Görsel yükleme hatası durumunda işlemi yeniden
başlatır.
○ Riverpod Providers:
■ addClothingItemControllerProvider: AddClothingItemController'ı sağlayan
StateNotifierProvider.
■ customCategoriesProvider: Kullanıcının özel kategorilerini sağlayan
Provider<List<CustomCategory>> (önceki ekrandan geliyor).
● Kullanıcı Akışı (Interaction Flow):
1. Kullanıcı WardrobeHomeScreen'den FloatingActionButton'a basar veya bir
yönlendirme ile bu ekrana gelir.
2. AddClothingItemScreen yüklenir. İlk durumda ImagePickerWidget görünür
olur.
3. Kullanıcı ImagePickerWidget'a tıklar ve galeriden bir görsel seçer veya kamera
ile yeni fotoğraf çeker.
4. pickImage() çağrılır, state.selectedImage güncellenir.
5. ImagePreviewWidget seçilen görseli gösterir. Bu widget'ın bir "Düzenle"
butonu vardır. Kullanıcı bu butona basarsa, ImageCropperWidget açılır.
Kullanıcı burada görseli kırparak/döndürerek "Tamam" butonuna basar.
Düzenlenmiş görsel state.selectedImage'ı günceller.
6. Otomatik olarak veya kullanıcı bir "Analiz Et" butonuna basarak uploadImage()
tetiklenir.
7. Görsel Yükleniyor: isImageUploading true olur, AiTaggingLoadingView
(örneğin, "Görsel Yükleniyor...") gösterilir.
8. Görsel Yükleme Hatası: uploadImage() başarısız olursa, AiTaggingErrorView
gösterilir. Kullanıcı "Yeniden Dene" (retryImageUpload) veya "Farklı Bir Resim
Seç" seçeneğine sahip olur.
9. Görsel Yükleme Başarılı: state.uploadedImageUrl güncellenir.
triggerAiTagging() otomatik olarak çağrılır.
10. AI Etiketleme Yapılıyor: isAiTagging true olur, AiTaggingLoadingView
(örneğin, shimmer ve "AI Analiz Ediliyor..." metni veya Lottie animasyonu)
gösterilir.
11. AI Etiketleme Hatası: triggerAiTagging() başarısız olursa, AiTaggingErrorView
gösterilir. Kullanıcı "Yeniden Dene" (retryAiTagging) seçeneğine sahip olur.
(Mock senaryoda bu adım genellikle başarılı kabul edilir).
12. AI Etiketleme Başarılı (veya Mock Veri Geldi): state.aiGeneratedTags ve
state.extractedAttributes (kategori, renk, mevsim) güncellenir.
13. ClothingDetailsForm görünür olur. Bu formda:
■ AI tarafından çıkarılan kategori, renk, mevsim gibi alanlar Dropdown veya
TextField'larda salt okunur veya düzenlenebilir olarak gösterilir.
■ ChipsInput, kullanıcıya AI etiketlerini (aiGeneratedTags) salt okunur Chip
olarak ve kendi etiketlerini (userTags) ekleyebileceği/düzenleyebileceği
şekilde sunar.
■ CategoryDropdown, varsayılan kategorileri ve
customCategoriesProvider'dan gelen özel kategorileri listeler. AI'nın
önerdiği kategori önceden seçili olabilir. Kullanıcı "Yeni Kategori Ekle"
butonuna basarak AddCustomCategoryDialog'u açabilir.
■ Kullanıcı, formdaki alanları (isim, kategori, özel etiketler) düzenleyebilir.
14. Kullanıcı SaveClothingItemButton'a basar.
15. saveItem() çağrılır. isSaving true olur.
16. Kayıt Yapılıyor: Loading göstergesi gösterilir.
17. Kayıt Hatası: Hata oluşursa, kullanıcıya mesaj gösterilir.
18. Kayıt Başarılı: Kullanıcı WardrobeHomeScreen'e yönlendirilir ve yeni kıyafet
orada listelenir. Ekranın alt kısmında yeşil bir SnackBar veya ekranın ortasında
kısa bir süre için bir Lottie animasyonuyla 'Kıyafet Eklendi!' mesajı gösterilir.
● API/Servis Çağrıları (Girdi/Çıktı):
○ ImageUploadService -> ApiService:
■ Future<String> uploadImage(File imageFile): Görseli sunucuya yükler.
■ Girdi: Yerel File objesi.
■ Çıktı: Yüklenen görselin URL'si veya Failure.
○ AiTaggingService -> ApiService (Placeholder/Gelecekte):
■ Future<Map<String, dynamic>> analyzeImage(String imageUrl): Görseli
analiz eder.
■ Girdi: Sunucudaki görsel URL'si.
■ Çıktı: Etiketler listesi ve yapılandırılmış özellikler (kategori, renk,
mevsim) içeren Map veya Failure.
○ WardrobeRepository -> WardrobeRepositoryImpl -> ApiService:
■ Future<void> addItem(ClothingItem item): Yeni bir kıyafet ekler.
■ Girdi: ClothingItem objesi.
■ Çıktı: Başarı veya Failure.
○ AddClothingItemController, bu servis çağrılarını sırayla yönetir: Önce
uploadImage, sonra triggerAiTagging, en son addItem.
● UX Detayları & Kenar Durumlar:
○ Tasarım: Material Design 3'e uygun. ImagePickerWidget, kullanıcıyı
yönlendiren açık ve davetkar bir tasarım olmalı. AiTaggingLoadingView için
shimmer veya Lottie kullanılır.
○ AI Etiketleme (Mock): Gerçek AI entegrasyonu hazır olana kadar,
triggerAiTagging() çağrıldığında sabit/mock veriler state'e yüklenir.
○ UI/UX İyileştirmeleri: AddClothingItemScreen'deki form, AI'dan gelen
verilerle önceden doldurulmalı, böylece kullanıcı daha az manuel giriş yapmak
zorunda kalır.
○ Görsel Düzenleme: Kullanıcı, ImagePreviewWidget'taki "Düzenle" butonu ile
ImageCropperWidget'ı açabilir. Bu, AI'ın analiz edeceği alanı daraltarak daha
doğru etiketleme yapılmasına yardımcı olur.
○ Form Validasyonu: ClothingDetailsForm içinde, form alanları için inline
validasyon kuralları tanımlanır:
■ CategoryDropdown: Seçim zorunludur. Seçim yapılmazsa, dropdown
altında kırmızı bir hata mesajı ("Lütfen bir kategori seçin") gösterilir.
■ Etiketler (ChipsInput): En az 1 etiket (AI'dan gelen veya kullanıcıdan gelen)
zorunludur. Aksi halde hata mesajı gösterilir.
■ SaveClothingItemButton: Validasyon kuralları sağlanana kadar buton devre
dışı bırakılır. Tüm kurallar sağlanırsa buton aktif hale gelir.
○ Kullanıcı Geri Bildirimi: Kıyafet başarıyla eklendiğinde, kullanıcıya olumlu geri
bildirim verilmelidir (SnackBar veya Lottie animasyonu).
○ Hata Durumları:
■ Görsel Seçilmedi: Kullanıcı "Analiz Et" butonuna basmadan önce görsel
seçmemişse, uyarı mesajı gösterilir.
■ Yükleme/AI Hatası: AiTaggingErrorView açıklayıcı hata mesajı ve "Yeniden
Dene" butonu içermelidir.
■ Kayıt Hatası: saveItem() başarısız olursa, kullanıcıya uygun hata mesajı
gösterilir.
■ Kırpma İptali: Kullanıcı ImageCropperWidget'ta "İptal" butonuna basarsa,
orijinal seçilen görsel korunur.
○ Kenar Durumları:
■ Çevrimdışı: Bu ekran, görsel yükleme ve AI etiketleme gibi işlemleri
gerektirdiği için çevrimdışı çalışamaz.
■ Büyük Görsel: Seçilen görsel çok büyükse, ImageUploadService
yüklemeden önce lokalde resize etmelidir.
■ Aynı İsimle Kategori Oluşturma: AddCustomCategoryDialog'da kullanıcı
aynı isimle kategori oluşturmaya çalışırsa, açıklayıcı bir hata mesajı
gösterilmelidir.
4. Nihai ve Güncellenmiş Özellik: StyleAssistantScreen
● Sayfa Adı ve Amacı:
○ StyleAssistantScreen: Kullanıcının kişisel stil asistanıyla doğal dilde
yazışabildiği, sesli iletişim kurabildiği ve AI tarafından üretilen kombin/ürün
önerilerini görebildiği temel sohbet ekranıdır. Amacı, kullanıcıya entegre, akıcı
ve bağlamsal bir asistan deneyimi sunmaktır.
● Ana Bileşenler (Widget/Class Adları):
○ StyleAssistantScreen (StatelessWidget veya ConsumerWidget - Riverpod ile
state dinler)
○ AppBar (Flutter Widget - Başlık ("Style Assistant") ve "Yeni Sohbet" gibi
opsiyonel butonlar içerir)
○ ChatListView (Custom Widget - Mesajları (ChatBubble) dikey olarak listeleyen
alan)
○ ChatBubble (Custom Widget - Tek bir kullanıcı veya AI mesajını gösteren
konuşma baloncuğu)
○ InputBar (Custom Widget - Kullanıcının mesaj yazdığı ve gönderdiği alan)
○ VoiceInputButton (Custom Widget - Sesli moda geçmek için mikrofon ikonu)
○ ImageInputButton (Custom Widget - Görsel paylaşmak için galeri ikonu
(Icons.photo))
○ StyleAssistantController (Riverpod StateNotifier - Sohbet geçmişi, yükleme
durumu, sesli mod durumu gibi state'leri yönetir)
○ StyleAssistantRepository (Interface - Stil asistanı ile ilgili işlemleri tanımlar)
○ StyleAssistantRepositoryImpl (Implementation - StyleAssistantRepository'nin
gerçek uygulaması)
○ STTService (Service - Placeholder. Sesli konuşma tanıma servisi)
○ TTSService (Service - Placeholder. AI yanıtını seslendirme servisi)
○ OutfitCard (Custom Widget - AI'ın önerdiği bir kombini gösterir)
○ ProductCard (Custom Widget - AI'ın önerdiği bir ürünü gösterir)
○ MissingItemsSection (Custom Widget - Bir kombinde eksik olan ürünleri
listeleyen bölüm)
○ ImagePreview (Custom Widget - Sohbette paylaşılan görselin küçük
önizlemesini gösterir)
○ QuickActionChips (Custom Widget - Hızlı sorgu için önceden tanımlı
butonlar/chip'ler)
● Veri Modeli & State Yönetimi:
○ ChatMessage:
abstract class ChatMessage {
final String id;
final DateTime timestamp;
ChatMessage({required this.id, required this.timestamp});
}
class UserMessage extends ChatMessage {
final String text;
final String? imageUrl;
UserMessage({required super.id, required super.timestamp, required
this.text, this.imageUrl});
}
class AiMessage extends ChatMessage {
final String? text;
final List<Outfit>? outfits;
final List<Product>? products;
final bool isGenerating;
AiMessage({required super.id, required super.timestamp, this.text,
this.outfits, this.products, this.isGenerating = false});
}
○ Outfit:
class Outfit {
final String id;
final String name;
final String? coverImageUrl;
final List<String> clothingItemIds;
final DateTime createdAt;
final bool isFavorite;
}
○ Product:
class Product {
final String id;
final String name;
final String imageUrl;
final double price;
final String currency;
final String seller;
final String externalUrl;
final double? carbonFootprintKg;
final int greenScore;
}
○ StyleAssistantState:
class StyleAssistantState {
final List<ChatMessage> messages;
final bool isVoiceModeActive;
final bool isListening;
final bool isSpeaking;
final Object? error;
StyleAssistantState({this.messages = const [], this.isVoiceModeActive =
false, this.isListening = false, this.isSpeaking = false, this.error});
StyleAssistantState copyWith({...});
}
○ StyleAssistantController:
■ sendMessage(String text, {String? imageUrl}): Kullanıcı mesajını gönderir
ve AI yanıtını tetikler.
■ getAiResponse(UserMessage userMessage): AI'dan yanıt alır (streaming).
■ toggleVoiceMode(), startListening(), stopListening(), speakText(String
text), stopSpeaking(): Sesli mod kontrolleri.
■ pickImageAndSend(): Görsel seçip gönderir.
■ retrySendMessage(ChatMessage message): Hatalı gönderimi yeniden
dener.
● Kullanıcı Akışı (Interaction Flow):
1. Kullanıcı StyleAssistant sekmesine tıklar.
2. StyleAssistantScreen yüklenir, sohbet geçmişi listelenir.
3. Metinle Sohbet: Kullanıcı metin yazar, gönderir. sendMessage çağrılır. Yeni
UserMessage listeye eklenir. getAiResponse tetiklenir. AiMessage (yazıyor...)
eklenir, ardından yanıt geldikçe güncellenir.
4. Görsel Paylaşımı: Kullanıcı galeri ikonuna basar. pickImageAndSend çağrılır.
Görsel seçilir, yüklenir ve imageUrl ile boş bir mesaj gönderilir.
5. Sesli Sohbet: Kullanıcı mikrofon ikonuna basar. toggleVoiceMode çağrılır.
Kullanıcı konuşur, startListening ile STT başlar. Gelen metin anında
sendMessage ile gönderilir. AI yanıtı geldiğinde speakText ile TTS başlar.
6. Hızlı Eylemler: Kullanıcı QuickActionChips'lere tıklayarak hazır sorguları
gönderir.
7. Etkileşim: ProductCard'taki "Satın Al" butonu dış linke yönlendirir. OutfitCard
favorilere eklenebilir.
● API/Servis Çağrıları (Girdi/Çıktı):
○ StyleAssistantRepository -> ApiService:
■ Future<Stream<AiMessage>> getAiResponseStream(UserMessage
userMessage, {CancelToken? cancelToken}): Kullanıcı mesajını alır ve AI
yanıtını WebSocket veya Server-Sent Events (SSE) üzerinden bir Stream
olarak döner. cancelToken ile istek iptal edilebilir.
■ Future<String> uploadImage(File imageFile): Görsel yükler.
○ STTService: startListening(...) ile mikrofonu açar ve sesi metne çevirir.
○ TTSService: speak(...) ile metni seslendirir.
● UX Detayları & Kenar Durumlar:
○ Tasarım: ChatBubble'lar kullanıcı ve AI için farklı stillerde (sağ/mavi, sol/gri)
olmalı.
○ Otomatik Kaydırma (Auto-scroll): Yeni mesaj geldiğinde liste otomatik
olarak en alta kaydırılır.
○ Mesaj Silme/Düzenleme: Kullanıcı kendi mesajına uzun basarak açılan
menüden "Sil" veya "Düzenle" seçeneklerini kullanabilir.
○ Konuşma İptali (Interrupt): AI yanıtlarken kullanıcı yeni mesaj gönderirse,
önceki AI yanıtı stream'i iptal edilir.
○ Cache'lenmiş Yanıtlar: Tekrarlanan sorgular için LRUCache kullanılarak
yanıtlar cache'lenebilir.
○ UI/UX İyileştirmeleri: InputBar'da Icons.photo kullanımı, QuickActionChips ve
gerçek zamanlı STT/TTS deneyimi iyileştirir.
○ Görsel Paylaşımı: Seçilen görsel sohbete ImagePreview olarak eklenir.
○ Ürün Önerisi: Ürün önerileri (ProductCard listesi) metin yanıtıyla aynı
AiMessage baloncuğu içinde gösterilir.
○ Geri Bildirim: "AI yazıyor..." animasyonu, "Dinliyorum..." göstergesi ve hata
durumunda "Yeniden Dene" seçeneği sunulur.
○ Kenar Durumları: Ağ hatası, çevrimdışı durum, sesli mod hataları (mikrofon
izni reddi) ve uzun mesajlar yönetilir. ListView.builder ve
cached_network_image ile performans optimize edilir.
5. Nihai ve Güncellenmiş Özellik: WardrobeAnalyticsScreen
● Sayfa Adı ve Amacı:
○ WardrobeAnalyticsScreen: Kullanıcının dijital gardırobunun istatistiksel
özetini, içgörülerini ve kişiselleştirilmiş önerilerini sunduğu ekrandır. Amacı,
kullanıcıya gardırobunun durumu hakkında bilgi vermek, eksik öğeleri tespit
etmek, alışveriş önerileri sunmak ve sürdürülebilirlik bilinci artırmaktır.
● Ana Bileşenler (Widget/Class Adları):
○ WardrobeAnalyticsScreen
○ AppBar
○ TabBar & TabBarView ("İstatistikler", "Öneriler", "Alışveriş Rehberi")
○ StatisticsTab, InsightsTab, ShoppingGuideTab
○ PieChartWidget, BarChartWidget
○ InsightCard, ShoppingGuideItemCard
○ WardrobeAnalyticsController, WardrobeAnalyticsRepository
● Veri Modeli & State Yönetimi:
○ WardrobeAnalyticsState:
class WardrobeAnalyticsState {
final Map<String, int> categoryDistribution;
final Map<String, int> colorDistribution;
final Map<String, int> seasonDistribution;
final Map<String, double> carbonByCategory; // Yeni
final double totalCarbonFootprint; // Yeni
final int totalItems;
final ClothingItem? mostWornItem;
final List<Insight> insights;
final List<ShoppingGuideItem> shoppingGuides;
final TimeRange selectedTimeRange; // Yeni
final bool isLoading;
final bool isLoadingMoreInsights; // Yeni
final bool isLoadingMoreGuides; // Yeni
final Object? error;
WardrobeAnalyticsState copyWith({...});
}
enum TimeRange { last7Days, last30Days, allTime }
○ Insight:
class Insight {
final String id;
final String title;
final String description;
final String actionType; // "ai_query", "ecommerce_link", "view_item",
"add_to_favorites"
final String? actionPayload;
final bool isFavorite; // Yeni
}
○ ShoppingGuideItem:
class ShoppingGuideItem {
final String id;
final String title;
final String description;
final String imageUrl;
final String aiQuery;
}
○ WardrobeAnalyticsController:
■ loadAnalytics({bool isRefresh = false}): Analitik verilerini yükler.
■ refreshAnalytics(): Verileri yeniler.
■ changeTimeRange(TimeRange newRange): Zaman aralığını değiştirir ve
verileri yeniden yükler.
■ loadMoreInsights(), loadMoreShoppingGuides(): Pagination için daha fazla
veri yükler.
■ toggleInsightFavorite(String insightId): Bir içgörüyü favorilere ekler/çıkarır.
● Kullanıcı Akışı (Interaction Flow):
1. Kullanıcı ProfileScreen'den "Gardırop Analitiği"ne tıklar.
2. WardrobeAnalyticsScreen yüklenir. loadAnalytics çağrılır.
3. Yükleme/Hata durumları yönetilir.
4. Veri Geldiğinde:
■ TabBar görünür olur.
■ İstatistikler Sekmesi:
■ Pasta ve çubuk grafikler (kategori, renk, mevsim, karbon ayak izi
dağılımı).
■ Temel istatistikler (toplam eşya, toplam karbon).
■ Zaman aralığı seçimi için SegmentedControl veya DropdownButton.
■ Öneriler Sekmesi:
■ InsightCard'lar listelenir. Her kartta actionType'a göre farklı eylem
butonu bulunur.
■ Her kartta favorilere ekleme ikonu bulunur.
■ Liste sonuna gelindiğinde loadMoreInsights ile yeni veriler yüklenir.
■ Alışveriş Rehberi Sekmesi:
■ ShoppingGuideItemCard'lar listelenir.
■ Liste sonuna gelindiğinde loadMoreShoppingGuides ile yeni veriler
yüklenir.
● API/Servis Çağrıları (Girdi/Çıktı):
○ WardrobeAnalyticsRepository -> ApiService:
■ Future<WardrobeAnalyticsData> getAnalytics({TimeRange timeRange,
bool forceRefresh = false}): Analitik verilerini çeker.
■ Future<List<Insight>> getInsightsPaginated(...),
Future<List<ShoppingGuideItem>> getShoppingGuidesPaginated(...):
Sayfalama için çağrılar.
■ Future<void> updateInsightFavoriteStatus(...): İçgörü favori durumunu
günceller.
● UX Detayları & Kenar Durumlar:
○ Tasarım: Grafikler ve kartlar kullanıcı dostu ve anlaşılır olmalı.
○ Zaman Aralığı Seçimi: Kullanıcı, istatistiklerin hesaplanacağı zaman aralığını
seçebilir.
○ Karbon Ayak İzi Grafiği: Kategori bazlı karbon emisyonu çubuk grafikle
gösterilir.
○ Insight Eylem Butonları: Butonlar, actionType'a göre değişen ikon ve
etiketlerle bağlama uygun eylemler sunar.
○ Favori Insight'lar: Kullanıcı önemli içgörüleri favorileyebilir.
○ Cache/Eşzamanlı Güncelleme: Ekran açıldığında önce cache'lenmiş veriden
hızlı bir ön yükleme yapılır, ardından API'den güncel veri ile state güncellenir.
○ Performans (Pagination): Uzun listeler için sayfalama kullanılır.
○ Kenar Durumları: Ağ hatası, veri olmaması, çevrimdışı durum yönetilir.
6. Nihai ve Güncellenmiş Özellik: MyCombinationsScreen
● Sayfa Adı ve Amacı:
○ MyCombinationsScreen: Kullanıcının, gardırobundaki kıyafetlerle
oluşturduğu ve kaydettiği tüm kombinlerin listelendiği ekrandır. Kullanıcı
burada kombinlerini arayabilir, görüntüleyebilir, yeni kombinler oluşturabilir,
mevcutları düzenleyebilir, silebilir ve toplu işlemler yapabilir.
● Ana Bileşenler (Widget/Class Adları):
○ MyCombinationsScreen
○ AppBar (Arama butonu içerir)
○ CombinationsGridView, CombinationsListView
○ CombinationCard
○ EmptyCombinationsView, CombinationsErrorView, CombinationsLoadingView
○ FloatingActionButton (CreateCombinationScreen'e yönlendirir)
○ CombinationsMultiSelectToolbar (Toplu işlemler için)
○ CombinationsController, CombinationsRepository
● Veri Modeli & State Yönetimi:
○ Combination:
class Combination {
final String id;
final String name;
final String? coverImageUrl;
final List<String> clothingItemIds;
final DateTime createdAt;
final bool isFavorite;
final bool isPublic;
final int likeCount;
final int commentCount;
final String? originalRemixedFromId; // Kombin Remix için
}
○ CombinationsState:
class CombinationsState {
final List<Combination> combinations;
final bool hasReachedMax;
final String sortBy;
final bool isGridView;
final String searchTerm; // Yeni
final bool isMultiSelectMode; // Yeni
final Set<String> selectedCombinationsInMultiSelect; // Yeni
final bool isLoading;
final bool isLoadingMore; // Yeni
final Object? error;
CombinationsState copyWith({...});
}
○ CombinationsController:
■ loadCombinations, loadMoreCombinations, refreshCombinations: Veri
yükleme ve sayfalama.
■ sortCombinations, toggleView: Görüntüleme seçenekleri.
■ searchCombinations(String term): Arama yapar.
■ deleteCombination, toggleFavorite: Tekil işlemler.
■ enterMultiSelectMode, exitMultiSelectMode,
toggleCombinationSelectionInMultiSelect, deleteSelectedCombinations:
Toplu işlemler.
■ syncOfflineChanges: Çevrimdışı yapılan değişiklikleri senkronize eder.
● Kullanıcı Akışı (Interaction Flow):
1. Kullanıcı MyCombinationsScreen'e gelir.
2. loadCombinations ile veriler yüklenir.
3. Veri Geldiğinde:
■ Kombinler grid/list olarak gösterilir.
■ Kullanıcı AppBar'daki arama ikonu ile arama yapabilir.
■ Kullanıcı bir CombinationCard'a tıklayarak CombinationDetailScreen'e
gider.
■ Kullanıcı bir CombinationCard'a uzun basarak çoklu seçim moduna girer.
CombinationsMultiSelectToolbar ile toplu silme gibi işlemler yapabilir.
■ Kullanıcı FloatingActionButton ile yeni kombin oluşturur.
■ Liste sonuna gelindiğinde loadMoreCombinations ile yeni veriler yüklenir.
4. Deep Link: myapp://combination/abc123 gibi bir link, kullanıcıyı doğrudan ilgili
CombinationDetailScreen'e yönlendirir.
● API/Servis Çağrıları (Girdi/Çıktı):
○ CombinationsRepository -> ApiService:
■ Future<List<Combination>> getCombinations(..., {String? searchTerm}):
Arama terimi desteği eklendi.
■ Future<void> deleteCombinations(List<String> combinationIds): Toplu
silme desteği eklendi.
■ Future<void> syncOfflineChanges(...): Çevrimdışı değişiklikleri senkronize
eder.
● UX Detayları & Kenar Durumlar:
○ Arama & Filtre: AppBar'daki arama ikonu ile arama çubuğu açılır.
○ Çoklu Seçim (Bulk Actions): Uzun basma ile çoklu seçim modu başlar. Üstte
çıkan toolbar ile toplu işlemler yapılır.
○ Paylaşım Akışı: "Paylaş" aksiyonu, share_plus paketi gibi bir servis ile
platformun paylaşma menüsünü açar.
○ Deep Link / Hızlı Erişim: GoRouter ile /combination/:id yolu tanımlanır.
○ Analitik & Telemetri: Kritik kullanıcı eylemleri (create, delete, share)
AnalyticsService ile loglanır.
○ Offline Düzeyi: Çevrimdışı yapılan silme, favori yapma gibi işlemler bir
"bekleyen değişiklikler" kuyruğuna alınır ve online olunduğunda
syncOfflineChanges ile senkronize edilir.
7. Özellik: CreateCombinationScreen
● Sayfa Adı ve Amacı:
○ CreateCombinationScreen: Kullanıcının gardırobundaki kıyafetleri seçerek
yeni bir kombin oluşturduğu veya mevcut bir kombini düzenlediği ekrandır.
Amacı, kullanıcıya sezgisel ve esnek bir araç sağlayarak, kendi tarzını yansıtan
kombinler hazırlamasını kolaylaştırmaktır.
● Ana Bileşenler (Widget/Class Adları):
○ CreateCombinationScreen (StatefulWidget)
○ AppBar ("Kaydet" butonu içerir)
○ CombinationNameField (TextField)
○ CoverImagePicker
○ WardrobeItemsSelector (Gardıroptan çoklu kıyafet seçimi)
○ SelectedItemsPreview (Seçilen kıyafetlerin önizlemesi)
○ CreateCombinationController, CombinationsRepository, WardrobeRepository
● Veri Modeli & State Yönetimi:
○ CreateCombinationState:
class CreateCombinationState {
final String? combinationId; // Düzenleme modu için
final String name;
final String? coverImageUrl;
final File? newCoverImageFile;
final bool isCoverImageUploading;
final List<String> selectedClothingItemIds;
final bool isSaving;
final Object? error;
CreateCombinationState copyWith({...});
}
○ CreateCombinationController:
■ initCombination(String? combinationIdToEdit): Düzenleme veya remix
modu için ekranı başlatır.
■ changeName, pickCoverImage, removeCoverImage, uploadCoverImage:
Form alanlarını yönetir.
■ selectClothingItem, deselectClothingItem: Kıyafet seçimini yönetir.
■ saveCombination(): Yeni kombini oluşturur veya mevcut olanı günceller.
● Kullanıcı Akışı (Interaction Flow):
1. Kullanıcı MyCombinationsScreen'den "Yeni Ekle" veya bir kombinin "Düzenle"
butonuna tıklar.
2. CreateCombinationScreen yüklenir. Düzenleme/remix modundaysa, form
mevcut verilerle doldurulur.
3. Kullanıcı kombin ismini girer.
4. (Opsiyonel) Kullanıcı kapak görseli seçer/yükler.
5. Kullanıcı WardrobeItemsSelector ile gardırobundan kıyafetleri seçer.
6. Seçilen kıyafetler SelectedItemsPreview'da gösterilir.
7. Kullanıcı "Kaydet" butonuna tıklar. saveCombination çağrılır.
8. Veriler doğrulanır, (varsa) kapak görseli yüklenir ve kombi sunucuya kaydedilir.
9. Başarılı olunca kullanıcı MyCombinationsScreen'e yönlendirilir.
● API/Servis Çağrıları (Girdi/Çıktı):
○ CombinationsRepository -> ApiService:
■ getCombinationById: Düzenleme için kombi verisini çeker.
■ uploadImage: Kapak görselini yükler.
■ createCombination, updateCombination: Kombiyi kaydeder/günceller.
○ WardrobeRepository -> ApiService:
■ getAllClothingItems: Kıyafet seçici için tüm kıyafetleri çeker.
● UX Detayları & Kenar Durumlar:
○ Tasarım: Form tamamlanana kadar "Kaydet" butonu devre dışı bırakılabilir.
○ UI/UX İyileştirmeleri: WardrobeItemsSelector içinde arama/filtreleme olabilir.
SelectedItemsPreview seçimi kolaylaştırır.
○ Form Doğrulama: Kombin ismi zorunlu olabilir.
○ Hata Durumları: Yükleme/kayıt hataları yönetilir.
○ Kenar Durumları: Çevrimdışı çalışma desteklenmez. Büyük görseller
yüklenmeden önce resize edilir.
8. Özellik: CombinationDetailScreen
● Sayfa Adı ve Amacı:
○ CombinationDetailScreen: Kullanıcının oluşturduğu veya başkalarının
paylaştığı tek bir kombinin detaylı bilgilerini görüntülediği ekrandır. Sosyal
etkileşimi (beğeni, yorum, paylaşım, remix) kolaylaştırır.
● Ana Bileşenler (Widget/Class Adları):
○ CombinationDetailScreen
○ AppBar (Kullanıcının kendi kombiniyse "Düzenle", "Sil" menüsü içerir)
○ CombinationHeader (Kapak görseli, ad, beğeni/yorum sayısı)
○ ClothingItemsList (Kombindeki kıyafetlerin listesi)
○ CombinationActions (Favori, yorum, paylaş, remix butonları)
○ CommentsSection (Yorumları listeler ve yeni yorum ekleme alanı sunar)
○ CombinationDetailController, CombinationsRepository, CommentsRepository
● Veri Modeli & State Yönetimi:
○ CombinationDetailState:
class CombinationDetailState {
final Combination? combination;
final List<Comment> comments;
final bool isLoading;
final bool isLoadingComments;
final bool isSavingComment;
final bool isPerformingAction;
final Object? error;
CombinationDetailState copyWith({...});
}
○ Comment:
class Comment {
final String id;
final String userId;
final String userDisplayName;
final String userAvatarUrl;
final String text;
final DateTime createdAt;
}
○ CombinationDetailController:
■ loadCombination, loadComments: Verileri yükler.
■ toggleFavorite, addComment, deleteComment, shareCombination,
remixThisCombination, deleteCombination: Kullanıcı eylemlerini yönetir.
● Kullanıcı Akışı (Interaction Flow):
1. Kullanıcı bir CombinationCard'a tıklar.
2. CombinationDetailScreen yüklenir. loadCombination ve loadComments
çağrılır.
3. Veri Geldiğinde:
■ CombinationHeader kombinin üst bilgilerini gösterir.
■ ClothingItemsList kombindeki kıyafetleri listeler.
■ CombinationActions ile kullanıcı favoriye ekleyebilir, paylaşabilir, remix
yapabilir.
■ CommentsSection ile kullanıcı yorumları okuyabilir ve yeni yorum
ekleyebilir.
■ Kullanıcı kendi kombiniyse AppBar'daki menüden düzenleyebilir veya
silebilir.
● API/Servis Çağrıları (Girdi/Çıktı):
○ CombinationsRepository -> ApiService: getCombinationById,
updateCombination, deleteCombination.
○ CommentsRepository -> ApiService: getCommentsForCombination,
addComment, deleteComment.
○ ShareService: Kombini paylaşır.
● UX Detayları & Kenar Durumlar:
○ Tasarım: Net ve erişilebilir olmalı.
○ Hata/Yükleniyor Durumları: Shimmer efektleri ve hata mesajları ile yönetilir.
○ Kenar Durumları: Ağ hatası, boş yorum gönderiminin engellenmesi, çok
sayıda yorum için lazy loading, çevrimdışı durum yönetilir. Kritik eylemler için
analitik loglama yapılır.
9. Nihai ve Güncellenmiş Özellik: SocialFeedScreen
● Sayfa Adı ve Amacı:
○ SocialFeedScreen: Kullanıcıların başkalarının paylaştığı kombinleri görebildiği,
beğenebildiği, yorum yapabildiği, kaydedebildiği ve filtreleyebildiği sosyal akış
ekranıdır. Amacı, topluluk etkileşimini ve stil ilhamını teşvik etmektir.
● Ana Bileşenler (Widget/Class Adları):
○ SocialFeedScreen
○ AppBar
○ FeedFilterBar (Stil etiketleri, topluluklar ve sıralama seçenekleri için)
○ SocialPostsListView
○ SocialPostCard (Gönderi kartı)
○ SocialFeedController, SocialFeedRepository
● Veri Modeli & State Yönetimi:
○ SocialPost:
class SocialPost {
final String id;
final String authorId;
final String authorDisplayName;
final String authorAvatarUrl;
final String combinationId;
// ...
final List<String> styleTags;
final String? communityId;
final bool isLikedByCurrentUser; // Yeni
final bool isSavedByCurrentUser; // Yeni
final bool isNSFW; // Yeni
}
○ SocialFeedState:
class SocialFeedState {
final List<SocialPost> posts;
final bool hasReachedMax;
final Set<String> selectedStyleTags;
final String? selectedCommunityId;
final FeedSortOption sortOption; // Yeni
final bool isLoading;
final bool isLoadingMore;
final Object? error;
SocialFeedState copyWith({...});
}
enum FeedSortOption { mostRecent, mostPopular, trending }
○ SocialFeedController:
■ loadPosts, loadMorePosts, refreshPosts: Veri yükleme ve sayfalama.
■ toggleStyleTagFilter, selectCommunity, changeSortOption: Filtreleme ve
sıralama.
■ likePost, unlikePost, savePost, unsavePost: Beğeni/Kaydetme işlemleri.
■ reportPost, blockUser: İçerik moderasyonu.
■ syncOfflineActions: Çevrimdışı eylemleri senkronize eder.
● Kullanıcı Akışı (Interaction Flow):
1. Kullanıcı Social Feed sekmesine tıklar.
2. loadPosts ile veriler yüklenir.
3. Veri Geldiğinde:
■ FeedFilterBar ile kullanıcı akışı filtreleyebilir ve sıralayabilir.
■ SocialPostsListView gönderileri listeler.
■ Her SocialPostCard'da kullanıcı gönderiyi beğenebilir, kaydedebilir, yorum
yapmak veya detayları görmek için tıklayabilir.
■ Kart üzerindeki üç nokta menüsünden "Bildir", "Engelle" gibi moderasyon
işlemleri yapılabilir.
■ Kart üzerinde kaydırma (swipe) veya uzun basma gibi mikro-etkileşimler
olabilir.
● API/Servis Çağrıları (Girdi/Çıktı):
○ SocialFeedRepository -> ApiService:
■ getPosts: Filtre ve sıralama parametreleri ile gönderileri çeker.
■ likePost, unlikePost, savePost, unsavePost: Beğeni/kaydetme.
■ reportPost, blockUser: Moderasyon.
■ syncOfflineActions: Çevrimdışı eylemleri senkronize eder.
● UX Detayları & Kenar Durumlar:
○ Bildirim ve Abonelikler: Yeni beğeni/yorum/gönderi için push bildirimi
(FirebaseMessaging). Anlık güncellemeler için WebSocket veya GraphQL
Subscription.
○ İçerik Moderasyonu & Güvenlik: "Bildir", "Engelle", "Sessize Al" seçenekleri.
Sunucu tarafında NSFW filtreleme.
○ Erişilebilirlik & Uluslararasılaştırma: Widget'lar için semanticsLabel,
metinler için AppLocalizations.
○ Performans & Ölçeklenebilirlik: Farklı çözünürlükte görseller, sunucu
tarafında optimize edilmiş sorgular ve indeksler, CDN kullanımı.
○ Çevrimdışı Destek: Cache'ten veri gösterme ve offline eylemleri kuyruğa alıp
online olunca senkronize etme.
○ Test & Kalite: Widget, notifier ve entegrasyon testleri.
○ Kullanıcı Deneyimi İyileştirmeleri: Swipe jestleri, "peek & pop" önizleme,
beğeni animasyonları.
○ Analitik Detayları: Scroll derinliği, etiket/topluluk ilgisi gibi metrikler toplanır.
10. Özellik: UserProfileScreen
● Sayfa Adı ve Amacı:
○ UserProfileScreen: Kullanıcının kendi profilini, istatistiklerini, sosyal
etkileşimlerini (kombinler, favoriler vb.) ve hesap ayarlarını yönettiği merkezi
kontrol panelidir.
● Ana Bileşenler (Widget/Class Adları):
○ UserProfileScreen
○ AppBar ("Ayarlar" butonu içerir)
○ ProfileHeader (Avatar, ad, biyografi, Aura Puanı)
○ AuraScoreDisplay (Puan, rozet ve ilerleme çubuğu)
○ ProfileStatsRow (Kombin, favori, takipçi sayısı)
○ ProfileTabBar & ProfileTabBarView ("Kombinlerim", "Favorilerim",
"Beğenilerim", "Sosyal Paylaşımlarım", "Topluluklar", "Swap Geçmişi")
○ UserProfileController, UserProfileRepository
● Veri Modeli & State Yönetimi:
○ UserProfileState:
class UserProfileState {
final User? user;
final int auraScore;
final int userLevel;
final double levelProgress;
final Map<String, int> profileStats;
final bool isLoading;
final Object? error;
UserProfileState copyWith({...});
}
○ User:
class User {
final String id;
final String displayName;
final String? avatarUrl;
final String? bio;
final Map<String, dynamic> settings; // Gizlilik ayarları
}
○ UserProfileController:
■ loadUserProfile, refreshUserProfile: Profil verisini yükler/yeniler.
■ updateBio: Biyografiyi günceller.
■ navigateToSettings: Ayarlar ekranına yönlendirir.
● Kullanıcı Akışı (Interaction Flow):
1. Kullanıcı Profile sekmesine tıklar.
2. UserProfileScreen yüklenir, loadUserProfile çağrılır.
3. Veri Geldiğinde:
■ ProfileHeader, AuraScoreDisplay, ProfileStatsRow kullanıcının temel
bilgilerini ve istatistiklerini gösterir.
■ ProfileTabBarView ile kullanıcı kendi kombinlerini, favorilerini, beğenilerini,
sosyal paylaşımlarını, topluluklarını ve takas geçmişini ayrı sekmelerde
görebilir.
■ "Ayarlar" butonu ile PrivacySettingsScreen gibi ekranlara gidebilir.
● API/Servis Çağrıları (Girdi/Çıktı):
○ UserProfileRepository -> ApiService:
■ getUserProfile: Kullanıcının tüm profil verisini çeker.
■ updateUserBio: Biyografiyi günceller.
● UX Detayları & Kenar Durumlar:
○ Tasarım: ProfileHeader dikkat çekici olmalı. Sekmeler arası geçişler hızlı
olmalı.
○ Aura Puanı & Seviye: AuraScoreDisplay kullanıcıyı motive edecek şekilde
(rozetler, ilerleme çubuğu) tasarlanmalı.
○ Gizlilik Ayarları Entegrasyonu: Bu ekranda gösterilen veriler, kullanıcının
gizlilik ayarlarına göre filtrelenmelidir.
○ Kenar Durumları: Ağ hatası, çevrimdışı durum (temel veriler cache'ten
gösterilir), performans (sekme içerikleri lazy load edilir) yönetilir.
11. Özellik: WardrobePlannerScreen
● Sayfa Adı ve Amacı:
○ WardrobePlannerScreen: Kullanıcının, kombinlerini takvim üzerinde günlere
planlayabildiği ve hava durumuyla entegre öneriler alabildiği ekrandır.
● Ana Bileşenler (Widget/Class Adları):
○ WardrobePlannerScreen
○ AppBar
○ PlannerCalendarView (TableCalendar gibi)
○ PlannedOutfitCard (Takvimde planlanmış kombin kartı)
○ CombinationDragTarget (Kombinlerin bırakılacağı takvim hücresi)
○ DraggableCombinationCard (Sürüklenebilir kombin kartı)
○ WeatherInfoDisplay (Hava durumu bilgisi)
○ WeatherWarningBanner (Hava durumu uyarıları)
○ WardrobePlannerController, WardrobePlannerRepository, WeatherService
● Veri Modeli & State Yönetimi:
○ WardrobePlannerState:
class WardrobePlannerState {
final List<PlannedOutfit> plannedOutfits;
final Map<DateTime, WeatherSnapshot> weatherData; // Yeni
final DateTime focusedDay;
final DateTime selectedDay;
final bool isLoading;
final bool isSaving;
final Object? error;
WardrobePlannerState copyWith({...});
}
○ PlannedOutfit:
class PlannedOutfit {
final String id;
final DateTime date;
final String combinationId;
final WeatherSnapshot plannedWeather; // Yeni
final WeatherSnapshot? currentWeather; // Yeni
final bool? weatherAlertTriggered; // Yeni
}
○ WeatherSnapshot:
class WeatherSnapshot {
final String condition;
final double minTemp;
final double maxTemp;
final String iconCode;
final double windSpeedKmh; // Yeni
final String windDirection; // Yeni
}
○ WardrobePlannerController:
■ loadPlannedOutfits, loadWeatherData: Planları ve hava durumunu yükler.
■ selectDay, focusDay: Takvim navigasyonu.
■ planCombinationForDate: Bir kombini tarihe planlar.
■ unplanCombination: Planı kaldırır.
■ checkForWeatherAlerts: Hava durumu değişikliklerini kontrol eder.
● Kullanıcı Akışı (Interaction Flow):
1. Kullanıcı WardrobePlannerScreen'e gelir.
2. Planlar ve hava durumu verisi yüklenir.
3. Veri Geldiğinde:
■ PlannerCalendarView takvimi gösterir. Her hücrede hava durumu bilgisi ve
uyarıları yer alır.
■ Kullanıcı bir DraggableCombinationCard'ı bir takvim hücresine
(CombinationDragTarget) sürükleyip bırakır.
■ Bırakma anında, kombin hava durumuyla uyumlu değilse bir uyarı gösterilir
("Bu kombin hava koşullarına uygun olmayabilir.").
■ Kullanıcı onaylarsa planCombinationForDate ile plan kaydedilir.
● API/Servis Çağrıları (Girdi/Çıktı):
○ WardrobePlannerRepository -> ApiService: getPlannedOutfits,
createPlannedOutfit, deletePlannedOutfit.
○ WeatherService -> ApiService (örn: OpenWeatherMap): getWeatherForecast.
● UX Detayları & Kenar Durumlar:
○ Hava Durumu Entegrasyonu (Gelişmiş): Takvim hücrelerinde hava durumu
simgesi ve sıcaklık gösterilir. Rüzgar hızı gibi özel bilgiler ikonla belirtilir.
Uyumsuz planlar görsel olarak farklılaştırılır. "Etek uçuşma uyarısı" gibi
bağlamsal uyarılar gösterilir.
○ Sürükle-Bırak: Etkileşim akıcı ve sezgisel olmalıdır.
○ Kenar Durumları: Ağ hatası, çevrimdışı durum, performans yönetilir.
12. Özellik: SwapMarketScreen (İkinci El Takas Platformu)
● Sayfa Adı ve Amacı:
○ SwapMarketScreen: Kullanıcıların, kıyafetlerini başkalarına satarak veya takas
ederek yeniden değerlendirdiği sosyal bir pazar yeridir.
● Ana Bileşenler (Widget/Class Adları):
○ SwapMarketScreen
○ AppBar
○ SwapListingsGridView, SwapListingsListView
○ SwapListingCard (İlan kartı)
○ SwapMarketFilterBar (Tür, kategori, fiyat aralığı filtresi)
○ FloatingActionButton (CreateSwapListingScreen'e yönlendirir)
○ SwapMarketController, SwapMarketRepository
● Veri Modeli & State Yönetimi:
○ SwapListing:
class SwapListing {
final String id;
final String ownerId;
final int ownerSwapScore;
final String clothingItemId;
final String title;
final String description;
final String type; // "sale" veya "swap"
final double? price;
final String? swapWantedFor;
final String imageUrl;
final String status; // "active", "sold", "swapped"
final bool isSavedByCurrentUser; // Yeni
}
○ SwapMarketState:
class SwapMarketState {
final List<SwapListing> listings;
final bool hasReachedMax;
final String? selectedTypeFilter;
final String? selectedCategoryFilter;
final double? minPriceFilter;
final double? maxPriceFilter;
final bool isLoading;
final bool isLoadingMore;
final Object? error;
SwapMarketState copyWith({...});
}
○ SwapMarketController:
■ loadListings, loadMoreListings, refreshListings: Veri yükleme ve sayfalama.
■ applyFilters: Filtreleri uygular.
■ saveListing, unsaveListing: İlanı favorilere ekler/çıkarır.
● Kullanıcı Akışı (Interaction Flow):
1. Kullanıcı Swap Market sekmesine tıklar.
2. loadListings ile ilanlar yüklenir.
3. Veri Geldiğinde:
■ SwapMarketFilterBar ile kullanıcı ilanları filtreleyebilir.
■ İlanlar grid/list olarak gösterilir.
■ Her SwapListingCard'da ilan bilgileri ve satıcının "Swap Puanı" gösterilir.
■ Kullanıcı karttaki "İlgi Göster" butonu ile ilanı favorileyebilir.
■ Kullanıcı karta tıklayarak SwapListingDetailScreen'e gider.
■ Kullanıcı FloatingActionButton ile yeni ilan oluşturur.
● API/Servis Çağrıları (Girdi/Çıktı):
○ SwapMarketRepository -> ApiService:
■ getListings: Filtre parametreleri ile ilanları çeker.
■ saveListing, unsaveListing: Favori durumunu günceller.
● UX Detayları & Kenar Durumlar:
○ Karma Puan Sistemi: SwapListingCard'da satıcının puanı gösterilerek
güvenilirlik artırılır.
○ Kenar Durumları: Ağ hatası, çok sayıda ilan için lazy loading, çevrimdışı
durum (cache'ten gösterme) yönetilir.
13. Özellik: CreateSwapListingScreen
● Sayfa Adı ve Amacı:
○ CreateSwapListingScreen: Kullanıcının, gardırobundaki bir kıyafeti seçerek
onu satılık veya takaslık olarak listelediği ekrandır.
● Ana Bileşenler (Widget/Class Adları):
○ CreateSwapListingScreen (StatefulWidget)
○ AppBar ("Yayınla" butonu içerir)
○ LinkedClothingItemPreview (Seçilen kıyafetin önizlemesi)
○ ListingTypeSelector ("Satılık" / "Takaslık")
○ PriceInputField, SwapWantedForField
○ DescriptionTextField, TermsTextField
○ AdditionalImagesPicker
○ CreateSwapListingController, SwapMarketRepository, WardrobeRepository
● Veri Modeli & State Yönetimi:
○ CreateSwapListingState:
class CreateSwapListingState {
final String? clothingItemId;
final String description;
final String type;
final double? price;
final String? swapWantedFor;
final List<File> newAdditionalImageFiles;
final bool isPublishing;
final Object? error;
CreateSwapListingState copyWith({...});
}
○ CreateSwapListingController:
■ initWithClothingItem(String itemId): Ekranı seçilen kıyafetle başlatır.
■ changeType, changePrice, vs.: Form alanlarını yönetir.
■ pickAdditionalImages, uploadAdditionalImages: Ek görselleri yönetir.
■ publishListing(): Formu doğrular ve ilanı yayınlar.
● Kullanıcı Akışı (Interaction Flow):
1. Kullanıcı bir ClothingItem için "Sat/Takas Et" seçeneğini seçer.
2. CreateSwapListingScreen açılır ve seçilen kıyafetin bilgileriyle doldurulur.
3. Kullanıcı ilan türünü ("Satılık" veya "Takaslık") seçer ve ilgili alanları (fiyat veya
istenen eşya) doldurur.
4. Açıklama, koşullar ve (opsiyonel) ek görseller ekler.
5. "Yayınla" butonuna tıklar. publishListing çağrılır.
6. Veriler doğrulanır, (varsa) görseller yüklenir ve ilan sunucuya kaydedilir.
7. Başarılı olunca kullanıcı SwapMarketScreen'e yönlendirilir.
● API/Servis Çağrıları (Girdi/Çıktı):
○ WardrobeRepository -> ApiService: getClothingItemById.
○ SwapMarketRepository -> ApiService: uploadImage, createListing.
● UX Detayları & Kenar Durumlar:
○ Form Doğrulama: Gerekli alanlar (açıklama, fiyat/takas tercihi)
doldurulmadan "Yayınla" butonu devre dışı bırakılır.
○ UI/UX İyileştirmeleri: LinkedClothingItemPreview bağlamı güçlendirir. Alanlar,
seçilen ilan türüne göre dinamik olarak gösterilir/gizlenir.
○ Kenar Durumları: Çevrimdışı çalışma desteklenmez. Büyük görseller resize
edilir.
14. Özellik: SwapListingDetailScreen
● Sayfa Adı ve Amacı:
○ SwapListingDetailScreen: Bir takas/satış ilanının tüm detaylarını, satıcı
profilini ve etkileşim butonlarını gösteren ekrandır.
● Ana Bileşenler (Widget/Class Adları):
○ SwapListingDetailScreen
○ AppBar (Kullanıcının kendi ilanıysa "Düzenle", "Sil", "Satıldı Olarak İşaretle"
menüsü içerir)
○ ListingImageGallery (İlan görselleri galerisi)
○ ListingDetailsSection (Açıklama, fiyat, koşullar)
○ SellerInfoCard (Satıcı adı, avatarı, swap puanı)
○ ListingActionButtons ("Mesaj Gönder", "Favorilere Ekle", "Paylaş")
○ SwapListingDetailController, SwapMarketRepository
● Veri Modeli & State Yönetimi:
○ SwapListingDetailState:
class SwapListingDetailState {
final SwapListing? listing;
final bool isLoading;
final bool isPerformingAction;
final Object? error;
SwapListingDetailState copyWith({...});
}
○ SwapListingDetailController:
■ loadListing: İlan detaylarını yükler.
■ saveListing, unsaveListing: Favori durumunu yönetir.
■ contactSeller(): PreSwapChatScreen'e yönlendirir.
■ shareListing: İlanı paylaşır.
■ deleteListing, markAsSoldOrSwapped: İlan sahibi için eylemler.
● Kullanıcı Akışı (Interaction Flow):
1. Kullanıcı bir SwapListingCard'a tıklar.
2. SwapListingDetailScreen yüklenir, loadListing çağrılır.
3. Veri Geldiğinde:
■ İlanın görselleri, detayları ve satıcı bilgileri (swap puanı dahil) gösterilir.
■ Kullanıcı ListingActionButtons ile "Mesaj Gönder" (sohbet başlatır),
"Favorilere Ekle" veya "Paylaş" eylemlerini gerçekleştirebilir.
■ İlan sahibiyse, AppBar'daki menüden ilanı silebilir veya durumunu
güncelleyebilir.
● API/Servis Çağrıları (Girdi/Çıktı):
○ SwapMarketRepository -> ApiService: getListingById, saveListing,
unsaveListing, deleteListing, updateListingStatus.
○ ShareService: İlanı paylaşır.
● UX Detayları & Kenar Durumlar:
○ Görsel Galeri: Kullanıcının görselleri rahatça incelemesini (zoom, kaydırma)
sağlamalıdır.
○ Satıcı Bilgisi: SellerInfoCard satıcının güvenilirliğini hızlıca gösterir.
○ Kenar Durumları: Ağ hatası, çevrimdışı durum (temel veri cache'ten gösterilir)
yönetilir.
15. Özellik: PreSwapChatScreen (Ön Takas Sohbeti)
● Sayfa Adı ve Amacı:
○ PreSwapChatScreen: Bir takas ilanıyla ilgili olarak alıcı ve satıcının özel
mesajlaşma yoluyla iletişim kurduğu ekrandır.
● Ana Bileşenler (Widget/Class Adları):
○ PreSwapChatScreen
○ AppBar (Karşı tarafın adı ve avatarı ile)
○ ChatMessagesListView
○ ChatMessageBubble
○ ChatInputBar
○ PreSwapChatController, MessagingRepository
● Veri Modeli & State Yönetimi:
○ DirectMessageThread:
class DirectMessageThread {
final String id;
final List<String> participantIds;
final bool isDealAgreed; // Anlaşma sağlandı mı?
final DateTime? dealAgreedAt;
final String? relatedListingId;
}
○ DirectMessage:
class DirectMessage {
final String id;
final String threadId;
final String senderId;
final String text;
final DateTime sentAt;
}
○ PreSwapChatState:
class PreSwapChatState {
final DirectMessageThread? thread;
final List<DirectMessage> messages;
final bool isLoading;
final bool isSendingMessage;
final Object? error;
PreSwapChatState copyWith({...});
}
○ PreSwapChatController:
■ initChat(String otherUserId, String? relatedListingId): Sohbeti başlatır veya
mevcut olanı yükler.
■ loadMessages: Mesajları yükler.
■ sendMessage: Mesaj gönderir.
■ agreeToDeal(): "Anlaşma Sağlandı" işlemini yönetir.
● Kullanıcı Akışı (Interaction Flow):
1. Kullanıcı SwapListingDetailScreen'de "Mesaj Gönder"e tıklar.
2. PreSwapChatScreen açılır. initChat ile mevcut sohbet aranır veya yeni bir tane
oluşturulur.
3. Mesaj geçmişi yüklenir ve gösterilir.
4. Kullanıcı ChatInputBar'dan mesaj gönderir.
5. Sohbet sırasında, taraflar "Anlaşma Sağlandı" butonuna tıklayabilir.
6. Butona tıklandığında, sorumluluğun kendilerinde olduğuna dair bir uyarı
Dialog'u gösterilir.
7. Kullanıcı onaylarsa, anlaşma durumu (isDealAgreed) sunucuya kaydedilir.
● API/Servis Çağrıları (Girdi/Çıktı):
○ MessagingRepository -> ApiService: getOrCreateThread,
getMessagesForThread, sendMessage, updateThreadDealStatus.
● UX Detayları & Kenar Durumlar:
○ UI/UX İyileştirmeleri: AppBar'da karşı tarafın bilgileri olması netlik sağlar.
"Anlaşma Sağlandı" butonu belirgin olmalıdır.
○ Kenar Durumları: Ağ hatası, çevrimdışı durum (mesajlaşma için internet
gerekir), uzun mesajlar, çok sayıda mesaj için pagination yönetilir.
16. Özellik: FavoritesScreen
● Sayfa Adı ve Amacı:
○ FavoritesScreen: Kullanıcının, uygulama içinde favorilediği tüm içerikleri
(kombinler, ürünler, sosyal gönderiler, takas ilanları) toplu olarak görüntülediği
ekrandır.
● Ana Bileşenler (Widget/Class Adları):
○ FavoritesScreen
○ AppBar
○ FavoritesTabBar & FavoritesTabBarView ("Ürünler", "Kombinler", "Gönderiler",
"Takas İlanları")
○ FavoritesGridView, FavoritesListView
○ FavoritesMultiSelectToolbar (Toplu işlemler için)
○ FavoritesController, FavoritesRepository
● Veri Modeli & State Yönetimi:
○ FavoritesState:
class FavoritesState {
final List<Product> favoriteProducts;
final List<Combination> favoriteCombinations;
final List<SocialPost> favoritePosts;
final List<SwapListing> favoriteSwapListings;
final FavoritesTab activeTab;
final bool isGridView;
final bool isLoading;
final bool isMultiSelectMode; // Yeni
final Set<String> selectedItemsInMultiSelect; // Yeni
final Object? error;
FavoritesState copyWith({...});
}
enum FavoritesTab { products, combinations, posts, swapListings }
○ FavoritesController:
■ loadFavorites, refreshFavorites: Favorileri yükler/yeniler.
■ changeTab, toggleView: Görüntüleme seçenekleri.
■ removeFromFavorites: Tek bir öğeyi favorilerden kaldırır.
■ enterMultiSelectMode, exitMultiSelectMode,
toggleItemSelectionInMultiSelect, removeSelectedItemsFromFavorites:
Toplu işlemler.
● Kullanıcı Akışı (Interaction Flow):
1. Kullanıcı Favorites sekmesine tıklar.
2. loadFavorites ile tüm favori içerikler yüklenir.
3. Veri Geldiğinde:
■ FavoritesTabBar ile kullanıcı farklı favori türleri arasında geçiş yapabilir.
■ Aktif sekmeye ait favoriler grid/list olarak gösterilir.
■ Kullanıcı bir Card'a tıklayarak orijinal içeriğin detayına gider.
■ Kullanıcı bir Card'a uzun basarak çoklu seçim moduna girer ve
FavoritesMultiSelectToolbar ile seçili öğeleri topluca favorilerden
kaldırabilir.
● API/Servis Çağrıları (Girdi/Çıktı):
○ FavoritesRepository -> ApiService:
■ getAllFavorites: Tüm favori türlerini tek seferde çeker.
■ removeFavorite: Tek bir öğeyi kaldırır.
■ removeFavorites: Toplu kaldırma işlemi yapar.
● UX Detayları & Kenar Durumlar:
○ Sekmeler: Farklı favori türlerini ayırmak, büyük listelerde gezinmeyi
kolaylaştırır.
○ Boş Durum: Aktif sekmede favori yoksa, kullanıcıyı keşfetmeye yönlendiren bir
mesaj gösterilir.
○ Kenar Durumları: Ağ hatası, çok sayıda öğe için lazy loading, çevrimdışı
durum (cache'ten gösterme) yönetilir.
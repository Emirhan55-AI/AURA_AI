1. Görsel Kimlik ve Material 3 Özelleştirme
Aura için sıcak, samimi ve kişisel bir his verecek renk paleti tasarımı önemlidir. Light ve Dark tema renk
şemaları şu şekilde önerilebilir (HEX):
Birincil renk (Primary): #FF6F61 (sıcak koral ton)
İkincil renk (Secondary): #FFD700 (parlak altın sarısı)
Yüzey renkleri (Surface/Background): Açık modda #FFFFFF (beyaz) ve #F5F5F5 (açık gri); koyu
modda #121212 (siyah ton) ve #1E1E1E (koyu gri) .
Yardımcı renkler (Accent): #FFB399 (pastel pembe), #6A5ACD (lüks mora yakın ton) gibi
destekleyici tonlar.
Bu renkler Google’ın Material 3 dinamik renk sistemiyle ColorScheme.fromSeed(seedColor: ...)
kullanılarak da türetilebilir . Örneğin Flutter’da:
final colorScheme = ColorScheme.fromSeed(seedColor: Color(0xFFFF6F61),
brightness: Brightness.light);
final darkColorScheme = ColorScheme.fromSeed(seedColor: Color(0xFFFF6F61),
brightness: Brightness.dark);
ThemeData theme = ThemeData(useMaterial3: true, colorScheme: colorScheme);
ThemeData darkTheme = ThemeData(useMaterial3: true, colorScheme:
darkColorScheme);
Tipografi için Google Fonts’tan başlık ve gövde yazı tipi aileleri önerileri:
- Başlık: Montserrat veya Playfair Display (modern, şık görünüm).
- Gövde: Inter veya DM Sans (okunaklı, geniş ağırlık seçenekli) .
Flutter kodunda bunu şöyle tanımlayabiliriz:
textTheme: TextTheme(
headlineLarge: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
bodyMedium: GoogleFonts.inter(),
),
Örneğin Flutter belgelerinde ThemeData ’ya GoogleFonts uygulaması şu şekilde gösterilmiştir .
Ayrıca Pacifico veya Oswald gibi fontlar da vurgu için eklenebilir .
STYLE_GUIDE.md içeriği şu bölümleri kapsar: - Renkler: Birincil/ikincil renk kodları, arka plan, yüzey
tonları.
- Tipografi: Başlık/gövde fontları, boyutları, ağırlıkları.
- Bileşen Stilleri: Düğme, kart, simge vb. standart görünümleri.
Örneğin STYLE_GUIDE.md’de renk tablosu ve tipografi aşağıdaki gibi listelenebilir (kod/markdown
biçiminde):
• 1 2
•
•
3
•
1
4
5
5
1
# Stil Kılavuzu (STYLE_GUIDE.md)
## Renk Paleti
- Birincil: #FF6F61
- İkincil: #FFD700
- Arka Plan (Light): #FFFFFF, Yüzey: #F5F5F5
- Arka Plan (Dark): #121212, Yüzey: #1E1E1E
- Vurgu Renkleri: #FFB399, #6A5ACD
## Tipografi
- Başlık: Montserrat (veya Playfair Display)
- Gövde: Inter (veya DM Sans)
- Örnek:
 ```dart
ThemeData(
textTheme: TextTheme(
headlineLarge: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
bodyText1: GoogleFonts.inter(),
),
);
 ```
## Bileşenler
- Birincil Düğme (PrimaryButton): #FF6F61 arka plan, beyaz yazı .
- Kartlar (Card): Yuvarlatılmış köşe, gölge.
- Girişler (Input): Alt çizgi veya kutu stilinde, vurgulu renk olarak
birincil.
2. Rakip Analizi ve Özellik Akışı
Stitch Fix: Kullanıcı onboarding’inde 10–15 dakikalık detaylı bir anket sunar . Özellikle “stil çemberi”
sorusunda kullanıcılara 24 farklı kıyafet fotoğrafı gösterilerek hangi stilleri tercih ettiği sorulur .
Görsel sunumda 1 kolon yerine 2 kolon düzeninin kullanıcılar tarafından daha hızlı olduğu bulunmuştur
. Bu yaklaşım, Aura için de page view veya grid yapısında çoklu görsel tercih soruları ile uyarlanabilir.
Whering: Dijital gardırop uygulaması olan Whering’de onboarding akışı kıyafet ekleme ile başlar,
ardından kullanıcılar katologdan veya fotoğraflarla gardıroplarını oluşturur . Sonraki adımlarda
arkadaşlarla stil paylaşma ve günlük kombin önerileri sunulur. Örneğin:
1) Gardırop ekleme: Eşyaları fotoğrafla veya mağaza görseliyle yükleme .
2) Kombin oluşturma: Otomatik kıyafet eşleştirme.
3) Günlük öneri: Kişisel stilinize göre öneriler alma.
4) Arkadaş etkileşimi: Arkadaş gardıroplarını görme ve ilham alma.
Bu akış Aura için de kullanılabilir; ilk aşamada kullanıcılar Gardırobum adıyla eşyalarını yükleyebilir ve
sonraki sayfalarda stil tercihlerine göre önerilere yönlendirilebilir.
2
6
6
7
8
8
2
Aura Öneri Akışı (Flutter widget’larla):
- PageView: Adım adım ilerleyen onboarding ekranları için (örneğin stil soruları).
- Stepper: Çok adımlı stil testi ilerlemesi için üstte adım göstergesi.
- Slider: Örneğin "Günlük stil puanınız nedir?" gibi kaydırmalı puanlama soruları.
- FilterChip veya Checkbox: Tercih stillerini kategorik seçmek için.
Örnek taslak: Kullanıcılar yatay kaydırma ile stil tercihleri arasında geçiş yaparken (PageView) yukarıda
adım işaretçisi (Stepper) ve alt kısımda devam/geri düğmeleri olabilir. Görseldeki örnek kullanışlı bir
onboarding akışını gösterir. Bu taslağa göre, ilk adımda cinsiyet/beden bilgisi; sonraki adımlarda “senin
stilin” soruları olabilir.
Öneri Kartları Konseptleri:
1. Tinder benzeri kaydırılabilir kart (flutter_card_swiper): Kullanıcıları sola/sağa kaydırarak önerilere
onay/ret verebileceği akış. Örneğin [CardSwiper] widget’ı ile kart oluşturulur:
CardSwiper(
cardsCount: suggestions.length,
cardBuilder: (ctx, idx, x, y) => SuggestionCard(data: suggestions[idx]),
)
Burada her kart SuggestionCard bileşeni olabilir .
2. Üst üste yığılmış kartlar (Stacked Card Carousel): StackedCardsCarouselWidget(items:
items) basit kullanımıyla ardışık dikey bir kaydırmalı görünüm sağlar . Örneğin:
StackedCardsCarouselWidget(
items: suggestions.map((s) => SuggestionCard(data: s)).toList(),
);
3. Dönen kart/Paginated Carousel: PageView ile yatay kaydırmada kartlar arasında geçiş. Örneğin
PageView.builder + Transform.scale kullanarak aktif kartı öne çıkaran bir efekt eklenebilir.
Her üç konsepte uygun örnek kod ve basit taslak çizimler geliştirilmelidir. Örneğin, yukarıdaki kod
parçaları veritabanındaki suggestions listesini kullanır.
3. Flutter UI Yapısı
Aura’nın lib/presentation/ klasör yapısı şu şekilde önerilebilir (özelleştirilebilir):
lib/presentation/
├─ common/ # Ortak bileşenler (PrimaryButton, CustomAppBar, vb.)
├─ onboarding/ # Onboarding ekranları
├─ profile/ # Profil ve ayarlar ekranları
├─ suggestions/ # Stil öneri ekranları
└─ theme/ # Tema ve stiller
9
10
3
Bu yapıda, her özelliğe ait ekranlar kendi klasöründe toplanır. Andrea Bizzotto’ya göre feature-first
yaklaşımda, katmanlar her özelliğin içinde düzenlenerek okunabilirlik artar .
COMPONENT_LIST.md örneği (içerikler ve kod):
# Bileşen Listesi (COMPONENT_LIST.md)
## PrimaryButton
- **Dosya:** lib/presentation/common/primary_button.dart
- **Tanım:** Uygulamanın birincil eylem düğmesi.
- **Örnek Kod:**
 ```dart
class PrimaryButton extends StatelessWidget {
final String text;
final VoidCallback onPressed;
const PrimaryButton({required this.text, required this.onPressed});
@override
Widget build(BuildContext context) {
return ElevatedButton(
style: ElevatedButton.styleFrom(
backgroundColor: Color(0xFFFF6F61), // AppColors.primary
padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
),
onPressed: onPressed,
child: Text(text, style: TextStyle(color: Colors.white)),
);
}
}
 ```
 (*Material 3 kullanılırsa `ElevatedButton` otomatik yeni stile uyum
sağlayacaktır.*)
## CustomAppBar
- **Dosya:** lib/presentation/common/custom_app_bar.dart
- **Tanım:** Standart AppBar’in yüksekliği veya düzeni özelleştirilmiş
hali.
- **Örnek Kod:**
 ```dart
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
final Widget child;
final double height;
CustomAppBar({required this.child, this.height = kToolbarHeight});
@override
Size get preferredSize => Size.fromHeight(height);
@override
Widget build(BuildContext context) {
return Container(
11
4
height: preferredSize.height,
color: Theme.of(context).colorScheme.primary,
alignment: Alignment.center,
child: child,
);
}
}
 ```
 (CopsOnRoad’un StackOverflow cevabı, `PreferredSizeWidget` kullanımıyla
benzer bir örnek sunmuştur .)
## EmptyStateWidget
- **Dosya:** lib/presentation/common/empty_state_widget.dart
- **Tanım:** Liste boş olduğunda veya hata durumunda kullanıcıya görsel mesaj
gösteren widget.
- **Örnek Kod:**
 ```dart
class EmptyStateWidget extends StatelessWidget {
final String title, message;
EmptyStateWidget({required this.title, required this.message});
@override
Widget build(BuildContext context) {
return Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(Icons.info_outline, size: 64, color: Colors.grey),
SizedBox(height: 16),
Text(title, style: Theme.of(context).textTheme.headlineSmall),
SizedBox(height: 8),
Text(message, style: Theme.of(context).textTheme.bodyMedium,
textAlign: TextAlign.center),
],
),
);
}
}
 ```
 (*Örneğin veritabanı sıfır kayıt döndüğünde veya çevrimdışı moddayken bu
gösterilebilir.*)
4. Mikro Etkileşimler ve Animasyonlar
Stil önerileri hazırlanırken veya analiz yapılırken küçük animasyonlar kullanıcı deneyimini zenginleştirir.
Örneğin:
- Öneri hazırlanıyor (loading): Ekrana bir yükleme animasyonu (shimmer veya Lottie hız göstergesi)
eklenebilir.
- Analiz yapılıyor: İlerleme çubuğu veya dairesel sayaç animasyonu.
- Fotoğraf yükleme: Yüklenirken % animasyonu veya dönen bir ikon.
12 13
5
- Yeni öneri geldi: Öneri kartı yumuşakça kayarak veya renk değiştirerek belirir.
- Profil güncellendi: Başarı için küçük bir konfeti veya tik animasyonu.
Bu etkiler için flutter_animate ve Lottie kullanılabilir. Örnek kod:
flutter_animate ile basit bir metin geçişi:
Text("Stil Analizi Yapılıyor...")
.animate()
.fadeIn(duration: 500.ms)
.scale(duration: 600.ms, curve: Curves.easeOut);
Burada .animate().fadeIn().scale() zinciriyle widget’a efekt uygulanır . Bu
kütüphane ile .fadeIn() , .move() , .blur() gibi hazır efektler birbirine bağlanabilir .
Lottie ile karmaşık animasyon (örneğin konfeti veya yükleme animasyonu):
Lottie.asset('assets/loading_animation.json');
Lottie.network('https://assets10.lottiefiles.com/packages/
lf20_bdxk9mqf.json');
Lottie paketi ile JSON formatlı animasyonlar doğrudan oynatılır . ( Lottie.asset veya
Lottie.network kullanılarak dosya ekleyebiliriz.)
Animasyon rehberi ANIMATION_GUIDE.md içeriğinde:
- flutter_animate Kullanımı: Widget’a .animate() ekleyip zincirli efektler kullanın (örn.
.fadeIn() , .scale() ) .
- Lottie Kullanımı: JSON animasyonları için Lottie.asset('path') veya
Lottie.network('url') ile yükleyin .
- Genel İlkeler: Animasyonlar kısa (1-2 saniye) ve döngüsüz olmalı; kullanıcının ilerlemesini
durdurmamalı. Yükleme/succes durumlarında geri bildirim vermeli.
- Alternatif: Animasyon gösterilemiyorsa statik içerik veya yükleme çubuğu ile yerini doldurun.
5. Sistemik Durumlar için UI Tasarımı
Hata/Olay Mesajları (API 500, offline, bakım): Kullanıcıyı paniğe sürüklemeyen, samimi bir dil
kullanılmalıdır. Örneğin:
- Sunucu Hatası (500): “Üzgünüz, bir sorun oluştu. Lütfen bir süre sonra tekrar deneyin.”
- İnternet Yok: “Görünüşe göre bağlantınız kesildi. Ağ ayarlarını kontrol edip yeniden deneyin.”
- Bakım: “Biraz bakım çalışmamız var. Çok yakında geri döneceğiz!”
Bu mesajlar kısa ve anlaşılır olmalı; hata kodu teknik detay vermek yerine kullanıcının ne yapabileceğine
odaklanmalıdır (örneğin “Tekrar Dene” düğmesi). Nielsen Norman Group’a göre hata mesajları anlaşılır
ve kullanıcıya saygılı olmalı . Kullanıcıyı suçlamayan, olumlu bir ton tercih edilmelidir.
Widget Taslakları: Örneğin EmptyStateWidget kullanılarak hata durumları için şablon gösterilebilir.
Her durumda simge+başlık+detay bilgisi içeren merkezi bir ekran iyi bir çözümdür. Örneğin:
•
14
14
•
15
14
15
16
6
if (error) {
return EmptyStateWidget(
title: "Bir şeyler yanlış gitti",
message: "Sunucuya ulaşılamadı. Lütfen sonra tekrar deneyin.",
);
} else if (!connected) {
return EmptyStateWidget(
title: "Bağlantı Yok",
message: "Lütfen internet bağlantınızı kontrol edin.",
);
}
Bu tür mesajlar kullanıcının endişelenmesini engeller, bilgilendirici ve yönlendiricidir. NNGroup da
mesajların yapıcı, kullanıcı hatasını değil durumu vurgulayan bir tona sahip olmasını önerir .
Kaynaklar: Yukarıdaki öneriler, Material 3 uyumlu Flutter örnekleri , rakip uygulamalar (Stitch Fix
stil testi akışı , Whering gardırop akışı ), ve tasarım sistemi kılavuzlarından derlenmiştir
. Bu kapsamlı öneriler Aura uygulaması için uyarlanabilir, çalışır durumda ve amaca
yönelik çözümler sunmaktadır.
Themes | Flutter
https://docs.flutter.dev/cookbook/design/themes
How to Build a Flutter Design System Without Losing Your Mind | by DeyvissonEduardo.Dev
| Medium
https://medium.com/@DeyvissonDev/how-to-build-a-flutter-design-system-without-losing-your-mind-f92bf1b2f723
The 40 Best Google Fonts—A Curated Collection for 2025 · Typewolf
https://www.typewolf.com/google-fonts
UX Design: How do we capture style preferences during sign-up? | Stitch Fix Technology –
Multithreaded
https://multithreaded.stitchfix.com/blog/2016/11/30/us-design-capture-style-preferences-during-sign-up/
How Whering Works – Whering
https://whering.co.uk/how-it-works
flutter_card_swiper | Flutter package
https://pub.dev/packages/flutter_card_swiper
stacked_cards_carousel - Dart API docs
https://pub.dev/documentation/stacked_cards_carousel/latest/
Flutter Project Structure: Feature-first or Layer-first?
https://codewithandrea.com/articles/flutter-project-structure/
dart - Custom AppBar Flutter - Stack Overflow
https://stackoverflow.com/questions/53658208/custom-appbar-flutter
flutter_animate | Flutter package
https://pub.dev/packages/flutter_animate
lottie | Flutter package
https://pub.dev/packages/lottie
16
1 5
6 8 17 14
15 9 10 16
1 5
2 3 17
4
6 7
8
9
10
11
12 13
14
15
7
Error-Message Guidelines - NN/g
https://www.nngroup.com/articles/error-message-guidelines/
16
8
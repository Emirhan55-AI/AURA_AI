Flutter Tasarım Sistemi (Material 3 + Atomic
Design + Monorepo)
Tema Yönetimi ve Stil Rehberi
Material 3 (Material You) Teması: Flutter’da Material 3 kullanarak renk paleti ve tipografi tanımlanır.
Tema, ThemeData sınıfıyla oluşturulur; M3’te renk paletini
ColorScheme.fromSeed(seedColor: ...) ile belirleyip açık/koyu modlar otomatik oluşturulabilir
. Örneğin:
final lightTheme = ThemeData(
useMaterial3: true,
colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
scaffoldBackgroundColor: AppColors.background,
textTheme: GoogleFonts.openSansTextTheme(),
elevatedButtonTheme: ElevatedButtonThemeData(
style: ElevatedButton.styleFrom(
backgroundColor: AppColors.primary,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(AppRadius.md),
),
),
),
);
final darkTheme = ThemeData(
brightness: Brightness.dark,
colorScheme: ColorScheme.fromSeed(
seedColor: AppColors.primary,
brightness: Brightness.dark,
),
scaffoldBackgroundColor: AppColors.bgDark,
// ...
);
Bu örnekte AppColors ve AppRadius gibi tasarım tokenları, renkleri ve köşe yarıçaplarını merkezi
olarak tutar . Google Fonts paketiyle özel yazı tipleri de entegre edilebilir (ör.
GoogleFonts.openSansTextTheme() ) . Tema değişikliği, MaterialApp ’in themeMode:
themeMode özelliği ile kontrol edilir. Örneğin, Riverpod kullanarak tema modu sağlayıcısı oluşturup
( final themeProvider = StateProvider((_)=>ThemeMode.system); ), uygulamada tüm
widget’ların güncel temayı kullanması sağlanabilir.
Mimari ve Stil Katmanları: Temel tasarım özellikleri “tasarım tokenları” olarak ayrılmalıdır. Örneğin
AppColors , AppTypography , AppSpacing , AppRadius sınıflarında renk, yazı tipi, boşluk ve
radius değerleri sabitlenir . Bu değerler Atomic Design akışındaki en alt seviyede (Atoms
1
2 3
4 5
6 7
1
katmanı) referans alınır. Sonra bu tokenlar, ThemeData veya özel CAColorSchemeData gibi sınıflarda
toplanarak açık/koyu tema olarak sunulur . Tema yönetimi bölümü genellikle packages/
ui_kit/lib/src/themes/ içinde tutulur; dosya yapısı şu şekilde olabilir:
packages/ui_kit/
 lib/
 src/
 tokens/
 app_colors.dart
 app_typography.dart
 app_spacing.dart
 app_radius.dart
 themes/
 light_theme.dart
 dark_theme.dart
Bu sayede tüm stil bilgisi merkezde tanımlı olur. Sınıf ve dosya adları CamelCase (örn. AppColors ) /
snake_case (örn. app_colors.dart ) kurallarına göre isimlendirilir.
Kullanılacak Araçlar ve Paketler: - flutter_riverpod veya provider ile tema değişikliği gibi
durumları yönetmek kolaylaşır. Örneğin StateProvider<ThemeMode> ile tema akışı sağlanabilir. -
google_fonts paketi, Google Fonts’u dinamik indirip kullanmaya yarar . - Tema otomatik
güncelleme için ThemeData kullanımı ve Flutter’ın dahili Theme.of(context) erişimi yeterlidir. - Stil
rehberi için Figma belgeleri ile senkronizasyon amacıyla Design Token araçları (ör. Token Studio)
düşünülebilir, ancak Flutter içinden doğrudan ColorScheme.fromSeed kullanmak çoğu senaryoda
uygundur .
Potansiyel Sorunlar ve Çözümler: - Aşırı yeniden çizim (rebuild) maliyeti: Tema değiştiğinde
MaterialApp altındaki tüm widget’lar güncellenir. Çok sayıda widget varsa kısa sürede binlerce
rebuild olabilir. Çözüm olarak const yapıcıları kullanmak, gereksiz yeniden oluşturmayı önler. Ayrıca
Riverpod ile sadece tema modunu dinleyip ona göre güncellemek ve gerektiğinde ConsumerWidget
sınırlamaları kullanmak faydalıdır.
- Dinamik metin ölçekleme: Kullanıcı metin boyutunu büyüttüğünde tasarım bozulmamalı. Tüm metin
stilleri TextTheme içinde tanımlanmalı ve MediaQuery.textScaleFactor dikkate alınmalı (yazı tipi
boyutu %X.sp gibi değil, TextStyle içine göreceli ayarlanmalı).
- Renk kontrastı ve karanlık mod uyumu: Renk paletinin her iki modda kontrast koşullarını sağlaması
gerekir. Temada kullanılan renklerin WCAG kontrast koşulu (en az 4.5:1) sağlandığı doğrulanmalı
. Tüm akıllı ikonlar ve arka plan-buton renkleri karanlık modda da anlaşılır olmalıdır. Gerektiğinde
ThemeMode.system ile cihaz ayarlarına uyum sağlanabilir.
- Stylable widget çoğaltımı: Tasarım sistemindeki stilleri kullanmayan hatalı widget kodları oluşabilir.
Bunu önlemek için renkleri ve stilleri sabitler yerine Theme.of(context) veya ortak AppColors
üzerinden almak teşvik edilmelidir. Yine LeanCode örneğinde görüldüğü gibi CAColor sınıfının private
olması, geliştiricilerin yalnızca belirlenen renkleri kullanmasını zorunlu kılar .
Performans, Bakım ve Test Edilebilirlik:
- Performans: Tema değişiminde meydana gelen rebuild’lerin süresi, widget sayısına bağlıdır. Örneğin
1000 widget’lık bir sayfada birkaç milisaniyede yeniden çizim tamamlanabilir; modern cihazlarda bu
genellikle farkedilmez. Ancak const widget’lar ve shouldRebuild optimizasyonları gereksiz iş
yükünü azaltır.
7 2
4
8 2
9
10
7
2
- Bakım: Stil tokenları sayesinde renkler, fontlar ve boşluklar tek bir yerden güncellenebilir. Tema
parametreleri kod içinde dağınık değil, merkezi yapıdadır. Bu, ekip içinde tutarlılığı artırır. Atomic Design
yaklaşımı da bileşenlerin tek göreve odaklı olmasını sağlayarak karmaşıklığı azaltır .
- Test edilebilirlik: Her tema ve component için widget testleri yazılmalıdır. Örneğin bir HeadingText
bileşeni için farklı tema altındaki görüntüler veya alt yazı boyutları test edilebilir. Tema değişikliği
senaryoları için entegrasyon veya altın (golden) testler oluşturulabilir. CI/CD hattında flutter test
komutu ile bu testlerin otomatik çalışması sağlanabilir .
Güvenlik ve Erişilebilirlik (a11y):
- Erişilebilirlik: Tüm UI bileşenleri için erişilebilirlik desteklenmelidir. Örneğin resimlerde
semanticLabel , düğme ve form elemanlarında labelText gibi özellikler kullanılarak ekran
okuyuculara açıklama sağlanır . Metin renklerinin ve buton kontrastlarının minimum 4.5:1
oranını sağladığından emin olunmalıdır . Etkileşim elemanları (buton, ikon vb.) en az 48×48dp hedef
boyutunda olmalı . Ayrıca, ekrandaki metinler cihaza göre ölçeklenebilmeli (dynamic type
desteklemeli) ve MediaQuery.textScaleFactor hesaplanmalıdır . Gerektiğinde Semantics
veya Tooltip widget’ları ile ekstra açıklamalar eklenebilir.
- Güvenlik: UI kütüphanesi özelinde, güvenlik genellikle backend ve iş katmanına dair olsa da, kullanıcı
girişi alınan alanlarda (şifre alanı gibi) doğru obscureText: true kullanımı, clipboard geçmişindeki
hassas verilerin temizlenmesi vb. dikkate alınabilir. Tema veya stil kodları arasında API anahtarı gibi
hassas bilgiler kesinlikle bulunmamalıdır. Genel olarak güvenlik, doğru erişim kontrollerinin uygulandığı
ve verilerin güvenli taşındığı iş katmanlarında sağlanmalıdır.
Dosya Yapısı ve İsimlendirme:
Tasarım sistemi modülü packages/ui_kit içinde örneğin aşağıdaki gibi organize edilebilir:
packages/
└─ ui_kit/
 └─ lib/
 ├─ ui_kit.dart // Kütüphane ana ihracat dosyası
 └─ src/
 ├─ tokens/ // Renk, yazı, boşluk değerleri
 │ ├─ app_colors.dart
 │ ├─ app_typography.dart
 │ ├─ app_spacing.dart
 │ └─ app_radius.dart
 ├─ themes/ // ThemeData tanımları
 │ ├─ light_theme.dart
 │ └─ dark_theme.dart
 └─ components/ // Atomic Design bileşenleri
 ├─ atoms/
 ├─ molecules/
 ├─ organisms/
 ├─ templates/
 └─ pages/
Sınıf adları PascalCase, dosya adları snake_case kullanılmalıdır (örn. primary_button.dart içinde
PrimaryButton sınıfı). Atomic Design kuralına göre en küçük bileşenler atoms , bunları gruplayanlar
molecules , daha büyük bileşenler organisms , düzen şablonları templates ve son kullanıcı
11 12
13
14 15
9
16
10
3
ekranları pages klasöründe toplanır . Bileşenlerin yeniden kullanılabilir olması için her biri
statik yöntemler yerine widget olarak tanımlanmalı ve parametrelerinden türetilmelidir.
Bileşenlerin Paketlenmesi ve Yeniden Kullanılabilirlik:
ui_kit bir Flutter paketi (package) olarak hazırlandığında, pubspec.yaml içinde diğer paketler ve
app’ler tarafından kolayca eklenecek şekilde ayarlanır. ui_kit.dart içine kütüphanenin ana
ihracatları (export) konur, örneğin:
// lib/ui_kit.dart
export 'src/tokens/app_colors.dart';
export 'src/tokens/app_typography.dart';
export 'src/components/atoms/buttons/primary_button.dart';
// ...
export 'src/themes/light_theme.dart';
export 'src/themes/dark_theme.dart';
Bu şekilde uygulama kodunda package:ui_kit/ui_kit.dart ile tüm bileşen ve temalar erişilebilir
hale gelir. Bileşen paketinin boyutu font, ikon ve image varlıklarından etkilenir; gereksiz asset’leri
kaldırmak, Google Fonts’un sadece kullanılacak ağırlıkları pakete dahil etmek uygulama boyutunu
düşürür. Örneğin sadece gerektiğinde HTTP üzerinden indirme yapmak paket boyutunu küçültür .
Performans açısından, tasarım sistemi kodu genellikle birkaç yüz KB civarındadır; büyük oranda yeniden
kullanılabilirliğin faydası ve tutarlı tasarım, küçük boyut farkını gölgede bırakır.
Monorepo Yapılandırması ve CI/CD Entegrasyonu:
Projeyi monorepo olarak yönetmek için Melos gibi araçlar kullanılabilir . Monorepo’da melos.yaml
ile paketler tanımlanır. Örneğin:
name: my_app_repo
packages:
- packages/ui_kit
- apps/app_main
Melos ile tüm paketlerin bağımlılıkları tek komutla kurulabilir. CI/CD hattında melos komutları
kullanılarak otomatik kontroller sağlanır. Örneğin GitHub Actions veya Codemagic iş akışında sırasıyla
dart pub global activate melos , melos bootstrap , melos run analyze , melos run
test komutları çalıştırılabilir . Örneğin Codemagic örneği:
scripts:
- name: Melos Bootstrap
script: |
dart pub global activate melos
melos bootstrap
- name: Run Analyze
script: melos run analyze
- name: Run Tests
script: melos run test
17 18
19
20
13 21
4
Ayrıca, CI süresini kısaltmak için sadece ilgili paketlerde değişiklik olduğunda build tetiklenebilir; böylece
örneğin sadece packages/ui_kit/** veya apps/** altı değişirse CI çalıştırılır . Monorepo
avantajları arasında kod tekrarının azalması, tüm proje için tutarlı yapı sağlanması ve katmanlı
mimarinin zorunlu hale gelmesi sayılabilir . Dezavantajı ise başlangıçta ek konfigürasyon
gerektirmesidir. Hızlı geri bildirim için pull request başına tüm paketlerde kod analizi, format kontrolü ve
testler çalıştırılmalıdır . UI tasarım sistemi paketinde de flutter_lints ve flutter_test
kullanılarak her bileşen için birim ve widget testleri yazılmalıdır.
Özel Widget (Bileşen) Geliştirme
Mimari ve Atomic Yapı: Atomic Design prensibine göre her bileşen katmanı net tanımlanır .
Örneğin “Atom” katmanı tekil widget’lardan (ör. basit düğme, ikon, metin) oluşur. “Molecule” düzeyi bu
atomların birleşimidir (örn. arama kutusu = input + buton) . “Organism” ise birden çok molekül veya
atoma sahip daha büyük bir UI parçasıdır (örn. navbar). Öneri: packages/ui_kit/lib/src/
components/atoms/ , .../molecules/ , .../organisms/ gibi klasörler oluşturun ve her bileşen
dosyasını ilgili katmana yerleştirin. Bu yaklaşım, parçalara odaklı çalışmayı ve yeniden kullanılabilir kod
yazmayı kolaylaştırır.
Kod Şablonları (Örnekler): Örneğin bir atom düğme bileşeni şöyle olabilir:
// lib/src/components/atoms/primary_button.dart
import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
class PrimaryButton extends StatelessWidget {
final String label;
final VoidCallback onPressed;
const PrimaryButton({required this.label, required this.onPressed, Key?
key}) : super(key: key);
@override
Widget build(BuildContext context) {
return ElevatedButton(
onPressed: onPressed,
style: ElevatedButton.styleFrom(
backgroundColor: AppColors.primary,
foregroundColor: AppColors.onPrimary,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(AppRadius.md),
),
),
child: Text(label),
);
}
}
Bu atomik düğme daha sonra bir molecule içinde tekrar kullanılabilir. Örneğin bir login form molekülü:
22
23
13
11 12
24
5
class LoginForm extends StatelessWidget {
// ...
@override
Widget build(BuildContext context) {
return Column(children: [
TextField(decoration: InputDecoration(labelText: 'Email')),
const SizedBox(height: AppSpacing.md),
PrimaryButton(label: 'Giriş Yap', onPressed: _login),
]);
}
}
Burada PrimaryButton bir atom örneğidir, LoginForm ise bir molecule. Atomic metodoloji
sayesinde her katmandaki bileşenler bağımsız test edilebilir. Örneğin PrimaryButton için widget testi
yazarak doğru renkte render edildiğinden emin olunur.
Kullanılacak Araçlar ve Paketler:
- Riverpod/Provider: Bileşenlerin üzerinde veri akışını sağlamak (örn. form verisi, tema durumu) için
kullanılır. Örneğin bir form validasyonu StateNotifier veya Provider ile yapılabilir.
- flutter_hooks: Bileşen içindeki state yönetimini basitleştirebilir (örn.
useTextEditingController() ).
- Equatable / freezed: Model veya UI state’lerini kolayca karşılaştırıp test etmeye yarayan paketler.
- flutter_svg: Vektör ikonları yüklemek için.
- flutter_test: Her custom widget için unit/widget testleri yazmak zorunludur. - Diğer: İkonlar için
font_awesome_flutter , animasyonlar için lottie veya rive ihtiyaca göre eklenebilir.
Olası Sorunlar ve Çözümleri:
- Esnek yapı: Bileşenler birbirine çok bağımlı olmamalıdır. Örn. bir molekül içerisinde kullandığınız atom
bileşeni değiştiğinde molekül de bozulmamalı; bu nedenle atomlar açık bir arayüz (props) ile veri almalı.
- Stateful bileşenler: Mümkünse bileşenleri stateless yapıp dışardan state yönetimi sağlanmalı. Eğer
state gerekiyorsa ConsumerWidget gibi kolay test edilebilir yapılar tercih edilebilir.
- İsim çatışmaları: Aynı isimde farklı katman bileşen olmasından kaçının. Örneğin hem atom hem
organism katmanında Card sınıfı olursa karışıklık olur. Detaylı klasör hiyerarşisi bu tip çatışmaları
önler.
- Tema ile uyum: Özel bileşenler Theme.of(context) veya tokenları referans almalı; inline sabit
renkler kullanılmamalıdır. Aksi halde tema değişiminden etkilenmeyen elemanlar oluşabilir.
- Performans: Bileşen ağaçları derin olursa, her build çağrısında karmaşık yapılar inşa etmek maliyetli
olabilir. Gerekli olmayan alt widget’lar için const işaretleyin. Ağır çizimler varsa RepaintBoundary
ile sınırlayın.
Performans, Bakım ve Test Edilebilirlik:
- Atomic tasarım bileşenleri küçük ve bağımsız olduğundan birim testleri kolaydır. Örneğin her atom için
widget testleri yazarak doğru düzenlenip düzenlenmediğini kontrol edin.
- Yeni bir bileşen eklendiğinde (örn. PrimaryButton ’a ikincil bir stil eklemek gibi) yalnızca o bileşen
üzerinde test güncellemesi gerekir; diğerleri etkilenmez, bu da bakımı kolaylaştırır.
- Kullanım Örneği – Yeni Bileşen Ekleme: Örneğin bir “DangerButton” bileşeni eklenecekse, bunu
atoms/ altına danger_button.dart olarak koyar, tasarım tokenlarını (örneğin
AppColors.error ) kullanarak tanımlar, sonra uygulamada tek satırla ( import 'package:ui_kit/
components/atoms/danger_button.dart' ) kullanılabilir hale getirirsiniz. Bu ekleme uygulamaya
6
global boyutta tutarlı bir stil getirir ve herhangi bir yerde tekrar kullanılabilir.
- Performans Maliyeti: Örneğin bir ListView içinde yüzlerce kart bileşeni kullandığınızda, her kart
kendi build metodu ile performans yükü getirebilir. Bu durumda const yapıcılar,
ListView.builder gibi tembel (lazy) widget’lar tercih edilmelidir. Genel olarak, Atomic bileşenler inmemory küçük ve hızlıdır; kötü performans genellikle karmaşık düzen veya aşırı gereksiz rebuild’lerden
kaynaklanır.
- Kapasite Etkisi: UI kütüphanesi kodu ve küçük resim/ikon varlıkları, uygulama boyutuna birkaç yüz KB
ila MB ekleyebilir. Örneğin her yeni özel font pakete birkaç yüz KB ekler. Bu etki, kütüphane içerisindeki
bağımlılıkların sayısına ve asset kullanımına bağlıdır. Ancak tutarlı bir design system ile uzun vadede
bakım maliyeti düşer.
Veri Akışı Örneği – Tema Değişikliği: Örneğin kullanıcı ayarlar ekranında “Karanlık Mod” anahtarına
dokunduğunda şu akış gerçekleşir: Switch tetiklenir → Riverpod themeProvider güncellenir (light/
dark toggling) → MyApp ya da MaterialApp otomatik olarak yeni themeMode ile rebuild olur
(çünkü ref.watch(themeProvider) kullanılır). Bu sayede UI anında yeni temayı yansıtır. Bu akışı
sağlamak için ref.listen(themeProvider, (prev, next) => {/* ... */}) gibi yöntemlerle
ayar değişikliği dinlenebilir.
Gerçek Kullanım Senaryoları: (1) Gece Modu Geçişi: Kullanıcı telefon karanlık moda aldığında veya
ayarlar menüsünden “Gece Modu” tuşuna bastığında themeMode = ThemeMode.dark yapılır. Bu, tüm
uygulamanın koyu temaya geçmesini sağlar (yukarıdaki veri akışı gerçekleşir). (2) Yeni Buton Bileşeni
Ekleme: Ürün ekibinin isteğiyle yeni bir “Onayla” stilinde buton gerekirse, PrimaryButton atomu
klonlanıp farklı stil tokenlarıyla (örn. renk, gölge) güncellenerek yeni bir molekül oluşturulabilir. Bu yeni
bileşen components/atoms altına eklenir ve proje çapında kullanılır. (3) Tema Renk Paleti
Güncelleme: Markaya göre bir palet değişikliği olursa, AppColors.primary vs değerleri tokens
katmanında güncellenir. Tüm kullanılan bileşenler bu tokenları referans aldığından otomatik olarak
yenilenir.
Responsive Tasarım Uygulamaları
Adaptif ve Duyarlı Tasarım: Flutter’da duyarlı (responsive) tasarım, UI elemanlarının mevcut ekrana
göre kendini düzenlemesi (ör. genişlikleri yüzde oranlı veya Expanded kullanarak esnetme) anlamına
gelir. Adaptif (adaptive) tasarım ise farklı cihaz tiplerine göre farklı düzen veya widget kullanılmasıdır (ör.
tablet için yan menü). Genel olarak tek terim içinde ele alınsalar da, responsive MediaQuery /
LayoutBuilder ile esnek düzen, adaptive ise AdaptiveLayout veya paketlerle farklı widget
seçimidir .
Kullanılacak Araçlar ve Paketler: - flutter_screenutil: Farklı ekran boyutlarına göre ölçekleme yapar.
ScreenUtilInit(designSize: Size(390, 844), ...) ile başlangıç yapılır ve ölçülendirme için
.w, .h, .sp uzantıları kullanılır . Örneğin Container(width: 100.w, height: 100.h)
veya fontSize: 18.sp gibi.
- adaptive_breakpoints: Ekran genişliğine göre cihaz tipini algılar. getWindowType(context)
fonksiyonu ile küçük (telefon), orta (tablet) veya büyük (desktop) cihaz ayrımı yapılabilir . Bu
sayede if (getWindowType(context)==AdaptiveWindowType.medium) tabletLayout() gibi
koşullar yazılır.
- flutter_platform_widgets: Farklı platformlarda (iOS, Android, Web) özel widget kullanımı sağlar.
Örneğin PlatformWidget ile Android’de ElevatedButton , iOS’ta CupertinoButton göstermek
mümkündür .
- LayoutBuilder & Flex: LayoutBuilder kullanarak ekran genişliğine göre Column yerine Row
25 26
27 28
29 30
31
7
kullanmak veya widget’ları farklı gruplarda sunmak yaygındır. Ayrıca Flexible , Expanded ,
GridView vb. widget’lar da responsive düzeni destekler .
Örnek Kod – flutter_screenutil:
return ScreenUtilInit(
designSize: const Size(390, 844),
builder: (context, child) {
return MaterialApp(
home: Scaffold(
body: Container(
width: 200.w, // tasarım 390dp genişlik temel alınarak ölçeklenir
child: Text('Başlık', style: TextStyle(fontSize: 16.sp)),
),
),
);
},
);
Bu kod, 390dp genişliğe göre tasarlanmış bir arayüzde, gerçek cihaz genişliğine orantılı bir görüntü
sunar .
Örnek Kod – adaptive_breakpoints:
LayoutBuilder(builder: (context, constraints) {
if (getWindowType(context) == AdaptiveWindowType.small) {
return PhoneLayout();
} else if (getWindowType(context) == AdaptiveWindowType.medium) {
return TabletLayout();
} else {
return DesktopLayout();
}
})
Bu yapı, adaptive_breakpoints ile cihazı sınıflandırarak uygun düzeni seçer .
Potansiyel Sorunlar ve Çözümler:
- Farklı ekranlarda bozuk düzen: Tasarım öğeleri çok sabit konumlu yapılırsa, küçük ekranlarda taşma
olabilir. Çözüm olarak Expanded , Flexible , FittedBox ve yüzde oranlı boyutlama kullanılmalı.
- Yeni ekran boyutlarıyla uyumsuzluk: Cihaz ailesi genişledikçe (katlanabilirler, tabletler) yeni kırılım
noktaları gerekebilir. adaptive_breakpoints ile özel aralıklar belirleyip her aralığa uygun tasarım
yapılabilir.
- Performans: Karmaşık responsive kontroller, her build’de hesaplanır. Gereksizse bu kontrolleri en üst
düzeye taşıyıp (örn. bir ResponsiveWrapper widget’ında) alt seviyelere yayılmasını önleyin.
- Deneme Yanılma: Tasarım sisteminde responsive davranışı doğrulamak için gerçek cihaz
emülatörlerinde test etmek gerekebilir. Özellikle web’de fare/klavye ile kontrol desteği ve büyük ekranlar
farklılık yaratabilir.
32
33 28
29 30
8
Performans, Bakım ve Test Edilebilirlik:
- Atomic bileşenler responsive özellikleri içeriyorsa, her boyutta doğru davrandığından emin olmak için
widget testleri yazılmalıdır (ör. pumpWidget ile farklı ekran çözünürlüklerini simüle etmek).
- Ekran kısıtlamaları (örn. constraints.maxWidth ) değiştikçe oluşabilecek UI kaymaları için
golden testler kurulabilir.
- Gerçek Kullanım Senaryoları: (1) Ekran Boyutu Değişimi: Bir kullanıcı telefonunu yatay moddan
dikeye çevirdiğinde veya bir tablet kullanmaya geçtiğinde, menu konumunun değişmesi (üst bar’dan
yan menüye) gibi yeniden düzenleme senaryoları. (2) Responsive Grid/List Görünüm: Buradaki
kullanıcı alışveriş kartlarını liste veya ızgara olarak görebiliyor. Küçük ekranda tek sütun listede, büyük
ekranda üçlü ızgarada gösterim örneği. (3) Farklı Platform Tasarımları: Android’de standart AppBar ,
iOS’ta CupertinoNavigationBar kullanımı gibi platform-spesifik widget seçimi (örn.
PlatformScaffold ) .
- Performans Maliyeti: Adaptive düzen seçimi genelde düşük maliyetlidir; basit bir if kontrolü. Ancak
sayfa düzeni tamamen yenileniyorsa (örn. bölünmüş ekran vs tek sütun) bu maliyeti artırabilir. Tasarım
sisteminde bu tip durumlar optimize edilerek (örn. IndexedStack ile ekranlar arasında geçiş yapıp
mevcut state’i koruyarak) performans yükü azaltılabilir.
UI Bileşen Kütüphanesi (packages/ui_kit) Oluşturma
Mimari Öneriler: Atomic Design prensibini monorepo paketine taşıyın. ui_kit paketi içindeki
klasörler Atomic katmanlarını yansıtmalıdır (tokens, atoms, molecules, vs.). Yukarıda bahsedilen dosya
yapısı bu noktada uygulanır. Temalar ( ThemeData ) ayrı bir katman, bileşenler bir diğeri olarak
düşünülür. Örneğin tokens katmanı diğer katmanlara bağımsızdır; atoms veya molecules sadece tokens
ve kendi alt katmanlarını kullanır . Bu bölümlendirme, ekip içinde rol dağılımına da yardımcı olur
(ör. bir geliştirici sadece atoms’a odaklanabilir).
Araçlar ve Paketler: - Melos / FlutterPub: Çoklu paket yönetimi için Melos kullanarak ui_kit , diğer
uygulama paketleri ve paylaşılan paketler arasında bağımlılıkları yönetin .
- CI/CD (GitHub Actions, Codemagic): Test, analiz ve yayın için otomasyon. Önceki bölümdeki Melos
komutlarını devreye alın . - flutter_lints: Kod standartlarını zorunlu kılar, tüm paketlerde aynı lint
kuralları uygulanır.
- Dokümantasyon: Kütüphane kullanımını belgelemek için README, otomatik API dokümantasyonu
veya Design System rehberi eklentileri düşünün. Markdown tabanlı rehber, her bileşenin nasıl
kullanılacağını örneklerle açıklar.
Kod Şablonları (Örnek): ui_kit paketinin pubspec.yaml örneği:
name: ui_kit
description: "Uygulamanın ortak UI tasarım sistemi paketi"
version: 0.1.0
environment:
sdk: '>=3.0.0 <4.0.0'
dependencies:
flutter:
sdk: flutter
flutter_riverpod: ^2.0.0
adaptive_breakpoints: ^0.0.4
flutter_screenutil: ^5.7.0
google_fonts: ^6.2.1
34
35 36
20 37
13 21
9
Melos yapılandırması: Örneğin ana dizinde melos.yaml :
name: project_repo
packages:
- packages/ui_kit
- apps/main_app
Bu ayarlarla hem uygulama hem de ui_kit aynı repo içinde geliştirilir .
Potansiyel Sorunlar ve Çözümleri:
- Sürüm Yönetimi: Monorepo’da çok sayıda paket olduğu için versiyon çakışmalarına dikkat edilmeli.
Melos’un otomatik sürümleme ve yayın özelliği kullanılabilir . - Bağımlılık Döngüleri: UI kit
bağımlılıkları, uygulama koduna ui_kit: ^0.1.0 yolu yerine path ile verilirse paketler çakışabilir.
Doğru paket etiketleme (örneğin ui_kit/ui_kit.dart ) ve Melos linklemeleriyle döngüler önlenir.
- Gereksiz Paket Büyümesi: ui_kit içine çok spesifik iş kuralları eklemeyin. Yalnızca genel UI öğeleri
ve temalar olsun. Uygulamaya özel logik ayrı pakette kalmalı. Böylece UI kütüphanesinin büyümesi
kontrol altında tutulur.
- Kullanım Hataları: Geliştiricilerin ui_kit ’ten doğru biçimde import ettiğinden emin olun. Ör.
import 'package:ui_kit/ui_kit.dart'; kullanılmalı, dosya yollayan import’lardan kaçınılmalı.
Lint kuralları ve code review bu sorunu azaltır.
Performans, Bakım ve Test Edilebilirlik:
- ui_kit tasarım sistemi, test kapsamı sayesinde yüksek güvenilir olmalıdır. Her bileşen için widget
testler ( flutter_test ) yazılmalı, örneğin önemli bileşenlerin render çıktıları karşılaştırılmalı (golden
test).
- UI kütüphanesi düzgün dokümante edilirse (özellikle kullanım örnekleri ve API açıklamaları), bakım ve
yeni geliştiricilerin adaptasyonu kolaylaşır.
- Real-World Use Case: (1) Yeni Bileşen Eklenmesi: Diyelim “Kırmızı Hatırlatma Butonu” eklenmesi
isteniyor. Tasarımcı AppColors.error rengini belirlemişse, bu renkten türeyen ErrorButton
bileşenini atoms dizinine ekler, testlerini yazar. Uygulamada şimdi bu bileşeni hızlıca çağırarak tutarlı
kırmızı bir stil elde edersiniz. (2) Tema Güncelleme Senaryosu: Markanın yeni bir mavisini kullanmak
istiyorsunuz; sadece AppColors.primary = Color(0xFF123ABC) yapılır, tüm paket temasında ve
atomlarda otomatik güncellemeler olur. (3) UI Kit İçindeki Bir Hatanın Düzeltmesi: Ortak bir atomda
bug bulunursa (ör. yanlış kenar boşluğu), ui_kit paketinde düzeltip yeni sürüm yayınlarsınız;
monorepo’daki diğer uygulamaların CI’si bu değişiklikle otomatik testleri çalıştırır ve güncellendiği
görülür.
Monorepo & CI/CD ile Entegrasyon: Daha önce belirtildiği gibi Melos’u kullanarak çoklu paketi tek repo
içinde yönetin . CI/CD hattında melos komutlarını kullanarak otomatik test ve yayımlama
yapabilirsiniz . Özellikle, uygulama ve ui_kit aynı repoda olduğunda melos bootstrap ile
tüm bağımlılıklar aynı anda kurulabilir. Github Actions veya Codemagic pipeline’ında tüm paketler için
melos run analyze , melos run test gibi işlemler tanımlanmalıdır . Monorepo’da CI uç
noktaları genellikle paket düzeyinde çalışır: her PR için tüm testler ve analizler yapılır; kritik paketlere ek
testler (ör. ui bileşenlerinin golden testleri) eklenir. Bu yapı, tek bir merkezi derleme ve sürüm yönetimi
sağlar, böylece ui_kit ’e yapılan güncellemeler anında uygulamalarda test edilir.
Material 3 tasarım sisteminde açık ve koyu mod uyumu temel önceliktir. Yukarıdaki örnek, LeanCode’un
bankacılık uygulamasında açık ve koyu mod tasarımını gösterir. Tasarım sistemi bu iki modu tutarlı renk
paletiyle destekleyerek her durumda erişilebilir bir deneyim sunar .
37
20
20
13 21
13
2 9
10
Kaynaklar: Material 3 temaları için Flutter dokümantasyonunda ThemeData ve
ColorScheme.fromSeed kullanımı ; responsive/adaptive düzen için Flutter dökümantasyonu ve
örnek kodlar ; Atomic Design ve tasarım sistemleri için LeanCode ve diğer bloglar ;
monorepo yönetimi ve Melos için ilgili rehberler ; erişilebilirlik için Flutter A11y rehberleri
.
Mastering Material Design 3: The Complete Guide to Theming in Flutter
https://www.christianfindlay.com/blog/flutter-mastering-material-design3
Design Systems in Flutter: Build Scalable UI with Design Tokens
https://indusvalley.io/blogs/flutter-design-systems-with-tokens
google_fonts | Flutter package
https://pub.dev/packages/google_fonts
Flutter Design System in Large-Scale Apps: How to Build It? - LeanCode
https://leancode.co/blog/building-a-design-system-in-flutter-app
Mastering Accessibility (A11y) in Flutter: The Only Guide You’ll Ever Need | by
Himanshu Agarwal | Jun, 2025 | Medium
https://himanshu-agarwal.medium.com/mastering-accessibility-a11y-in-flutter-the-only-guide-youll-ever-need-05cfd4dbf664
Flutter with Atomic Design
https://dev.notsu.io/flutter-with-atomic-design
How to manage your Flutter monorepos | Codemagic Blog
https://blog.codemagic.io/flutter-monorepos/
Flutter — Building a Design System with Atomic Design | by HlfDev | Medium
https://medium.com/@hlfdev/building-a-design-system-with-atomic-design-in-flutter-a7a16e28739b
Melos
https://melos.invertase.dev/
Adaptive design | Flutter
https://docs.flutter.dev/ui/adaptive-responsive
Adaptive vs. Responsive: How It In Flutter? | by Mosab Youssef "Khaled Abd El
Fattah Youssef " | Medium
https://ms3byoussef.medium.com/adaptive-vs-responsive-how-it-in-flutter-65b0f9682b3b
Flutter Screenutil — Create Responsive Application | by Chandra Duta | Medium
https://mdutachandra.medium.com/flutter-screenutil-create-responsive-flutter-apps-54c4c7b459da
GitHub - nimblehq/flutter-monorepo-example: Having multiple repositories in 1 repo
https://github.com/nimblehq/flutter-monorepo-example
1
25 38 7 11
20 13 10
14
1 8
2 3 6
4 5 19
7 12
9 10 14 15 16
11 18 24 36
13 21 22 23
17 35
20
25
26 29 30 31 32 34 38
27 28 33
37
11
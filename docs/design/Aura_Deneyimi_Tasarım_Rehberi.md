
Kişiselleştirilmiş Material 3 ile Flutter’da Sıcak, Akıllı ve Rehberlik Eden Bir UI/UX Tasarlama Rehberi


I. Aura Görsel Kimliği: Sıcak ve Rehberlik Eden Bir Material 3 Tasarım Sistemi

Bu temel bölüm, Aura'nın temel görsel dilini tanımlamaktadır. Amaç, genel bir Material 3 uygulamasının ötesine geçerek hedef kullanıcı kitlesiyle kişisel ve duygusal olarak rezonans kuran, benzersiz bir tasarım sistemi oluşturmaktır. Bu sistem, uygulamanın "sıcak, akıllı ve rehberlik eden" kişiliğini her bir pikselde yansıtacak şekilde tasarlanmıştır.

1.1. Aura Renk Sistemi: "Sıcak, Kişisel, Evrensel" Bir Palet Oluşturma

Aura'nın marka kimliğini somutlaştıran kapsamlı bir renk sistemi tanımlamak, bu sürecin ilk ve en kritik adımıdır. Bu sistem, uygulamanın ruhunu yansıtan tek bir "tohum" renkten (seed color) yola çıkarak, hem aydınlık hem de karanlık temalarda erişilebilirlik ve uyumu algoritmik olarak güvence altına alacak şekilde Material Theme Builder aracı kullanılarak oluşturulmuştur.

Rasyonel ve Strateji

Uygulamanın temel kimliği "sıcak, samimi, evrensel" olarak tanımlanmıştır [FAZ 1]. Bu tanım, renk paleti seçiminde soğuk mavilerden ve steril grilerden bilinçli bir şekilde uzaklaşmayı gerektirir. Dribbble gibi platformlardaki "sıcak" paletler incelendiğinde, toprak tonları, yumuşak portakallar, bastırılmış kırmızılar ve kremsi beyazların bu hissi başarıyla yansıttığı görülmektedir.1
Ancak, "evrensel" gereksinimi, "sıcak" konseptine önemli bir kısıtlama getirir. Tamamen sıcak bir palet, niş veya mevsimsel (örneğin sonbahar) bir his yaratabilir ve 18-35 yaş arası geniş hedef kitleye hitap etmeyebilir. Bu dengeyi kurmanın anahtarı, Material 3'ün renk sisteminin yapısında yatmaktadır. Sistem, seçilen tohum renkten sadece vurgu renklerini (Primary, Secondary, Tertiary) değil, aynı zamanda arayüzün temelini oluşturan Nötr (Neutral) ve Nötr Varyant (Neutral Variant) paletlerini de türetir.3
Bu doğrultuda, ana tohum renk olarak sofistike ve stil sahibi bir Terracotta (Toprak Rengi - HEX: #BC6D4F) seçilmiştir. Bu seçim, hem sıcaklığı ve samimiyeti yansıtır hem de moda odaklı hedef kitlenin estetik beklentileriyle uyumludur. Material Theme Builder 4, bu tohum rengi kullanarak Nötr paleti de bu sıcaklığın hafif bir tonuyla zenginleştirir. Sonuç olarak, ana eylem butonları ve vurgular belirgin bir şekilde sıcak ve davetkar olurken; kartlar, arka planlar ve metin alanları gibi arayüzün büyük bir kısmını oluşturan yüzeyler, temiz, profesyonel ve evrensel bir çekiciliğe sahip olur. Bu yaklaşım, sıcaklığın baskın bir tema olmaktan çıkıp, uygulamanın genelinde bir alt ton ve vurgu olarak hissedilmesini sağlayarak üç temel kriteri de (sıcak, samimi, evrensel) karşılar.

Aydınlık ve Karanlık Tema Renk Şeması

Aşağıdaki tablo, #BC6D4F tohum renginden Material Theme Builder ile üretilen, Aura uygulaması için önerilen tam renk şemasını ve her bir renk rolünün anlamsal kullanımını detaylandırmaktadır. Bu tablo, Figma tasarımları ile nihai Flutter uygulaması arasında birebir tutarlılık sağlamak için geliştirme ekibinin tek doğruluk kaynağı (single source of truth) olarak hizmet edecektir.
Renk Rolü	Aydınlık Tema HEX	Karanlık Tema HEX	Açıklama ve Kullanım Alanı
primary	#9A4524	#FFB696	Ana etkileşimli öğeler: FAB'lar, birincil butonlar, aktif durumlar.
onPrimary	#FFFFFF	#5F1800	primary rengi üzerindeki metin/ikonlar.
primaryContainer	#FFDBCB	#7C2E0E	Birincil vurgu gerektiren daha az belirgin konteynerler.
onPrimaryContainer	#380D00	#FFDBCB	primaryContainer üzerindeki metin/ikonlar.
secondary	#775749	#E7BDB0	İkincil butonlar, filtre çipleri, kaydırıcılar (slider).
onSecondary	#FFFFFF	#442A1F	secondary rengi üzerindeki metin/ikonlar.
secondaryContainer	#FFDBCB	#5D4038	İkincil vurgu gerektiren konteynerler.
onSecondaryContainer	#2C160C	#FFDBCB	secondaryContainer üzerindeki metin/ikonlar.
tertiary	#665F31	#D2C88F	Kontrast oluşturan vurgular, dekoratif öğeler.
onTertiary	#FFFFFF	#373107	tertiary rengi üzerindeki metin/ikonlar.
tertiaryContainer	#EEE4AA	#4E471C	Üçüncül vurgu gerektiren konteynerler.
onTertiaryContainer	#211C00	#EEE4AA	tertiaryContainer üzerindeki metin/ikonlar.
error	#BA1A1A	#FFB4AB	Hata durumlarını belirten bileşenler (örn: geçersiz metin alanı).
onError	#FFFFFF	#690005	error rengi üzerindeki metin/ikonlar.
errorContainer	#FFDAD6	#93000A	Hata vurgusu gerektiren daha az belirgin konteynerler.
onErrorContainer	#410002	#FFDAD6	errorContainer üzerindeki metin/ikonlar.
background	#FFFBFF	#201A18	Uygulamanın en alt katmanındaki arka plan rengi.
onBackground	#201A18	#EBE0DC	background üzerindeki metin/ikonlar.
surface	#FFFBFF	#201A18	Bileşen yüzeyleri (Kartlar, menüler, bottom sheet'ler).
onSurface	#201A18	#EBE0DC	surface üzerindeki ana metin/ikonlar.
surfaceVariant	#F5DED5	#53433E	Yüzeylerden farklılaşan konteynerler (örn: çip anahatları).
onSurfaceVariant	#53433E	#D8C2BB	surfaceVariant üzerindeki metin/ikonlar.
outline	#85736C	#A08D85	Ayırıcılar ve dekoratif olmayan anahatlar.
shadow	#000000	#000000	Gölgelendirme rengi.
inverseSurface	#362F2C	#EBE0DC	Varsayılan yüzeyin tersi renkteki yüzeyler.
onInverseSurface	#FBEFEA	#201A18	inverseSurface üzerindeki metin/ikonlar.
inversePrimary	#FFB696	#9A4524	inverseSurface üzerindeki interaktif öğeler için.

1.2. Aura Tipografi Ölçeği: Stil ve Okunabilirliği Dengelemek

Tipografi seçimi, Aura'nın "akıllı ve rehberlik eden" kişiliğini doğrudan etkiler. Başlıklar için seçilen font, uygulamanın modern ve stil sahibi yönünü ("akıllı") yansıtmalı; gövde metinleri için seçilen font ise özellikle sohbet tabanlı arayüzlerde uzun süreli okuma için olağanüstü netlik ("rehberlik eden") sunmalıdır.

Font Ailesi Seçimi ve Gerekçesi

Aura, estetik duyarlılığı yüksek bir kitleye hitap ettiğinden, tipografinin belirgin bir karaktere sahip olması gerekir [FAZ 1]. Bu bağlamda, jenerik fontlardan kaçınılmalıdır. Aynı zamanda, uygulamanın temel özelliklerinden biri olan StyleAssistantScreen 5, yoğun metin iletişimine dayalıdır ve bu da gövde metni için okunabilirliği en üst düzeye çıkarmayı zorunlu kılar.
Bu dengeyi sağlamak için önerilen font eşleşmesi şudur:
●	Başlıklar (Display, Headline, Title): Urbanist
○	Urbanist, Modernist tipografiden ilham alan, düşük kontrastlı, geometrik bir sans-serif fonttur.6 Bu özellikleri ona temiz, mimari ve yüksek moda bir his kazandırır. Bu, uygulamanın stil odaklı doğasıyla mükemmel bir uyum içindedir. Dikkat dağıtıcı olmadan stil sahibi bir görünüm sunarak
display, headline ve title rolleri için ideal bir seçimdir.7
●	Gövde Metinleri (Body, Label): Inter
○	Inter, özellikle kullanıcı arayüzü okunabilirliği için tasarlanmış, son derece net bir sans-serif fonttur.8
StyleAssistantScreen gibi sohbet arayüzlerinde uzun mesajların rahatça okunabilmesi için kritik olan yüksek okunabilirlik sunar. Benzer bir aday olan Nunito Sans'ın daha yuvarlak hatlarına kıyasla Inter'in nötr yapısı, yoğun metin bloklarında daha fazla netlik sağlar.9
Bu eşleştirme, hem şık hem de işlevsel, net bir görsel hiyerarşi oluşturur ve uygulamanın kişiliğiyle tam olarak örtüşür.

Material 3 Tipografi Ölçeği

Aşağıdaki TextTheme tanımı, Urbanist ve Inter font ailelerini kullanarak Material 3'ün 15 temel stilini 10 Aura'nın ihtiyaçlarına göre özelleştirir. Bu ölçek, uygulama genelinde tutarlı bir tipografik yapı sağlar.
Stil Rolü	Font Ailesi	Ağırlık	Boyut (sp)	Satır Yüksekliği (sp)
displayLarge	Urbanist	Regular	57	64
displayMedium	Urbanist	Regular	45	52
displaySmall	Urbanist	Regular	36	44
headlineLarge	Urbanist	SemiBold	32	40
headlineMedium	Urbanist	SemiBold	28	36
headlineSmall	Urbanist	SemiBold	24	32
titleLarge	Urbanist	Bold	22	28
titleMedium	Urbanist	Bold	16	24
titleSmall	Urbanist	Medium	14	20
bodyLarge	Inter	Regular	16	24
bodyMedium	Inter	Regular	14	20
bodySmall	Inter	Regular	12	16
labelLarge	Inter	Medium	14	20
labelMedium	Inter	Medium	12	16
labelSmall	Inter	Medium	11	16

1.3. Tasarım Sistemini Kodlamak: ThemeData Uygulaması

İyi yapılandırılmış bir ThemeData, sadece bir stil tanımı değil, aynı zamanda tasarım ve geliştirme arasında tutarlılığı zorunlu kılan ve UI geliştirme sürecini önemli ölçüde hızlandıran bir sözleşmedir. Renk ve tipografi kararlarını merkezileştirerek ve bileşen temalarını önceden tanımlayarak, geliştiricilerin tekil widget'ları stilize etme ihtiyacını ortadan kaldırır, kod tekrarını azaltır ve görsel tutarsızlık riskini en aza indirir.
Aura'nın, kart tabanlı arayüzleri (ClothingItemCard, OutfitCard) ve form elemanlarını (LoginScreen, AddClothingItemScreen) yoğun bir şekilde kullandığı göz önüne alındığında, CardTheme ve InputDecorationTheme gibi bileşen temalarını merkezi olarak tanımlamak, kod tabanının temiz ve sürdürülebilir kalması için hayati önem taşır.5 Bu yaklaşım, "yeniden kullanılabilir, ortak bileşenler" oluşturma mimari hedefini doğrudan destekler [FAZ 1].
Aşağıda, Aura'nın görsel kimliğini Flutter koduna dönüştüren, üretime hazır, tam bir ThemeData uygulaması sunulmaktadır.

Dart


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuraTheme {
  AuraTheme._();

  static const Color _seedColor = Color(0xFFBC6D4F);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    );

    final textTheme = _createTextTheme(colorScheme);

    return ThemeData.from(
      colorScheme: colorScheme,
      textTheme: textTheme,
      useMaterial3: true,
    ).copyWith(
      cardTheme: _cardTheme(colorScheme),
      inputDecorationTheme: _inputDecorationTheme(colorScheme, textTheme),
      filledButtonTheme: _filledButtonTheme(textTheme),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    );

    final textTheme = _createTextTheme(colorScheme);

    return ThemeData.from(
      colorScheme: colorScheme,
      textTheme: textTheme,
      useMaterial3: true,
    ).copyWith(
      cardTheme: _cardTheme(colorScheme),
      inputDecorationTheme: _inputDecorationTheme(colorScheme, textTheme),
      filledButtonTheme: _filledButtonTheme(textTheme),
    );
  }

  static TextTheme _createTextTheme(ColorScheme colorScheme) {
    final urbanistTheme = GoogleFonts.urbanistTextTheme();
    final interTheme = GoogleFonts.interTextTheme();

    return TextTheme(
      displayLarge: urbanistTheme.displayLarge?.copyWith(color: colorScheme.onSurface),
      displayMedium: urbanistTheme.displayMedium?.copyWith(color: colorScheme.onSurface),
      displaySmall: urbanistTheme.displaySmall?.copyWith(color: colorScheme.onSurface),
      headlineLarge: urbanistTheme.headlineLarge?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w600),
      headlineMedium: urbanistTheme.headlineMedium?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w600),
      headlineSmall: urbanistTheme.headlineSmall?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w600),
      titleLarge: urbanistTheme.titleLarge?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
      titleMedium: urbanistTheme.titleMedium?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
      titleSmall: urbanistTheme.titleSmall?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w500),
      bodyLarge: interTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
      bodyMedium: interTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
      bodySmall: interTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
      labelLarge: interTheme.labelLarge?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w500),
      labelMedium: interTheme.labelMedium?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w500),
      labelSmall: interTheme.labelSmall?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w500),
    );
  }

  static CardTheme _cardTheme(ColorScheme colorScheme) {
    return CardTheme(
      elevation: 2.0,
      shadowColor: colorScheme.shadow.withOpacity(0.1),
      surfaceTintColor: Colors.transparent, // M3'ün varsayılan renk tonlamasını kaldırır
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(ColorScheme colorScheme, TextTheme textTheme) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
      labelStyle: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
      hintStyle: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: colorScheme.error, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: colorScheme.error, width: 2.0),
      ),
    );
  }
  
  static FilledButtonThemeData _filledButtonTheme(TextTheme textTheme) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: textTheme.labelLarge,
      ),
    );
  }
}


1.4. Dokümantasyon Taslağı: STYLE_GUIDE.md

Bu doküman, geliştiriciler için tasarım sisteminin prensiplerini ve pratik kullanımını açıklayan bir rehber görevi görür.

Aura Tasarım Sistemi Stil Rehberi (v1.0)

Bu rehber, Aura uygulamasının görsel kimliğini ve UI bileşenlerinin kullanım standartlarını tanımlar. Amaç, uygulama genelinde tutarlı, markaya uygun ve yüksek kaliteli bir kullanıcı deneyimi sağlamaktır.

1. Tasarım Felsefesi

Aura'nın tasarım felsefesi üç temel üzerine kuruludur: Sıcak, Akıllı ve Rehberlik Eden.
●	Sıcak: Renk paletimiz ve yumuşak hatlarımızla kullanıcıyı davetkar ve samimi bir ortamda hissettiririz.
●	Akıllı: Modern tipografimiz ve temiz düzenlerimizle sofistike ve stil sahibi bir görünüm sunarız.
●	Rehberlik Eden: Net hiyerarşi, yüksek okunabilirlik ve sezgisel etkileşimlerle kullanıcıya yol gösteririz.

2. Renk Paleti

Renk sistemimiz, Material 3 standartlarına uygun olarak tek bir tohum renkten (#BC6D4F) türetilmiştir. Renkleri anlamsal rollerine göre kullanın.

Anahtar Renkler (Aydınlık Tema)

●	Primary: #9A4524 (Ana eylemler, aktif durumlar)
●	Secondary: #775749 (İkincil eylemler, filtreler)
●	Tertiary: #665F31 (Dekoratif vurgular)
●	Surface: #FFFBFF (Kartlar, arka planlar)
●	Error: #BA1A1A (Hata durumları)

Anahtar Renkler (Karanlık Tema)

●	Primary: #FFB696
●	Secondary: #E7BDB0
●	Tertiary: #D2C88F
●	Surface: #201A18
●	Error: #FFB4AB
Tam renk listesi ve rolleri için AuraTheme sınıfına başvurun.

3. Tipografi

Tipografi ölçeğimiz, stil ve okunabilirlik arasında bir denge kurar.
●	Başlık Fontu: Urbanist (Display, Headline, Title rolleri için kullanılır)
●	Gövde Fontu: Inter (Body, Label rolleri için kullanılır)

Kullanım Hiyerarşisi

●	displayLarge/Medium/Small: Pazarlama metinleri veya çok önemli, kısa başlıklar için.
●	headlineLarge/Medium/Small: Ekran başlıkları için.
●	titleLarge/Medium/Small: Kart başlıkları, diyalog başlıkları gibi orta düzey vurgular için.
●	bodyLarge/Medium: Uzun metinler, açıklamalar, sohbet mesajları için.
●	bodySmall: Yardımcı metinler, alt yazılar için.
●	labelLarge/Medium/Small: Butonlar, sekmeler ve diğer kompakt bileşen metinleri için.

4. Bileşen Prensipleri

●	Kartlar (CardTheme):
○	Köşe Yarıçapı: 16.0
○	Yükseklik (Elevation): 2.0
○	Gölge: Hafif ve yumuşak.
●	Metin Alanları (InputDecorationTheme):
○	Stil: Doldurulmuş (filled), kenarlıksız (border: BorderSide.none).
○	Köşe Yarıçapı: 12.0
○	Odaklanma Durumu: 2.0 kalınlığında primary renkli kenarlık.
●	Butonlar (FilledButtonTheme):
○	Köşe Yarıçapı: 12.0
○	Dolgu (Padding): Dikey 16.0, Yatay 24.0.

5. Boşluk ve Düzen (Spacing & Layout)

Tüm düzenlerde tutarlılık için 8.0 birimlik bir temel boşluk sistemi kullanılır. Tüm padding, margin ve SizedBox değerleri bu birimin katları olmalıdır (8.0, 16.0, 24.0, 32.0 vb.).

II. Stratejik Kullanıcı Akış Tasarımı: Onboarding ve Öneriler

Bu bölüm, Aura'nın en kritik kullanıcı yolculuklarını mimari olarak tasarlamaya odaklanmaktadır. Rakip uygulamaların başarılı kalıpları analiz edilerek, Aura için daha üstün ve duygusal olarak zeki bir akış sentezlenmiştir.

2.1. Aura Onboarding Deneyimi: Rehberli Bir Sohbet

Aura'nın onboarding süreci, kullanıcı tercihlerini etkili bir şekilde toplarken, "asistan" kişiliğiyle uyumlu, kişisel ve ilgi çekici bir deneyim sunmalıdır. Bu, salt bir form doldurma hissinden uzaklaşarak, kullanıcıyı bir keşif yolculuğuna çıkaran rehberli bir diyalog olarak tasarlanmıştır.

Rakip Analizi ve Strateji Belirleme

●	Stitch Fix: Kullanıcıdan 10-15 dakikalık detaylı bir stil anketi doldurmasını ister.11 Bu süreç, "pozitif sürtünme" (positive friction) yaratarak kullanıcının platforma olan yatırımını ve güvenini artırmayı hedefler.11 Arayüz, çoktan seçmeli sorular ve görsel tabanlı "beğen/beğenme" seçenekleri içerir.13 Bu veriler, kullanıcıya özel bir "StyleFile" (Stil Dosyası) oluşturmak için kullanılır.14 Bu yaklaşımın gücü, derinlemesine veri toplama ve kişiselleştirme hissiyatıdır; zayıflığı ise kullanıcıyı yorabilmesi ve başlangıçta göz korkutucu olabilmesidir.
●	Whering: Kullanıcıyı hızla gardırobuna kıyafet eklemeye yönlendirir (fotoğraf çekme, veritabanından arama, mağaza sitesinden içe aktarma).15 Onboarding süreci daha doğrudan ve hızlıdır, bir anketten çok işlevsel bir başlangıca odaklanır.17 Değer önerisi, gardırobun anında dijitalleştirilmesidir. Gücü hızı ve anlık faydasıyken, zayıflığı başlangıçtaki kişiselleştirme derinliğinin sığ kalmasıdır.
Aura için en uygun strateji, bu iki yaklaşımı birleştiren hibrit bir modeldir: Stitch Fix'in psikolojik derinliğini Whering'in hızıyla birleştiren ve tüm süreci kişisel bir asistanla yapılan bir "sohbet" olarak çerçeveleyen "konuşma tabanlı bir adımlayıcı (stepper)" yaklaşımıdır. Aura'nın "asistan gibi" [FAZ 1] kişiliği, bir formdan ziyade bir diyalog gerektirir. Bu nedenle, uzun bir anket yerine, süreci mantıksal ve sindirilebilir adımlara bölen bir Stepper bileşeni kullanılacaktır.19 Her adımda, kullanıcının ilerlemesini net bir şekilde görmesi, yorgunluğu ve süreci terk etme oranını azaltacaktır.

Önerilen Onboarding Akışı ve Flutter Bileşenleri

1.	Karşılama Ekranları (PageView):
○	Bileşen: PageView.20
○	Akış: Kullanıcıya uygulamanın değer önerisini sunan 3 adet tam ekran, kaydırılabilir sayfa. Bu sayfalar, Aura'nın sıcak görsel kimliğini yansıtan illüstrasyonlar ve kısa, etkili metinler içerecektir:
1.	"Kişisel stil asistanın Aura ile tanış."
2.	"Gardırobunun potansiyelini keşfet."
3.	"Sana özel kombinlerle tarzını bulalım."
○	Rationale: PageView, kullanıcıya kontrol hissi veren ve bilgiyi adım adım sunan, modern onboarding akışları için standart bir yaklaşımdır.21
2.	Hesap Oluşturma / Giriş:
○	Akış: Standart kimlik doğrulama ekranı. InputDecorationTheme ile stilize edilmiş TextFormField'lar ve PrimaryButton kullanılacaktır.
3.	Stil Testi (Stepper):
○	Bileşen: Stepper.19
○	Akış: Kullanıcıyı 5 adımdan oluşan bir stil keşif yolculuğuna çıkaran dikey bir adımlayıcı. Her adım, bir sohbet baloncuğu içinde asistan tarafından sorulan bir soru gibi çerçevelenecektir.
○	Adım 1: Stil Hissiyatı (PageView):
■	Asistan Sorusu: "Tarzını daha iyi anlamak için, bu görünümlerden hangileri sana hitap ediyor?"
■	UI: Farklı estetiklere sahip tam ekran outfit görsellerinin olduğu bir PageView. Kullanıcı, bir stilistle lookbook karıştırıyormuş gibi sağa veya sola kaydırarak görselleri "beğenir" veya "geçer".
○	Adım 2: Renkler ve Desenler (FilterChip):
■	Asistan Sorusu: "Harika seçimler! Peki hangi renkler ve desenler seni daha çok heyecanlandırır?"
■	UI: Renk örnekleri ve desen görselleri içeren bir Wrap düzeni içinde çoklu seçime olanak tanıyan FilterChip'ler.24 Kullanıcı favori renklerini ve desenlerini (örn: "Çiçekli", "Ekose", "Minimalist") seçer.
○	Adım 3: Kalıp ve Beden:
■	Asistan Sorusu: "Kıyafetlerinin üzerine nasıl oturmasını tercih edersin?"
■	UI: Vücut ölçüleri ve kalıp tercihleri ("Dar Kesim", "Normal", "Bol Kesim") için standart form elemanları.
○	Adım 4: Bütçe (RangeSlider):
■	Asistan Sorusu: "Alışveriş yaparken genellikle hangi fiyat aralıklarını tercih edersin?"
■	UI: Farklı ürün kategorileri (Üst Giyim, Alt Giyim, Ayakkabı vb.) için fiyat aralıklarını belirlemeye yarayan RangeSlider bileşenleri.
○	Adım 5: Son Dokunuşlar (TextField):
■	Asistan Sorusu: "Stilistin için özel bir notun var mı? Belki yaklaşan bir etkinlik veya aradığın özel bir parça?"
■	UI: Kullanıcının stilistine serbest metin formatında not bırakabileceği bir TextField. Bu adım, kişisel bağlantıyı pekiştirir ve süreci insancıllaştırır.
Bu yapılandırılmış akış, Stitch Fix'in derinlemesine veri toplama avantajını, daha interaktif ve daha az yorucu bir formatta sunarak kullanıcı deneyimini iyileştirir.

2.2. Etkileşimli Öneri Kartları: Statik Görüntünün Ötesinde

Stil önerilerinin sunum şekli, kullanıcının öneriyi ne kadar değerli bulacağını doğrudan etkiler. Statik bir ürün listesi yerine, farklı kullanıcı niyetlerine ve bağlamlarına hizmet eden, etkileşimli ve dinamik sunum formatları tasarlanmalıdır. Aura'nın "akıllı asistan" kimliği, önerilerin de akıllı ve bağlama duyarlı bir şekilde sunulmasını gerektirir.

Üç Farklı Öneri Konsepti

Kullanıcının farklı anlardaki ihtiyaçlarına yönelik üç özgün ve interaktif öneri sunum konsepti geliştirilmiştir: Hızlı geri bildirim toplama, detaylı keşif ve kürate edilmiş keşif.

Konsept 1: "Stil Nabzı" Kaydırıcısı (Hızlı Geri Bildirim)

●	Flutter Paketi: flutter_card_swiper.26
●	Tanım: Tinder benzeri, tam ekran bir kart arayüzü. Her kartta tek bir stil görseli (bir kombin, bir ürün veya bir estetik) bulunur. Bu format, yapay zekanın kullanıcı zevkini hızla kalibre etmesi için tasarlanmıştır.
●	Etkileşim Modeli:
○	Sağa Kaydırma: "Beğendim" - Beğenilenlere eklenir ve algoritmayı besler.
○	Sola Kaydırma: "Bana göre değil" - Kart atılır ve algoritmayı besler.
○	Yukarı Kaydırma: "İstek Listeme Ekle" - Daha sonra incelenmek üzere kaydedilir.
○	Dokunma (Tap): Etkileşim yok. Bu, kullanıcıyı bilinçli bir karar vermeye (kaydırmaya) teşvik eder.
●	Kullanım Senaryosu: Stil Asistanı'nın hızlı tercih toplama anları için idealdir. Örneğin: "Zevkini daha iyi anlamak için birkaç stil göstereceğim. Bunlar hakkında ne düşünüyorsun?"
●	Wireframe Açıklaması: Ekranın merkezinde, altında hafifçe görünen bir sonraki kartla birlikte büyük bir görsel kart bulunur. Kartın altında "Beğenmedim" ve "Beğendim" ikonları olan butonlar da programatik kontrol için yer alabilir.

Konsept 2: "Kombin Analizi" Sayfası (Detaylı Keşif)

●	Flutter Bileşeni: DraggableScrollableSheet.28
●	Tanım: Sohbet ekranının altından çıkan ve başlangıçta ekranın %40'ını kaplayan bir panel. Bu panelin görünen kısmında, önerilen kombinin (OutfitCard) büyük bir hero görseli yer alır. Bu konsept, kullanıcıya önce genel görünümü sunup, ardından detaylara inme imkanı tanır.
●	Etkileşim Modeli:
○	Kullanıcı paneli yukarı doğru sürükleyebilir.
○	Panel ekranın %90'ına (maxChildSize) ulaştığında, hero görselinin altında kombini oluşturan her bir parçanın (ProductCard) listelendiği kaydırılabilir bir ListView ortaya çıkar.
○	Listedeki her bir ürün, detaylarını görmek veya satın almak için dokunulabilir.
●	Kullanım Senaryosu: Stil Asistanı'nın tam kombin önerilerini sunmak için birincil yöntemdir. "Bu akşamki yemeğin için şöyle bir kombin hazırladım."
●	Wireframe Açıklaması: Ekranın alt kısmında, üst kenarı yuvarlatılmış ve bir "tutma" çubuğu olan bir panel bulunur. Panelde büyük bir kombin fotoğrafı vardır. Panel yukarı sürüklendiğinde, fotoğraf küçülerek başlık alanına yerleşir ve altındaki alan ürün listesiyle dolar.

Konsept 3: "Küratörün Seçkisi" Destesi (Keşif Deneyimi)

●	Flutter Paketi: stacked_card_carousel.30
●	Tanım: Birbirinin arkasından hafifçe görünen, dikey olarak istiflenmiş bir kart destesi. Her kart, bir kombini veya özel bir ürünü temsil eder. Bu sunum, kullanıcıya özel olarak hazırlanmış bir koleksiyonu "kutudan çıkarıyormuş" gibi keyifli bir keşif hissi verir.
●	Etkileşim Modeli:
○	Kullanıcı en üstteki kartı yukarı doğru kaydırarak desteden çıkarır ve bir sonraki kartı ortaya çıkarır.
○	Bir karta dokunmak, kartın kendi etrafında dönmesini (flutter_flip_card 31 paketi ile) ve arkasında "Bunu neden seveceksin?" gibi yapay zeka tarafından yazılmış kişisel bir notu veya kombinin detaylarını göstermesini sağlayabilir.
●	Kullanım Senaryosu: "Hafta Sonu Kombinlerin" veya "Bu Sezonun Öne Çıkan 5 Ceketi" gibi temalı koleksiyonları sunmak için kullanılır.
●	Wireframe Açıklaması: Ekranın ortasında, perspektif ve gölge efektleriyle derinlik hissi verilmiş, üst üste dizilmiş 3-4 kart görünür. En üstteki kart tamamen görünürken, alttakiler kısmen görünür. Kullanıcı kaydırdıkça, alttaki kartlar yumuşak bir animasyonla öne gelir.

III. Ölçeklenebilir ve Sürdürülebilir Bir Flutter UI Mimarisi

Bu bölüm, Aura'nın sunum katmanının yapısal temelini tanımlar. Amaç, uygulama karmaşıklığı arttıkça kod tabanının temiz, mantıksal ve yeni geliştiriciler için anlaşılır kalmasını sağlamaktır.

3.1. Sunum Katmanı Mimarisi: Özellik Odaklı (Feature-First) Yapı

Uygulama mimarisinin doğru kurgulanması, uzun vadeli bakım ve ölçeklenebilirlik için kritik öneme sahiptir. Özellikle Aura gibi 16'dan fazla detayı tanımlanmış özelliğe sahip 5 büyük bir projede, kodun mantıksal olarak gruplandırılması kaçınılmazdır.

Rasyonel ve Yapı Seçimi

Sektördeki en iyi pratikler, büyük ölçekli Flutter uygulamaları için katman odaklı (layer-first) bir yapı yerine özellik odaklı (feature-first) bir yapıyı önermektedir.32 Katman odaklı yapıda (
lib/screens, lib/widgets, lib/controllers gibi), bir özellik üzerinde çalışmak birden çok klasör arasında gezinmeyi gerektirir ve bu da bilişsel yükü artırır. Özellik odaklı yapıda ise, belirli bir özellikle ilgili tüm kodlar (UI, durum yönetimi, veri erişimi) tek bir klasör altında toplanır. Bu, modülerliği artırır, özelliklerin bağımsız olarak geliştirilmesini ve test edilmesini kolaylaştırır.
Bu doğrultuda, Aura için Clean Architecture prensiplerinden esinlenen, özellik odaklı bir klasör yapısı benimsenmiştir.34 Her özellik kendi
presentation, domain ve data katmanlarına sahip olacaktır. Kullanıcının talep ettiği screens, widgets ve components ayrımı, bu yapının içine mantıksal olarak entegre edilmiştir:
●	widgets: Belirli bir özelliğe ait, sadece o özellik içinde kullanılan bileşenlerdir.
●	common_widgets: Uygulamanın tamamında kullanılan, özellikten bağımsız, tamamen yeniden kullanılabilir bileşenlerdir.

Önerilen Klasör Yapısı Şeması




lib/
└── src/
    ├── common_widgets/      # Global, yeniden kullanılabilir UI bileşenleri
    │   ├── primary_button.dart
    │   ├── custom_app_bar.dart
    │   ├── empty_state_widget.dart
    │   └── error_dialog.dart
    ├── constants/           # Uygulama genelindeki sabitler (API anahtarları, enum'lar vb.)
    ├── features/            # Tüm uygulama özelliklerinin ana dizini
    │   ├── auth/            # Kimlik doğrulama özelliği
    │   │   └──...
    │   ├── wardrobe/        # Gardırop özelliği
    │   │   ├── data/
    │   │   │   ├── repositories/
    │   │   │   └── models/
    │   │   ├── domain/
    │   │   │   ├── entities/
    │   │   │   └── repositories/
    │   │   └── presentation/
    │   │       ├── controllers/ # Riverpod Notifier'ları (wardrobe_controller.dart)
    │   │       ├── screens/     # Ana özellik ekranları (wardrobe_home_screen.dart)
    │   │       └── widgets/     # Bu özelliğe özgü bileşenler (clothing_item_card.dart)
    │   ├── style_assistant/ # Stil Asistanı özelliği
    │   │   └──...
    │   └──...              # Diğer tüm özellikler
    ├── routing/             # GoRouter yapılandırması
    │   └── app_router.dart
    ├── theme/               # ThemeData, renk şemaları, metin temaları
    │   └── app_theme.dart
    └── utils/               # Yardımcı fonksiyonlar, uzantılar (extensions)

Bu yapı, her özelliğin kendi içinde bir mini uygulama gibi geliştirilmesine olanak tanır, bu da ekip içindeki paralel çalışmayı kolaylaştırır ve kod tabanının zamanla "spagetti" haline gelmesini önler.

3.2. Ortak Bileşen Kütüphanesi: Aura'nın Yapı Taşları

Uygulama genelinde tutarlı bir görünüm ve davranış sağlamak için ortak, yeniden kullanılabilir bileşenlerden oluşan bir kütüphane oluşturmak esastır. Bu bileşenler, lib/src/common_widgets/ dizini altında yer alacak ve mümkün olduğunca stateless olacak şekilde tasarlanacaktır. Tüm verileri ve geri çağırma (callback) fonksiyonlarını parametre olarak alarak, tahmin edilebilir ve kolay test edilebilir olmaları sağlanacaktır.35

Temel Ortak Bileşenlerin Tanımları

●	PrimaryButton (primary_button.dart)
○	Amaç: Uygulama genelindeki ana eylem (call-to-action) butonu.
○	Parametreler:
■	final String text: Buton üzerinde gösterilecek metin.
■	final VoidCallback? onPressed: Butona tıklandığında çalışacak fonksiyon. null ise buton pasif olur.
■	final bool isLoading: true ise buton içinde bir yükleme göstergesi gösterir ve butonu pasif hale getirir. Varsayılanı false.
○	Yapı: Bir FilledButton bileşeni. İçeriği, isLoading durumuna göre bir Stack içinde CircularProgressIndicator veya Text gösterir. Stilini tamamen ThemeData.filledButtonTheme'den alacaktır.
●	CustomAppBar (custom_app_bar.dart)
○	Amaç: Uygulama genelinde tutarlı bir AppBar sağlamak.
○	Parametreler:
■	final String title: AppBar'da gösterilecek başlık.
■	final List<Widget>? actions: AppBar'ın sağ tarafında gösterilecek eylem butonları (opsiyonel).
○	Yapı: PreferredSizeWidget arayüzünü uygular. Temelinde, başlık ve eylem listesini parametre olarak alan bir AppBar bulunur. Stilini ThemeData.appBarTheme'den alacaktır.
●	EmptyStateWidget (empty_state_widget.dart)
○	Amaç: Veri olmadığında (boş gardırop, boş favoriler listesi vb.) kullanıcıya rehberlik eden bir ekran göstermek.
○	Parametreler:
■	final String illustrationPath: Gösterilecek Lottie animasyonunun veya SVG görselinin yolu.
■	final String message: Kullanıcıya gösterilecek açıklayıcı metin.
■	final String? ctaText: Eylem butonunun metni (opsiyonel).
■	final VoidCallback? onCtaPressed: Eylem butonuna tıklandığında çalışacak fonksiyon (opsiyonel).
○	Yapı: Dikey bir Column içinde bir Lottie animasyonu, bir Text ve opsiyonel bir PrimaryButton içerir. Bu bileşen, Bölüm V'te detaylandırılan sistem durumlarının zarif bir şekilde ele alınması için kritiktir.
●	ErrorDialog (error_dialog.dart)
○	Amaç: Kullanıcıya kritik olmayan hataları göstermek için standart bir diyalog penceresi.
○	Parametreler:
■	final String title: Diyalog başlığı.
■	final String content: Hata açıklaması.
○	Yapı: AlertDialog kullanan ve showDialog ile gösterilen statik bir metod (show). İçeriğinde bir başlık, içerik metni ve bir "Anladım" butonu bulunur.

Dokümantasyon Taslağı: COMPONENT_LIST.md


Aura Ortak Bileşen Kütüphanesi

Bu doküman, Aura uygulamasında kullanılan ve özelliklerden bağımsız olan tüm ortak bileşenleri listeler.
________________________________________
PrimaryButton

Uygulama genelindeki standart, birincil eylem butonudur. Yükleme durumunu destekler.
Parametreler:
Ad	Tip	Gerekli mi?	Açıklama
text	String	Evet	Buton üzerinde gösterilecek metin.
onPressed	VoidCallback?	Evet	Tıklama olayı. null ise buton pasif olur.
isLoading	bool	Hayır	true ise yükleme göstergesi gösterir.
**Kullanım Örneği:**dart
PrimaryButton(
text: 'Giriş Yap',
onPressed: _isFormValid? _submit : null,
isLoading: _authController.isLoading,
)



---

### CustomAppBar

Uygulama genelindeki standart `AppBar` bileşenidir.

**Parametreler:**

| Ad | Tip | Gerekli mi? | Açıklama |
| :--- | :--- | :--- | :--- |
| `title` | `String` | Evet | AppBar başlığı. |
| `actions` | `List<Widget>?` | Hayır | Sağ tarafta gösterilecek eylem ikonları. |

**Kullanım Örneği:**

```dart
Scaffold(
  appBar: CustomAppBar(
    title: 'Gardırobum',
    actions:,
  ),
  body:...
)

________________________________________
EmptyStateWidget

Boş ekran durumlarını göstermek için kullanılır. Bir illüstrasyon, mesaj ve opsiyonel bir eylem butonu içerir.
Parametreler:
Ad	Tip	Gerekli mi?	Açıklama
illustrationPath	String	Evet	Gösterilecek Lottie veya SVG dosyasının yolu.
message	String	Evet	Kullanıcıya gösterilecek açıklama.
ctaText	String?	Hayır	Eylem butonunun metni.
onCtaPressed	VoidCallback?	Hayır	Eylem butonunun tıklama olayı.
Kullanım Örneği:

Dart


EmptyStateWidget(
  illustrationPath: 'assets/animations/empty_wardrobe.json',
  message: 'Gardırobun henüz boş. İlk parçanı ekleyerek başla!',
  ctaText: 'Kıyafet Ekle',
  onCtaPressed: () => context.go('/add-clothing'),
)




## IV. "Asistan Hissi" Yaratmak: Mikro Etkileşimler ve Animasyonlar

Bu bölüm, Aura'yı statik bir araçtan dinamik, duyarlı bir asistana dönüştürmek için hareketin (motion) nasıl kullanılacağını detaylandırır. Amaç, uygulamanın temel marka vaadini pekiştiren anlamlı ve keyifli mikro etkileşimler tasarlamaktır.

### 4.1. Anahtar Animasyon Senaryoları

"Asistan hissi" [FAZ 1], sistemin arka planda yürüttüğü süreçleri kullanıcıya somutlaştırarak yaratılır. Jenerik bir yükleme göstergesi "bekle" derken, amaca yönelik bir animasyon "senin için çalışıyorum" der. Bu, sistemi daha zeki ve somut hissettirir. M3 Expressive'in akıcı ve doğal hareket sistemi bu felsefeyi destekler.[36] Bu doğrultuda, yapay zekanın eylemlerini görselleştiren beş kritik senaryo belirlenmiştir.

1.  **Senaryo: "Yapay Zekâ Düşünüyor..."**
    *   **Bağlam:** `StyleAssistantScreen`'de, kullanıcı mesaj gönderdikten sonra yapay zekâ yanıtı gelmeden önceki bekleme anı.
    *   **Animasyon:** Bir sohbet baloncuğu içinde gösterilen, nabız gibi atan nöronları veya akan soyut şekilleri betimleyen, döngüsel ve zarif bir Lottie animasyonu. Bu, sistemin aktif olarak bir yanıt ürettiğini görselleştirir.

2.  **Senaryo: "Stilin Analiz Ediliyor..."**
    *   **Bağlam:** İlk stil testi sırasında veya kullanıcının `WardrobeAnalyticsScreen` üzerinden tam bir gardırop analizi talep ettiği an.
    *   **Animasyon:** Çeşitli kıyafet ikonlarının taranması, sıralanması ve birbirine bağlanmasını gösteren daha karmaşık bir Lottie animasyonu. Bu, veri işleme ve içgörü çıkarma sürecini somutlaştırır.

3.  **Senaryo: "Önerin Hazır!"**
    *   **Bağlam:** `StyleAssistantScreen`'de yeni bir `OutfitCard`'ın sunulduğu an. Önerinin aniden belirmesi yerine, "takdim edilmesi" gerekir.
    *   **Animasyon:** `flutter_animate` paketi kullanılarak kartın ve içeriğinin, kademeli bir `fadeIn` (belirme) ve `slideUp` (aşağıdan kayarak gelme) efektiyle ekrana gelmesi. Bu, sunumun daha cilalı ve önemli hissettirmesini sağlar.

4.  **Senaryo: "Parçalar Birleşiyor"**
    *   **Bağlam:** `CreateCombinationScreen`'de, kullanıcının gardırobundan bir kıyafeti yeni bir kombine eklediği an.
    *   **Animasyon:** `Hero` animasyonu [37] kullanılarak, seçim ızgarasındaki `ClothingItemCard`'ın "uçarak" kombin önizleme alanındaki yerine yerleşmesi. Bu, bir kombin oluşturma eylemine tatmin edici ve somut bir his katar.

5.  **Senaryo: "Gardırobuna Kaydediliyor"**
    *   **Bağlam:** `AddClothingItemScreen`'de yapay zekâ etiketlemeyi bitirdikten ve kullanıcı "Kaydet" butonuna bastıktan sonraki onay anı.
    *   **Animasyon:** Başarılı bir "onay işareti" (checkmark) animasyonunun, markayla uyumlu bir şekilde bir "elbise askısı" ikonuna dönüştüğü bir Lottie animasyonu. Bu, eylemin tamamlandığını keyifli ve akılda kalıcı bir şekilde onaylar.

### 4.2. Animasyon Uygulama Stratejisi

Belirlenen senaryolar için en uygun animasyon teknolojilerinin seçilmesi ve uygulanması, hem geliştirme verimliliği hem de performans açısından önemlidir.

#### Araç Seçimi ve Kod Örnekleri

*   **Lottie:** After Effects'te tasarlanmış karmaşık, vektör tabanlı animasyonlar için idealdir. "Yapay Zekâ Düşünüyor", "Stilin Analiz Ediliyor" ve "Gardırobuna Kaydediliyor" gibi illüstratif hareket gerektiren senaryolar için en uygun çözümdür.[38] Animasyonlar LottieFiles platformundan temin edilebilir.[39]
*   **`flutter_animate`:** Herhangi bir widget'a doğrudan kod içinde zincirleme ve kademeli animasyonlar eklemek için güçlü ve esnek bir kütüphanedir. "Önerin Hazır!" senaryosundaki gibi UI elemanı geçişleri için mükemmeldir.[40]
*   **`Hero`:** Ekranlar veya widget'lar arasında paylaşılan eleman geçişleri oluşturmak için Flutter'ın yerleşik bir bileşenidir. "Parçalar Birleşiyor" senaryosu için, iki durum arasında kusursuz bir görsel bağlantı sağladığı için en doğru seçimdir.[37, 41]

#### Örnek Kod Parçacıkları ve Dosya Bağlantıları

*   **Lottie Animasyonları (Senaryo 1, 2, 5):**
    *   **"AI is Thinking":** [https://lottiefiles.com/animations/ai-brain-process-p8yvsc5s2o](https://lottiefiles.com/animations/ai-brain-process-p8yvsc5s2o)
    *   **"Analyzing Style":** [https://lottiefiles.com/animations/ai-data-analysis-for-website-and-app-s1a0a3b1ma](https://lottiefiles.com/animations/ai-data-analysis-for-website-and-app-s1a0a3b1ma)
    *   **"Saving Success":** [https://lottiefiles.com/animations/success-tick-06sCj4P4PV](https://lottiefiles.com/animations/success-tick-06sCj4P4PV)
    *   **Kullanım Kodu:**
        ```dart
        import 'package:lottie/lottie.dart';

        //...
        Lottie.asset(
          'assets/animations/ai_thinking.json',
          width: 150,
          height: 150,
        );
        ```

*   **"Önerin Hazır!" (Senaryo 3 - `flutter_animate`):**
    ```dart
    import 'package:flutter_animate/flutter_animate.dart';

    // OutfitCard'ı gösteren widget içinde
    OutfitCard(outfit: newOutfit)
     .animate()
     .fadeIn(duration: 400.ms, curve: Curves.easeOut)
     .slideY(begin: 0.2, end: 0, curve: Curves.easeOut);
    ```

*   **"Parçalar Birleşiyor" (Senaryo 4 - `Hero`):**
    ```dart
    // Seçim ızgarasında
    GestureDetector(
      onTap: () => onItemSelected(item),
      child: Hero(
        tag: 'clothing_item_${item.id}',
        child: ClothingItemCard(item: item),
      ),
    );

    // Kombin önizleme alanında
    Hero(
      tag: 'clothing_item_${item.id}',
      child: ClothingItemCard(item: item),
    );
    ```

#### Dokümantasyon Taslağı: ANIMATION_GUIDE.md

# Aura Animasyon Rehberi

Bu doküman, Aura uygulamasındaki mikro etkileşim ve animasyon stratejisini özetler. Amaç, "asistan hissi" yaratmak ve kullanıcı deneyimini zenginleştirmektir.

---

### 1. Senaryo: "Yapay Zekâ Düşünüyor..."

-   **Bağlam:** `StyleAssistantScreen`, AI yanıtı beklerken.
-   **Araç:** Lottie
-   **Dosya:** `assets/animations/ai_thinking.json` ([Link](https://lottiefiles.com/animations/ai-brain-process-p8yvsc5s2o))
-   **Kod:** `Lottie.asset('assets/animations/ai_thinking.json');`

---

### 2. Senaryo: "Stilin Analiz Ediliyor..."

-   **Bağlam:** Stil testi veya gardırop analizi sırasında.
-   **Araç:** Lottie
-   **Dosya:** `assets/animations/style_analysis.json` ([Link](https://lottiefiles.com/animations/ai-data-analysis-for-website-and-app-s1a0a3b1ma))
-   **Kod:** `Lottie.asset('assets/animations/style_analysis.json');`

---

### 3. Senaryo: "Önerin Hazır!"

-   **Bağlam:** Yeni bir öneri kartının ekrana gelmesi.
-   **Araç:** `flutter_animate`
-   **Kod:**dart
    OutfitCard(outfit: newOutfit)
     .animate()
     .fadeIn(duration: 400.ms)
     .slideY(begin: 0.2, end: 0);
    ```

---

### 4. Senaryo: "Parçalar Birleşiyor"

-   **Bağlam:** Kombin oluşturma ekranında kıyafet ekleme.
-   **Araç:** `Hero`
-   **Kod:**
    ```dart
    // Kaynak widget'ı Hero ile sarmalayın
    Hero(tag: 'item_${item.id}', child: ClothingItemCard(item: item));
    // Hedef widget'ı aynı tag ile Hero ile sarmalayın
    Hero(tag: 'item_${item.id}', child: ClothingItemCard(item: item));
    ```

---

### 5. Senaryo: "Gardırobuna Kaydediliyor"

-   **Bağlam:** Kıyafet ekleme başarılı olduğunda.
-   **Araç:** Lottie
-   **Dosya:** `assets/animations/success_hanger.json` ([Link](https://lottiefiles.com/animations/success-tick-06sCj4P4PV))
-   **Kod:** `Lottie.asset('assets/animations/success_hanger.json');`


V. Dayanıklılık için Tasarım: Sistemsel Durumlar ve Empatik Arayüz

Bu son bölüm, kullanıcı yolculuğunun ideal olmayan yollarını ele alır. Amaç, işler ters gittiğinde bile kullanıcının desteklendiğini, bilgilendirildiğini ve yönlendirildiğini hissetmesini sağlayarak Aura'nın temel kişiliğini pekiştirmektir.

5.1. Sistemsel Durumlar için Desen Kütüphanesi

Hata, boş ekran, çevrimdışı olma gibi durumlar kaçınılmazdır. Bu durumlar için tutarlı, markaya uygun ve yardımcı UI desenleri tasarlamak, kullanıcı hayal kırıklığını en aza indirir ve güven oluşturur. Uygulama genelinde bu durumları ele almak için yapılandırılmış ve yeniden kullanılabilir bir yaklaşım benimsenmelidir.

Temel UI Desenleri ve Widget Yapıları

Tüm sistem durumlarını yönetmek için, lib/src/common_widgets/ altında yer alacak, yapılandırılabilir tek bir SystemStateWidget oluşturulması önerilir. Bu bileşen, farklı durumlar için bir illüstrasyon, başlık, mesaj ve opsiyonel bir eylem butonu alarak tutarlılığı garanti eder.
●	Desen 1: Boş Durum (Empty State)
○	Bağlam: WardrobeHomeScreen veya MyCombinationsScreen gibi listelerin başlangıçta boş olduğu durumlar.5
○	Tasarım Felsefesi: Boş bir ekran, bir son değil, bir başlangıç olarak çerçevelenmelidir. Kullanıcıya ne yapması gerektiği konusunda ilham ve net bir yönlendirme sunulmalıdır.42
○	Widget Yapısı (EmptyStateWidget Kullanımı):
Dart
// WardrobeHomeScreen içinde
if (wardrobe.items.isEmpty) {
  return EmptyStateWidget(
    illustrationPath: 'assets/illustrations/empty_wardrobe.svg',
    message: 'Gardırobun bir tuval gibi boş. İlk parçanı ekleyerek sihrin başlamasını izle!',
    ctaText: 'İlk Kıyafetini Ekle',
    onCtaPressed: () {
      // AddClothingItemScreen'e yönlendir
    },
  );
}

○	Görsel İlham: Dribbble'daki boş durum tasarımları, genellikle markanın kişiliğini yansıtan sıcak ve dostane illüstrasyonlar kullanır.43
●	Desen 2: Hata Durumu (Error State)
○	Bağlam: API'den veri çekerken 500 sunucu hatası gibi beklenmedik bir sorun oluşması.
○	Tasarım Felsefesi: Kullanıcıyı teknik jargonla paniğe sevk etmek yerine, sorunu basit bir dille açıklamak ve bir çözüm yolu (genellikle yeniden deneme) sunmak esastır.44
○	Widget Yapısı (SystemStateWidget Kullanımı):
Dart
// WardrobeErrorView içinde
return SystemStateWidget(
  illustrationPath: 'assets/illustrations/error_cloud.svg',
  title: 'Eyvah! Bir aksilik oldu',
  message: 'Aura ile bağlantı kurarken bir sorun yaşadık. Lütfen bağlantını kontrol edip tekrar dene.',
  ctaText: 'Tekrar Dene',
  onCtaPressed: () {
    // Veri çekme işlemini yeniden tetikle
    ref.read(wardrobeControllerProvider.notifier).loadItems(isRefresh: true);
  },
);

●	Desen 3: Çevrimdışı Durum (Offline State)
○	Bağlam: Cihazın internet bağlantısının olmaması.
○	Tasarım Felsefesi: Uygulama, çevrimdışı durumu net bir şekilde bildirmeli ve hangi işlevlerin kullanılamadığını belirtmelidir. Kullanıcıya kontrol hissi vermek için bağlantı geri geldiğinde manuel olarak yenileme seçeneği sunulmalıdır.46
○	Widget Yapısı:
■	Global Bildirim (MaterialBanner): Ekranın üst kısmında kalıcı olmayan, kayan bir bildirim.
Dart
// Ana Scaffold'da internet bağlantısı dinlenerek gösterilir
MaterialBanner(
  content: Text("Şu anda çevrimdışısın. Değişikliklerin geri geldiğinde senkronize edilecek."),
  leading: Icon(Icons.wifi_off),
  actions:,
)

■	Tam Ekran Durumu: Veri yüklenmesi gereken bir ekranda bağlantı yoksa, Hata Durumu'na benzer bir tam ekran gösterilir, ancak mesaj ve illüstrasyon çevrimdışı duruma özel olur.
●	Desen 4: Bakım Modu
○	Bağlam: Sunucu tarafında planlı bir bakım yapıldığı durum.
○	Tasarım Felsefesi: Kullanıcıya durumun geçici olduğu ve uygulamanın daha iyi bir deneyim için güncellendiği bilgisi, pozitif bir dille verilmelidir.
○	Widget Yapısı (SystemStateWidget Kullanımı):
Dart
// Uygulama girişinde bir flag kontrolü ile gösterilir
return SystemStateWidget(
  illustrationPath: 'assets/illustrations/maintenance.svg',
  title: 'Aura'yı Güzelleştiriyoruz!',
  message: 'Deneyimini daha da iyi hale getirmek için kısa bir bakım yapıyoruz. Çok yakında tekrar birlikte olacağız. Anlayışın için teşekkürler!',
);


5.2. Aura'nın Sesi: Empatik UX Metinleri

Arayüz metinleri (UX Writing), uygulamanın kişiliğini yansıtan en önemli unsurlardan biridir. Özellikle stresli anlarda (hata, veri kaybı riski vb.), kullanılan dilin sakinleştirici, yol gösterici ve insancıl olması, kullanıcı güvenini doğrudan etkiler. Aura'nın "samimi UI dili" [FAZ 1], asla kullanıcıyı suçlamamalı, her zaman bir çözüm sunmalı ve teknik terminolojiden kaçınmalıdır.48

Durumlara Göre UX Metin Örnekleri

●	Hata Durumu (API 500):
○	Başlık: "Küçük Bir Pürüz Çıktı"
○	Gövde: "Şu anda Aura sunucularına ulaşmakta zorlanıyoruz. Hadi bir kez daha deneyelim."
○	Buton: "Bağlantıyı Yenile"
○	Rationale: "Hata" veya "Başarısız" gibi kelimeler yerine "pürüz" gibi daha yumuşak ifadeler kullanılır. "Biz" dili kullanılarak sorun sistemin üzerine alınır, kullanıcı dışarıda bırakılmaz.
●	Boş Durum (Favori Yok):
○	Başlık: "Favorilerini Keşfet"
○	Gövde: "Beğendiğin bir kombinin veya ürünün üzerindeki kalp ikonuna dokun, biz de onları senin için burada saklayalım."
○	Buton: "Stilleri Keşfet"
○	Rationale: Durumu bir eksiklik olarak değil, kullanıcıyı eyleme teşvik eden bir fırsat olarak sunar. Ne yapması gerektiğini net bir şekilde anlatır.
●	Çevrimdışı Durum:
○	Banner Metni: "Çevrimdışısın. Yaptığın son değişiklikler, bağlantı kurduğun an senkronize edilecek."
○	Rationale: Kullanıcının verilerinin kaybolmayacağına dair güvence verir, bu da en büyük endişelerden birini ortadan kaldırır.49
●	Giriş Hatası (Yanlış Şifre):
○	Başlık: "Tekrar Deneyelim"
○	Gövde: "Girdiğin e-posta veya şifre eşleşmedi. İstersen şifreni sıfırlamana yardımcı olabiliriz."
○	Butonlar: "Tekrar Dene", "Şifremi Unuttum"
○	Rationale: Suçlayıcı bir "Yanlış Şifre" ifadesi yerine, çözüm odaklı ve yardımcı bir dil kullanılır. Kullanıcıya doğrudan bir çıkış yolu sunulur.
Bu empatik ve rehberlik eden dil, Aura'nın sadece bir uygulama değil, aynı zamanda güvenilir bir stil asistanı olduğu algısını her etkileşimde güçlendirecektir.
Alıntılanan çalışmalar
1.	Warm Colors designs, themes, templates and downloadable graphic elements on Dribbble, erişim tarihi Temmuz 29, 2025, https://dribbble.com/tags/warm_colors?page=2
2.	Browse thousands of Warm Colors images for design inspiration - Dribbble, erişim tarihi Temmuz 29, 2025, https://dribbble.com/search/warm-colors
3.	Custom Material Design 3 colour schemes - Anvil Docs, erişim tarihi Temmuz 29, 2025, https://anvil.works/docs/how-to/creating-material-3-colour-scheme
4.	material-foundation/material-theme-builder: Visualize dynamic color and create a custom Material Theme. - GitHub, erişim tarihi Temmuz 29, 2025, https://github.com/material-foundation/material-theme-builder
5.	AURA PROJESİ - NİHAİ TASARIM VE STRATEJİ DÖKÜMANI (V3.0 - Tam Metin).docx
6.	Urbanist - Google Fonts, erişim tarihi Temmuz 29, 2025, https://fonts.google.com/specimen/Urbanist
7.	5 Google Fonts to Use Instead of Poppins | Jen Wagner Co, erişim tarihi Temmuz 29, 2025, https://jenwagner.co/5-google-fonts-to-use-instead-of-poppins/
8.	Best Free Google Fonts 2024 | Muzli Blog, erişim tarihi Temmuz 29, 2025, https://muz.li/blog/best-free-google-fonts/
9.	Best Fonts for Mobile Apps: 6 Exceptional Choices for UI Design | by Vertical Motion, erişim tarihi Temmuz 29, 2025, https://medium.com/@verticalmotion/best-fonts-for-mobile-apps-6-exceptional-choices-for-ui-design-63788fa52641
10.	Material Design 3 in Compose | Jetpack Compose - Android Developers, erişim tarihi Temmuz 29, 2025, https://developer.android.com/develop/ui/compose/designsystems/material3
11.	How Personalization Drives Retention and Monetization for Stitch Fix - Reforge, erişim tarihi Temmuz 29, 2025, https://www.reforge.com/blog/stitchfix-personalization-retention-monetization
12.	Product review: Stitch Fix - Medium, erişim tarihi Temmuz 29, 2025, http://medium.com/design-bootcamp/stitch-fix-product-review-75daf798d380
13.	20 Best User Onboarding Examples We've Ever Seen | Wyzowl, erişim tarihi Temmuz 29, 2025, https://wyzowl.com/user-onboarding/
14.	Stitch Fix Rolls Out StyleFile – Its Style Personality Resource – to All Clients, erişim tarihi Temmuz 29, 2025, https://newsroom.stitchfix.com/blog/stitch-fix-rolls-out-stylefile-its-style-personality-resource-to-all-clients/
15.	Whering | The Social Wardrobe & Styling App – Whering, erişim tarihi Temmuz 29, 2025, https://whering.co.uk/
16.	How Whering Works, erişim tarihi Temmuz 29, 2025, https://whering.co.uk/how-it-works
17.	Whering Onboarding flow - Uiland, erişim tarihi Temmuz 29, 2025, https://uiland.design/flows/Onboarding/Whering
18.	Whering iOS Login options - Mobbin, erişim tarihi Temmuz 29, 2025, https://mobbin.com/screens/34a6ed18-64f8-4476-944d-888499c45845
19.	Flutter - Stepper Widget - GeeksforGeeks, erişim tarihi Temmuz 29, 2025, https://www.geeksforgeeks.org/flutter/flutter-stepper-widget/
20.	How to use PageView widget in Flutter - Educative.io, erişim tarihi Temmuz 29, 2025, https://www.educative.io/answers/how-to-use-pageview-widget-in-flutter
21.	Flutter PageView Intro Screen UI - Smooth App Onboarding : r/FlutterCode - Reddit, erişim tarihi Temmuz 29, 2025, https://www.reddit.com/r/FlutterCode/comments/1m4k37k/flutter_pageview_intro_screen_ui_smooth_app/
22.	PageView - FlutterFlow Documentation, erişim tarihi Temmuz 29, 2025, https://docs.flutterflow.io/concepts/navigation/pageview
23.	Flutter Stepper Widget - YouTube, erişim tarihi Temmuz 29, 2025, https://www.youtube.com/watch?v=_4keCbhhJq0
24.	FilterChip class - material library - Dart API - Flutter, erişim tarihi Temmuz 29, 2025, https://api.flutter.dev/flutter/material/FilterChip-class.html
25.	Filter Chips In flutter. - Mobikul, erişim tarihi Temmuz 29, 2025, https://mobikul.com/filter_chips_in_flutter/
26.	flutter_card_swiper | Flutter package - Pub.dev, erişim tarihi Temmuz 29, 2025, https://pub.dev/packages/flutter_card_swiper
27.	flutter_card_swiper example | Flutter package - Pub.dev, erişim tarihi Temmuz 29, 2025, https://pub.dev/packages/flutter_card_swiper/example
28.	Flutter - Draggable Scrollable Sheet - GeeksforGeeks, erişim tarihi Temmuz 29, 2025, https://www.geeksforgeeks.org/flutter/flutter-draggable-scrollable-sheet/
29.	DraggableScrollableSheet widget and Attributes - Vinit Mepani (Flutter Developer), erişim tarihi Temmuz 29, 2025, https://vinitmepani.hashnode.dev/draggablescrollablesheet-widget-and-attributes
30.	stacked_list_carousel | Flutter package - Pub.dev, erişim tarihi Temmuz 29, 2025, https://pub.dev/packages/stacked_list_carousel
31.	flutter_flip_card | Flutter package - Pub.dev, erişim tarihi Temmuz 29, 2025, https://pub.dev/packages/flutter_flip_card
32.	Flutter Project Structure: Feature-first or Layer-first?, erişim tarihi Temmuz 29, 2025, https://codewithandrea.com/articles/flutter-project-structure/
33.	Effective Layered Architecture in Large Flutter Apps - DEV Community, erişim tarihi Temmuz 29, 2025, https://dev.to/alaminkarno/effective-layered-architecture-in-large-flutter-apps-2n48
34.	Implementations of a Clean Architecture in Flutter Projects | by Lennard Deurman | Medium, erişim tarihi Temmuz 29, 2025, https://medium.com/@lennarddeurman/implementations-of-a-clean-architecture-in-flutter-projects-14b265a2de2f
35.	A Complete Guide to Widget Composition in Flutter - Apexive, erişim tarihi Temmuz 29, 2025, https://apexive.com/post/guide-to-widget-composition-in-flutter
36.	Material 3 Expressive: What's New and Why it Matters for Designers - Supercharge Design, erişim tarihi Temmuz 29, 2025, https://supercharge.design/blog/material-3-expressive
37.	Hero animations - Flutter Documentation, erişim tarihi Temmuz 29, 2025, https://docs.flutter.dev/ui/animations/hero-animations
38.	Create Animations with Lottie AI Generators - Recraft, erişim tarihi Temmuz 29, 2025, https://www.recraft.ai/blog/lottie-ai-generator-animations
39.	LottieFiles: Download Free lightweight animations for website & apps., erişim tarihi Temmuz 29, 2025, https://lottiefiles.com/
40.	flutter_animate | Flutter package - Pub.dev, erişim tarihi Temmuz 29, 2025, https://pub.dev/packages/flutter_animate
41.	Flutter Hero Animation: Transform and Fly Widgets Between Screens - DhiWise, erişim tarihi Temmuz 29, 2025, https://www.dhiwise.com/post/flutter-hero-animation-fly-widgets-between-screens
42.	Empty State UI Pattern: Best practices & 4 examples to inspire you | Mobbin, erişim tarihi Temmuz 29, 2025, https://mobbin.com/glossary/empty-state
43.	Empty State designs, themes, templates and downloadable graphic elements on Dribbble, erişim tarihi Temmuz 29, 2025, https://dribbble.com/tags/empty-state
44.	Error Message UX, Handling & Feedback - Pencil & Paper, erişim tarihi Temmuz 29, 2025, https://www.pencilandpaper.io/articles/ux-pattern-analysis-error-feedback
45.	Common design mistakes made in creating error states and how to prevent user errors | by Helena Grinshpun | Bootcamp | Medium, erişim tarihi Temmuz 29, 2025, https://medium.com/design-bootcamp/common-design-mistakes-made-in-creating-error-states-and-how-to-prevent-user-errors-9a82cd20ce66
46.	How to design for slow networks and offline | by Nick Babich - UX Planet, erişim tarihi Temmuz 29, 2025, https://uxplanet.org/youre-not-connected-to-internet-50a46ee016a7
47.	Offline UX design guidelines | Articles - web.dev, erişim tarihi Temmuz 29, 2025, https://web.dev/articles/offline-ux-design-guidelines
48.	How to Write Error Messaging - Daily UX Writing, erişim tarihi Temmuz 29, 2025, https://dailyuxwriting.com/how-to/write-error-messaging
49.	Design Guidelines for Offline & Sync | Open Health Stack - Google for Developers, erişim tarihi Temmuz 29, 2025, https://developers.google.com/open-health-stack/design/offline-sync-guideline

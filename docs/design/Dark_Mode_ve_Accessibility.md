Karanlık Mod ve Erişilebilirlik
Sistem Temayla Uyumlu Karanlık Mod
Mimari Öneriler: Uygulamada sistem temasıyla uyumlu karanlık mod için
MaterialApp.themeMode = ThemeMode.system kullanılabilir. Bu sayede işletim sistemi
karanlık moda geçtiğinde Flutter otomatik olarak darkTheme teması uygular . Ayrıca
kullanıcı uygulama içi ayarlardan temayı manuel değiştirebilmeli; bu durumda Riverpod vb.
durum yönetimi ile tema tercihi (örneğin ThemeMode.light/dark ) saklanıp uygulanmalıdır.
Tema durumu Domain katmanında “Tema tercihi güncelle” gibi bir use-case ile işlenip, Ayarlar
(LocalStorage/SharedPreferences) katmanına kaydedilebilir. Monorepo veya çoklu paket
yapısında tema sağlayıcıları (theme providers) ortak paket olarak tanımlanabilir.
Araçlar ve Kütüphaneler: Flutter’ın yerleşik ThemeData , ThemeMode ,
MediaQuery.platformBrightness gibi özellikleri yeterlidir. Durum yönetimi için Riverpod v2
(StateNotifierProvider) ya da flutter_riverpod kullanılabilir. Tema tercihini kalıcı hale
getirmek için shared_preferences veya hydrated_bloc benzeri paketler tercih edilebilir.
Resimler için Image.asset ile renk filtresi uygulamak veya karanlık modda alternatif asset
kullanmak gerekebilir. Yüksek kontrast desteklemek için MaterialApp.highContrastTheme
özelliği kullanılabilir (örneğin iOS’un “Increase Contrast” modu) .
Örnek Kod: Aşağıda Riverpod kullanan bir tema değişim örneği verilmiştir. ThemeNotifier
uygulama açıldığında önce tercihleri yükler ve değiştirme fonksiyonuyla günceller.
final themeNotifier = StateNotifierProvider<ThemeNotifier,
ThemeMode>((ref) {
return ThemeNotifier();
});
class ThemeNotifier extends StateNotifier<ThemeMode> {
ThemeNotifier() : super(ThemeMode.system) {
loadTheme();
}
void loadTheme() async {
final prefs = await SharedPreferences.getInstance();
final saved = prefs.getString('themeMode') ?? 'system';
state = ThemeMode.values.firstWhere((m) => m.toString()==saved);
}
void toggleDark() async {
state = (state == ThemeMode.dark) ? ThemeMode.light :
ThemeMode.dark;
final prefs = await SharedPreferences.getInstance();
prefs.setString('themeMode', state.toString());
}
}
class MyApp extends ConsumerWidget {
@override
•
1
•
2
•
1
Widget build(BuildContext context, WidgetRef ref) {
final themeMode = ref.watch(themeNotifier);
return MaterialApp(
title: 'Örnek Uygulama',
theme: ThemeData.light(),
darkTheme: ThemeData.dark(),
themeMode: themeMode,
home: const MyHomePage(),
);
}
}
Potansiyel Sorunlar ve Çözümleri: Karışan temalar veya eksik karanlık renkler sık rastlanan
sorunlardır. Çözüm için tüm ThemeData renklerini (colorScheme) karanlık ve aydınlık temaya
tanımlayın. Sabit yazı veya arka plan renkleri kullanmak yerine
Theme.of(context).colorScheme tercih edin. Örneğin görsel/ikonların karanlık arka planda
görünürlüğü için Image.asset(..., color:
Theme.of(context).brightness==Brightness.dark?Colors.white:Colors.black)
gibi dinamik ayarlamalar yapılabilir . Sistem teması manuel olarak
değiştirildiğinde uygulama yeniden başlatma olmadan anında güncellenir;
bazı özel paketlerde WidgetsBindingObserver` ile platform değişikliği dinlenebilir.
Performans, Bakım ve Test Önerileri: Tema değişimi tüm widget ağacının yeniden çizilmesine
neden olur; bu nedenle mümkün olduğunca const widget kullanarak fazla tekrar
oluşturmaktan kaçının. Tema değişimi nadiren gerçekleştiğinden performans üzerine etkisi
genellikle düşüktür. Test için karanlık ve aydınlık temada temel ekran görüntüsü (golden) testleri
oluşturulabilir ve metinlerin okunabilirliği, kontrastı kontrol edilebilir . Ayrıca platform font
büyüklüğü (textScaleFactor) ayarı ve yüksek kontrast modu (MediaQuery.highContrast) altında
test edilmesi önerilir.
Akış (Metinsel Şema): Bir örnek akış şu şekildedir: Kullanıcı mobil ayarlardan temayı koyu moda
alır → İşletim sistemi güncel parlaklık bilgisini günceller → Flutter’ın MaterialApp ’ı
themeMode = ThemeMode.system olduğu için bu değişimi algılar → Uygulama tüm arayüzü
darkTheme ile yeniden çizer. Alternatif olarak: Kullanıcı uygulama Ayarlar ekranında “Karanlık
Mod” anahtarına basar → UI katmanı, ThemeNotifier üzerinden toggleDark() çağrısı yapar →
Domain katmanında tercih kaydedilip uygulama durumu güncellenir → MaterialApp rebuild edilir.
Kullanım Senaryoları:
Senaryo 1: Kullanıcı gün içinde parlak ortamdan karanlık bir ortama geçtiğinde, cihaz otomatik
koyu moda geçtiğinde uygulama da otomatik koyu temaya döner.
Senaryo 2: Kullanıcı uygulama ayarlarından gece modunu manuel açar; tercihi kaydedilir ve
uygulama anında koyu renklere geçer.
Senaryo 3: Karanlık mod açıkken bile logo gibi resimlerin görünürlüğü düşük kalabilir; bu
durumda uygulama resim renklerini tema parlaklığına göre filtreler veya alternatifi kullanır.
Performans ve Kapasite Tahminleri: Tema değiştirme işlemi, animasyonlu arayüzler haricinde
tek seferlik bir yeniden çizim işlemidir. Örneğin 1000 civarında widget içeren bir ekranda tema
değişimi saniyenin altında tamamlanabilir (cihaz ve widget karmaşıklığına bağlı olarak, genellikle
birkaç on milisaniye). Ağır işlem veya veri transferi gerektirmez. Depolama katmanı olarak
tercihin kaydedilmesi (SharedPreferences) küçük miktarda I/O işlemidir. Birden fazla kullanıcı
aynı anda tema değiştiriyor demek sunucu açısından anlamsızdır; tüm işlemler istemci
tarafındadır. Tema değişimi performans darboğazı olarak çok nadirdir ve modern cihazlarda
genellikle akıcıdır.
•
3
•
4
•
•
•
•
•
•
2
Kontrast ve Yazı Boyutu Ayarları
Mimari Öneriler: Tasarım aşamasında kullanıcı arayüzü renk kontrastlarının yeterli olduğundan
emin olun. W3C’ye göre küçük metinlerde en az 4.5:1, büyük metinlerde 3:1 kontrast oranı
olmalıdır . Uygulama tema renklerini (özellikle arka plan ve ön plan renklerini) bu standartlara
uygun belirleyin. Yazı boyutu için işletim sistemi ölçeklendirmesini destekleyin; Flutter’da Text
widget’ları otomatik olarak MediaQuery.textScaleFactor değerine göre ölçeklenir .
Responsive düzen kullanarak (örn. Flexible , Expanded ) büyük fontlarda taşmayı engelleyin.
Araçlar ve Kütüphaneler: Flutter’ın yerleşik MediaQuery (textScaleFactor, highContrast) ve
tema sistemi kullanılabilir. Kontrast kontrolü için WCAG hesaplayıcı (örn. online araçlar) veya
flutter_test içindeki erişilebilirlik kılavuz API’ları (meetsGuideline) kullanılabilir. Yazı tiplerini
Google Fonts ile temaya entegre ederken, değişen boyutlar ve kontrastlı renkler belirlenebilir.
Bazı gelişmiş paketler ( flex_color_scheme ) kontrast destekli tema oluşturmayı kolaylaştırır,
ancak temelde Flutter’ın standardı yeterlidir.
Örnek Kod: Aşağıdaki örnek, ekrandaki bir metin widget’ının cihazın metin ölçeğine göre
otomatik boyutlanmasını göstermektedir:
@override
Widget build(BuildContext context) {
final scaleFactor = MediaQuery.of(context).textScaleFactor;
return Text(
'Örnek Metin',
style: Theme.of(context).textTheme.bodyMedium,
// Aşağıdaki satır genellikle gerekli değil; Text widget'ları
otomatik ölçeklenir.
textScaleFactor: scaleFactor,
);
}
Kontrast için tema tanımına dikkat edin; örneğin ThemeData içinde colorScheme:
ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light)
kullandığınızda Flutter, otomatik yüksek kontrastlı renk kombinasyonları üretir.
Potansiyel Sorunlar ve Çözümleri: Düşük kontrast veya yeterince büyük olmayan metinler en
yaygın sorunlardır. Aşağıdaki çözümler önerilir: Temadaki onBackground , onSurface gibi
ColorScheme renklerini WCAG oranına göre ayarlayın. Kritik metinler için koyu zemin üzerine
açık renk (veya tersi) kullanın. Yazı boyutları için responsive düzenlerde yer açın, gerektiğinde
kaydırma (scroll) veya sarmalayıcı ( Wrap ) kullanın. Kullanıcının metni büyütmesi durumunda
arayüz taşmalarını engellemek için öğeleri esnek yapıda tasarlayın. Fonksiyonel olarak gereken
minimum font büyüklüğü veya kontrast oranları için testler ekleyin.
Performans, Bakım ve Test Önerileri: Dinamik font ve renkler, uygulamanın normal akışında
performansı çok etkilemez. Ancak aşırı büyük fontlar düzeni bozabilir; bu durumda otomatik
testlerle (widget testleri) farklı textScaleFactor değerlerinde görünümler kontrol edilebilir.
Flutter test paketindeki erişilebilirlik kılavuz API’si ile kontrast ve hedef boyutu kontrolleri
eklenebilir . Örneğin await expectLater(tester,
meetsGuideline(textContrastGuideline)); ile kontrast testi yapılabilir. Uygulamanın her
iki renk modunda (açık/karanlık) ve farklı dil ölçeklendirme değerlerinde düzgün
görüntülendiğinden emin olun.
Akış (Metinsel Şema): Kullanıcı işletim sistemi erişilebilirlik ayarlarından yazı boyutunu büyütür →
Flutter MediaQuery.textScaleFactor güncellenir → Tüm Text widget’ları yeni skala ile
yeniden render edilir. Benzer şekilde kontrast modu varsa: Kullanıcı yüksek kontrast moda geçer →
•
5
6
•
•
•
•
7
•
3
MediaQueryData.highContrast true olur ve MaterialApp.highContrastTheme geçerli
temayı override eder.
Kullanım Senaryoları:
Senaryo 1: Kullanıcı parlak güneş altında ekranı okuması zorlaşır; uygulama tasarımında koyu
renkli metni açık arka plan üzerine alarak kontrastı artırır.
Senaryo 2: Görme problemi olan bir kullanıcı telefon ayarlarından metin boyutunu maksimuma
getirir; uygulamada butonlar ve metinler genişletilerek taşmayan bir arayüz sunulur.
Senaryo 3: Kullanıcı cihazda “yüksek kontrast” ayarını etkinleştirir (örn. iOS’da Increase Contrast);
uygulama MaterialApp.highContrastTheme kullanarak daha belirgin renkler yükler .
Performans ve Kapasite Tahminleri: Kontrast ve font büyütme ayarları tamamen istemci
cihazda gerçekleşir. Metin boyutu büyütme durumunda ekran yeniden düzenlendiği için, çok
karmaşık widget hiyerarşilerinde birkaç ek milisaniye gecikme olabilir. Ancak modern cihazlarda
örneğin birkaç yüz widget barındıran bir ekran, ölçek faktörü arttığında da genellikle 60 FPS
civarında akıcı kalır. Yüksek kontrast modu genellikle statik tema değişikliğidir; etkisi kararlı
olarak yükleme anında az miktarda CPU/ GPU harcar. Ölçek faktörleri için bellek veya ağ ek yükü
yoktur.
Erişilebilirlik (a11y) Destekleri
Mimari Öneriler: Erişilebilirlik özelliklerini uygulamanın başından itibaren planlayın. UI
katmanında her etkileşimli bileşenin anlamlı etiketleri ve rollerine sahip olduğundan emin olun.
Örneğin IconButton gibi widget’lar otomatik etiketler sağlar ancak özel bileşenler için
Semantics widget’ı ile label , button gibi özellikler tanımlanmalıdır. Her ekran için geçiş
odak düzenini ( FocusScope ) doğru ayarlayıp erişilebilir büyük dokunma alanları (en az
48x48dp) kullandığınızdan emin olun . Domain katmanında “erişilebilirlik kontrolü” gibi bir
test use-case’i tasarlayarak temel sayfaların erişilebilirlik gereksinimlerini düzenli test edin.
Araçlar ve Kütüphaneler: Flutter’ın kendi erişilebilirlik araçları (Flutter Inspector’ın a11y
inceleme modu) ve platform özel araçlar kullanılmalıdır. Android için Accessibility Scanner, iOS
için Xcode Accessibility Inspector gibi araçlarla denetleme yapılabilir. Kod seviyesinde
package:flutter/semantics.dart içindeki Semantics ve SemanticsService sınıfları
kullanılabilir. Ayrıca Erişilebilirlik Yol Göstergeci API ( meetsGuideline ) ile minimum boyut ve
kontrast testleri ekleyebilirsiniz . Tap target kontrolleri (androidTapTargetGuideline,
iOSTapTargetGuideline) ve etiketleme kontrolleri (labeledTapTargetGuideline) testi,
uygulamanızın erişilebilirlik standartlarını korur.
Örnek Kod: Aşağıda özel bir buton için Semantics kullanımı gösterilmiştir. Böylece ekrandaki
bir simge veya bileşen, ekran okuyucu tarafından doğru şekilde seslendirilebilir.
Semantics(
label: 'Profil sayfası butonu',
hint: 'Kullanıcının profil sayfasını açar',
button: true,
child: IconButton(
icon: const Icon(Icons.person),
onPressed: () { /* ... */ },
),
);
Standart ElevatedButton , IconButton gibi bileşenler varsayılan olarak semantik button
rolü ve etiket desteği sunar; kişiye özel widget’lar için Semantics wrapper kullanın. Ayrıca
•
•
•
•
2
•
•
7
•
7
•
4
formlar için TextFormField ’larda labelText veya Semantics(label: ...) kullanarak
giriş alanlarına açıklayıcı etiketler ekleyin.
Potansiyel Sorunlar ve Çözümleri: Sıklıkla yapılan hatalar arasında düğmelerin veya ikonların
hiçbir erişilebilir etiket içer(ilm)emesi, küçük dokunma hedefleri ve yanlış odak sırası bulunur.
Bunu önlemek için tüm etkileşimli widget’lara Semantics(label: ...) ekleyin veya
Button benzeri hazır widget’ları tercih edin. Örneğin sadece ikon kullanan bir buton için
Tooltip veya Semantics(label: ...) eklemek gerekir. Dokunma hedefi boyutlarını
büyütmek (kutucukları boş bırakmak) ve kenar boştan kaçınmak kullanım kolaylığını artırır.
Resimlere alternatif metin (başlık) sağlamak için Image widget’larında SemanticLabel
parametresi kullanılabilir.
Performans, Bakım ve Test Önerileri: Erişilebilirlik desteği genelde arayüz düzenine hafif bir ek
yük getirir (ek semantik node’lar). Performansı genelde etkilemez; ancak çok derin widget
yapılarında semantik ağaç oluşturma süresi milisaniyeler alabilir. Erişilebilirlik testleri düzenli
entegre edilmelidir: Flutter testlerinde meetsGuideline kullanarak hedef boyut, etiket ve kontrast
kontrolleri ekleyin . Kod incelemesinde erişilebilirlik maddeleri kontrol listesini uygulayın
(buton etiketleri, alternatif metinler vb.). CI aşamasında otomatik tarayıcılar ile düşük kontrast
veya ölçek sorunları uyarıları ekleyebilirsiniz.
Akış (Metinsel Şema): Kullanıcı ekran okuyucu modunu açar → Flutter otomatik olarak ekran
ağacını Semantics ağacı olarak oluşturur → Screen reader bu semantik bilgileri kullanarak
metinleri seslendirir. Örneğin bir liste ekranında, her öğe için ListTile widget’ı başlık ( title )
ve açıklama ( subtitle ) sağlar; erişilebilirlik ağacı bu bilgileri seslendirir. Özel bir bileşen için: UI
katmanı Semantics widget’ı ile rol ve etiket atar → Flutter erişilebilirlik ağacı oluşturulur → Screen
reader bu veriyi kullanıcıya aktarır.
Kullanım Senaryoları:
Senaryo 1: Gözünü tam olarak kullanamayan bir kullanıcı, uygulamadaki “Kaydet” butonuna
odaklanır; ekran okuyucu “Kaydet butonu” şeklinde uyarı verir.
Senaryo 2: Büyük ekranlı TV veya tablet gibi bir cihazda kullanıcı sekmeler arasında klavye ile
dolaşıyor; uygulamadaki sekme sırası ve odak vurgusu ( FocusScope ) düzgün düzenlenmiştir,
böylece neyin seçili olduğu ekranda görünür hale gelir.
Senaryo 3: Renk körlüğü olan bir kullanıcı uygulamayı açar; önceden belirlenen kontrastlı renk
teması sayesinde metin ve simgeler birbirinden kolayca ayırt edilir.
Performans ve Kapasite Tahminleri: Erişilebilirlik öğeleri (semantik düğümler, etiketler) hafif
veri yapılarıdır; normal bir ekran için birkaç yüz semantik nodo bellek kullanımı (KB seviyesinde)
ile sınırlıdır. Semantik ağaç oluşturmak ve screen reader ile iletişim kurmak, CPU tarafında
genelde yerleşik platform API’lerine dayanır, bu nedenle uygulama performansı üzerinde belirgin
bir yük oluşturmaz. Çok geniş ölçekli kullanıcı erişilebilirliği senaryolarında (binlerce aynı anda)
yine her istemci kendi cihazında işler, sunucuya ekstra yük getirmez. Flutter’ın erişilebilirlik test
araçlarını kullanarak, performans darboğazı olabilecek durumlarda önceden uyarı alabilirsiniz
.
Ekran Okuyucu Optimizasyonları
Mimari Öneriler: Her ekranda sesli geri bildirim sağlayacak şekilde tasarım yapın. Örneğin form
alanları, görsel bileşenler veya karmaşık widget’lar için kullanıcıya bilgi verecek Semantics
özellikleri ekleyin. Yerleşik widget’lar çoğunlukla doğru semantik etiket sağlar; ancak özel düzen
veya animasyonlu bileşenlerde odak hareketi ve açıklamaların doğruluğunu kontrol edin.
Uygulamanın tamamında MaterialApp.localizationsDelegates ve supportedLocales
tanımlayarak dil desteği sunmuş olun; ekran okuyucular genellikle uygulamanın sistem diline
göre uygun sesi seçer. Kod tarafında gerekirse SemanticsService.announce() ile belirli
durumlarda bildirimleri manuel olarak yaptırabilirsiniz.
•
•
7
•
•
•
•
•
•
7 8
•
5
Araçlar ve Kütüphaneler: Flutter’ın Semantics widget’ı, SemanticsConfiguration ,
SemanticsService gibi araçları kullanın. Özellikle karmaşık grafiksel arayüzlerde özel
seslendirme metinleri eklemek için Semantics(label: ..., value: ..., hint: ...)
kullanabilirsiniz. Platform bağımsız test için flutter_test paketindeki erişilebilirlik
yordamları, ayrıca TalkBack/VoiceOver gibi gerçek cihaz araçları kullanılmalıdır. Ayrıca web
platformda, uygulamayı --dart-define=FLUTTER_WEB_DEBUG_SHOW_SEMANTICS=true ile
çalıştırarak semantik ağaç üzerinde görsel doğrulamaya imkan verebilirsiniz.
Örnek Kod: Çok karmaşık bir liste öğesi örneği: Aşağıdaki kod, özel bir kart bileşeninin semantik
rolünü belirtir. Böylece ekran okuyucu kartı “buton” olarak tanır ve başlık/alt başlığı ayrı ayrı okur.
Semantics(
container: true,
label: 'Ürün Bilgi Kartı',
onTapHint: 'Detayları görüntülemek için dokunun',
child: Card(
child: ListTile(
title: Text('Ürün Adı: Örnek Ürün'),
subtitle: Text('Fiyat: 100₺'),
trailing: const Icon(Icons.chevron_right),
onTap: () { /* Detay sayfasına gider */ },
),
),
);
Burada onTapHint ile Semantics içine eklenen Card bileşeni, dokunulduğunda ne
yapılacağını belirtir. container: true ile bu semantik grubun bir konteyner (paket) olduğu
vurgulanır. Sonuçta ekran okuyucu bu öğeyi “Ürün Bilgi Kartı, [içindekiler]” şeklinde duyurur.
Potansiyel Sorunlar ve Çözümleri: Ekran okuyucu optimizasyonlarında, en büyük hatalardan
biri içeriğin doğru sırada okunmamasıdır. Yığılmış widget’lar veya görünmez kaplamalar okuma
sırasını bozabilir; ExcludeSemantics veya MergeSemantics widget’larıyla düzenlemeler
yapabilirsiniz. Çok fazla bilgi veren karmaşık ekranlar kafa karıştırabilir; gerekli olmayan
decorative öğeleri excludeSemantics: true ile ekran okuyucu listesinden çıkarın. Dinamik
içerik güncellemeleri (örn. yeni bildirimler) için SemanticsService.announce() kullanarak
kullanıcıyı uyarın. Ayrıca, erişilebilirlik ayarları (ör. yüksek kontrast, metin büyültme) altında test
ederek kullanıcı deneyimini kontrol edin.
Performans, Bakım ve Test Önerileri: Semantik açıklamalar eklemek genelde küçük bir ek yük
getirir. Karmaşık uygulamalarda semantik ağaç bakımını kolaylaştırmak için benzer widget’larda
ortak semantik düzeni kullanan yardımcı fonksiyonlar oluşturabilirsiniz. Test otomasyonu için
emülatör veya gerçek cihazda TalkBack/VoiceOver senaryoları çalıştırın. Flutter test
framework’ünde SemanticsHandle ile uygulamayı açarak tester.ensureSemantics() ile
semantik ağacın varlığını doğrulayabilirsiniz. Ayrıca son kullanıcı testi için mutlaka gerçek
cihazda ekran okuyucularla doğrulama yapın.
Akış (Metinsel Şema): Kullanıcı ekran okuyucuyu aktif eder (örn. Android’de TalkBack) → Flutter
uygulaması semantik bilgileri oluşturur → Kullanıcı ekrana dokunur veya kaydırır → Sistem ekran
okuyucu semantik ağacından bilgi alır ve sesi oynatır. Örneğin bir kayıt formunda: Kullanıcı “İsim”
alanına odaklandığında semantik etiket “İsim” olarak duyulur, kullanıcı metin girer, ardından “Soyad”
alanına geçildiğinde “Soyad” duyurulur.
Kullanım Senaryoları:
•
•
•
•
•
•
6
Senaryo 1: Görme engelli bir kullanıcı bir galeri uygulamasında resimlere dokunur; her resim için
Semantics(label: ...) ile eklenmiş alternatif metin okunur (örneğin “Deniz manzaralı
fotoğraf”).
Senaryo 2: Çevrim içi mesajlaşma ekranında yeni mesaj geldiğinde,
SemanticsService.announce('Yeni mesaj: Merhaba!', TextDirection.ltr) ile bir
sesli bildirim gönderilir.
Senaryo 3: Karmaşık bir grafik gösteriminde (ör. istatistik grafiği), grafik öğelerini betimleyen gizli
metinler veya tablo açıklamaları eklenerek ekran okuyucunun içeriği yorumlaması sağlanır.
Performans ve Kapasite Tahminleri: Semantik optimizasyonlar çoğunlukla uygulama başına
sabit maliyetlidir. Tipik bir ekranda onlarca semantik düğüm bulunur; bu, bellek ve CPU kullanımı
açısından ihmal edilebilir seviyededir (örneğin bir ekran için 10–50ms’lik bir semantik ağaç
oluşturma süresi). Çok sayıda kullanıcı tarafından eşzamanlı erişim (ör. sunucu tarafı yükü) konu
dışıdır çünkü semantik işlemler tamamen istemcidedir. Otomasyon testleri ve duyarlılık
kontrolleri ile, sesli geri bildirim performansındaki olası düşüşler önceden tespit edilebilir
.
Kaynakça: Flutter resmi erişilebilirlik ve tema belgeleri ile uzman kaynaklar kullanılmıştır
.
Implementing Dark Mode in Flutter: A Complete Guide | by Flutter Nik | Medium
https://medium.com/@ravipatel84184/implementing-dark-mode-in-flutter-a-complete-guide-e6924d2d9932
highContrastTheme property - MaterialApp class - material library - Dart API
https://api.flutter.dev/flutter/material/MaterialApp/highContrastTheme.html
Accessibility | Flutter
https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility
•
•
•
•
8
7
1 2 6
5 8 7
1 3 4
2
5 6 7 8
7
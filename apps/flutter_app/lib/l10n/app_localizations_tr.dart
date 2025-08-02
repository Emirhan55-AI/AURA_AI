import 'app_localizations.dart';

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  // Common strings
  @override
  String get appName => 'Aura';
  @override
  String get close => 'Kapat';
  @override
  String get cancel => 'İptal';
  @override
  String get confirm => 'Onayla';
  @override
  String get save => 'Kaydet';
  @override
  String get delete => 'Sil';
  @override
  String get edit => 'Düzenle';
  @override
  String get add => 'Ekle';
  @override
  String get search => 'Ara';
  @override
  String get filter => 'Filtrele';
  @override
  String get sort => 'Sırala';
  @override
  String get loading => 'Yükleniyor...';
  @override
  String get error => 'Hata';
  @override
  String get retry => 'Tekrar Dene';
  @override
  String get success => 'Başarılı';
  @override
  String get warning => 'Uyarı';
  @override
  String get info => 'Bilgi';
  @override
  String get yes => 'Evet';
  @override
  String get no => 'Hayır';
  @override
  String get ok => 'Tamam';
  @override
  String get back => 'Geri';
  @override
  String get next => 'İleri';
  @override
  String get previous => 'Önceki';
  @override
  String get done => 'Bitti';
  @override
  String get skip => 'Atla';
  @override
  String get selectAll => 'Tümünü Seç';
  @override
  String get deselectAll => 'Seçimi Kaldır';
  @override
  String get noDataFound => 'Veri bulunamadı';
  @override
  String get noResultsFound => 'Sonuç bulunamadı';
  @override
  String get tryAgain => 'Tekrar dene';
  @override
  String get refresh => 'Yenile';

  // Authentication
  @override
  String get welcome => 'Hoş Geldiniz';
  @override
  String get login => 'Giriş Yap';
  @override
  String get logout => 'Çıkış Yap';
  @override
  String get register => 'Kayıt Ol';
  @override
  String get email => 'E-posta';
  @override
  String get password => 'Şifre';
  @override
  String get confirmPassword => 'Şifreyi Onayla';
  @override
  String get forgotPassword => 'Şifremi Unuttum';
  @override
  String get resetPassword => 'Şifreyi Sıfırla';
  @override
  String get createAccount => 'Hesap Oluştur';
  @override
  String get alreadyHaveAccount => 'Zaten hesabınız var mı?';
  @override
  String get dontHaveAccount => 'Hesabınız yok mu?';
  @override
  String get invalidEmail => 'Lütfen geçerli bir e-posta girin';
  @override
  String get invalidPassword => 'Şifre en az 6 karakter olmalıdır';
  @override
  String get passwordsDoNotMatch => 'Şifreler eşleşmiyor';
  @override
  String get loginFailed => 'Giriş başarısız. Lütfen tekrar deneyin.';
  @override
  String get registrationFailed => 'Kayıt başarısız. Lütfen tekrar deneyin.';
  @override
  String get resetPasswordSent => 'Şifre sıfırlama e-postası gönderildi';

  // Onboarding
  @override
  String get onboardingTitle1 => 'Gardırobunuzu Organize Edin';
  @override
  String get onboardingDescription1 => 'Tüm kıyafetlerinizi tek bir yerde takip edin';
  @override
  String get onboardingTitle2 => 'Harika Kombinler Oluşturun';
  @override
  String get onboardingDescription2 => 'Kıyafetlerinizi karıştırıp mükemmel kombinler oluşturun';
  @override
  String get onboardingTitle3 => 'Akıllı Öneriler';
  @override
  String get onboardingDescription3 => 'Hava durumu ve etkinliklere göre kişiselleştirilmiş kombin önerileri alın';
  @override
  String get getStarted => 'Başlayın';

  // Wardrobe
  @override
  String get wardrobe => 'Gardırop';
  @override
  String get myWardrobe => 'Gardırobum';
  @override
  String get addClothingItem => 'Kıyafet Ekle';
  @override
  String get clothingItem => 'Kıyafet';
  @override
  String get clothingItems => 'Kıyafetler';
  @override
  String get category => 'Kategori';
  @override
  String get categories => 'Kategoriler';
  @override
  String get color => 'Renk';
  @override
  String get colors => 'Renkler';
  @override
  String get brand => 'Marka';
  @override
  String get size => 'Beden';
  @override
  String get condition => 'Durum';
  @override
  String get purchaseDate => 'Satın Alma Tarihi';
  @override
  String get purchasePrice => 'Satın Alma Fiyatı';
  @override
  String get notes => 'Notlar';
  @override
  String get favorite => 'Favori';
  @override
  String get favorites => 'Favoriler';
  @override
  String get addToFavorites => 'Favorilere Ekle';
  @override
  String get removeFromFavorites => 'Favorilerden Çıkar';
  @override
  String get selectPhoto => 'Fotoğraf Seç';
  @override
  String get takePhoto => 'Fotoğraf Çek';
  @override
  String get chooseFromGallery => 'Galeriden Seç';
  @override
  String get itemAddedSuccessfully => 'Kıyafet başarıyla eklendi';
  @override
  String get itemUpdatedSuccessfully => 'Kıyafet başarıyla güncellendi';
  @override
  String get itemDeletedSuccessfully => 'Kıyafet başarıyla silindi';
  @override
  String get deleteItemConfirmation => 'Bu kıyafeti silmek istediğinizden emin misiniz?';
  @override
  String get deleteItem => 'Kıyafeti Sil';

  // Categories
  @override
  String get tops => 'Üst Giyim';
  @override
  String get bottoms => 'Alt Giyim';
  @override
  String get dresses => 'Elbiseler';
  @override
  String get outerwear => 'Dış Giyim';
  @override
  String get shoes => 'Ayakkabılar';
  @override
  String get accessories => 'Aksesuarlar';
  @override
  String get underwear => 'İç Giyim';
  @override
  String get sleepwear => 'Pijamalar';
  @override
  String get activewear => 'Spor Giyim';
  @override
  String get formal => 'Resmi';
  @override
  String get casual => 'Günlük';
  @override
  String get work => 'İş';

  // Colors
  @override
  String get black => 'Siyah';
  @override
  String get white => 'Beyaz';
  @override
  String get gray => 'Gri';
  @override
  String get brown => 'Kahverengi';
  @override
  String get beige => 'Bej';
  @override
  String get red => 'Kırmızı';
  @override
  String get pink => 'Pembe';
  @override
  String get orange => 'Turuncu';
  @override
  String get yellow => 'Sarı';
  @override
  String get green => 'Yeşil';
  @override
  String get blue => 'Mavi';
  @override
  String get purple => 'Mor';
  @override
  String get navy => 'Lacivert';
  @override
  String get multicolor => 'Çok Renkli';

  // Conditions
  @override
  String get excellent => 'Mükemmel';
  @override
  String get good => 'İyi';
  @override
  String get fair => 'Orta';
  @override
  String get poor => 'Kötü';

  // Outfits
  @override
  String get outfits => 'Kombinler';
  @override
  String get myOutfits => 'Kombinlerim';
  @override
  String get createOutfit => 'Kombin Oluştur';
  @override
  String get outfitName => 'Kombin Adı';
  @override
  String get outfitCreated => 'Kombin başarıyla oluşturuldu';
  @override
  String get outfitUpdated => 'Kombin başarıyla güncellendi';
  @override
  String get outfitDeleted => 'Kombin başarıyla silindi';
  @override
  String get deleteOutfitConfirmation => 'Bu kombini silmek istediğinizden emin misiniz?';
  @override
  String get selectItems => 'Kıyafet Seç';
  @override
  String get noItemsSelected => 'Hiç kıyafet seçilmedi';
  @override
  String get outfit => 'Kombin';

  // Settings
  @override
  String get settings => 'Ayarlar';
  @override
  String get profile => 'Profil';
  @override
  String get preferences => 'Tercihler';
  @override
  String get language => 'Dil';
  @override
  String get theme => 'Tema';
  @override
  String get darkMode => 'Karanlık Mod';
  @override
  String get lightMode => 'Açık Mod';
  @override
  String get systemMode => 'Sistem Modu';
  @override
  String get notifications => 'Bildirimler';
  @override
  String get privacy => 'Gizlilik';
  @override
  String get about => 'Hakkında';
  @override
  String get version => 'Sürüm';
  @override
  String get support => 'Destek';
  @override
  String get contactUs => 'Bize Ulaşın';
  @override
  String get rateApp => 'Uygulamayı Değerlendir';
  @override
  String get shareApp => 'Uygulamayı Paylaş';
  @override
  String get clearCache => 'Önbelleği Temizle';
  @override
  String get clearData => 'Verileri Temizle';
  @override
  String get exportData => 'Verileri Dışa Aktar';
  @override
  String get importData => 'Verileri İçe Aktar';

  // Errors
  @override
  String get somethingWentWrong => 'Bir şeyler yanlış gitti';
  @override
  String get networkError => 'Ağ hatası';
  @override
  String get noInternetConnection => 'İnternet bağlantısı yok';
  @override
  String get serverError => 'Sunucu hatası';
  @override
  String get dataLoadingFailed => 'Veri yükleme başarısız';
  @override
  String get dataSavingFailed => 'Veri kaydetme başarısız';
  @override
  String get validationError => 'Lütfen girdiğinizi kontrol edin';
  @override
  String get permissionDenied => 'İzin reddedildi';
  @override
  String get fileNotFound => 'Dosya bulunamadı';
  @override
  String get invalidFile => 'Geçersiz dosya';
  @override
  String get uploadFailed => 'Yükleme başarısız';

  // Date and Time
  @override
  String get today => 'Bugün';
  @override
  String get yesterday => 'Dün';
  @override
  String get tomorrow => 'Yarın';
  @override
  String get thisWeek => 'Bu Hafta';
  @override
  String get lastWeek => 'Geçen Hafta';
  @override
  String get thisMonth => 'Bu Ay';
  @override
  String get lastMonth => 'Geçen Ay';
  @override
  String get thisYear => 'Bu Yıl';
  @override
  String get lastYear => 'Geçen Yıl';

  // Statistics
  @override
  String get statistics => 'İstatistikler';
  @override
  String get totalItems => 'Toplam Kıyafet';
  @override
  String get totalOutfits => 'Toplam Kombin';
  @override
  String get favoriteItems => 'Favori Kıyafetler';
  @override
  String get recentlyAdded => 'Son Eklenenler';
  @override
  String get mostWorn => 'En Çok Giyilen';
  @override
  String get leastWorn => 'En Az Giyilen';
  @override
  String get averagePrice => 'Ortalama Fiyat';
  @override
  String get totalValue => 'Toplam Değer';
}

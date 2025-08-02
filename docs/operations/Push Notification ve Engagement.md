Push Notification ve Engagement
Firebase Cloud Messaging Entegrasyonu
Mimari Önerileri: Push bildirim altyapısı olarak Google’ın çapraz platform çözümü FCM
(Firebase Cloud Messaging) kullanılmalıdır. Flutter’da firebase_messaging paketi ile
entegrasyon sağlanır. Uygulama başlatıldığında Firebase.initializeApp() çağırılıp
FirebaseMessaging.instance.requestPermission() ile kullanıcıdan izin alınır . Cihaz
başlatıldığında FCM kaydı için getToken() ile alınan device token kullanıcı profiline
(örneğin Supabase profil tablosuna) kaydedilir. Böylece backend’den (FastAPI veya Supabase
fonksiyonu) bu tokene hedefli push gönderilebilir. Mesaj alımı için
FirebaseMessaging.onMessage (uygulama ön plandayken) ve
FirebaseMessaging.onBackgroundMessage (arka plandaysa) dinleyicileri tanımlanmalıdır
. Arka planda mesaj işlemek için top-level bir handler (@pragma ile işaretli) yazılmalı .
FastAPI tarafında ise Python firebase-admin SDK ile messaging.send(message)
kullanılarak push iletilebilir (örnek kod aşağıdadır).
Araçlar ve Kütüphaneler: Flutter’da firebase_core, firebase_messaging, gerektiğinde
flutter_local_notifications (foreground bildirim için) kullanılmalı . Backend’de firebaseadmin (Python) veya FCM HTTP API’si ile mesaj gönderilir. Örneğin FastAPI içinde
firebase_admin.messaging modülü kullanarak hedef cihazların tokenlarına bildirim
atanabilir .
Örnek Kod (Flutter):
// Firebase başlatma ve izin isteme
await Firebase.initializeApp();
FirebaseMessaging messaging = FirebaseMessaging.instance;
NotificationSettings settings = await messaging.requestPermission(
alert: true, badge: true, sound: true
);
if (settings.authorizationStatus == AuthorizationStatus.authorized) {
String? token = await messaging.getToken();
// token'ı backend'e (Supabase profiline) gönder
}
// Uygulama ön planda iken mesaj dinleme
FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
print('Mesaj alındı (ön planda): ${msg.data}');
// Burada flutter_local_notifications ile gösterim yapılabilir
});
// Arka planda mesaj dinleme (top-level fonksiyon)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage msg)
async {
•
1
2 3
•
2 4
5
•
1
await Firebase.initializeApp();
print('Arka planda mesaj: ${msg.messageId}');
}
FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
Bu kodda requestPermission ile izin istenir, getToken() ile cihaz token’ı alınır ve
onMessage / onBackgroundMessage ile gelen mesajlar işlenir .
Potansiyel Sorunlar ve Çözümler:
APNs Konfigürasyonu: iOS için APNs sertifikası veya anahtarının Firebase projesine yüklenmesi
gerekir. Yoksa iOS cihazlarda mesaj alınamaz.
Bildirim Kanalı (Android 8+): Android 8+ cihazlarda kanal oluşturulmalıdır. FCM varsayılan kanal
sunar, ancak kendi kanalınızı tanımlamak için default_notification_channel_id meta
verisi kullanılabilir .
Android 13+ İzni: Android 13 (API 33) ve sonrası için manifest’e POST_NOTIFICATIONS
eklendikten sonra runtime izni alınmalı. Aksi halde bildirimler gösterilmez .
Background Handler: onBackgroundMessage fonksiyonu top-level ve @pragma('vm:entrypoint') ile işaretlenmelidir; aksi durumda mesaj işleme çalışmaz .
Token Yenileme: Kullanıcının FCM token’ı zamanla değişebilir.
FirebaseMessaging.instance.onTokenRefresh dinlenip backend’e güncelleme
gönderilmelidir.
Veri Miktarı: Çok fazla veri içeren mesajlar cihaz performansını etkileyebilir. Mesaj yükünü
minimumda tutun, kullanıcıyı yönlendirecek deep link veya data kullandığınıza emin olun.
Performans, Bakım ve Test Önerileri:
Cihaz başına dakikada 240, saatte 5000 mesaj gönderimi sınırı vardır . Bu sınırı aşmamak
için bildirimleri kademeli olarak gönderin veya FCM Topics kullanın. Örneğin 10K kullanıcıya push
atarken toplu (batch) veya konularla (topic) yayın yapabilirsiniz.
Test için Firebase Console veya script ile doğrudan mesaj gönderin. Ayrıca flutterfire
configure ile yapılandırılmış örnek projede olduğu gibi gerçek cihazlarda tüm durumları
(foreground, background, terminated) kontrol edin .
Riverpod gibi state yönetiminde NotificationService şeklinde bir servis sağlayıcı (Provider)
oluşturup, uygulama açılır açılmaz dinleyicileri kaydedin. Bu sayede testler sırasında izole
edilebilir ve bakım kolaylığı sağlanır.
Mesaj payload’larına (örn. data alanı) anlamlı anahtarlar ekleyerek, uygulama açıldığında ilgili
ekranlara yönlendirme yapın. Bildirime tıklama event’ini FirebaseAnalytics.logEvent ile
kaydedip etkileşimi ölçün.
Katmanlar Arası Akış (Örnek):
Kullanıcı “Beğeni” yaptığında: UI → Uygulama Katmanı (Riverpod) → Domain (LikeUseCase) → API
Katmanı (REST GraphQL) → FastAPI servisi (Supabase güncellemesi) →
firebase_admin.messaging.send() ile FCM push → Flutter uygulamasında onMessage
ile alım → Kullanıcıya local bildirim gösterilmesi.
Use-Case Senaryoları:
1 2
•
•
•
6
•
7
•
3
•
•
•
• 8
•
2
•
•
•
•
•
2
Bir kullanıcı favori tasarımcısından yeni kombin ekleyince, tasarımcıyı takip eden tüm
kullanıcılara anında push gönderilir. Böylece dikkat çekilerek uygulamaya yönlendirme sağlanır.
Mesajlaşma özelliği varsa, kullanıcı bir mesaj aldığında anlık bildirim gönderilir. Arka planda
çalışan FastAPI, gelen mesajı işler ve ilgili diğer kullanıcıya FCM ile iletir.
Kullanıcı beğendiği ürünün stoğu tükenmek üzereyse (“Low stock”), arkaplanda çalışan hizmet bu
durumu algılar ve kullanıcıya anlık hatırlatma push’u yollar.
Performans/Kapasite Öngörüleri:
Örneğin 10K aktif kullanıcıya günde ortalama 5 push atılsın (örn. benzer öneriler, bildirimler vb.).
Bu 50K/gün, FCM için rahatlıkla yönetilebilecek bir hacimdir (FCM yüz milyonlarca iletiyi
destekler) . Ancak ani patlamalarda backend’i ölçeklendirin.
Broadcat/Topics kullanırken cihaz sayısı arttıkça konuya abone edilirken network yükü doğar. Çok
yüksek abone sayılarında segmentasyon yapıp alt-konular (örneğin “tr_1”, “tr_2” vb.) oluşturmak
gerekebilir.
Kaydolma izni (“opt-in”) oranlarını izleyin. Yüksek trafik dönemlerinde (örn. kampanya dönemleri)
sık push gereksinimi varsa, FCM quota limitlerine takılmamak için gönderimleri sıraya alın veya
paralelleştirin.
Local Notification Yönetimi
Mimari Önerileri: Flutter uygulamasında uygulama içi bildirimler ve zamanlanmış hatırlatmalar
için flutter_local_notifications paketi kullanılmalıdır. Örneğin uygulama ön plandayken
bir FCM mesajı alınırsa, bu mesajı ekrana göstermek için lokal bildirim oluşturmamız gerekir,
çünkü gözüken bildirim varsayılan olarak gösterilmez . Yüksek önem dereceli bir Android
NotificationChannel tanımlayarak (örneğin Importance.high ) uyarı (heads-up) bildirimleri
alınmasını sağlayın . iOS’ta da
FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert:
true, badge: true, sound: true) ile ön plan sunumunu açın . Zamanlanmış
bildirimler (örn. günlük hatırlatma) için plugin’in schedule veya periodicallyShow
metodunu kullanın.
Araçlar ve Kütüphaneler: flutter_local_notifications paketi (Android/iOS/kaynak
masaüstü bildirimleri) . Alternatif olarak awesome_notifications paketi de kullanılabilir; bu
paket aksiyon butonları ve resimli bildirimler için geniş imkanlar sunar. Firebase bağlantısı için
yine firebase_messaging kullanılmaya devam eder. Bildirim ikonları ve kanal bilgileri
platforma uygun şekilde yapılandırılmalıdır.
Örnek Kod:
final FlutterLocalNotificationsPlugin fln =
FlutterLocalNotificationsPlugin();
const AndroidInitializationSettings androidInit =
AndroidInitializationSettings('@mipmap/ic_launcher');
final InitializationSettings initSettings =
InitializationSettings(android: androidInit);
await fln.initialize(initSettings);
•
•
•
•
•
9
•
•
2 1
•
2
4
10
•
4
•
3
// Yüksek öncelikli Android kanalı oluşturma
const AndroidNotificationChannel androidChannel =
AndroidNotificationChannel(
'high_importance_channel',
'Önemli Bildirimler',
description: 'Önemli bildirimler için kanal.',
importance: Importance.high,
);
await
fln.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
?.createNotificationChannel(androidChannel);
// Foreground mesajı geldiğinde lokal bildirim gösterme
FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
final notif = msg.notification;
if (notif != null && notif.android != null) {
fln.show(
msg.hashCode,
notif.title,
notif.body,
NotificationDetails(
android: AndroidNotificationDetails(
androidChannel.id, androidChannel.name,
channelDescription: androidChannel.description,
),
),
);
}
});
Bu kod flutter_local_notifications ile bir kanal tanımlayıp, gelen FCM mesajlarını lokal
bildirim olarak gösterir .
Potansiyel Sorunlar ve Çözümler:
İzin Gerekliliği: iOS’ta lokal bildirimler için izin gereklidir. IOSInitializationSettings ile izin
tanımı yapın. Android 13+’te POST_NOTIFICATIONS iznini runtime’da isteyin.
Bildirim Sınırları: iOS’ta eşzamanlı bekleyen bildirimin üst sınırı ~64’tür. Çok sayıda zamanlanmış
bildirim ayarlarsanız, limitin üzerine çıkanlar atılabilir. Planlama yaparken bu limiti dikkate alın.
İcon ve Kanal: Her platforma uygun ikon seti ve kanal tanımlamayı atlamayın. Kullanılmayan
bildirim kanalları kullanıcı için kafa karışıklığı oluşturabilir.
Uygulama Ölü Konsol Kullanımı: Uygulama kapalıyken arka planda lokal bildirim oluşturmak
zordur (Flutter initialize gerekebilir). Mümkün olduğunca zamanlama bildirimlerini uygulama
açıkken veya OS planlayıcısı ile yapın.
Performans, Bakım ve Test Önerileri:
Bildirim kanalları, önceden sadece bir kez oluşturulmalı ve yeniden kullanılmalıdır. Yüksek/orta/
düşük öncelik gibi kanalları yöneterek tutarlı deneyim sağlayın.
4 2
•
•
•
•
•
•
•
4
Lokal bildirimler cihazda hafif kaynak tüketir; ancak çok sayıda zamanlanmış bildirim belleği
kullanabilir. Yedekleme gibi durumlarda bunları temizleyin (örn.
cancelAllNotifications() ).
Hem emülatörde hem gerçek cihazlarda kanal ve izinleri test edin. Android 13 özel izin
(POST_NOTIFICATIONS) bu paket tarafından otomatik istemez; ayrı kod gerekebilir.
flutter_local_notifications ile yapılmış bir gösterimden sonra uygulama arka planda
ise, kullanıcı bildirimi tıkladığında uygulama açılacaktır. Onu yönlendirmek için
onSelectNotification callback kullanılabilir.
Katmanlar Arası Akış (Örnek):
Zamanlanmış Hatırlatma: Uygulama Açılışı → App Controller (Timer ayarı) →
flutter_local_notifications.schedule(...) ile belirli tarihte bildirim kaydetme.
Anlık Bildirim (İçerik Trigerli): Kullanıcı uygulama içi bir işlemi tetikler (ör. alışveriş tamamlıyor) →
işlem sonucunda lokal bildirim anında gösterilir (FCM dışı, doğrudan plugin ile).
Use-Case Senaryoları:
Kullanıcı günlük rutinini uygulamada belirttiyse (örn. egzersiz zamanı), ilgili saatte lokal push ile
hatırlatma gönderilir.
Kullanıcı favorilere eklediği ürün stokta azaldığında, ön planda veya arka planda planlı bir lokal
bildirimle hatırlatma yapılır.
Günlük moda ipuçları (örn. “Günün kombini”) gibi periyodik içerik her gün aynı saatte lokal
bildirimle sunulabilir.
Performans/Kapasite Öngörüleri:
Lokal bildirimler internet kullanmaz; ölçekle ilgili endişe yoktur. Ancak cihazın bildirim kuyruğu ve
iOS sınırlamalarına dikkat edilmelidir.
Android’da birden fazla kanal kullanımı, kullanıcıların bildirim yönetimini kolaylaştırır. Örneğin
“genel”, “kampanya”, “aktif görev” gibi kanallar.
Zamanlanmış çok sayıda bildirim, özellikle düşük bellekli cihazlarda performans sorununa yol
açabilir. Gereksiz veya eskimiş bildirimler temizlenmeli.
Bildirim İzin Yönetimi
Mimari Önerileri: Kullanıcıdan bildirim izni istemek için en uygun zaman başlangıç veya kritik
bir özellik tetiklendiğinde sağlanmalıdır. Flutter’da firebase_messaging ile
requestPermission() çağrılır; iOS ve Android 13+’de kullanıcının onayı bu adımda alınır .
Android 13 ve üstü için ayrıca permission_handler paketi üzerinden
Permission.notification.request() da yapılabilir. İzin reddedilirse yeniden sorma
mümkün olmadığından (özellikle iOS’ta), önceden izin isteme gerekçesini açıklayan bir ekran
gösterip kullanıcıyı Ayarlar’a yönlendirmek gerekir.
Araçlar ve Kütüphaneler:
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
•
•
•
•
4 2
•
1
•
5
Flutter firebase_messaging paketi (iOS/macOS için bildirim izni isteme) .
permission_handler (Android 13+ özel Permission.notification ).
Gerekirse özel dialoglar (ör. Riverpod ile PermissionController) ile kullanıcıya izin açıklaması
gösterin.
Örnek Kod:
// Bildirim izni isteme
NotificationSettings settings = await
FirebaseMessaging.instance.requestPermission(
alert: true, badge: true, sound: true, announcement: false
);
if (settings.authorizationStatus == AuthorizationStatus.authorized) {
print('Bildirim izni verildi.');
} else {
print('Bildirim izni reddedildi.');
// Gerekirse Ayarlar’a yönlendirme yapılabilir.
}
Bu kod iOS ve (Android 13 üzeri) platformlarda izin penceresini açar .
Potansiyel Sorunlar ve Çözümler:
Tekrar İsteme Yok: iOS’ta kullanıcı “Reddettim” dediyse tekrar izin diyaloğu gösterilemez . Bu
yüzden önceden bilgilendirme yapın. Aynı şekilde Android’da kullanıcı açıkça “Hayır” dediyse
ayarlardan açması gerekir.
Android 13+ İzni: Manifest’e POST_NOTIFICATIONS ekledikten sonra runtime’da izin
istemelisiniz . Aksi halde uygulama notifikasyon göstermez.
Kullanıcı Deneyimi: İzni çok erken veya yanlış zamanda sorarsanız kullanıcıdan olumsuz yanıt
alabilirsiniz. Genellikle uygulama tanıtıldıktan, değerini anladıktan sonra izin istemek daha
başarılıdır.
Yönlendirme: Kullanıcı izin vermezse uygulama içi bir “Ayarlar” ekranı veya diyalog ile onu sistem
ayarlarına yönlendirin.
Performans, Bakım ve Test Önerileri:
İzin talebini uygulamanın çok başlangıcında değil, uygulama içi kullanıcıya değeri
anımsatacak bir eylemden sonra yapın. Örneğin “Bildirimlerle favori tasarımcılarının
içeriklerini kaçırmayın” gibi kısa bir açıklama sunarak talep edin.
Deneme cihazlarında hem izin verdikten sonra hem reddettikten sonra davranışı test edin. iOS’ta
reddedilince uygulama önüne izin diyaloğu gelmediğini, settings.authorizationStatus
değerinin denied döndüğünü kontrol edin.
Android 13 için AndroidPermissionHandler çağrısını test edin ve izin durumuna göre
kullanıcıya bilgi verin. Gerekirse kullanıcıya “Bildirimler kapalı. Etkileşimi artırmak için
açabilirsiniz.” benzeri uyarı gösterin.
Unit testi yerine manuel test önerilir, zira izin diyaloğu sistem davranışıdır. E2E testlerde Mockito
ile requestPermission davranışını canlandırabilirsiniz.
• 1
•
•
•
1
•
• 11
•
7
•
•
•
•
•
•
•
6
Katmanlar Arası Akış (Örnek):
Uygulama İlk Açılışta: Uygulama Açılışı → Onboarding/Permissions Ekranı →
requestPermission() çağrısı → Kullanıcı yanıtı → (Verildiyse) Token alınır ve kaydedilir,
(Verilmediyse) kullanıcı bilgilendirilir.
Ayarlar Menüsünden: Kullanıcı menüden izinleri kontrol ederse: UI →
FirebaseMessaging.instance.getNotificationSettings() ile durum al → Kullanıcı izin
durumuna göre Ayarlar’a yönlendirme.
Use-Case Senaryoları:
İlk açılışta, uygulamaya hoş geldiniz bilgisi gösterip sonra bildirimlerin faydası anlatıldıktan sonra
izin isteyin. Örneğin “En yeni kombinleri ilk siz görün.” gibi bir mesajla motivasyon sağlayın.
Uygulama içi spesifik bir eylem sonrası izin istenebilir. Örneğin kullanıcı favori bir ürünü “takip”
ettiğinde “Bu ürüne dair güncellemeleri almak ister misiniz?” diyerek izin diyaloğu açabilirsiniz.
Android 13 cihazlarda, uygulama açılırken değil de bir aksiyon sonrası izin istemek daha iyi sonuç
verir (ör. ekran geçişi sonrası).
Performans/Kapasite Öngörüleri:
İzin isteme işlemi ağ kullanmaz ve bekleme süresi kısa olmalıdır, ancak kullanıcı deneyimine
etkisi büyüktür. Uygulama hızından ziyade “zamanlama” kritik olduğu için UX testi önemlidir.
Deneylerde izin istenen anda uygulama açılma süresinin kullanıcıdaki etkisini ölçün (örneğin
Splash screen yerine ana ekranda istemek).
Kullanıcıların % kaçının izin verdiği ve nerede verdikleri (ayarlardan mı, ilk deneme/ret ardından
mı) gibi metrikleri Firebase Analytics ile takip edebilirsiniz.
User Engagement Stratejileri
Mimari Önerileri: Push bildirimleri yalnızca haberleşme aracı değil, kullanıcı bağlılığını artırma
stratejisidir. Özellikle e-ticaret ve sosyal uygulamalarda kişiselleştirme ve zamanlama ön
plandadır. Geçmiş davranışa dayalı kişiselleştirilmiş push’lar, doğru zamanda gönderildiğinde çok
daha etkilidir . Bu nedenle Firebase Analytics ile kullanıcıların ilgi alanları, etkinlikleri (ör.
favoriye ekleme, beğeni, önceki alışveriş) takip edilmeli; belirli gruplar (segmentler) için
özelleştirilmiş içerik hazırlanmalıdır. Örneğin kullanıcı modu “sokak stili” ise sadece ona uygun
kombin duyurusu, indirim ya da içerik göndermek verimi artırır.
Araçlar ve Kütüphaneler: Firebase altyapısını kullanarak; Firebase Analytics ile özel event’ler
( logEvent ) kaydedilebilir, segmentasyon yapılabilir. Remote Config veya A/B test araçları ile
farklı bildirim içeriklerini veya zamanlamaları kıyaslayın. Pazarlama amaçlı üçüncü parti çözümler
(Braze, MoEngage vb.) de entegre edilebilir, ancak Firebase’in sundukları pek çok ihtiyacı karşılar.
Push mesajlarının içeriğini hazırlamak için backend’de şablonlama veya dinamik içerik (ör.
kullanıcı adı dahil etme, güncellik bilgisi ekleme) sistemi kurun.
Örnek Kod: Kullanıcının bir ürünü beğendiğinde hem Analytics’e kayıt hem de backend’e haber
verip push göndermek şu şekilde olabilir:
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
•
1 7
•
12
•
•
7
// Flutter: Analytics event
await FirebaseAnalytics.instance.logEvent(
name: 'item_liked',
parameters: {'item_id': itemId, 'category': 'clothing'},
);
# FastAPI: Beğeni sonrası push
from firebase_admin import messaging
message = messaging.Message(
notification=messaging.Notification(
title="Kombinin beğenildi!",
body=f"{liker_name} kombinini beğendi."
),
token=target_user_token,
data={'type': 'like', 'item_id': str(itemId)}
)
response = messaging.send(message)
print("Gönderilen mesaj ID:", response)
Bu örnekte beğeni olayı Flutter’da loglanır, aynı anda FastAPI backend’i FCM ile bildirim gönderir.
FCM data payload sayesinde uygulama açıldığında ilgili sayfaya yönlendirme yapılabilir.
Potansiyel Sorunlar ve Çözümler:
Aşırı Gönderim: Çok sık push gönderimi kullanıcıda bildirimi kapatma eğilimi yaratır. Örneğin
günde birden fazla pazarlama bildirimi yerine, kritik olaylar (iletim, beğeni, vs) ayrı,
promosyonlar ayrı periyotlarda planlanmalı.
Hedefleme Kaybı: Geniş bir gruba aynı mesaj atmak kişiselleştirilmiş etkiyi düşürür. FCM Topics
veya conditions kullanarak (örn. topics: ["segment_A", "segment_B"] ) grupları
hedefleyin.
Trafik Patlaması: Pazarlama kampanyaları veya beklenmedik trafik artışlarında (örneğin popüler
bir içeriğin viral olması) push mesajları da artar. FastAPI veya mesaj işleyen servisler auto-scaling
ile desteklenmeli. Kuyruk mekanizması (Redis, Celery) ile istekler karşılanmalı.
İçerik Uyumsuzluğu: Bildirim içeriği, kullanıcıyı açmaya ikna etmediğinde etkileşim düşer. Başlık/
metin kısa, ilgi çekici olmalı; emojiler veya açık çağrı (CTA) kullanılabilir.
Zamanlama: Gece yarısı bildirim kullanıcı kaybettirir. Gönderim saatlerini kullanıcı yerel saatine
göre ayarlamak için backend’de zaman dilimine dikkat edin.
Performans, Bakım ve Test Önerileri:
Segmentasyon için Firebase Analytics’ten user property’ler (örn. “favorite_category”)
tanımlayarak bu değerlere göre topic’lar oluşturun. Mesela sporla ilgilenenler “sports_topic”a,
elegan modayı sevenler “elegant_topic”a abone olur.
A/B testleri yaparak bildirim içeriğinin performansını ölçün. Firebase’de Remote Config ile farklı
kitlelere farklı mesaj test edin ve açılma/oran dönüşüm oranlarını karşılaştırın.
Her push kampanyası için hedef metrikler (örn. % açılma, % dönüşüm) belirleyin. Bu değerler CI/
CD pipeline’ında değil, pazarlama dashboard’larında izlenmelidir.
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
8
Bildirimlerin sonuçlarını Firebase Analytics’te özel event’lerle takip edin (örn.
notification_opened , notification_action ). Böylece hangi içeriklerin işe yaradığını
analiz edebilirsiniz.
Katmanlar Arası Akış (Örnek):
Yeni Ürün Bildirimi: Yeni ürün ekleme olayı backend’de gerçekleşir (Supabase veri güncelleme) →
FastAPI, ilgili kullanıcılara FCM push (ürünle ilgili veri payload) gönderir → Flutter’da
onMessage tetiklenir veya sistem bildirimi ile gösterilir.
Etkinlik Sonrası Hatırlatma: Kullanıcı bir etkinliğe katıldıysa (konferans, atölye vb.), FastAPI bu
katılımı kaydeder ve uygun zamanda (örn. etkinlik öncesi 1 saat kala) zamanlanmış bir FCM
mesajı yollar → Uygulamada bildirimle hatırlatma yapılır.
Use-Case Senaryoları:
Kombin Beğeni: Kullanıcı bir ürünü beğendiğinde, ürünün sahibi kullanıcılardan biri ise ona
“Ürünün beğenildi” bildiriminde bulunulur. Bu örnekte cihaz token’ları Supabase’de saklanır ve
FastAPI bu token’a FCM gönderir.
Kampanya Hatırlatma: Büyük bir kampanya başlayacağı zaman (örn. özel indirim günleri), tüm
kullanıcılara değil, daha önce alışveriş yapmış veya belirli kategori ile ilgilenen segmentlere
bildirim gönderilir. Böylece reklam bütçesi verimli kullanılır.
Profil Güncellemesi: Kullanıcı profilini detaylı doldurmayı unuttuysa, profil tamamlama bildirimi
gönderilir. Kullanıcılar, izleyici ekledikçe veya aktif oldukça daha kişiselleşen bildirimi alır.
Performans/Kapasite Öngörüleri:
Push bildirimleri için bir bottleneck genellikle backend hizmetidir. FastAPI veya mesaj kuyruğu
hizmeti yatay olarak ölçeklendirilmeli; örneğin her 100K kullanıcı için en az 2-3 instance önerilir.
Firebase Analytics günde milyonlarca event loglayabilir; bu veriler gerçek zamanlı tüketim yerine
batch analiz için uygundur. Gerçek zamanlı push tetiklemeleri doğrudan uygulama event’inden
(örn. beğeni yapıldığında anlık) yürütebilirsiniz.
FCM Topics kullanıyorsanız, her topic’a abone cihaz sayısı çok yüksekse belirli limitlerin (örn.
HTTP request başına gönderim kapasitesi) aşılmamasına dikkat edin. Gerekirse büyük kullanıcı
gruplarını alt-topiklere ayırarak segmentasyon yapın.
Permissions | FlutterFire
https://firebase.flutter.dev/docs/messaging/permissions/
Receive messages in a Flutter app  |  Firebase Cloud Messaging
https://firebase.google.com/docs/cloud-messaging/flutter/receive
firebase_messaging example | Flutter package
https://pub.dev/packages/firebase_messaging/example
Build app server send requests  |  Firebase Cloud Messaging
https://firebase.google.com/docs/cloud-messaging/send-message
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
•
•
12
1 11
2 3
4 10
5
9
Set up a Firebase Cloud Messaging client app on Android
https://firebase.google.com/docs/cloud-messaging/android/client
About FCM messages  |  Firebase Cloud Messaging
https://firebase.google.com/docs/cloud-messaging/concept-options
Does FCM have any limitations on the number of free in-app/push notifications? Can it handle 21M+
notifications/month for 7M users? : r/Firebase
https://www.reddit.com/r/Firebase/comments/1dbuivf/does_fcm_have_any_limitations_on_the_number_of/
35 Push Notification Best Practices That Work: A Complete Guide for Marketers35 Push Notification
Best Practices That Work: A Complete Guide for Marketers
https://clevertap.com/blog/push-notification-best-practices/
6 7
8
9
12
10
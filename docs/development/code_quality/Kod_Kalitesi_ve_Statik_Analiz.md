Kod Kalitesi ve Statik Analiz
Modern hibrit bir projede kod kalitesi, hem frontend (Flutter/Dart) hem de backend (FastAPI/Python)
katmanlarında titizce sağlanmalıdır. Bu amaçla lint kuralları ve statik analiz araçları devreye girer.
Flutter’da package:flutter_lints seti ve analysis_options.yaml ile güçlü lint kuralları
belirlenirken, FastAPI tarafında ruff , flake8 , mypy gibi araçlar ve pre-commit hook’ları
kullanılır. Tüm kod tabanında otoformatlama (ör. dart format , black ), tip kontrolü ve hata
bulma adımları CI pipeline’ında otomatikleştirilir. Örneğin; Flutter projesinin kökünde bir
analysis_options.yaml dosyası aşağıdaki gibi olabilir:
include: package:flutter_lints/flutter.yaml
linter:
rules:
avoid_print: false # print yerine log kullanılmasını teşvik et
prefer_const_constructors: true
avoid_init_to_null: true
analyzer:
strong-mode:
implicit-casts: false # açıkcast ve implicit-dynamic yasakla
implicit-dynamic: false
errors:
unused_local_variable: warning
dead_code: error
Bu yapı flutter_lints ’i etkinleştirir, ardından kuralları özelleştirmeyi sağlar . Python/FastAPI
tarafında ise pyproject.toml veya .flake8 , .pre-commit-config.yaml gibi dosyalarla benzer
kurallar belirlenir. Örneğin bir .pre-commit-config.yaml aşağıdaki gibi tanımlanabilir:
repos:
- repo: https://github.com/astral-sh/ruff
rev: 0.0.284
hooks:
- id: ruff # Çok hızlı Python lint aracı
- repo: https://github.com/psf/black
rev: 23.9.1
hooks:
- id: black # Python kod formatlama
- repo: https://github.com/pre-commit/mirrors-mypy
rev: v1.0.1
hooks:
- id: mypy
args: [--ignore-missing-imports]
1 2
3
1
Bu lint araçları, kodlama standartlarına uyumu zorunlu kılar, hataları erkenden yakalar ve
okunabilirliği artırır . Örneğin, Flutter’daki analysis_options.yaml ile implicit-dynamic
kapatılarak tip güvenliği sağlanır, unused_local_variable gibi hatalar ciddi uyarıya çevrilir .
Python tarafında ise Ruff, Flake8 ve Black fonksiyonlarını tek bir hızlı araçta toplar; kod tabanındaki
bütün Python dosyalarını saniyeler içinde (binlerce satırda ~0.2 saniyede) tarayabilir .
Özelleştirilmiş lint kuralları ( custom_lint paketi) ile proje ihtiyaçlarına göre ek kontroller (ör. naming
convention, güvenlik politikası gibi) yazılabilir .
Araçlar ve kütüphaneler: package:flutter_lints , analysis_options.yaml ,
custom_lint (Dart), ruff , flake8 , mypy , black , isort , pre-commit (Python). Kod
editöründe Dart analizörü ve VSCode/Android Studio eklentileri, Python için de Ruff/Mypy
eklentileri kullanılabilir.
Kod örneği: Yukarıdaki analysis_options.yaml gibi yapı, lint kurallarını merkezi olarak
yönetir. Python’da pyproject.toml içinde [tool.ruff] , [tool.mypy] bölümleriyle
kurallar tanımlanır.
Potansiyel sorunlar: Çok katı kurallar geliştiriciyi yavaşlatabilir; geçerli durumlar için //
ignore: ile devre dışı bırakma imkanı sağlanmalı. Kurallar güncellenirse legacy kodda çok
sayıda uyarı gelebilir – bu durumda dart fix , uvx ruff fix gibi otomatik düzeltmelerden
yararlanılır. Çakışan linter konfigürasyonları (birden fazla include ) tekilleştirilmelidir .
Performans ve bakım: Flutter analizörü genelde hızlıdır ve değişen dosyalarda artımlı çalışır;
Python’da Ruff yüzlerce kat daha hızlı olduğu için test/milyon satırlık projelerde bile gecikme
sorun olmaz . Linter kuralları, kod karmaşıklığını düşürerek test edilebilirliği artırır.
Karmaşıklık (cyclomatic complexity) gibi metrikler de CI ile izlenerek aşılması engellenir.
Metinsel akış: Geliştirici (UI/domain katmanında) kod yazar (IDE gerçek zamanlı Dart analizörü
uyarır) → Kod versiyon kontrolüne push edilir → CI pipeline tetiklenir → flutter analyze ve
ruff check adımları çalışır (lint hatası varsa pipeline başarısız olur) → Hatalar düzeltilip tekrar
push yapılır → Kod inceleme (Pull Request) başlar.
Senaryo: Yeni bir widget geliştiricisi print kullanır, ancak avoid_print lint kuralı devreye
girer. CI başarısız olunca hata raporu alınır; geliştirici debugPrint veya Logger kullanarak
hatayı giderir. Öte yandan backend’de bir endpoint için yanlış async kullanımı tespit eden Ruff
hatası, CI raporunda görünür ve düzeltilir.
Kod İnceleme Süreçleri (Code Review)
Kod inceleme, yazılan değişikliklerin kalite kontrolünden geçmesini sağlar. Entegre bir CI ile kod
incelemesi daha etkili hale gelir: lint ve testler ön incelemeyi otomatik yapar, böylece insan
incelemesi mimari, iş mantığı ve stil gibi derin konulara odaklanır . Genellikle GitHub/GitLab
üzerinden Pull Request (Merge Request) akışı izlenir. Küçük, odaklanmış PR’lar teşvik edilir – örneğin
200-400 satır arasında değişiklikler üzerinde durulmalı . Kod incelemede ön kontrol adımları
şunlardır:
Geliştirici yeni bir özellik/bug-fix dalı açar ve kod yazar.
Kodu versiyon kontrolüne push edince CI otomatik çalışır (lint, test, statik analiz).
CI başarıyla geçerse geliştirici Pull Request oluşturur.
En az 2 farklı reviewer, PR’ı inceler. İsimlendirme, kod stili, karmaşıklık, mimari tutarlılık gibi
konulara bakar; güvenlik veya performans endişelerini kontrol eder.
Gerekirse reviewer’lar yorum ve iyileştirme önerileri ekler. Geliştirici düzeltmeleri yapar ve
günceller.
Tüm onaylar alındığında ve gerekli kalite metrikleri sağlandığında (ör. kod kapsamı, kalite gate)
dal ana gelişme hattına birleştirilir.
4 5
2
6 7
8
•
•
•
9
•
7
•
•
4 5
10
1.
2.
3.
4.
5.
6.
2
Araçlar ve uygulama: GitHub/GitLab pull request şablonları, kod inceleme checklist’leri (örn.
okunabilirlik, test kapsamı, güvenlik kontrolleri listeleri), otomatik entegrasyonlar (lint ve test
sonuçlarını PR’a ekleyen GitHub Action’lar) kullanılır. Gerekirse Danger veya benzeri araçlarla ek
kurallar (ör. PR başlığı kontrolü, TODO/lint hatası engelleme) eklenebilir.
Potansiyel sorunlar: Çok büyük PR’lar yorucu olabilir; böl ve yönet ilkesiyle küçük PR’lar tercih
edilmelidir. Otomasyon eksikse reviewer’lar sıradan hataları fark etmeyebilir. Bu yüzden
“committen önce testler geçmeli” ve “lint hatası yok” gibi politikalar zorunlu tutulur. PR incelemesi
uzun sürerse gecikmeler olur; bu yüzden küçük ve anlamlı değişiklik hedeflenmelidir . Ayrıca
kod incelemesinin bir öğrenme fırsatı olduğu unutulmamalı, yapıcı geri bildirim kültürü (pozitif
ve net yorum) benimsenmelidir .
Test edilebilirlik & bakımı: Kod inceleme süreçleri, iyi tanımlı modüller ve temiz kod yazılmasını
teşvik eder. Örneğin, iş mantığı karmaşıklaşmadan önce basitleştirilmeli (ayrıştırılmalı), böylece
kod hem test edilebilir hem de anlaşılır olur. Review sırasında test senaryoları da gözden
geçirilerek eksik durumlar belirlenebilir.
Metinsel akış: Geliştirici kodu push eder → CI (lint/test) çalıştırır → PR açılır → Kod inceleme
checklist’i ile incelenir (örn. değişiklik küçük mü, anlamlı isimlendirme var mı, mimari uyumlu mu) →
Geri bildirimler üzerinden düzeltmeler yapılır → Onay alan PR merge edilir.
Senaryo: Yeni bir özellik branşı açıldığında, CI kalite kontrolü sonrası ekip kodu inceler. Örneğin,
bir arkadaşımız “şu kod bloğu tekrar eder olmuş, bunun yerine fonksiyon yazabilir miyiz?” diye
sorabilir. Veya “burası async olmalı” gibi geri dönüşler yapılabilir. Değişiklikler tamamlanınca
yazılım sahaya alınır.
Unit Test Coverage Hedefleri
Bir sistemin güvenilir olması için yeterli test kapsamı gereklidir, ancak kapsam yüzdesine körü körüne
bakılmaz; odak riskli kod yollarını test etmekte olmalıdır . Genele bakıldığında Google
standartlarına göre yaklaşık %60 “kabul edilebilir”, %75 “övgüye değer”, %90 ise “örnek teşkil eden” bir
kapsam hedefidir . Bu projede en az %75 kapsam hedeflenebilir, önemli modüller için ise %90 civarı
iyidir. Ancak özellikle kritik özelliklerde %100 testi aramak yerine, önemli kod akışları (business logic) ve
hata durumları mutlaka test edilmelidir.
Araçlar: Flutter’da flutter_test , mockito / mocktail , widget/integration testleri için
integration_test vb. paketler; FastAPI’de pytest , pytest-cov , requests veya
httpx ile test yazımı; kod kapsam raporu için lcov veya coverage.py kullanılır. CI
entegrasyonu için Codecov veya Codemagic’in dahili coverage raporları kullanılabilir.
Kod örneği: Örneğin Flutter’da bir API isteği yapan fonksiyon için şu şekilde bir test yazılabilir:
test('Like API çağrısı başarılı olmalı', () async {
// Mock Supabase client
when(supabase.from('likes').insert(any)).thenAnswer((_) async =>
{ ... });
final response = await likeService.likePost(postId);
expect(response.status, equals(201));
});
Potansiyel sorunlar: Yüksek kapsam hedeflemek checklist tuzağına yol açabilir (gereksiz testler
yazmak). Ayrıca hızlıca değişebilen UI kodlarının kapsamı düşük olabilir. Bu nedenle kapsam
hedeflerine aşırı takılmadan önemli iş akışlarına öncelik verilmeli . Eksik kapsam için Sonar/
Codecov gibi araçların raporları PR süreçlerinde incelenebilir. Veri tabanı veya network gerektiren
7.
8.
10
5 11
9.
10.
11.
12 13
14
•
•
•
13
3
testlerde entegrasyon testleri kullanılmalı, ünitestlerde ise bunlar mock’lanarak izolasyon
sağlanmalıdır.
Performans: Test seti ne kadar geniş olursa CI süresi o kadar uzar. Basit bir Flutter UI testinin
çalışması birkaç saniye, tüm test setinin tamamlanması ortalama birkaç dakika sürebilir.
Python’da basit pytest suite’leri (ör. birkaç yüz test) genelde 10–30 saniye, daha kapsamlı
entegrasyon testleri 1–2 dakikada biter. Kod coverage toplamanın ek bir maliyeti var, ancak çoğu
araç bunu CI sonrası hızlıca yapabilir. Örneğin flutter test --coverage komutu
sonrasında lcov raporu oluşturmak ~30 saniye sürer.
Kalite ölçümleri: CI’da her PR’da “yeni eklenen kod” için minimum coverage doğrulaması
yapılabilir. Google rehberlerine göre, her commit’te %99 kapsam hedeflenmesi, proje genelinde
ise %90 taban eşiği makul sayılır . Bu, özellikle yeni kodda test yazılmasını garanti eder.
Kapsamın sürdürülmesi için Codemagic gibi araçlarla kalite kapıları (coverage gate) eklenebilir.
CI Pipeline’da Quality Gate’ler
Sürekli entegrasyon hattında kalite kapıları (quality gates) statik analiz ve test sonuçlarına göre
otomatik karar verir. Örneğin SonarQube kullanılıyorsa, kod kapsamı, hatalar, güvenlik açıkları gibi
metriklere eşikler belirlenir . Bir PR açıldığında CI şu adımları izler:
Lint ve statik analiz: flutter analyze , ruff check vb. çalışır. Herhangi bir bloklayıcı
uyarı veya hata varsa pipeline fail olur.
Test ve coverage: Birimler ve entegrasyon testleri çalıştırılır. Coverage raporu üretilir.
Coverage’ın yeni kod veya proje genelinde hedefin altında olup olmadığı kontrol edilir.
Quality Gate kontrolü: SonarQube (veya benzeri bir sistem) tüm bu sonuçları toplar. Örneğin
“Yeni kodda coverage ≥ %80”, “kritik hata yok”, “code smells azalıyor” gibi koşullar konulur. Eğer
bu koşullar sağlanmazsa, merge engellenir . Böylece sadece yüksek kalitede değişiklikler
ana koda alınır.
Deploy kararı: Tüm kalite kontroller geçildikten sonra kod otomatik olarak staging/prod
ortamına dağıtılabilir (gerekiyorsa manuel onay ile).
Araçlar ve entegrasyon: SonarQube/SonarCloud, Codecov status check’leri, Codemagic’teki
test/coverage adımları gibi araçlar kullanılabilir. Örneğin Sonar’ın “Clean as You Code” kalite
geçidi, yeni kodun belirli kuralları aşmamasını garanti eder . GitHub Actions veya Codemagic
workflow ile bu adımlar tüm PR’lar ve master branch için zorunlu hale getirilir.
Potansiyel sorunlar: Çok sıkı kriterler (örneğin yüksek coverage eşiği) geliştirmeyi yavaşlatabilir,
bu yüzden eşikler makul seviyede tutulmalıdır. Yanlış yapılandırılmış Sonar kuralları da yanlış
alarm verebilir. Bu sebeple öncelikle düşük seviye (warning) raporlar incelenmeli, sonra ileri
seviye (blocker) eşiği ayarlanmalıdır. Ayrıca ci pipeline zaman zaman uzun sürebilir; bu
aşamalarda artımlı tarama, önbellekleme veya paralel çalıştırma tercih edilir.
Performans & kapasite: Quality gate kontrollerinin eklenmesi, pipeline süresine ek birkaç
saniye ila bir dakika ekler. Python lint (Ruff) genelde milisaniyeler alırken, kapsam raporu
hesaplama birkaç saniye sürer. Sonar analizi büyük projelerde birkaç dakikayı bulabilir; ancak
projeyi modüllere ayırarak (monorepo’da hiyerarşik konfigürasyon ) veya sadece değiştirileni
tarayarak hızlanır. Örneğin büyük bir FastAPI kod tabanının Ruff ile taranması ~0.2s sürerken ,
Sonar analizi birkaç yüz satırlık değişikliklerde bile 30–60 saniye alabilir. Pipelineların ölçekliliği
için CI sunucu sayısı ve paralel iş sınırları (örneğin Codemagic paralel job sınırı) izlenmelidir.
Metinsel akış: Bir kod değişikliği yapıldığında UI/Backend katmanında kod revizyonu → Kod push
edilir → CI pipeline’da lint ve testler koşulur → Sonar/Quality Gate kontrolleri çalışır (coverage,
•
•
15
16 17
•
•
•
18
•
•
16
•
•
19
7
•
4
vulnerability, duplication) → Eğer tüm kriterler sağlanırsa PR onaylanır ve merge edilir, aksi halde hata
raporu ile geri bildirim verilir.
Senaryo: Örneğin yeni bir ödeme özelliği ekleyen PR’da CreditCardService sınıfına test
eklenmemişse coverage düşer ve Sonar uyarı verir. Değişiklik merge edilmeden önce eksik test
yazılır ve coverage %80’in üzerine çıkarılırsa, kalite kapısı atlatılmış olur. Aynı şekilde, lint veya
güvenlik sorununda pipeline otomatik olarak başarısız olur ve geliştiriciye bildirim gider.
Performans ve Kapasite Tahminleri (Kod Kalitesi Süreçleri)
Kod kalitesi süreçlerinin performansı da planlanmalıdır. Linting genellikle çok hızlıdır; örneğin Ruff, 250
bin satırlık bir projeyi ~0.2 saniyede analiz edebilmektedir . Dart analizörü de değişiklikleri
önbellekleme ile hızlıca tarar. Bu sayede lint aşaması CI’da neredeyse anlık gerçekleşir. Testler ise
projenin büyüklüğüne bağlıdır: birkaç yüz birim testi 10–30 saniyede, kapsamlı entegrasyon testleri 1–3
dakikada tamamlanabilir. Kod kapsamı araçları (Coverage.py, LCOV) raporlarını hızla üretir; bu ek 20–60
saniye ek yük getirir. Sonar analizi büyük kod tabanlarında birkaç on saniye ila birkaç dakika sürebilir.
Kapasite tahmini olarak, örneğin 1K geliştirici ve 10K günlük commit gibi bir projede bile, lint ve temel
testler paralel çalışarak saniyeler içinde sonuç verebilir. Quality gate’ler (ör. Sonar bulut servisi) genellikle
saniyeler içinde rapor sunar; lokalde çok büyük projelerde dakikalar olabilirse de bulut araçlar hızlıdır.
Kod coverage oranı takibi için CI sunucusu kaynakları ihtiyaca göre ölçeklendirilmeli; çoğu araç
(Codemagic, GitHub Actions) concurrency ile birden fazla işleri aynı anda çalıştırır.
Sonuç olarak, kapsamlı lint ve statik analiz kuralları ile kişi hataları minimize edilir, test süreçleri
güçlendirilir, kod bakımı kolaylaşır ve sürüm güvenliği artar . Bu sayede geliştirici ekip,
değişiklikleri güvenle sahaya çıkarabilir ve sürdürülebilir bir kod tabanı elde edilir.
Kaynaklar: Flutter ve Dart dokümanları (lint yapılandırma), DCM blog (kod inceleme ve lint önemi)
, Google Testing Blog (coverage rehberi) , SonarQube dokümanları (quality gate) ,
Ruff GitHub (Python lint performansı) , Charles’ın blogu (custom_lint tanıtımı) .
Introducing package:flutter_lints | Flutter
https://docs.flutter.dev/release/breaking-changes/flutter-lints-package
Improving Code Reviews - Tools and Practices for Dart and Flutter Projects | DCM - Code Quality
Tool for Flutter Developers
https://dcm.dev/blog/2024/08/08/improving-code-review-process/
GitHub - astral-sh/ruff: An extremely fast Python linter and code formatter, written in
Rust.
https://github.com/astral-sh/ruff
Code reviews: Best practices for maintaining code quality
https://www.statsig.com/perspectives/code-reviews-best-practices-for-maintaining-code-quality
Create your own lint rules with custom lint | Charles's Blog
https://charlescyt.github.io/create-your-own-lint-rules-with-custom-lint
Google Testing Blog: Code Coverage Best Practices
https://testing.googleblog.com/2020/08/code-coverage-best-practices.html
Integrating Quality Gates into Your CI/CD Pipeline: SonarQube Setup Guide | Sonar
https://www.sonarsource.com/learn/integrating-quality-gates-ci-cd-pipeline/
•
7
4 5
4
5 14 13 16 17
3 7 8
1 9
2 4
3 6 7 19
5 10 11
8
12 13 14 15
16 17 18
5
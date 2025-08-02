Kurumsal Düzey Kod Üretimi için Gelişmiş
Prompt Mühendisliği
Yapay zeka temelli kod üretiminde en iyi sonuçları elde etmek için model özelliklerine göre uyarlanmış
stratejiler, ileri düzey prompt kalıpları, çok aşamalı akışlar ve test-odaklı geri bildirim yaklaşımları gereklidir.
Aşağıda, Claude, Qwen, GPT-4o ve Gemini gibi farklı LLM’ler için özelleştirilmiş teknikleri, kod kalitesini
artıran yöntemleri ve güvenlik/doğruluk önlemlerini kapsamlı biçimde ele alıyoruz.
1. Model Bazlı Prompt Stratejileri
Claude (Anthropic): Çok geniş bağlam penceresi (200K+) ve detaylı cevap verme eğilimi vardır
. Karmaşık projelerde bütün dosyaları içeren tek bir prompt kullanılabilir. Claude’a görev
verirken ayrıntılı açıklamalar ve kapsamlı yapılar sağlayın. Örneğin, Claude’dan "bir sunucu
tarafı API tasarımı yapmasını" istiyorsanız, projenin tüm yapısını tarif eden uzun bir açıklama
verin. Claude kodun mantığını adım adım izleme konusunda iyidir, ama bazen gereğinden çok
uzun yanıt verebilir. Bu sebeple, çıktıyı kısıtlı tutmak için açık şablonlar veya YAML yapıları
kullanılabilir.
GPT-4o (OpenAI): Güçlü mantık ve algoritmik çözüm becerisine sahiptir . Daha sınırlı bir
bağlam penceresi (örn. 128K) olduğundan, özellikle karmaşık görevlerde "adım adım düşünme
(chain-of-thought)" içeren sorular vererek modellerini zorlamak faydalı olabilir. GPT-4o’ya
doğrudan kod üretiminde kesin adımlar veya CoT etiketi kullanarak yönlendirin. Örneğin, "Adım
adım bir kullanıcı doğrulama sistemi kur" tarzında istemler, modelin güvenilir, hatasız kod
üretimine yardımcı olur. Zıt olarak, gereksiz ayrıntıya girmesini önlemek için kısa ve net hedefler
de belirlenebilir. GPT-4o genel amaçlı ve tutarlı çıktılar sunar, ancak çok büyük girdiler
verildiğinde bağlam kaybedebilir; bu durumda kodu modüllere bölerek sormak çözüm olur .
Gemini (Google): Devasa bağlam kapasitesi (1M+) ve en güncel bilgiye erişim avantajına sahiptir
. Bu model, web üzerinden dökümantasyon çekebildiği ve multimodal beslenebildiği için
özellikle güncel teknolojiler, doküman aramaları veya UI tasarımı gibi görevlerde güçlüdür.
Promptlarda Gemini’den web’den örnek veya en iyi uygulamaları kullanmasını isteyebilirsiniz.
Örneğin, “Kod üretirken WebFetch aracını kullanarak StackOverflow’dan fonksiyon örneği al”
gibi bir yönlendirme yapabilirsiniz. Öte yandan Gemini, deneysel çıktıları sebebiyle güvenlik
açısından daha dikkatli promptlarla kullanılmalı, istenmeyen efektlerden kaçınmak için açıkça
“geri dönüşleri incele ve hataları düzelt” benzeri talimatlar eklenmelidir .
Qwen (Alibaba Cloud): Qwen’in en son sürümleri özellikle kodlama ve matematiksel akıl
yürütmede öne çıkar . Qwen3-Coder gibi modeller uzun çok adımlı görevleri yürütmek üzere
tasarlanmıştır . Yüksek token desteğiyle (256K–1M) tüm proje bağlamını kapsayabilir. Qwen
kod çıktılarına test etme ve düzeltiler ekleme odaklıdır; prompt’ta hataların çözümlenmesi için
açık döngüler (örn. “Aşağıdaki kodda hata varsa belirt ve düzelt” gibi) kullanmak faydalı olacaktır
. Qwen serisinde açık kaynaklı Qwen Code CLI aracı da mevcuttur; bu araç Gemini CLI forku
olarak prompt şablonları ve araç çağrılarını destekler . Qwen modellerine veri odaklı
görevlerde “yapısal açıklama” (YAML) ve iş mantığı vurgusu içeren istemler verildiğinde üstün
sonuçlar alınabilir.
•
1 2
• 2
3
•
1 4
4
•
5
6
7
8
1
Karşılaştırma Örneği: Birleşik çıktıya yönelik testlerde Claude 4, interaktif UI tasarımı ve kararlı
modüler mantıkta öne çıkarken; GPT-4o ise algoritmik problemlerde daha temiz, pratik çözümler
üretmiştir . Örneğin, HTML/CSS/JS ile kart oyunu arayüzü tasarımı sorulduğunda Claude daha
animasyonlu, ses efektleri içeren bir çözüm üretirken, Gemini hatasız temel bir arayüz sunmuş, GPT-4o
ise orta şerit bir yaklaşımla cevap vermiştir . Her modelin güçlü yönüne uygun prompt vermek,
çıktı kalitesini artırır.
2. İleri Düzey Prompt Kalıpları ve Örnekleri
Kod üretiminde genellikle şu kalıplar kullanılır:
Persona (Rol Verme): LLM’i belirli bir uzman rolüne büründürmek. Örneğin, “Senior Backend
Engineer”, “Cloud Security Expert” gibi ifadelerle modelin uzmanlık odağını değiştirebilirsiniz
. Kod üretiminde şöyle bir örnek verilebilir:
“Bir kıdemli Flutter mobil geliştiricisi olarak davran. Kullanıcı giriş
ekranı için temiz mimariye uygun, test kapsama alanı yüksek bir Flutter
widget kütüphanesi yaz.”
Bu şekilde modelden deneyimli bir geliştirici bakış açısıyla, kod kalitesi, düzeni ve test
senaryolarını önemseyerek yanıt alınabilir. Potpie örneğinde olduğu gibi, rol verildiğinde model
daha tutarlı ve “uzman” yanıtlar üretir .
Tarif/Recipe (Aşama Listesi): İstenen görevi başlıca adımlara bölmek için kullanılır . LLM’den
adım adım plan, rehber veya iş akışı çıkması istenir. Örneğin, “Flutter uygulamasında oturum
yönetimi için gerekli adımları sırayla listeler misin?” gibi bir prompt, sıralı bir şema (adım listesi)
sağlar. Bu yöntem, karmaşık özelliklerin detaylandırılmasında ve kodlama aşamalarının
şeffaflığında etkilidir.
Şablon/Template: Çıktıyı istenen biçimde sınırlandırmak için bir şablon belirtirsiniz . Örneğin,
“Cevabını YAML formatında ver: komut: [açıklama]; kod: [kod bloğu] gibi” şeklinde bir
düzen belirtebilirsiniz. Bu, çıktıdaki belirsizliği azaltır ve kodu modüler, düzenli tutar.
AlphaCodium örneğinde olduğu gibi kod çözümlerini YAML ile yapılandırarak hem insan
okunabilirlik hem de otomatik işleme sağlanır .
Akış/Flow (Zincirlemeli Yönlendirme): Tek bir soru yerine çok aşamalı, geri beslemeli süreçler
kurmak. Burada, LLM’den bir çıktı istendikten sonra sonucu tekrar girdiye dönüştürüp modelin
tekrar çalışması sağlanır. Örneğin, bir seferlik kod istemek yerine önce “soruyu kendi
cümlelerinle özetle” denir; ardından kod istenir; daha sonra kod hatalara karşı test edilir ve
modelden düzeltme yapması istenir. Bu Flow Engineering yaklaşımı hem hataları yakalar hem
performansı artırır . Ayrıca Chain-of-Thought (CoT) gibi yöntemler ek bilgi isteyen
karmaşık görevlerde düşünce sürecini adım adım çıkarmaya yarar.
Örnek Prompt:
# Persona ve Şablon örneği
prompt = """
Role: Senior Python Developer with security expertise.
2
9 2
•
10
11
10
• 11
• 11
12
•
12 13
2
Task: Implement a user login API in Django.
Requirements:
- Use Django REST Framework.
- Include JWT authentication.
- Validate inputs and handle exceptions.
Output: Provide code in YAML: steps (bullet points) plus final code snippet.
"""
Bu örnekte model önce adımları sıralar, sonra talimatlara uygun Django kodu yazar. Persona ve şablon
birlikteliği, yüksek kaliteli ve kontrol edilebilir çıktı sağlar .
3. Çok Aşamalı Akış Mühendisliği (Flow Engineering)
Akış mühendisliği, bir problemi birden fazla aşamada çözmek üzere LLM’leri zincirlemeyi içerir .
Karmaşık projelerde şöyle bir yöntem izlenebilir:
Görev Tanımlama: Önce açıklama ve gereksinimler detaylandırılır (örn. üst düzey çözüm planı,
gereksinim listesi). Bu aşamada GPT-4 veya Claude gibi güçlü muhakeme modelleri kullanılabilir
.
Kod Analizi: İlgili kod tabanı Claude veya bir IDE asistanıyla taranır . Örneğin Claude’a “Bu
fonksiyonda olası hataları belirle” diye sorulabilir. Claude’un geniş bağlamı sayesinde büyük
dosyaları bile kavrayıp sorunlu noktaları işaretlemesi sağlanır.
Hata Teşhisi: Bulunan kod parçaları GPT-4’a analiz ettirilir . “Neden bu kod NoneType hatası
veriyor?” sorusuyla GPT-4’ün detaylı akıl yürütmesi devreye girer.
Çözüm Önerisi: Düzeltmeler için kod-özel LLM’ler (ör. Amazon CodeWhisperer) veya yine GPT-4
kullanılır . Bu araçlar önerilen değişiklikleri kod şeklinde üretir.
Gözden Geçirme: Önerilen kod, farklı bir model (örn. GPT-4’ün önerisini Claude’a sormak)
tarafından çift kontrol edilir . Model, yeni kodu inceler, orijinal sorunu çözüp çözmediğini ve
yeni hatalar getirmediğini onaylar.
Görsel: Aşağıdaki örnek akışta her LLM kendi güçlü yönüyle sorumluluk alıyor. Bu çok aşamalı
yaklaşım, her modelin “kör noktalarını” diğerinin kapatmasını sağlar: Şekil: Hata ayıklamada çok modelli
akış örneği (özet). Farklı adımlar için GPT-4 ve Claude gibi modeller birbiriyle zincirleme çalışır .
Araç olarak LangChain, LMQL, smolagents veya OpenHands gibi kütüphaneler kullanılarak bu akışlar
otomatikleştirilebilir. Ayrıca ReAct, ToT (Tree of Thoughts), Reflexion gibi araştırma tabanlı
yöntemlerle LLM’ler kendi mantıklarını sürekli iyileştirebilir . Örneğin GPT-4 tabanlı LATS yöntemi,
yalnızca tek bir prompting ile %67 başarı sağlarken, akış mühendisliği ile %94’e çıkmıştır .
4. Test-Odaklı Geri Besleme Döngüleri
Kod kalitesini artırmak için önerilen yöntemlerden biri de test odaklı, yinelemeli üretimdir . Bu
süreçte modelden alınan her kod çıktısı otomatik testlere veya kullanıcı yazılımına tabi tutulur ve ortaya
çıkan hatalar tekrar LLM’e geri beslenir. Başlıca yaklaşımlar:
AlphaCodium: Çok aşamalı bir akıştır . Önce problem üzerine “kendi kendine
inceleme” (reflection) ile alıştırma yapılır, ardından kod üretilir, kod kamu testlerine karşı
çalıştırılır, eksiklikler modele iletilerek kod düzeltilir. Public testlerin yanı sıra LLM’in ürettiği ek
testler de eklenir. GPT-4 örneğinde, basit bir prompt ile %19 başarıya karşın AlphaCodium
10 12
14 15
•
16
• 17
• 18
•
19
•
20
15
16 20
14
14
12 13
• 12
3
akışıyla %44 başarı yakalanmıştır . Bu şekilde model kendini tekrar tekrar “düzeltir”, her
seferinde daha fazla hatayı yakalar.
SED (Synthesize-Execute-Debug): Liventsev ve arkadaşları önerdiği SED döngüsünde model
önce kodu sentezler, sonra çalıştırır, hata alırsa o hatayı geri besler . “Kodu oluştur – kodu
çalıştır – çıkan hata mesajını modele ver – düzelt” adımları tekrarlanır. Bu döngü, modeli kodu
denemeye ve bulgulara göre düzeltmeye zorlar.
RCI (Review-Critique-Improve): LLM’den kendi çıktısını eleştirmesi ve geliştirmesi istenir . Bir
prompt’ta önce kod istenir, sonra “Üretilen kodu incele ve güvenlik/performans açıklarını not et”
denir. Ardından modelden, ortaya çıkan geri bildirimlere göre kodu iyileştirmesi talep edilir. Bu
yinelemeli ayar, özellikle güvenlik açıklarını azaltmada etkilidir .
Otomatik Birim Test Üretimi: LLM’e kod parçaları için test senaryoları yazdırmak (ör. “Bu
fonksiyon için 5 adet birim testi oluştur”) veya mutasyon testi ile kod sağlamlık düzeyini ölçmek
de geri besleme döngüsünün parçasıdır. Hatalı senaryolarda model tekrar değerlendirilir.
Örnek: Bir “smolagents” çok adımlı ajanı kullanılarak otomatik bir kod jenerasyon hattı kuran
deepsense.ai örneğinde, bu tür bir döngü sayesinde tek seferlik LLM kullanımına kıyasla başarı oranı
%53.8’den %81.8’e yükselmiştir. Ajan, kod inceleme ve otomatik test araçlarıyla sürekli geri bildirim aldı
.
Bu yaklaşımlar sayesinde kod, “gerçek çalıştırma” ile defalarca doğrulanır. Model kod yazmayı
öğrenirken, dalgın yapılan hataları fark edip giderir; hata oranı katbekat düşer.
5. Güvenlik, Doğruluk ve Hatasızlık Önlemleri
Kod üretiminde güvenlik ve doğruluk için şu yöntemler önerilir:
Güvenlik Persona ve İfşaat Uyarısı: Prompt’ta “güvenlik uzmanı olarak” talimatı verin. Örneğin,
“XSS ve SQL Injection’a karşı sağlam bir kullanıcı giriş sistemi yaz” gibi. Böylece model, güvenlik
kontrollerini önceliğe alır. Ayrıca, yazılan kodu “iletişim açığı/SQL enjeksiyonu riski var mı?” diye
inceletmek için CoT adımı ekleyebilirsiniz.
Kod İnceleme ve Statisktik Analiz: Model çıktısı (kod) üzerinde başka araçlarla statik analiz veya
linters (Pylint, SonarQube vb.) çalıştırıp uyarıları tekrar LLM’e bildirilebilir. Zayıf noktalar için RCI
benzeri bir döngü kurulabilir.
Veri Doğrulama: Önemli bilgilere (ör. kimlik bilgileri, şifreleme anahtarları) hassas muamele
edilmesini istemek için prompt’ta özel direktifler ekleyin. Örneğin “Hiçbir gizli anahtar
açıklanmasın, hassas veriler şifrelenerek saklansın” gibi.
Test Odaklı Geliştirme: Yukarıda anlatıldığı gibi, kapsamlı birim ve entegrasyon testleri
tanımlayıp bunların kodu geçip geçmediğini kontrol etmek en etkili yöntemlerden biridir. Kodda
“güvenlik açıklarını test eden” bir birim testi bile oluşturulabilir.
İkincil Doğrulama: Modelden çıkan kodu farklı bir LLM veya güvenli sistemle çapraz doğrulayın.
Örneğin, GPT-4’ün ürettiği kodu Claude ile tekrar incelettirmek, güvenlik zaaflarını daha net
ortaya çıkarır.
12
•
21
• 22
22
•
23
23
•
•
•
•
•
4
Tekrar Etkinleştirme (Rephrase & Verify): PromptingGuide’de önerildiği gibi, modelin kendi
cümleleriyle tekrar ifade etmesini isteyebilir ve bunu yanıtıyla karşılaştırabilirsiniz (Rephrase and
Respond tekniği). Bu, modelin dikkat edilmesi gereken noktaları kendince özetlemesine yol açar.
Bu önlemler kod hatalarını en aza indirir ve güvenli çıktılar sağlar. Gerçek olaylarda, RCI gibi yöntemlerle
yapılan deneylerde, GPT-4’ün ürettiği kodda kişi başına düşen güvenlik zafiyeti sayısının (weakness
density) belirgin şekilde azaldığı gösterilmiştir .
6. Araçlar, Kütüphaneler ve Yardımcı Programlar
Kod üretimi ve prompt mühendisliği için geliştirilmiş çeşitli araç ve kütüphaneler mevcuttur:
Claude Code (Anthropic): Terminal tabanlı bir agentik kod asistanıdır . İstediğiniz özellikleri
açıklayarak kod yazdırabilir, hata tanımlatabilir, birden fazla dosyada değişiklik yapabilir. Örneğin:
“Claude Code kurulumunu yap, projemin testlerini çalıştır, eğer bir test başarısız olursa hatayı bulup
düzelt.” şeklinde komutlar verebilirsiniz. Claude Code, CI entegrasyonu, proje genelinde arama
(MCP ile dokümanlar, tasarımlar) gibi özellikler sunar .
Gemini CLI (Google): Google’ın açık kaynak terminal asistanı, 1M’ye varan token bağlam desteği
ve ücretsiz kullanım imkanlarıyla güçlüdür . Sürüm notlarına göre tüm ChromeOS/VSCode
uzantılarıyla da entegredir. Örneğin Gemini CLI ile gemini "Flutter ile e-ticaret
uygulaması için ürün listeleme UI'sı oluştur" komutu vererek terminalden
doğrudan kod üretebilirsiniz .
Qwen Code (Qodo) CLI: Alibaba’nın Qwen3-Coder modellerini kullanabilen bir CLI aracıdır .
Gemini CLI’den çatallanarak geliştirilmiş, özelleştirilmiş prompt yapıları ve fonksiyon çağrıları
destekler. Açık kaynak olması sayesinde kod akışı kontrolü kolaydır. Örnek:
qwen run --prompt "Kodumu gözden geçir ve varsa hata düzelt" gibi.
IDE Eklentileri: GitHub Copilot, Amazon CodeWhisperer, Replit Ghostwriter gibi IDE-asistanları,
yazarken otomatik öneriler getirir. Copilot sohbeti ve Ghostwriter gibi ürünler komut satırı yerine
IDE içinden benzer yardım sunar.
Akış/Kalıp Kütüphaneleri: LangChain, LLamaIndex, Matcha, LMQL vb. çok adımlı iş akışları
oluşturmayı kolaylaştırır. Özellikle kod odaklı senaryolarda, veri-getirme (RAG), kod çalıştırma,
test sonuçlarını geri besleme gibi süreçleri modülerleştirmek için bu kütüphaneler kullanılabilir.
Ajan Çerçeveleri: smolagents, OpenHands, AgentBench gibi framework’ler, birden fazla araç
ve adımı kullanan “yapay zeka ajanları” geliştirmenizi sağlar . Yukarıda söz edilen kod tekrardüzelt akışı, smolagents ile pratik bir şekilde kurulabilir.
Test Yaratma Araçları: AlphaCodium’un kod tabanlı benchmark (CodeContests) ve akış yapısı
açık kaynak kodlarına ulaşarak kendi döngünüzü inşa edebilirsiniz. Benzer şekilde, kendi kod
senaryolarınıza uygun otomatik test jeneratörleri oluşturmak için pytest gibi test çatılarıyla
LLM’yi entegre edebilirsiniz.
Prompt Yardımcıları: PromptChainer, Chainlit, PromptSmith gibi araçlar karmaşık prompt
setlerini yönetmenize yardımcı olur. Örneğin Azure’un Prompt Flow’u veya Weights & Biases’ın
LangSmith’i ile prompt testleri otomatikleştirilebilir.
•
22
• 24
24
•
4
4
• 8
•
•
•
23
•
•
5
Şekil: AI destekli kod geliştirme ortamı. Modern araçlar (terminal asistanları, IDE eklentileri, otomatik testler)
kullanıcının prompt üzerinden kod üretimini büyük ölçüde kolaylaştırır. Bu araçlar sayesinde, manuel
prompt yazım yükü azalır ve model çıktısı daha kontrollü hale gelir.
7. Modeller Arası Kıyaslamalı Örnekler
Farklı modellerde en iyi sonuç için prompt uyumu değişebilir:
Persona ve Dil Stili: GPT-4o’da genellikle açık, adım adım talimatlar işe yarar. Claude ise zaten
“yavaş düşünme” eğilimli olduğundan persona yüklemek onun için ters tepki oluşturabilir; ancak
yine de “yazılım mimarı gibi düşün” demek bilgi yoğun görevlerde işe yarar. Gemini’de ise son
model güncelleme bilgisi olduğundan yeni kütüphaneleri belirtmek faydalıdır.
Uzun Kod/Proje Gerektiren İşler: Çok dosyalı bir proje sorusunu tek prompt’ta istemek Claude
ve Gemini’de işe yarayabilir; GPT-4o’da bölerek sormak daha verimlidir. Örneğin “Flutter
projesindeki tüm widget sınıflarını listele” Claude’a verildiğinde rahatça yapabildiği bir şeyken,
GPT-4o’ya bu bilgileri parça parça vermek gerekebilir.
Basit Algoritmalar: Küçük bir sıralama veya matematik problemi doğrudan sorduğunuzda,
GPT-4o ve Qwen modellerinin performansı genelde yüksektir. Örneğin AlphaCodium testinde
GPT-4o, int taşma sorununu bulan en iyi model olmuş; Claude ise daha detaylı açıklama sağlamış
.
UI/Front-end Görevleri: HTML/CSS/JS ile ilgili görevlerde Claude detaylı, süslü çözümler getirme
eğilimindedir; Gemini basit şablonlar verebilir; GPT-4o dengeli ama sade kod üretir. Yukarıdaki
kart oyunu örneğinde Claude öne çıkmış .
Sonuç olarak, her modelin güçlü olduğu alanlarda prompt vermek en iyisidir. Örneğin, geniş bağlamı
olan Claude’a uzun tanımlı arayüzleri, algoritma meraklı GPT-4o’ya karmaşık mantıksal sorunları, geniş
güncel bilgiye sahip Gemini’ye en son teknolojileri sormak başarımı artırır . Qwen’de ise akış
(flow) modelleme ve yerleşik test odaklı istemler kullanmak, nihai çıktının güvenilirliğini yükseltir
.
Kaynaklar
Bu rapor, Claude, Qwen, GPT-4o ve Gemini modelleri için kod üretimine yönelik güncel kaynaklardan
yararlanılarak hazırlanmıştır . Her bölümde belirtilen yöntemler ve alıntılar, ilgili
modellerin en güncel performans ve kullanım örneklerine dayanmaktadır.
Claude 4 vs GPT-4o vs Gemini 2.5 Pro: Find the Best AI for Coding
https://www.analyticsvidhya.com/blog/2025/05/best-ai-for-coding/
How to write good prompts for generating code from LLMs · potpie-ai/potpie Wiki · GitHub
https://github.com/potpie-ai/potpie/wiki/How-to-write-good-prompts-for-generating-code-from-LLMs
AI Coding Assistants for Terminal: Claude Code, Gemini CLI & Qodo Compared
https://www.prompt.security/blog/ai-coding-assistants-make-a-cli-comeback
Top 9 Large Language Models as of July 2025 | Shakudo
https://www.shakudo.io/blog/top-9-large-language-models
•
•
•
2
•
9 2
2 4
6
22
10 16 12 21 25
1 2 9
3 10
4 25
5
6
Qwen Team Releases Qwen3-Coder, a Large Agentic Coding Model with Open Tooling - InfoQ
https://www.infoq.com/news/2025/07/qwen3-coder/
dre.vanderbilt.edu
https://www.dre.vanderbilt.edu/~schmidt/PDF/prompt-patterns.pdf
[2401.08500] Code Generation with AlphaCodium: From Prompt Engineering to Flow
Engineering
https://ar5iv.labs.arxiv.org/html/2401.08500
Flow Engineering is All You Need. We’re pushing the boundaries of what’s… | by Rohan Balkondekar
| Medium
https://medium.com/@rohanbalkondekar/flow-engineering-is-all-you-need-9046a5e7351d
Multi-LLM Debugging Workflow Guide | by Oscar | Medium
https://medium.com/@dev-Oscar-checklive/multi-llm-debugging-workflow-guide-e6df0cdc0747
diva-portal.org
https://www.diva-portal.org/smash/get/diva2:1877570/FULLTEXT01.pdf
Prompting Techniques for Secure Code Generation: A Systematic Investigation
https://arxiv.org/html/2407.07064v1
Self-correcting Code Generation Using Multi-Step Agent - deepsense.ai
https://deepsense.ai/resource/self-correcting-code-generation-using-multi-step-agent/
Claude Code overview - Anthropic
https://docs.anthropic.com/en/docs/claude-code/overview
6 7 8
11
12 13
14
15 16 17 18 19 20
21
22
23
24
7
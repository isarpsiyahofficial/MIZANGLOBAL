# LEFFERION PRIME - MIZAN 250+ Madde Kontrol Dokümanı

Bu doküman, ana 240 maddelik şartnameye eklenen yeni gider kategori ve not gereksinimleriyle birlikte uygulama kontrol listesini takip etmek için kullanılır. Maddeler tek tek doğrulanabilir olmalıdır.

## Çekirdek Kapsam

001. Flutter APK projesi olacak.
002. İlk aşamada imzasız release APK yeterli olacak.
003. GitHub Actions üzerinden build alınabilecek.
004. Uygulama adı `LEFFERION PRIME - MIZAN` olacak.
005. Lefferion Prime logosu kullanılacak.
006. Logo şeffaf PNG kaynağından gelecek.
007. Logo responsive yerleşecek.
008. Logo taşmayacak.
009. Logo kesilmeyecek.
010. Logo HD kalitede kullanılacak.
011. Uygulama local veri mantığıyla çalışacak.
012. Uygulama internete bağımlı olmayacak.
013. Veriler cihaz içinde saklanacak.
014. Ağır animasyon kullanılmayacak.
015. RAM tüketimini artıracak gereksiz görsel efektlerden kaçınılacak.
016. Kart tabanlı responsive arayüz kullanılacak.
017. Küçük ekranda tablo kullanılmayacak.
018. Büyük ekranda kartlar yan yana dizilebilecek.
019. SafeArea kullanılacak.
020. Scroll olmayan sıkışık ekran bırakılmayacak.

## Banka ve Borç Kuralları

021. Banka isimleri hazır liste olarak gelmeyecek.
022. Gerçek banka marka adı örneği sabit yazılmayacak.
023. Kullanıcı banka adını kendisi yazacak.
024. Banka adı maksimum 100 karakter olacak.
025. Uzun banka adı taşmadan kırılacak.
026. Banka logosu kullanılmayacak.
027. Bankalarla resmi bağlantı varmış gibi gösterilmeyecek.
028. Aynı kişinin aynı banka adı altında birden fazla borç ürünü olabilecek.
029. Banka toplamı alt ürünlerden hesaplanacak.
030. Borç ürünü ödemesi başka ürünü etkilemeyecek.
031. KMH hesabı ayrı ürün olarak tutulacak.
032. Kredi kartı ayrı ürün olarak tutulacak.
033. Kredi ayrı ürün olarak tutulacak.
034. Araç kredisi ayrı tür seçilebilecek.
035. Ev kredisi ayrı tür seçilebilecek.
036. Nakit avans ayrı tür seçilebilecek.
037. Taksitli nakit avans ayrı tür seçilebilecek.
038. Özel borç türü eklenebilecek.
039. Her borçta toplam borç olacak.
040. Her borçta ödenen miktar hesaplanacak.
041. Her borçta kalan borç otomatik hesaplanacak.
042. Her borçta aylık tutar olacak.
043. Her borçta son ödeme tarihi olacak.
044. Her borçta durum hesaplanacak.
045. Aktif durum etiketi olacak.
046. Yaklaşan ödeme etiketi olacak.
047. Gecikmede etiketi olacak.
048. Tamamlandı etiketi olacak.
049. Pasif etiketi olacak.
050. Durum sadece renkle anlatılmayacak.
051. Durum yazıyla da gösterilecek.
052. Kısmi ödeme yapılabilecek.
053. Kısmi ödeme kalan tutarı azaltacak.
054. Kalan varsa bildirim devam edecek.
055. Tam ödeme ilgili kaydı tamamlandı yapacak.
056. Borç ödeme geçmişi kendi ürününde kalacak.
057. Genel geçmiş olsa bile kaynak kayıt bağı korunacak.
058. Tamamlanan borç arşivlenebilecek.
059. Tamamlanan borç geçmişi silinmeyecek.
060. Yanlış veri sonradan düzeltilebilecek.

## Kişi, Fatura, Kira ve Taksit

061. Birden fazla kişi oluşturulabilecek.
062. Her kişinin ödeme alanı ayrı olacak.
063. Kişi toplam borcu görülecek.
064. Kişi aylık ödeme yükü görülecek.
065. Kişi gecikmiş kayıt sayısı görülecek.
066. Seçili kişiler birlikte raporlanabilecek.
067. Faturalar ayrı kayıt tipi olacak.
068. Elektrik faturası desteklenecek.
069. Su faturası desteklenecek.
070. Telefon faturası desteklenecek.
071. İnternet faturası desteklenecek.
072. Özel fatura desteklenecek.
073. Faturada kurum adı olacak.
074. Faturada abone numarası olacak.
075. Faturada tesisat/sözleşme numarası olacak.
076. Faturada tutar olacak.
077. Faturada son ödeme tarihi olacak.
078. Fatura durumu hesaplanacak.
079. Fatura ödeme geçmişi kendi kaydında kalacak.
080. Kira ayrı kayıt tipi olacak.
081. Kirada tutar olacak.
082. Kirada ödeme günü olacak.
083. Kirada alıcı adı olacak.
084. Kirada IBAN olacak.
085. Kirada sözleşme başlangıcı tutulabilecek.
086. Kirada sözleşme bitişi tutulabilecek.
087. Kirada artış tarihi tutulabilecek.
088. Kira ödeme geçmişi kendi kaydında kalacak.
089. Taksit mantığı borç/kira alanında izlenebilecek.
090. Fatura/kira/taksit gider toplamına karışmayacak.

## Gider ve Kategori Kuralları

091. Giderler ayrı modül olacak.
092. Giderler borç toplamına karışmayacak.
093. Giderler fatura toplamına karışmayacak.
094. Giderler kira toplamına karışmayacak.
095. Giderler kalem kalem girilebilecek.
096. Giderlerde kategori olacak.
097. Kullanıcı gider kategorisi oluşturabilecek.
098. Kullanıcı kategori adını kendi belirleyecek.
099. Kategori adı düzenlenebilecek.
100. Kategori silinebilecek.
101. Kategori silme tehlikeli işlem sayılacak.
102. Kategori silmek için tam olarak `ONAYLIYORUM` yazılacak.
103. Onay metni yanlışsa silme yapılmayacak.
104. Kategori içinde kaç harcama olduğu gösterilecek.
105. Kategori yanında toplam tutar gösterilecek.
106. Kategori içinde detayları göster alanı olacak.
107. Kategori detayında harcamalar listelenecek.
108. Harcama ürün adı tutulacak.
109. Harcama adet tutulacak.
110. Harcama birim fiyat tutulacak.
111. Harcama toplamı otomatik hesaplanacak.
112. Harcama notu tutulabilecek.
113. Harcama tarihi tutulacak.
114. Günlük gider toplamı hesaplanacak.
115. Aylık gider toplamı hesaplanacak.
116. Ay değişince aktif ay yeni toplamla başlayacak.
117. Eski ay gideri geçmişte korunacak.
118. Son 30 gün filtre mantığı desteklenecek.
119. Son 60 gün filtre mantığı desteklenecek.
120. Son 90 gün filtre mantığı desteklenecek.
121. Ay/yıl filtre mantığı desteklenecek.
122. Gider silinirse toplam yeniden hesaplanacak.
123. Kategori silinirse kategoriye bağlı veri riski kullanıcıya gösterilecek.
124. Gider kategori ekranı kartları şişirmeyecek.
125. Kategori detayları açılır kapanır yapıda olacak.

## Not Sistemi

126. Her banka borç ürünü detayında not ekle olacak.
127. Her fatura detayında not ekle olacak.
128. Her kira/taksit detayında not ekle olacak.
129. Notlar ödeme notlarından ayrı tutulacak.
130. Notlar fazla yer kaplamayacak.
131. Notlar ayrı bir kompakt alanda gösterilecek.
132. Kartlarda uzun notlar sürekli açık durmayacak.
133. Detayda son notlar kısa görünecek.
134. Fazla notlar saklı bilgi olarak kalacak.
135. Not metni boş kaydedilmeyecek.
136. Not karakter sınırı olacak.
137. Not tarihi tutulacak.
138. Notlar kaynak kayda bağlı kalacak.
139. Borç notu fatura altında görünmeyecek.
140. Fatura notu kira altında görünmeyecek.
141. Kira notu banka borcu altında görünmeyecek.
142. Not ekleme diğer modül verisini bozmayacak.
143. Notlar local veriye kaydedilecek.
144. Not alanı responsive olacak.
145. Not alanı klavye açılınca bozulmayacak.

## Bildirimler

146. Gider bildirimi ayrı sistem olacak.
147. Gider bildirimi ödeme bildirimiyle karışmayacak.
148. Sabah gider bildirimi olacak.
149. Öğlen gider bildirimi olacak.
150. Akşam gider bildirimi olacak.
151. Sabah varsayılan 07:00 olacak.
152. Öğlen varsayılan 12:00 olacak.
153. Akşam varsayılan 21:00 olacak.
154. Her gider bildirimi aç/kapat yapılabilecek.
155. Her gider bildirimi metni düzenlenebilecek.
156. Ödeme bildirimi son tarihten 5 gün önce başlayacak.
157. Ödeme bildirimi son ödeme günü dahil takip edecek.
158. Gecikme sonrası 5 gün daha takip edecek.
159. Bu aralıkta günde 2 bildirim mantığı olacak.
160. Ödeme bildirimi kayıt bazlı olacak.
161. Bir ödeme diğer bildirimi susturmayacak.
162. Ödeme işaretlenmezse bildirim devam edecek.
163. Bildirim izni istenecek.
164. Varsayılan telefon bildirim sesi kullanılacak.
165. Pil optimizasyonu uyarısı olacak.
166. Telefon yeniden başlarsa bildirim tekrar planlanacak.
167. Bildirimler ayarlardan kapatılabilecek.
168. Bildirim kaçırmamak için kayıt bazlı motor tasarlanacak.
169. Bildirim durumu ekranda anlaşılır gösterilecek.
170. Bildirim ayarları veriye karışmayacak.

## Arama, Filtre ve Rapor

171. Arama olacak.
172. Kişi filtresi olacak.
173. Ay filtresi olacak.
174. Gider kategorisi filtresi olacak.
175. Borç türü filtresi olacak.
176. Gecikmede filtresi olacak.
177. Yaklaşan ödeme filtresi olacak.
178. Raporlarda kişi toplamı olacak.
179. Raporlarda banka adı toplamı olacak.
180. Raporlarda borç türü toplamı olacak.
181. Raporlarda fatura toplamı olacak.
182. Raporlarda kira/taksit toplamı olacak.
183. Raporlarda gider kategori toplamı olacak.
184. Raporlarda aylık gider toplamı olacak.
185. Raporlar kart ve bar yapısıyla gösterilecek.
186. Raporlarda yazılar taşmayacak.
187. Raporlarda renk ve yazı birlikte kullanılacak.
188. PDF/CSV dışa aktarma opsiyonel değerlendirilecek.
189. Yedekleme opsiyonel değerlendirilecek.
190. PIN/şifre opsiyonel değerlendirilecek.

## Form, Validasyon ve Responsive

191. Tüm zorunlu alanlar boş geçilemeyecek.
192. Tutar alanları sayı/para formatı alacak.
193. Tarih alanları date picker ile seçilecek.
194. Saat alanları time picker ile seçilecek.
195. Yanlış veri girişinde net uyarı olacak.
196. Uzun açıklamalar satır kıracak.
197. Klavye açıldığında ekran scroll olacak.
198. Alt menü taşmayacak.
199. Tablet görünümü desteklenecek.
200. Yatay ekran desteklenecek.
201. Font büyütme düzeni bozmamalı.
202. Kartlar iç içe gereksiz kullanılmayacak.
203. Butonlar ekran dışına taşmayacak.
204. Liste satırları sağa sola kaymayacak.
205. Hizalama profesyonel olacak.
206. Yazılar kart ortasında anlamsız kalmayacak.
207. Değerler okunur hizalanacak.
208. Detay ekranları bottom sheet veya ayrı sayfa olarak düzenli olacak.
209. Notlar detay alanında kompakt duracak.
210. Silme işlemleri yanlış dokunmayla yapılmayacak.

## Veri Güvenliği ve Ayrışma

211. Hiçbir modül başka modülün verisini sıfırlamayacak.
212. Kişi güncellenirken fatura/kira korunacak.
213. Borç ödemesi giderleri etkilemeyecek.
214. Gider ekleme borçları etkilemeyecek.
215. Kategori işlemi kişi borçlarını etkilemeyecek.
216. Not ekleme ödeme geçmişini bozmayacak.
217. Ödeme geçmişi kaynak kayda bağlı kalacak.
218. Local JSON bozulursa sağlam yedekten kurtarma yolu olacak; örnek veri yazılmayacak.
219. Veri kaydı atomik mantıkla yapılacak.
220. Aynı isimli kategori uyarı verecek.
221. Aynı banka adı tekrarında kullanıcı uyarılabilecek.
222. Karakter sınırları uygulanacak.
223. Banka adı 100 karakteri aşmayacak.
224. Kategori adı 60 karakteri aşmayacak.
225. Not 240 karakteri aşmayacak.

## Build ve Teslim

226. `flutter pub get` çalışacak.
227. `flutter analyze` çalışacak.
228. `flutter test` çalışacak.
229. Release APK build alınacak.
230. APK artifact olarak yüklenecek.
231. Launcher icon üretilecek.
232. Android uygulama adı doğru uygulanacak.
233. GitHub Actions manuel çalıştırılabilecek.
234. Ana branch push ile build tetiklenecek.
235. Testler hesaplama doğruluğunu kontrol edecek.
236. Testler kategori toplamını kontrol edecek.
237. Testler banka marka adının sabit gelmediğini kontrol edecek.
238. Testler notların kaynak kayda bağlı olduğunu kontrol edecek.
239. Testler kategori silme onay şartını kontrol edecek.
240. Testler veri modüllerinin birbirini silmediğini kontrol edecek.

## Kabul Kontrolü

241. Ana panel kritik ödemeleri gösterecek.
242. Ana panel fatura/kira yaklaşanlarını da gösterecek.
243. Kişiler ekranı kişi bazlı özet gösterecek.
244. Banka grubu kullanıcı yazımı olduğunu belirtecek.
245. Fatura detayında not eklenebilecek.
246. Kira detayında not eklenebilecek.
247. Banka borç detayında not eklenebilecek.
248. Gider ekranı kategori toplamlarını gösterecek.
249. Gider detayları kategori altında görünecek.
250. Kategori silme onayı `ONAYLIYORUM` dışında çalışmayacak.
251. Rapor ekranı fatura ve kira/taksit toplamlarını gösterecek.
252. Ayarlar ekranı bildirim saatlerini gösterecek.
253. Uygulama görsel olarak sade, hizalı ve profesyonel olacak.
254. Uygulama düşük RAM hedefiyle basit widget ağacı kullanacak.
255. Repo içinde kalite kontrol dokümanı bulunacak.
256. Repo içinde otomatik smoke validation scripti bulunacak.
257. v93 zip yalnızca logo kaynağı olarak kullanılacak.
258. v93 site yapısı Mizan uygulamasına karıştırılmayacak.
259. Kullanıcı cevap vermese de batch akışı sürdürülebilecek.
260. Nihai kabul: responsive, taşmasız, doğru hesaplayan, kayıtları karıştırmayan, bildirimleri doğru çalışan APK.


## Sade Bilgi Mimarisi ve Genişletilmiş Kayıtlar

261. İlk kurulum hiçbir örnek kişi, borç, ödeme, fatura, kira, abonelik veya gider içermeyecek.
262. Ana sayfadaki Kalan toplam borç kartı dokunulabilir olacak.
263. Kalan toplam borç detayı beş ana kayıt grubunu ayrı gösterecek.
264. Kritik ödeme satırı ilgili kaydın gerçek detay ekranını açacak.
265. Kayıtlar ekranında önce aktif kişi açık biçimde seçilecek.
266. Banka Borçları ayrı bölüm olacak.
267. Kişisel ve Kurumsal Borçlar ayrı bölüm olacak.
268. Faturalar ayrı bölüm olacak.
269. Abonelikler ayrı bölüm olacak.
270. Kira ve Taksitler ayrı bölüm olacak.
271. Kişisel ve Kurumsal Borçlarda alacaklı türü seçilebilecek.
272. Alacaklı türlerinde kişi, şirket/kurum, çek, senet, esnaf/işletme, aile/yakın ve diğer bulunacak.
273. Çek kaydı çek numarası, düzenleyen ve kullanıcı girişli banka bilgisi taşıyabilecek.
274. Senet kaydı senet numarası, senet adedi ve ayrı ödeme planı satırları taşıyabilecek.
275. Her yeni kayıt türü kendi ödeme, not, arşiv ve bildirim ilişkisini koruyacak.
276. Bildirim planlaması hiçbir koşulda gerçekleşmiş ödeme kaydı oluşturmayacak.
277. Bildirim saatleri cihazın yerel saat diliminde saat ve dakika bileşenleriyle planlanacak.
278. Pil optimizasyonu ayarına yönlendiren buton bulunmayacak.
279. Tüm veriyi örnek kayıtlarla sıfırlayan buton bulunmayacak.
280. Tüm kayıtlar ilişkileri ve benzersiz kimlikleri korunarak CSV olarak dışa ve içe aktarılabilecek.
281. CSV geri yükleme onay verilmeden mevcut state üzerinde değişiklik yapmayacak.
282. Bildirim servisindeki hata yerel veri dosyasının yüklenmesini engellemeyecek.
283. Ana ve yedek kayıt dosyaları okunamazsa yeni veri yazımı mevcut dosyaları korumak için durdurulacak.
284. Her kullanıcı işlemi doğrulama sonrası anında yerel dosyaya kaydedilecek.
285. Raporlar ekranı ilk bakışta kalan, gecikmiş, yaklaşan ve gider toplamlarını sade gösterecek.
286. Giderler ekranı bugün, bu ay, kategori ve kayıt listesi ayrımını anlaşılır gösterecek.
287. Dar telefon, büyük yazı ve tablet görünümü yeni kayıt bölümleriyle tekrar test edilecek.
288. İlk kurulum boş ekranları ve dolu kullanım ekranları ayrı gerçek Flutter renderlarıyla denetlenecek.
289. Kişi düzenleme ve silme işlemleri ana özet kartında dağınık durmayacak, Kişi detayları alanında bulunacak.
290. Kişi detayları seçili kişiye bağlı banka, kişisel/kurumsal, fatura, abonelik ve kira/taksit kayıtlarını birlikte gösterecek.
291. Giderler ve Raporlar ekranlarında cihazda gri blok oluşturan iç içe ExpansionTile yapıları kullanılmayacak.
292. Banka borcu eklerken ödeme tarihi yöntemi Son ödeme tarihi veya Her ayın belirli günü olarak seçilebilecek.
293. Her ayın belirli günü seçeneği 1 ile 31 arasında doğrulanacak ve aylık tutar zorunlu olacak.
294. Eski banka borcu kayıtları veri kaybı olmadan Son ödeme tarihi yöntemiyle açılacak.
295. Önümüzdeki 7 gün, gecikmiş ve yaklaşan tutarlar toplam kalan borcu değil sıradaki vade/taksit tutarını kullanacak.
296. Raporlar seçili ayda gerçekleşen banka borcu ödemelerini ayrı toplam gösterecek.
297. Raporlar kişisel/kurumsal borç, fatura, abonelik ve kira/taksit ödemelerini ayrı toplam gösterecek.
298. Giderler ödeme geçmişi toplamlarına karıştırılmayacak ve kendi kategori dağılımında kalacak.
299. Bu ay gerçekleşen toplam ödeme-gider raporu, gerçekleşen tüm ödeme türleri ile Giderler toplamının birleşimini gösterecek.
300. Yeni kişi detayları, tarih yöntemi, vade tutarı ve gerçekleşen ödeme raporları otomatik test ve gerçek Flutter renderlarıyla doğrulanacak.

## Ödeme Türleri, Bildirim Tercihleri ve Ayrıntılı PDF Raporları

301. Ödeme ekleme penceresi kalan borcun tamamını varsayılan ödeme tutarı olarak göstermeyecek.
302. Ödeme ekleme penceresinde Taksit ödemesi, Borç kapama ve Kısmi ödeme seçenekleri bulunacak.
303. Taksit ödemesi seçildiğinde sıradaki taksit veya dönem tutarı otomatik hesaplanacak.
304. Borç kapama seçildiğinde gerçek kalan borç tutarı otomatik hesaplanacak.
305. Kısmi ödeme seçildiğinde tutar kullanıcı tarafından girilecek ve kalan borcu aşamayacak.
306. Seçilen ödeme türü ödeme geçmişinde, CSV yedeğinde ve raporlarda korunacak.
307. Taksitli kayıtlarda kullanıcıdan ödenen taksit sayısı istenmeyecek; opsiyonel kalan taksit sayısı gösterilecek.
308. Taksit ödemesi kaydedildiğinde kalan taksit sayısı otomatik azalacak.
309. Toplam ve kalan taksit sayıları birbirinden türetilecek; ödenen taksit sayısı kullanıcı arayüzünde gösterilmeyecek.
310. Her ayın belirli günü seçilen kayıtlar seçilen aylık gün üzerinden bildirim planına dahil edilecek.
311. Ödeme bildirimleri kullanıcı tarafından 1 ile 10 arasında ayrı saatler olarak eklenip düzenlenebilecek.
312. Bildirim sesi cihazın varsayılan sesi veya sessiz olarak seçilebilecek.
313. Bildirim ayarları büyük ve anlamsız sayaç kartları yerine sade, profesyonel ve açıklamalı bir merkezde gösterilecek.
314. Rapor dönemi Günlük olarak seçilebilecek.
315. Rapor dönemi Haftalık olarak seçilebilecek ve hafta pazartesi-pazar aralığında hesaplanacak.
316. Rapor dönemi Aylık olarak seçilebilecek.
317. Rapor dönemi Yıllık olarak seçilebilecek; güncel yıl tamamlanmadıysa 1 Ocak ile bugün arasını kapsayacak.
318. Rapor dönemi Tüm zamanlar olarak seçilebilecek ve başlangıçtan bugüne bütün hareketleri kapsayacak.
319. Rapor kişi kapsamı tüm kişiler veya aynı anda seçilebilen belirli kişiler olarak ayarlanabilecek.
320. Gerçekleşen banka, kişisel/kurumsal, fatura, abonelik ve kira/taksit ödemeleri ayrı ayrı toplamlanacak.
321. Giderler gerçekleşen ödeme kayıtlarına karıştırılmayacak ve kendi kategori toplamlarında kalacak.
322. Gerçekleşen toplam ödeme-gider raporu ödeme türleri toplamı ile gider toplamını ayrıca gösterecek.
323. Kalan ödeme yükünün dağılımı seçili döneme düşen gerçek taksit/dönem tutarlarıyla ayrıntılı gösterilecek.
324. Gider dağılımı seçili dönemde nereye, hangi tarihte ve ne kadar harcandığını ayrıntılı gösterecek.
325. Kişi bazında kalan borç raporu taksit tutarını değil her kaydın gerçek kalan bakiyesini gösterecek.
326. Ekrandaki rapor ve PDF raporu aynı MizanReport veri nesnesinden üretilecek.
327. Her rapor dönemi PDF olarak cihaz dosyalarına kaydedilebilecek.
328. Her rapor dönemi Android paylaşım menüsü üzerinden paylaşılabilecek.
329. PDF paylaşımı WhatsApp gibi cihazda kurulu uygun uygulamalara gönderilebilecek.
330. PDF sayfalarında metin, tablo ve tutar kayması veya taşması olmayacak.
331. PDF ayrıntıları sayfa sınırına ulaştığında otomatik olarak yeni sayfada devam edecek.
332. PDF içinde farklı kişilerin, kayıt türlerinin, ödemelerin veya giderlerin verileri birbirine karışmayacak.
333. PDF gerçekleşen ödeme ayrıntılarında kişi, kayıt türü, kayıt adı, ödeme türü, tarih ve tutarı gösterecek.
334. PDF gider ayrıntılarında kategori, gider adı, tarih, miktar, birim fiyat, toplam ve notu gösterecek.
335. Tüm zamanlar PDF’i bütün ödeme geçmişini, bütün giderleri ve güncel kalan borçları ayrıntılı sunacak.
336. PDF üretimi geçerli PDF başlığı, çok sayfalı içerik ve taşmasız render testleriyle doğrulanacak.
337. Bildirim sıklığı veya ses tercihi değişikliği hiçbir şekilde ödeme kaydı oluşturmayacak.
338. Ödeme, taksit, bildirim, rapor, PDF, CSV ve yerel kayıt ilişkileri birlikte bütünlük testinden geçecek.
339. Analyzer, şartname kontrolü, bütün testler, görsel render ve release APK aynı commit üzerinde geçmeden teslim yapılmayacak.
340. Bu revizyon mevcut çalışan kişi, borç, fatura, abonelik, kira, gider, not, arşiv ve CSV özelliklerini kaldırmayacak veya bozmayacak.


## Gelir, Kayıtlı Aylar ve Gelişmiş Dönem Takibi

341. Her ayın belirli günü seçilerek yeni oluşturulan banka borcunun ilk vadesi kayıt ayı değil bir sonraki ay olacak.
342. Ayın 29, 30 veya 31. günü seçildiğinde kısa aylarda o ayın son geçerli günü kullanılacak.
343. Aylık borcun ilk vade tarihi sonraki hesaplamalarda sabit dönem başlangıcı olarak korunacak.
344. Gecikmiş aylık borçlarda ödenmemiş bütün dönemler ay ay listelenecek.
345. Haziran ve Temmuz dönemleri ödenmemişse yalnız Temmuz değil Haziran ve Temmuz birlikte gösterilecek.
346. Taksit ödemesi en eski ödenmemiş döneme bağlanacak.
347. Kısmi ödeme seçilen dönemin kalan tutarını azaltacak ancak tamamlanmayan dönemi kapatmayacak.
348. Yeni ödeme bildirim saati ekleme limiti en az 1 ve en fazla 10 olacak.
349. Her ödeme bildirim saatinin saat, dakika, açık-kapalı durumu ve mesajı ayrı düzenlenebilecek.
350. Ödeme bildirim saatleri CSV ve yerel JSON yedeğinde kimlikleriyle korunacak.
351. Gelir bilgisi tamamen opsiyonel olacak.
352. Kullanıcı gelir türü veya adını serbest metin olarak girebilecek.
353. Gelir sıklığı tek seferlik, günlük, haftalık veya aylık seçilebilecek.
354. Her gelir kaydı tutar, başlangıç tarihi, not ve arşiv durumu taşıyacak.
355. Gelir kayıtları her değişiklikten sonra anında yerel dosyaya kaydedilecek.
356. Gelir kayıtları CSV dışa aktarma ve geri yüklemede eksiksiz korunacak.
357. Ana sayfanın en üstünde gelir özeti yer alacak.
358. Gelir girilmemişse ana sayfa ve raporlar Gelir bilgisi belirtilmemiş mesajını gösterecek.
359. Gelir girilmişse ana sayfa bu ay gelir, ödemeler sonrası kalan ve ödeme-gider sonrası net tutarı gösterecek.
360. Raporlar seçili dönemde gelir toplamını, ödeme toplamını, gider toplamını ve son net bakiyeyi ayrı gösterecek.
361. Gelir, borç ödemesi ve gider kayıtları birbirine dönüştürülmeden ayrı veri türleri olarak saklanacak.
362. Aylık rapor seçiminde gün seçici açılmayacak; ay seçimi yapılacak.
363. Aylık rapor listesinde yalnız uygulamada gerçek kayıt bulunan aylar gösterilecek.
364. Kayıt bulunmayan eski veya gelecek aylar aylık seçim listesine yapay olarak eklenmeyecek.
365. Kalan taksit sayısı raporda gösterilecek; ödenen taksit sayısı raporda ve kayıt detayında gösterilmeyecek.
366. Gelir, aylık dönemler ve özel bildirim saatleri eski kayıtları kaybetmeden şema sürümü yükseltilerek eklenecek.
367. Gelir ve yeni bildirim alanları bulunmayan eski JSON kayıtları varsayılan güvenli değerlerle açılacak.
368. Gelir hesapları günlük, haftalık, aylık ve tek seferlik sınır tarihleriyle otomatik test edilecek.
369. Kayıtlı ay listesi yalnız gerçek ödeme, gider, gelir veya vade verilerinden türetildiğini test edecek.
370. Gelir ve dönem revizyonu analyzer, bütün testler, responsive render, PDF, CSV ve release APK aynı commit üzerinde geçmeden teslim edilmeyecek.

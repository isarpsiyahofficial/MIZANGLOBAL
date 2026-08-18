const Map<String, String> mizanPersianValidation = <String, String>{
  'Her değişiklik cihazda anında kaydedilir; sağlam kayıt doğrulanmadan üzerine yazılmaz.':
      'هر تغییر بلافاصله روی دستگاه ذخیره می‌شود و تا اعتبارسنجی رکورد سالم، داده قبلی بازنویسی نمی‌شود.',
  'Kişiler, borçlar, faturalar, abonelikler, ödemeler, notlar, gelirler ve giderler her işlemden sonra cihazdaki dosyaya yazılır.':
      'اطلاعات اشخاص، بدهی‌ها، قبض‌ها، اشتراک‌ها، پرداخت‌ها، یادداشت‌ها، درآمدها و هزینه‌ها پس از هر عملیات در فایل دستگاه نوشته می‌شود.',
  'Yeni kayıt doğrulandıktan sonra ana dosya değiştirilir; son sağlam kopya ayrıca korunur.':
      'فایل اصلی فقط پس از اعتبارسنجی رکورد جدید جایگزین می‌شود و آخرین نسخه سالم جداگانه حفظ می‌شود.',
  'Yedek içe aktarılırken mevcut kayıtlar silinmez. Ortak kayıtlar atlanır, yalnız yeni kayıtlar ve eksik ilişkiler eklenir.':
      'هنگام درون‌ریزی نسخه پشتیبان، رکوردهای موجود حذف نمی‌شوند. رکوردهای مشترک نادیده گرفته می‌شوند و فقط رکوردهای جدید و ارتباط‌های ناقص افزوده می‌شوند.',
  'Kişi, banka, borç, ödeme, not, kategori, gider, gelir ve bildirim saatleri kendi kimlik ve bağlantılarıyla aktarılır. Aynı kayıt ikinci kez yazılmaz.':
      'اشخاص، بانک‌ها، بدهی‌ها، پرداخت‌ها، یادداشت‌ها، دسته‌ها، هزینه‌ها، درآمدها و زمان اعلان با شناسه و ارتباط خود منتقل می‌شوند. یک رکورد دوبار نوشته نمی‌شود.',
  'Uygulama dili seçilmelidir.': 'باید زبان برنامه انتخاب شود.',
  'Ülke kodu geçersiz.': 'کد کشور نامعتبر است.',
  'Para birimi kodu geçersiz.': 'کد واحد پول نامعتبر است.',
  'Tamamlanmış profilde uygulama dili eksik.':
      'زبان برنامه در نمایه تکمیل‌شده وجود ندارد.',
  'Tamamlanmış profilde ülke kodu geçersiz.':
      'کد کشور در نمایه تکمیل‌شده نامعتبر است.',
  'Tamamlanmış profilde para birimi kodu geçersiz.':
      'کد واحد پول در نمایه تکمیل‌شده نامعتبر است.',
  'Global katalog henüz yüklenmedi.': 'فهرست جهانی هنوز بارگذاری نشده است.',
  'Global katalog sayıları doğrulanamadı.':
      'تعداد عناصر فهرست جهانی اعتبارسنجی نشد.',
  'Bildirim izni veya zamanlama servisi açılamadı:':
      'مجوز اعلان یا سرویس زمان‌بندی باز نشد:',
  'Yerel kayıt alanı güvenli biçimde açılamadı. Mevcut dosyaları korumak için yeni veri yazımı durduruldu.':
      'فضای ذخیره‌سازی محلی به‌صورت امن باز نشد. برای حفاظت از فایل‌های موجود، نوشتن داده جدید متوقف شد.',
  'Bildirim izni kapalı. Android izni açıldığında MİZAN otomatik olarak yeniden senkronize eder.':
      'مجوز اعلان خاموش است. پس از دادن مجوز Android، MİZAN به‌صورت خودکار دوباره همگام می‌شود.',
  'Dakik bildirim izni kapalı. Android izni açıldığında MİZAN otomatik olarak yeniden senkronize eder.':
      'مجوز زمان‌بندی دقیق خاموش است. یادآوری‌ها به‌صورت تقریبی برنامه‌ریزی می‌شوند و پس از اعطای مجوز Android، MİZAN خودکار زمان‌بندی دقیق را بازمی‌گرداند.',
  'Kayıt yapıldı ancak bildirimler otomatik senkronize edilemedi:':
      'رکورد ذخیره شد اما اعلان‌ها خودکار همگام نشدند:',
  'Kişi adı': 'نام شخص',
  'Banka adı': 'نام بانک',
  'Toplam borç': 'مجموع بدهی',
  'Aylık tutar': 'مبلغ ماهانه',
  'Gecikme günü': 'تعداد روز تأخیر',
  'Limit': 'سقف',
  'Kullanılan limit': 'مبلغ استفاده‌شده از سقف',
  'Açıklama': 'توضیحات',
  'Düzenli ödeme tutarı': 'مبلغ پرداخت منظم',
  'Borç başlığı': 'عنوان بدهی',
  'Alacaklı adı': 'نام طلبکار',
  'Çek numarası': 'شماره چک',
  'Düzenleyen': 'صادرکننده',
  'Banka bilgisi': 'اطلاعات بانک',
  'Senet numarası': 'شماره سفته',
  'Ödeme planı tutarı': 'مبلغ برنامه پرداخت',
  'Abonelik tutarı': 'مبلغ اشتراک',
  'Abonelik türü': 'نوع اشتراک',
  'Abonelik başlığı': 'عنوان اشتراک',
  'Sağlayıcı adı': 'نام ارائه‌دهنده',
  'Abone numarası': 'شماره اشتراک',
  'Sözleşme numarası': 'شماره قرارداد',
  'Fatura tutarı': 'مبلغ قبض',
  'Dönem fatura tutarı': 'مبلغ قبض دوره',
  'Kurum adı': 'نام سازمان',
  'Kira/taksit tutarı': 'مبلغ اجاره یا قسط',
  'Kira/taksit başlığı': 'عنوان اجاره یا قسط',
  'Alıcı adı': 'نام دریافت‌کننده',
  'IBAN': 'IBAN',
  'Adet': 'تعداد',
  'Birim fiyat': 'قیمت واحد',
  'Gider adı': 'نام هزینه',
  'Gider notu': 'یادداشت هزینه',
  'Ödeme tutarı': 'مبلغ پرداخت',
  'Ödeme notu': 'یادداشت پرداخت',
  'Ödeme yöntemi': 'روش پرداخت',
  'Not': 'یادداشت',
  'Notlar': 'یادداشت‌ها',
  'Kategori adı': 'نام دسته',
  'Gelir tutarı': 'مبلغ درآمد',
  'Gelir türü': 'نوع درآمد',
  'Gelir notu': 'یادداشت درآمد',
  'Hatırlatma adı': 'نام یادآوری',
  'Bildirim mesajı': 'متن اعلان',
  'Geçici': 'موقت',
  'Ödeme hatırlatması': 'یادآوری پرداخت',
  'Yaklaşan ve gecikmiş ödemelerini kontrol et.':
      'پرداخت‌های نزدیک و معوق خود را بررسی کنید.',
  'En fazla 10 ödeme bildirimi eklenebilir.':
      'حداکثر ۱۰ اعلان پرداخت قابل افزودن است.',
  'Ödeme bildirim saati bulunamadı.': 'زمان اعلان پرداخت پیدا نشد.',
  'Bildirim saati geçersiz.': 'زمان اعلان نامعتبر است.',
  'En az bir ödeme bildirim saati bulunmalıdır.':
      'حداقل یک زمان اعلان پرداخت باید وجود داشته باشد.',
  'Gelir kaydı bulunamadı.': 'رکورد درآمد پیدا نشد.',
  'Haftalık gelir için geçerli bir gün seçilmelidir.':
      'برای درآمد هفتگی باید یک روز معتبر انتخاب شود.',
  'Aylık gelir günü 1 ile 31 arasında olmalıdır.':
      'روز درآمد ماهانه باید بین ۱ تا ۳۱ باشد.',
  'Yatış günü takibi yalnız haftalık ve aylık gelirlerde kullanılabilir.':
      'پیگیری روز واریز فقط برای درآمد هفتگی و ماهانه قابل استفاده است.',
  'Bu gelir için yatış günü takibi açık değil.':
      'پیگیری روز واریز برای این درآمد روشن نیست.',
  'Bu gelir dönemi daha önce alındı olarak işaretlenmiş.':
      'این دوره درآمد قبلاً دریافت‌شده علامت خورده است.',
  'Geri alınacak gelir işareti yok.':
      'علامت دریافت درآمدی برای بازگردانی وجود ندارد.',
  'Bildirim ayarı bulunamadı.': 'تنظیم اعلان پیدا نشد.',
  'Ödeme kalan borçtan büyük olamaz.':
      'پرداخت نمی‌تواند از بدهی باقی‌مانده بیشتر باشد.',
  'Borç kaydı bulunamadı.': 'رکورد بدهی پیدا نشد.',
  'Ödeme kalan fatura tutarından büyük olamaz.':
      'پرداخت نمی‌تواند از مبلغ باقی‌مانده قبض بیشتر باشد.',
  'Ödeme aboneliğin bu dönem kalan tutarından büyük olamaz.':
      'پرداخت نمی‌تواند از مبلغ باقی‌مانده اشتراک در این دوره بیشتر باشد.',
  'Ödeme kalan kira/taksit tutarından büyük olamaz.':
      'پرداخت نمی‌تواند از مبلغ باقی‌مانده اجاره یا قسط بیشتر باشد.',
  'Ödeme kaydı bulunamadı.': 'رکورد پرداخت پیدا نشد.',
  'Güncellenen ödeme toplam tutarı aşamaz.':
      'پرداخت به‌روزشده نمی‌تواند از مبلغ کل بیشتر باشد.',
  'Toplam borç, daha önce ödenen tutardan düşük olamaz.':
      'مجموع بدهی نمی‌تواند از مبلغی که قبلاً پرداخت شده کمتر باشد.',
  'Fatura tutarı, daha önce ödenen tutardan düşük olamaz.':
      'مبلغ قبض نمی‌تواند از مبلغی که قبلاً پرداخت شده کمتر باشد.',
  'Kira/taksit tutarı, daha önce ödenen tutardan düşük olamaz.':
      'مبلغ اجاره یا قسط نمی‌تواند از مبلغی که قبلاً پرداخت شده کمتر باشد.',
  'Her ayın belirli günü seçildiğinde aylık tutar girilmelidir.':
      'با انتخاب روز مشخص هر ماه باید مبلغ ماهانه وارد شود.',
  'Gecikmiş ay seçimi yalnız aylık ödeme gününde kullanılabilir.':
      'انتخاب ماه معوق فقط با روز پرداخت ماهانه قابل استفاده است.',
  'Gecikmiş ayın ödeme tarihi henüz gelmemiş olamaz.':
      'تاریخ پرداخت ماه معوق انتخاب‌شده نمی‌تواند در آینده باشد.',
  'Kullanılan limit toplam limiti aşamaz.':
      'سقف استفاده‌شده نمی‌تواند از سقف کل بیشتر باشد.',
  'Son ödeme tarihi borç tarihinden önce olamaz.':
      'تاریخ سررسید نمی‌تواند پیش از تاریخ بدهی باشد.',
  'Taksitli borçta ödeme tutarı girilmelidir.':
      'برای بدهی اقساطی باید مبلغ پرداخت وارد شود.',
  'Özel ödeme aralığı gün olarak girilmelidir.':
      'بازه پرداخت دلخواه باید بر حسب روز وارد شود.',
  'Çek numarası boş bırakılamaz.': 'شماره چک نمی‌تواند خالی باشد.',
  'Senet numarası boş bırakılamaz.': 'شماره سفته نمی‌تواند خالی باشد.',
  'Abonelik ödeme sıklığı tek ödeme olamaz.':
      'تناوب پرداخت اشتراک نمی‌تواند یک پرداخت باشد.',
  'Aylık fatura günü 1 ile 31 arasında olmalıdır.':
      'روز قبض ماهانه باید بین ۱ تا ۳۱ باشد.',
  'Ödeme günü 1 ile 31 arasında olmalı.': 'روز پرداخت باید بین ۱ تا ۳۱ باشد.',
  'Ürün taksitinde toplam taksit sayısı gereklidir.':
      'برای قسط کالا، تعداد کل اقساط لازم است.',
  'Sözleşme bitişi başlangıçtan önce olamaz.':
      'پایان قرارداد نمی‌تواند پیش از شروع آن باشد.',
  'Bir borç kaydında ödeme toplamı borcu aşıyor.':
      'مجموع پرداخت‌ها در یکی از رکوردهای بدهی از بدهی بیشتر است.',
  'Bir kişisel borçta ödeme toplamı borcu aşıyor.':
      'مجموع پرداخت‌ها در یکی از بدهی‌های شخصی از بدهی بیشتر است.',
  'Bir fatura kaydında ödeme toplamı tutarı aşıyor.':
      'مجموع پرداخت‌ها در یکی از رکوردهای قبض از مبلغ قبض بیشتر است.',
  'Aylık fatura ödeme günü geçersiz.': 'روز پرداخت قبض ماهانه نامعتبر است.',
  'Dönemsel fatura tutarı sıfırdan büyük olmalıdır.':
      'مبلغ قبض دوره باید بیشتر از صفر باشد.',
  'Bir kira kaydında ödeme toplamı tutarı aşıyor.':
      'مجموع پرداخت‌ها در یکی از رکوردهای اجاره از مبلغ آن بیشتر است.',
  'Bir gider kaydı bulunmayan kategoriye bağlı.':
      'یک رکورد هزینه به دسته‌ای که وجود ندارد متصل است.',
  'Kişi bulunamadı.': 'شخص پیدا نشد.',
  'Banka kaydı bulunamadı.': 'رکورد بانک پیدا نشد.',
  'Kişisel/kurumsal borç bulunamadı.': 'بدهی شخصی یا سازمانی پیدا نشد.',
  'Abonelik kaydı bulunamadı.': 'رکورد اشتراک پیدا نشد.',
  'Fatura kaydı bulunamadı.': 'رکورد قبض پیدا نشد.',
  'Kira/taksit kaydı bulunamadı.': 'رکورد اجاره یا قسط پیدا نشد.',
  'Gider kategorisi bulunamadı.': 'دسته هزینه پیدا نشد.',
  'Gider kaydı bulunamadı.': 'رکورد هزینه پیدا نشد.',
  'Bu kişide aynı banka adı zaten var.':
      'بانکی با همین نام برای این شخص از قبل وجود دارد.',
  'Bu kategori adı zaten kullanılıyor.': 'این نام دسته از قبل استفاده شده است.',
  'Banka borcu kaydı bulunamadı.': 'رکورد بدهی بانکی پیدا نشد.',
  'Toplam taksit pozitif olmalı.': 'تعداد کل اقساط باید مثبت باشد.',
  'Taksit ilerlemesi negatif olamaz.':
      'تعداد اقساط پرداخت‌شده نمی‌تواند منفی باشد.',
  'Taksit ilerlemesi toplam taksiti aşamaz.':
      'تعداد اقساط پرداخت‌شده نمی‌تواند از تعداد کل اقساط بیشتر باشد.',
  'Tutar boş bırakılamaz.': 'مبلغ نمی‌تواند خالی باشد.',
  'Geçerli bir para tutarı girin.': 'یک مبلغ پولی معتبر وارد کنید.',
  'Tutar biçimi anlaşılamadı.': 'قالب مبلغ قابل تشخیص نیست.',
  'En fazla iki kuruş hanesi girilebilir.':
      'حداکثر دو رقم اعشار قابل واردکردن است.',
  'Değer': 'مقدار',
  'Lefferion Prime - MİZAN hata yapabilir. Lütfen vade, gecikme ve ödeme bilgilerini son kez kontrol edin.':
      'Lefferion Prime - MİZAN ممکن است خطا کند. لطفاً اطلاعات سررسید، تأخیر و پرداخت را یک‌بار دیگر بررسی کنید.',
  'Son ödeme bugün': 'سررسید امروز است',
  'Ocak': 'ژانویه',
  'Şubat': 'فوریه',
  'Mart': 'مارس',
  'Nisan': 'آوریل',
  'Mayıs': 'مه',
  'Haziran': 'ژوئن',
  'Temmuz': 'ژوئیه',
  'Ağustos': 'اوت',
  'Eylül': 'سپتامبر',
  'Ekim': 'اکتبر',
  'Kasım': 'نوامبر',
  'Aralık': 'دسامبر',
  'Oca': 'ژان',
  'Şub': 'فور',
  'Mar': 'مار',
  'Nis': 'آور',
  'May': 'مه',
  'Haz': 'ژوئن',
  'Tem': 'ژوئیه',
  'Ağu': 'اوت',
  'Eyl': 'سپت',
  'Eki': 'اکت',
  'Kas': 'نوا',
  'Ara': 'دسا',
  'Bildirim servisi bu platformda etkin değil.':
      'سرویس اعلان در این پلتفرم فعال نیست.',
  'Gider bildirimleri': 'اعلان‌های هزینه',
  'Ödeme bildirimleri': 'اعلان‌های پرداخت',
  'Günlük gider kaydı bildirimleri': 'اعلان‌های ثبت هزینه روزانه',
  'Tüm kayıt türlerinin son ödeme bildirimleri':
      'اعلان‌های سررسید همه انواع رکورد',
  'Android dışında gerçek zamanlama yapılmaz.':
      'خارج از Android زمان‌بندی واقعی انجام نمی‌شود.',
  'Bildirim izni kapalı.': 'مجوز اعلان خاموش است.',
  'Dakik bildirim izni kapalı. Saat ve dakika doğruluğu için izni açın.':
      'مجوز زمان‌بندی دقیق خاموش است. برای دقت ساعت و دقیقه آن را روشن کنید.',
  'Dakik bildirim izni verilmedi.': 'مجوز زمان‌بندی دقیق داده نشد.',
  'Bildirim izni kapalı. Yeni bildirimler oluşturulmadı.':
      'مجوز اعلان خاموش است. اعلان جدیدی ساخته نشد.',
  'Dakik bildirim izni kapalı. Android mevcut dakik planları iptal eder; izin açıldığında plan yeniden kurulmalıdır.':
      'مجوز زمان‌بندی دقیق خاموش است. Android ممکن است برنامه‌های دقیق موجود را لغو کند؛ MİZAN زمان‌بندی تقریبی را ادامه می‌دهد و پس از اعطای مجوز برنامه دقیق را بازمی‌گرداند.',
  'Bildirim izni kapalı. Önce bildirim iznini açın.':
      'مجوز اعلان خاموش است. ابتدا مجوز اعلان را روشن کنید.',
  'Dakik bildirim izni verilmedi. Test yaklaşık zamanda çalıştırılmayacak.':
      'مجوز زمان‌بندی دقیق داده نشد. آزمون با زمان‌بندی تقریبی اجرا می‌شود.',
  'MİZAN bildirim testi': 'آزمون اعلان MİZAN',
  'Bu test, ayarlanan dakik bildirim sistemiyle oluşturuldu.':
      'این آزمون با سامانه زمان‌بندی دقیق تنظیم‌شده ساخته شد.',
  'Yedek kayıt doğrulanamadı.': 'نسخه پشتیبان اعتبارسنجی نشد.',
  'Ana kayıt okunamadı; son sağlam yedek geri yüklendi.':
      'فایل اصلی داده خوانده نشد و آخرین نسخه پشتیبان سالم بازیابی شد.',
  'Ana ve yedek kayıt dosyaları okunamadı. Dosyalar korunuyor.':
      'فایل اصلی و نسخه پشتیبان خوانده نشدند. فایل‌ها حفظ می‌شوند.',
  'MİZAN kullanıma hazır. İlk kişi veya kaydı ekleyebilirsin.':
      'MİZAN آماده استفاده است. می‌توانید نخستین شخص یا رکورد را اضافه کنید.',
  'Geçici kayıt doğrulanamadı.': 'رکورد موقت اعتبارسنجی نشد.',
};

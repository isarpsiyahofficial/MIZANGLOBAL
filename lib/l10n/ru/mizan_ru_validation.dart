const Map<String, String> mizanRussianValidation = <String, String>{
  'Her değişiklik cihazda anında kaydedilir; sağlam kayıt doğrulanmadan üzerine yazılmaz.':
      'Каждое изменение немедленно сохраняется на устройстве; действительные данные никогда не перезаписываются до проверки нового сохранения.',
  'Kişiler, borçlar, faturalar, abonelikler, ödemeler, notlar, gelirler ve giderler her işlemden sonra cihazdaki dosyaya yazılır.':
      'Люди, долги, счета, подписки, платежи, заметки, доходы и расходы записываются в файл на устройстве после каждого действия.',
  'Yeni kayıt doğrulandıktan sonra ana dosya değiştirilir; son sağlam kopya ayrıca korunur.':
      'Основной файл заменяется только после проверки новых данных; последняя действующая копия сохраняется отдельно.',
  'Yedek içe aktarılırken mevcut kayıtlar silinmez. Ortak kayıtlar atlanır, yalnız yeni kayıtlar ve eksik ilişkiler eklenir.':
      'Импорт резервной копии не удаляет существующие записи. Соответствующие записи пропускаются; добавляются только новые записи и отсутствующие связи.',
  'Kişi, banka, borç, ödeme, not, kategori, gider, gelir ve bildirim saatleri kendi kimlik ve bağlantılarıyla aktarılır. Aynı kayıt ikinci kez yazılmaz.':
      'Люди, банки, долги, платежи, примечания, категории, расходы, доходы и время уведомлений переносятся с исходными идентификаторами и связями. Одна и та же запись не записывается повторно.',
  'Uygulama dili seçilmelidir.': 'Необходимо выбрать язык приложения.',
  'Ülke kodu geçersiz.': 'Неверный код страны.',
  'Para birimi kodu geçersiz.': 'Неверный код валюты.',
  'Tamamlanmış profilde uygulama dili eksik.':
      'В заполненном профиле отсутствует язык приложения.',
  'Tamamlanmış profilde ülke kodu geçersiz.':
      'В заполненном профиле указан неверный код страны.',
  'Tamamlanmış profilde para birimi kodu geçersiz.':
      'В заполненном профиле указан неверный код валюты.',
  'Global katalog henüz yüklenmedi.': 'Глобальный каталог ещё не загружен.',
  'Global katalog sayıları doğrulanamadı.':
      'Не удалось проверить количество элементов глобального каталога.',
  'Bildirim izni veya zamanlama servisi açılamadı:':
      'Не удалось открыть разрешение на уведомления или службу планирования:',
  'Yerel kayıt alanı güvenli biçimde açılamadı. Mevcut dosyaları korumak için yeni veri yazımı durduruldu.':
      'Не удалось безопасно открыть локальное хранилище. Новые записи были остановлены для защиты существующих файлов.',
  'Bildirim izni kapalı. Android izni açıldığında MİZAN otomatik olarak yeniden senkronize eder.':
      'Разрешение на уведомления отключено. MİZAN выполнит повторную синхронизацию автоматически после включения разрешения Android.',
  'Dakik bildirim izni kapalı. Android izni açıldığında MİZAN otomatik olarak yeniden senkronize eder.':
      'Разрешение на точные будильники отключено. MİZAN автоматически синхронизируется после включения разрешения Android.',
  'Kayıt yapıldı ancak bildirimler otomatik senkronize edilemedi:':
      'Запись сохранилась, но уведомления не удалось синхронизировать автоматически:',
  'Kişi adı': 'Имя',
  'Banka adı': 'Название банка',
  'Toplam borç': 'Общий долг',
  'Aylık tutar': 'Ежемесячная сумма',
  'Gecikme günü': 'Просрочка в днях',
  'Limit': 'Лимит',
  'Kullanılan limit': 'Использованный лимит',
  'Açıklama': 'Описание',
  'Düzenli ödeme tutarı': 'Обычная сумма платежа',
  'Borç başlığı': 'Название долга',
  'Alacaklı adı': 'Имя кредитора',
  'Çek numarası': 'Номер чека',
  'Düzenleyen': 'Кем выдано',
  'Banka bilgisi': 'Информация о банке',
  'Senet numarası': 'Номер векселя',
  'Ödeme planı tutarı': 'Сумма плана оплаты',
  'Abonelik tutarı': 'Сумма подписки',
  'Abonelik türü': 'Тип подписки',
  'Abonelik başlığı': 'Название подписки',
  'Sağlayıcı adı': 'Название поставщика',
  'Abone numarası': 'Абонентский номер',
  'Sözleşme numarası': 'Номер контракта',
  'Fatura tutarı': 'Сумма счета',
  'Dönem fatura tutarı': 'Сумма расчетного периода',
  'Kurum adı': 'Название учреждения',
  'Kira/taksit tutarı': 'Сумма арендной платы/рассрочки',
  'Kira/taksit başlığı': 'Название аренды / рассрочки',
  'Alıcı adı': 'Имя получателя',
  'IBAN': 'IBAN',
  'Adet': 'Количество',
  'Birim fiyat': 'Цена за единицу товара',
  'Gider adı': 'Название расхода',
  'Gider notu': 'Примечание к расходу',
  'Ödeme tutarı': 'Сумма платежа',
  'Ödeme notu': 'Примечание к оплате',
  'Ödeme yöntemi': 'Способ оплаты',
  'Not': 'Примечание',
  'Notlar': 'Примечания',
  'Kategori adı': 'Название категории',
  'Gelir tutarı': 'Сумма дохода',
  'Gelir türü': 'Тип дохода',
  'Gelir notu': 'Примечание о доходах',
  'Hatırlatma adı': 'Название напоминания',
  'Bildirim mesajı': 'Текст уведомления',
  'Geçici': 'Временно',
  'Ödeme hatırlatması': 'Напоминание об оплате',
  'Yaklaşan ve gecikmiş ödemelerini kontrol et.':
      'Просмотрите предстоящие и просроченные платежи.',
  'En fazla 10 ödeme bildirimi eklenebilir.':
      'Вы можете добавить до 10 уведомлений о платежах.',
  'Ödeme bildirim saati bulunamadı.': 'Время уведомления о платеже не найдено.',
  'Bildirim saati geçersiz.': 'Недопустимое время уведомления.',
  'En az bir ödeme bildirim saati bulunmalıdır.':
      'Необходимо указать хотя бы одно время уведомления о платеже.',
  'Gelir kaydı bulunamadı.': 'Запись о доходах не найдена.',
  'Haftalık gelir için geçerli bir gün seçilmelidir.':
      'Выберите действительный день недели для получения еженедельного дохода.',
  'Aylık gelir günü 1 ile 31 arasında olmalıdır.':
      'День ежемесячного дохода должен находиться между 1 и 31.',
  'Yatış günü takibi yalnız haftalık ve aylık gelirlerde kullanılabilir.':
      'Отслеживание дня поступления доступно только для еженедельного и ежемесячного дохода.',
  'Bu gelir için yatış günü takibi açık değil.':
      'Для этого дохода отслеживание дня поступления не включено.',
  'Bu gelir dönemi daha önce alındı olarak işaretlenmiş.':
      'Этот период дохода уже отмечен как полученный.',
  'Geri alınacak gelir işareti yok.':
      'Нет статуса получения дохода, который можно было бы отменить.',
  'Bildirim ayarı bulunamadı.': 'Настройка уведомлений не найдена.',
  'Ödeme kalan borçtan büyük olamaz.':
      'Платеж не может превышать оставшуюся сумму долга.',
  'Borç kaydı bulunamadı.': 'Запись о задолженности не найдена.',
  'Ödeme kalan fatura tutarından büyük olamaz.':
      'Платеж не может превышать оставшуюся сумму счета.',
  'Ödeme aboneliğin bu dönem kalan tutarından büyük olamaz.':
      'Платеж не может превышать оставшуюся сумму подписки за этот период.',
  'Ödeme kalan kira/taksit tutarından büyük olamaz.':
      'Платеж не может превышать оставшуюся сумму арендной платы/рассрочки.',
  'Ödeme kaydı bulunamadı.': 'Запись о платеже не найдена.',
  'Güncellenen ödeme toplam tutarı aşamaz.':
      'Обновленный платеж не может превышать общую сумму.',
  'Toplam borç, daha önce ödenen tutardan düşük olamaz.':
      'Общий долг не может быть ниже уже выплаченной суммы.',
  'Fatura tutarı, daha önce ödenen tutardan düşük olamaz.':
      'Сумма счета не может быть ниже уже оплаченной суммы.',
  'Kira/taksit tutarı, daha önce ödenen tutardan düşük olamaz.':
      'Сумма арендной платы/рассрочки не может быть ниже уже уплаченной суммы.',
  'Her ayın belirli günü seçildiğinde aylık tutar girilmelidir.':
      'Ежемесячная сумма требуется, если выбран определенный день каждого месяца.',
  'Gecikmiş ay seçimi yalnız aylık ödeme gününde kullanılabilir.':
      'Выбор месяца просрочки доступен только с указанием дня ежемесячного платежа.',
  'Gecikmiş ayın ödeme tarihi henüz gelmemiş olamaz.':
      'Срок оплаты выбранного месяца просрочки не может быть в будущем.',
  'Kullanılan limit toplam limiti aşamaz.':
      'Использованный кредит не может превышать общий лимит.',
  'Son ödeme tarihi borç tarihinden önce olamaz.':
      'Дата платежа не может быть раньше даты возникновения долга.',
  'Taksitli borçta ödeme tutarı girilmelidir.':
      'Для долга с рассрочкой необходимо указать сумму платежа.',
  'Özel ödeme aralığı gün olarak girilmelidir.':
      'Введите индивидуальный интервал платежей в днях.',
  'Çek numarası boş bırakılamaz.': 'Требуется номер чека.',
  'Senet numarası boş bırakılamaz.': 'Необходимо указать номер векселя.',
  'Abonelik ödeme sıklığı tek ödeme olamaz.':
      'Подписка не может использовать частоту единоразовых платежей.',
  'Aylık fatura günü 1 ile 31 arasında olmalıdır.':
      'День ежемесячного счета должен находиться в диапазоне от 1 до 31.',
  'Ödeme günü 1 ile 31 arasında olmalı.':
      'День платежа должен находиться в диапазоне от 1 до 31.',
  'Ürün taksitinde toplam taksit sayısı gereklidir.':
      'Для рассрочки продукта необходимо указать общее количество платежей.',
  'Sözleşme bitişi başlangıçtan önce olamaz.':
      'Дата окончания договора не может быть раньше даты начала.',
  'Bir borç kaydında ödeme toplamı borcu aşıyor.':
      'Сумма платежей по записи о долге превышает сумму долга.',
  'Bir kişisel borçta ödeme toplamı borcu aşıyor.':
      'Выплаты по личному долгу превышают сумму долга.',
  'Bir fatura kaydında ödeme toplamı tutarı aşıyor.':
      'Сумма платежей по счёту превышает сумму счёта.',
  'Aylık fatura ödeme günü geçersiz.':
      'Неверный день оплаты ежемесячного счета.',
  'Dönemsel fatura tutarı sıfırdan büyük olmalıdır.':
      'Сумма расчетного периода должна быть больше нуля.',
  'Bir kira kaydında ödeme toplamı tutarı aşıyor.':
      'Платежи по арендной плате превышают причитающуюся сумму.',
  'Bir gider kaydı bulunmayan kategoriye bağlı.':
      'Расход привязан к несуществующей категории.',
  'Kişi bulunamadı.': 'Человек не найден.',
  'Banka kaydı bulunamadı.': 'Банковская запись не найдена.',
  'Kişisel/kurumsal borç bulunamadı.':
      'Личная/деловая задолженность не обнаружена.',
  'Abonelik kaydı bulunamadı.': 'Запись о подписке не найдена.',
  'Fatura kaydı bulunamadı.': 'Запись о счете не найдена.',
  'Kira/taksit kaydı bulunamadı.': 'Запись об аренде/рассрочке не найдена.',
  'Gider kategorisi bulunamadı.': 'Категория расходов не найдена.',
  'Gider kaydı bulunamadı.': 'Запись о расходах не найдена.',
  'Bu kişide aynı banka adı zaten var.':
      'У этого человека уже есть банк с таким названием.',
  'Bu kategori adı zaten kullanılıyor.':
      'Это название категории уже используется.',
  'Banka borcu kaydı bulunamadı.':
      'Запись о банковской задолженности не найдена.',
  'Toplam taksit pozitif olmalı.':
      'Общее количество взносов должно быть положительным.',
  'Taksit ilerlemesi negatif olamaz.':
      'Количество выполненных платежей не может быть отрицательным.',
  'Taksit ilerlemesi toplam taksiti aşamaz.':
      'Количество выполненных платежей не может превышать общее количество платежей.',
  'Tutar boş bırakılamaz.': 'Требуется сумма.',
  'Geçerli bir para tutarı girin.': 'Введите действительную денежную сумму.',
  'Tutar biçimi anlaşılamadı.': 'Не удалось распознать формат суммы.',
  'En fazla iki kuruş hanesi girilebilir.':
      'Введите не более двух десятичных знаков.',
  'Değer': 'Значение',
  'Lefferion Prime - MİZAN hata yapabilir. Lütfen vade, gecikme ve ödeme bilgilerini son kez kontrol edin.':
      'Lefferion Prime - MİZAN может допускать ошибки. Перед продолжением проверьте сроки, состояние просрочки и сведения о платежах.',
  'Son ödeme bugün': 'Срок оплаты сегодня',
  'Ocak': 'Январь',
  'Şubat': 'Февраль',
  'Mart': 'Март',
  'Nisan': 'Апрель',
  'Mayıs': 'Май',
  'Haziran': 'Июнь',
  'Temmuz': 'Июль',
  'Ağustos': 'Август',
  'Eylül': 'Сентябрь',
  'Ekim': 'Октябрь',
  'Kasım': 'Ноябрь',
  'Aralık': 'Декабрь',
  'Oca': 'Янв',
  'Şub': 'Фев',
  'Mar': 'Мар',
  'Nis': 'Апр',
  'May': 'Май',
  'Haz': 'Июн',
  'Tem': 'Июл',
  'Ağu': 'Авг',
  'Eyl': 'Сен',
  'Eki': 'Окт',
  'Kas': 'Ноя',
  'Ara': 'Дек',
  'Bildirim servisi bu platformda etkin değil.':
      'Служба уведомлений недоступна на этой платформе.',
  'Gider bildirimleri': 'Уведомления о расходах',
  'Ödeme bildirimleri': 'Уведомления о платежах',
  'Günlük gider kaydı bildirimleri': 'Уведомления о ежедневных расходах',
  'Tüm kayıt türlerinin son ödeme bildirimleri':
      'Уведомления о сроках оплаты для всех типов записей',
  'Android dışında gerçek zamanlama yapılmaz.':
      'Реальное планирование доступно только на Android.',
  'Bildirim izni kapalı.': 'Разрешение на уведомления отключено.',
  'Dakik bildirim izni kapalı. Saat ve dakika doğruluğu için izni açın.':
      'Разрешение на точные будильники отключено. Включите его для доставки в выбранные час и минуту.',
  'Dakik bildirim izni verilmedi.':
      'Разрешение на точные будильники не предоставлено.',
  'Bildirim izni kapalı. Yeni bildirimler oluşturulmadı.':
      'Разрешение на уведомления отключено. Новые уведомления не создавались.',
  'Dakik bildirim izni kapalı. Android mevcut dakik planları iptal eder; izin açıldığında plan yeniden kurulmalıdır.':
      'Разрешение на точные будильники отключено. Android отменяет существующие точные расписания; после выдачи разрешения расписание необходимо создать заново.',
  'Bildirim izni kapalı. Önce bildirim iznini açın.':
      'Разрешение на уведомления отключено. Сначала включите разрешение на уведомления.',
  'Dakik bildirim izni verilmedi. Test yaklaşık zamanda çalıştırılmayacak.':
      'Разрешение на точные будильники не предоставлено. Тест не будет запущен с приблизительным временем.',
  'MİZAN bildirim testi': 'Тест уведомлений MİZAN',
  'Bu test, ayarlanan dakik bildirim sistemiyle oluşturuldu.':
      'Этот тест был создан с настроенной точной системой уведомлений.',
  'Yedek kayıt doğrulanamadı.': 'Резервную копию не удалось проверить.',
  'Ana kayıt okunamadı; son sağlam yedek geri yüklendi.':
      'Не удалось прочитать основной файл данных; восстановлена последняя действительная резервная копия.',
  'Ana ve yedek kayıt dosyaları okunamadı. Dosyalar korunuyor.':
      'Не удалось прочитать ни основной файл данных, ни резервную копию. Файлы сохранены.',
  'MİZAN kullanıma hazır. İlk kişi veya kaydı ekleyebilirsin.':
      'MİZAN готов к работе. Для начала добавьте первую запись о человеке или другую запись.',
  'Geçici kayıt doğrulanamadı.': 'Временное сохранение не удалось проверить.',
};

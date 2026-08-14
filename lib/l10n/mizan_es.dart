typedef SpanishTextTranslator = String Function(String source);

const Map<String, String> mizanSpanish = <String, String>{
  'MİZAN Aylık Raporu': 'Informe mensual de MİZAN',
  'Aktif': 'Activo',
  'Yaklaşıyor': 'Próximo a vencer',
  'Gecikmede': 'Vencido',
  'Tamamlandı': 'Completado',
  'Pasif': 'Inactivo',
  'KMH hesabı': 'Cuenta con sobregiro',
  'Kredi kartı': 'Tarjeta de crédito',
  'Kredi': 'Préstamo',
  'Araç kredisi': 'Préstamo para vehículo',
  'Ev kredisi': 'Hipoteca',
  'Nakit avans': 'Anticipo de efectivo',
  'Taksitli nakit avans': 'Anticipo de efectivo a plazos',
  'Özel borç türü': 'Tipo de deuda personalizado',
  'Son ödeme tarihi': 'Fecha de vencimiento',
  'Her ayın belirli günü': 'Un día específico de cada mes',
  'Taksit ödemesi': 'Pago de cuota',
  'Borç kapama': 'Saldar deuda',
  'Kısmi ödeme': 'Pago parcial',
  'Günde 1 kez': 'Una vez al día',
  'Günde 2 kez': 'Dos veces al día',
  'Günde 3 kez': 'Tres veces al día',
  'Cihazın varsayılan bildirim sesi':
      'Sonido de notificación predeterminado del dispositivo',
  'Sessiz': 'Silencio',
  'Tek seferlik': 'Una sola vez',
  'Günlük': 'Diario',
  'Haftalık': 'Semanal',
  'Aylık': 'Mensual',
  'Elektrik': 'Electricidad',
  'Su': 'Agua',
  'Telefon': 'Teléfono',
  'İnternet': 'Internet',
  'Doğalgaz': 'Gas natural',
  'Özel fatura': 'Factura personalizada',
  'Tek dönem faturası': 'Factura de un solo periodo',
  'Her ay tekrarlayan fatura': 'Factura mensual recurrente',
  'Ev kirası': 'Alquiler de vivienda',
  'Ürün taksiti': 'Compra a plazos',
  'Özel oluştur': 'Personalizado',
  'Kişi': 'Persona',
  'Şirket / Kurum': 'Empresa / organización',
  'Çek': 'Cheque',
  'Senet': 'Pagaré',
  'Esnaf / İşletme': 'Comercio / empresa',
  'Aile / Yakın': 'Familiar / persona cercana',
  'Diğer': 'Otro',
  'Tek ödeme': 'Pago único',
  'İki haftada bir': 'Cada dos semanas',
  'Üç aylık': 'Trimestral',
  'Yıllık': 'Anual',
  'Özel aralık': 'Intervalo personalizado',
  'Dijital hizmet': 'Servicio digital',
  'Üyelik': 'Membresía',
  'Sigorta': 'Seguro',
  'Eğitim': 'Educación',
  'Bakım / servis': 'Mantenimiento / servicio',
  'Diğer abonelik': 'Otra suscripción',
  'Banka borcu': 'Deuda bancaria',
  'Kişisel / kurumsal borç': 'Deuda personal / empresarial',
  'Fatura': 'Factura',
  'Abonelik': 'Suscripción',
  'Kira / taksit': 'Alquiler / cuota',
  'Ana sayfa': 'Inicio',
  'Kayıtlar': 'Registros',
  'Giderler': 'Gastos',
  'Raporlar': 'Informes',
  'Ayarlar': 'Ajustes',
  'Kapat': 'Cerrar',
  'Kaydet': 'Guardar',
  'Vazgeç': 'Cancelar',
  'Sil': 'Eliminar',
  'Düzenle': 'Editar',
  'Ekle': 'Añadir',
  'Devam et': 'Continuar',
  'Geri': 'Atrás',
  'Tamam': 'Listo',
  'Onayla': 'Confirmar',
  'Aramayı temizle': 'Borrar búsqueda',
  'Eşleşen sonuç bulunamadı.': 'No se encontraron resultados coincidentes.',
  'Dil seç': 'Seleccionar idioma',
  'Dil ara': 'Buscar idiomas',
  'Ülke seç': 'Seleccionar país',
  'Ülke adı veya kod ara': 'Buscar por nombre o código de país',
  'Para birimi seç': 'Seleccionar moneda',
  'Ad, ISO kodu veya sembol ara': 'Buscar por nombre, código ISO o símbolo',
  'Uygulama dili': 'Idioma de la aplicación',
  'Ülke / borç bölgesi': 'País / región de deuda',
  'Varsayılan para birimi': 'Moneda predeterminada',
  'Kurulumu tamamla': 'Completar configuración',
  'MİZAN GLOBAL': 'MİZAN GLOBAL',
  'Bu seçimler yalnız ilk kurulumda sorulur. Daha sonra Ayarlar bölümünden değiştirilebilir; mevcut kayıtlar silinmez.':
      'Estas opciones solo se solicitan durante la configuración inicial. Puedes cambiarlas más adelante en Ajustes sin eliminar ningún registro existente.',
  'Yalnızca tamamen entegre edilmiş bir dil seçilebilir.':
      'Solo se puede seleccionar un idioma completamente integrado.',
  'Dil, ülke ve para birimi': 'Idioma, país y moneda',
  'Bu seçimleri değiştirmek kayıtları, ödemeleri veya geçmişi silmez.':
      'Cambiar estas opciones no elimina registros, pagos ni el historial.',
  'Profil kayıtları korunur': 'Tus registros se conservan',
  'Dil, ülke veya varsayılan para birimi değiştiğinde mevcut kişi, borç, fatura, gider, gelir ve ödeme kayıtları değiştirilmez.':
      'Cambiar el idioma, el país o la moneda predeterminada no modifica las personas, deudas, facturas, gastos, ingresos ni pagos existentes.',
  'Bildirim sistemi': 'Sistema de notificaciones',
  'Bildirim izni': 'Permiso de notificaciones',
  'Dakik bildirim izni': 'Permiso de alarmas exactas',
  'Açık': 'Activado',
  'Kapalı': 'Desactivado',
  'Dakik teslim için izin gerekli':
      'Se requiere permiso para programar con precisión',
  'Bildirim planı bilgisi': 'Información del calendario de notificaciones',
  'Otomatik senkronizasyon': 'Sincronización automática',
  'Ödeme hatırlatmaları': 'Recordatorios de pago',
  'Saat ekle': 'Añadir hora',
  'Ses ve titreşim': 'Sonido y vibración',
  'Titreşim açık': 'Vibración activada',
  'Titreşim kapalı': 'Vibración desactivada',
  'Vade kayıtları değiştirilmez':
      'Los registros de vencimiento no se modifican',
  'Günlük gider hatırlatmaları': 'Recordatorios diarios de gastos',
  'Yerel veri güvenliği': 'Seguridad de datos locales',
  'Anlık yerel kayıt': 'Guardado local instantáneo',
  'Doğrulanmış yedek kopya': 'Copia de seguridad verificada',
  'CSV yedekleme': 'Copia de seguridad CSV',
  'CSV yedeğini dışa aktar': 'Exportar copia de seguridad CSV',
  'CSV yedeğini mevcut verilerle birleştir':
      'Combinar copia de seguridad CSV con los datos existentes',
  'İlişkiler korunur': 'Se conservan las relaciones',
  'Ana durumu ve Android izinlerini burada yönet. Hatırlatma saati ve mesajı ilgili kaydın ayrıntısındadır.':
      'Gestiona aquí el estado principal y los permisos de Android. La hora y el mensaje de cada recordatorio se encuentran en los detalles del registro correspondiente.',
  'Etkin hatırlatmalar seçilen gün ve dakikada planlanır.':
      'Los recordatorios activos se programan para el día, la hora y el minuto seleccionados.',
  'Hatırlatmalar durdurulur; kayıtlar ve ayarlar silinmez.':
      'Los recordatorios se detendrán; los registros y los ajustes no se eliminarán.',
  'Android bildirim izni kapalı. İzin açılmadan hiçbir MİZAN bildirimi oluşturulmaz.':
      'El permiso de notificaciones de Android está desactivado. MİZAN no puede crear notificaciones hasta que se conceda el permiso.',
  'Android dakik bildirim izni kapalı. MİZAN yaklaşık zamanlama kullanmaz; saat ve dakikada teslim için bu izin açılmalıdır.':
      'El permiso de alarmas exactas de Android está desactivado. MİZAN no utiliza horarios aproximados; activa este permiso para entregar las notificaciones a la hora y al minuto seleccionados.',
  'Kayıt değişiklikleri üst üste bindirilmeden sırayla işlenir. Yalnız sıradaki gerekli bildirimler dakik biçimde yenilenir; gereksiz günlük kopyalar oluşturulmaz.':
      'Los cambios en los registros se procesan en orden y sin solaparse. Solo se actualizan con precisión las próximas notificaciones necesarias; no se crean duplicados diarios innecesarios.',
  'Her kart yalnız özet gösterir. Saat, mesaj ve açık/kapalı durumu karta dokununca düzenlenir.':
      'Cada tarjeta muestra solo un resumen. Tócala para editar la hora, el mensaje y el estado de activación.',
  'Bildirim planlaması yalnız hatırlatma oluşturur; ödeme, taksit, gider veya geçmiş kaydı üretmez.':
      'La programación de notificaciones solo crea recordatorios; nunca genera pagos, cuotas, gastos ni registros de historial.',
  'Her gider hatırlatmasının saatini, mesajını ve açık/kapalı durumunu kendi ayrıntısından düzenle.':
      'Edita la hora, el mensaje y el estado de cada recordatorio de gastos desde sus propios detalles.',
  'Her değişiklik cihazda anında kaydedilir; sağlam kayıt doğrulanmadan üzerine yazılmaz.':
      'Cada cambio se guarda de inmediato en el dispositivo; los datos válidos no se sobrescriben hasta que se verifica el nuevo guardado.',
  'Kişiler, borçlar, faturalar, abonelikler, ödemeler, notlar, gelirler ve giderler her işlemden sonra cihazdaki dosyaya yazılır.':
      'Las personas, deudas, facturas, suscripciones, pagos, notas, ingresos y gastos se escriben en el archivo del dispositivo después de cada operación.',
  'Yeni kayıt doğrulandıktan sonra ana dosya değiştirilir; son sağlam kopya ayrıca korunur.':
      'El archivo principal solo se reemplaza después de verificar los nuevos datos; la última copia válida se conserva por separado.',
  'Yedek içe aktarılırken mevcut kayıtlar silinmez. Ortak kayıtlar atlanır, yalnız yeni kayıtlar ve eksik ilişkiler eklenir.':
      'Al importar una copia de seguridad no se eliminan los registros existentes. Se omiten los registros coincidentes y solo se añaden los nuevos registros y las relaciones que falten.',
  'Kişi, banka, borç, ödeme, not, kategori, gider, gelir ve bildirim saatleri kendi kimlik ve bağlantılarıyla aktarılır. Aynı kayıt ikinci kez yazılmaz.':
      'Las personas, bancos, deudas, pagos, notas, categorías, gastos, ingresos y horas de notificación se transfieren con sus identificadores y relaciones originales. Un mismo registro nunca se escribe dos veces.',
  'Uygulama dili seçilmelidir.':
      'Debes seleccionar un idioma para la aplicación.',
  'Ülke kodu geçersiz.': 'Código de país no válido.',
  'Para birimi kodu geçersiz.': 'Código de moneda no válido.',
  'Tamamlanmış profilde uygulama dili eksik.':
      'Al perfil completado le falta el idioma de la aplicación.',
  'Tamamlanmış profilde ülke kodu geçersiz.':
      'El perfil completado contiene un código de país no válido.',
  'Tamamlanmış profilde para birimi kodu geçersiz.':
      'El perfil completado contiene un código de moneda no válido.',
  'Global katalog henüz yüklenmedi.':
      'El catálogo global todavía no se ha cargado.',
  'Global katalog sayıları doğrulanamadı.':
      'No se pudieron verificar los recuentos del catálogo global.',
  'Bildirim izni veya zamanlama servisi açılamadı:':
      'No se pudo abrir el permiso de notificaciones o el servicio de programación:',
  'Yerel kayıt alanı güvenli biçimde açılamadı. Mevcut dosyaları korumak için yeni veri yazımı durduruldu.':
      'No se pudo abrir de forma segura el almacenamiento local. Se ha detenido la escritura de nuevos datos para proteger los archivos existentes.',
  'Bildirim izni kapalı. Android izni açıldığında MİZAN otomatik olarak yeniden senkronize eder.':
      'El permiso de notificaciones está desactivado. MİZAN se volverá a sincronizar automáticamente cuando se active el permiso de Android.',
  'Dakik bildirim izni kapalı. Android izni açıldığında MİZAN otomatik olarak yeniden senkronize eder.':
      'El permiso de alarmas exactas está desactivado. MİZAN se volverá a sincronizar automáticamente cuando se active el permiso de Android.',
  'Kayıt yapıldı ancak bildirimler otomatik senkronize edilemedi:':
      'El registro se guardó, pero las notificaciones no pudieron sincronizarse automáticamente:',
  'Kişi adı': 'Nombre de la persona',
  'Banka adı': 'Nombre del banco',
  'Toplam borç': 'Deuda total',
  'Aylık tutar': 'Importe mensual',
  'Gecikme günü': 'Días de retraso',
  'Limit': 'Límite',
  'Kullanılan limit': 'Límite utilizado',
  'Açıklama': 'Descripción',
  'Düzenli ödeme tutarı': 'Importe del pago periódico',
  'Borç başlığı': 'Título de la deuda',
  'Alacaklı adı': 'Nombre del acreedor',
  'Çek numarası': 'Número de cheque',
  'Düzenleyen': 'Emisor',
  'Banka bilgisi': 'Información bancaria',
  'Senet numarası': 'Número de pagaré',
  'Ödeme planı tutarı': 'Importe del plan de pagos',
  'Abonelik tutarı': 'Importe de la suscripción',
  'Abonelik türü': 'Tipo de suscripción',
  'Abonelik başlığı': 'Título de la suscripción',
  'Sağlayıcı adı': 'Nombre del proveedor',
  'Abone numarası': 'Número de abonado',
  'Sözleşme numarası': 'Número de contrato',
  'Fatura tutarı': 'Importe de la factura',
  'Dönem fatura tutarı': 'Importe del periodo de facturación',
  'Kurum adı': 'Nombre de la entidad',
  'Kira/taksit tutarı': 'Importe del alquiler/cuota',
  'Kira/taksit başlığı': 'Título del alquiler/cuota',
  'Alıcı adı': 'Nombre del beneficiario',
  'IBAN': 'IBAN',
  'Adet': 'Cantidad',
  'Birim fiyat': 'Precio unitario',
  'Gider adı': 'Nombre del gasto',
  'Gider notu': 'Nota del gasto',
  'Ödeme tutarı': 'Importe del pago',
  'Ödeme notu': 'Nota del pago',
  'Ödeme yöntemi': 'Método de pago',
  'Not': 'Nota',
  'Notlar': 'Notas',
  'Kategori adı': 'Nombre de la categoría',
  'Gelir tutarı': 'Importe del ingreso',
  'Gelir türü': 'Tipo de ingreso',
  'Gelir notu': 'Nota del ingreso',
  'Hatırlatma adı': 'Nombre del recordatorio',
  'Bildirim mesajı': 'Mensaje de notificación',
  'Geçici': 'Temporal',
  'Ödeme hatırlatması': 'Recordatorio de pago',
  'Yaklaşan ve gecikmiş ödemelerini kontrol et.':
      'Revisa tus pagos próximos y vencidos.',
  'En fazla 10 ödeme bildirimi eklenebilir.':
      'Puedes añadir hasta 10 notificaciones de pago.',
  'Ödeme bildirim saati bulunamadı.':
      'No se encontró la hora de la notificación de pago.',
  'Bildirim saati geçersiz.': 'Hora de notificación no válida.',
  'En az bir ödeme bildirim saati bulunmalıdır.':
      'Debe haber al menos una hora de notificación de pago.',
  'Gelir kaydı bulunamadı.': 'No se encontró el registro de ingresos.',
  'Haftalık gelir için geçerli bir gün seçilmelidir.':
      'Selecciona un día de la semana válido para el ingreso semanal.',
  'Aylık gelir günü 1 ile 31 arasında olmalıdır.':
      'El día del ingreso mensual debe estar entre 1 y 31.',
  'Yatış günü takibi yalnız haftalık ve aylık gelirlerde kullanılabilir.':
      'El seguimiento de la fecha de cobro solo está disponible para ingresos semanales y mensuales.',
  'Bu gelir için yatış günü takibi açık değil.':
      'El seguimiento de la fecha de cobro no está activado para este ingreso.',
  'Bu gelir dönemi daha önce alındı olarak işaretlenmiş.':
      'Este periodo de ingresos ya está marcado como cobrado.',
  'Geri alınacak gelir işareti yok.':
      'No hay ningún cobro de ingreso que deshacer.',
  'Bildirim ayarı bulunamadı.':
      'No se encontró la configuración de notificación.',
  'Ödeme kalan borçtan büyük olamaz.':
      'El pago no puede superar la deuda pendiente.',
  'Borç kaydı bulunamadı.': 'No se encontró el registro de deuda.',
  'Ödeme kalan fatura tutarından büyük olamaz.':
      'El pago no puede superar el importe pendiente de la factura.',
  'Ödeme aboneliğin bu dönem kalan tutarından büyük olamaz.':
      'El pago no puede superar el importe pendiente de la suscripción para este periodo.',
  'Ödeme kalan kira/taksit tutarından büyük olamaz.':
      'El pago no puede superar el importe pendiente del alquiler/cuota.',
  'Ödeme kaydı bulunamadı.': 'No se encontró el registro de pago.',
  'Güncellenen ödeme toplam tutarı aşamaz.':
      'El pago actualizado no puede superar el importe total.',
  'Toplam borç, daha önce ödenen tutardan düşük olamaz.':
      'La deuda total no puede ser inferior al importe ya pagado.',
  'Fatura tutarı, daha önce ödenen tutardan düşük olamaz.':
      'El importe de la factura no puede ser inferior al importe ya pagado.',
  'Kira/taksit tutarı, daha önce ödenen tutardan düşük olamaz.':
      'El importe del alquiler/cuota no puede ser inferior al importe ya pagado.',
  'Her ayın belirli günü seçildiğinde aylık tutar girilmelidir.':
      'Debes introducir un importe mensual al seleccionar un día específico de cada mes.',
  'Gecikmiş ay seçimi yalnız aylık ödeme gününde kullanılabilir.':
      'La selección de un mes vencido solo está disponible con un día de pago mensual.',
  'Gecikmiş ayın ödeme tarihi henüz gelmemiş olamaz.':
      'La fecha de vencimiento del mes seleccionado no puede estar en el futuro.',
  'Kullanılan limit toplam limiti aşamaz.':
      'El límite utilizado no puede superar el límite total.',
  'Son ödeme tarihi borç tarihinden önce olamaz.':
      'La fecha de vencimiento no puede ser anterior a la fecha de la deuda.',
  'Taksitli borçta ödeme tutarı girilmelidir.':
      'Debes introducir un importe de pago para una deuda a plazos.',
  'Özel ödeme aralığı gün olarak girilmelidir.':
      'Introduce el intervalo de pago personalizado en días.',
  'Çek numarası boş bırakılamaz.': 'El número de cheque es obligatorio.',
  'Senet numarası boş bırakılamaz.': 'El número de pagaré es obligatorio.',
  'Abonelik ödeme sıklığı tek ödeme olamaz.':
      'Una suscripción no puede tener una frecuencia de pago único.',
  'Aylık fatura günü 1 ile 31 arasında olmalıdır.':
      'El día de pago mensual de la factura debe estar entre 1 y 31.',
  'Ödeme günü 1 ile 31 arasında olmalı.':
      'El día de pago debe estar entre 1 y 31.',
  'Ürün taksitinde toplam taksit sayısı gereklidir.':
      'El número total de cuotas es obligatorio para una compra a plazos.',
  'Sözleşme bitişi başlangıçtan önce olamaz.':
      'La fecha de finalización del contrato no puede ser anterior a la fecha de inicio.',
  'Bir borç kaydında ödeme toplamı borcu aşıyor.':
      'Los pagos de un registro de deuda superan el importe de la deuda.',
  'Bir kişisel borçta ödeme toplamı borcu aşıyor.':
      'Los pagos de una deuda personal superan el importe de la deuda.',
  'Bir fatura kaydında ödeme toplamı tutarı aşıyor.':
      'Los pagos de una factura superan el importe de la factura.',
  'Aylık fatura ödeme günü geçersiz.':
      'Día de pago mensual de la factura no válido.',
  'Dönemsel fatura tutarı sıfırdan büyük olmalıdır.':
      'El importe del periodo de facturación debe ser superior a cero.',
  'Bir kira kaydında ödeme toplamı tutarı aşıyor.':
      'Los pagos de un registro de alquiler superan el importe adeudado.',
  'Bir gider kaydı bulunmayan kategoriye bağlı.':
      'Un gasto está vinculado a una categoría que no existe.',
  'Kişi bulunamadı.': 'No se encontró la persona.',
  'Banka kaydı bulunamadı.': 'No se encontró el registro bancario.',
  'Kişisel/kurumsal borç bulunamadı.':
      'No se encontró la deuda personal/empresarial.',
  'Abonelik kaydı bulunamadı.': 'No se encontró el registro de suscripción.',
  'Fatura kaydı bulunamadı.': 'No se encontró el registro de factura.',
  'Kira/taksit kaydı bulunamadı.':
      'No se encontró el registro de alquiler/cuota.',
  'Gider kategorisi bulunamadı.': 'No se encontró la categoría de gastos.',
  'Gider kaydı bulunamadı.': 'No se encontró el registro de gasto.',
  'Bu kişide aynı banka adı zaten var.':
      'Esta persona ya tiene un banco con el mismo nombre.',
  'Bu kategori adı zaten kullanılıyor.':
      'Este nombre de categoría ya está en uso.',
  'Banka borcu kaydı bulunamadı.':
      'No se encontró el registro de deuda bancaria.',
  'Toplam taksit pozitif olmalı.':
      'El número total de cuotas debe ser positivo.',
  'Taksit ilerlemesi negatif olamaz.':
      'El progreso de las cuotas no puede ser negativo.',
  'Taksit ilerlemesi toplam taksiti aşamaz.':
      'El progreso de las cuotas no puede superar el número total de cuotas.',
  'Tutar boş bırakılamaz.': 'El importe es obligatorio.',
  'Geçerli bir para tutarı girin.': 'Introduce un importe monetario válido.',
  'Tutar biçimi anlaşılamadı.': 'No se pudo reconocer el formato del importe.',
  'En fazla iki kuruş hanesi girilebilir.':
      'Introduce como máximo dos decimales.',
  'Değer': 'Valor',
  'Lefferion Prime - MİZAN hata yapabilir. Lütfen vade, gecikme ve ödeme bilgilerini son kez kontrol edin.':
      'Lefferion Prime - MİZAN puede cometer errores. Revisa las fechas de vencimiento, los retrasos y la información de pago antes de continuar.',
  'Son ödeme bugün': 'Vence hoy',
  'Ocak': 'Enero',
  'Şubat': 'Febrero',
  'Mart': 'Marzo',
  'Nisan': 'Abril',
  'Mayıs': 'Mayo',
  'Haziran': 'Junio',
  'Temmuz': 'Julio',
  'Ağustos': 'Agosto',
  'Eylül': 'Septiembre',
  'Ekim': 'Octubre',
  'Kasım': 'Noviembre',
  'Aralık': 'Diciembre',
  'Oca': 'Ene',
  'Şub': 'Feb',
  'Mar': 'Mar',
  'Nis': 'Abr',
  'May': 'May',
  'Haz': 'Jun',
  'Tem': 'Jul',
  'Ağu': 'Ago',
  'Eyl': 'Sep',
  'Eki': 'Oct',
  'Kas': 'Nov',
  'Ara': 'Dic',
  'Bildirim servisi bu platformda etkin değil.':
      'El servicio de notificaciones no está disponible en esta plataforma.',
  'Gider bildirimleri': 'Notificaciones de gastos',
  'Ödeme bildirimleri': 'Notificaciones de pagos',
  'Günlük gider kaydı bildirimleri':
      'Notificaciones diarias para registrar gastos',
  'Tüm kayıt türlerinin son ödeme bildirimleri':
      'Notificaciones de vencimiento para todos los tipos de registro',
  'Android dışında gerçek zamanlama yapılmaz.':
      'La programación real solo está disponible en Android.',
  'Bildirim izni kapalı.': 'El permiso de notificaciones está desactivado.',
  'Dakik bildirim izni kapalı. Saat ve dakika doğruluğu için izni açın.':
      'El permiso de alarmas exactas está desactivado. Actívalo para recibir las notificaciones a la hora y al minuto seleccionados.',
  'Dakik bildirim izni verilmedi.':
      'No se concedió el permiso de alarmas exactas.',
  'Bildirim izni kapalı. Yeni bildirimler oluşturulmadı.':
      'El permiso de notificaciones está desactivado. No se crearon nuevas notificaciones.',
  'Dakik bildirim izni kapalı. Android mevcut dakik planları iptal eder; izin açıldığında plan yeniden kurulmalıdır.':
      'El permiso de alarmas exactas está desactivado. Android cancela las programaciones exactas existentes; el calendario debe reconstruirse cuando se conceda el permiso.',
  'Bildirim izni kapalı. Önce bildirim iznini açın.':
      'El permiso de notificaciones está desactivado. Actívalo primero.',
  'Dakik bildirim izni verilmedi. Test yaklaşık zamanda çalıştırılmayacak.':
      'No se concedió el permiso de alarmas exactas. La prueba no se ejecutará con una hora aproximada.',
  'MİZAN bildirim testi': 'Prueba de notificación de MİZAN',
  'Bu test, ayarlanan dakik bildirim sistemiyle oluşturuldu.':
      'Esta prueba se creó con el sistema configurado de notificaciones exactas.',
  'Yedek kayıt doğrulanamadı.': 'No se pudo verificar la copia de seguridad.',
  'Ana kayıt okunamadı; son sağlam yedek geri yüklendi.':
      'No se pudo leer el archivo de datos principal; se restauró la última copia de seguridad válida.',
  'Ana ve yedek kayıt dosyaları okunamadı. Dosyalar korunuyor.':
      'No se pudo leer ni el archivo de datos principal ni la copia de seguridad. Los archivos se han conservado.',
  'MİZAN kullanıma hazır. İlk kişi veya kaydı ekleyebilirsin.':
      'MİZAN está listo. Añade tu primera persona o registro para empezar.',
  'Geçici kayıt doğrulanamadı.': 'No se pudo verificar el guardado temporal.',
  'Kayıt doğrulaması başarısız oldu.': 'La verificación de los datos falló.',
  'Detayı gör': 'Ver detalles',
  'Not ekle': 'Añadir nota',
  'Bu kayda ait not bulunmuyor. Notlar ödeme açıklamalarından ayrı tutulur.':
      'No hay notas para este registro. Las notas se guardan por separado de las descripciones de pago.',
  'Notu sil': 'Eliminar nota',
  'Notları daralt': 'Contraer notas',
  'Not boş bırakılamaz.': 'La nota es obligatoria.',
  'Yalnızca bu not silinecek. Devam edilsin mi?':
      'Solo se eliminará esta nota. ¿Deseas continuar?',
  'Borç, ödeme ve giderlerin sade özeti. Detay görmek için kartlara dokunabilirsin.':
      'Resumen claro de tus deudas, pagos y gastos. Toca una tarjeta para ver los detalles.',
  'Bu Ayın Ödeme Durumu': 'Estado de pagos de este mes',
  'Gecikmiş ödemeler': 'Pagos vencidos',
  'Bugünkü normal gider': 'Gastos habituales de hoy',
  'Bu ay normal gider': 'Gastos habituales de este mes',
  'Bugünkü ödemelere yapılan gider': 'Pagos realizados hoy',
  'Bu ay ödemelere yapılan gider': 'Pagos realizados este mes',
  'Bugünkü toplam gider': 'Gasto total de hoy',
  'Normal giderler ile banka, şahıs, fatura, abonelik, kira ve taksit ödemelerinin toplamıdır.':
      'Incluye los gastos habituales y los pagos de deudas bancarias, deudas personales, facturas, suscripciones, alquileres y cuotas.',
  'Bu ay toplam gider': 'Gasto total de este mes',
  'Bu ayın normal giderleri ile kaydedilmiş tüm ödeme giderlerinin toplamıdır.':
      'Incluye los gastos habituales de este mes y todos los pagos registrados.',
  'Kritik ödemeler': 'Pagos críticos',
  'Gecikmiş veya yedi gün içinde vadesi gelen kayıtlar. Ayrıntı için satıra dokun.':
      'Registros vencidos o con vencimiento en los próximos siete días. Toca una fila para ver los detalles.',
  'Kritik ödeme yok': 'No hay pagos críticos',
  'Gecikmiş veya önümüzdeki yedi gün içinde vadesi gelen kayıt bulunmuyor.':
      'No hay registros vencidos ni con vencimiento en los próximos siete días.',
  'Uygulama boş ve kullanıma hazır':
      'La aplicación está vacía y lista para usar',
  'Örnek ödeme veya borç oluşturulmadı. Kayıtlar bölümünden ilk kişiyi ekleyerek başlayabilirsin.':
      'No se han creado pagos ni deudas de ejemplo. Empieza añadiendo tu primera persona en Registros.',
  'Gelir bilgileri': 'Información de ingresos',
  'Gelir ekle': 'Añadir ingreso',
  'Gelir kaydı opsiyoneldir. Borç ödemeleri ve giderler gelirden ayrı tutulur; net sonuç raporda hesaplanır.':
      'Registrar ingresos es opcional. Los pagos de deudas y los gastos se controlan por separado; el resultado neto se calcula en Informes.',
  'Gelir bilgisi belirtilmemiş': 'No se ha indicado información de ingresos',
  'Tek seferlik, günlük, haftalık veya aylık gelir ekleyebilirsin.':
      'Puedes añadir ingresos únicos, diarios, semanales o mensuales.',
  'Gelir yattı': 'Marcar como cobrado',
  'Son alınma işaretini geri al': 'Deshacer el último cobro',
  'Arşivden çıkar': 'Restaurar del archivo',
  'Arşivle': 'Archivar',
  'Geliri düzenle': 'Editar ingreso',
  'Gelir türü / adı': 'Tipo / nombre del ingreso',
  'Maaş, ek iş, kira geliri…':
      'Salario, trabajo adicional, ingreso por alquiler…',
  'Gelir türü boş bırakılamaz.': 'El tipo de ingreso es obligatorio.',
  'Gelir tutarı sıfırdan büyük olmalıdır.':
      'El importe del ingreso debe ser superior a cero.',
  'Gelir sıklığı': 'Frecuencia del ingreso',
  'Yatış gününü takip et': 'Controlar la fecha de cobro',
  'Opsiyoneldir. Planlanan gün ile gerçek alınma tarihi ayrı tutulur.':
      'Opcional. La fecha prevista y la fecha real de cobro se guardan por separado.',
  'Haftanın hangi günü yatıyor?': '¿Qué día de la semana se cobra?',
  'Her ayın kaçında yatıyor?': '¿Qué día del mes se cobra?',
  'Ay daha kısaysa o ayın son geçerli günü kullanılır.':
      'Si el mes tiene menos días, se usa el último día válido.',
  'Gelir başlangıç tarihini seçin': 'Selecciona la fecha de inicio del ingreso',
  'Gelir notu (opsiyonel)': 'Nota del ingreso (opcional)',
  'Salı': 'Martes',
  'Çarşamba': 'Miércoles',
  'Perşembe': 'Jueves',
  'Pazartesi': 'Lunes',
  'Cuma': 'Viernes',
  'Cumartesi': 'Sábado',
  'Pazar': 'Domingo',
  'Gün': 'Día',
  'Başlangıç': 'Inicio',
  'Arşivde': 'Archivado',
  'Gelirin gerçekten alındığı tarihi seçin':
      'Selecciona la fecha en la que se recibió realmente el ingreso',
  'Kalan toplam borç detayı': 'Detalles de la deuda total pendiente',
  'Her bölümün toplamı ayrı hesaplanır. Satıra dokunarak yalnız ilgili kayıtları görebilirsin.':
      'El total de cada sección se calcula por separado. Toca una fila para ver únicamente los registros correspondientes.',
  'Ödeme Durumu': 'Estado de pagos',
  'Açık planlanan kayıtlar ile bu ay gerçekten yapılan ödemeler ayrı gösterilir.':
      'Los registros programados pendientes y los pagos realizados este mes se muestran por separado.',
  'Açık planlanan ödemeler': 'Pagos programados pendientes',
  'Açık plan kalmadı': 'No quedan pagos programados pendientes',
  'Bu aya ait açık veya eksik ödeme bulunmuyor.':
      'No hay pagos pendientes o incompletos de este mes.',
  'Bu ay yapılan ödemeler': 'Pagos realizados este mes',
  'Yapılan ödeme yok': 'No se realizaron pagos',
  'Bu ay ödeme geçmişine kaydedilmiş işlem bulunmuyor.':
      'No hay operaciones registradas en el historial de pagos de este mes.',
  'Kayıt bulunmuyor': 'No se encontraron registros',
  'Bu başlığa ait açık ödeme kaydı yok.':
      'No hay pagos pendientes en esta sección.',
  'Gelir özeti': 'Resumen de ingresos',
  'Yönet': 'Gestionar',
  'Bu ay gelir': 'Ingresos de este mes',
  'Ödemeler sonrası kalan': 'Saldo después de los pagos',
  'Ödeme ve gider sonrası net': 'Neto después de pagos y gastos',
  'Ödemeler': 'Pagos',
  'Bütün harcamalar': 'Todos los gastos',
  'Bu ay': 'Este mes',
  'Son 30 gün': 'Últimos 30 días',
  'Son 90 gün': 'Últimos 90 días',
  'Tarih aralığı': 'Intervalo de fechas',
  'Tümü': 'Todo',
  'Harcamalar gün gün gruplanır; arama ve günlük toplam sıralaması uzun yıllarda da kontrollü çalışır.':
      'Los gastos se agrupan por día; la búsqueda y el orden por total diario siguen funcionando con fluidez incluso con datos de varios años.',
  'Bugün': 'Hoy',
  'Filtreleme ve arama': 'Filtros y búsqueda',
  'Tarih, gün adı, gider, kategori veya not yazabilirsiniz. Türkçe karakterler ve bitişik ifadeler eşleşir.':
      'Puedes buscar por fecha, día de la semana, gasto, categoría o nota. Se admiten caracteres acentuados y términos escritos sin espacios.',
  'Gider veya tarih ara': 'Buscar gastos o fechas',
  'Araç, yoğurt, 23.07.2026, Perşembe…': 'Coche, yogur, 23/07/2026, jueves…',
  'Günleri sırala': 'Ordenar días',
  'Tüm kategoriler': 'Todas las categorías',
  'Kategori ekle': 'Añadir categoría',
  'Önce kategori ekleyin': 'Añade primero una categoría',
  'Market, ulaşım veya kullanıcıya özel başka bir kategori ekledikten sonra gider kaydı oluşturabilirsiniz.':
      'Después de añadir una categoría, como Supermercado, Transporte o cualquier categoría personalizada, podrás crear un gasto.',
  'Eşleşen gider bulunamadı': 'No se encontraron gastos coincidentes',
  'Seçili kategori, dönem ve arama ifadesine uyan kayıt yok.':
      'No hay registros que coincidan con la categoría, el periodo y la búsqueda seleccionados.',
  'Daha fazla gün göster': 'Mostrar más días',
  'Bütün harcamalar görünümünde günlük harcamalar ve ödemeler ayrı başlıklar altında tutulur; yalnız toplamları birlikte hesaplanır.':
      'En Todos los gastos, los gastos diarios y los pagos se mantienen en secciones separadas; solo se combinan sus totales.',
  'Tarih aralığı seçin': 'Seleccionar intervalo de fechas',
  'Gider kategorileri': 'Categorías de gastos',
  'Kategori silinirse yalnız o kategoriye bağlı giderler açık onayla silinir.':
      'Al eliminar una categoría, solo se borran los gastos vinculados a ella y únicamente tras una confirmación explícita.',
  'Kategoriyi düzenle': 'Editar categoría',
  'Kategori adı boş bırakılamaz.': 'El nombre de la categoría es obligatorio.',
  'Kategoriyi sil': 'Eliminar categoría',
  'ONAYLIYORUM yazın': 'Escribe CONFIRMO',
  'Tam olarak ONAYLIYORUM yazılmalı.': 'Debes escribir CONFIRMO exactamente.',
  'Gideri düzenle': 'Editar gasto',
  'Gider adı boş bırakılamaz.': 'El nombre del gasto es obligatorio.',
  'Adet / miktar': 'Cantidad / medida',
  'Birim fiyat negatif olamaz.': 'El precio unitario no puede ser negativo.',
  'Gideri sil': 'Eliminar gasto',
  'Banka / kredi': 'Banco / crédito',
  'Kişisel / kurumsal': 'Personal / empresarial',
  'Ödeme bulunamadı': 'No se encontraron pagos',
  'Seçili filtrede kaydedilmiş ödeme yok.':
      'No hay pagos registrados para el filtro seleccionado.',
  'Daha fazla ödeme günü göster': 'Mostrar más días de pago',
  'Kategori bulunamadı': 'No se encontró la categoría',
  'Bu günden daha fazla göster': 'Mostrar más a partir de este día',
  'Gider işlemleri': 'Acciones de gasto',
  'Önce kişiyi seç, ardından kayıt türünü aç. Her bölüm birbirinden bağımsız tutulur.':
      'Selecciona primero una persona y después abre un tipo de registro. Cada sección se gestiona de forma independiente.',
  'Kişi ekle': 'Añadir persona',
  'Henüz kişi yok': 'Todavía no hay personas',
  'Kayıtların birbirine karışmaması için önce ödeme ve gider kayıtlarının sahibi olacak kişiyi ekleyin.':
      'Añade primero a la persona a la que pertenecerán los pagos y los gastos para mantener los registros separados.',
  'İlk kişiyi ekle': 'Añadir la primera persona',
  'Kişisel ve Kurumsal Borçlar': 'Deudas personales y empresariales',
  'Kişi, şirket/kurum, çek, senet, esnaf/işletme, aile/yakın ve diğer alacaklılar':
      'Personas, empresas/organizaciones, cheques, pagarés, comercios/negocios, familiares/personas cercanas y otros acreedores',
  'Kişisel / kurumsal borç ekle': 'Añadir deuda personal / empresarial',
  'Banka dışı borç kaydı bulunmuyor.': 'No se encontraron deudas no bancarias.',
  'Elektrik, su, telefon, internet, doğalgaz ve özel faturalar':
      'Electricidad, agua, teléfono, internet, gas natural y facturas personalizadas',
  'Fatura ekle': 'Añadir factura',
  'Fatura kaydı bulunmuyor.': 'No se encontraron facturas.',
  'Belirli aralıklarla tekrarlayan dijital hizmet, üyelik, sigorta, eğitim ve bakım ödemeleri':
      'Servicios digitales, membresías, seguros, educación y pagos de mantenimiento recurrentes',
  'Abonelik ekle': 'Añadir suscripción',
  'Abonelik kaydı bulunmuyor.': 'No se encontraron suscripciones.',
  'Kira ve Taksitler': 'Alquileres y cuotas',
  'Ev/iş yeri kirası, ürün taksiti ve düzenli ödeme planları':
      'Alquiler de vivienda o local, compras a plazos y planes de pago periódicos',
  'Kira / taksit ekle': 'Añadir alquiler / cuota',
  'Kira veya taksit kaydı bulunmuyor.':
      'No se encontraron alquileres ni cuotas.',
  'Tek dönem': 'Un solo periodo',
  'Bu dönem': 'Este periodo',
  'Ödenmemiş toplam': 'Total pendiente',
  'Kayıt sahibi': 'Titular del registro',
  'Aşağıdaki bütün kayıtlar yalnızca seçili kişiye aittir.':
      'Todos los registros siguientes pertenecen únicamente a la persona seleccionada.',
  'Kişi seçin': 'Seleccionar persona',
  'Kalan toplam': 'Total pendiente',
  'Bu ay planlanan': 'Programado este mes',
  'Gecikmiş kayıt': 'Registro vencido',
  'Kişi detaylarını aç': 'Abrir detalles de la persona',
  'Arşivdekileri göster': 'Mostrar registros archivados',
  'Kişi kaydı bulunamadı.': 'No se encontró el registro de la persona.',
  'Gecikmiş kayıtlar': 'Registros vencidos',
  'Bu başlıkta kayıt bulunmuyor.': 'No hay registros en esta sección.',
  'Kişi detayları': 'Detalles de la persona',
  'Bu kişiye ait kayıtlar': 'Registros de esta persona',
  'Bu kişiye bağlı açık ödeme kaydı yok.':
      'No hay pagos pendientes vinculados a esta persona.',
  'Kişiyi düzenle': 'Editar persona',
  'Kişiyi sil': 'Eliminar persona',
  'Banka Borçları': 'Deudas bancarias',
  'Banka grubu ekle': 'Añadir grupo bancario',
  'Banka borcu yok': 'No hay deuda bancaria',
  'Banka adı kullanıcı tarafından yazılır. Hazır banka markası veya logosu kullanılmaz.':
      'El nombre del banco lo introduce el usuario. No se utilizan marcas ni logotipos bancarios predefinidos.',
  'Banka grubu işlemleri': 'Acciones del grupo bancario',
  'Banka grubunu sil': 'Eliminar grupo bancario',
  'Grubu sil': 'Eliminar grupo',
  'Borç ekle': 'Añadir deuda',
  'Grubu düzenle': 'Editar grupo',
  'Bu banka grubunda görüntülenecek borç bulunmuyor.':
      'No hay deudas que mostrar en este grupo bancario.',
  'Toplam ödeme': 'Total pagado',
  'Ödeme ekle': 'Añadir pago',
  'Kayıt bilgileri': 'Detalles del registro',
  'Ödeme geçmişi': 'Historial de pagos',
  'Yalnızca bu kayda bağlı ödemeler':
      'Pagos vinculados únicamente a este registro',
  'Ödeme yok': 'No hay pagos',
  'Bu kayda henüz ödeme eklenmedi.':
      'Todavía no se han añadido pagos a este registro.',
  'Ödemeyi sil': 'Eliminar pago',
  'Ödeme planı': 'Plan de pagos',
  'Kalan borç': 'Deuda pendiente',
  'Ödeme tarihi': 'Fecha de pago',
  'Gecikme': 'Retraso',
  'Ödenmeyen aylar': 'Meses impagados',
  'Kalan taksit sayısı': 'Cuotas pendientes',
  'Borç tarihi': 'Fecha de la deuda',
  'Ödeme sıklığı': 'Frecuencia de pago',
  'Düzenli ödeme': 'Pago periódico',
  'Çek no': 'N.º de cheque',
  'Senet no': 'N.º de pagaré',
  'Kalan fatura': 'Factura pendiente',
  'Fatura düzeni': 'Calendario de facturación',
  'Ödeme günü': 'Día de pago',
  'İlk fatura ayı': 'Primer mes de facturación',
  'Kayıtlı değişken tutarlar': 'Importes variables guardados',
  'Abone no': 'N.º de abonado',
  'Sözleşme / tesisat no': 'N.º de contrato / instalación',
  'Bu dönem kalan': 'Pendiente de este periodo',
  'Tekrar sıklığı': 'Frecuencia de repetición',
  'Sözleşme no': 'N.º de contrato',
  'Kalan tutar': 'Importe pendiente',
  'Kayıt türü': 'Tipo de registro',
  'İlk ödeme ayı': 'Primer mes de pago',
  'Sözleşme başlangıcı': 'Inicio del contrato',
  'Sözleşme bitişi': 'Fin del contrato',
  'Kaydı sil': 'Eliminar registro',
  'Bu işlem yalnız açık onayla yapılır.':
      'Esta acción requiere una confirmación explícita.',
  'Toplam taksit': 'Total de cuotas',
  'Kalan taksit sayısı toplam taksit sayısını aşamaz.':
      'El número de cuotas pendientes no puede superar el número total de cuotas.',
  'Kalan taksit sayısı, kayıtlı taksit ödemeleriyle uyumlu değil.':
      'El número de cuotas pendientes no coincide con los pagos de cuotas registrados.',
  'Hazır marka listesi yoktur; adı kullanıcı belirler.':
      'No hay una lista de marcas predefinida; el usuario introduce el nombre.',
  'Borç ürünü ekle': 'Añadir deuda bancaria',
  'Borç ürününü düzenle': 'Editar deuda bancaria',
  'Borç türü': 'Tipo de deuda',
  'Başlık': 'Título',
  'Ödeme tarihi yöntemi': 'Método de fecha de vencimiento',
  'Her ayın kaçıncı günü?': '¿Qué día de cada mes?',
  '1 ile 31 arasında bir gün girin.': 'Introduce un día entre 1 y 31.',
  'Aylık ödeme günü 1 ile 31 arasında olmalıdır.':
      'El día de pago mensual debe estar entre 1 y 31.',
  'İlk geçerli vade': 'Primer vencimiento válido',
  'Güncel manuel gecikme günü': 'Días de retraso manuales actuales',
  'Yeni manuel gecikme günü (opsiyonel)':
      'Nuevos días de retraso manuales (opcional)',
  'Takvimle otomatik artar. Diğer alanları kaydetmek bu gecikme referansını değiştirmez.':
      'Aumenta automáticamente con el calendario. Guardar otros campos no modifica esta referencia de retraso.',
  'Değer değiştirilirse referans tarihi bugün esas alınarak gecikme, bildirim ve rapor hesapları yeniden kurulur.':
      'Si se modifica, los cálculos de retrasos, notificaciones e informes se reconstruyen usando hoy como fecha de referencia.',
  'Gecikme düzenlemesi açık': 'Ajuste de retraso activado',
  'Gecikme gününü değiştir': 'Cambiar días de retraso',
  'Gecikme günü 0 ile 3650 arasında olmalıdır.':
      'Los días de retraso deben estar entre 0 y 3650.',
  'Kalan taksit sayısı (opsiyonel)': 'Cuotas pendientes (opcional)',
  'Ödeme kaydı eklendikçe otomatik azalır.':
      'Disminuye automáticamente a medida que se registran pagos.',
  'Limit (opsiyonel)': 'Límite (opcional)',
  'Belirtilmemiş': 'No especificado',
  'Kaldırılacak': 'Se eliminará',
  'Gecikme hesabını yeniden kur': 'Reconstruir cálculo de retrasos',
  'Bu işlem referans tarihini bugün esas alarak vade, gecikme, bildirim, rapor ve ödeme hesaplarını yeniden hesaplayacaktır.':
      'Esta acción volverá a calcular las fechas de vencimiento, los retrasos, las notificaciones, los informes y los pagos usando hoy como fecha de referencia.',
  'Değişikliği onayla': 'Confirmar cambio',
  'Gecikmiş aylar (opsiyonel)': 'Meses vencidos (opcional)',
  'Ödenmeyen ayları seç. Gecikme, seçilen en eski ayın ödeme gününden bugüne otomatik hesaplanır.':
      'Selecciona los meses impagados. El retraso se calcula automáticamente desde el día de pago del mes más antiguo seleccionado hasta hoy.',
  'Gecikmiş ay ekle': 'Añadir mes vencido',
  'Ay ve yıl seç': 'Seleccionar mes y año',
  'Yıl': 'Año',
  'Seç': 'Seleccionar',
  'Faturayı düzenle': 'Editar factura',
  'Fatura türü': 'Tipo de factura',
  'Varsayılan aylık tutar': 'Importe mensual predeterminado',
  'Her ayın kaçında ödenecek? (1-31)': '¿Qué día del mes vence? (1–31)',
  '29, 30 veya 31 seçildiğinde kısa aylarda ayın son geçerli günü kullanılır.':
      'Si se selecciona 29, 30 o 31, en los meses más cortos se utiliza el último día válido.',
  'Girilen tutarın ait olduğu ay':
      'Mes al que corresponde el importe introducido',
  'Elektrik, su, doğalgaz ve benzeri faturaların tutarı her ay ayrı kaydedilir. Geçmiş ayların tutarı değiştirilmeden raporlarda gerçek ödeme kayıtları kullanılır.':
      'Los importes de electricidad, agua, gas natural y facturas similares se guardan por separado para cada mes. Los informes utilizan los pagos reales sin modificar los importes de meses anteriores.',
  'Tesisat / sözleşme numarası': 'Número de instalación / contrato',
  'Kira / taksiti düzenle': 'Editar alquiler / cuota',
  'Kira başlığı': 'Título del alquiler',
  'Ürün / taksit başlığı': 'Título del producto / cuota',
  'Aylık kira tutarı': 'Importe mensual del alquiler',
  'Toplam ürün bedeli': 'Precio total del producto',
  'Aylık ödeme tutarı': 'Importe del pago mensual',
  'Toplam tutar': 'Importe total',
  'Her ay tekrarlayan ödeme': 'Pago mensual recurrente',
  'Kapalıysa kayıt tek ödeme olarak değerlendirilir.':
      'Si está desactivado, el registro se considera un pago único.',
  '15 veya 20 gibi yalnız gün numarasını yazın; MİZAN takvimi kendisi takip eder.':
      'Introduce solo el número del día, como 15 o 20; MİZAN se encargará de seguir el calendario.',
  'Ev sahibi / alıcı': 'Arrendador / beneficiario',
  'Alıcı / satıcı adı': 'Nombre del beneficiario / vendedor',
  'IBAN (opsiyonel)': 'IBAN (opcional)',
  'Sözleşme başlangıcı (opsiyonel)': 'Inicio del contrato (opcional)',
  'Sözleşme bitişi (opsiyonel)': 'Fin del contrato (opcional)',
  'Kira artış tarihi (opsiyonel)': 'Fecha de aumento del alquiler (opcional)',
  'Toplam taksit (opsiyonel)': 'Total de cuotas (opcional)',
  'Toplam taksit sayısını girin.': 'Introduce el número total de cuotas.',
  'Kalan taksit (opsiyonel)': 'Cuotas pendientes (opcional)',
  'Son ödeme tarihi takvimden sabitlenmez. Girilen ödeme günü ve ilk ödeme ayı esas alınır; sonraki aylar gerçek takvime göre otomatik hesaplanır.':
      'La fecha de vencimiento no queda fijada a una única fecha del calendario. Se utilizan el día de pago y el primer mes de pago introducidos; los meses siguientes se calculan automáticamente según el calendario real.',
  'Kişisel / kurumsal borcu düzenle': 'Editar deuda personal / empresarial',
  'Alacaklı türü': 'Tipo de acreedor',
  'Borcun oluştuğu tarih': 'Fecha de origen de la deuda',
  'Taksitli ödeme planı': 'Plan de pago a plazos',
  'Açıksa taksit sayısı ve düzenli ödeme tutarı saklanır.':
      'Si está activado, se guardan el número de cuotas y el importe del pago periódico.',
  'Özel ödeme aralığı (gün)': 'Intervalo de pago personalizado (días)',
  'Gün sayısını girin.': 'Introduce el número de días.',
  'Toplam taksiti girin.': 'Introduce el total de cuotas.',
  'Ödeme kaydı eklendikçe kalan taksit sayısı otomatik azalır.':
      'El número de cuotas pendientes disminuye automáticamente a medida que se registran pagos.',
  'Çeki düzenleyen kişi / kurum': 'Persona / entidad emisora del cheque',
  'Banka bilgisi (kullanıcı girişi)':
      'Información bancaria (introducida por el usuario)',
  'Senet adedi': 'Número de pagarés',
  'Mevcut senet': 'Pagaré actual',
  'Birden fazla senet varsa her biri ayrı vade satırı olarak oluşturulur.':
      'Si hay varios pagarés, cada uno se crea como una fila de vencimiento independiente.',
  'Aboneliği düzenle': 'Editar suscripción',
  'Özel tür adı': 'Nombre del tipo personalizado',
  'Dönem tutarı': 'Importe por periodo',
  'Özel tekrar aralığı (gün)': 'Intervalo de repetición personalizado (días)',
  'Sıradaki ödeme tarihi': 'Próxima fecha de pago',
  'Bu kaydın planlanan taksit/dönem tutarı otomatik kullanılır.':
      'Se utiliza automáticamente el importe programado de la cuota/periodo de este registro.',
  'Kalan borcun tamamı ödeme tutarı olarak otomatik kullanılır.':
      'Se utiliza automáticamente todo el saldo pendiente como importe del pago.',
  'Kalan borcu aşmayacak ödeme tutarını kendin girebilirsin.':
      'Puedes introducir un importe de pago que no supere el saldo pendiente.',
  'Ödemeyi düzenle': 'Editar pago',
  'Ödeme türü': 'Tipo de pago',
  'Ödeme tutarı kalan borçtan büyük olamaz.':
      'El importe del pago no puede superar el saldo pendiente.',
  'Otomatik tutar ödeme türüne göre hesaplandı. Kısmi ödeme seçilirse elle değiştirilebilir.':
      'El importe se calculó automáticamente según el tipo de pago. Puede editarse al seleccionar Pago parcial.',
  'Ödeme yöntemi (opsiyonel)': 'Método de pago (opcional)',
  'Ödeme notu (opsiyonel)': 'Nota del pago (opcional)',
  'Seçilmedi': 'Sin seleccionar',
  'Tarihi temizle': 'Borrar fecha',
  'Ödemeleri, giderleri ve kalan yükü aynı filtreyle doğru ve ayrıntılı gösterir.':
      'Muestra con precisión y detalle los pagos, los gastos y las obligaciones pendientes usando el mismo filtro.',
  'Ödemelere yapılan gider': 'Pagos realizados',
  'Normal giderler': 'Gastos habituales',
  'Kalan ödeme yükü': 'Obligaciones de pago pendientes',
  'Gecikmiş': 'Vencido',
  'Gelir ayrıntıları': 'Detalles de ingresos',
  'Serbest girilen gelir türleri ve seçili döneme düşen tutarları gösterilir.':
      'Muestra los tipos de ingreso introducidos por el usuario y los importes correspondientes al periodo seleccionado.',
  'Seçili dönemde gelir oluşmuyor.':
      'No hay ingresos en el periodo seleccionado.',
  'Gelir bilgisi belirtilmemiş.': 'No se ha indicado información de ingresos.',
  'Gerçekleşen harcamaların dağılımı': 'Distribución del gasto real',
  'Günlük harcamalar ve ödeme geçmişi ayrı kaynaklar olarak, en yüksek tutardan en düşüğe sıralanır.':
      'Los gastos diarios y el historial de pagos se tratan como fuentes separadas y se ordenan de mayor a menor importe.',
  'Gerçekleşen ödeme ayrıntıları': 'Detalles de pagos registrados',
  'Kişi, kayıt, ödeme türü, tarih ve tutar birbirine karışmadan listelenir.':
      'La persona, el registro, el tipo de pago, la fecha y el importe se muestran sin mezclar sus relaciones.',
  'Seçili kapsamda gerçekleşen ödeme bulunmuyor.':
      'No se encontraron pagos registrados con los filtros seleccionados.',
  'Kalan ödeme yükünün dağılımı': 'Distribución de pagos pendientes',
  'Toplam borcun tamamı değil, seçili döneme düşen sıradaki ödeme ve taksit tutarları gösterilir.':
      'Muestra los próximos pagos y cuotas que corresponden al periodo seleccionado, no el saldo total de la deuda.',
  'Kalan ödeme ayrıntıları': 'Detalles de pagos pendientes',
  'Seçili dönemde açık ödeme yükü bulunmuyor.':
      'No hay obligaciones de pago pendientes en el periodo seleccionado.',
  'Gider dağılımı': 'Distribución de gastos',
  'Normal giderler ile ödeme kayıtları aynı toplamda yer alır; kaynak türleri ayrı etiketlerle gösterilir.':
      'Los gastos habituales y los pagos registrados se incluyen en el mismo total, pero sus tipos de origen se muestran con etiquetas separadas.',
  'Seçili dönemde gider veya ödeme kaydı yok.':
      'No hay gastos ni pagos registrados en el periodo seleccionado.',
  'Bütün harcama ayrıntıları': 'Detalles de todos los gastos',
  'Her gün başlık olarak gösterilir. Başlığa dokununca günlük harcamalar ve ödemeler kendi bölümlerinde açılır.':
      'Cada día se muestra como encabezado. Tócalo para desplegar los gastos y pagos diarios en sus propias secciones.',
  'Seçili dönemde gider veya ödeme ayrıntısı bulunmuyor.':
      'No se encontraron detalles de gastos ni pagos en el periodo seleccionado.',
  'Kişi kapsamı': 'Personas incluidas',
  'Tüm kişileri kapsa': 'Incluir a todas las personas',
  'Bütün kişilerin ödeme ve borç kayıtları rapora alınır.':
      'El informe incluye los pagos y las deudas de todas las personas.',
  'PDF hazırlanıyor.': 'Preparando PDF.',
  'MİZAN PDF raporunu kaydet': 'Guardar informe PDF de MİZAN',
  'PDF raporu kaydedildi.': 'Informe PDF guardado.',
  'PDF raporu kaydedilemedi': 'No se pudo guardar el informe PDF',
  'PDF raporu paylaşılamadı': 'No se pudo compartir el informe PDF',
  'Normal gider ayrıntıları': 'Detalles de gastos habituales',
  'Ödeme ayrıntıları': 'Detalles de pagos',
  'Kalan ödeme yükü ayrıntıları': 'Detalles de pagos pendientes',
  'Gecikmiş ödeme ayrıntıları': 'Detalles de pagos vencidos',
  'Yaklaşan ödeme ayrıntıları': 'Detalles de próximos pagos',
  'Normal giderler ve ödemeler ayrı başlıklar altında kalır; yalnız toplam hesaplamada birleşir.':
      'Los gastos habituales y los pagos permanecen bajo encabezados separados y solo se combinan al calcular los totales.',
  'Seçili döneme taşınan gecikmiş kayıtlar ile dönemin açık ödeme yükü ayrıntılı gösterilir.':
      'Muestra en detalle los registros vencidos arrastrados al periodo seleccionado junto con las obligaciones de pago pendientes del periodo.',
  'Gecikmiş tutar, açık ve ödenmemiş dönemlerin toplamıdır.':
      'El importe vencido es la suma de los periodos abiertos e impagados.',
  'Raporun referans gününden itibaren önümüzdeki 7 gün içinde vadesi kalan açık kayıtlar gösterilir.':
      'Muestra los registros abiertos que vencen en los siete días posteriores a la fecha de referencia del informe.',
  'Seçili kapsamda ayrıntı bulunmuyor.':
      'No se encontraron detalles con los filtros seleccionados.',
  'Tüm kişiler': 'Todas las personas',
  'Rapor kapsamı': 'Contenido del informe',
  'Dönem ve kişi filtresi ekrandaki verilerle PDF’de birebir aynıdır.':
      'Los filtros de periodo y personas son exactamente los mismos en el informe de pantalla y en el PDF.',
  'Tüm kayıt geçmişi': 'Historial completo de registros',
  'Kayıtlı ay bulunmuyor': 'No se encontraron meses guardados',
  'Kayıtlı yıl bulunmuyor': 'No se encontraron años guardados',
  'Güncel ay her zaman açılır; geçmişte kayıt, ödeme, gider veya gelir bulunan aylar ayrıca seçilebilir.':
      'El mes actual siempre está disponible; también puedes seleccionar meses anteriores que contengan registros, pagos, gastos o ingresos.',
  'Güncel yıl her zaman açılır; kayıt bulunan geçmiş yıllar ayrıca seçilebilir.':
      'El año actual siempre está disponible; también puedes seleccionar años anteriores que contengan registros.',
  'İlk kayıttan bugüne kadar bütün ödeme, gider ve gelir hareketleri kapsanır.':
      'Incluye toda la actividad de pagos, gastos e ingresos desde el primer registro hasta hoy.',
  'Kalan kayıt durumu (opsiyonel)': 'Estado de registros pendientes (opcional)',
  'Tüm durumlar': 'Todos los estados',
  'Gider kayıtlarında kişi alanı bulunmadığı için giderler seçili dönem kapsamında ve kişi filtresinden bağımsız hesaplanır.':
      'Como los gastos no tienen un campo de persona, se calculan para el periodo seleccionado de forma independiente al filtro de personas.',
  'Kayıtlı yılı seç': 'Seleccionar un año guardado',
  'Kayıtlı ayı seç': 'Seleccionar un mes guardado',
  'Gelir ve net durum': 'Ingresos y posición neta',
  'Gelirden gerçekleşen ödemeler ve giderler sırayla düşülür.':
      'Los pagos registrados y los gastos se descuentan de los ingresos en orden.',
  'PDF raporu': 'Informe PDF',
  'Aynı raporu kaydedebilir veya WhatsApp dahil paylaşım menüsüne gönderebilirsin.':
      'Puedes guardar el mismo informe o enviarlo al menú para compartir, incluido WhatsApp.',
  'PDF hazırlanıyor': 'Preparando PDF',
  'PDF indir': 'Descargar PDF',
  'PDF paylaş': 'Compartir PDF',
  'Seçili dönem gider özeti': 'Resumen de gastos del periodo seleccionado',
  'Bütün harcamalar, normal giderler ile banka, şahıs, fatura, abonelik, kira ve taksit ödemelerinin toplamıdır.':
      'Todos los gastos son la suma de los gastos habituales y los pagos de deudas bancarias, deudas personales, facturas, suscripciones, alquileres y cuotas.',
  'Normal giderler ile banka, şahıs, fatura, abonelik, kira ve taksit ödemelerine yapılan giderlerin toplamıdır. Gelir ayrı gösterilir.':
      'Suma de los gastos habituales y los pagos de deudas bancarias, deudas personales, facturas, suscripciones, alquileres y cuotas. Los ingresos se muestran por separado.',
  'Gelir sonrası net': 'Saldo neto tras los ingresos',
  'Kayıt bulunmuyor.': 'No se encontraron registros.',
  'Daha fazla gider günü göster': 'Mostrar más días de gastos',
  'Kişi bazında güncel kalan borç': 'Deuda pendiente actual por persona',
  'Kişi ve kayıt türü başlıklarına dokunarak ayrıntıları açıp kapatabilirsiniz. Kayıt satırına dokununca tam kayıt detayı açılır.':
      'Toca los encabezados de persona y tipo de registro para desplegar o contraer los detalles. Toca una fila para abrir los detalles completos del registro.',
  'Toplam kalan': 'Total pendiente',
  'Hafta': 'Semana',
  'Tüm zamanlar': 'Todo el historial',
  'PDF rapor sayfası görüntüye dönüştürülemedi.':
      'La página del informe PDF no pudo convertirse en imagen.',
  'Sayfa': 'Página',
  'finans raporu': 'informe financiero',
  'Kayıtlı kişi yok': 'No hay personas guardadas',
  'GÜN BAŞLIĞI': 'ENCABEZADO DEL DÍA',
  'Rapor özeti': 'Resumen del informe',
  'Ödeme kayıtları ve Giderler bölümü birbirine karıştırılmadan hesaplanır.':
      'Los pagos registrados y la sección Gastos se calculan sin mezclar sus fuentes.',
  'Ödemeler sonrası kalan gelir': 'Ingresos restantes después de los pagos',
  'Toplam gider sonrası net': 'Neto después del gasto total',
  'Seçili dönemde kalan ödeme yükü':
      'Obligaciones de pago pendientes en el periodo seleccionado',
  'Gecikmiş ödeme yükü': 'Obligaciones de pago vencidas',
  'Yaklaşan ödeme yükü': 'Próximas obligaciones de pago',
  'Gelir türleri seçili döneme düşen tekrar sayısına göre hesaplanır.':
      'Los tipos de ingreso se calculan según el número de repeticiones que correspondan al periodo seleccionado.',
  'Seçili dönem ve kişi kapsamındaki ödeme geçmişi kayıt türüne göre ayrılır.':
      'El historial de pagos del periodo y de las personas seleccionadas se separa por tipo de registro.',
  'Her ödeme yalnız bağlı olduğu kişi ve kayıt altında gösterilir.':
      'Cada pago se muestra únicamente bajo la persona y el registro a los que está vinculado.',
  'Gecikmiş kayıtlarda gösterilen taksit ve ana para tutarlarına işleyebilecek faizler, gecikme bedelleri ve diğer olası durum etkenleri dahil değildir.':
      'Los importes de cuotas y capital mostrados en los registros vencidos no incluyen posibles intereses, recargos por demora ni otros factores que puedan aplicarse.',
  'Ödeme kayıtları': 'Pagos registrados',
  'Normal giderler ve ödeme kayıtları aynı rapor toplamına dahil edilir; kaynakları birbirine karıştırılmadan ayrı renklerle gösterilir.':
      'Los gastos habituales y los pagos registrados se incluyen en el mismo total del informe y se muestran con colores separados sin mezclar sus fuentes.',
  'Seçili dönemde gider veya ödeme kaydı bulunmuyor.':
      'No hay gastos ni pagos registrados en el periodo seleccionado.',
  'Günler başlık olarak gösterilir; her günün normal harcamaları ve ödemeleri kendi bölümünde, satır taşması olmadan listelenir.':
      'Los días se muestran como encabezados; los gastos habituales y los pagos de cada día aparecen en sus propias secciones sin desbordamiento de texto.',
  'Seçili dönemde gider ayrıntısı bulunmuyor.':
      'No se encontraron detalles de gastos en el periodo seleccionado.',
  'Toplam borcun tamamı değil, seçili döneme düşen sıradaki ödeme/taksit tutarları gösterilir.':
      'Muestra los próximos importes de pago/cuota que correspondan al periodo seleccionado, no el saldo total de la deuda.',
  'Vade, kişi, kayıt türü, gecikme süresi ve sıradaki ödeme tutarı birlikte sunulur.':
      'La fecha de vencimiento, la persona, el tipo de registro, la duración del retraso y el próximo importe de pago se muestran juntos.',
  'Seçili kişilerin bütün açık kayıtları, dönem filtresinden bağımsız güncel bakiye olarak sunulur.':
      'Todos los registros abiertos de las personas seleccionadas se muestran como saldos actuales, independientemente del filtro de periodo.',
  'Toplam güncel kalan borç': 'Deuda pendiente actual total',
  'Bildirim davranışı, yerel kayıt güvenliği ve yedekleme seçenekleri':
      'Comportamiento de las notificaciones, seguridad de los datos locales y opciones de copia de seguridad',
  'Bildirim sistemi açık': 'Sistema de notificaciones activado',
  'özel bildirim saati': 'horas de notificación personalizadas',
  'Hatırlatmayı düzenle': 'Editar recordatorio',
  'Durum ve saat': 'Estado y hora',
  'Bildirim saatini seç': 'Seleccionar hora de notificación',
  'Saat ve dakika': 'Hora y minuto',
  'Hatırlatma açık': 'Recordatorio activado',
  'Seçilen vade günlerinde planlanır.':
      'Se programa en las fechas de vencimiento seleccionadas.',
  'Kayıt korunur ancak bildirim oluşturulmaz.':
      'El registro se conserva, pero no se crea ninguna notificación.',
  'Dakik bildirim izni kapalı':
      'El permiso de alarmas exactas está desactivado',
  'MİZAN yaklaşık zamanlama kullanmaz. Kaydettiğinde gerekli Android izin ekranı otomatik açılır; izin verildiğinde bildirimler uygulamaya dönüşte otomatik senkronize edilir.':
      'MİZAN no utiliza horarios aproximados. Al guardar, se abre automáticamente la pantalla del permiso necesario de Android; cuando se concede, las notificaciones se sincronizan al volver a la aplicación.',
  '1 dakika sonra test bildirimi': 'Notificación de prueba en 1 minuto',
  'Bu hatırlatmayı sil': 'Eliminar este recordatorio',
  'Ses ve titreşim davranışı': 'Comportamiento del sonido y la vibración',
  'Bildirim sesi': 'Sonido de notificación',
  'Titreşim': 'Vibración',
  'Sessiz ses seçildiğinde titreşim de kullanılmaz.':
      'La vibración también se desactiva al seleccionar Silencio.',
  'Hatırlatmayı sil': 'Eliminar recordatorio',
  'Diğer hatırlatmalar ve kayıtlar etkilenmez.':
      'Los demás recordatorios y registros no se verán afectados.',
  'MİZAN CSV yedeğini kaydet': 'Guardar copia de seguridad CSV de MİZAN',
  'CSV yedeği oluşturuldu.': 'Copia de seguridad CSV creada.',
  'CSV yedeği oluşturulamadı': 'No se pudo crear la copia de seguridad CSV',
  'MİZAN CSV yedeğini seç': 'Seleccionar copia de seguridad CSV de MİZAN',
  'Seçilen CSV dosyası okunamadı.':
      'No se pudo leer el archivo CSV seleccionado.',
  'CSV yedeği birleştirilemedi':
      'No se pudo combinar la copia de seguridad CSV',
  'CSV yedeğini birleştir': 'Combinar copia de seguridad CSV',
  'Mevcut kayıtlar silinmeyecek veya yedekteki ortak verilerle yeniden yazılmayacak. Yalnız yeni kayıtlar ve eksik alt ilişkiler eklenecek.':
      'Los registros existentes no se eliminarán ni se sobrescribirán con datos coincidentes de la copia de seguridad. Solo se añadirán registros nuevos y relaciones secundarias que falten.',
  'Yeni eklenecek': 'Nuevos registros que se añadirán',
  'Eksik ilişkisi tamamlanacak': 'Relaciones que se completarán',
  'Ortak kullanıcı kaydı: Yok': 'Registros de usuario coincidentes: ninguno',
  'Ortak kullanıcı kaydı atlanacak':
      'Registros de usuario coincidentes que se omitirán',
  'Verileri birleştir': 'Combinar datos',
  'Bu alan boş bırakılamaz.': 'Este campo es obligatorio.',
  'Sabah gider': 'Gastos de la mañana',
  'Bugünkü giderlerini işlemeyi unutma.':
      'No olvides registrar los gastos de hoy.',
  'Öğlen gider': 'Gastos del mediodía',
  'Öğlene kadar yaptığın harcamaları ekleyebilirsin.':
      'Puedes añadir los gastos realizados antes del mediodía.',
  'Akşam gider': 'Gastos de la noche',
  'Günü kapatmadan giderlerini kontrol et.':
      'Revisa tus gastos antes de terminar el día.',
  'Günün ödeme planını gözden geçir.': 'Revisa el plan de pagos de hoy.',
  'Kategori silmek için tam olarak ONAYLIYORUM yazılmalı.':
      'Debes escribir CONFIRMO exactamente para eliminar la categoría.',
  'CSV yedeği doğrulandı ve geri yüklendi.':
      'La copia de seguridad CSV se verificó y restauró.',
  'CSV yedeği mevcut kayıtlarla birleştirildi: ':
      'La copia de seguridad CSV se combinó con los registros existentes: ',
  'Banka': 'Banco',
  'Borç': 'Deuda',
  'Kişisel/kurumsal borç': 'Deuda personal/empresarial',
  'Kira': 'Alquiler',
  'Gider': 'Gasto',
  'Eski kayıttan aktarıldı': 'Importado de un registro anterior',
  'Kalan toplam borç': 'Deuda total pendiente',
  'Gecikmiş toplam': 'Total vencido',
  'Önümüzdeki 7 gün': 'Próximos 7 días',
  'Gelir': 'Ingreso',
  'Abonelikler': 'Suscripciones',
  'Kategoriler': 'Categorías',
  'ONAYLIYORUM': 'CONFIRMO',
  'Kategori': 'Categoría',
  'Tutar': 'Importe',
  'Taksit': 'Cuota',
  'Ay': 'Mes',
  'Bildirim': 'Notificación',
  'CSV yedeği boş veya eksik.':
      'La copia de seguridad CSV está vacía o incompleta.',
  'Bu dosya MİZAN CSV yedeği değil.':
      'Este archivo no es una copia de seguridad CSV de MİZAN.',
  'CSV tam yedek verisi geçersiz.':
      'Los datos completos de la copia de seguridad CSV no son válidos.',
  'CSV içinde tam MİZAN yedeği bulunamadı.':
      'No se encontró una copia de seguridad completa de MİZAN en el archivo CSV.',
  'Kategorisiz': 'Sin categoría',
  'Günlük harcama': 'Gasto diario',
  'Ödeme': 'Pago',
  'LEFFERION PRIME - MIZAN': 'LEFFERION PRIME - MIZAN',
  'LEFFERION PRIME - MİZAN': 'LEFFERION PRIME - MIZAN',
  'maaş': 'salario',
  'Maaş': 'Salario',
  'Banka borçları': 'Deudas bancarias',
  'Kişisel ve kurumsal borçlar': 'Deudas personales y empresariales',
  'Kira ve taksitler': 'Alquileres y cuotas',
  'Daha fazla ödeme günü göster ': 'Mostrar más días de pago ',
  'Bu günden daha fazla göster ': 'Mostrar más a partir de este día ',
  'Günlük harcamalar': 'Gastos diarios',
  'Gider ekle': 'Añadir gasto',
  'Banka grubunu düzenle': 'Editar grupo bancario',
  'Daha fazla gider günü göster ': 'Mostrar más días de gastos ',
  'Kişi kaydı bulunmuyor.': 'No se encontraron registros de personas.',
  'MİZAN full backup': 'Copia de seguridad completa de MİZAN',
  'MİZAN tam yedek': 'Copia de seguridad completa de MİZAN',
  'Yeniden eskiye': 'Más recientes primero',
  'Eskiden yeniye': 'Más antiguos primero',
  'En yüksek harcama günü': 'Día con mayor gasto',
  'En düşük harcama günü': 'Día con menor gasto',
  'Kişi kapsamı: Kayıtlı kişi yok':
      'Personas incluidas: no hay personas registradas',
  'Toplam gider': 'Gasto total',
  'Gider ayrıntıları': 'Detalles de gastos',
  'Ödeme hatırlatması 1': 'Recordatorio de pago 1',
  'Ödeme hatırlatması 2': 'Recordatorio de pago 2',
  'Ödeme hatırlatması 3': 'Recordatorio de pago 3',
  'FileSystemException: ': 'Error del sistema de archivos: ',
  'Invalid argument(s): ': 'Argumento no válido: ',
  'FormatException: ': 'Formato no válido: ',
};

String translateSpanishDynamic(String source, SpanishTextTranslator translate) {
  for (final pattern in _spanishPatterns) {
    final match = pattern.regExp.firstMatch(source);
    if (match != null) return pattern.builder(match, translate);
  }
  var value = source;
  for (final entry in _spanishPhrases) {
    value = value.replaceAll(entry.$1, entry.$2);
  }
  return value;
}

String _lowerFirst(String value) {
  if (value.isEmpty) return value;
  return '${value[0].toLowerCase()}${value.substring(1)}';
}

String _count(String value, String singular, String plural) =>
    value == '1' ? '$value $singular' : '$value $plural';

String _days(String value) => _count(value, 'día', 'días');
String _records(String value) => _count(value, 'registro', 'registros');
String _payments(String value) => _count(value, 'pago', 'pagos');
String _expenses(String value) => _count(value, 'gasto', 'gastos');
String _months(String value) => _count(value, 'mes', 'meses');
String _people(String value) => _count(value, 'persona', 'personas');
String _verbByCount(String value, String singular, String plural) =>
    value == '1' ? singular : plural;

final List<_SpanishPattern> _spanishPatterns = <_SpanishPattern>[
  _SpanishPattern(
    RegExp(r'^MİZAN (.+) Raporu$'),
    (m, t) => 'Informe ${_lowerFirst(t(m[1]!))} de MİZAN',
  ),
  _SpanishPattern(
    RegExp(r'^(.+) finans raporu$'),
    (m, t) => 'Informe financiero de ${m[1]}',
  ),
  _SpanishPattern(
    RegExp(r'^LEFFERION PRIME - MİZAN · Sayfa (\d+)$'),
    (m, t) => 'LEFFERION PRIME - MIZAN · Página ${m[1]}',
  ),
  _SpanishPattern(
    RegExp(r'^(.+) · devam$'),
    (m, t) => '${t(m[1]!)} · continuación',
  ),
  _SpanishPattern(RegExp(r'^Dönem: (.+)$'), (m, t) => 'Periodo: ${m[1]}'),
  _SpanishPattern(
    RegExp(r'^Kişi kapsamı: (.+)$'),
    (m, t) => 'Personas incluidas: ${t(m[1]!)}',
  ),
  _SpanishPattern(
    RegExp(r'^Oluşturulma: (.+)$'),
    (m, t) => 'Generado: ${m[1]}',
  ),
  _SpanishPattern(
    RegExp(r'^Açık plan (.+) · Bu ay yapılan (.+)$'),
    (m, t) => 'Plan pendiente ${m[1]} · Pagado este mes ${m[2]}',
  ),
  _SpanishPattern(
    RegExp(r'^(.+) Ödeme Durumu$'),
    (m, t) => 'Estado de pagos de ${m[1]}',
  ),
  _SpanishPattern(
    RegExp(r'^(\d+) açık kayıt · (.+)$'),
    (m, t) => '${_records(m[1]!)} abiertos · ${m[2]}',
  ),
  _SpanishPattern(
    RegExp(r'^(\d+) günlük harcama · (\d+) ödeme$'),
    (m, t) => '${_expenses(m[1]!)} diarios · ${_payments(m[2]!)}',
  ),
  _SpanishPattern(
    RegExp(r'^(\d+) gün · (\d+) kayıt · (.+)$'),
    (m, t) => '${_days(m[1]!)} · ${_records(m[2]!)} · ${m[3]}',
  ),
  _SpanishPattern(
    RegExp(r'^(\d+) ödeme · (.+)$'),
    (m, t) => '${_payments(m[1]!)} · ${m[2]}',
  ),
  _SpanishPattern(
    RegExp(r'^(\d+) gider · (.+)$'),
    (m, t) => '${_expenses(m[1]!)} · ${m[2]}',
  ),
  _SpanishPattern(
    RegExp(r'^(\d+) gider kaydı$'),
    (m, t) => '${_records(m[1]!)} de gastos',
  ),
  _SpanishPattern(
    RegExp(r'^Daha fazla gün göster \((\d+) kaldı\)$'),
    (m, t) => 'Mostrar más días (${_count(m[1]!, 'restante', 'restantes')})',
  ),
  _SpanishPattern(
    RegExp(r'^Daha fazla ödeme günü göster \((\d+) kaldı\)$'),
    (m, t) =>
        'Mostrar más días de pago (${_count(m[1]!, 'restante', 'restantes')})',
  ),
  _SpanishPattern(
    RegExp(r'^Daha fazla gider günü göster \((\d+) kaldı\)$'),
    (m, t) =>
        'Mostrar más días de gastos (${_count(m[1]!, 'restante', 'restantes')})',
  ),
  _SpanishPattern(
    RegExp(r'^Bu günden daha fazla göster \((\d+) kaldı\)$'),
    (m, t) =>
        'Mostrar más a partir de este día (${_count(m[1]!, 'restante', 'restantes')})',
  ),
  _SpanishPattern(
    RegExp(r'^(.+) için (\d+) gün kaldı$'),
    (m, t) => '${m[1]} vence en ${_days(m[2]!)}',
  ),
  _SpanishPattern(
    RegExp(r'^(.+) bugün bekleniyor$'),
    (m, t) => '${m[1]} se espera hoy',
  ),
  _SpanishPattern(
    RegExp(r'^(.+) (\d+) gün gecikti$'),
    (m, t) => '${m[1]} lleva ${_days(m[2]!)} de retraso',
  ),
  _SpanishPattern(
    RegExp(r'^Son alındı: (.+) · Planlanan (.+)$'),
    (m, t) => 'Último cobro: ${m[1]} · Programado ${m[2]}',
  ),
  _SpanishPattern(
    RegExp(
      r'^Planlanan (.+) dönemi, (.+) tarihinde alındı olarak kaydedildi\. Sabit yatış günü değişmedi\.$',
    ),
    (m, t) =>
        'El periodo previsto para ${m[1]} se registró como cobrado el ${m[2]}. La fecha fija de cobro no cambió.',
  ),
  _SpanishPattern(
    RegExp(r'^(.+) gerçek fatura tutarı$'),
    (m, t) => 'Importe real de la factura de ${m[1]}',
  ),
  _SpanishPattern(
    RegExp(r'^Kalan tutar: (.+)$'),
    (m, t) => 'Importe pendiente: ${m[1]}',
  ),
  _SpanishPattern(
    RegExp(r'^Kalan taksit: (\d+)$'),
    (m, t) => 'Cuotas pendientes: ${m[1]}',
  ),
  _SpanishPattern(
    RegExp(r'^(.+) gider kaydı silinsin mi\?$'),
    (m, t) => '¿Eliminar el gasto ${m[1]}?',
  ),
  _SpanishPattern(
    RegExp(
      r'^(.+) kategorisi ve yalnız bu kategoriye bağlı giderler silinecek\.$',
    ),
    (m, t) =>
        'Se eliminará la categoría ${m[1]} y únicamente los gastos asignados a ella.',
  ),
  _SpanishPattern(
    RegExp(
      r'^(.+) ve bu kişiye bağlı bütün kayıtlar silinecek\. Bu işlem yalnız açık onayla yapılır\.$',
    ),
    (m, t) =>
        'Se eliminarán ${m[1]} y todos los registros vinculados a esta persona. Esta acción requiere una confirmación explícita.',
  ),
  _SpanishPattern(
    RegExp(r'^PDF raporu kaydedilemedi: (.+)$'),
    (m, t) => 'No se pudo guardar el informe PDF: ${m[1]}',
  ),
  _SpanishPattern(
    RegExp(r'^PDF raporu paylaşılamadı: (.+)$'),
    (m, t) => 'No se pudo compartir el informe PDF: ${m[1]}',
  ),
  _SpanishPattern(
    RegExp(
      r'^Bildirim planındaki (\d+) kayıt Android sistemine yazılamadı\. İlk hata: (.+)$',
    ),
    (m, t) =>
        '${_verbByCount(m[1]!, 'No se pudo escribir', 'No se pudieron escribir')} ${_records(m[1]!)} del calendario de notificaciones en Android. Primer error: ${m[2]}',
  ),
  _SpanishPattern(
    RegExp(
      r'^Bildirim planı doğrulanamadı; Android tarafında (\d+) kayıt eksik kaldı\.$',
    ),
    (m, t) =>
        'No se pudo verificar el calendario de notificaciones; ${_verbByCount(m[1]!, 'falta', 'faltan')} ${_records(m[1]!)} en Android.',
  ),
  _SpanishPattern(
    RegExp(r'^Ödeme hatırlatması (\d+)$'),
    (m, t) => 'Recordatorio de pago ${m[1]}',
  ),
  _SpanishPattern(
    RegExp(r'^(.+) yeni, (.+) ilişki güncellendi(.*)\.$'),
    (m, t) =>
        '${_records(m[1]!)} nuevos; ${_verbByCount(m[2]!, 'se actualizó', 'se actualizaron')} ${_count(m[2]!, 'relación', 'relaciones')}${m[3]}.',
  ),
  _SpanishPattern(
    RegExp(r'^(.+) kayıt kimliği geçersiz veya tekrarlı\.$'),
    (m, t) =>
        'El identificador del registro ${m[1]} no es válido o está duplicado.',
  ),
  _SpanishPattern(
    RegExp(r'^(\d+) gün kaldı$'),
    (m, t) => '${_verbByCount(m[1]!, 'Queda', 'Quedan')} ${_days(m[1]!)}',
  ),
  _SpanishPattern(
    RegExp(r'^(\d+) gün gecikmede$'),
    (m, t) => '${_days(m[1]!)} de retraso',
  ),
  _SpanishPattern(
    RegExp(r'^Ödeme (\d+) gün gecikti\.$'),
    (m, t) => 'El pago lleva ${_days(m[1]!)} de retraso.',
  ),
  _SpanishPattern(
    RegExp(r'^Son ödeme (.+)\.$'),
    (m, t) => 'Fecha de vencimiento: ${m[1]}.',
  ),
  _SpanishPattern(
    RegExp(r'^Ayın (\d+)\. günü$'),
    (m, t) => 'Día ${m[1]} del mes',
  ),
  _SpanishPattern(
    RegExp(r'^Her ayın (\d+)\. günü$'),
    (m, t) => 'Día ${m[1]} de cada mes',
  ),
  _SpanishPattern(
    RegExp(r'^Her (.+)$'),
    (m, t) => 'Cada ${_lowerFirst(t(m[1]!))}',
  ),
  _SpanishPattern(RegExp(r'^Başlangıç: (.+)$'), (m, t) => 'Inicio: ${m[1]}'),
  _SpanishPattern(RegExp(r'^Başlangıç (.+)$'), (m, t) => 'Inicio ${m[1]}'),
  _SpanishPattern(
    RegExp(r'^Toplam (.+)$'),
    (m, t) => 'Total ${_lowerFirst(t(m[1]!))}',
  ),
  _SpanishPattern(RegExp(r'^Kalan (.+)$'), (m, t) => '${t(m[1]!)} pendiente'),
  _SpanishPattern(
    RegExp(r'^Bu dönem (.+)$'),
    (m, t) => '${t(m[1]!)} de este periodo',
  ),
  _SpanishPattern(RegExp(r'^Tarih: (.+)$'), (m, t) => 'Fecha: ${m[1]}'),
  _SpanishPattern(RegExp(r'^Not: (.*)$'), (m, t) => 'Nota: ${m[1]}'),
  _SpanishPattern(
    RegExp(r'^(.+) boş bırakılamaz\.$'),
    (m, t) => '${t(m[1]!)} es obligatorio.',
  ),
  _SpanishPattern(
    RegExp(r'^(.+) en fazla (\d+) karakter olabilir\.$'),
    (m, t) => '${t(m[1]!)} no puede superar los ${m[2]} caracteres.',
  ),
  _SpanishPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalı\.$'),
    (m, t) => '${t(m[1]!)} debe ser superior a cero.',
  ),
  _SpanishPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalıdır\.$'),
    (m, t) => '${t(m[1]!)} debe ser superior a cero.',
  ),
  _SpanishPattern(
    RegExp(r'^(.+) negatif olamaz\.$'),
    (m, t) => '${t(m[1]!)} no puede ser negativo.',
  ),
  _SpanishPattern(
    RegExp(r'^(.+) pozitif tam sayı olmalı\.$'),
    (m, t) => '${t(m[1]!)} debe ser un número entero positivo.',
  ),
  _SpanishPattern(
    RegExp(r'^(.+) sıfır veya pozitif tam sayı olmalı\.$'),
    (m, t) => '${t(m[1]!)} debe ser cero o un número entero positivo.',
  ),
  _SpanishPattern(RegExp(r'^(\d+) kayıt$'), (m, t) => _records(m[1]!)),
  _SpanishPattern(RegExp(r'^(\d+) ödeme$'), (m, t) => _payments(m[1]!)),
  _SpanishPattern(RegExp(r'^(\d+) gider$'), (m, t) => _expenses(m[1]!)),
  _SpanishPattern(
    RegExp(r'^(\d+) gider kaydı$'),
    (m, t) => '${_records(m[1]!)} de gastos',
  ),
  _SpanishPattern(
    RegExp(r'^(.+) · (\d+) kayıt$'),
    (m, t) => '${m[1]} · ${_records(m[2]!)}',
  ),
  _SpanishPattern(RegExp(r'^(.+) gün$'), (m, t) => _days(m[1]!)),
  _SpanishPattern(RegExp(r'^(.+) ay$'), (m, t) => _months(m[1]!)),
  _SpanishPattern(
    RegExp(r'^(.+) kişi seçili$'),
    (m, t) =>
        '${_people(m[1]!)} ${_verbByCount(m[1]!, 'seleccionada', 'seleccionadas')}',
  ),
  _SpanishPattern(
    RegExp(r'^(.+) yeni kayıt eklendi; mevcut veriler korundu\.$'),
    (m, t) =>
        '${_verbByCount(m[1]!, 'Se añadió', 'Se añadieron')} ${_records(m[1]!)} nuevos; se conservaron los datos existentes.',
  ),
  _SpanishPattern(
    RegExp(r'^Test (.+) için dakik olarak planlandı\.$'),
    (m, t) => 'La prueba se programó exactamente para ${m[1]}.',
  ),
  _SpanishPattern(
    RegExp(r'^(.+) kaydedilemedi: (.+)$'),
    (m, t) => 'No se pudo guardar ${_lowerFirst(t(m[1]!))}: ${m[2]}',
  ),
  _SpanishPattern(
    RegExp(r'^(.+) oluşturulamadı: (.+)$'),
    (m, t) => 'No se pudo crear ${_lowerFirst(t(m[1]!))}: ${m[2]}',
  ),
  _SpanishPattern(
    RegExp(r'^(.+) paylaşılamadı: (.+)$'),
    (m, t) => 'No se pudo compartir ${_lowerFirst(t(m[1]!))}: ${m[2]}',
  ),
  _SpanishPattern(
    RegExp(r'^(.+) birleştirilemedi: (.+)$'),
    (m, t) => 'No se pudo combinar ${_lowerFirst(t(m[1]!))}: ${m[2]}',
  ),
];

const List<(String, String)> _spanishPhrases = <(String, String)>[
  ('Kişisel ve kurumsal borçlar', 'Deudas personales y empresariales'),
  ('Kişisel / kurumsal borç', 'Deuda personal / empresarial'),
  ('Kişisel/kurumsal borç', 'Deuda personal/empresarial'),
  ('Ödemelere yapılan gider', 'Pagos realizados'),
  ('Bu ay yapılan', 'Pagado este mes'),
  ('Açık plan', 'Plan pendiente'),
  ('Kalan tutar', 'Importe pendiente'),
  ('Kalan toplam borç', 'Deuda total pendiente'),
  ('Gecikmiş toplam', 'Total vencido'),
  ('Önümüzdeki 7 gün', 'Próximos 7 días'),
  ('Son ödeme bugün', 'Vence hoy'),
  ('Banka borçları', 'Deudas bancarias'),
  ('Kira ve taksitler', 'Alquileres y cuotas'),
  ('Günlük harcamalar', 'Gastos diarios'),
  ('Gider ayrıntıları', 'Detalles de gastos'),
  ('Ödeme ayrıntıları', 'Detalles de pagos'),
  ('Gerçekleşen ödeme', 'Pago registrado'),
  ('Ödeme kayıtları', 'Pagos registrados'),
  ('Normal giderler', 'Gastos habituales'),
  ('Toplam gider', 'Gasto total'),
  ('Kalan ödeme yükü', 'Obligaciones de pago pendientes'),
  ('Gecikmiş ödeme yükü', 'Obligaciones de pago vencidas'),
  ('Yaklaşan ödeme yükü', 'Próximas obligaciones de pago'),
  ('Kişi kapsamı', 'Personas incluidas'),
  ('Oluşturulma', 'Generado'),
  ('Dönem', 'Periodo'),
  ('devam', 'continuación'),
];

class _SpanishPattern {
  const _SpanishPattern(this.regExp, this.builder);
  final RegExp regExp;
  final String Function(RegExpMatch match, SpanishTextTranslator translate)
      builder;
}

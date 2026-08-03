// REVIEWED ITALIAN LOCALIZATION — VALIDATION, STORAGE AND NOTIFICATIONS.
const Map<String, String> mizanItalianValidation = <String, String>{
  'Her değişiklik cihazda anında kaydedilir; sağlam kayıt doğrulanmadan üzerine yazılmaz.':
      'Ogni modifica viene salvata immediatamente sul dispositivo; i dati validi non vengono sovrascritti finché la nuova registrazione non è stata verificata.',
  'Kişiler, borçlar, faturalar, abonelikler, ödemeler, notlar, gelirler ve giderler her işlemden sonra cihazdaki dosyaya yazılır.':
      'Persone, debiti, bollette, abbonamenti, pagamenti, note, entrate e spese vengono scritti nel file sul dispositivo dopo ogni operazione.',
  'Yeni kayıt doğrulandıktan sonra ana dosya değiştirilir; son sağlam kopya ayrıca korunur.':
      'Il file principale viene sostituito soltanto dopo la verifica dei nuovi dati; viene inoltre conservata l’ultima copia valida.',
  'Yedek içe aktarılırken mevcut kayıtlar silinmez. Ortak kayıtlar atlanır, yalnız yeni kayıtlar ve eksik ilişkiler eklenir.':
      'Durante l’importazione di un backup, le registrazioni esistenti non vengono eliminate. Le voci già presenti vengono ignorate; vengono aggiunte soltanto le nuove voci e i collegamenti mancanti.',
  'Kişi, banka, borç, ödeme, not, kategori, gider, gelir ve bildirim saatleri kendi kimlik ve bağlantılarıyla aktarılır. Aynı kayıt ikinci kez yazılmaz.':
      'Persone, banche, debiti, pagamenti, note, categorie, spese, entrate e orari delle notifiche vengono trasferiti con i rispettivi identificativi e collegamenti. La stessa registrazione non viene scritta due volte.',
  'Uygulama dili seçilmelidir.': 'È necessario selezionare la lingua dell’app.',
  'Ülke kodu geçersiz.': 'Il codice del Paese non è valido.',
  'Para birimi kodu geçersiz.': 'Il codice valuta non è valido.',
  'Tamamlanmış profilde uygulama dili eksik.':
      'Nel profilo completato manca la lingua dell’app.',
  'Tamamlanmış profilde ülke kodu geçersiz.':
      'Il profilo completato contiene un codice Paese non valido.',
  'Tamamlanmış profilde para birimi kodu geçersiz.':
      'Il profilo completato contiene un codice valuta non valido.',
  'Global katalog henüz yüklenmedi.':
      'Il catalogo globale non è ancora stato caricato.',
  'Global katalog sayıları doğrulanamadı.':
      'Non è stato possibile verificare il numero di voci del catalogo globale.',
  'Bildirim izni veya zamanlama servisi açılamadı:':
      'Non è stato possibile aprire l’autorizzazione alle notifiche o il servizio di pianificazione:',
  'Yerel kayıt alanı güvenli biçimde açılamadı. Mevcut dosyaları korumak için yeni veri yazımı durduruldu.':
      'Non è stato possibile aprire in sicurezza l’area di archiviazione locale. La scrittura di nuovi dati è stata interrotta per proteggere i file esistenti.',
  'Bildirim izni kapalı. Android izni açıldığında MİZAN otomatik olarak yeniden senkronize eder.':
      'L’autorizzazione alle notifiche è disattivata. MİZAN eseguirà nuovamente la sincronizzazione automatica non appena verrà concessa l’autorizzazione Android.',
  'Dakik bildirim izni kapalı. Android izni açıldığında MİZAN otomatik olarak yeniden senkronize eder.':
      'L’autorizzazione agli allarmi esatti è disattivata. MİZAN eseguirà nuovamente la sincronizzazione automatica non appena verrà concessa l’autorizzazione Android.',
  'Kayıt yapıldı ancak bildirimler otomatik senkronize edilemedi:':
      'I dati sono stati salvati, ma non è stato possibile sincronizzare automaticamente le notifiche:',
  'Kişi adı': 'Nome della persona',
  'Banka adı': 'Nome della banca',
  'Toplam borç': 'Debito totale',
  'Aylık tutar': 'Importo mensile',
  'Gecikme günü': 'Giorni di ritardo',
  'Limit': 'Fido',
  'Kullanılan limit': 'Fido utilizzato',
  'Açıklama': 'Descrizione',
  'Düzenli ödeme tutarı': 'Importo del pagamento ricorrente',
  'Borç başlığı': 'Titolo del debito',
  'Alacaklı adı': 'Nome del creditore',
  'Çek numarası': 'Numero dell’assegno',
  'Düzenleyen': 'Emittente',
  'Banka bilgisi': 'Dati bancari',
  'Senet numarası': 'Numero della cambiale',
  'Ödeme planı tutarı': 'Importo del piano di pagamento',
  'Abonelik tutarı': 'Importo dell’abbonamento',
  'Abonelik türü': 'Tipo di abbonamento',
  'Abonelik başlığı': 'Titolo dell’abbonamento',
  'Sağlayıcı adı': 'Nome del fornitore',
  'Abone numarası': 'Codice cliente',
  'Sözleşme numarası': 'Numero del contratto',
  'Fatura tutarı': 'Importo della bolletta',
  'Dönem fatura tutarı': 'Importo della bolletta del periodo',
  'Kurum adı': 'Nome dell’ente',
  'Kira/taksit tutarı': 'Importo dell’affitto o della rata',
  'Kira/taksit başlığı': 'Titolo dell’affitto o della rata',
  'Alıcı adı': 'Nome del beneficiario',
  'IBAN': 'IBAN',
  'Adet': 'Quantità',
  'Birim fiyat': 'Prezzo unitario',
  'Gider adı': 'Nome della spesa',
  'Gider notu': 'Nota sulla spesa',
  'Ödeme tutarı': 'Importo del pagamento',
  'Ödeme notu': 'Nota sul pagamento',
  'Ödeme yöntemi': 'Metodo di pagamento',
  'Not': 'Nota',
  'Notlar': 'Note',
  'Kategori adı': 'Nome della categoria',
  'Gelir tutarı': 'Importo dell’entrata',
  'Gelir türü': 'Tipo di entrata',
  'Gelir notu': 'Nota sull’entrata',
  'Hatırlatma adı': 'Nome del promemoria',
  'Bildirim mesajı': 'Messaggio di notifica',
  'Geçici': 'Provvisorio',
  'Ödeme hatırlatması': 'Promemoria di pagamento',
  'Yaklaşan ve gecikmiş ödemelerini kontrol et.':
      'Controlli i pagamenti in scadenza e quelli scaduti.',
  'En fazla 10 ödeme bildirimi eklenebilir.':
      'È possibile aggiungere al massimo 10 notifiche di pagamento.',
  'Ödeme bildirim saati bulunamadı.':
      'L’orario della notifica di pagamento non è stato trovato.',
  'Bildirim saati geçersiz.': 'L’orario della notifica non è valido.',
  'En az bir ödeme bildirim saati bulunmalıdır.':
      'È necessario definire almeno un orario per le notifiche di pagamento.',
  'Gelir kaydı bulunamadı.':
      'La registrazione dell’entrata non è stata trovata.',
  'Haftalık gelir için geçerli bir gün seçilmelidir.':
      'Per un’entrata settimanale è necessario selezionare un giorno valido.',
  'Aylık gelir günü 1 ile 31 arasında olmalıdır.':
      'Il giorno dell’entrata mensile deve essere compreso tra 1 e 31.',
  'Yatış günü takibi yalnız haftalık ve aylık gelirlerde kullanılabilir.':
      'Il monitoraggio del giorno di accredito è disponibile soltanto per le entrate settimanali e mensili.',
  'Bu gelir için yatış günü takibi açık değil.':
      'Il monitoraggio del giorno di accredito non è attivo per questa entrata.',
  'Bu gelir dönemi daha önce alındı olarak işaretlenmiş.':
      'Questo periodo di entrata è già stato contrassegnato come ricevuto.',
  'Geri alınacak gelir işareti yok.':
      'Non è presente alcuna registrazione di entrata da annullare.',
  'Bildirim ayarı bulunamadı.':
      'L’impostazione della notifica non è stata trovata.',
  'Ödeme kalan borçtan büyük olamaz.':
      'Il pagamento non può superare il debito residuo.',
  'Borç kaydı bulunamadı.': 'La registrazione del debito non è stata trovata.',
  'Ödeme kalan fatura tutarından büyük olamaz.':
      'Il pagamento non può superare l’importo residuo della bolletta.',
  'Ödeme aboneliğin bu dönem kalan tutarından büyük olamaz.':
      'Il pagamento non può superare l’importo residuo dell’abbonamento per questo periodo.',
  'Ödeme kalan kira/taksit tutarından büyük olamaz.':
      'Il pagamento non può superare l’importo residuo dell’affitto o della rata.',
  'Ödeme kaydı bulunamadı.':
      'La registrazione del pagamento non è stata trovata.',
  'Güncellenen ödeme toplam tutarı aşamaz.':
      'Il pagamento aggiornato non può superare l’importo totale.',
  'Toplam borç, daha önce ödenen tutardan düşük olamaz.':
      'Il debito totale non può essere inferiore all’importo già pagato.',
  'Fatura tutarı, daha önce ödenen tutardan düşük olamaz.':
      'L’importo della bolletta non può essere inferiore all’importo già pagato.',
  'Kira/taksit tutarı, daha önce ödenen tutardan düşük olamaz.':
      'L’importo dell’affitto o della rata non può essere inferiore all’importo già pagato.',
  'Her ayın belirli günü seçildiğinde aylık tutar girilmelidir.':
      'Quando viene selezionato un giorno fisso del mese, è necessario inserire un importo mensile.',
  'Gecikmiş ay seçimi yalnız aylık ödeme gününde kullanılabilir.':
      'La selezione di un mese scaduto è disponibile soltanto per i pagamenti con giorno mensile.',
  'Gecikmiş ayın ödeme tarihi henüz gelmemiş olamaz.':
      'La data di scadenza di un mese contrassegnato come scaduto non può essere futura.',
  'Kullanılan limit toplam limiti aşamaz.':
      'Il fido utilizzato non può superare il fido totale.',
  'Son ödeme tarihi borç tarihinden önce olamaz.':
      'La data di scadenza non può precedere la data del debito.',
  'Taksitli borçta ödeme tutarı girilmelidir.':
      'Per un debito rateizzato è necessario inserire un importo di pagamento.',
  'Özel ödeme aralığı gün olarak girilmelidir.':
      'L’intervallo di pagamento personalizzato deve essere espresso in giorni.',
  'Çek numarası boş bırakılamaz.': 'Il numero dell’assegno è obbligatorio.',
  'Senet numarası boş bırakılamaz.': 'Il numero della cambiale è obbligatorio.',
  'Abonelik ödeme sıklığı tek ödeme olamaz.':
      'La frequenza di pagamento di un abbonamento non può essere impostata su pagamento unico.',
  'Aylık fatura günü 1 ile 31 arasında olmalıdır.':
      'Il giorno mensile della bolletta deve essere compreso tra 1 e 31.',
  'Ödeme günü 1 ile 31 arasında olmalı.':
      'Il giorno di pagamento deve essere compreso tra 1 e 31.',
  'Ürün taksitinde toplam taksit sayısı gereklidir.':
      'Per una rata di acquisto è necessario indicare il numero totale di rate.',
  'Sözleşme bitişi başlangıçtan önce olamaz.':
      'La data di fine del contratto non può precedere la data di inizio.',
  'Bir borç kaydında ödeme toplamı borcu aşıyor.':
      'La somma dei pagamenti di un debito supera l’importo del debito.',
  'Bir kişisel borçta ödeme toplamı borcu aşıyor.':
      'La somma dei pagamenti di un debito personale supera l’importo del debito.',
  'Bir fatura kaydında ödeme toplamı tutarı aşıyor.':
      'La somma dei pagamenti di una bolletta supera il relativo importo.',
  'Aylık fatura ödeme günü geçersiz.':
      'Il giorno di pagamento della bolletta mensile non è valido.',
  'Dönemsel fatura tutarı sıfırdan büyük olmalıdır.':
      'L’importo della bolletta del periodo deve essere maggiore di zero.',
  'Bir kira kaydında ödeme toplamı tutarı aşıyor.':
      'La somma dei pagamenti di un affitto supera l’importo dovuto.',
  'Bir gider kaydı bulunmayan kategoriye bağlı.':
      'Una spesa è collegata a una categoria inesistente.',
  'Kişi bulunamadı.': 'La persona non è stata trovata.',
  'Banka kaydı bulunamadı.':
      'La registrazione della banca non è stata trovata.',
  'Kişisel/kurumsal borç bulunamadı.':
      'Il debito personale o aziendale non è stato trovato.',
  'Abonelik kaydı bulunamadı.':
      'La registrazione dell’abbonamento non è stata trovata.',
  'Fatura kaydı bulunamadı.':
      'La registrazione della bolletta non è stata trovata.',
  'Kira/taksit kaydı bulunamadı.':
      'La registrazione dell’affitto o della rata non è stata trovata.',
  'Gider kategorisi bulunamadı.': 'La categoria di spesa non è stata trovata.',
  'Gider kaydı bulunamadı.':
      'La registrazione della spesa non è stata trovata.',
  'Bu kişide aynı banka adı zaten var.':
      'Per questa persona esiste già una banca con lo stesso nome.',
  'Bu kategori adı zaten kullanılıyor.':
      'Questo nome di categoria è già in uso.',
  'Banka borcu kaydı bulunamadı.':
      'La registrazione del debito bancario non è stata trovata.',
  'Toplam taksit pozitif olmalı.':
      'Il numero totale di rate deve essere maggiore di zero.',
  'Taksit ilerlemesi negatif olamaz.':
      'L’avanzamento delle rate non può essere negativo.',
  'Taksit ilerlemesi toplam taksiti aşamaz.':
      'L’avanzamento delle rate non può superare il numero totale di rate.',
  'Tutar boş bırakılamaz.': 'L’importo è obbligatorio.',
  'Geçerli bir para tutarı girin.': 'Inserisca un importo monetario valido.',
  'Tutar biçimi anlaşılamadı.':
      'Il formato dell’importo non è stato riconosciuto.',
  'En fazla iki kuruş hanesi girilebilir.':
      'Sono consentite al massimo due cifre decimali.',
  'Değer': 'Valore',
  'Lefferion Prime - MİZAN hata yapabilir. Lütfen vade, gecikme ve ödeme bilgilerini son kez kontrol edin.':
      'Lefferion Prime – MİZAN può commettere errori. Verifichi un’ultima volta scadenze, ritardi e informazioni di pagamento.',
  'Son ödeme bugün': 'Scadenza oggi',
  'Ocak': 'Gennaio',
  'Şubat': 'Febbraio',
  'Mart': 'Marzo',
  'Nisan': 'Aprile',
  'Mayıs': 'Maggio',
  'Haziran': 'Giugno',
  'Temmuz': 'Luglio',
  'Ağustos': 'Agosto',
  'Eylül': 'Settembre',
  'Ekim': 'Ottobre',
  'Kasım': 'Novembre',
  'Aralık': 'Dicembre',
  'Oca': 'gen',
  'Şub': 'feb',
  'Mar': 'mar',
  'Nis': 'apr',
  'May': 'mag',
  'Haz': 'giu',
  'Tem': 'lug',
  'Ağu': 'ago',
  'Eyl': 'set',
  'Eki': 'ott',
  'Kas': 'nov',
  'Ara': 'dic',
  'Bildirim servisi bu platformda etkin değil.':
      'Il servizio di notifiche non è disponibile su questa piattaforma.',
  'Gider bildirimleri': 'Notifiche delle spese',
  'Ödeme bildirimleri': 'Notifiche di pagamento',
  'Günlük gider kaydı bildirimleri':
      'Notifiche giornaliere per la registrazione delle spese',
  'Tüm kayıt türlerinin son ödeme bildirimleri':
      'Notifiche di scadenza per tutti i tipi di registrazione',
  'Android dışında gerçek zamanlama yapılmaz.':
      'La pianificazione effettiva è disponibile soltanto su Android.',
  'Bildirim izni kapalı.': 'L’autorizzazione alle notifiche è disattivata.',
  'Dakik bildirim izni kapalı. Saat ve dakika doğruluğu için izni açın.':
      'L’autorizzazione agli allarmi esatti è disattivata. La conceda per rispettare l’ora e il minuto stabiliti.',
  'Dakik bildirim izni verilmedi.':
      'L’autorizzazione agli allarmi esatti non è stata concessa.',
  'Bildirim izni kapalı. Yeni bildirimler oluşturulmadı.':
      'L’autorizzazione alle notifiche è disattivata. Non sono state create nuove notifiche.',
  'Dakik bildirim izni kapalı. Android mevcut dakik planları iptal eder; izin açıldığında plan yeniden kurulmalıdır.':
      'L’autorizzazione agli allarmi esatti è disattivata. Android annulla le pianificazioni esatte esistenti; dopo la concessione dell’autorizzazione il piano dovrà essere ricreato.',
  'Bildirim izni kapalı. Önce bildirim iznini açın.':
      'L’autorizzazione alle notifiche è disattivata. Conceda prima questa autorizzazione.',
  'Dakik bildirim izni verilmedi. Test yaklaşık zamanda çalıştırılmayacak.':
      'L’autorizzazione agli allarmi esatti non è stata concessa. Il test non verrà eseguito a un orario approssimativo.',
  'MİZAN bildirim testi': 'Test delle notifiche MİZAN',
  'Bu test, ayarlanan dakik bildirim sistemiyle oluşturuldu.':
      'Questo test è stato creato con il sistema configurato per le notifiche all’ora esatta.',
  'Yedek kayıt doğrulanamadı.': 'Non è stato possibile verificare il backup.',
  'Ana kayıt okunamadı; son sağlam yedek geri yüklendi.':
      'Non è stato possibile leggere il file principale; è stato ripristinato l’ultimo backup valido.',
  'Ana ve yedek kayıt dosyaları okunamadı. Dosyalar korunuyor.':
      'Non è stato possibile leggere né il file principale né il file di backup. I file vengono mantenuti.',
  'MİZAN kullanıma hazır. İlk kişi veya kaydı ekleyebilirsin.':
      'MİZAN è pronto all’uso. Può aggiungere la prima persona o la prima registrazione.',
  'Geçici kayıt doğrulanamadı.':
      'Non è stato possibile verificare la registrazione provvisoria.',
};

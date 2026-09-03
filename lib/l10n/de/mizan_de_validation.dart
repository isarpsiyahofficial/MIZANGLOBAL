const Map<String, String> mizanGermanValidation = <String, String>{
  'Her değişiklik cihazda anında kaydedilir; sağlam kayıt doğrulanmadan üzerine yazılmaz.':
      'Jede Änderung wird sofort auf dem Gerät gespeichert; gültige Daten werden erst überschrieben, nachdem der neue Eintrag geprüft wurde.',
  'Kişiler, borçlar, faturalar, abonelikler, ödemeler, notlar, gelirler ve giderler her işlemden sonra cihazdaki dosyaya yazılır.':
      'Personen, Schulden, Rechnungen, Abonnements, Zahlungen, Notizen, Einnahmen und Ausgaben werden nach jedem Vorgang in die Datei auf dem Gerät geschrieben.',
  'Yeni kayıt doğrulandıktan sonra ana dosya değiştirilir; son sağlam kopya ayrıca korunur.':
      'Die Hauptdatei wird erst nach erfolgreicher Prüfung der neuen Daten ersetzt; die letzte gültige Kopie bleibt zusätzlich erhalten.',
  'Yedek içe aktarılırken mevcut kayıtlar silinmez. Ortak kayıtlar atlanır, yalnız yeni kayıtlar ve eksik ilişkiler eklenir.':
      'Beim Importieren einer Sicherung werden vorhandene Einträge nicht gelöscht. Bereits vorhandene Einträge werden übersprungen; nur neue Einträge und fehlende Verknüpfungen werden ergänzt.',
  'Kişi, banka, borç, ödeme, not, kategori, gider, gelir ve bildirim saatleri kendi kimlik ve bağlantılarıyla aktarılır. Aynı kayıt ikinci kez yazılmaz.':
      'Personen, Banken, Schulden, Zahlungen, Notizen, Kategorien, Ausgaben, Einnahmen und Benachrichtigungszeiten werden mit ihren Kennungen und Verknüpfungen übertragen. Derselbe Eintrag wird nicht doppelt gespeichert.',
  'Uygulama dili seçilmelidir.': 'Die App-Sprache muss ausgewählt werden.',
  'Ülke kodu geçersiz.': 'Der Ländercode ist ungültig.',
  'Para birimi kodu geçersiz.': 'Der Währungscode ist ungültig.',
  'Tamamlanmış profilde uygulama dili eksik.':
      'Im abgeschlossenen Profil fehlt die App-Sprache.',
  'Tamamlanmış profilde ülke kodu geçersiz.':
      'Das abgeschlossene Profil enthält einen ungültigen Ländercode.',
  'Tamamlanmış profilde para birimi kodu geçersiz.':
      'Das abgeschlossene Profil enthält einen ungültigen Währungscode.',
  'Global katalog henüz yüklenmedi.':
      'Der globale Katalog wurde noch nicht geladen.',
  'Global katalog sayıları doğrulanamadı.':
      'Die Anzahl der Einträge im globalen Katalog konnte nicht geprüft werden.',
  'Bildirim izni veya zamanlama servisi açılamadı:':
      'Die Benachrichtigungsberechtigung oder der Planungsdienst konnte nicht geöffnet werden:',
  'Yerel kayıt alanı güvenli biçimde açılamadı. Mevcut dosyaları korumak için yeni veri yazımı durduruldu.':
      'Der lokale Speicherbereich konnte nicht sicher geöffnet werden. Das Schreiben neuer Daten wurde angehalten, um vorhandene Dateien zu schützen.',
  'Bildirim izni kapalı. Android izni açıldığında MİZAN otomatik olarak yeniden senkronize eder.':
      'Die Benachrichtigungsberechtigung ist deaktiviert. MİZAN synchronisiert automatisch erneut, sobald die Android-Berechtigung erteilt wurde.',
  'Dakik bildirim izni kapalı. Android izni açıldığında MİZAN otomatik olarak yeniden senkronize eder.':
      'Die Berechtigung für exakte Alarme ist deaktiviert. MİZAN synchronisiert automatisch erneut, sobald die Android-Berechtigung erteilt wurde.',
  'Kayıt yapıldı ancak bildirimler otomatik senkronize edilemedi:':
      'Die Daten wurden gespeichert, die Benachrichtigungen konnten jedoch nicht automatisch synchronisiert werden:',
  'Kişi adı': 'Name der Person',
  'Banka adı': 'Name der Bank',
  'Toplam borç': 'Gesamtschuld',
  'Aylık tutar': 'Monatsbetrag',
  'Gecikme günü': 'Verzugstage',
  'Limit': 'Kreditrahmen',
  'Kullanılan limit': 'Genutzter Kreditrahmen',
  'Açıklama': 'Beschreibung',
  'Düzenli ödeme tutarı': 'Regelmäßiger Zahlungsbetrag',
  'Borç başlığı': 'Schuldtitel',
  'Alacaklı adı': 'Name des Gläubigers',
  'Çek numarası': 'Schecknummer',
  'Düzenleyen': 'Aussteller',
  'Banka bilgisi': 'Bankverbindung',
  'Senet numarası': 'Schuldscheinnummer',
  'Ödeme planı tutarı': 'Betrag des Zahlungsplans',
  'Abonelik tutarı': 'Abonnementbetrag',
  'Abonelik türü': 'Abonnementart',
  'Abonelik başlığı': 'Abonnementtitel',
  'Sağlayıcı adı': 'Name des Anbieters',
  'Abone numarası': 'Kundennummer',
  'Sözleşme numarası': 'Vertragsnummer',
  'Fatura tutarı': 'Rechnungsbetrag',
  'Dönem fatura tutarı': 'Rechnungsbetrag für den Zeitraum',
  'Kurum adı': 'Name der Institution',
  'Kira/taksit tutarı': 'Miet- oder Ratenbetrag',
  'Kira/taksit başlığı': 'Miet- oder Ratentitel',
  'Alıcı adı': 'Name des Empfängers',
  'IBAN': 'IBAN',
  'Adet': 'Anzahl',
  'Birim fiyat': 'Stückpreis',
  'Gider adı': 'Bezeichnung der Ausgabe',
  'Gider notu': 'Ausgabennotiz',
  'Ödeme tutarı': 'Zahlungsbetrag',
  'Ödeme notu': 'Zahlungsnotiz',
  'Ödeme yöntemi': 'Zahlungsmethode',
  'Not': 'Notiz',
  'Notlar': 'Notizen',
  'Kategori adı': 'Kategoriename',
  'Gelir tutarı': 'Einnahmenbetrag',
  'Gelir türü': 'Einnahmenart',
  'Gelir notu': 'Einnahmennotiz',
  'Hatırlatma adı': 'Name der Erinnerung',
  'Bildirim mesajı': 'Benachrichtigungstext',
  'Geçici': 'Vorläufig',
  'Ödeme hatırlatması': 'Zahlungserinnerung',
  'Yaklaşan ve gecikmiş ödemelerini kontrol et.':
      'Prüfen Sie Ihre anstehenden und überfälligen Zahlungen.',
  'En fazla 10 ödeme bildirimi eklenebilir.':
      'Es können höchstens 10 Zahlungsbenachrichtigungen hinzugefügt werden.',
  'Ödeme bildirim saati bulunamadı.':
      'Die Uhrzeit der Zahlungsbenachrichtigung wurde nicht gefunden.',
  'Bildirim saati geçersiz.': 'Die Benachrichtigungszeit ist ungültig.',
  'En az bir ödeme bildirim saati bulunmalıdır.':
      'Es muss mindestens eine Uhrzeit für Zahlungsbenachrichtigungen festgelegt sein.',
  'Gelir kaydı bulunamadı.': 'Der Einnahmeneintrag wurde nicht gefunden.',
  'Haftalık gelir için geçerli bir gün seçilmelidir.':
      'Für wöchentliche Einnahmen muss ein gültiger Wochentag ausgewählt werden.',
  'Aylık gelir günü 1 ile 31 arasında olmalıdır.':
      'Der Tag für monatliche Einnahmen muss zwischen 1 und 31 liegen.',
  'Yatış günü takibi yalnız haftalık ve aylık gelirlerde kullanılabilir.':
      'Die Überwachung des Zahlungseingangstags ist nur für wöchentliche und monatliche Einnahmen verfügbar.',
  'Bu gelir için yatış günü takibi açık değil.':
      'Die Überwachung des Zahlungseingangstags ist für diese Einnahme nicht aktiviert.',
  'Bu gelir dönemi daha önce alındı olarak işaretlenmiş.':
      'Dieser Einnahmenzeitraum wurde bereits als erhalten markiert.',
  'Geri alınacak gelir işareti yok.':
      'Es gibt keine Einnahmenmarkierung, die rückgängig gemacht werden kann.',
  'Bildirim ayarı bulunamadı.':
      'Die Benachrichtigungseinstellung wurde nicht gefunden.',
  'Ödeme kalan borçtan büyük olamaz.':
      'Die Zahlung darf die Restschuld nicht übersteigen.',
  'Borç kaydı bulunamadı.': 'Der Schuldeneintrag wurde nicht gefunden.',
  'Ödeme kalan fatura tutarından büyük olamaz.':
      'Die Zahlung darf den verbleibenden Rechnungsbetrag nicht übersteigen.',
  'Ödeme aboneliğin bu dönem kalan tutarından büyük olamaz.':
      'Die Zahlung darf den für diesen Zeitraum verbleibenden Abonnementbetrag nicht übersteigen.',
  'Ödeme kalan kira/taksit tutarından büyük olamaz.':
      'Die Zahlung darf den verbleibenden Miet- oder Ratenbetrag nicht übersteigen.',
  'Ödeme kaydı bulunamadı.': 'Der Zahlungseintrag wurde nicht gefunden.',
  'Güncellenen ödeme toplam tutarı aşamaz.':
      'Die aktualisierte Zahlung darf den Gesamtbetrag nicht übersteigen.',
  'Toplam borç, daha önce ödenen tutardan düşük olamaz.':
      'Die Gesamtschuld darf nicht niedriger als der bereits gezahlte Betrag sein.',
  'Fatura tutarı, daha önce ödenen tutardan düşük olamaz.':
      'Der Rechnungsbetrag darf nicht niedriger als der bereits gezahlte Betrag sein.',
  'Kira/taksit tutarı, daha önce ödenen tutardan düşük olamaz.':
      'Der Miet- oder Ratenbetrag darf nicht niedriger als der bereits gezahlte Betrag sein.',
  'Her ayın belirli günü seçildiğinde aylık tutar girilmelidir.':
      'Wenn ein bestimmter Tag jedes Monats ausgewählt wird, muss ein Monatsbetrag eingegeben werden.',
  'Gecikmiş ay seçimi yalnız aylık ödeme gününde kullanılabilir.':
      'Die Auswahl eines überfälligen Monats ist nur bei einem monatlichen Zahlungstag verfügbar.',
  'Gecikmiş ayın ödeme tarihi henüz gelmemiş olamaz.':
      'Das Fälligkeitsdatum eines als überfällig markierten Monats darf nicht in der Zukunft liegen.',
  'Kullanılan limit toplam limiti aşamaz.':
      'Der genutzte Kreditrahmen darf den gesamten Kreditrahmen nicht übersteigen.',
  'Son ödeme tarihi borç tarihinden önce olamaz.':
      'Das Fälligkeitsdatum darf nicht vor dem Schuldentag liegen.',
  'Taksitli borçta ödeme tutarı girilmelidir.':
      'Bei einer Schuld mit Ratenzahlung muss ein Zahlungsbetrag eingegeben werden.',
  'Özel ödeme aralığı gün olarak girilmelidir.':
      'Das benutzerdefinierte Zahlungsintervall muss in Tagen eingegeben werden.',
  'Çek numarası boş bırakılamaz.': 'Die Schecknummer ist erforderlich.',
  'Senet numarası boş bırakılamaz.': 'Die Schuldscheinnummer ist erforderlich.',
  'Abonelik ödeme sıklığı tek ödeme olamaz.':
      'Die Zahlungsfrequenz eines Abonnements kann nicht auf eine einmalige Zahlung gesetzt werden.',
  'Aylık fatura günü 1 ile 31 arasında olmalıdır.':
      'Der monatliche Rechnungstag muss zwischen 1 und 31 liegen.',
  'Ödeme günü 1 ile 31 arasında olmalı.':
      'Der Zahlungstag muss zwischen 1 und 31 liegen.',
  'Ürün taksitinde toplam taksit sayısı gereklidir.':
      'Für eine Produktrate ist die Gesamtzahl der Raten erforderlich.',
  'Sözleşme bitişi başlangıçtan önce olamaz.':
      'Das Vertragsende darf nicht vor dem Vertragsbeginn liegen.',
  'Bir borç kaydında ödeme toplamı borcu aşıyor.':
      'Die Summe der Zahlungen eines Schuldeneintrags übersteigt die Schuld.',
  'Bir kişisel borçta ödeme toplamı borcu aşıyor.':
      'Die Summe der Zahlungen einer privaten Schuld übersteigt die Schuld.',
  'Bir fatura kaydında ödeme toplamı tutarı aşıyor.':
      'Die Summe der Zahlungen einer Rechnung übersteigt den Rechnungsbetrag.',
  'Aylık fatura ödeme günü geçersiz.':
      'Der Zahlungstag der monatlichen Rechnung ist ungültig.',
  'Dönemsel fatura tutarı sıfırdan büyük olmalıdır.':
      'Der Rechnungsbetrag für den Zeitraum muss größer als null sein.',
  'Bir kira kaydında ödeme toplamı tutarı aşıyor.':
      'Die Summe der Zahlungen eines Mieteintrags übersteigt den fälligen Betrag.',
  'Bir gider kaydı bulunmayan kategoriye bağlı.':
      'Ein Ausgabeneintrag ist mit einer nicht vorhandenen Kategorie verknüpft.',
  'Kişi bulunamadı.': 'Die Person wurde nicht gefunden.',
  'Banka kaydı bulunamadı.': 'Der Bankeintrag wurde nicht gefunden.',
  'Kişisel/kurumsal borç bulunamadı.':
      'Die private oder geschäftliche Schuld wurde nicht gefunden.',
  'Abonelik kaydı bulunamadı.': 'Der Abonnementeintrag wurde nicht gefunden.',
  'Fatura kaydı bulunamadı.': 'Der Rechnungseintrag wurde nicht gefunden.',
  'Kira/taksit kaydı bulunamadı.':
      'Der Miet- oder Rateneintrag wurde nicht gefunden.',
  'Gider kategorisi bulunamadı.': 'Die Ausgabenkategorie wurde nicht gefunden.',
  'Gider kaydı bulunamadı.': 'Der Ausgabeneintrag wurde nicht gefunden.',
  'Bu kişide aynı banka adı zaten var.':
      'Für diese Person ist bereits eine Bank mit diesem Namen vorhanden.',
  'Bu kategori adı zaten kullanılıyor.':
      'Dieser Kategoriename wird bereits verwendet.',
  'Banka borcu kaydı bulunamadı.':
      'Der Bankschuldeneintrag wurde nicht gefunden.',
  'Toplam taksit pozitif olmalı.':
      'Die Gesamtzahl der Raten muss größer als null sein.',
  'Taksit ilerlemesi negatif olamaz.':
      'Der Ratenfortschritt darf nicht negativ sein.',
  'Taksit ilerlemesi toplam taksiti aşamaz.':
      'Der Ratenfortschritt darf die Gesamtzahl der Raten nicht übersteigen.',
  'Tutar boş bırakılamaz.': 'Der Betrag ist erforderlich.',
  'Geçerli bir para tutarı girin.': 'Geben Sie einen gültigen Geldbetrag ein.',
  'Tutar biçimi anlaşılamadı.': 'Das Betragsformat wurde nicht erkannt.',
  'En fazla iki kuruş hanesi girilebilir.':
      'Es sind höchstens zwei Dezimalstellen zulässig.',
  'Değer': 'Wert',
  'Lefferion Prime - MİZAN hata yapabilir. Lütfen vade, gecikme ve ödeme bilgilerini son kez kontrol edin.':
      'Lefferion Prime – MİZAN kann Fehler machen. Prüfen Sie Fälligkeiten, Verzögerungen und Zahlungsangaben bitte abschließend.',
  'Son ödeme bugün': 'Heute fällig',
  'Ocak': 'Januar',
  'Şubat': 'Februar',
  'Mart': 'März',
  'Nisan': 'April',
  'Mayıs': 'Mai',
  'Haziran': 'Juni',
  'Temmuz': 'Juli',
  'Ağustos': 'August',
  'Eylül': 'September',
  'Ekim': 'Oktober',
  'Kasım': 'November',
  'Aralık': 'Dezember',
  'Oca': 'Jan.',
  'Şub': 'Feb.',
  'Mar': 'März',
  'Nis': 'Apr.',
  'May': 'Mai',
  'Haz': 'Juni',
  'Tem': 'Juli',
  'Ağu': 'Aug.',
  'Eyl': 'Sept.',
  'Eki': 'Okt.',
  'Kas': 'Nov.',
  'Ara': 'Dez.',
  'Bildirim servisi bu platformda etkin değil.':
      'Der Benachrichtigungsdienst ist auf dieser Plattform nicht verfügbar.',
  'Gider bildirimleri': 'Ausgabenbenachrichtigungen',
  'Ödeme bildirimleri': 'Zahlungsbenachrichtigungen',
  'Günlük gider kaydı bildirimleri':
      'Tägliche Benachrichtigungen zur Ausgabenerfassung',
  'Tüm kayıt türlerinin son ödeme bildirimleri':
      'Fälligkeitsbenachrichtigungen für alle Eintragsarten',
  'Android dışında gerçek zamanlama yapılmaz.':
      'Eine echte Zeitplanung ist nur unter Android verfügbar.',
  'Bildirim izni kapalı.': 'Die Benachrichtigungsberechtigung ist deaktiviert.',
  'Dakik bildirim izni kapalı. Saat ve dakika doğruluğu için izni açın.':
      'Die Berechtigung für exakte Alarme ist deaktiviert. Aktivieren Sie sie, damit Stunde und Minute eingehalten werden.',
  'Dakik bildirim izni verilmedi.':
      'Die Berechtigung für exakte Alarme wurde nicht erteilt.',
  'Bildirim izni kapalı. Yeni bildirimler oluşturulmadı.':
      'Die Benachrichtigungsberechtigung ist deaktiviert. Es wurden keine neuen Benachrichtigungen erstellt.',
  'Dakik bildirim izni kapalı. Android mevcut dakik planları iptal eder; izin açıldığında plan yeniden kurulmalıdır.':
      'Die Berechtigung für exakte Alarme ist deaktiviert. Android hebt vorhandene exakte Planungen auf; nach Erteilung der Berechtigung muss der Plan neu erstellt werden.',
  'Bildirim izni kapalı. Önce bildirim iznini açın.':
      'Die Benachrichtigungsberechtigung ist deaktiviert. Erteilen Sie zuerst diese Berechtigung.',
  'Dakik bildirim izni verilmedi. Test yaklaşık zamanda çalıştırılmayacak.':
      'Die Berechtigung für exakte Alarme wurde nicht erteilt. Der Test wird nicht zu einer ungefähren Zeit ausgeführt.',
  'MİZAN bildirim testi': 'MİZAN-Benachrichtigungstest',
  'Bu test, ayarlanan dakik bildirim sistemiyle oluşturuldu.':
      'Dieser Test wurde mit dem eingerichteten System für exakte Benachrichtigungen erstellt.',
  'Yedek kayıt doğrulanamadı.':
      'Die Sicherungsdaten konnten nicht geprüft werden.',
  'Ana kayıt okunamadı; son sağlam yedek geri yüklendi.':
      'Die Hauptdatei konnte nicht gelesen werden; die letzte gültige Sicherung wurde wiederhergestellt.',
  'Ana ve yedek kayıt dosyaları okunamadı. Dosyalar korunuyor.':
      'Weder die Hauptdatei noch die Sicherungsdatei konnten gelesen werden. Die Dateien bleiben erhalten.',
  'MİZAN kullanıma hazır. İlk kişi veya kaydı ekleyebilirsin.':
      'MİZAN ist einsatzbereit. Sie können die erste Person oder den ersten Eintrag hinzufügen.',
  'Geçici kayıt doğrulanamadı.':
      'Der vorläufige Eintrag konnte nicht geprüft werden.',
};

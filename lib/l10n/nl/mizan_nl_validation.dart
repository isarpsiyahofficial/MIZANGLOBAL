const Map<String, String> mizanDutchValidation = <String, String>{
  'Her değişiklik cihazda anında kaydedilir; sağlam kayıt doğrulanmadan üzerine yazılmaz.':
      'Elke wijziging wordt onmiddellijk op het apparaat opgeslagen; geldige gegevens worden niet overschreven voordat de nieuwe registratie is geverifieerd.',
  'Kişiler, borçlar, faturalar, abonelikler, ödemeler, notlar, gelirler ve giderler her işlemden sonra cihazdaki dosyaya yazılır.':
      'Personen, schulden, facturen, abonnementen, betalingen, notities, inkomsten en uitgaven worden na elke handeling naar het bestand op het apparaat geschreven.',
  'Yeni kayıt doğrulandıktan sonra ana dosya değiştirilir; son sağlam kopya ayrıca korunur.':
      'Het hoofdbestand wordt pas vervangen nadat de nieuwe gegevens zijn geverifieerd; de laatste geldige kopie blijft daarnaast behouden.',
  'Yedek içe aktarılırken mevcut kayıtlar silinmez. Ortak kayıtlar atlanır, yalnız yeni kayıtlar ve eksik ilişkiler eklenir.':
      'Bij het importeren van een reservekopie worden bestaande registraties niet verwijderd. Reeds aanwezige registraties worden overgeslagen; alleen nieuwe registraties en ontbrekende koppelingen worden toegevoegd.',
  'Kişi, banka, borç, ödeme, not, kategori, gider, gelir ve bildirim saatleri kendi kimlik ve bağlantılarıyla aktarılır. Aynı kayıt ikinci kez yazılmaz.':
      'Personen, banken, schulden, betalingen, notities, categorieën, uitgaven, inkomsten en meldingstijden worden met hun eigen identificaties en koppelingen overgezet. Dezelfde registratie wordt niet tweemaal geschreven.',
  'Uygulama dili seçilmelidir.': 'U moet een app-taal selecteren.',
  'Ülke kodu geçersiz.': 'De landcode is ongeldig.',
  'Para birimi kodu geçersiz.': 'De valutacode is ongeldig.',
  'Tamamlanmış profilde uygulama dili eksik.':
      'De app-taal ontbreekt in het voltooide profiel.',
  'Tamamlanmış profilde ülke kodu geçersiz.':
      'Het voltooide profiel bevat een ongeldige landcode.',
  'Tamamlanmış profilde para birimi kodu geçersiz.':
      'Het voltooide profiel bevat een ongeldige valutacode.',
  'Global katalog henüz yüklenmedi.':
      'De globale catalogus is nog niet geladen.',
  'Global katalog sayıları doğrulanamadı.':
      'Het aantal items in de globale catalogus kon niet worden geverifieerd.',
  'Bildirim izni veya zamanlama servisi açılamadı:':
      'De meldingstoestemming of planningsservice kon niet worden geopend:',
  'Yerel kayıt alanı güvenli biçimde açılamadı. Mevcut dosyaları korumak için yeni veri yazımı durduruldu.':
      'De lokale opslag kon niet veilig worden geopend. Het schrijven van nieuwe gegevens is gestopt om de bestaande bestanden te beschermen.',
  'Bildirim izni kapalı. Android izni açıldığında MİZAN otomatik olarak yeniden senkronize eder.':
      'De meldingstoestemming staat uit. MİZAN synchroniseert automatisch opnieuw zodra de Android-toestemming is ingeschakeld.',
  'Dakik bildirim izni kapalı. Android izni açıldığında MİZAN otomatik olarak yeniden senkronize eder.':
      'De toestemming voor exacte alarmen staat uit. MİZAN synchroniseert automatisch opnieuw zodra de Android-toestemming is ingeschakeld.',
  'Kayıt yapıldı ancak bildirimler otomatik senkronize edilemedi:':
      'De gegevens zijn opgeslagen, maar de meldingen konden niet automatisch worden gesynchroniseerd:',
  'Kişi adı': 'Naam van de persoon',
  'Banka adı': 'Banknaam',
  'Toplam borç': 'Totale schuld',
  'Aylık tutar': 'Maandbedrag',
  'Gecikme günü': 'Achterstandsdagen',
  'Limit': 'Kredietlimiet',
  'Kullanılan limit': 'Gebruikte kredietlimiet',
  'Açıklama': 'Omschrijving',
  'Düzenli ödeme tutarı': 'Periodiek betalingsbedrag',
  'Borç başlığı': 'Schuldtitel',
  'Alacaklı adı': 'Naam van de schuldeiser',
  'Çek numarası': 'Chequenummer',
  'Düzenleyen': 'Uitgever',
  'Banka bilgisi': 'Bankgegevens',
  'Senet numarası': 'Nummer schuldbekentenis',
  'Ödeme planı tutarı': 'Bedrag van de betalingsregeling',
  'Abonelik tutarı': 'Abonnementsbedrag',
  'Abonelik türü': 'Abonnementstype',
  'Abonelik başlığı': 'Abonnementstitel',
  'Sağlayıcı adı': 'Naam van de aanbieder',
  'Abone numarası': 'Klantnummer',
  'Sözleşme numarası': 'Contractnummer',
  'Fatura tutarı': 'Factuurbedrag',
  'Dönem fatura tutarı': 'Factuurbedrag van de periode',
  'Kurum adı': 'Naam van de instelling',
  'Kira/taksit tutarı': 'Huur- of termijnbedrag',
  'Kira/taksit başlığı': 'Huur- of termijntitel',
  'Alıcı adı': 'Naam van de ontvanger',
  'IBAN': 'IBAN',
  'Adet': 'Aantal',
  'Birim fiyat': 'Eenheidsprijs',
  'Gider adı': 'Naam van de uitgave',
  'Gider notu': 'Notitie bij de uitgave',
  'Ödeme tutarı': 'Betalingsbedrag',
  'Ödeme notu': 'Betalingsnotitie',
  'Ödeme yöntemi': 'Betaalmethode',
  'Not': 'Notitie',
  'Notlar': 'Notities',
  'Kategori adı': 'Categorienaam',
  'Gelir tutarı': 'Inkomstenbedrag',
  'Gelir türü': 'Inkomstentype',
  'Gelir notu': 'Notitie bij de inkomst',
  'Hatırlatma adı': 'Naam van de herinnering',
  'Bildirim mesajı': 'Meldingsbericht',
  'Geçici': 'Tijdelijk',
  'Ödeme hatırlatması': 'Betalingsherinnering',
  'Yaklaşan ve gecikmiş ödemelerini kontrol et.':
      'Controleer uw binnenkort vervallende en achterstallige betalingen.',
  'En fazla 10 ödeme bildirimi eklenebilir.':
      'U kunt maximaal 10 betalingsmeldingen toevoegen.',
  'Ödeme bildirim saati bulunamadı.':
      'De tijd van de betalingsmelding is niet gevonden.',
  'Bildirim saati geçersiz.': 'De meldingstijd is ongeldig.',
  'En az bir ödeme bildirim saati bulunmalıdır.':
      'Er moet ten minste één tijd voor betalingsmeldingen zijn ingesteld.',
  'Gelir kaydı bulunamadı.': 'De inkomstenregistratie is niet gevonden.',
  'Haftalık gelir için geçerli bir gün seçilmelidir.':
      'Voor wekelijkse inkomsten moet u een geldige dag selecteren.',
  'Aylık gelir günü 1 ile 31 arasında olmalıdır.':
      'De dag voor maandelijkse inkomsten moet tussen 1 en 31 liggen.',
  'Yatış günü takibi yalnız haftalık ve aylık gelirlerde kullanılabilir.':
      'Het bijhouden van de bijschrijvingsdag is alleen beschikbaar voor wekelijkse en maandelijkse inkomsten.',
  'Bu gelir için yatış günü takibi açık değil.':
      'Het bijhouden van de bijschrijvingsdag staat voor deze inkomst niet aan.',
  'Bu gelir dönemi daha önce alındı olarak işaretlenmiş.':
      'Deze inkomstenperiode is al als ontvangen gemarkeerd.',
  'Geri alınacak gelir işareti yok.':
      'Er is geen ontvangstmarkering om ongedaan te maken.',
  'Bildirim ayarı bulunamadı.': 'De meldingsinstelling is niet gevonden.',
  'Ödeme kalan borçtan büyük olamaz.':
      'De betaling mag niet hoger zijn dan de resterende schuld.',
  'Borç kaydı bulunamadı.': 'De schuldregistratie is niet gevonden.',
  'Ödeme kalan fatura tutarından büyük olamaz.':
      'De betaling mag niet hoger zijn dan het resterende factuurbedrag.',
  'Ödeme aboneliğin bu dönem kalan tutarından büyük olamaz.':
      'De betaling mag niet hoger zijn dan het resterende abonnementsbedrag van deze periode.',
  'Ödeme kalan kira/taksit tutarından büyük olamaz.':
      'De betaling mag niet hoger zijn dan het resterende huur- of termijnbedrag.',
  'Ödeme kaydı bulunamadı.': 'De betalingsregistratie is niet gevonden.',
  'Güncellenen ödeme toplam tutarı aşamaz.':
      'De bijgewerkte betaling mag het totaalbedrag niet overschrijden.',
  'Toplam borç, daha önce ödenen tutardan düşük olamaz.':
      'De totale schuld mag niet lager zijn dan het reeds betaalde bedrag.',
  'Fatura tutarı, daha önce ödenen tutardan düşük olamaz.':
      'Het factuurbedrag mag niet lager zijn dan het reeds betaalde bedrag.',
  'Kira/taksit tutarı, daha önce ödenen tutardan düşük olamaz.':
      'Het huur- of termijnbedrag mag niet lager zijn dan het reeds betaalde bedrag.',
  'Her ayın belirli günü seçildiğinde aylık tutar girilmelidir.':
      'Wanneer een vaste dag van de maand is geselecteerd, moet u een maandbedrag invoeren.',
  'Gecikmiş ay seçimi yalnız aylık ödeme gününde kullanılabilir.':
      'De selectie van een achterstallige maand is alleen beschikbaar bij een maandelijkse betaaldag.',
  'Gecikmiş ayın ödeme tarihi henüz gelmemiş olamaz.':
      'De vervaldatum van een als achterstallig gemarkeerde maand kan niet in de toekomst liggen.',
  'Kullanılan limit toplam limiti aşamaz.':
      'De gebruikte kredietlimiet mag de totale kredietlimiet niet overschrijden.',
  'Son ödeme tarihi borç tarihinden önce olamaz.':
      'De vervaldatum kan niet vóór de schulddatum liggen.',
  'Taksitli borçta ödeme tutarı girilmelidir.':
      'Voor een schuld in termijnen moet u een betalingsbedrag invoeren.',
  'Özel ödeme aralığı gün olarak girilmelidir.':
      'Het aangepaste betalingsinterval moet in dagen worden ingevoerd.',
  'Çek numarası boş bırakılamaz.': 'Het chequenummer is verplicht.',
  'Senet numarası boş bırakılamaz.':
      'Het nummer van de schuldbekentenis is verplicht.',
  'Abonelik ödeme sıklığı tek ödeme olamaz.':
      'De betalingsfrequentie van een abonnement kan niet Eenmalige betaling zijn.',
  'Aylık fatura günü 1 ile 31 arasında olmalıdır.':
      'De maandelijkse factuurdag moet tussen 1 en 31 liggen.',
  'Ödeme günü 1 ile 31 arasında olmalı.':
      'De betaaldag moet tussen 1 en 31 liggen.',
  'Ürün taksitinde toplam taksit sayısı gereklidir.':
      'Voor een producttermijn is het totale aantal termijnen verplicht.',
  'Sözleşme bitişi başlangıçtan önce olamaz.':
      'De einddatum van het contract kan niet vóór de begindatum liggen.',
  'Bir borç kaydında ödeme toplamı borcu aşıyor.':
      'De som van de betalingen voor een schuldregistratie overschrijdt de schuld.',
  'Bir kişisel borçta ödeme toplamı borcu aşıyor.':
      'De som van de betalingen voor een persoonlijke schuld overschrijdt de schuld.',
  'Bir fatura kaydında ödeme toplamı tutarı aşıyor.':
      'De som van de betalingen voor een factuur overschrijdt het factuurbedrag.',
  'Aylık fatura ödeme günü geçersiz.':
      'De betaaldag van de maandelijkse factuur is ongeldig.',
  'Dönemsel fatura tutarı sıfırdan büyük olmalıdır.':
      'Het factuurbedrag van de periode moet groter zijn dan nul.',
  'Bir kira kaydında ödeme toplamı tutarı aşıyor.':
      'De som van de betalingen voor een huurregistratie overschrijdt het verschuldigde bedrag.',
  'Bir gider kaydı bulunmayan kategoriye bağlı.':
      'Een uitgave is gekoppeld aan een categorie die niet bestaat.',
  'Kişi bulunamadı.': 'De persoon is niet gevonden.',
  'Banka kaydı bulunamadı.': 'De bankregistratie is niet gevonden.',
  'Kişisel/kurumsal borç bulunamadı.':
      'De particuliere of zakelijke schuld is niet gevonden.',
  'Abonelik kaydı bulunamadı.': 'De abonnementsregistratie is niet gevonden.',
  'Fatura kaydı bulunamadı.': 'De factuurregistratie is niet gevonden.',
  'Kira/taksit kaydı bulunamadı.':
      'De huur- of termijnregistratie is niet gevonden.',
  'Gider kategorisi bulunamadı.': 'De uitgavencategorie is niet gevonden.',
  'Gider kaydı bulunamadı.': 'De uitgavenregistratie is niet gevonden.',
  'Bu kişide aynı banka adı zaten var.':
      'Voor deze persoon bestaat al een bank met dezelfde naam.',
  'Bu kategori adı zaten kullanılıyor.': 'Deze categorienaam is al in gebruik.',
  'Banka borcu kaydı bulunamadı.': 'De bankschuldregistratie is niet gevonden.',
  'Toplam taksit pozitif olmalı.':
      'Het totale aantal termijnen moet groter zijn dan nul.',
  'Taksit ilerlemesi negatif olamaz.':
      'De termijnvoortgang mag niet negatief zijn.',
  'Taksit ilerlemesi toplam taksiti aşamaz.':
      'De termijnvoortgang mag het totale aantal termijnen niet overschrijden.',
  'Tutar boş bırakılamaz.': 'Het bedrag is verplicht.',
  'Geçerli bir para tutarı girin.': 'Voer een geldig geldbedrag in.',
  'Tutar biçimi anlaşılamadı.': 'De indeling van het bedrag is niet herkend.',
  'En fazla iki kuruş hanesi girilebilir.':
      'Er zijn maximaal twee decimalen toegestaan.',
  'Değer': 'Waarde',
  'Lefferion Prime - MİZAN hata yapabilir. Lütfen vade, gecikme ve ödeme bilgilerini son kez kontrol edin.':
      'Lefferion Prime – MİZAN kan fouten maken. Controleer vervaldata, achterstanden en betalingsgegevens nog eenmaal.',
  'Son ödeme bugün': 'Vervalt vandaag',
  'Ocak': 'Januari',
  'Şubat': 'Februari',
  'Mart': 'Maart',
  'Nisan': 'April',
  'Mayıs': 'Mei',
  'Haziran': 'Juni',
  'Temmuz': 'Juli',
  'Ağustos': 'Augustus',
  'Eylül': 'September',
  'Ekim': 'Oktober',
  'Kasım': 'November',
  'Aralık': 'December',
  'Oca': 'jan',
  'Şub': 'feb',
  'Mar': 'mrt',
  'Nis': 'apr',
  'May': 'mei',
  'Haz': 'jun',
  'Tem': 'jul',
  'Ağu': 'aug',
  'Eyl': 'sep',
  'Eki': 'okt',
  'Kas': 'nov',
  'Ara': 'dec',
  'Bildirim servisi bu platformda etkin değil.':
      'De meldingsservice is niet beschikbaar op dit platform.',
  'Gider bildirimleri': 'Uitgavenmeldingen',
  'Ödeme bildirimleri': 'Betalingsmeldingen',
  'Günlük gider kaydı bildirimleri':
      'Dagelijkse meldingen voor het registreren van uitgaven',
  'Tüm kayıt türlerinin son ödeme bildirimleri':
      'Vervaldatummeldingen voor alle registratietypen',
  'Android dışında gerçek zamanlama yapılmaz.':
      'Werkelijke planning is alleen beschikbaar op Android.',
  'Bildirim izni kapalı.': 'De meldingstoestemming staat uit.',
  'Dakik bildirim izni kapalı. Saat ve dakika doğruluğu için izni açın.':
      'De toestemming voor exacte alarmen staat uit. Schakel deze in voor nauwkeurigheid op uur en minuut.',
  'Dakik bildirim izni verilmedi.':
      'De toestemming voor exacte alarmen is niet verleend.',
  'Bildirim izni kapalı. Yeni bildirimler oluşturulmadı.':
      'De meldingstoestemming staat uit. Er zijn geen nieuwe meldingen aangemaakt.',
  'Dakik bildirim izni kapalı. Android mevcut dakik planları iptal eder; izin açıldığında plan yeniden kurulmalıdır.':
      'De toestemming voor exacte alarmen staat uit. Android annuleert bestaande exacte planningen; nadat toestemming is verleend, moet de planning opnieuw worden opgebouwd.',
  'Bildirim izni kapalı. Önce bildirim iznini açın.':
      'De meldingstoestemming staat uit. Schakel eerst de meldingstoestemming in.',
  'Dakik bildirim izni verilmedi. Test yaklaşık zamanda çalıştırılmayacak.':
      'De toestemming voor exacte alarmen is niet verleend. De test wordt niet op een benaderd tijdstip uitgevoerd.',
  'MİZAN bildirim testi': 'MİZAN-meldingstest',
  'Bu test, ayarlanan dakik bildirim sistemiyle oluşturuldu.':
      'Deze test is aangemaakt met het ingestelde systeem voor exacte meldingen.',
  'Yedek kayıt doğrulanamadı.': 'De reservekopie kon niet worden geverifieerd.',
  'Ana kayıt okunamadı; son sağlam yedek geri yüklendi.':
      'Het hoofdbestand kon niet worden gelezen; de laatste geldige reservekopie is hersteld.',
  'Ana ve yedek kayıt dosyaları okunamadı. Dosyalar korunuyor.':
      'Het hoofdbestand en de reservekopie konden niet worden gelezen. De bestanden blijven behouden.',
  'MİZAN kullanıma hazır. İlk kişi veya kaydı ekleyebilirsin.':
      'MİZAN is klaar voor gebruik. U kunt de eerste persoon of registratie toevoegen.',
  'Geçici kayıt doğrulanamadı.':
      'De tijdelijke registratie kon niet worden geverifieerd.',
};

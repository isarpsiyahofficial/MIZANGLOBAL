const Map<String, String> mizanRomanianValidation = <String, String>{
  'Her değişiklik cihazda anında kaydedilir; sağlam kayıt doğrulanmadan üzerine yazılmaz.':
      'Fiecare modificare este salvată imediat pe dispozitiv; datele valide nu sunt niciodată suprascrise înainte ca noua salvare să fie verificată.',
  'Kişiler, borçlar, faturalar, abonelikler, ödemeler, notlar, gelirler ve giderler her işlemden sonra cihazdaki dosyaya yazılır.':
      'Persoanele, datoriile, facturile, abonamentele, plățile, notele, veniturile și cheltuielile sunt scrise în fișierul de pe dispozitiv după fiecare operațiune.',
  'Yeni kayıt doğrulandıktan sonra ana dosya değiştirilir; son sağlam kopya ayrıca korunur.':
      'Fișierul principal este înlocuit numai după verificarea noilor date; ultima copie valabilă se păstrează separat.',
  'Yedek içe aktarılırken mevcut kayıtlar silinmez. Ortak kayıtlar atlanır, yalnız yeni kayıtlar ve eksik ilişkiler eklenir.':
      'Importul unei copii de rezervă nu șterge înregistrările existente. Înregistrările care se potrivesc sunt omise; sunt adăugate doar înregistrări noi și relații lipsă.',
  'Kişi, banka, borç, ödeme, not, kategori, gider, gelir ve bildirim saatleri kendi kimlik ve bağlantılarıyla aktarılır. Aynı kayıt ikinci kez yazılmaz.':
      'Persoanele, băncile, datoriile, plățile, notele, categoriile, cheltuielile, veniturile și orele de notificare sunt transferate cu identificatorii și relațiile lor originale. Aceeași înregistrare nu este scrisă de două ori.',
  'Uygulama dili seçilmelidir.': 'Trebuie selectată o limbă pentru aplicație.',
  'Ülke kodu geçersiz.': 'Cod de țară nevalid.',
  'Para birimi kodu geçersiz.': 'Cod valutar nevalid.',
  'Tamamlanmış profilde uygulama dili eksik.':
      'Profilului completat lipsește o limbă a aplicației.',
  'Tamamlanmış profilde ülke kodu geçersiz.':
      'Profilul completat are un cod de țară nevalid.',
  'Tamamlanmış profilde para birimi kodu geçersiz.':
      'Profilul completat are un cod valutar nevalid.',
  'Global katalog henüz yüklenmedi.': 'Catalogul global nu s-a încărcat încă.',
  'Global katalog sayıları doğrulanamadı.':
      'Numărul elementelor din catalogul global nu a putut fi verificat.',
  'Bildirim izni veya zamanlama servisi açılamadı:':
      'Permisiunea de notificare sau serviciul de programare nu a putut fi deschis:',
  'Yerel kayıt alanı güvenli biçimde açılamadı. Mevcut dosyaları korumak için yeni veri yazımı durduruldu.':
      'Stocarea locală nu a putut fi deschisă în siguranță. Noile scrieri au fost oprite pentru a proteja fișierele existente.',
  'Bildirim izni kapalı. Android izni açıldığında MİZAN otomatik olarak yeniden senkronize eder.':
      'Permisiunea de notificare este dezactivată. MİZAN se va resincroniza automat după ce permisiunea Android este activată.',
  'Dakik bildirim izni kapalı. Android izni açıldığında MİZAN otomatik olarak yeniden senkronize eder.':
      'Permisiunea de alarmă exactă este dezactivată. MİZAN se va resincroniza automat după ce permisiunea Android este activată.',
  'Kayıt yapıldı ancak bildirimler otomatik senkronize edilemedi:':
      'Înregistrarea a fost salvată, dar notificările nu au putut fi sincronizate automat:',
  'Kişi adı': 'Numele persoanei',
  'Banka adı': 'Numele băncii',
  'Toplam borç': 'Datoria totală',
  'Aylık tutar': 'Sumă lunară',
  'Gecikme günü': 'Zile restante',
  'Limit': 'Limită',
  'Kullanılan limit': 'Limită folosită',
  'Açıklama': 'Descriere',
  'Düzenli ödeme tutarı': 'Valoarea plății regulate',
  'Borç başlığı': 'Titlul datoriei',
  'Alacaklı adı': 'Numele creditorului',
  'Çek numarası': 'Numărul cecului',
  'Düzenleyen': 'Emitentul',
  'Banka bilgisi': 'Informații bancare',
  'Senet numarası': 'Numărul biletului la ordin',
  'Ödeme planı tutarı': 'Valoarea planului de plată',
  'Abonelik tutarı': 'Valoarea abonamentului',
  'Abonelik türü': 'Tipul abonamentului',
  'Abonelik başlığı': 'Titlul abonamentului',
  'Sağlayıcı adı': 'Numele furnizorului',
  'Abone numarası': 'Numărul abonatului',
  'Sözleşme numarası': 'Numărul contractului',
  'Fatura tutarı': 'Valoarea facturii',
  'Dönem fatura tutarı': 'Valoarea facturii pentru perioadă',
  'Kurum adı': 'Numele instituției',
  'Kira/taksit tutarı': 'Sumă chirie/rată',
  'Kira/taksit başlığı': 'Titlu chirie/rată',
  'Alıcı adı': 'Numele beneficiarului',
  'IBAN': 'IBAN',
  'Adet': 'Cantitate',
  'Birim fiyat': 'Preț unitar',
  'Gider adı': 'Denumirea cheltuielii',
  'Gider notu': 'Nota cheltuielii',
  'Ödeme tutarı': 'Valoarea plății',
  'Ödeme notu': 'Notă de plată',
  'Ödeme yöntemi': 'Modalitate de plată',
  'Not': 'Notă',
  'Notlar': 'Note',
  'Kategori adı': 'Numele categoriei',
  'Gelir tutarı': 'Valoarea venitului',
  'Gelir türü': 'Tip de venit',
  'Gelir notu': 'Nota de venit',
  'Hatırlatma adı': 'Numele mementoului',
  'Bildirim mesajı': 'Mesaj de notificare',
  'Geçici': 'Temporar',
  'Ödeme hatırlatması': 'Memento de plată',
  'Yaklaşan ve gecikmiş ödemelerini kontrol et.':
      'Examinați plățile viitoare și restante.',
  'En fazla 10 ödeme bildirimi eklenebilir.':
      'Se pot adăuga cel mult 10 notificări de plată.',
  'Ödeme bildirim saati bulunamadı.':
      'Ora de notificare a plății nu a fost găsită.',
  'Bildirim saati geçersiz.': 'Ora de notificare nevalidă.',
  'En az bir ödeme bildirim saati bulunmalıdır.':
      'Este necesară cel puțin o oră pentru notificările de plată.',
  'Gelir kaydı bulunamadı.': 'Înregistrarea venitului nu a fost găsită.',
  'Haftalık gelir için geçerli bir gün seçilmelidir.':
      'Selectați o zi a săptămânii valabilă pentru venitul săptămânal.',
  'Aylık gelir günü 1 ile 31 arasında olmalıdır.':
      'Ziua lunară de încasare trebuie să fie între 1 și 31.',
  'Yatış günü takibi yalnız haftalık ve aylık gelirlerde kullanılabilir.':
      'Urmărirea zilei de încasare este disponibilă numai pentru veniturile săptămânale și lunare.',
  'Bu gelir için yatış günü takibi açık değil.':
      'Urmărirea zilei de plată nu este activată pentru acest venit.',
  'Bu gelir dönemi daha önce alındı olarak işaretlenmiş.':
      'Această perioadă de venit a fost deja marcată ca primită.',
  'Geri alınacak gelir işareti yok.':
      'Nu există o marcare a încasării care să poată fi anulată.',
  'Bildirim ayarı bulunamadı.': 'Setarea de notificare nu a fost găsită.',
  'Ödeme kalan borçtan büyük olamaz.': 'Plata nu poate depăși datoria rămasă.',
  'Borç kaydı bulunamadı.': 'Înregistrarea datoriei nu a fost găsită.',
  'Ödeme kalan fatura tutarından büyük olamaz.':
      'Plata nu poate depăși suma restantă a facturii.',
  'Ödeme aboneliğin bu dönem kalan tutarından büyük olamaz.':
      'Plata nu poate depăși suma rămasă a abonamentului pentru această perioadă.',
  'Ödeme kalan kira/taksit tutarından büyük olamaz.':
      'Plata nu poate depăși suma restantă a chiriei/ratei.',
  'Ödeme kaydı bulunamadı.': 'Înregistrarea plății nu a fost găsită.',
  'Güncellenen ödeme toplam tutarı aşamaz.':
      'Plata actualizată nu poate depăși suma totală.',
  'Toplam borç, daha önce ödenen tutardan düşük olamaz.':
      'Datoria totală nu poate fi mai mică decât suma plătită deja.',
  'Fatura tutarı, daha önce ödenen tutardan düşük olamaz.':
      'Suma facturii nu poate fi mai mică decât suma plătită deja.',
  'Kira/taksit tutarı, daha önce ödenen tutardan düşük olamaz.':
      'Suma chiriei/ratei nu poate fi mai mică decât suma plătită anterior.',
  'Her ayın belirli günü seçildiğinde aylık tutar girilmelidir.':
      'O sumă lunară este necesară atunci când este selectată o anumită zi a fiecărei luni.',
  'Gecikmiş ay seçimi yalnız aylık ödeme gününde kullanılabilir.':
      'Selecția lunilor restante este disponibilă numai cu o zi de plată lunară.',
  'Gecikmiş ayın ödeme tarihi henüz gelmemiş olamaz.':
      'Data scadență a lunii restante selectate nu poate fi în viitor.',
  'Kullanılan limit toplam limiti aşamaz.':
      'Creditul utilizat nu poate depăși limita totală.',
  'Son ödeme tarihi borç tarihinden önce olamaz.':
      'Data scadenței nu poate fi anterioară datei datoriei.',
  'Taksitli borçta ödeme tutarı girilmelidir.':
      'Pentru datoria în rate este necesară o sumă de plată.',
  'Özel ödeme aralığı gün olarak girilmelidir.':
      'Introduceți intervalul personalizat de plată în zile.',
  'Çek numarası boş bırakılamaz.': 'Numărul cecului este obligatoriu.',
  'Senet numarası boş bırakılamaz.': 'Numărul biletului la ordin este necesar.',
  'Abonelik ödeme sıklığı tek ödeme olamaz.':
      'Un abonament nu poate folosi o frecvență de plată unică.',
  'Aylık fatura günü 1 ile 31 arasında olmalıdır.':
      'Ziua lunară de plată a facturii trebuie să fie între 1 și 31.',
  'Ödeme günü 1 ile 31 arasında olmalı.':
      'Ziua de plată trebuie să fie între 1 și 31.',
  'Ürün taksitinde toplam taksit sayısı gereklidir.':
      'Numărul total de rate este necesar pentru o rată de produs.',
  'Sözleşme bitişi başlangıçtan önce olamaz.':
      'Data de încheiere a contractului nu poate fi anterioară datei de începere.',
  'Bir borç kaydında ödeme toplamı borcu aşıyor.':
      'Totalul plăților pentru o datorie depășește valoarea datoriei.',
  'Bir kişisel borçta ödeme toplamı borcu aşıyor.':
      'Totalul plăților pentru o datorie personală depășește valoarea datoriei.',
  'Bir fatura kaydında ödeme toplamı tutarı aşıyor.':
      'Totalul plăților pentru o factură depășește valoarea facturii.',
  'Aylık fatura ödeme günü geçersiz.':
      'Zi lunară de plată a facturii nevalidă.',
  'Dönemsel fatura tutarı sıfırdan büyük olmalıdır.':
      'Valoarea facturii pentru perioadă trebuie să fie mai mare decât zero.',
  'Bir kira kaydında ödeme toplamı tutarı aşıyor.':
      'Totalul plăților pentru o înregistrare de chirie depășește suma datorată.',
  'Bir gider kaydı bulunmayan kategoriye bağlı.':
      'O cheltuială este asociată unei categorii inexistente.',
  'Kişi bulunamadı.': 'Persoana nu a fost găsită.',
  'Banka kaydı bulunamadı.': 'Înregistrarea bancară nu a fost găsită.',
  'Kişisel/kurumsal borç bulunamadı.':
      'Datoria personală/comercială nu a fost găsită.',
  'Abonelik kaydı bulunamadı.': 'Înregistrarea abonamentului nu a fost găsită.',
  'Fatura kaydı bulunamadı.': 'Înregistrarea facturii nu a fost găsită.',
  'Kira/taksit kaydı bulunamadı.':
      'Înregistrarea chiriei/ratei nu a fost găsită.',
  'Gider kategorisi bulunamadı.': 'Categoria cheltuielii nu a fost găsită.',
  'Gider kaydı bulunamadı.': 'Înregistrarea cheltuielii nu a fost găsită.',
  'Bu kişide aynı banka adı zaten var.':
      'Această persoană are deja o bancă cu același nume.',
  'Bu kategori adı zaten kullanılıyor.':
      'Acest nume de categorie este deja utilizat.',
  'Banka borcu kaydı bulunamadı.':
      'Înregistrarea datoriei bancare nu a fost găsită.',
  'Toplam taksit pozitif olmalı.':
      'Numărul total de rate trebuie să fie pozitiv.',
  'Taksit ilerlemesi negatif olamaz.': 'Progresul ratelor nu poate fi negativ.',
  'Taksit ilerlemesi toplam taksiti aşamaz.':
      'Progresul ratelor nu poate depăși numărul total de rate.',
  'Tutar boş bırakılamaz.': 'Este necesară suma.',
  'Geçerli bir para tutarı girin.': 'Introduceți o sumă validă.',
  'Tutar biçimi anlaşılamadı.': 'Formatul sumei nu a putut fi recunoscut.',
  'En fazla iki kuruş hanesi girilebilir.':
      'Pot fi introduse cel mult două zecimale.',
  'Değer': 'Valoare',
  'Lefferion Prime - MİZAN hata yapabilir. Lütfen vade, gecikme ve ödeme bilgilerini son kez kontrol edin.':
      'Lefferion Prime - MİZAN poate face greșeli. Verificați încă o dată scadențele, starea de întârziere și informațiile despre plăți.',
  'Son ödeme bugün': 'Scadent astăzi',
  'Ocak': 'ianuarie',
  'Şubat': 'februarie',
  'Mart': 'martie',
  'Nisan': 'aprilie',
  'Mayıs': 'mai',
  'Haziran': 'iunie',
  'Temmuz': 'iulie',
  'Ağustos': 'august',
  'Eylül': 'septembrie',
  'Ekim': 'octombrie',
  'Kasım': 'noiembrie',
  'Aralık': 'decembrie',
  'Oca': 'ian',
  'Şub': 'feb',
  'Mar': 'mar',
  'Nis': 'apr',
  'May': 'mai',
  'Haz': 'iun',
  'Tem': 'iul',
  'Ağu': 'aug',
  'Eyl': 'sept',
  'Eki': 'oct',
  'Kas': 'nov',
  'Ara': 'dec',
  'Bildirim servisi bu platformda etkin değil.':
      'Serviciul de notificare nu este disponibil pe această platformă.',
  'Gider bildirimleri': 'Notificări de cheltuieli',
  'Ödeme bildirimleri': 'Notificări de plată',
  'Günlük gider kaydı bildirimleri':
      'Notificări de intrare zilnică a cheltuielilor',
  'Tüm kayıt türlerinin son ödeme bildirimleri':
      'Notificări de scadență pentru toate tipurile de înregistrări',
  'Android dışında gerçek zamanlama yapılmaz.':
      'Programarea reală este disponibilă numai pe Android.',
  'Bildirim izni kapalı.': 'Permisiunea de notificare este dezactivată.',
  'Dakik bildirim izni kapalı. Saat ve dakika doğruluğu için izni açın.':
      'Permisiunea pentru alarme exacte este dezactivată. Activați-o pentru livrare la ora și minutul selectate.',
  'Dakik bildirim izni verilmedi.':
      'Permisiunea pentru alarme exacte nu a fost acordată.',
  'Bildirim izni kapalı. Yeni bildirimler oluşturulmadı.':
      'Permisiunea de notificare este dezactivată. Nu au fost create notificări noi.',
  'Dakik bildirim izni kapalı. Android mevcut dakik planları iptal eder; izin açıldığında plan yeniden kurulmalıdır.':
      'Permisiunea pentru alarme exacte este dezactivată. Android anulează programările exacte existente; programarea trebuie refăcută după acordarea permisiunii.',
  'Bildirim izni kapalı. Önce bildirim iznini açın.':
      'Permisiunea de notificare este dezactivată. Activați mai întâi permisiunea de notificare.',
  'Dakik bildirim izni verilmedi. Test yaklaşık zamanda çalıştırılmayacak.':
      'Permisiunea pentru alarme exacte nu a fost acordată. Testul nu va fi executat cu o programare aproximativă.',
  'MİZAN bildirim testi': 'Test de notificare MİZAN',
  'Bu test, ayarlanan dakik bildirim sistemiyle oluşturuldu.':
      'Acest test a fost creat cu sistemul configurat de notificări la ora exactă.',
  'Yedek kayıt doğrulanamadı.': 'Copia de rezervă nu a putut fi verificată.',
  'Ana kayıt okunamadı; son sağlam yedek geri yüklendi.':
      'Fișierul de date principal nu a putut fi citit; ultima copie de rezervă validă a fost restaurată.',
  'Ana ve yedek kayıt dosyaları okunamadı. Dosyalar korunuyor.':
      'Nici fișierul de date principal, nici copia de rezervă nu au putut fi citite. Fișierele au fost păstrate.',
  'MİZAN kullanıma hazır. İlk kişi veya kaydı ekleyebilirsin.':
      'MİZAN este gata de utilizare. Adăugați prima persoană sau prima înregistrare pentru a începe.',
  'Geçici kayıt doğrulanamadı.': 'Salvarea temporară nu a putut fi verificată.',
};

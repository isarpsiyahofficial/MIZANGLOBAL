// REVIEWED FRENCH LOCALIZATION — VALIDATION, STORAGE AND NOTIFICATIONS.
const Map<String, String> mizanFrenchValidation = <String, String>{
  'Her değişiklik cihazda anında kaydedilir; sağlam kayıt doğrulanmadan üzerine yazılmaz.':
      'Chaque modification est enregistrée immédiatement sur l’appareil ; les données valides ne sont jamais remplacées avant la validation du nouvel enregistrement.',
  'Kişiler, borçlar, faturalar, abonelikler, ödemeler, notlar, gelirler ve giderler her işlemden sonra cihazdaki dosyaya yazılır.':
      'Les personnes, dettes, factures, abonnements, paiements, notes, revenus et dépenses sont écrits dans le fichier de l’appareil après chaque opération.',
  'Yeni kayıt doğrulandıktan sonra ana dosya değiştirilir; son sağlam kopya ayrıca korunur.':
      'Le fichier principal n’est remplacé qu’après validation des nouvelles données ; la dernière copie valide est également conservée.',
  'Yedek içe aktarılırken mevcut kayıtlar silinmez. Ortak kayıtlar atlanır, yalnız yeni kayıtlar ve eksik ilişkiler eklenir.':
      'Lors de l’importation d’une sauvegarde, les données existantes ne sont pas supprimées. Les éléments déjà présents sont ignorés ; seuls les nouveaux éléments et les liens manquants sont ajoutés.',
  'Kişi, banka, borç, ödeme, not, kategori, gider, gelir ve bildirim saatleri kendi kimlik ve bağlantılarıyla aktarılır. Aynı kayıt ikinci kez yazılmaz.':
      'Les personnes, banques, dettes, paiements, notes, catégories, dépenses, revenus et horaires de notification sont transférés avec leurs identifiants et leurs liens. Un même élément n’est jamais écrit deux fois.',
  'Uygulama dili seçilmelidir.': 'La langue de l’application doit être sélectionnée.',
  'Ülke kodu geçersiz.': 'Le code pays n’est pas valide.',
  'Para birimi kodu geçersiz.': 'Le code de devise n’est pas valide.',
  'Tamamlanmış profilde uygulama dili eksik.':
      'La langue de l’application est absente du profil finalisé.',
  'Tamamlanmış profilde ülke kodu geçersiz.':
      'Le profil finalisé contient un code pays non valide.',
  'Tamamlanmış profilde para birimi kodu geçersiz.':
      'Le profil finalisé contient un code de devise non valide.',
  'Global katalog henüz yüklenmedi.': 'Le catalogue mondial n’est pas encore chargé.',
  'Global katalog sayıları doğrulanamadı.':
      'Le nombre d’éléments du catalogue mondial n’a pas pu être validé.',
  'Bildirim izni veya zamanlama servisi açılamadı:':
      'Impossible d’ouvrir l’autorisation des notifications ou le service de programmation :',
  'Yerel kayıt alanı güvenli biçimde açılamadı. Mevcut dosyaları korumak için yeni veri yazımı durduruldu.':
      'L’espace de stockage local n’a pas pu être ouvert en toute sécurité. L’écriture de nouvelles données a été interrompue afin de protéger les fichiers existants.',
  'Bildirim izni kapalı. Android izni açıldığında MİZAN otomatik olarak yeniden senkronize eder.':
      'Les notifications ne sont pas autorisées. MİZAN se resynchronisera automatiquement dès que l’autorisation Android sera accordée.',
  'Dakik bildirim izni kapalı. Android izni açıldığında MİZAN otomatik olarak yeniden senkronize eder.':
      'Les alarmes exactes ne sont pas autorisées. MİZAN se resynchronisera automatiquement dès que l’autorisation Android sera accordée.',
  'Kayıt yapıldı ancak bildirimler otomatik senkronize edilemedi:':
      'Les données ont été enregistrées, mais les notifications n’ont pas pu être synchronisées automatiquement :',
  'Kişi adı': 'Nom de la personne',
  'Banka adı': 'Nom de la banque',
  'Toplam borç': 'Dette totale',
  'Aylık tutar': 'Montant mensuel',
  'Gecikme günü': 'Jours de retard',
  'Limit': 'Plafond',
  'Kullanılan limit': 'Plafond utilisé',
  'Açıklama': 'Description',
  'Düzenli ödeme tutarı': 'Montant du paiement récurrent',
  'Borç başlığı': 'Intitulé de la dette',
  'Alacaklı adı': 'Nom du créancier',
  'Çek numarası': 'Numéro du chèque',
  'Düzenleyen': 'Émetteur',
  'Banka bilgisi': 'Coordonnées bancaires',
  'Senet numarası': 'Numéro du billet à ordre',
  'Ödeme planı tutarı': 'Montant de l’échéancier',
  'Abonelik tutarı': 'Montant de l’abonnement',
  'Abonelik türü': 'Type d’abonnement',
  'Abonelik başlığı': 'Intitulé de l’abonnement',
  'Sağlayıcı adı': 'Nom du fournisseur',
  'Abone numarası': 'Numéro d’abonné',
  'Sözleşme numarası': 'Numéro de contrat',
  'Fatura tutarı': 'Montant de la facture',
  'Dönem fatura tutarı': 'Montant facturé pour la période',
  'Kurum adı': 'Nom de l’organisme',
  'Kira/taksit tutarı': 'Montant du loyer ou de la mensualité',
  'Kira/taksit başlığı': 'Intitulé du loyer ou de la mensualité',
  'Alıcı adı': 'Nom du bénéficiaire',
  'IBAN': 'IBAN',
  'Adet': 'Quantité',
  'Birim fiyat': 'Prix unitaire',
  'Gider adı': 'Nom de la dépense',
  'Gider notu': 'Note sur la dépense',
  'Ödeme tutarı': 'Montant du paiement',
  'Ödeme notu': 'Note sur le paiement',
  'Ödeme yöntemi': 'Mode de paiement',
  'Not': 'Note',
  'Notlar': 'Notes',
  'Kategori adı': 'Nom de la catégorie',
  'Gelir tutarı': 'Montant du revenu',
  'Gelir türü': 'Type de revenu',
  'Gelir notu': 'Note sur le revenu',
  'Hatırlatma adı': 'Nom du rappel',
  'Bildirim mesajı': 'Message de notification',
  'Geçici': 'Temporaire',
  'Ödeme hatırlatması': 'Rappel de paiement',
  'Yaklaşan ve gecikmiş ödemelerini kontrol et.':
      'Vérifiez vos paiements à venir et en retard.',
  'En fazla 10 ödeme bildirimi eklenebilir.':
      'Vous pouvez ajouter au maximum 10 notifications de paiement.',
  'Ödeme bildirim saati bulunamadı.':
      'L’horaire de la notification de paiement est introuvable.',
  'Bildirim saati geçersiz.': 'L’horaire de notification n’est pas valide.',
  'En az bir ödeme bildirim saati bulunmalıdır.':
      'Au moins un horaire de notification de paiement doit être défini.',
  'Gelir kaydı bulunamadı.': 'Le revenu enregistré est introuvable.',
  'Haftalık gelir için geçerli bir gün seçilmelidir.':
      'Un jour de la semaine valide doit être sélectionné pour un revenu hebdomadaire.',
  'Aylık gelir günü 1 ile 31 arasında olmalıdır.':
      'Le jour du revenu mensuel doit être compris entre 1 et 31.',
  'Yatış günü takibi yalnız haftalık ve aylık gelirlerde kullanılabilir.':
      'Le suivi du jour de versement est disponible uniquement pour les revenus hebdomadaires et mensuels.',
  'Bu gelir için yatış günü takibi açık değil.':
      'Le suivi du jour de versement n’est pas activé pour ce revenu.',
  'Bu gelir dönemi daha önce alındı olarak işaretlenmiş.':
      'Cette période de revenu est déjà marquée comme reçue.',
  'Geri alınacak gelir işareti yok.':
      'Aucune réception de revenu ne peut être annulée.',
  'Bildirim ayarı bulunamadı.': 'Le paramètre de notification est introuvable.',
  'Ödeme kalan borçtan büyük olamaz.':
      'Le paiement ne peut pas dépasser le solde restant de la dette.',
  'Borç kaydı bulunamadı.': 'La dette enregistrée est introuvable.',
  'Ödeme kalan fatura tutarından büyük olamaz.':
      'Le paiement ne peut pas dépasser le montant restant de la facture.',
  'Ödeme aboneliğin bu dönem kalan tutarından büyük olamaz.':
      'Le paiement ne peut pas dépasser le montant restant de l’abonnement pour cette période.',
  'Ödeme kalan kira/taksit tutarından büyük olamaz.':
      'Le paiement ne peut pas dépasser le montant restant du loyer ou de la mensualité.',
  'Ödeme kaydı bulunamadı.': 'Le paiement enregistré est introuvable.',
  'Güncellenen ödeme toplam tutarı aşamaz.':
      'Le paiement modifié ne peut pas dépasser le montant total.',
  'Toplam borç, daha önce ödenen tutardan düşük olamaz.':
      'La dette totale ne peut pas être inférieure au montant déjà payé.',
  'Fatura tutarı, daha önce ödenen tutardan düşük olamaz.':
      'Le montant de la facture ne peut pas être inférieur au montant déjà payé.',
  'Kira/taksit tutarı, daha önce ödenen tutardan düşük olamaz.':
      'Le montant du loyer ou de la mensualité ne peut pas être inférieur au montant déjà payé.',
  'Her ayın belirli günü seçildiğinde aylık tutar girilmelidir.':
      'Un montant mensuel doit être saisi lorsqu’un jour précis de chaque mois est sélectionné.',
  'Gecikmiş ay seçimi yalnız aylık ödeme gününde kullanılabilir.':
      'La sélection d’un mois en retard est disponible uniquement pour les paiements assortis d’un jour mensuel.',
  'Gecikmiş ayın ödeme tarihi henüz gelmemiş olamaz.':
      'La date d’échéance du mois marqué en retard ne peut pas être située dans le futur.',
  'Kullanılan limit toplam limiti aşamaz.':
      'Le plafond utilisé ne peut pas dépasser le plafond total.',
  'Son ödeme tarihi borç tarihinden önce olamaz.':
      'La date d’échéance ne peut pas être antérieure à la date de la dette.',
  'Taksitli borçta ödeme tutarı girilmelidir.':
      'Un montant de paiement doit être saisi pour une dette remboursée en plusieurs fois.',
  'Özel ödeme aralığı gün olarak girilmelidir.':
      'L’intervalle de paiement personnalisé doit être saisi en jours.',
  'Çek numarası boş bırakılamaz.': 'Le numéro du chèque est obligatoire.',
  'Senet numarası boş bırakılamaz.': 'Le numéro du billet à ordre est obligatoire.',
  'Abonelik ödeme sıklığı tek ödeme olamaz.':
      'La fréquence de paiement d’un abonnement ne peut pas être définie sur paiement unique.',
  'Aylık fatura günü 1 ile 31 arasında olmalıdır.':
      'Le jour de facturation mensuelle doit être compris entre 1 et 31.',
  'Ödeme günü 1 ile 31 arasında olmalı.':
      'Le jour de paiement doit être compris entre 1 et 31.',
  'Ürün taksitinde toplam taksit sayısı gereklidir.':
      'Le nombre total de mensualités est obligatoire pour un achat payé en plusieurs fois.',
  'Sözleşme bitişi başlangıçtan önce olamaz.':
      'La date de fin du contrat ne peut pas être antérieure à sa date de début.',
  'Bir borç kaydında ödeme toplamı borcu aşıyor.':
      'Le total des paiements d’une dette dépasse son montant.',
  'Bir kişisel borçta ödeme toplamı borcu aşıyor.':
      'Le total des paiements d’une dette personnelle dépasse son montant.',
  'Bir fatura kaydında ödeme toplamı tutarı aşıyor.':
      'Le total des paiements d’une facture dépasse son montant.',
  'Aylık fatura ödeme günü geçersiz.':
      'Le jour de paiement de la facture mensuelle n’est pas valide.',
  'Dönemsel fatura tutarı sıfırdan büyük olmalıdır.':
      'Le montant facturé pour la période doit être supérieur à zéro.',
  'Bir kira kaydında ödeme toplamı tutarı aşıyor.':
      'Le total des paiements d’un loyer dépasse le montant dû.',
  'Bir gider kaydı bulunmayan kategoriye bağlı.':
      'Une dépense est liée à une catégorie inexistante.',
  'Kişi bulunamadı.': 'La personne est introuvable.',
  'Banka kaydı bulunamadı.': 'Les coordonnées bancaires sont introuvables.',
  'Kişisel/kurumsal borç bulunamadı.':
      'La dette personnelle ou professionnelle est introuvable.',
  'Abonelik kaydı bulunamadı.': 'L’abonnement enregistré est introuvable.',
  'Fatura kaydı bulunamadı.': 'La facture enregistrée est introuvable.',
  'Kira/taksit kaydı bulunamadı.':
      'Le loyer ou la mensualité enregistrés sont introuvables.',
  'Gider kategorisi bulunamadı.': 'La catégorie de dépense est introuvable.',
  'Gider kaydı bulunamadı.': 'La dépense enregistrée est introuvable.',
  'Bu kişide aynı banka adı zaten var.':
      'Une banque portant ce nom existe déjà pour cette personne.',
  'Bu kategori adı zaten kullanılıyor.':
      'Ce nom de catégorie est déjà utilisé.',
  'Banka borcu kaydı bulunamadı.': 'La dette bancaire enregistrée est introuvable.',
  'Toplam taksit pozitif olmalı.':
      'Le nombre total de mensualités doit être supérieur à zéro.',
  'Taksit ilerlemesi negatif olamaz.':
      'L’avancement des mensualités ne peut pas être négatif.',
  'Taksit ilerlemesi toplam taksiti aşamaz.':
      'L’avancement des mensualités ne peut pas dépasser leur nombre total.',
  'Tutar boş bırakılamaz.': 'Le montant est obligatoire.',
  'Geçerli bir para tutarı girin.': 'Saisissez un montant valide.',
  'Tutar biçimi anlaşılamadı.': 'Le format du montant n’a pas été reconnu.',
  'En fazla iki kuruş hanesi girilebilir.':
      'Deux décimales au maximum sont autorisées.',
  'Değer': 'Valeur',
  'Lefferion Prime - MİZAN hata yapabilir. Lütfen vade, gecikme ve ödeme bilgilerini son kez kontrol edin.':
      'Lefferion Prime — MİZAN peut commettre des erreurs. Vérifiez une dernière fois les échéances, les retards et les informations de paiement.',
  'Son ödeme bugün': 'Échéance aujourd’hui',
  'Ocak': 'Janvier',
  'Şubat': 'Février',
  'Mart': 'Mars',
  'Nisan': 'Avril',
  'Mayıs': 'Mai',
  'Haziran': 'Juin',
  'Temmuz': 'Juillet',
  'Ağustos': 'Août',
  'Eylül': 'Septembre',
  'Ekim': 'Octobre',
  'Kasım': 'Novembre',
  'Aralık': 'Décembre',
  'Oca': 'janv.',
  'Şub': 'févr.',
  'Mar': 'mars',
  'Nis': 'avr.',
  'May': 'mai',
  'Haz': 'juin',
  'Tem': 'juil.',
  'Ağu': 'août',
  'Eyl': 'sept.',
  'Eki': 'oct.',
  'Kas': 'nov.',
  'Ara': 'déc.',
  'Bildirim servisi bu platformda etkin değil.':
      'Le service de notifications n’est pas disponible sur cette plateforme.',
  'Gider bildirimleri': 'Notifications de dépenses',
  'Ödeme bildirimleri': 'Notifications de paiement',
  'Günlük gider kaydı bildirimleri':
      'Notifications quotidiennes de saisie des dépenses',
  'Tüm kayıt türlerinin son ödeme bildirimleri':
      'Notifications d’échéance pour tous les types de données',
  'Android dışında gerçek zamanlama yapılmaz.':
      'La programmation réelle est disponible uniquement sur Android.',
  'Bildirim izni kapalı.': 'Les notifications ne sont pas autorisées.',
  'Dakik bildirim izni kapalı. Saat ve dakika doğruluğu için izni açın.':
      'Les alarmes exactes ne sont pas autorisées. Accordez cette autorisation pour respecter l’heure et la minute prévues.',
  'Dakik bildirim izni verilmedi.':
      'L’autorisation des alarmes exactes n’a pas été accordée.',
  'Bildirim izni kapalı. Yeni bildirimler oluşturulmadı.':
      'Les notifications ne sont pas autorisées. Aucune nouvelle notification n’a été créée.',
  'Dakik bildirim izni kapalı. Android mevcut dakik planları iptal eder; izin açıldığında plan yeniden kurulmalıdır.':
      'Les alarmes exactes ne sont pas autorisées. Android annule les programmations exactes existantes ; elles devront être recréées après l’octroi de l’autorisation.',
  'Bildirim izni kapalı. Önce bildirim iznini açın.':
      'Les notifications ne sont pas autorisées. Accordez d’abord cette autorisation.',
  'Dakik bildirim izni verilmedi. Test yaklaşık zamanda çalıştırılmayacak.':
      'L’autorisation des alarmes exactes n’a pas été accordée. Le test ne sera pas exécuté à une heure approximative.',
  'MİZAN bildirim testi': 'Test de notification MİZAN',
  'Bu test, ayarlanan dakik bildirim sistemiyle oluşturuldu.':
      'Ce test a été créé avec le système configuré de notifications à l’heure exacte.',
  'Yedek kayıt doğrulanamadı.': 'La sauvegarde n’a pas pu être validée.',
  'Ana kayıt okunamadı; son sağlam yedek geri yüklendi.':
      'Le fichier principal n’a pas pu être lu ; la dernière sauvegarde valide a été restaurée.',
  'Ana ve yedek kayıt dosyaları okunamadı. Dosyalar korunuyor.':
      'Le fichier principal et le fichier de sauvegarde n’ont pas pu être lus. Les fichiers sont conservés.',
  'MİZAN kullanıma hazır. İlk kişi veya kaydı ekleyebilirsin.':
      'MİZAN est prêt à l’emploi. Vous pouvez ajouter la première personne ou le premier élément.',
  'Geçici kayıt doğrulanamadı.':
      'L’enregistrement temporaire n’a pas pu être validé.',
};

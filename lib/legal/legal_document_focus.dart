import 'legal_documents.dart';

abstract final class LegalDocumentFocus {
  static const Map<String, Map<String, String>> _values = {
    'tr': {
      'privacy':
          'Bu belge, cihazda tutulan finansal kayıtları, internet bağlantısı kontrolünü, Google reklam hizmetlerini ve reklam gizlilik tercihlerinin sözleşme kabulünden ayrı nasıl yönetildiğini açıklar.',
      'terms':
          'Bu belge, MIZAN kullanım kurallarını, ücretsiz ve Premium erişimi, yerel veri sorumluluğunu ve güncel hukuki paket kabul edilmeden normal kullanımın açılamayacağını açıklar.',
      'purchase':
          'Bu belge, tek seferlik premium_lifetime satın alımını, Google Play üzerinden otomatik geri yüklemeyi, iade haklarını ve süreli Premium yollarını açıklar.',
    },
    'en': {
      'privacy':
          'This document explains local financial records, connectivity checks, Google advertising services, and how advertising privacy choices are handled separately from mandatory legal acceptance.',
      'terms':
          'This document explains MIZAN use rules, Free and Premium access, local-data responsibilities, and the requirement to accept the current legal bundle before normal use.',
      'purchase':
          'This document explains the one-time premium_lifetime purchase, automatic Google Play restore, refund rights, and temporary Premium routes.',
    },
    'es': {
      'privacy':
          'Este documento explica los registros financieros locales, las comprobaciones de conexión, los servicios publicitarios de Google y la gestión separada de las opciones de privacidad publicitaria.',
      'terms':
          'Este documento explica las reglas de uso de MIZAN, el acceso gratuito y Premium, la responsabilidad sobre los datos locales y la aceptación obligatoria del paquete legal antes del uso normal.',
      'purchase':
          'Este documento explica la compra única premium_lifetime, la restauración automática mediante Google Play, los derechos de reembolso y las modalidades Premium temporales.',
    },
    'pt-BR': {
      'privacy':
          'Este documento explica os registros financeiros locais, a verificação de conexão, os serviços de anúncios do Google e a gestão separada das escolhas de privacidade de anúncios.',
      'terms':
          'Este documento explica as regras de uso do MIZAN, o acesso gratuito e Premium, a responsabilidade pelos dados locais e a aceitação obrigatória do pacote jurídico antes do uso normal.',
      'purchase':
          'Este documento explica a compra única premium_lifetime, a restauração automática pelo Google Play, os direitos de reembolso e as formas de Premium temporário.',
    },
    'pt-PT': {
      'privacy':
          'Este documento explica os registos financeiros locais, a verificação da ligação, os serviços publicitários da Google e a gestão separada das escolhas de privacidade publicitária.',
      'terms':
          'Este documento explica as regras de utilização do MIZAN, o acesso gratuito e Premium, a responsabilidade pelos dados locais e a aceitação obrigatória do pacote jurídico antes da utilização normal.',
      'purchase':
          'Este documento explica a compra única premium_lifetime, o restauro automático através do Google Play, os direitos de reembolso e as modalidades Premium temporárias.',
    },
    'fr': {
      'privacy':
          'Ce document explique les données financières locales, les vérifications de connexion, les services publicitaires Google et la gestion séparée des choix de confidentialité publicitaire.',
      'terms':
          'Ce document explique les règles d’utilisation de MIZAN, les accès gratuit et Premium, la responsabilité des données locales et l’acceptation obligatoire du dossier juridique avant l’utilisation normale.',
      'purchase':
          'Ce document explique l’achat unique premium_lifetime, la restauration automatique via Google Play, les droits au remboursement et les formes temporaires de Premium.',
    },
    'de': {
      'privacy':
          'Dieses Dokument erläutert lokale Finanzdaten, Verbindungsprüfungen, Google-Werbedienste und die getrennte Verwaltung von Datenschutzentscheidungen für Werbung.',
      'terms':
          'Dieses Dokument erläutert die MIZAN-Nutzungsregeln, kostenlosen und Premium-Zugang, Verantwortung für lokale Daten und die erforderliche Annahme des aktuellen Rechtspakets vor der normalen Nutzung.',
      'purchase':
          'Dieses Dokument erläutert den einmaligen Kauf premium_lifetime, die automatische Wiederherstellung über Google Play, Erstattungsrechte und zeitlich begrenzte Premium-Wege.',
    },
    'it': {
      'privacy':
          'Questo documento spiega i dati finanziari locali, i controlli di connettività, i servizi pubblicitari Google e la gestione separata delle scelte sulla privacy pubblicitaria.',
      'terms':
          'Questo documento spiega le regole d’uso di MIZAN, l’accesso gratuito e Premium, la responsabilità dei dati locali e l’accettazione obbligatoria del pacchetto legale prima dell’uso normale.',
      'purchase':
          'Questo documento spiega l’acquisto una tantum premium_lifetime, il ripristino automatico tramite Google Play, i diritti di rimborso e le modalità Premium temporanee.',
    },
    'nl': {
      'privacy':
          'Dit document legt lokale financiële gegevens, verbindingscontroles, Google-advertentiediensten en de afzonderlijke verwerking van advertentieprivacykeuzes uit.',
      'terms':
          'Dit document legt de MIZAN-gebruiksregels, gratis en Premium-toegang, verantwoordelijkheid voor lokale gegevens en verplichte aanvaarding van het juridische pakket vóór normaal gebruik uit.',
      'purchase':
          'Dit document legt de eenmalige aankoop premium_lifetime, automatisch herstel via Google Play, terugbetalingsrechten en tijdelijke Premium-routes uit.',
    },
    'pl': {
      'privacy':
          'Ten dokument opisuje lokalne dane finansowe, sprawdzanie połączenia, usługi reklamowe Google oraz oddzielne zarządzanie wyborami prywatności reklam.',
      'terms':
          'Ten dokument opisuje zasady korzystania z MIZAN, dostęp bezpłatny i Premium, odpowiedzialność za dane lokalne oraz obowiązek zaakceptowania aktualnego pakietu prawnego przed normalnym użyciem.',
      'purchase':
          'Ten dokument opisuje jednorazowy zakup premium_lifetime, automatyczne przywracanie przez Google Play, prawa do zwrotu oraz czasowe formy Premium.',
    },
    'ro': {
      'privacy':
          'Acest document explică datele financiare locale, verificările de conectivitate, serviciile de publicitate Google și gestionarea separată a opțiunilor de confidențialitate pentru reclame.',
      'terms':
          'Acest document explică regulile de utilizare MIZAN, accesul gratuit și Premium, responsabilitatea pentru datele locale și acceptarea obligatorie a pachetului juridic înainte de utilizarea normală.',
      'purchase':
          'Acest document explică achiziția unică premium_lifetime, restaurarea automată prin Google Play, drepturile de rambursare și formele temporare de Premium.',
    },
    'el': {
      'privacy':
          'Το έγγραφο εξηγεί τα τοπικά οικονομικά δεδομένα, τους ελέγχους σύνδεσης, τις υπηρεσίες διαφήμισης Google και τη χωριστή διαχείριση των επιλογών απορρήτου διαφημίσεων.',
      'terms':
          'Το έγγραφο εξηγεί τους κανόνες χρήσης του MIZAN, τη δωρεάν και Premium πρόσβαση, την ευθύνη για τα τοπικά δεδομένα και την υποχρεωτική αποδοχή του νομικού πακέτου πριν από την κανονική χρήση.',
      'purchase':
          'Το έγγραφο εξηγεί την εφάπαξ αγορά premium_lifetime, την αυτόματη επαναφορά μέσω Google Play, τα δικαιώματα επιστροφής χρημάτων και τις προσωρινές μορφές Premium.',
    },
    'ru': {
      'privacy':
          'Документ объясняет локальное хранение финансовых данных, проверку подключения, рекламные сервисы Google и отдельное управление настройками конфиденциальности рекламы.',
      'terms':
          'Документ объясняет правила MIZAN, бесплатный и Premium-доступ, ответственность за локальные данные и обязательное принятие актуального юридического пакета до обычного использования.',
      'purchase':
          'Документ объясняет разовую покупку premium_lifetime, автоматическое восстановление через Google Play, права на возврат и временные варианты Premium.',
    },
    'uk': {
      'privacy':
          'Документ пояснює локальне зберігання фінансових даних, перевірку з’єднання, рекламні сервіси Google та окреме керування налаштуваннями приватності реклами.',
      'terms':
          'Документ пояснює правила MIZAN, безкоштовний і Premium-доступ, відповідальність за локальні дані та обов’язкове прийняття актуального юридичного пакета до звичайного використання.',
      'purchase':
          'Документ пояснює одноразову покупку premium_lifetime, автоматичне відновлення через Google Play, права на повернення та тимчасові варіанти Premium.',
    },
    'ar': {
      'privacy':
          'تشرح هذه الوثيقة حفظ السجلات المالية محليًا وفحص الاتصال وخدمات إعلانات Google وكيفية إدارة خيارات خصوصية الإعلانات بصورة منفصلة عن القبول القانوني الإلزامي.',
      'terms':
          'تشرح هذه الوثيقة قواعد استخدام MIZAN والوصول المجاني وPremium ومسؤولية البيانات المحلية وضرورة قبول الحزمة القانونية الحالية قبل الاستخدام العادي.',
      'purchase':
          'تشرح هذه الوثيقة شراء premium_lifetime لمرة واحدة والاستعادة التلقائية عبر Google Play وحقوق الاسترداد وطرق Premium المؤقتة.',
    },
    'fa': {
      'privacy':
          'این سند نگهداری محلی سوابق مالی، بررسی اتصال، خدمات تبلیغاتی Google و مدیریت جداگانه انتخاب‌های حریم خصوصی تبلیغات از پذیرش حقوقی اجباری را توضیح می‌دهد.',
      'terms':
          'این سند قوانین استفاده از MIZAN، دسترسی رایگان و Premium، مسئولیت داده‌های محلی و الزام پذیرش بسته حقوقی جاری پیش از استفاده عادی را توضیح می‌دهد.',
      'purchase':
          'این سند خرید یک‌باره premium_lifetime، بازیابی خودکار از طریق Google Play، حقوق بازپرداخت و روش‌های Premium موقت را توضیح می‌دهد.',
    },
    'he': {
      'privacy':
          'מסמך זה מסביר שמירת נתונים פיננסיים מקומית, בדיקות חיבור, שירותי הפרסום של Google וניהול נפרד של בחירות פרטיות בפרסום מהקבלה המשפטית המחייבת.',
      'terms':
          'מסמך זה מסביר את כללי השימוש ב-MIZAN, גישה חינמית ו-Premium, אחריות לנתונים מקומיים ואת החובה לקבל את החבילה המשפטית העדכנית לפני שימוש רגיל.',
      'purchase':
          'מסמך זה מסביר את הרכישה החד-פעמית premium_lifetime, שחזור אוטומטי דרך Google Play, זכויות החזר ודרכי Premium זמניות.',
    },
    'hi': {
      'privacy':
          'यह दस्तावेज़ स्थानीय वित्तीय रिकॉर्ड, कनेक्टिविटी जाँच, Google विज्ञापन सेवाओं और अनिवार्य कानूनी स्वीकृति से अलग विज्ञापन गोपनीयता विकल्पों के प्रबंधन को समझाता है।',
      'terms':
          'यह दस्तावेज़ MIZAN उपयोग नियम, निःशुल्क और Premium पहुँच, स्थानीय डेटा की जिम्मेदारी और सामान्य उपयोग से पहले वर्तमान कानूनी पैकेज स्वीकार करने की आवश्यकता समझाता है।',
      'purchase':
          'यह दस्तावेज़ एकमुश्त premium_lifetime खरीद, Google Play से स्वचालित पुनर्स्थापना, रिफंड अधिकार और अस्थायी Premium विकल्प समझाता है।',
    },
    'bn': {
      'privacy':
          'এই নথিতে স্থানীয় আর্থিক রেকর্ড, সংযোগ পরীক্ষা, Google বিজ্ঞাপন সেবা এবং বাধ্যতামূলক আইনি গ্রহণ থেকে আলাদাভাবে বিজ্ঞাপন গোপনীয়তার পছন্দ পরিচালনার বিষয় ব্যাখ্যা করা হয়েছে।',
      'terms':
          'এই নথিতে MIZAN ব্যবহারের নিয়ম, বিনামূল্যে ও Premium প্রবেশাধিকার, স্থানীয় ডেটার দায়িত্ব এবং স্বাভাবিক ব্যবহারের আগে বর্তমান আইনি প্যাকেজ গ্রহণের বাধ্যবাধকতা ব্যাখ্যা করা হয়েছে।',
      'purchase':
          'এই নথিতে একবারের premium_lifetime ক্রয়, Google Play-এর মাধ্যমে স্বয়ংক্রিয় পুনরুদ্ধার, ফেরতের অধিকার এবং সাময়িক Premium পদ্ধতি ব্যাখ্যা করা হয়েছে।',
    },
    'ur': {
      'privacy':
          'یہ دستاویز مقامی مالی ریکارڈ، کنکشن جانچ، Google اشتہاری خدمات اور لازمی قانونی قبولیت سے الگ اشتہاری رازداری کے انتخاب کے انتظام کی وضاحت کرتی ہے۔',
      'terms':
          'یہ دستاویز MIZAN کے استعمال کے قواعد، مفت اور Premium رسائی، مقامی ڈیٹا کی ذمہ داری اور عام استعمال سے پہلے موجودہ قانونی پیکیج قبول کرنے کی شرط بیان کرتی ہے۔',
      'purchase':
          'یہ دستاویز ایک مرتبہ premium_lifetime خرید، Google Play سے خودکار بحالی، رقم واپسی کے حقوق اور عارضی Premium طریقوں کی وضاحت کرتی ہے۔',
    },
    'id': {
      'privacy':
          'Dokumen ini menjelaskan catatan keuangan lokal, pemeriksaan koneksi, layanan iklan Google, serta pengelolaan pilihan privasi iklan secara terpisah dari persetujuan hukum wajib.',
      'terms':
          'Dokumen ini menjelaskan aturan penggunaan MIZAN, akses Gratis dan Premium, tanggung jawab data lokal, serta kewajiban menerima paket hukum terbaru sebelum penggunaan normal.',
      'purchase':
          'Dokumen ini menjelaskan pembelian sekali premium_lifetime, pemulihan otomatis melalui Google Play, hak pengembalian dana, dan jalur Premium sementara.',
    },
    'ms': {
      'privacy':
          'Dokumen ini menerangkan rekod kewangan setempat, semakan sambungan, perkhidmatan iklan Google dan pengurusan pilihan privasi iklan secara berasingan daripada penerimaan undang-undang wajib.',
      'terms':
          'Dokumen ini menerangkan peraturan penggunaan MIZAN, akses Percuma dan Premium, tanggungjawab data setempat serta kewajipan menerima pakej undang-undang semasa sebelum penggunaan biasa.',
      'purchase':
          'Dokumen ini menerangkan pembelian sekali premium_lifetime, pemulihan automatik melalui Google Play, hak bayaran balik dan laluan Premium sementara.',
    },
    'fil': {
      'privacy':
          'Ipinapaliwanag ng dokumentong ito ang lokal na financial records, pagsusuri ng koneksiyon, mga serbisyo ng Google ads, at hiwalay na pamamahala ng mga pagpili sa ad privacy mula sa sapilitang legal na pagtanggap.',
      'terms':
          'Ipinapaliwanag ng dokumentong ito ang mga tuntunin ng MIZAN, Free at Premium access, pananagutan sa lokal na data, at kinakailangang pagtanggap sa kasalukuyang legal package bago normal na paggamit.',
      'purchase':
          'Ipinapaliwanag ng dokumentong ito ang minsanang premium_lifetime purchase, awtomatikong restore sa Google Play, refund rights, at pansamantalang Premium routes.',
    },
    'vi': {
      'privacy':
          'Tài liệu này giải thích dữ liệu tài chính lưu cục bộ, kiểm tra kết nối, dịch vụ quảng cáo Google và cách quản lý lựa chọn quyền riêng tư quảng cáo tách biệt với việc chấp nhận pháp lý bắt buộc.',
      'terms':
          'Tài liệu này giải thích quy tắc sử dụng MIZAN, quyền truy cập Miễn phí và Premium, trách nhiệm với dữ liệu cục bộ và yêu cầu chấp nhận bộ điều khoản hiện hành trước khi sử dụng bình thường.',
      'purchase':
          'Tài liệu này giải thích giao dịch premium_lifetime một lần, khôi phục tự động qua Google Play, quyền hoàn tiền và các hình thức Premium tạm thời.',
    },
    'th': {
      'privacy':
          'เอกสารนี้อธิบายข้อมูลการเงินที่เก็บไว้ในเครื่อง การตรวจสอบการเชื่อมต่อ บริการโฆษณาของ Google และการจัดการตัวเลือกความเป็นส่วนตัวของโฆษณาแยกจากการยอมรับข้อกำหนดทางกฎหมายที่จำเป็น',
      'terms':
          'เอกสารนี้อธิบายกฎการใช้ MIZAN การเข้าถึงแบบฟรีและ Premium ความรับผิดชอบต่อข้อมูลในเครื่อง และข้อกำหนดให้ยอมรับชุดเอกสารกฎหมายปัจจุบันก่อนใช้งานตามปกติ',
      'purchase':
          'เอกสารนี้อธิบายการซื้อ premium_lifetime แบบครั้งเดียว การกู้คืนอัตโนมัติผ่าน Google Play สิทธิการคืนเงิน และวิธีรับ Premium ชั่วคราว',
    },
    'sw': {
      'privacy':
          'Hati hii inaeleza rekodi za fedha zinazohifadhiwa kwenye kifaa, ukaguzi wa muunganisho, huduma za matangazo za Google na usimamizi tofauti wa chaguo za faragha ya matangazo.',
      'terms':
          'Hati hii inaeleza kanuni za kutumia MIZAN, ufikiaji wa Bure na Premium, wajibu wa data za kifaa na sharti la kukubali kifurushi cha sasa cha kisheria kabla ya matumizi ya kawaida.',
      'purchase':
          'Hati hii inaeleza ununuzi wa mara moja wa premium_lifetime, urejeshaji wa moja kwa moja kupitia Google Play, haki za kurejeshewa fedha na njia za Premium za muda.',
    },
    'zh': {
      'privacy': '本文说明本地财务记录、网络连接检查、Google 广告服务，以及广告隐私选择如何与强制法律条款的接受分开管理。',
      'terms': '本文说明 MIZAN 的使用规则、免费与 Premium 权限、本地数据责任，以及在正常使用前必须接受当前法律文件包的要求。',
      'purchase':
          '本文说明一次性 premium_lifetime 购买、通过 Google Play 自动恢复、退款权利以及临时 Premium 获取方式。',
    },
    'ja': {
      'privacy':
          'この文書は、端末内の金融記録、接続確認、Google 広告サービス、および広告プライバシーの選択を必須の法的同意とは別に管理する仕組みを説明します。',
      'terms':
          'この文書は、MIZAN の利用規則、無料版と Premium、端末内データの責任、および通常利用前に最新の法的文書一式への同意が必要であることを説明します。',
      'purchase':
          'この文書は、一回限りの premium_lifetime 購入、Google Play による自動復元、返金に関する権利、一時的な Premium の取得方法を説明します。',
    },
    'ko': {
      'privacy':
          '이 문서는 기기 내 금융 기록, 연결 확인, Google 광고 서비스, 그리고 광고 개인정보 선택을 필수 법적 동의와 별도로 관리하는 방식을 설명합니다.',
      'terms':
          '이 문서는 MIZAN 이용 규칙, 무료 및 Premium 이용, 로컬 데이터 책임, 정상 사용 전에 최신 법적 문서 묶음을 동의해야 하는 요구사항을 설명합니다.',
      'purchase':
          '이 문서는 일회성 premium_lifetime 구매, Google Play 자동 복원, 환불 권리 및 임시 Premium 획득 방식을 설명합니다.',
    },
  };

  static String text(LegalDocumentType type, String languageTag) {
    final values = _values[languageTag] ?? _values['en']!;
    final key = switch (type) {
      LegalDocumentType.privacy => 'privacy',
      LegalDocumentType.terms => 'terms',
      LegalDocumentType.purchase => 'purchase',
    };
    return values[key] ?? _values['en']![key]!;
  }
}

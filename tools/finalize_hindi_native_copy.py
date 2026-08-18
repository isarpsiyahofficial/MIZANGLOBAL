#!/usr/bin/env python3
"""Apply the reviewed India-oriented Hindi product-copy decisions.

The stable Turkish keys remain untouched. This script only rewrites Hindi values,
is deterministic, and is safe to run repeatedly.
"""
from __future__ import annotations

import re
import sys
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))

from build_ukrainian_locale import parse_map  # noqa: E402
from hindi_terminology import HINDI_TERMINOLOGY  # noqa: E402

PARTS = tuple(sorted((ROOT / 'lib/l10n/hi').glob('mizan_hi_*.dart')))

EXACT: dict[str, str] = {
    # Core finance and navigation.
    'MİZAN Aylık Raporu': 'MİZAN मासिक रिपोर्ट',
    'Aktif': 'सक्रिय',
    'Yaklaşıyor': 'जल्द देय',
    'Gecikmede': 'बकाया',
    'Tamamlandı': 'पूरा हुआ',
    'Pasif': 'निष्क्रिय',
    'Özel borç türü': 'अपनी पसंद का कर्ज़ प्रकार',
    'Her ayın belirli günü': 'हर महीने की तय तारीख',
    'Taksit ödemesi': 'किस्त का भुगतान',
    'Borç kapama': 'पूरा कर्ज़ चुकाना',
    'Cihazın varsayılan bildirim sesi': 'डिवाइस की डिफ़ॉल्ट सूचना ध्वनि',
    'Sessiz': 'बिना आवाज़',
    'Tek seferlik': 'एक बार',
    'Özel fatura': 'अपनी पसंद का बिल',
    'Tek dönem faturası': 'एक अवधि का बिल',
    'Her ay tekrarlayan fatura': 'हर महीने आने वाला बिल',
    'Ev kirası': 'घर का किराया',
    'Ürün taksiti': 'उत्पाद की किस्त',
    'Özel oluştur': 'अपनी पसंद से बनाएँ',
    'Şirket / Kurum': 'कंपनी / संस्था',
    'Esnaf / İşletme': 'दुकानदार / व्यवसाय',
    'Aile / Yakın': 'परिवार / करीबी',
    'Tek ödeme': 'एकमुश्त भुगतान',
    'İki haftada bir': 'हर दो सप्ताह',
    'Özel aralık': 'अपनी पसंद का अंतराल',
    'Bakım / servis': 'रखरखाव / सेवा',
    'Diğer abonelik': 'अन्य सदस्यता',
    'Kişisel / kurumsal borç': 'व्यक्तिगत / व्यावसायिक कर्ज़',
    'Aramayı temizle': 'खोज साफ़ करें',
    'Dil seç': 'भाषा चुनें',
    'Ülke / borç bölgesi': 'देश / कर्ज़ क्षेत्र',
    'Kurulumu tamamla': 'सेटअप पूरा करें',
    'Profil kayıtları korunur': 'आपके रिकॉर्ड सुरक्षित रहते हैं',
    'Bildirim sistemi': 'सूचना प्रणाली',
    'Dakik bildirim izni': 'सटीक अलार्म की अनुमति',
    'Açık': 'चालू',
    'Kapalı': 'बंद',
    'Dakik teslim için izin gerekli': 'सटीक समय पर सूचना के लिए अनुमति चाहिए',
    'Bildirim planı bilgisi': 'सूचना समय-सारणी की जानकारी',
    'Otomatik senkronizasyon': 'स्वचालित सिंक',
    'Ödeme hatırlatmaları': 'भुगतान रिमाइंडर',
    'Vade kayıtları değiştirilmez': 'देय तारीख वाले रिकॉर्ड नहीं बदलते',
    'Günlük gider hatırlatmaları': 'दैनिक खर्च रिमाइंडर',
    'Anlık yerel kayıt': 'तुरंत स्थानीय रूप से सहेजना',
    'Doğrulanmış yedek kopya': 'सत्यापित बैकअप',
    'İlişkiler korunur': 'रिकॉर्ड के संबंध सुरक्षित रहते हैं',
    'Ana durumu ve Android izinlerini burada yönet. Hatırlatma saati ve mesajı ilgili kaydın ayrıntısındadır.':
        'मुख्य स्थिति और Android अनुमतियाँ यहाँ प्रबंधित करें। हर रिमाइंडर का समय और संदेश संबंधित रिकॉर्ड के विवरण में मिलता है।',
    'Etkin hatırlatmalar seçilen gün ve dakikada planlanır.':
        'चालू रिमाइंडर चुने गए दिन और मिनट के लिए निर्धारित किए जाते हैं।',
    'Hatırlatmalar durdurulur; kayıtlar ve ayarlar silinmez.':
        'रिमाइंडर रुक जाते हैं; रिकॉर्ड और सेटिंग्स नहीं हटते।',
    'Android bildirim izni kapalı. İzin açılmadan hiçbir MİZAN bildirimi oluşturulmaz.':
        'Android की सूचना अनुमति बंद है। अनुमति मिलने तक MİZAN कोई सूचना नहीं बनाएगा।',
    'Android dakik bildirim izni kapalı. MİZAN yaklaşık zamanlama kullanmaz; saat ve dakikada teslim için bu izin açılmalıdır.':
        'Android की सटीक अलार्म अनुमति बंद है। MİZAN अनुमानित समय का उपयोग करेगा; चुने गए घंटे और मिनट पर सटीक सूचना के लिए यह अनुमति चालू करें।',
    'Kayıt değişiklikleri üst üste bindirilmeden sırayla işlenir. Yalnız sıradaki gerekli bildirimler dakik biçimde yenilenir; gereksiz günlük kopyalar oluşturulmaz.':
        'रिकॉर्ड में बदलाव बिना टकराव के क्रम से संसाधित होते हैं। केवल अगली ज़रूरी सूचनाएँ दोबारा निर्धारित होती हैं; अनावश्यक दैनिक प्रतियाँ नहीं बनतीं।',
    'Her kart yalnız özet gösterir. Saat, mesaj ve açık/kapalı durumu karta dokununca düzenlenir.':
        'हर कार्ड केवल सारांश दिखाता है। कार्ड पर टैप करके समय, संदेश और चालू/बंद स्थिति संपादित करें।',
    'Bildirim planlaması yalnız hatırlatma oluşturur; ödeme, taksit, gider veya geçmiş kaydı üretmez.':
        'सूचना समय-सारणी केवल रिमाइंडर बनाती है; इससे भुगतान, किस्त, खर्च या इतिहास रिकॉर्ड नहीं बनते।',
    'Her gider hatırlatmasının saatini, mesajını ve açık/kapalı durumunu kendi ayrıntısından düzenle.':
        'हर खर्च रिमाइंडर का समय, संदेश और चालू/बंद स्थिति उसके विवरण से संपादित करें।',

    # Dashboard and income.
    'Kayıt doğrulaması başarısız oldu.': 'रिकॉर्ड का सत्यापन विफल रहा।',
    'Not ekle': 'नोट जोड़ें',
    'Notları daralt': 'नोट समेटें',
    'Yalnızca bu not silinecek. Devam edilsin mi?': 'केवल यही नोट हटेगा। जारी रखें?',
    'Bu Ayın Ödeme Durumu': 'इस महीने की भुगतान स्थिति',
    'Gecikmiş ödemeler': 'बकाया भुगतान',
    'Bugünkü normal gider': 'आज के सामान्य खर्च',
    'Bu ay normal gider': 'इस महीने के सामान्य खर्च',
    'Bugünkü ödemelere yapılan gider': 'आज किए गए भुगतान',
    'Bu ay ödemelere yapılan gider': 'इस महीने किए गए भुगतान',
    'Kritik ödemeler': 'ज़रूरी भुगतान',
    'Kritik ödeme yok': 'कोई ज़रूरी भुगतान नहीं',
    'Örnek ödeme veya borç oluşturulmadı. Kayıtlar bölümünden ilk kişiyi ekleyerek başlayabilirsin.':
        'कोई नमूना भुगतान या कर्ज़ नहीं बनाया गया। रिकॉर्ड में पहला व्यक्ति जोड़कर शुरुआत करें।',
    'Gelir kaydı opsiyoneldir. Borç ödemeleri ve giderler gelirden ayrı tutulur; net sonuç raporda hesaplanır.':
        'आय जोड़ना वैकल्पिक है। कर्ज़ के भुगतान और खर्च आय से अलग रखे जाते हैं; शुद्ध परिणाम रिपोर्ट में निकाला जाता है।',
    'Gelir yattı': 'आय मिल गई',
    'Son alınma işaretini geri al': 'आय मिलने का अंतिम निशान हटाएँ',
    'Arşivden çıkar': 'आर्काइव से वापस लाएँ',
    'Arşivle': 'आर्काइव करें',
    'Gelir sıklığı': 'आय मिलने की आवृत्ति',
    'Yatış gününü takip et': 'आय मिलने की तारीख ट्रैक करें',
    'Opsiyoneldir. Planlanan gün ile gerçek alınma tarihi ayrı tutulur.':
        'वैकल्पिक। तय तारीख और वास्तव में आय मिलने की तारीख अलग-अलग रखी जाती हैं।',
    'Haftanın hangi günü yatıyor?': 'आय सप्ताह के किस दिन मिलती है?',
    'Her ayın kaçında yatıyor?': 'आय हर महीने किस तारीख को मिलती है?',
    'Başlangıç': 'आरंभ',
    'Arşivde': 'आर्काइव में',
    'Kalan toplam borç detayı': 'कुल बाकी कर्ज़ का विवरण',
    'Ödeme Durumu': 'भुगतान स्थिति',
    'Açık planlanan ödemeler': 'बाकी निर्धारित भुगतान',
    'Açık plan kalmadı': 'कोई निर्धारित भुगतान बाकी नहीं',
    'Bu ay yapılan ödemeler': 'इस महीने किए गए भुगतान',
    'Yönet': 'प्रबंधित करें',
    'Ödeme ve gider sonrası net': 'भुगतान और खर्च के बाद शुद्ध राशि',
    'Bütün harcamalar': 'सभी खर्च',
    'Filtreleme ve arama': 'फ़िल्टर और खोज',
    'Tarih, gün adı, gider, kategori veya not yazabilirsiniz. Türkçe karakterler ve bitişik ifadeler eşleşir.':
        'तारीख, दिन, खर्च, श्रेणी या नोट से खोजें। उच्चारण चिह्न और जुड़े हुए शब्द भी मिलान किए जाते हैं।',
    'Araç, yoğurt, 23.07.2026, Perşembe…': 'कार, दही, 23/07/2026, गुरुवार…',
    'Günleri sırala': 'दिनों को क्रम में लगाएँ',
    'Kategori ekle': 'श्रेणी जोड़ें',
    'Market, ulaşım veya kullanıcıya özel başka bir kategori ekledikten sonra gider kaydı oluşturabilirsiniz.':
        'किराना, यात्रा या अपनी पसंद की कोई श्रेणी जोड़ने के बाद खर्च रिकॉर्ड बनाया जा सकता है।',
    'Eşleşen gider bulunamadı': 'मेल खाता कोई खर्च नहीं मिला',
    'Kategori silinirse yalnız o kategoriye bağlı giderler açık onayla silinir.':
        'श्रेणी हटाने पर स्पष्ट पुष्टि के बाद केवल उसी श्रेणी से जुड़े खर्च हटेंगे।',
    'ONAYLIYORUM yazın': '“मैं सहमत हूँ” लिखें',
    'Tam olarak ONAYLIYORUM yazılmalı.': 'ठीक-ठीक “मैं सहमत हूँ” लिखना ज़रूरी है।',
    'Adet / miktar': 'संख्या / मात्रा',
    'Banka / kredi': 'बैंक / क्रेडिट',
    'Daha fazla ödeme günü göster': 'और भुगतान वाले दिन दिखाएँ',
    'Bu günden daha fazla göster': 'इस दिन के और रिकॉर्ड दिखाएँ',
    'Gider işlemleri': 'खर्च से जुड़ी कार्रवाइयाँ',
    'Henüz kişi yok': 'अभी कोई व्यक्ति नहीं है',
    'İlk kişiyi ekle': 'पहला व्यक्ति जोड़ें',
    'Kişisel ve Kurumsal Borçlar': 'व्यक्तिगत और व्यावसायिक कर्ज़',
    'Kişisel / kurumsal borç ekle': 'व्यक्तिगत / व्यावसायिक कर्ज़ जोड़ें',
    'Banka dışı borç kaydı bulunmuyor.': 'बैंक के बाहर का कोई कर्ज़ रिकॉर्ड नहीं है।',
    'Kira ve Taksitler': 'किराया और किस्तें',

    # Record screens.
    'Tek dönem': 'एक बार',
    'Bu dönem': 'यह अवधि',
    'Ödenmemiş toplam': 'कुल बाकी',
    'Kişi seçin': 'व्यक्ति चुनें',
    'Kalan toplam': 'कुल बाकी',
    'Bu ay planlanan': 'इस महीने निर्धारित',
    'Gecikmiş kayıt': 'बकाया रिकॉर्ड',
    'Kişi detaylarını aç': 'व्यक्ति का विवरण खोलें',
    'Arşivdekileri göster': 'आर्काइव किए रिकॉर्ड दिखाएँ',
    'Gecikmiş kayıtlar': 'बकाया रिकॉर्ड',
    'Bu kişiye ait kayıtlar': 'इस व्यक्ति के रिकॉर्ड',
    'Kişiyi düzenle': 'व्यक्ति संपादित करें',
    'Kişiyi sil': 'व्यक्ति हटाएँ',
    'Banka Borçları': 'बैंक के कर्ज़',
    'Banka grubu ekle': 'बैंक समूह जोड़ें',
    'Banka borcu yok': 'बैंक का कोई कर्ज़ नहीं',
    'Banka grubu işlemleri': 'बैंक समूह की कार्रवाइयाँ',
    'Borç ekle': 'कर्ज़ जोड़ें',
    'Kayıt bilgileri': 'रिकॉर्ड की जानकारी',
    'Yalnızca bu kayda bağlı ödemeler': 'केवल इस रिकॉर्ड से जुड़े भुगतान',
    'Kalan borç': 'बाकी कर्ज़',
    'Ödenmeyen aylar': 'भुगतान न किए गए महीने',
    'Borç tarihi': 'कर्ज़ की तारीख',
    'Ödeme sıklığı': 'भुगतान की आवृत्ति',
    'Kayıtlı değişken tutarlar': 'सहेजी गई बदलती राशियाँ',
    'Abone no': 'ग्राहक संख्या',
    'Sözleşme / tesisat no': 'अनुबंध / कनेक्शन संख्या',
    'Bu dönem kalan': 'इस अवधि की बाकी राशि',
    'Tekrar sıklığı': 'दोहराने की आवृत्ति',
    'Sözleşme no': 'अनुबंध संख्या',
    'Kalan tutar': 'बाकी राशि',
    'İlk ödeme ayı': 'पहले भुगतान का महीना',
    'Sözleşme başlangıcı': 'अनुबंध शुरू होने की तारीख',
    'Sözleşme bitişi': 'अनुबंध समाप्त होने की तारीख',
    'Toplam taksit': 'कुल किस्तें',
    'Borç ürünü ekle': 'क्रेडिट उत्पाद जोड़ें',
    'Borç ürününü düzenle': 'क्रेडिट उत्पाद संपादित करें',
    'Ödeme tarihi yöntemi': 'देय तारीख तय करने का तरीका',
    'Her ayın kaçıncı günü?': 'हर महीने की कौन-सी तारीख?',
    'İlk geçerli vade': 'पहली मान्य देय तारीख',
    'Güncel manuel gecikme günü': 'मौजूदा मैनुअल देरी के दिन',
    'Yeni manuel gecikme günü (opsiyonel)': 'देरी के नए दिन (वैकल्पिक)',
    'Gecikme düzenlemesi açık': 'देरी समायोजन चालू',
    'Gecikme gününü değiştir': 'देरी के दिन बदलें',
    'Gecikme hesabını yeniden kur': 'देरी की गणना फिर से बनाएँ',
    'Gecikmiş aylar (opsiyonel)': 'भुगतान न किए गए महीने (वैकल्पिक)',
    'Gecikmiş ay ekle': 'भुगतान न किया गया महीना जोड़ें',
    'Seç': 'चुनें',
    'Faturayı düzenle': 'बिल संपादित करें',
    'Fatura türü': 'बिल का प्रकार',
    'Her ayın kaçında ödenecek? (1-31)': 'हर महीने किस तारीख को भुगतान होगा? (1–31)',
    'Girilen tutarın ait olduğu ay': 'दर्ज राशि का महीना',
    'Tesisat / sözleşme numarası': 'कनेक्शन / अनुबंध संख्या',
    'Kira / taksiti düzenle': 'किराया / किस्त संपादित करें',
    'Kira başlığı': 'किराए का शीर्षक',
    'Ürün / taksit başlığı': 'उत्पाद / किस्त का शीर्षक',
    'Her ay tekrarlayan ödeme': 'हर महीने दोहराया जाने वाला भुगतान',
    'Ev sahibi / alıcı': 'मकान मालिक / प्राप्तकर्ता',
    'Alıcı / satıcı adı': 'प्राप्तकर्ता / विक्रेता का नाम',
    'Sözleşme başlangıcı (opsiyonel)': 'अनुबंध शुरू होने की तारीख (वैकल्पिक)',
    'Sözleşme bitişi (opsiyonel)': 'अनुबंध समाप्त होने की तारीख (वैकल्पिक)',
    'Kalan taksit (opsiyonel)': 'बाकी किस्तें (वैकल्पिक)',
    'Kişisel / kurumsal borcu düzenle': 'व्यक्तिगत / व्यावसायिक कर्ज़ संपादित करें',
    'Alacaklı türü': 'लेनदार का प्रकार',
    'Borcun oluştuğu tarih': 'कर्ज़ बनने की तारीख',
    'Özel ödeme aralığı (gün)': 'अपनी पसंद का भुगतान अंतराल (दिन)',
    'Banka bilgisi (kullanıcı girişi)': 'बैंक की जानकारी (उपयोगकर्ता द्वारा दर्ज)',
    'Senet adedi': 'प्रॉमिसरी नोट की संख्या',
    'Mevcut senet': 'मौजूदा प्रॉमिसरी नोट',
    'Özel tür adı': 'अपनी पसंद के प्रकार का नाम',
    'Dönem tutarı': 'हर अवधि की राशि',
    'Özel tekrar aralığı (gün)': 'अपनी पसंद का दोहराव अंतराल (दिन)',
    'Sıradaki ödeme tarihi': 'अगली भुगतान तारीख',
    'Tarihi temizle': 'तारीख साफ़ करें',

    # Reports and PDF.
    'Ödemelere yapılan gider': 'किए गए भुगतान',
    'Normal giderler': 'सामान्य खर्च',
    'Kalan ödeme yükü': 'बाकी भुगतान दायित्व',
    'Gelir ayrıntıları': 'आय का विवरण',
    'Gerçekleşen harcamaların dağılımı': 'किए गए खर्चों का वितरण',
    'Gerçekleşen ödeme ayrıntıları': 'किए गए भुगतानों का विवरण',
    'Kalan ödeme yükünün dağılımı': 'बाकी भुगतान दायित्वों का वितरण',
    'Kalan ödeme ayrıntıları': 'बाकी भुगतान का विवरण',
    'Gider dağılımı': 'खर्च का वितरण',
    'Bütün harcama ayrıntıları': 'सभी खर्चों का विवरण',
    'Kişi kapsamı': 'शामिल लोग',
    'Tüm kişileri kapsa': 'सभी लोगों को शामिल करें',
    'Normal gider ayrıntıları': 'सामान्य खर्चों का विवरण',
    'Ödeme ayrıntıları': 'भुगतान का विवरण',
    'Kalan ödeme yükü ayrıntıları': 'बाकी भुगतान दायित्वों का विवरण',
    'Gecikmiş ödeme ayrıntıları': 'बकाया भुगतानों का विवरण',
    'Yaklaşan ödeme ayrıntıları': 'आगामी भुगतानों का विवरण',
    'Rapor kapsamı': 'रिपोर्ट का दायरा',
    'Tüm kayıt geçmişi': 'पूरा रिकॉर्ड इतिहास',
    'Kayıtlı ay bulunmuyor': 'कोई सहेजा गया महीना नहीं मिला',
    'Kayıtlı yıl bulunmuyor': 'कोई सहेजा गया वर्ष नहीं मिला',
    'Kalan kayıt durumu (opsiyonel)': 'बाकी रिकॉर्ड की स्थिति (वैकल्पिक)',
    'Kayıtlı yılı seç': 'सहेजा गया वर्ष चुनें',
    'Kayıtlı ayı seç': 'सहेजा गया महीना चुनें',
    'Gelir ve net durum': 'आय और शुद्ध स्थिति',
    'Seçili dönem gider özeti': 'चुनी गई अवधि के खर्चों का सारांश',
    'Gelir sonrası net': 'आय के बाद शुद्ध राशि',
    'Kişi bazında güncel kalan borç': 'व्यक्ति के अनुसार मौजूदा बाकी कर्ज़',
    'Tüm zamanlar': 'पूरी अवधि',
    'Kayıtlı kişi yok': 'कोई सहेजा गया व्यक्ति नहीं',
    'GÜN BAŞLIĞI': 'दिन का शीर्षक',
    'Ödemeler sonrası kalan gelir': 'भुगतान के बाद बाकी आय',
    'Toplam gider sonrası net': 'कुल खर्च के बाद शुद्ध राशि',
    'Gecikmiş ödeme yükü': 'बकाया भुगतान दायित्व',
    'Toplam güncel kalan borç': 'कुल मौजूदा बाकी कर्ज़',

    # Settings, backup and infrastructure.
    'özel bildirim saati': 'अपनी पसंद के सूचना समय',
    'Hatırlatmayı düzenle': 'रिमाइंडर संपादित करें',
    'Hatırlatma açık': 'रिमाइंडर चालू',
    'Dakik bildirim izni kapalı': 'सटीक अलार्म की अनुमति बंद है',
    'MİZAN yaklaşık zamanlama kullanmaz. Kaydettiğinde gerekli Android izin ekranı otomatik açılır; izin verildiğinde bildirimler uygulamaya dönüşte otomatik senkronize edilir.':
        'MİZAN अनुमानित समय का उपयोग करेगा। सहेजने पर Android की ज़रूरी अनुमति स्क्रीन अपने-आप खुलेगी; अनुमति मिलने के बाद ऐप पर लौटते ही सूचनाएँ अपने-आप सिंक होंगी।',
    '1 dakika sonra test bildirimi': '1 मिनट बाद परीक्षण सूचना',
    'Bu hatırlatmayı sil': 'यह रिमाइंडर हटाएँ',
    'Sessiz ses seçildiğinde titreşim de kullanılmaz.': '“बिना आवाज़” चुनने पर कंपन भी बंद रहेगा।',
    'Mevcut kayıtlar silinmeyecek veya yedekteki ortak verilerle yeniden yazılmayacak. Yalnız yeni kayıtlar ve eksik alt ilişkiler eklenecek.':
        'मौजूदा रिकॉर्ड न हटेंगे और न ही बैकअप के समान डेटा से दोबारा लिखे जाएँगे। केवल नए रिकॉर्ड और अधूरे संबंध जोड़े जाएँगे।',
    'Eksik ilişkisi tamamlanacak': 'अधूरे संबंध पूरे किए जाएँगे',
    'Ortak kullanıcı kaydı: Yok': 'समान उपयोगकर्ता रिकॉर्ड: कोई नहीं',
    'Ortak kullanıcı kaydı atlanacak': 'समान उपयोगकर्ता रिकॉर्ड छोड़े जाएँगे',
    'Kategori silmek için tam olarak ONAYLIYORUM yazılmalı.':
        'श्रेणी हटाने के लिए ठीक-ठीक “मैं सहमत हूँ” लिखना ज़रूरी है।',
    'CSV yedeği mevcut kayıtlarla birleştirildi: ': 'CSV बैकअप मौजूदा रिकॉर्ड से मिला दिया गया: ',
    'ONAYLIYORUM': 'मैं सहमत हूँ',
    'Banka borçları': 'बैंक के कर्ज़',
    'Kişisel ve kurumsal borçlar': 'व्यक्तिगत और व्यावसायिक कर्ज़',
    'Kira ve taksitler': 'किराया और किस्तें',
    'Daha fazla ödeme günü göster ': 'और भुगतान वाले दिन दिखाएँ ',
    'Bu günden daha fazla göster ': 'इस दिन के और रिकॉर्ड दिखाएँ ',
    'Günlük harcamalar': 'दैनिक खर्च',
    'Daha fazla gider günü göster ': 'और खर्च वाले दिन दिखाएँ ',
    'Yeniden eskiye': 'नए से पुराने',
    'Eskiden yeniye': 'पुराने से नए',
    'En yüksek harcama günü': 'सबसे अधिक खर्च वाला दिन',
    'En düşük harcama günü': 'सबसे कम खर्च वाला दिन',
    'Invalid argument(s): ': 'अमान्य मान: ',

    # Validation and user-facing errors.
    'Uygulama dili seçilmelidir.': 'ऐप की भाषा चुनना ज़रूरी है।',
    'Global katalog henüz yüklenmedi.': 'वैश्विक कैटलॉग अभी लोड नहीं हुआ है।',
    'Global katalog sayıları doğrulanamadı.': 'वैश्विक कैटलॉग की संख्या सत्यापित नहीं हो सकी।',
    'Yerel kayıt alanı güvenli biçimde açılamadı. Mevcut dosyaları korumak için yeni veri yazımı durduruldu.':
        'स्थानीय संग्रहण सुरक्षित रूप से नहीं खुल सका। मौजूदा फ़ाइलों को बचाने के लिए नया डेटा लिखना रोक दिया गया है।',
    'Limit': 'सीमा',
    'Alacaklı adı': 'लेनदार का नाम',
    'Abone numarası': 'ग्राहक संख्या',
    'Yatış günü takibi yalnız haftalık ve aylık gelirlerde kullanılabilir.':
        'आय मिलने की तारीख केवल साप्ताहिक और मासिक आय के लिए ट्रैक की जा सकती है।',
    'Bu gelir için yatış günü takibi açık değil.': 'इस आय के लिए मिलने की तारीख ट्रैक करना चालू नहीं है।',
    'Ödeme kalan borçtan büyük olamaz.': 'भुगतान बाकी कर्ज़ से अधिक नहीं हो सकता।',
    'Borç kaydı bulunamadı.': 'कर्ज़ का रिकॉर्ड नहीं मिला।',
    'Toplam borç, daha önce ödenen tutardan düşük olamaz.':
        'कुल कर्ज़ पहले से चुकाई गई राशि से कम नहीं हो सकता।',
    'Son ödeme tarihi borç tarihinden önce olamaz.':
        'अंतिम भुगतान तारीख कर्ज़ बनने की तारीख से पहले नहीं हो सकती।',
    'Taksitli borçta ödeme tutarı girilmelidir.': 'किस्त वाले कर्ज़ के लिए भुगतान राशि दर्ज करें।',
    'Bir borç kaydında ödeme toplamı borcu aşıyor.': 'कर्ज़ रिकॉर्ड के भुगतान कुल कर्ज़ से अधिक हैं।',
    'Bir kişisel borçta ödeme toplamı borcu aşıyor.':
        'व्यक्तिगत कर्ज़ के भुगतान कुल कर्ज़ से अधिक हैं।',
    'Kişisel/kurumsal borç bulunamadı.': 'व्यक्तिगत / व्यावसायिक कर्ज़ नहीं मिला।',
    'Banka borcu kaydı bulunamadı.': 'बैंक के कर्ज़ का रिकॉर्ड नहीं मिला।',
    'Bir gider kaydı bulunmayan kategoriye bağlı.':
        'एक खर्च ऐसे श्रेणी से जुड़ा है जो मौजूद नहीं है।',
    'Gider kategorisi bulunamadı.': 'खर्च की श्रेणी नहीं मिली।',
    'Gider kaydı bulunamadı.': 'खर्च का रिकॉर्ड नहीं मिला।',
    'Tutar boş bırakılamaz.': 'राशि दर्ज करना ज़रूरी है।',
    'Geçerli bir para tutarı girin.': 'मान्य राशि दर्ज करें।',
    'En fazla iki kuruş hanesi girilebilir.': 'दशमलव के बाद अधिकतम दो अंक दर्ज किए जा सकते हैं।',
    'Değer': 'मान',
    'Dakik bildirim izni kapalı. Saat ve dakika doğruluğu için izni açın.':
        'सटीक अलार्म की अनुमति बंद है। चुने गए घंटे और मिनट पर सूचना के लिए अनुमति चालू करें।',
    'Dakik bildirim izni verilmedi. Test yaklaşık zamanda çalıştırılmayacak.':
        'सटीक अलार्म की अनुमति नहीं मिली। परीक्षण अनुमानित समय पर नहीं चलाया जाएगा।',
    'Ana kayıt okunamadı; son sağlam yedek geri yüklendi.':
        'मुख्य डेटा फ़ाइल पढ़ी नहीं जा सकी; अंतिम सही बैकअप पुनर्स्थापित किया गया।',
    'Geçici kayıt doğrulanamadı.': 'अस्थायी रूप से सहेजा गया डेटा सत्यापित नहीं हो सका।',
    'Bu banka grubunda görüntülenecek borç bulunmuyor.': 'इस बैंक समूह में दिखाने के लिए कोई कर्ज़ रिकॉर्ड नहीं है।',
    'Dil, ülke veya varsayılan para birimi değiştiğinde mevcut kişi, borç, fatura, gider, gelir ve ödeme kayıtları değiştirilmez.':
        'भाषा, देश या डिफ़ॉल्ट मुद्रा बदलने से मौजूदा व्यक्ति, कर्ज़, बिल, खर्च, आय और भुगतान रिकॉर्ड नहीं बदलते।',
    'Kişiler, borçlar, faturalar, abonelikler, ödemeler, notlar, gelirler ve giderler her işlemden sonra cihazdaki dosyaya yazılır.':
        'हर कार्रवाई के बाद व्यक्ति, कर्ज़, बिल, सदस्यता, भुगतान, नोट, आय और खर्च डिवाइस की फ़ाइल में सहेजे जाते हैं।',
    'Kişi, banka, borç, ödeme, not, kategori, gider, gelir ve bildirim saatleri kendi kimlik ve bağlantılarıyla aktarılır. Aynı kayıt ikinci kez yazılmaz.':
        'व्यक्ति, बैंक, कर्ज़, भुगतान, नोट, श्रेणी, खर्च, आय और सूचना समय अपनी मूल आईडी और संबंधों के साथ स्थानांतरित होते हैं। एक ही रिकॉर्ड दूसरी बार नहीं लिखा जाता।',
    'Borç başlığı': 'कर्ज़ का शीर्षक',
    'Kişisel/kurumsal borç': 'व्यक्तिगत / व्यावसायिक कर्ज़',
    'Borç, ödeme ve giderlerin sade özeti. Detay görmek için kartlara dokunabilirsin.':
        'कर्ज़, भुगतान और खर्चों का साफ़ सारांश। विवरण देखने के लिए कार्ड पर टैप करें।',
    'Normal giderler ile banka, şahıs, fatura, abonelik, kira ve taksit ödemelerinin toplamıdır.':
        'यह सामान्य खर्चों और बैंक कर्ज़, व्यक्तिगत कर्ज़, बिल, सदस्यता, किराया तथा किस्त भुगतानों का कुल है।',
    'Toplam borcun tamamı değil, seçili döneme düşen sıradaki ödeme ve taksit tutarları gösterilir.':
        'यह पूरे कर्ज़ की शेष राशि नहीं, बल्कि चुनी गई अवधि में आने वाले अगले भुगतान और किस्तें दिखाता है।',
    'Bütün kişilerin ödeme ve borç kayıtları rapora alınır.':
        'सभी लोगों के भुगतान और कर्ज़ रिकॉर्ड रिपोर्ट में शामिल किए जाते हैं।',
    'Bütün harcamalar, normal giderler ile banka, şahıs, fatura, abonelik, kira ve taksit ödemelerinin toplamıdır.':
        'सभी खर्च सामान्य खर्चों और बैंक कर्ज़, व्यक्तिगत कर्ज़, बिल, सदस्यता, किराया तथा किस्त भुगतानों का कुल हैं।',
    'Normal giderler ile banka, şahıs, fatura, abonelik, kira ve taksit ödemelerine yapılan giderlerin toplamıdır. Gelir ayrı gösterilir.':
        'यह सामान्य खर्चों और बैंक कर्ज़, व्यक्तिगत कर्ज़, बिल, सदस्यता, किराया तथा किस्त भुगतानों का कुल है। आय अलग दिखाई जाती है।',
    'Toplam borcun tamamı değil, seçili döneme düşen sıradaki ödeme/taksit tutarları gösterilir.':
        'यह पूरे कर्ज़ की शेष राशि नहीं, बल्कि चुनी गई अवधि में आने वाली अगली भुगतान या किस्त राशि दिखाता है।',
    'Belirli aralıklarla tekrarlayan dijital hizmet, üyelik, sigorta, eğitim ve bakım ödemeleri':
        'तय अंतराल पर दोहराए जाने वाले डिजिटल सेवा, सदस्यता, बीमा, शिक्षा और रखरखाव भुगतान',
    'Ev/iş yeri kirası, ürün taksiti ve düzenli ödeme planları':
        'घर या कार्यस्थल का किराया, उत्पाद की किस्त और नियमित भुगतान योजनाएँ',
    'Ödenmeyen ayları seç. Gecikme, seçilen en eski ayın ödeme gününden bugüne otomatik hesaplanır.':
        'भुगतान न किए गए महीने चुनें। देरी सबसे पुराने चुने गए महीने की भुगतान तारीख से आज तक अपने-आप गिनी जाती है।',
    'Gecikmiş tutar, açık ve ödenmemiş dönemlerin toplamıdır.':
        'बकाया राशि खुली और भुगतान न की गई अवधियों का कुल है।',
    'Bu gelir dönemi daha önce alındı olarak işaretlenmiş.':
        'इस आय अवधि को पहले ही “मिल गई” के रूप में दर्ज किया जा चुका है।',
}

PHRASE_REPLACEMENTS: tuple[tuple[str, str], ...] = (
    ('रिकार्ड', 'रिकॉर्ड'),
    ('अधिसूचना', 'सूचना'),
    ('अनुस्मारक', 'रिमाइंडर'),
    ('किश्त', 'किस्त'),
    ('ऋृण', 'लोन'),
    ('व्यय', 'खर्च'),
    ('अतिदेय', 'बकाया'),
    ('नियत तिथि', 'देय तिथि'),
    ('स्वचालित तुल्यकालन', 'स्वचालित सिंक'),
    ('Payday ट्रैकिंग', 'आय मिलने की तारीख ट्रैक करना'),
    ('I CONFIRM', '“मैं सहमत हूँ”'),
    ('मैं CONFIRM', 'मैं सहमत हूँ'),
    ('सम्पर्क का नम्बर', 'अनुबंध संख्या'),
    ('उत्कृष्ट कर्तव्य', 'बाकी कर्ज़'),
    ('उत्कृष्ट रिकॉर्ड स्थिति', 'बाकी रिकॉर्ड की स्थिति'),
    ('आप LIMIT', 'सीमा'),
    ('अमान्य दलील', 'अमान्य मान'),
    ('सारा खर्चा', 'सभी खर्च'),
    ('पुरालेख', 'आर्काइव'),
    ('चुपचाप', 'बिना आवाज़'),
    ('वन टाइम', 'एक बार'),
    ('एक - बारगी', 'एकमुश्त'),
    ('स्पष्ट खोज', 'खोज साफ़ करें'),
    ('प्रबंधित करना', 'प्रबंधित करें'),
    ('कोई लोग', 'कोई व्यक्ति'),
    ('मिलान व्यय', 'मेल खाता खर्च'),
    ('वेतन-दिवस', 'आय मिलने की तारीख'),
    ('पूर्ण भुगतान', 'कुल भुगतान'),
    ('विच्छेदन', 'वितरण'),
    ('किनारा', 'बैंक'),
    ('बचत सत्यापित', 'सहेजा गया डेटा सत्यापित'),
)


def quote(value: str) -> str:
    return "'" + value.replace('\\', '\\\\').replace("'", "\\'").replace('\n', '\\n') + "'"


def normalize(value: str) -> str:
    for old, new in PHRASE_REPLACEMENTS:
        value = value.replace(old, new)
    value = value.replace('\u200b', '').replace('\u200c', '').replace('\u200d', '')
    value = unicodedata.normalize('NFC', value).strip()
    if value.endswith('.') and not value.endswith('...'):
        value = value[:-1] + '।'
    value = value.replace(' .', '।').replace(' ।', '।')
    return value


def main() -> None:
    if not PARTS:
        raise SystemExit('Hindi static parts not found')
    total = 0
    known_keys: set[str] = set()
    for path in PARTS:
        source = path.read_text(encoding='utf-8')
        marker = re.search(r'const Map<String, String> (mizanHindi\w+)', source)
        if marker is None:
            raise SystemExit(f'Hindi map marker missing: {path}')
        variable = marker.group(1)
        pairs = parse_map(source, marker.group(0))
        lines = [
            f'const Map<String, String> {variable} = <String, String>{{',
        ]
        for key, current in pairs:
            value = EXACT.get(key, HINDI_TERMINOLOGY.get(key, current))
            value = normalize(value)
            lines.append(f'  {quote(key)}: {quote(value)},')
            known_keys.add(key)
            total += 1
        lines.append('};')
        path.write_text('\n'.join(lines) + '\n', encoding='utf-8')
    unknown = sorted(set(EXACT) - known_keys)
    if unknown:
        raise SystemExit(f'Unknown Hindi override keys: {unknown}')
    if total != 791:
        raise SystemExit(f'Hindi key count changed: {total}')
    print(f'Hindi native copy finalized: {total}/791')


if __name__ == '__main__':
    main()

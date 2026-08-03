#!/usr/bin/env python3
from __future__ import annotations
import re
from pathlib import Path
from build_polish_locale import parse_map

def dart_quote(value: str) -> str:
    escaped = value.replace("\\", "\\\\").replace("'", "\\'").replace("$", "\\$").replace("\r", "\\r").replace("\n", "\\n").replace("\t", "\\t")
    return f"'{escaped}'"

ROOT = Path(__file__).resolve().parents[1]
PL_DIR = ROOT / 'lib' / 'l10n' / 'pl'
INDEX = ROOT / 'lib' / 'l10n' / 'mizan_pl.dart'

O = {
# core
'Sessiz':'Bez dźwięku','Haftalık':'Co tydzień','Aylık':'Co miesiąc','Elektrik':'Prąd','Özel fatura':'Inny rachunek',
'Özel oluştur':'Własne','Çek':'Czek','Esnaf / İşletme':'Przedsiębiorca / Firma','Aile / Yakın':'Rodzina / Bliska osoba','Diğer':'Inne',
'Üç aylık':'Co kwartał','Yıllık':'Co rok','Özel aralık':'Własny odstęp','Banka borcu':'Zadłużenie bankowe',
'Kişisel / kurumsal borç':'Zadłużenie prywatne / firmowe','Abonelik':'Subskrypcja','Kira / taksit':'Czynsz / rata',
'Profil kayıtları korunur':'Dane profilu są zachowywane','Bildirim izni':'Uprawnienie do powiadomień',
'Dakik bildirim izni':'Uprawnienie do dokładnych alarmów','Açık':'Włączone','Kapalı':'Wyłączone',
'Dakik teslim için izin gerekli':'Wymagane jest uprawnienie do dokładnych alarmów','Saat ekle':'Dodaj godzinę',
'Titreşim açık':'Wibracje włączone','Titreşim kapalı':'Wibracje wyłączone','Anlık yerel kayıt':'Natychmiastowy zapis lokalny',
'Doğrulanmış yedek kopya':'Zweryfikowana kopia zapasowa',
'Bu seçimler yalnız ilk kurulumda sorulur. Daha sonra Ayarlar bölümünden değiştirilebilir; mevcut kayıtlar silinmez.':'Te ustawienia są wybierane tylko przy pierwszej konfiguracji. Później można je zmienić w Ustawieniach bez usuwania istniejących wpisów.',
'Dil, ülke veya varsayılan para birimi değiştiğinde mevcut kişi, borç, fatura, gider, gelir ve ödeme kayıtları değiştirilmez.':'Zmiana języka, kraju lub waluty domyślnej nie modyfikuje istniejących osób ani wpisów zadłużenia, rachunków, wydatków, dochodów i płatności.',
'Ana durumu ve Android izinlerini burada yönet. Hatırlatma saati ve mesajı ilgili kaydın ayrıntısındadır.':'Tutaj można zarządzać stanem głównym i uprawnieniami Androida. Godzina oraz treść przypomnienia znajdują się w szczegółach odpowiedniego wpisu.',
'Etkin hatırlatmalar seçilen gün ve dakikada planlanır.':'Włączone przypomnienia są planowane na wybrany dzień, godzinę i minutę.',
'Android bildirim izni kapalı. İzin açılmadan hiçbir MİZAN bildirimi oluşturulmaz.':'Uprawnienie Androida do powiadomień jest wyłączone. Do czasu jego włączenia MİZAN nie utworzy żadnego powiadomienia.',
'Android dakik bildirim izni kapalı. MİZAN yaklaşık zamanlama kullanmaz; saat ve dakikada teslim için bu izin açılmalıdır.':'Uprawnienie Androida do dokładnych alarmów jest wyłączone. MİZAN nie stosuje przybliżonego planowania; aby powiadomienia pojawiały się o wybranej godzinie i minucie, należy włączyć to uprawnienie.',
'Kayıt değişiklikleri üst üste bindirilmeden sırayla işlenir. Yalnız sıradaki gerekli bildirimler dakik biçimde yenilenir; gereksiz günlük kopyalar oluşturulmaz.':'Zmiany wpisów są przetwarzane kolejno, bez nakładania się. Odświeżane są wyłącznie najbliższe wymagane powiadomienia z dokładnym czasem; zbędne codzienne kopie nie są tworzone.',
'Her kart yalnız özet gösterir. Saat, mesaj ve açık/kapalı durumu karta dokununca düzenlenir.':'Każda karta pokazuje tylko podsumowanie. Po dotknięciu karty można zmienić godzinę, wiadomość oraz stan włączenia.',
'Her gider hatırlatmasının saatini, mesajını ve açık/kapalı durumunu kendi ayrıntısından düzenle.':'Godzinę, wiadomość i stan każdego przypomnienia o wydatku można zmienić w jego szczegółach.',
# dashboard
'Not boş bırakılamaz.':'Notatka nie może być pusta.',
'Borç, ödeme ve giderlerin sade özeti. Detay görmek için kartlara dokunabilirsin.':'Przejrzyste podsumowanie zadłużenia, płatności i wydatków. Dotknięcie karty otwiera szczegóły.',
'Bugünkü ödemelere yapılan gider':'Dzisiejsze wydatki na płatności','Bu ay ödemelere yapılan gider':'Wydatki na płatności w tym miesiącu',
'Gecikmiş veya yedi gün içinde vadesi gelen kayıtlar. Ayrıntı için satıra dokun.':'Wpisy po terminie lub z terminem płatności w ciągu siedmiu dni. Dotknięcie wiersza otwiera szczegóły.',
'Gecikmiş veya önümüzdeki yedi gün içinde vadesi gelen kayıt bulunmuyor.':'Brak wpisów po terminie lub z terminem płatności w ciągu najbliższych siedmiu dni.',
'Örnek ödeme veya borç oluşturulmadı. Kayıtlar bölümünden ilk kişiyi ekleyerek başlayabilirsin.':'Nie utworzono przykładowych płatności ani zadłużeń. Aby rozpocząć, należy dodać pierwszą osobę w sekcji Rejestry.',
'Gelir kaydı opsiyoneldir. Borç ödemeleri ve giderler gelirden ayrı tutulur; net sonuç raporda hesaplanır.':'Wpis dochodu jest opcjonalny. Spłaty zadłużenia i wydatki są przechowywane oddzielnie od dochodu, a wynik netto jest obliczany w Raportach.',
'Tek seferlik, günlük, haftalık veya aylık gelir ekleyebilirsin.':'Można dodać dochód jednorazowy, dzienny, tygodniowy lub miesięczny.',
'Gelir yattı':'Oznacz jako otrzymany','Son alınma işaretini geri al':'Cofnij ostatnie oznaczenie otrzymania','Arşivle':'Przenieś do archiwum',
'Opsiyoneldir. Planlanan gün ile gerçek alınma tarihi ayrı tutulur.':'Opcjonalne. Planowany dzień i rzeczywista data otrzymania są przechowywane oddzielnie.',
'Ay daha kısaysa o ayın son geçerli günü kullanılır.':'Jeśli miesiąc jest krótszy, używany jest jego ostatni dzień.',
'Başlangıç':'Początek','Her bölümün toplamı ayrı hesaplanır. Satıra dokunarak yalnız ilgili kayıtları görebilirsin.':'Suma każdej sekcji jest obliczana oddzielnie. Dotknięcie wiersza pokazuje wyłącznie powiązane wpisy.',
'Açık planlanan kayıtlar ile bu ay gerçekten yapılan ödemeler ayrı gösterilir.':'Otwarte zaplanowane wpisy i płatności faktycznie wykonane w tym miesiącu są wyświetlane oddzielnie.',
'Açık planlanan ödemeler':'Otwarte zaplanowane płatności','Açık plan kalmadı':'Brak otwartych zaplanowanych płatności',
'Bu aya ait açık veya eksik ödeme bulunmuyor.':'Brak otwartych lub niepełnych płatności za ten miesiąc.',
'Yönet':'Zarządzaj','Ödemeler sonrası kalan':'Pozostało po płatnościach','Ödeme ve gider sonrası net':'Wynik netto po płatnościach i wydatkach',
'Tümü':'Wszystkie','Harcamalar gün gün gruplanır; arama ve günlük toplam sıralaması uzun yıllarda da kontrollü çalışır.':'Wydatki są grupowane według dni. Wyszukiwanie i sortowanie sum dziennych działają sprawnie także przy danych z wielu lat.',
'Tarih, gün adı, gider, kategori veya not yazabilirsiniz. Türkçe karakterler ve bitişik ifadeler eşleşir.':'Można wyszukiwać według daty, dnia tygodnia, wydatku, kategorii lub notatki. Obsługiwane są znaki diakrytyczne i wyrażenia pisane łącznie.',
'ONAYLIYORUM yazın':'Wpisz POTWIERDZAM','Tam olarak ONAYLIYORUM yazılmalı.':'Należy wpisać dokładnie POTWIERDZAM.',
'Adet / miktar':'Liczba / ilość','Kişisel / kurumsal':'Prywatne / firmowe','Gider işlemleri':'Operacje na wydatkach',
'Henüz kişi yok':'Nie dodano jeszcze żadnej osoby','Kişisel ve Kurumsal Borçlar':'Zadłużenia prywatne i firmowe',
'Kişi, şirket/kurum, çek, senet, esnaf/işletme, aile/yakın ve diğer alacaklılar':'Osoby, firmy i instytucje, czeki, weksle, przedsiębiorcy, rodzina, bliskie osoby oraz inni wierzyciele',
'Kişisel / kurumsal borç ekle':'Dodaj zadłużenie prywatne / firmowe','Fatura kaydı bulunmuyor.':'Brak wpisów rachunków.',
'Belirli aralıklarla tekrarlayan dijital hizmet, üyelik, sigorta, eğitim ve bakım ödemeleri':'Cykliczne opłaty za usługi cyfrowe, członkostwa, ubezpieczenia, edukację oraz konserwację i serwis',
'Kira ve Taksitler':'Czynsze i raty','Ev/iş yeri kirası, ürün taksiti ve düzenli ödeme planları':'Czynsz za mieszkanie lub lokal, raty za produkty i regularne plany płatności',
# records
'Kişi detaylarını aç':'Otwórz szczegóły osoby','Banka Borçları':'Zadłużenia bankowe','Banka grubu ekle':'Dodaj grupę bankową',
'Banka borcu yok':'Brak zadłużenia bankowego','Banka grubu işlemleri':'Operacje na grupie bankowej','Banka grubunu sil':'Usuń grupę bankową',
'Grubu düzenle':'Edytuj grupę','Kayıt bilgileri':'Szczegóły wpisu','Kalan borç':'Pozostałe zadłużenie','Gecikme':'Po terminie',
'Çek no':'Nr czeku','Kalan fatura':'Pozostała kwota rachunku','Bu dönem kalan':'Pozostało w tym okresie',
'Tekrar sıklığı':'Częstotliwość powtarzania','Sözleşme no':'Nr umowy','Sözleşme başlangıcı':'Początek umowy','Sözleşme bitişi':'Koniec umowy',
'Toplam taksit':'Łączna liczba rat','Kalan taksit sayısı, kayıtlı taksit ödemeleriyle uyumlu değil.':'Liczba pozostałych rat jest niezgodna z zapisanymi płatnościami ratalnymi.',
'Borç ürünü ekle':'Dodaj produkt zadłużeniowy','Borç ürününü düzenle':'Edytuj produkt zadłużeniowy','Ödeme tarihi yöntemi':'Sposób wyznaczania terminu płatności',
'İlk geçerli vade':'Pierwszy prawidłowy termin','Güncel manuel gecikme günü':'Aktualna ręczna liczba dni po terminie','Yeni manuel gecikme günü (opsiyonel)':'Nowa ręczna liczba dni po terminie (opcjonalnie)',
'Takvimle otomatik artar. Diğer alanları kaydetmek bu gecikme referansını değiştirmez.':'Wartość zwiększa się automatycznie wraz z upływem dni. Zapisanie innych pól nie zmienia daty odniesienia opóźnienia.',
'Değer değiştirilirse referans tarihi bugün esas alınarak gecikme, bildirim ve rapor hesapları yeniden kurulur.':'Po zmianie wartości obliczenia opóźnień, powiadomień i raportów są tworzone ponownie z dzisiejszą datą jako punktem odniesienia.',
'Gecikme düzenlemesi açık':'Ręczna korekta opóźnienia włączona','Gecikme gününü değiştir':'Zmień liczbę dni po terminie','Gecikme hesabını yeniden kur':'Przelicz opóźnienie',
'Seç':'Wybierz','Kira başlığı':'Tytuł czynszu','Ev sahibi / alıcı':'Wynajmujący / odbiorca','Toplam taksit (opsiyonel)':'Łączna liczba rat (opcjonalnie)',
'Kalan taksit (opsiyonel)':'Liczba pozostałych rat (opcjonalnie)','Kişisel / kurumsal borcu düzenle':'Edytuj zadłużenie prywatne / firmowe',
'Toplam taksiti girin.':'Wprowadź łączną liczbę rat.','Ödeme kaydı eklendikçe kalan taksit sayısı otomatik azalır.':'Liczba pozostałych rat zmniejsza się automatycznie po zapisaniu każdej płatności.',
'Özel tür adı':'Nazwa własnego typu','Özel tekrar aralığı (gün)':'Własny odstęp powtarzania (dni)',
'Kalan borcu aşmayacak ödeme tutarını kendin girebilirsin.':'Można wprowadzić kwotę płatności, która nie przekracza pozostałego zadłużenia.',
'Otomatik tutar ödeme türüne göre hesaplandı. Kısmi ödeme seçilirse elle değiştirilebilir.':'Kwota została obliczona automatycznie według rodzaju płatności. Po wybraniu płatności częściowej można ją zmienić ręcznie.',
'Ödeme notu (opsiyonel)':'Notatka do płatności (opcjonalnie)',
# reports
'Kalan ödeme yükü':'Pozostałe zobowiązania płatnicze','Gecikmiş':'Po terminie','Kalan ödeme yükünün dağılımı':'Podział pozostałych zobowiązań płatniczych',
'Kalan ödeme ayrıntıları':'Szczegóły pozostałych płatności','Kalan ödeme yükü ayrıntıları':'Szczegóły pozostałych zobowiązań płatniczych',
'Kişi kapsamı':'Zakres osób','Tüm kişileri kapsa':'Uwzględnij wszystkie osoby','Tüm kişiler':'Wszystkie osoby','Tüm kayıt geçmişi':'Pełna historia wpisów',
'Kalan kayıt durumu (opsiyonel)':'Stan otwartych wpisów (opcjonalnie)','Gelir ve net durum':'Dochód i wynik netto',
'Gelirden gerçekleşen ödemeler ve giderler sırayla düşülür.':'Zarejestrowane płatności i wydatki są kolejno odejmowane od dochodu.',
'Aynı raporu kaydedebilir veya WhatsApp dahil paylaşım menüsüne gönderebilirsin.':'Ten sam raport można zapisać lub wysłać do menu udostępniania, również przez WhatsApp.',
'Kayıtlı kişi yok':'Brak zapisanych osób','GÜN BAŞLIĞI':'NAGŁÓWEK DNIA','Tüm zamanlar':'Cały okres',
'Gelir sonrası net':'Wynik netto po uwzględnieniu dochodu','Gecikmiş ödeme yükü':'Zobowiązania płatnicze po terminie',
'Yaklaşan ödeme yükü':'Nadchodzące zobowiązania płatnicze','Toplam güncel kalan borç':'Łączne aktualne zadłużenie',
# settings
'Sessiz ses seçildiğinde titreşim de kullanılmaz.':'Po wybraniu opcji Bez dźwięku wyłączane są również wibracje.',
'Bugünkü giderlerini işlemeyi unutma.':'Należy pamiętać o zapisaniu dzisiejszych wydatków.',
'Öğlene kadar yaptığın harcamaları ekleyebilirsin.':'Można dodać wydatki poniesione do południa.',
'Günü kapatmadan giderlerini kontrol et.':'Przed zakończeniem dnia warto sprawdzić wydatki.',
'Kategori silmek için tam olarak ONAYLIYORUM yazılmalı.':'Aby usunąć kategorię, należy wpisać dokładnie POTWIERDZAM.',
'Kişisel/kurumsal borç':'Zadłużenie prywatne / firmowe','Kira':'Czynsz','Eski kayıttan aktarıldı':'Zaimportowano ze starszego wpisu',
'Kalan toplam borç':'Łączne pozostałe zadłużenie','Gecikmiş toplam':'Łączna kwota po terminie','Ödeme':'Płatność',
'Kişisel ve kurumsal borçlar':'Zadłużenia prywatne i firmowe','Kira ve taksitler':'Czynsze i raty','Kişi kaydı bulunmuyor.':'Brak wpisów osób.',
'Eskiden yeniye':'Najpierw najstarsze',
# validation
'Her değişiklik cihazda anında kaydedilir; sağlam kayıt doğrulanmadan üzerine yazılmaz.':'Każda zmiana jest natychmiast zapisywana na urządzeniu; prawidłowe dane nie są nadpisywane, dopóki nowy zapis nie zostanie zweryfikowany.',
'Yeni kayıt doğrulandıktan sonra ana dosya değiştirilir; son sağlam kopya ayrıca korunur.':'Plik główny jest zastępowany dopiero po zweryfikowaniu nowego zapisu; ostatnia prawidłowa kopia jest przechowywana oddzielnie.',
'Kişi, banka, borç, ödeme, not, kategori, gider, gelir ve bildirim saatleri kendi kimlik ve bağlantılarıyla aktarılır. Aynı kayıt ikinci kez yazılmaz.':'Osoby, banki, zadłużenia, płatności, notatki, kategorie, wydatki, dochody i godziny powiadomień są przenoszone z zachowaniem identyfikatorów i relacji. Ten sam wpis nie jest zapisywany ponownie.',
'Global katalog sayıları doğrulanamadı.':'Nie udało się zweryfikować liczby pozycji w katalogach globalnych.',
'Bildirim izni veya zamanlama servisi açılamadı:':'Nie udało się otworzyć ustawień uprawnień do powiadomień lub usługi planowania:',
'Yerel kayıt alanı güvenli biçimde açılamadı. Mevcut dosyaları korumak için yeni veri yazımı durduruldu.':'Nie udało się bezpiecznie otworzyć lokalnego magazynu danych. Zapisywanie nowych danych zostało wstrzymane w celu ochrony istniejących plików.',
'Toplam borç':'Łączne zadłużenie','Gecikme günü':'Liczba dni po terminie','Çek numarası':'Numer czeku','Hatırlatma adı':'Nazwa przypomnienia','Bildirim mesajı':'Treść powiadomienia',
'En fazla 10 ödeme bildirimi eklenebilir.':'Można dodać maksymalnie 10 godzin powiadomień o płatnościach.',
'En az bir ödeme bildirim saati bulunmalıdır.':'Należy ustawić co najmniej jedną godzinę powiadomienia o płatności.',
'Gelir kaydı bulunamadı.':'Nie znaleziono wpisu dochodu.','Borç kaydı bulunamadı.':'Nie znaleziono wpisu zadłużenia.',
'Kullanılan limit toplam limiti aşamaz.':'Wykorzystana część limitu nie może przekraczać limitu całkowitego.',
'Son ödeme tarihi borç tarihinden önce olamaz.':'Termin płatności nie może być wcześniejszy niż data powstania zadłużenia.',
'Banka kaydı bulunamadı.':'Nie znaleziono wpisu banku.','Kişisel/kurumsal borç bulunamadı.':'Nie znaleziono zadłużenia prywatnego / firmowego.',
'Banka borcu kaydı bulunamadı.':'Nie znaleziono wpisu zadłużenia bankowego.','Taksit ilerlemesi negatif olamaz.':'Liczba spłaconych rat nie może być ujemna.',
'Taksit ilerlemesi toplam taksiti aşamaz.':'Liczba spłaconych rat nie może przekraczać łącznej liczby rat.',
'Geçerli bir para tutarı girin.':'Należy wprowadzić prawidłową kwotę.','En fazla iki kuruş hanesi girilebilir.':'Można wprowadzić najwyżej dwa miejsca po przecinku.',
'Lefferion Prime - MİZAN hata yapabilir. Lütfen vade, gecikme ve ödeme bilgilerini son kez kontrol edin.':'Lefferion Prime - MİZAN może popełniać błędy. Przed kontynuowaniem należy sprawdzić terminy płatności, stan opóźnień i informacje o płatnościach.',
'Son ödeme bugün':'Termin płatności dzisiaj','Mart':'Marzec','Mayıs':'Maj','Oca':'sty','Şub':'lut','Mar':'mar','Nis':'kwi','May':'maj','Haz':'cze','Tem':'lip','Ağu':'sie','Eyl':'wrz','Eki':'paź','Kas':'lis','Ara':'gru',
'Tüm kayıt türlerinin son ödeme bildirimleri':'Powiadomienia o terminach płatności dla wszystkich typów wpisów',
'Android dışında gerçek zamanlama yapılmaz.':'Rzeczywiste planowanie powiadomień jest dostępne wyłącznie w Androidzie.',
'Dakik bildirim izni kapalı. Saat ve dakika doğruluğu için izni açın.':'Uprawnienie do dokładnych alarmów jest wyłączone. Aby zachować wybraną godzinę i minutę, należy je włączyć.',
'Dakik bildirim izni verilmedi.':'Nie udzielono uprawnienia do dokładnych alarmów.',
'Dakik bildirim izni kapalı. Android mevcut dakik planları iptal eder; izin açıldığında plan yeniden kurulmalıdır.':'Uprawnienie do dokładnych alarmów jest wyłączone. Android anuluje istniejące dokładne harmonogramy; po udzieleniu uprawnienia należy utworzyć je ponownie.',
'Bildirim izni kapalı. Önce bildirim iznini açın.':'Uprawnienie do powiadomień jest wyłączone. Najpierw należy je włączyć.',
'Dakik bildirim izni verilmedi. Test yaklaşık zamanda çalıştırılmayacak.':'Nie udzielono uprawnienia do dokładnych alarmów. Test nie zostanie uruchomiony z przybliżonym czasem.',
'Bu test, ayarlanan dakik bildirim sistemiyle oluşturuldu.':'Test został utworzony przy użyciu skonfigurowanego systemu dokładnych powiadomień.',
}

# Whole-sentence refinements that are naturally impersonal/formal.
REPL = {
'Możesz ': 'Można ',
'Twoich ': '',
'Twoje ': '',
'Kliknij ': 'Dotknięcie elementu pozwala ',
}

def write_map(path: Path, map_name: str, pairs: list[tuple[str,str]]) -> None:
    lines=[f'const Map<String, String> {map_name} = <String, String>{{']
    for k,v in pairs:
        v=O.get(k,v)
        lines.append(f'  {dart_quote(k)}: {dart_quote(v)},')
    lines.append('};')
    path.write_text('\n'.join(lines)+'\n',encoding='utf-8')

for path in sorted(PL_DIR.glob('mizan_pl_*.dart')):
    src=path.read_text(encoding='utf-8')
    m=re.search(r'const Map<String, String> (mizanPolish\w+)',src)
    if not m: raise SystemExit(f'map missing {path}')
    write_map(path,m.group(1),parse_map(src,m.group(0)))

index=INDEX.read_text(encoding='utf-8')
index=re.sub(r'// POLISH LOCALIZATION CANDIDATE.*\n','',index)
index=index.replace('// User-authored content is never translated.\n','// Reviewed Polish product copy. User-authored content is never translated.\n')
INDEX.write_text(index,encoding='utf-8')
print(f'Applied {len(O)} reviewed Polish overrides.')

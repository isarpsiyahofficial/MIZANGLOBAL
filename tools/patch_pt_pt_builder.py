#!/usr/bin/env python3
"""Apply deterministic CLDR gaps and reviewed pt-PT product-copy corrections."""
from pathlib import Path

path = Path(__file__).with_name('build_pt_pt_locale.py')
source = path.read_text(encoding='utf-8')
changed = False

currency_marker = '        "XCG": "florim caribenho",\n'
if currency_marker not in source:
    needle = '        "STN": "dobra de São Tomé e Príncipe",\n'
    if source.count(needle) != 1:
        raise SystemExit('Could not locate pt-PT currency override insertion point')
    replacement = needle + (
        '        "XAF": "franco CFA da África Central",\n'
        '        "XCD": "dólar das Caraíbas Orientais",\n'
        '        "XCG": "florim caribenho",\n'
        '        "XOF": "franco CFA da África Ocidental",\n'
        '        "XPF": "franco CFP",\n'
        '        "ZWG": "ouro do Zimbabué",\n'
    )
    source = source.replace(needle, replacement, 1)
    changed = True

reviewed_overrides = {
    'Uygulama boş ve kullanıma hazır': 'A aplicação está vazia e pronta a utilizar',
    'MİZAN kullanıma hazır. İlk kişi veya kaydı ekleyebilirsin.': 'O MİZAN está pronto a utilizar. Pode adicionar a primeira pessoa ou o primeiro registo.',
    'Örnek ödeme veya borç oluşturulmadı. Kayıtlar bölümünden ilk kişiyi ekleyerek başlayabilirsin.': 'Não foram criados pagamentos nem dívidas de exemplo. Comece por adicionar a primeira pessoa na secção Registos.',
    'Bu seçimler yalnız ilk kurulumda sorulur. Daha sonra Ayarlar bölümünden değiştirilebilir; mevcut kayıtlar silinmez.': 'Estas opções são pedidas apenas na configuração inicial. Podem ser alteradas mais tarde em Definições, sem eliminar os registos existentes.',
    'Bu seçimleri değiştirmek kayıtları, ödemeleri veya geçmişi silmez.': 'Alterar estas opções não elimina registos, pagamentos nem o histórico.',
    'Dil, ülke veya varsayılan para birimi değiştiğinde mevcut kişi, borç, fatura, gider, gelir ve ödeme kayıtları değiştirilmez.': 'Alterar o idioma, o país ou a moeda predefinida não modifica os registos existentes de pessoas, dívidas, faturas, despesas, rendimentos ou pagamentos.',
    'MİZAN yaklaşık zamanlama kullanmaz. Kaydettiğinde gerekli Android izin ekranı otomatik açılır; izin verildiğinde bildirimler uygulamaya dönüşte otomatik senkronize edilir.': 'O MİZAN não utiliza horários aproximados. Ao guardar, o ecrã de permissão necessário do Android é aberto automaticamente; depois de conceder a permissão, as notificações são sincronizadas ao regressar à aplicação.',
    'Yeni kayıt doğrulandıktan sonra ana dosya değiştirilir; son sağlam kopya ayrıca korunur.': 'O ficheiro principal só é substituído depois de os novos dados serem validados; a última cópia válida também é preservada.',
    'Her değişiklik cihazda anında kaydedilir; sağlam kayıt doğrulanmadan üzerine yazılmaz.': 'Cada alteração é guardada imediatamente no dispositivo; os dados válidos não são substituídos antes de o novo registo ser validado.',
    'Yedek içe aktarılırken mevcut kayıtlar silinmez. Ortak kayıtlar atlanır, yalnız yeni kayıtlar ve eksik ilişkiler eklenir.': 'Ao importar uma cópia de segurança, os registos existentes não são eliminados. Os registos coincidentes são ignorados; apenas são adicionados novos registos e relações em falta.',
    'Mevcut kayıtlar silinmeyecek veya yedekteki ortak verilerle yeniden yazılmayacak. Yalnız yeni kayıtlar ve eksik alt ilişkiler eklenecek.': 'Os registos existentes não serão eliminados nem substituídos por dados coincidentes da cópia de segurança. Apenas serão adicionados novos registos e relações secundárias em falta.',
    'Bugünkü giderlerini işlemeyi unutma.': 'Não se esqueça de registar as despesas de hoje.',
    'Öğlene kadar yaptığın harcamaları ekleyebilirsin.': 'Pode adicionar as despesas efetuadas até ao meio-dia.',
    'Günü kapatmadan giderlerini kontrol et.': 'Verifique as despesas antes de terminar o dia.',
    'Günün ödeme planını gözden geçir.': 'Reveja o plano de pagamentos de hoje.',
    'Aynı raporu kaydedebilir veya WhatsApp dahil paylaşım menüsüne gönderebilirsin.': 'Pode guardar o mesmo relatório ou enviá-lo através do menu de partilha, incluindo o WhatsApp.',
    'Harcamalar gün gün gruplanır; arama ve günlük toplam sıralaması uzun yıllarda da kontrollü çalışır.': 'As despesas são agrupadas por dia; a pesquisa e a ordenação pelos totais diários mantêm-se eficientes mesmo em períodos de vários anos.',
    'Tarih, gün adı, gider, kategori veya not yazabilirsiniz. Türkçe karakterler ve bitişik ifadeler eşleşir.': 'Pode pesquisar por data, dia da semana, despesa, categoria ou nota. Os caracteres acentuados e os termos escritos sem espaços também são reconhecidos.',
    'Önce kişiyi seç, ardından kayıt türünü aç. Her bölüm birbirinden bağımsız tutulur.': 'Selecione primeiro a pessoa e depois abra o tipo de registo. Cada secção é mantida de forma independente.',
    'Kayıtların birbirine karışmaması için önce ödeme ve gider kayıtlarının sahibi olacak kişiyi ekleyin.': 'Para manter os registos separados, adicione primeiro a pessoa a quem pertencem os pagamentos e as despesas.',
    'Banka adı kullanıcı tarafından yazılır. Hazır banka markası veya logosu kullanılmaz.': 'O nome do banco é introduzido pelo utilizador. Não são utilizadas marcas nem logótipos bancários predefinidos.',
    'Hazır marka listesi yoktur; adı kullanıcı belirler.': 'Não existe uma lista de marcas predefinida; o nome é indicado pelo utilizador.',
    '15 veya 20 gibi yalnız gün numarasını yazın; MİZAN takvimi kendisi takip eder.': 'Introduza apenas o número do dia, como 15 ou 20; o MİZAN acompanha automaticamente o calendário.',
}

insert_at = source.index('\n}\n\nREPLACEMENTS:')
for key, value in reviewed_overrides.items():
    literal = f'    {key!r}: {value!r},\n'
    # Builder uses JSON-style double-quoted Dart-source metadata; use Python repr
    # only as a detection shortcut and insert escaped JSON strings below.
    json_line = '    ' + __import__('json').dumps(key, ensure_ascii=False) + ': ' + __import__('json').dumps(value, ensure_ascii=False) + ',\n'
    if json_line not in source:
        source = source[:insert_at] + json_line + source[insert_at:]
        insert_at += len(json_line)
        changed = True

if changed:
    path.write_text(source, encoding='utf-8')
    print('Applied fixed CLDR names and reviewed pt-PT product-copy corrections.')
else:
    print('pt-PT builder corrections are already current.')

#!/usr/bin/env python3
"""Harden the deterministic European Portuguese locale builder.

This patch deliberately replaces the original substring conversion with
word-boundary rules, grammatical repairs and reviewed finance/UI overrides.
It is idempotent and runs before every pt-PT product build.
"""
from __future__ import annotations

import json
from pathlib import Path

path = Path(__file__).with_name("build_pt_pt_locale.py")
source = path.read_text(encoding="utf-8")
changed = False

# CLDR currently omits a few newly introduced or special currencies.
currency_marker = '        "XCG": "florim caribenho",\n'
if currency_marker not in source:
    needle = '        "STN": "dobra de São Tomé e Príncipe",\n'
    if source.count(needle) != 1:
        raise SystemExit("Could not locate pt-PT currency override insertion point")
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

# Semantic decisions that must not be inferred by a blind regional word swap.
reviewed_overrides = {
    "Fatura": "Fatura",
    "Kişisel / kurumsal borç": "Dívida pessoal / empresarial",
    "Varsayılan para birimi": "Moeda predefinida",
    "Borç kapama": "Liquidar dívida",
    "Yalnızca tamamen entegre edilmiş bir dil seçilebilir.": "Só é possível selecionar um idioma totalmente integrado.",
    "Dakik teslim için izin gerekli": "É necessária permissão para entrega à hora exata",
    "Anlık yerel kayıt": "Gravação local imediata",
    "Doğrulanmış yedek kopya": "Cópia de segurança verificada",
    "İlişkiler korunur": "As ligações são preservadas",
    "Ana durumu ve Android izinlerini burada yönet. Hatırlatma saati ve mesajı ilgili kaydın ayrıntısındadır.": "Gira aqui o estado principal e as permissões do Android. A hora e a mensagem de cada lembrete encontram-se nos detalhes do respetivo registo.",
    "Etkin hatırlatmalar seçilen gün ve dakikada planlanır.": "Os lembretes ativos são programados para o dia, a hora e o minuto selecionados.",
    "Hatırlatmalar durdurulur; kayıtlar ve ayarlar silinmez.": "Os lembretes são interrompidos; os registos e as definições não são eliminados.",
    "Android bildirim izni kapalı. İzin açılmadan hiçbir MİZAN bildirimi oluşturulmaz.": "A permissão de notificações do Android está desativada. O MİZAN não criará notificações enquanto a permissão não for concedida.",
    "Android dakik bildirim izni kapalı. MİZAN yaklaşık zamanlama kullanmaz; saat ve dakikada teslim için bu izin açılmalıdır.": "A permissão do Android para alarmes exatos está desativada. O MİZAN não utiliza horários aproximados; ative esta permissão para receber a notificação à hora e ao minuto selecionados.",
    "Kayıt değişiklikleri üst üste bindirilmeden sırayla işlenir. Yalnız sıradaki gerekli bildirimler dakik biçimde yenilenir; gereksiz günlük kopyalar oluşturulmaz.": "As alterações aos registos são processadas sequencialmente, sem sobreposição. Apenas as próximas notificações necessárias são atualizadas com precisão; não são criadas cópias diárias desnecessárias.",
    "Her kart yalnız özet gösterir. Saat, mesaj ve açık/kapalı durumu karta dokununca düzenlenir.": "Cada cartão apresenta apenas um resumo. Toque no cartão para editar a hora, a mensagem e o estado ativo/inativo.",
    "Bildirim planlaması yalnız hatırlatma oluşturur; ödeme, taksit, gider veya geçmiş kaydı üretmez.": "A programação de notificações cria apenas lembretes; não cria registos de pagamentos, prestações, despesas ou histórico.",
    "Her gider hatırlatmasının saatini, mesajını ve açık/kapalı durumunu kendi ayrıntısından düzenle.": "Edite a hora, a mensagem e o estado ativo/inativo de cada lembrete de despesa nos respetivos detalhes.",
    "Kişi, banka, borç, ödeme, not, kategori, gider, gelir ve bildirim saatleri kendi kimlik ve bağlantılarıyla aktarılır. Aynı kayıt ikinci kez yazılmaz.": "Pessoas, bancos, dívidas, pagamentos, notas, categorias, despesas, rendimentos e horas de notificação são transferidos com os respetivos identificadores e ligações. O mesmo registo não é gravado duas vezes.",
    "Uygulama dili seçilmelidir.": "É necessário selecionar o idioma da aplicação.",
    "Tamamlanmış profilde uygulama dili eksik.": "O perfil concluído não contém um idioma da aplicação.",
    "Global katalog sayıları doğrulanamadı.": "Não foi possível validar as contagens do catálogo global.",
    "Bildirim izni veya zamanlama servisi açılamadı:": "Não foi possível abrir a permissão de notificações ou o serviço de programação:",
    "Bildirim izni kapalı. Android izni açıldığında MİZAN otomatik olarak yeniden senkronize eder.": "A permissão de notificações está desativada. O MİZAN volta a sincronizar automaticamente quando a permissão do Android for ativada.",
    "Dakik bildirim izni kapalı. Android izni açıldığında MİZAN otomatik olarak yeniden senkronize eder.": "A permissão para alarmes exatos está desativada. O MİZAN volta a sincronizar automaticamente quando a permissão do Android for ativada.",
    "Ödeme kalan kira/taksit tutarından büyük olamaz.": "O pagamento não pode ser superior ao valor restante da renda/prestação.",
    "Kira/taksit tutarı, daha önce ödenen tutardan düşük olamaz.": "O valor da renda/prestação não pode ser inferior ao montante já pago.",
    "Taksitli borçta ödeme tutarı girilmelidir.": "Numa dívida em prestações, deve introduzir o valor do pagamento.",
    "Ürün taksitinde toplam taksit sayısı gereklidir.": "O número total de prestações é obrigatório numa compra a prestações.",
    "Dönemsel fatura tutarı sıfırdan büyük olmalıdır.": "O valor do período de faturação deve ser superior a zero.",
    "Yedek kayıt doğrulanamadı.": "Não foi possível validar a cópia de segurança.",
    "Ana kayıt okunamadı; son sağlam yedek geri yüklendi.": "Não foi possível ler o ficheiro principal; foi restaurada a última cópia de segurança válida.",
    "Ana ve yedek kayıt dosyaları okunamadı. Dosyalar korunuyor.": "Não foi possível ler o ficheiro principal nem o ficheiro da cópia de segurança. Os ficheiros foram preservados.",
    "Geçici kayıt doğrulanamadı.": "Não foi possível validar a gravação temporária.",
    "Borç, ödeme ve giderlerin sade özeti. Detay görmek için kartlara dokunabilirsin.": "Um resumo simples das suas dívidas, pagamentos e despesas. Toque nos cartões para ver os detalhes.",
    "Kişi, şirket/kurum, çek, senet, esnaf/işletme, aile/yakın ve diğer alacaklılar": "Pessoas, empresas/instituições, cheques, livranças, comerciantes/empresas, familiares/pessoas próximas e outros credores",
    "Elektrik, su, telefon, internet, doğalgaz ve özel faturalar": "Faturas de eletricidade, água, telefone, internet, gás natural e faturas personalizadas",
    "Yalnızca bu kayda bağlı ödemeler": "Apenas os pagamentos associados a este registo",
    "Takvimle otomatik artar. Diğer alanları kaydetmek bu gecikme referansını değiştirmez.": "Aumenta automaticamente de acordo com o calendário. Guardar os outros campos não altera esta referência de atraso.",
    "Gelir ayrıntıları": "Detalhes dos rendimentos",
    "Gelir bilgisi belirtilmemiş.": "Não foi indicado nenhum rendimento.",
    "Kişi, kayıt, ödeme türü, tarih ve tutar birbirine karışmadan listelenir.": "A pessoa, o registo, o tipo de pagamento, a data e o valor são apresentados sem misturar as respetivas ligações.",
    "Seçili kapsamda gerçekleşen ödeme bulunmuyor.": "Não foram encontrados pagamentos realizados no âmbito selecionado.",
    "Normal giderler ile ödeme kayıtları aynı toplamda yer alır; kaynak türleri ayrı etiketlerle gösterilir.": "As despesas comuns e os registos de pagamento integram o mesmo total, mas os tipos de origem são apresentados com etiquetas distintas.",
    "Her gün başlık olarak gösterilir. Başlığa dokununca günlük harcamalar ve ödemeler kendi bölümlerinde açılır.": "Cada dia é apresentado como um título. Toque no título para abrir as despesas e os pagamentos desse dia nas respetivas secções.",
    "MİZAN PDF raporunu kaydet": "Guardar o relatório PDF do MİZAN",
    "PDF raporu kaydedilemedi": "Não foi possível guardar o relatório PDF",
    "Rapor kapsamı": "Âmbito do relatório",
    "Dönem ve kişi filtresi ekrandaki verilerle PDF’de birebir aynıdır.": "Os filtros de período e de pessoas são exatamente iguais nos dados apresentados no ecrã e no PDF.",
    "Kalan kayıt durumu (opsiyonel)": "Estado dos registos restantes (opcional)",
    "Tüm durumlar": "Todos os estados",
    "Gelirden gerçekleşen ödemeler ve giderler sırayla düşülür.": "Os pagamentos realizados e as despesas são deduzidos dos rendimentos pela ordem apresentada.",
    "Normal giderler ile banka, şahıs, fatura, abonelik, kira ve taksit ödemelerine yapılan giderlerin toplamıdır. Gelir ayrı gösterilir.": "É a soma das despesas comuns com os pagamentos de dívidas bancárias e pessoais, faturas, subscrições, rendas e prestações. Os rendimentos são apresentados separadamente.",
    "Gelir sonrası net": "Saldo líquido após os rendimentos",
    "PDF rapor sayfası görüntüye dönüştürülemedi.": "Não foi possível converter a página do relatório PDF numa imagem.",
    "Ödeme kayıtları ve Giderler bölümü birbirine karıştırılmadan hesaplanır.": "Os registos de pagamento e a secção Despesas são calculados sem misturar as respetivas origens.",
    "Her ödeme yalnız bağlı olduğu kişi ve kayıt altında gösterilir.": "Cada pagamento é apresentado apenas sob a pessoa e o registo a que está associado.",
    "Gecikmiş kayıtlarda gösterilen taksit ve ana para tutarlarına işleyebilecek faizler, gecikme bedelleri ve diğer olası durum etkenleri dahil değildir.": "Os valores das prestações e do capital apresentados nos registos em atraso não incluem eventuais juros, encargos de mora ou outros fatores aplicáveis.",
    "Normal giderler ve ödeme kayıtları aynı rapor toplamına dahil edilir; kaynakları birbirine karıştırılmadan ayrı renklerle gösterilir.": "As despesas comuns e os registos de pagamento integram o mesmo total do relatório, mas são apresentados com cores diferentes sem misturar as respetivas origens.",
    "Günler başlık olarak gösterilir; her günün normal harcamaları ve ödemeleri kendi bölümünde, satır taşması olmadan listelenir.": "Os dias são apresentados como títulos; as despesas comuns e os pagamentos de cada dia são listados nas respetivas secções, sem texto fora da linha.",
    "Vade, kişi, kayıt türü, gecikme süresi ve sıradaki ödeme tutarı birlikte sunulur.": "O vencimento, a pessoa, o tipo de registo, a duração do atraso e o valor do próximo pagamento são apresentados em conjunto.",
    "Seçili kişilerin bütün açık kayıtları, dönem filtresinden bağımsız güncel bakiye olarak sunulur.": "Todos os registos em aberto das pessoas selecionadas são apresentados como saldos atuais, independentemente do filtro de período.",
    "Uygulama boş ve kullanıma hazır": "A aplicação está vazia e pronta a utilizar",
    "MİZAN kullanıma hazır. İlk kişi veya kaydı ekleyebilirsin.": "O MİZAN está pronto a utilizar. Pode adicionar a primeira pessoa ou o primeiro registo.",
    "Örnek ödeme veya borç oluşturulmadı. Kayıtlar bölümünden ilk kişiyi ekleyerek başlayabilirsin.": "Não foram criados pagamentos nem dívidas de exemplo. Comece por adicionar a primeira pessoa na secção Registos.",
    "Bu seçimler yalnız ilk kurulumda sorulur. Daha sonra Ayarlar bölümünden değiştirilebilir; mevcut kayıtlar silinmez.": "Estas opções são pedidas apenas na configuração inicial. Podem ser alteradas mais tarde em Definições, sem eliminar os registos existentes.",
    "Bu seçimleri değiştirmek kayıtları, ödemeleri veya geçmişi silmez.": "Alterar estas opções não elimina registos, pagamentos nem o histórico.",
    "Dil, ülke veya varsayılan para birimi değiştiğinde mevcut kişi, borç, fatura, gider, gelir ve ödeme kayıtları değiştirilmez.": "Alterar o idioma, o país ou a moeda predefinida não modifica os registos existentes de pessoas, dívidas, faturas, despesas, rendimentos ou pagamentos.",
    "MİZAN yaklaşık zamanlama kullanmaz. Kaydettiğinde gerekli Android izin ekranı otomatik açılır; izin verildiğinde bildirimler uygulamaya dönüşte otomatik senkronize edilir.": "O MİZAN não utiliza horários aproximados. Ao guardar, o ecrã de permissão necessário do Android é aberto automaticamente; depois de conceder a permissão, as notificações são sincronizadas ao regressar à aplicação.",
    "Yeni kayıt doğrulandıktan sonra ana dosya değiştirilir; son sağlam kopya ayrıca korunur.": "O ficheiro principal só é substituído depois de os novos dados serem validados; a última cópia válida também é preservada.",
    "Her değişiklik cihazda anında kaydedilir; sağlam kayıt doğrulanmadan üzerine yazılmaz.": "Cada alteração é guardada imediatamente no dispositivo; os dados válidos não são substituídos antes de o novo registo ser validado.",
    "Yedek içe aktarılırken mevcut kayıtlar silinmez. Ortak kayıtlar atlanır, yalnız yeni kayıtlar ve eksik ilişkiler eklenir.": "Ao importar uma cópia de segurança, os registos existentes não são eliminados. Os registos coincidentes são ignorados; apenas são adicionados novos registos e relações em falta.",
    "Mevcut kayıtlar silinmeyecek veya yedekteki ortak verilerle yeniden yazılmayacak. Yalnız yeni kayıtlar ve eksik alt ilişkiler eklenecek.": "Os registos existentes não serão eliminados nem substituídos por dados coincidentes da cópia de segurança. Apenas serão adicionados novos registos e relações secundárias em falta.",
    "Bugünkü giderlerini işlemeyi unutma.": "Não se esqueça de registar as despesas de hoje.",
    "Öğlene kadar yaptığın harcamaları ekleyebilirsin.": "Pode adicionar as despesas efetuadas até ao meio-dia.",
    "Günü kapatmadan giderlerini kontrol et.": "Verifique as despesas antes de terminar o dia.",
    "Günün ödeme planını gözden geçir.": "Reveja o plano de pagamentos de hoje.",
    "Aynı raporu kaydedebilir veya WhatsApp dahil paylaşım menüsüne gönderebilirsin.": "Pode guardar o mesmo relatório ou enviá-lo através do menu de partilha, incluindo o WhatsApp.",
    "Harcamalar gün gün gruplanır; arama ve günlük toplam sıralaması uzun yıllarda da kontrollü çalışır.": "As despesas são agrupadas por dia; a pesquisa e a ordenação pelos totais diários mantêm-se eficientes mesmo em períodos de vários anos.",
    "Tarih, gün adı, gider, kategori veya not yazabilirsiniz. Türkçe karakterler ve bitişik ifadeler eşleşir.": "Pode pesquisar por data, dia da semana, despesa, categoria ou nota. Os caracteres acentuados e os termos escritos sem espaços também são reconhecidos.",
    "Önce kişiyi seç, ardından kayıt türünü aç. Her bölüm birbirinden bağımsız tutulur.": "Selecione primeiro a pessoa e depois abra o tipo de registo. Cada secção é mantida de forma independente.",
    "Kayıtların birbirine karışmaması için önce ödeme ve gider kayıtlarının sahibi olacak kişiyi ekleyin.": "Para manter os registos separados, adicione primeiro a pessoa a quem pertencem os pagamentos e as despesas.",
    "Banka adı kullanıcı tarafından yazılır. Hazır banka markası veya logosu kullanılmaz.": "O nome do banco é introduzido pelo utilizador. Não são utilizadas marcas nem logótipos bancários predefinidos.",
    "Hazır marka listesi yoktur; adı kullanıcı belirler.": "Não existe uma lista de marcas predefinida; o nome é indicado pelo utilizador.",
    "15 veya 20 gibi yalnız gün numarasını yazın; MİZAN takvimi kendisi takip eder.": "Introduza apenas o número do dia, como 15 ou 20; o MİZAN acompanha automaticamente o calendário.",
}

override_end = source.index("\n}\n\nREPLACEMENTS:")
for key, value in reviewed_overrides.items():
    encoded_key = json.dumps(key, ensure_ascii=False)
    encoded_value = json.dumps(value, ensure_ascii=False)
    line_pattern = rf'^    {__import__("re").escape(encoded_key)}: .*,$'
    replacement_line = f"    {encoded_key}: {encoded_value},"
    updated, count = __import__("re").subn(
        line_pattern,
        replacement_line,
        source,
        count=1,
        flags=__import__("re").MULTILINE,
    )
    if count:
        source = updated
        changed = True
        continue
    insertion = replacement_line + "\n"
    source = source[:override_end] + insertion + source[override_end:]
    override_end += len(insertion)
    changed = True

start = source.index("REPLACEMENTS: tuple[tuple[str, str], ...] = (")
end = source.index("\ndef build_static_locale()", start)
new_block = r'''WORD_REPLACEMENTS: tuple[tuple[str, str], ...] = (
    ("Configurações", "Definições"),
    ("configurações", "definições"),
    ("aplicativos", "aplicações"),
    ("aplicativo", "aplicação"),
    ("Arquivos", "Ficheiros"),
    ("arquivos", "ficheiros"),
    ("Arquivo", "Ficheiro"),
    ("arquivo", "ficheiro"),
    ("Usuários", "Utilizadores"),
    ("usuários", "utilizadores"),
    ("Usuário", "Utilizador"),
    ("usuário", "utilizador"),
    ("Telas", "Ecrãs"),
    ("telas", "ecrãs"),
    ("Tela", "Ecrã"),
    ("tela", "ecrã"),
    ("Celulares", "Telemóveis"),
    ("celulares", "telemóveis"),
    ("Celular", "Telemóvel"),
    ("celular", "telemóvel"),
    ("Registros", "Registos"),
    ("registros", "registos"),
    ("Registro", "Registo"),
    ("registro", "registo"),
    ("registrados", "registados"),
    ("registradas", "registadas"),
    ("registrado", "registado"),
    ("registrada", "registada"),
    ("registrar", "registar"),
    ("Salvamento", "Gravação"),
    ("salvamento", "gravação"),
    ("Salvos", "Guardados"),
    ("salvos", "guardados"),
    ("Salvas", "Guardadas"),
    ("salvas", "guardadas"),
    ("Salvo", "Guardado"),
    ("salvo", "guardado"),
    ("Salva", "Guardada"),
    ("salva", "guardada"),
    ("Salvar", "Guardar"),
    ("salvar", "guardar"),
    ("Excluídos", "Eliminados"),
    ("excluídos", "eliminados"),
    ("Excluídas", "Eliminadas"),
    ("excluídas", "eliminadas"),
    ("Excluído", "Eliminado"),
    ("excluído", "eliminado"),
    ("Excluída", "Eliminada"),
    ("excluída", "eliminada"),
    ("Excluir", "Eliminar"),
    ("excluir", "eliminar"),
    ("Exclua", "Elimine"),
    ("exclua", "elimine"),
    ("Gerenciar", "Gerir"),
    ("gerenciar", "gerir"),
    ("Gerencie", "Gira"),
    ("gerencie", "gira"),
    ("Gerenciamento", "Gestão"),
    ("gerenciamento", "gestão"),
    ("Compartilhar", "Partilhar"),
    ("compartilhar", "partilhar"),
    ("compartilhados", "partilhados"),
    ("compartilhadas", "partilhadas"),
    ("compartilhado", "partilhado"),
    ("compartilhada", "partilhada"),
    ("Mesclar", "Combinar"),
    ("mesclar", "combinar"),
    ("mesclados", "combinados"),
    ("mescladas", "combinadas"),
    ("mesclado", "combinado"),
    ("mesclada", "combinada"),
    ("Backup", "Cópia de segurança"),
    ("backup", "cópia de segurança"),
    ("Receitas", "Rendimentos"),
    ("receitas", "rendimentos"),
    ("Receita", "Rendimento"),
    ("receita", "rendimento"),
    ("Aluguéis", "Rendas"),
    ("aluguéis", "rendas"),
    ("Aluguel", "Renda"),
    ("aluguel", "renda"),
    ("Parcelados", "A prestações"),
    ("parcelados", "a prestações"),
    ("Parceladas", "A prestações"),
    ("parceladas", "a prestações"),
    ("Parcelado", "A prestações"),
    ("parcelado", "a prestações"),
    ("Parcelada", "A prestações"),
    ("parcelada", "a prestações"),
    ("Parcelas", "Prestações"),
    ("parcelas", "prestações"),
    ("Parcela", "Prestação"),
    ("parcela", "prestação"),
    ("Assinaturas", "Subscrições"),
    ("assinaturas", "subscrições"),
    ("Assinatura", "Subscrição"),
    ("assinatura", "subscrição"),
    ("Seções", "Secções"),
    ("seções", "secções"),
    ("Seção", "Secção"),
    ("seção", "secção"),
    ("Escopo", "Âmbito"),
    ("escopo", "âmbito"),
    ("Status", "Estado"),
    ("status", "estado"),
    ("Somente", "Apenas"),
    ("somente", "apenas"),
    ("Faturamento", "Faturação"),
    ("faturamento", "faturação"),
    ("Exibidos", "Apresentados"),
    ("exibidos", "apresentados"),
    ("Exibidas", "Apresentadas"),
    ("exibidas", "apresentadas"),
    ("Exibido", "Apresentado"),
    ("exibido", "apresentado"),
    ("Exibida", "Apresentada"),
    ("exibida", "apresentada"),
    ("Vinculados", "Associados"),
    ("vinculados", "associados"),
    ("Vinculadas", "Associadas"),
    ("vinculadas", "associadas"),
    ("Vinculado", "Associado"),
    ("vinculado", "associado"),
    ("Vinculada", "Associada"),
    ("vinculada", "associada"),
    ("Vínculos", "Ligações"),
    ("vínculos", "ligações"),
    ("Vínculo", "Ligação"),
    ("vínculo", "ligação"),
    ("energia elétrica", "eletricidade"),
    ("Energia elétrica", "Eletricidade"),
    ("dólar americano", "dólar dos Estados Unidos"),
    ("Digite", "Escreva"),
    ("digite", "escreva"),
    ("Informe", "Introduza"),
    ("informe", "introduza"),
    ("Confira", "Verifique"),
    ("confira", "verifique"),
    ("Você", ""),
    ("você", ""),
    ("Retornar", "Regressar"),
    ("retornar", "regressar"),
    ("Nº", "N.º"),
)

PHRASE_REPAIRS: tuple[tuple[str, str], ...] = (
    ("Cópia de cópia de segurança", "Cópia de segurança"),
    ("cópia de cópia de segurança", "cópia de segurança"),
    ("o cópia de segurança", "a cópia de segurança"),
    ("O cópia de segurança", "A cópia de segurança"),
    ("do cópia de segurança", "da cópia de segurança"),
    ("um cópia de segurança", "uma cópia de segurança"),
    ("último cópia de segurança válido", "última cópia de segurança válida"),
    ("Último cópia de segurança válido", "Última cópia de segurança válida"),
    ("do aplicação", "da aplicação"),
    ("no aplicação", "na aplicação"),
    ("o aplicação", "a aplicação"),
    ("O aplicação", "A aplicação"),
    ("este aplicação", "esta aplicação"),
    ("Este aplicação", "Esta aplicação"),
    ("idioma do aplicação", "idioma da aplicação"),
    ("na ecrã", "no ecrã"),
    ("da ecrã", "do ecrã"),
    ("uma ecrã", "um ecrã"),
    ("do renda/prestação", "da renda/prestação"),
    ("do renda", "da renda"),
    ("Detalhes das rendimentos", "Detalhes dos rendimentos"),
    ("das rendimentos", "dos rendimentos"),
    ("As rendimentos", "Os rendimentos"),
    ("as rendimentos", "os rendimentos"),
    ("Nenhuma rendimento", "Nenhum rendimento"),
    ("nenhuma rendimento", "nenhum rendimento"),
    ("uma rendimento", "um rendimento"),
    ("Guardadamento", "Gravação"),
    ("guardadamento", "gravação"),
    ("Guardadar", "Guardar"),
    ("guardadar", "guardar"),
    ("prestaçãoda", "a prestações"),
    ("prestaçãodo", "a prestações"),
    ("em suas respetivas secções", "nas respetivas secções"),
    ("em suas respetivas seções", "nas respetivas secções"),
    ("sem misturar suas origens", "sem misturar as respetivas origens"),
    ("com seus identificadores", "com os respetivos identificadores"),
    ("aos quais está associado", "a que está associado"),
    ("na hora e no minuto", "à hora e ao minuto"),
    ("na hora exata", "à hora exata"),
    ("todos os estado", "todos os estados"),
    ("Todos os estado", "Todos os estados"),
    ("estado ativado/desativado", "estado ativo/inativo"),
    ("Estado ativado/desativado", "Estado ativo/inativo"),
    ("Dívida pessoal / Empresarial", "Dívida pessoal / empresarial"),
    ("Pessoal / Empresarial", "Pessoal / empresarial"),
)


def _replace_complete_word(value: str, source: str, target: str) -> str:
    return re.sub(rf"(?<!\w){re.escape(source)}(?!\w)", target, value)


def european_value(key: str, value: str) -> str:
    if key in OVERRIDES:
        return OVERRIDES[key]
    result = value
    for source_word, target_word in WORD_REPLACEMENTS:
        result = _replace_complete_word(result, source_word, target_word)
    for source_phrase, target_phrase in PHRASE_REPAIRS:
        result = result.replace(source_phrase, target_phrase)
    if "fatura" in key.casefold():
        result = re.sub(r"\bcontas\b", "faturas", result, flags=re.IGNORECASE)
        result = re.sub(r"\bconta\b", "fatura", result, flags=re.IGNORECASE)
    result = re.sub(r"\s{2,}", " ", result).strip()
    return result

'''
if source[start:end] != new_block:
    source = source[:start] + new_block + source[end:]
    changed = True

dynamic_start = source.index("def build_dynamic_locale() -> None:")
dynamic_end = source.index("\ndef _load(", dynamic_start)
new_dynamic = r'''def build_dynamic_locale() -> None:
    source = PT_BR_DYNAMIC.read_text(encoding="utf-8")
    source = source.replace("PortugueseBr", "PortuguesePt")
    source = source.replace("portugueseBr", "portuguesePt")
    source = source.replace("pt-BR", "pt-PT")
    for source_word, target_word in WORD_REPLACEMENTS:
        source = _replace_complete_word(source, source_word, target_word)
    for source_phrase, target_phrase in PHRASE_REPAIRS:
        source = source.replace(source_phrase, target_phrase)
    dynamic_repairs = {
        "'Escopo de pessoas: ${t(m[1]!)}'": "'Âmbito de pessoas: ${t(m[1]!)}'",
        "'${m[1]} é esperado hoje'": "'${m[1]} está previsto para hoje'",
        "'A categoria ${m[1]} e apenas as despesas associados a ela serão eliminadas.'": "'A categoria ${m[1]} e apenas as despesas que lhe estão associadas serão eliminadas.'",
        "'${m[1]} e todos os registos associados a esta pessoa serão eliminados.": "'${m[1]} e todos os registos associados a esta pessoa serão eliminados.",
        "'Não foi possível guardadar o relatório PDF: ${m[1]}'": "'Não foi possível guardar o relatório PDF: ${m[1]}'",
        "value == '1' ? '1 ligação atualizado' : '$value ligações atualizados'": "value == '1' ? '1 ligação atualizada' : '$value ligações atualizadas'",
        "'Valor real da conta de ${m[1]}'": "'Valor real da fatura de ${m[1]}'",
    }
    for old, new in dynamic_repairs.items():
        source = source.replace(old, new)
    PT_PT_DYNAMIC.write_text(source, encoding="utf-8")

'''
if source[dynamic_start:dynamic_end] != new_dynamic:
    source = source[:dynamic_start] + new_dynamic + source[dynamic_end:]
    changed = True

verify_anchor = '    i18n = I18N.read_text(encoding="utf-8")\n'
strict_gate = r'''    strict_forbidden = re.compile(
        r"\b(?:aplicativo|arquivo|salvar|salvamento|excluir|usuário|tela|celular|"
        r"configurações|registro|receita|aluguel|parcela|assinatura|gerenciar|"
        r"compartilhar|mesclar|somente|escopo|status|seção|seções|faturamento)\b|"
        r"guardadamento|guardadar|prestaçãod|cópia de cópia|do aplicação|no aplicação|"
        r"o aplicação|idioma do aplicação|na ecrã|da ecrã|do renda|das rendimentos|"
        r"as rendimentos|nenhuma rendimento|do cópia|o cópia|um cópia|vinculad|exibid",
        re.IGNORECASE,
    )
    strict_leaks = [(key, value) for key, value in pairs if strict_forbidden.search(value)]
    if strict_leaks:
        raise SystemExit(f"Non-native or malformed pt-PT copy: {strict_leaks[:20]}")
    dynamic_source = PT_PT_DYNAMIC.read_text(encoding="utf-8")
    if strict_forbidden.search(dynamic_source):
        match = strict_forbidden.search(dynamic_source)
        raise SystemExit(f"Non-native or malformed pt-PT dynamic copy: {match.group(0)!r}")
'''
if strict_gate not in source:
    if source.count(verify_anchor) != 1:
        raise SystemExit("Could not locate pt-PT verify insertion point")
    source = source.replace(verify_anchor, strict_gate + verify_anchor, 1)
    changed = True
else:
    old_fragment = r'guardad|prestaçãod|cópia de cópia'
    new_fragment = r'guardadamento|guardadar|prestaçãod|cópia de cópia'
    if old_fragment in source:
        source = source.replace(old_fragment, new_fragment, 1)
        changed = True

if changed:
    path.write_text(source, encoding="utf-8")
    print("Installed native-safe pt-PT conversion, overrides and strict gates.")
else:
    print("Native-safe pt-PT builder hardening is already current.")

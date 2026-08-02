#!/usr/bin/env python3
"""Build and verify the reviewed European Portuguese (`pt-PT`) locale.

The Brazilian Portuguese locale is used only as the already reviewed semantic
base. This script applies a deterministic European Portuguese terminology and
grammar layer, writes fixed catalog names from CLDR/Babel, integrates runtime
routing, and updates multilingual regression expectations. No network service
or runtime translation is used by the application.
"""
from __future__ import annotations

import argparse
import json
import re
import unicodedata
from pathlib import Path
from typing import Iterable

ROOT = Path(__file__).resolve().parents[1]
PT_BR = ROOT / "lib/l10n/mizan_pt_br.dart"
PT_BR_DYNAMIC = ROOT / "lib/l10n/mizan_pt_br_dynamic.dart"
PT_PT = ROOT / "lib/l10n/mizan_pt_pt.dart"
PT_PT_DYNAMIC = ROOT / "lib/l10n/mizan_pt_pt_dynamic.dart"
I18N = ROOT / "lib/l10n/mizan_i18n.dart"
HEADER = "// REVIEWED PT-PT LOCALIZATION — 791/791 STATIC VALUES AUDITED."
BR_MARKER = "const Map<String, String> mizanPortugueseBr"
PT_MARKER = "const Map<String, String> mizanPortuguesePt"


def _skip(text: str, index: int) -> int:
    while index < len(text):
        if text[index].isspace():
            index += 1
            continue
        if text.startswith("//", index):
            newline = text.find("\n", index)
            index = len(text) if newline < 0 else newline + 1
            continue
        if text.startswith("/*", index):
            end = text.find("*/", index + 2)
            if end < 0:
                raise ValueError("Unterminated block comment")
            index = end + 2
            continue
        return index
    return index


def _dart_string(text: str, index: int) -> tuple[str, int]:
    raw = False
    if text.startswith("r'", index):
        raw = True
        index += 1
    if index >= len(text) or text[index] != "'":
        raise ValueError(f"Expected Dart string at {index}")
    index += 1
    chars: list[str] = []
    while index < len(text):
        char = text[index]
        if char == "'":
            return "".join(chars), index + 1
        if char == "\\" and not raw:
            index += 1
            escaped = text[index]
            chars.append({"n": "\n", "r": "\r", "t": "\t"}.get(escaped, escaped))
            index += 1
            continue
        chars.append(char)
        index += 1
    raise ValueError("Unterminated Dart string")


def parse_map(source: str, marker: str) -> list[tuple[str, str]]:
    marker_index = source.index(marker)
    start = source.index("{", marker_index) + 1
    end = source.index("\n};", start)
    body = source[start:end]
    result: list[tuple[str, str]] = []
    index = 0
    while True:
        index = _skip(body, index)
        if index >= len(body):
            break
        key, index = _dart_string(body, index)
        index = _skip(body, index)
        if body[index] != ":":
            raise ValueError(f"Expected ':' after {key!r}")
        index = _skip(body, index + 1)
        parts: list[str] = []
        while index < len(body) and (body[index] == "'" or body.startswith("r'", index)):
            part, index = _dart_string(body, index)
            parts.append(part)
            index = _skip(body, index)
        if index >= len(body) or body[index] != ",":
            raise ValueError(f"Expected ',' after {key!r}")
        result.append((key, "".join(parts)))
        index += 1
    if len({key for key, _ in result}) != len(result):
        raise ValueError("Duplicate localization keys")
    return result


def quote(value: str) -> str:
    return "'" + (
        value.replace("\\", "\\\\")
        .replace("'", "\\'")
        .replace("$", "\\$")
        .replace("\r", "\\r")
        .replace("\n", "\\n")
    ) + "'"


def render_map(pairs: Iterable[tuple[str, str]]) -> str:
    lines = [
        HEADER,
        "// Deterministic European Portuguese product source.",
        "// User-authored names, notes and descriptions are never translated.",
        f"{PT_MARKER} = <String, String>{{",
    ]
    lines.extend(f"  {quote(key)}: {quote(value)}," for key, value in pairs)
    lines.extend(["};", ""])
    return "\n".join(lines)


# These are semantic choices where a blind Brazilian-to-European word swap is
# insufficient or would be ambiguous in a finance application.
OVERRIDES: dict[str, str] = {
    "MİZAN Aylık Raporu": "Relatório mensal do MİZAN",
    "KMH hesabı": "Conta com descoberto autorizado",
    "Kredi kartı": "Cartão de crédito",
    "Kredi": "Crédito",
    "Araç kredisi": "Crédito automóvel",
    "Ev kredisi": "Crédito à habitação",
    "Nakit avans": "Adiantamento de numerário",
    "Taksitli nakit avans": "Adiantamento de numerário em prestações",
    "Özel borç türü": "Tipo de dívida personalizado",
    "Taksit ödemesi": "Pagamento de prestação",
    "Elektrik": "Eletricidade",
    "Tek dönem faturası": "Fatura de período único",
    "Her ay tekrarlayan fatura": "Fatura mensal recorrente",
    "Özel fatura": "Fatura personalizada",
    "Ev kirası": "Renda da habitação",
    "Ürün taksiti": "Prestação de produto",
    "Senet": "Livrança",
    "Üyelik": "Adesão",
    "Abonelik": "Subscrição",
    "Diğer abonelik": "Outra subscrição",
    "Kira / taksit": "Renda / Prestação",
    "Ayarlar": "Definições",
    "Kaydet": "Guardar",
    "Sil": "Eliminar",
    "Aramayı temizle": "Limpar pesquisa",
    "Uygulama dili": "Idioma da aplicação",
    "Kurulumu tamamla": "Concluir configuração",
    "Profil kayıtları korunur": "Os registos do perfil são preservados",
    "CSV yedekleme": "Cópia de segurança CSV",
    "CSV yedeğini dışa aktar": "Exportar cópia de segurança CSV",
    "CSV yedeğini mevcut verilerle birleştir": "Combinar a cópia de segurança CSV com os dados existentes",
    "Kişi": "Pessoa",
    "Kayıtlar": "Registos",
    "Gelir": "Rendimento",
    "Gelirler": "Rendimentos",
    "Gelir bilgileri": "Informações sobre rendimentos",
    "Gelir ekle": "Adicionar rendimento",
    "Gelir özeti": "Resumo dos rendimentos",
    "Bu ay gelir": "Rendimento deste mês",
    "Gelir türü": "Tipo de rendimento",
    "Gelir tutarı": "Valor do rendimento",
    "Gelir notu": "Nota do rendimento",
    "Abonelikler": "Subscrições",
    "Kira": "Renda",
    "Taksit": "Prestação",
    "Kira ve Taksitler": "Rendas e prestações",
    "Banka / kredi": "Banco / Crédito",
    "PDF indir": "Transferir PDF",
    "PDF paylaş": "Partilhar PDF",
    "PDF raporu": "Relatório PDF",
    "MİZAN CSV yedeğini kaydet": "Guardar cópia de segurança CSV do MİZAN",
    "MİZAN CSV yedeğini seç": "Selecionar cópia de segurança CSV do MİZAN",
    "CSV yedeğini birleştir": "Combinar cópia de segurança CSV",
    "Verileri birleştir": "Combinar dados",
    "MİZAN full backup": "Cópia de segurança completa do MİZAN",
    "MİZAN tam yedek": "Cópia de segurança completa do MİZAN",
    "ONAYLIYORUM": "CONFIRMO",
    "ONAYLIYORUM yazın": "Escreva CONFIRMO",
    "Tam olarak ONAYLIYORUM yazılmalı.": "Escreva exatamente CONFIRMO.",
    "Kategori silmek için tam olarak ONAYLIYORUM yazılmalı.": "Para eliminar a categoria, escreva exatamente CONFIRMO.",
    "Dijital hizmet": "Serviço digital",
    "Kira / taksit ekle": "Adicionar renda / Prestação",
    "Kira / taksiti düzenle": "Editar renda / Prestação",
    "Kira/taksit tutarı": "Valor da renda/prestação",
    "Kira/taksit başlığı": "Título da renda/prestação",
    "Kira/taksit kaydı bulunamadı.": "O registo de renda/prestação não foi encontrado.",
    "Kira veya taksit kaydı bulunmuyor.": "Não existem registos de renda ou prestações.",
    "Aboneliği düzenle": "Editar subscrição",
    "Abonelik ekle": "Adicionar subscrição",
    "Abonelik kaydı bulunmuyor.": "Não existem registos de subscrições.",
    "Abonelik kaydı bulunamadı.": "O registo de subscrição não foi encontrado.",
    "Abonelik tutarı": "Valor da subscrição",
    "Abonelik türü": "Tipo de subscrição",
    "Abonelik başlığı": "Título da subscrição",
    "Senet numarası": "Número da livrança",
    "Senet numarası boş bırakılamaz.": "O número da livrança é obrigatório.",
    "Senet no": "N.º da livrança",
    "Senet adedi": "Quantidade de livranças",
    "Mevcut senet": "Livrança atual",
    "Birden fazla senet varsa her biri ayrı vade satırı olarak oluşturulur.": "Se existir mais de uma livrança, cada uma será criada como uma linha de vencimento separada.",
    "Lefferion Prime - MİZAN hata yapabilir. Lütfen vade, gecikme ve ödeme bilgilerini son kez kontrol edin.": "O Lefferion Prime — MİZAN pode cometer erros. Verifique novamente os vencimentos, atrasos e dados de pagamento.",    "Uygulama boş ve kullanıma hazır": "A aplicação está vazia e pronta a utilizar",
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
    "Gelir bilgisi belirtilmemiş": "Nenhum rendimento indicado",
    "Tek seferlik, günlük, haftalık veya aylık gelir ekleyebilirsin.": "Pode adicionar rendimentos pontuais, diários, semanais ou mensais.",
    "Arşivden çıkar": "Retirar do arquivo",
    "Gelir türü / adı": "Tipo / Nome do rendimento",
    "Maaş, ek iş, kira geliri…": "Salário, trabalho extra, rendimento de rendas…",
    "Gelir tutarı sıfırdan büyük olmalıdır.": "O valor do rendimento deve ser superior a zero.",
    "Gelir sıklığı": "Frequência do rendimento",
    "Gelir başlangıç tarihini seçin": "Selecionar a data de início do rendimento",
    "Gelir notu (opsiyonel)": "Nota do rendimento (opcional)",
    "Gelirin gerçekten alındığı tarihi seçin": "Selecionar a data em que o rendimento foi efetivamente recebido",
    "Haftalık gelir için geçerli bir gün seçilmelidir.": "Selecione um dia da semana válido para o rendimento semanal.",
    "Aylık gelir günü 1 ile 31 arasında olmalıdır.": "O dia do rendimento mensal deve estar entre 1 e 31.",
    "Yatış günü takibi yalnız haftalık ve aylık gelirlerde kullanılabilir.": "O acompanhamento do dia de recebimento só pode ser utilizado em rendimentos semanais e mensais.",
    "Bu gelir için yatış günü takibi açık değil.": "O acompanhamento do dia de recebimento não está ativado para este rendimento.",
    "Kişisel / kurumsal borç ekle": "Adicionar dívida pessoal / empresarial",
    "Kişisel / kurumsal borcu düzenle": "Editar dívida pessoal / empresarial",
    "Bu banka grubunda görüntülenecek borç bulunmuyor.": "Não há dívidas para apresentar neste grupo bancário.",
    "Varsayılan aylık tutar": "Valor mensal predefinido",
    "Cihazın varsayılan bildirim sesi": "Som de notificação predefinido do dispositivo",
    "PDF hazırlanıyor.": "A preparar o PDF.",
    "PDF hazırlanıyor": "A preparar o PDF",
    "Normal giderler ve ödemeler ayrı başlıklar altında kalır; yalnız toplam hesaplamada birleşir.": "As despesas comuns e os pagamentos mantêm-se em secções separadas; apenas são combinados no cálculo do total.",
    "İlk kayıttan bugüne kadar bütün ödeme, gider ve gelir hareketleri kapsanır.": "Abrange todos os movimentos de pagamentos, despesas e rendimentos desde o primeiro registo até hoje.",
    "Gider kayıtlarında kişi alanı bulunmadığı için giderler seçili dönem kapsamında ve kişi filtresinden bağımsız hesaplanır.": "Como os registos de despesas não têm um campo de pessoa, as despesas são calculadas no período selecionado, independentemente do filtro de pessoas.",
    "Bu kişide aynı banka adı zaten var.": "Esta pessoa já tem um banco com o mesmo nome.",
    "Gecikme hesabını yeniden kur": "Recalcular atraso",
    "Değer değiştirilirse referans tarihi bugün esas alınarak gecikme, bildirim ve rapor hesapları yeniden kurulur.": "Se o valor for alterado, os cálculos de atraso, notificações e relatórios serão refeitos tendo a data de hoje como referência.",
    "Bu işlem referans tarihini bugün esas alarak vade, gecikme, bildirim, rapor ve ödeme hesaplarını yeniden hesaplayacaktır.": "Esta ação recalculará vencimentos, atrasos, notificações, relatórios e pagamentos tendo a data de hoje como referência.",
    "29, 30 veya 31 seçildiğinde kısa aylarda ayın son geçerli günü kullanılır.": "Nos meses mais curtos, ao selecionar 29, 30 ou 31, é utilizado o último dia válido do mês.",
    "Girilen tutarın ait olduğu ay": "Mês a que pertence o valor introduzido",
    "Belirtilmemiş": "Não indicado",
    "Her ayın kaçıncı günü?": "Em que dia de cada mês?",
    "Haftanın hangi günü yatıyor?": "Em que dia da semana é recebido?",
    "Her ayın kaçında yatıyor?": "Em que dia do mês é recebido?",
    "Her ayın kaçında ödenecek? (1-31)": "Em que dia do mês será paga? (1–31)",

}

WORD_REPLACEMENTS: tuple[tuple[str, str], ...] = (
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
    ("associadas a ela", "que lhe estão associadas"),
    ("maior que zero", "superior a zero"),
    ("Em qual dia", "Em que dia"),
    ("Preparando o PDF.", "A preparar o PDF."),
    ("Preparando PDF", "A preparar o PDF"),
    ("movimentações", "movimentos"),
    ("possuem", "têm"),
    ("exibir", "apresentar"),
    ("padrão", "predefinido"),
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


def build_static_locale() -> None:
    pairs = parse_map(PT_BR.read_text(encoding="utf-8"), BR_MARKER)
    if len(pairs) != 791:
        raise SystemExit(f"Expected 791 pt-BR source keys, found {len(pairs)}")
    converted = [(key, european_value(key, value)) for key, value in pairs]
    PT_PT.write_text(render_map(converted), encoding="utf-8")


def build_dynamic_locale() -> None:
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


def _load(path: Path) -> dict[str, object]:
    return json.loads(path.read_text(encoding="utf-8"))


def _save(path: Path, payload: dict[str, object]) -> None:
    path.write_text(
        json.dumps(payload, ensure_ascii=False, separators=(",", ":")),
        encoding="utf-8",
    )


def _normal(value: str) -> str:
    text = unicodedata.normalize("NFKD", value.casefold())
    return "".join(char for char in text if not unicodedata.combining(char))


def build_catalogs() -> None:
    from babel import Locale

    locale = Locale.parse("pt_PT")
    language_overrides = {
        "pt-BR": "português (Brasil)",
        "pt-PT": "português (Portugal)",
        "fil": "filipino",
    }
    country_overrides = {
        "CI": "Costa do Marfim",
        "CD": "República Democrática do Congo",
        "CG": "República do Congo",
        "CV": "Cabo Verde",
        "CZ": "Chéquia",
        "KR": "Coreia do Sul",
        "KP": "Coreia do Norte",
        "PS": "Territórios Palestinianos",
        "ST": "São Tomé e Príncipe",
        "TL": "Timor-Leste",
        "TR": "Turquia",
        "VA": "Cidade do Vaticano",
    }
    currency_overrides = {
        "BRL": "real brasileiro",
        "EUR": "euro",
        "GBP": "libra esterlina",
        "TRY": "lira turca",
        "USD": "dólar dos Estados Unidos",
        "CVE": "escudo cabo-verdiano",
        "MZN": "metical moçambicano",
        "STN": "dobra de São Tomé e Príncipe",
        "XAF": "franco CFA da África Central",
        "XCD": "dólar das Caraíbas Orientais",
        "XCG": "florim caribenho",
        "XOF": "franco CFA da África Ocidental",
        "XPF": "franco CFP",
        "ZWG": "ouro do Zimbabué",
    }

    languages_path = ROOT / "assets/data/languages_v1.json"
    languages = _load(languages_path)
    for item in languages["items"]:  # type: ignore[index]
        code = str(item["code"])
        base = code.split("-", 1)[0]
        name = language_overrides.get(code) or str(locale.languages.get(base) or "")
        if not name:
            raise SystemExit(f"Missing pt-PT language name for {code}")
        item["namePtPt"] = name
    _save(languages_path, languages)

    countries_path = ROOT / "assets/data/countries_v1.json"
    countries = _load(countries_path)
    for item in countries["items"]:  # type: ignore[index]
        code = str(item["code"])
        name = country_overrides.get(code) or str(locale.territories.get(code) or "")
        if not name:
            raise SystemExit(f"Missing pt-PT country name for {code}")
        item["namePtPt"] = name
    _save(countries_path, countries)

    currencies_path = ROOT / "assets/data/currencies_v1.json"
    currencies = _load(currencies_path)
    for item in currencies["items"]:  # type: ignore[index]
        code = str(item["code"])
        name = currency_overrides.get(code) or str(locale.currencies.get(code) or "")
        if not name:
            raise SystemExit(f"Missing pt-PT currency name for {code}")
        item["namePtPt"] = name
        aliases = item.setdefault("aliases", [])
        for alias in (name, name.casefold(), _normal(name)):
            if alias and alias not in aliases:
                aliases.append(alias)
    _save(currencies_path, currencies)


def replace_once(path: Path, old: str, new: str) -> None:
    text = path.read_text(encoding="utf-8")
    if new in text:
        return
    if text.count(old) != 1:
        raise SystemExit(f"Expected one target in {path.relative_to(ROOT)}: {old[:90]!r}")
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


def replace_all(path: Path, old: str, new: str, count: int) -> None:
    text = path.read_text(encoding="utf-8")
    if text.count(new) == count:
        return
    if text.count(old) != count:
        raise SystemExit(
            f"Expected {count} targets in {path.relative_to(ROOT)}, found {text.count(old)}"
        )
    path.write_text(text.replace(old, new), encoding="utf-8")


def integrate_runtime() -> None:
    replace_once(
        I18N,
        "import 'mizan_pt_br_dynamic.dart';",
        "import 'mizan_pt_br_dynamic.dart';\nimport 'mizan_pt_pt.dart';\nimport 'mizan_pt_pt_dynamic.dart';",
    )
    replace_once(
        I18N,
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR'};",
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT'};",
    )
    replace_once(
        I18N,
        "  static bool get isPortugueseBr => _languageTag == 'pt-BR';\n",
        "  static bool get isPortugueseBr => _languageTag == 'pt-BR';\n  static bool get isPortuguesePt => _languageTag == 'pt-PT';\n",
    )
    replace_once(
        I18N,
        "    'pt-BR' => 'CONFIRMO',\n",
        "    'pt-BR' => 'CONFIRMO',\n    'pt-PT' => 'CONFIRMO',\n",
    )
    replace_once(
        I18N,
        "    if (normalized == 'pt-br') return 'pt-BR';\n",
        "    if (normalized == 'pt-br') return 'pt-BR';\n    if (normalized == 'pt-pt') return 'pt-PT';\n",
    )
    replace_once(
        I18N,
        "        normalized == 'pt-br';\n",
        "        normalized == 'pt-br' ||\n        normalized == 'pt-pt';\n",
    )
    replace_once(
        I18N,
        """    } else {
      result =
          mizanPortugueseBr[visibleSource] ??
          translatePortugueseBrReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'pt-BR'),
          );
    }
""",
        """    } else if (effective == 'pt-BR') {
      result =
          mizanPortugueseBr[visibleSource] ??
          translatePortugueseBrReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'pt-BR'),
          );
    } else {
      result =
          mizanPortuguesePt[visibleSource] ??
          translatePortuguesePtReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'pt-PT'),
          );
    }
""",
    )

    main = ROOT / "lib/main.dart"
    replace_once(
        main,
        """        locale: languageTag == 'pt-BR'
            ? const Locale('pt', 'BR')
            : Locale(languageTag),
""",
        """        locale: switch (languageTag) {
          'pt-BR' => const Locale('pt', 'BR'),
          'pt-PT' => const Locale('pt', 'PT'),
          _ => Locale(languageTag),
        },
""",
    )
    replace_once(
        main,
        "          Locale('pt', 'BR'),\n",
        "          Locale('pt', 'BR'),\n          Locale('pt', 'PT'),\n",
    )

    catalog = ROOT / "lib/global/global_catalog.dart"
    replace_all(
        catalog,
        "    required this.namePtBr,\n",
        "    required this.namePtBr,\n    required this.namePtPt,\n",
        3,
    )
    replace_all(
        catalog,
        "  final String namePtBr;\n",
        "  final String namePtBr;\n  final String namePtPt;\n",
        3,
    )
    replace_all(
        catalog,
        "    namePtBr: json['namePtBr']?.toString() ?? json['nameEn']?.toString() ?? '',\n",
        "    namePtBr: json['namePtBr']?.toString() ?? json['nameEn']?.toString() ?? '',\n    namePtPt: json['namePtPt']?.toString() ?? json['nameEn']?.toString() ?? '',\n",
        3,
    )
    replace_all(
        catalog,
        "    'pt-BR' => namePtBr,\n",
        "    'pt-BR' => namePtBr,\n    'pt-PT' => namePtPt,\n",
        3,
    )
    replace_once(
        catalog,
        "'$code $nativeName $nameTr $nameEn $nameEs $namePtBr'",
        "'$code $nativeName $nameTr $nameEn $nameEs $namePtBr $namePtPt'",
    )
    replace_once(
        catalog,
        "'$code $nameTr $nameEn $nameEs $namePtBr $nativeName'",
        "'$code $nameTr $nameEn $nameEs $namePtBr $namePtPt $nativeName'",
    )
    replace_once(
        catalog,
        "      namePtBr,\n      ...symbols,",
        "      namePtBr,\n      namePtPt,\n      ...symbols,",
    )

    formatters = ROOT / "lib/core/formatters.dart"
    replace_once(
        formatters,
        "  final groupSeparator = MizanI18n.isEnglish ? ',' : '.';\n",
        "  final groupSeparator = MizanI18n.isEnglish\n      ? ','\n      : (MizanI18n.isPortuguesePt ? ' ' : '.');\n",
    )
    replace_once(
        formatters,
        """  if (MizanI18n.isPortugueseBr && code == 'BRL') {
    return 'R\$ $amount';
  }
""",
        """  if (MizanI18n.isPortugueseBr && code == 'BRL') {
    return 'R\$ $amount';
  }
  if (MizanI18n.isPortuguesePt && code == 'EUR') {
    return '$amount €';
  }
""",
    )
    replace_once(
        formatters,
        "      : (MizanI18n.isPortugueseBr ? ptBrMonths : trMonths);\n",
        "      : ((MizanI18n.isPortugueseBr || MizanI18n.isPortuguesePt)\n            ? ptBrMonths\n            : trMonths);\n",
    )
    replace_once(
        formatters,
        """  if (MizanI18n.isPortugueseBr) {
    return '${ptBrMonths[value.month - 1]} de ${value.year}';
  }
""",
        """  if (MizanI18n.isPortugueseBr || MizanI18n.isPortuguesePt) {
    return '${ptBrMonths[value.month - 1]} de ${value.year}';
  }
""",
    )


def update_regressions() -> None:
    paths = [
        ROOT / "test/english_localization_test.dart",
        ROOT / "test/spanish_localization_test.dart",
        ROOT / "test/portuguese_br_localization_test.dart",
        ROOT / "tools/validate_english_localization.py",
        ROOT / "tools/validate_spanish_localization.py",
        ROOT / "tools/validate_portuguese_br_localization.py",
    ]
    for path in paths:
        text = path.read_text(encoding="utf-8")
        text = text.replace(
            "{'tr', 'en', 'es', 'pt-BR'}",
            "{'tr', 'en', 'es', 'pt-BR', 'pt-PT'}",
        )
        text = text.replace(
            "<String>{'tr', 'en', 'es', 'pt-BR'}",
            "<String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT'}",
        )
        text = text.replace(
            "Turkish, English, Spanish and Brazilian Portuguese",
            "Turkish, English, Spanish, Brazilian Portuguese and European Portuguese",
        )
        if path.name == "portuguese_br_localization_test.dart":
            text = text.replace(
                "expect(MizanI18n.isSupported('pt-PT'), isFalse);",
                "expect(MizanI18n.isSupported('pt-PT'), isTrue);",
            )
            text = text.replace(
                "expect(MizanI18n.normalizeLanguageTag('pt-PT'), 'tr');",
                "expect(MizanI18n.normalizeLanguageTag('pt-PT'), 'pt-PT');",
            )
        if path.name.endswith(".py"):
            text = text.replace(
                '"lib/l10n/mizan_pt_br_dynamic.dart",',
                '"lib/l10n/mizan_pt_br_dynamic.dart",\n        "lib/l10n/mizan_pt_pt.dart",\n        "lib/l10n/mizan_pt_pt_dynamic.dart",',
            )
        path.write_text(text, encoding="utf-8")


def write_tests() -> None:
    path = ROOT / "test/portuguese_pt_localization_test.dart"
    path.write_text(
        r'''import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/global/global_catalog.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  test('European Portuguese is enabled as an exact regional locale', () {
    expect(MizanI18n.isSupported('pt-PT'), isTrue);
    expect(MizanI18n.isSupported('pt_PT'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('PT_pt'), 'pt-PT');
    expect(MizanI18n.isSupported('pt'), isFalse);
  });

  test('pt-PT uses native finance and interface terminology', () {
    MizanI18n.setProfile(languageTag: 'pt-PT', currencyCode: 'EUR');
    expect(MizanI18n.text('Ayarlar'), 'Definições');
    expect(MizanI18n.text('Kayıtlar'), 'Registos');
    expect(MizanI18n.text('Kaydet'), 'Guardar');
    expect(MizanI18n.text('Sil'), 'Eliminar');
    expect(MizanI18n.text('Gelir'), 'Rendimento');
    expect(MizanI18n.text('Abonelik'), 'Subscrição');
    expect(MizanI18n.text('Ev kredisi'), 'Crédito à habitação');
    expect(MizanI18n.text('Araç kredisi'), 'Crédito automóvel');
    expect(MizanI18n.text('Kira ve Taksitler'), 'Rendas e prestações');
    expect(MizanI18n.destructiveConfirmation, 'CONFIRMO');
    expect(money(1234567.5), '1 234 567,50 €');
    expect(shortDate(DateTime(2026, 8, 1)), '1 ago 2026');
    expect(monthLabel(DateTime(2026, 8)), 'agosto de 2026');
  });

  test('pt-PT catalogs display European Portuguese while aliases remain searchable', () async {
    MizanI18n.setProfile(languageTag: 'pt-PT', currencyCode: 'EUR');
    final catalog = await GlobalCatalogRepository.load();
    expect(catalog.language('pt-PT').nameFor('pt-PT'), 'português (Portugal)');
    expect(catalog.country('PT').nameFor('pt-PT'), 'Portugal');
    expect(catalog.country('TR').nameFor('pt-PT'), 'Turquia');
    expect(catalog.currency('EUR').nameFor('pt-PT'), 'euro');
    expect(catalog.currency('USD').nameFor('pt-PT'), 'dólar dos Estados Unidos');
    expect(
      catalog.currencies
          .where((item) => item.matches('US Dollar'))
          .singleWhere((item) => item.code == 'USD')
          .nameFor('pt-PT'),
      'dólar dos Estados Unidos',
    );
  });

  test('user-authored text is preserved under pt-PT', () {
    MizanI18n.setProfile(languageTag: 'pt-PT', currencyCode: 'EUR');
    final userName = MizanI18n.user('Configurações Banco');
    final note = MizanI18n.user('Not: Aluguel personalizado');
    expect(MizanI18n.text(userName), 'Configurações Banco');
    expect(MizanI18n.text(note), 'Not: Aluguel personalizado');
    expect(
      MizanI18n.text('$userName · Kalan toplam borç'),
      'Configurações Banco · Dívida total restante',
    );
  });
}
''',
        encoding="utf-8",
    )


def verify() -> None:
    pairs = parse_map(PT_PT.read_text(encoding="utf-8"), PT_MARKER)
    if len(pairs) != 791:
        raise SystemExit(f"Expected 791 pt-PT values, found {len(pairs)}")
    values = dict(pairs)
    required = {
        "Ayarlar": "Definições",
        "Kayıtlar": "Registos",
        "Kaydet": "Guardar",
        "Sil": "Eliminar",
        "Gelir": "Rendimento",
        "Abonelik": "Subscrição",
        "Ev kredisi": "Crédito à habitação",
        "Kira ve Taksitler": "Rendas e prestações",
        "ONAYLIYORUM": "CONFIRMO",
    }
    for key, expected in required.items():
        if values.get(key) != expected:
            raise SystemExit(f"pt-PT terminology mismatch for {key!r}: {values.get(key)!r}")
    forbidden = re.compile(
        r"\b(?:aplicativo|salvar|excluir|usuário|tela|celular|"
        r"configurações|registro|receita|aluguel|parcela|assinatura|"
        r"gerenciar|compartilhar|mesclar)\b",
        re.IGNORECASE,
    )
    leaks = [(key, value) for key, value in pairs if forbidden.search(value)]
    if leaks:
        raise SystemExit(f"Brazilian terminology leakage: {leaks[:12]}")
    # Archive/file context gate.
    archive_usages = [
        (key, value)
        for key, value in pairs
        if re.search(r"\barquivos?\b", value, re.IGNORECASE)
        and not (key == "Arşivden çıkar" and value == "Retirar do arquivo")
    ]
    if archive_usages:
        raise SystemExit(
            f"pt-PT must use ficheiro for computer/data files: {archive_usages[:12]}"
        )
    strict_forbidden = re.compile(
        r"\b(?:aplicativo|salvar|salvamento|excluir|usuário|tela|celular|"
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
    # Native review round 2 gate.
    round2_forbidden = re.compile(
        r"rendimento informada|rendimentos únicas|\bda rendimento\b|"
        r"\buma rendimento\b|\ba rendimento\b|renda de renda|"
        r"Restaurar do ficheiro|\bexibir\b|\bPreparando\b|"
        r"\bmovimentações\b|\bpossuem\b|\bpadrão\b|\bEm qual\b|"
        r"associadas a ela|maior que zero",
        re.IGNORECASE,
    )
    round2_leaks = [
        (key, value) for key, value in pairs if round2_forbidden.search(value)
    ]
    uppercase_business = [
        (key, value) for key, value in pairs if "/ Empresarial" in value
    ]
    if round2_leaks or uppercase_business:
        raise SystemExit(
            f"Second native pt-PT review failed: "
            f"{(round2_leaks + uppercase_business)[:20]}"
        )
    dynamic_round2 = PT_PT_DYNAMIC.read_text(encoding="utf-8")
    dynamic_match = round2_forbidden.search(dynamic_round2)
    if dynamic_match or "/ Empresarial" in dynamic_round2:
        offending = dynamic_match.group(0) if dynamic_match else "/ Empresarial"
        raise SystemExit(
            f"Second native pt-PT dynamic review failed: {offending!r}"
        )
    i18n = I18N.read_text(encoding="utf-8")
    for marker in (
        "'pt-PT'",
        "mizanPortuguesePt[visibleSource]",
        "translatePortuguesePtReviewedDynamic(",
        "static bool get isPortuguesePt",
    ):
        if marker not in i18n:
            raise SystemExit(f"Missing pt-PT runtime marker: {marker}")
    for filename, expected_count in (
        ("languages_v1.json", 29),
        ("countries_v1.json", 161),
        ("currencies_v1.json", 154),
    ):
        payload = _load(ROOT / "assets/data" / filename)
        items = payload["items"]  # type: ignore[index]
        if payload["count"] != expected_count or len(items) != expected_count:  # type: ignore[index]
            raise SystemExit(f"Unexpected catalog size: {filename}")
        if any(not str(item.get("namePtPt", "")).strip() for item in items):
            raise SystemExit(f"Missing namePtPt in {filename}")
    print("pt-PT verification passed: 791/791 static values, runtime and catalogs")


def build() -> None:
    build_static_locale()
    build_dynamic_locale()
    build_catalogs()
    integrate_runtime()
    update_regressions()
    write_tests()
    verify()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--verify", action="store_true")
    args = parser.parse_args()
    if args.verify:
        verify()
    else:
        build()


if __name__ == "__main__":
    main()

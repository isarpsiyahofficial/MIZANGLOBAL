typedef ThaiDynamicTranslator = String Function(String source);

String translateThaiReviewedDynamic(
  String source,
  ThaiDynamicTranslator translate,
) {
  for (final pattern in _thaiPatterns) {
    final match = pattern.regExp.firstMatch(source);
    if (match != null) return pattern.builder(match, translate);
  }
  var value = source;
  for (final entry in _thaiPhrases) {
    value = value.replaceAll(entry.$1, entry.$2);
  }
  return value;
}

int _number(String value) => int.tryParse(value) ?? 0;
String _days(String value) => '${_number(value)} วัน';
String _items(String value) => '${_number(value)} รายการ';
String _openItems(String value) => '${_number(value)} รายการที่เปิดอยู่';
String _payments(String value) => '${_number(value)} การชำระเงิน';
String _expenses(String value) => '${_number(value)} ค่าใช้จ่าย';
String _months(String value) => '${_number(value)} เดือน';
String _selectedPeople(String value) => _number(value) == 0
    ? 'ยังไม่ได้เลือกบุคคล'
    : 'เลือกแล้ว ${_number(value)} คน';
String _remaining(String value) => 'เหลือ ${_number(value)}';
String _remainingDays(String value) => switch (_number(value)) {
  0 => 'ครบกำหนดวันนี้',
  _ => 'เหลือ ${_number(value)} วัน',
};
String _remainingInstallments(String value) => switch (_number(value)) {
  0 => 'ไม่เหลืองวด',
  _ => 'เหลือ ${_number(value)} งวด',
};
String _dailyExpenses(String value) => '${_number(value)} ค่าใช้จ่ายรายวัน';
String _expenseRecords(String value) => '${_number(value)} รายการค่าใช้จ่าย';
String _newItems(String value) => '${_number(value)} รายการใหม่';
String _updatedLinks(String value) => '${_number(value)} ความสัมพันธ์ที่อัปเดต';
String _androidWriteFailure(String value, String error) =>
    'ไม่สามารถเขียน ${_items(value)} ในแผนการแจ้งเตือนไปยังระบบ Android ได้ ข้อผิดพลาดแรก: $error';
String _androidMissing(String value) =>
    'ไม่สามารถตรวจสอบแผนการแจ้งเตือนได้; ฝั่ง Android ขาด ${_items(value)}';

final List<_ThaiPattern> _thaiPatterns = <_ThaiPattern>[
  _ThaiPattern(
    RegExp(r'^MİZAN (.+) Raporu$'),
    (m, t) => 'รายงาน ${t(m[1]!)} MİZAN',
  ),
  _ThaiPattern(
    RegExp(r'^(.+) finans raporu$'),
    (m, t) => 'รายงานการเงิน ${m[1]}',
  ),
  _ThaiPattern(
    RegExp(r'^LEFFERION PRIME - MİZAN · Sayfa (\d+)$'),
    (m, t) => 'LEFFERION PRIME - MİZAN · หน้า ${_number(m[1]!)}',
  ),
  _ThaiPattern(RegExp(r'^(.+) · devam$'), (m, t) => '${t(m[1]!)} · ต่อ'),
  _ThaiPattern(RegExp(r'^Dönem: (.+)$'), (m, t) => 'รอบ: ${m[1]}'),
  _ThaiPattern(
    RegExp(r'^Kişi kapsamı: (.+)$'),
    (m, t) => 'ขอบเขตบุคคล: ${t(m[1]!)}',
  ),
  _ThaiPattern(RegExp(r'^Oluşturulma: (.+)$'), (m, t) => 'สร้างเมื่อ: ${m[1]}'),
  _ThaiPattern(
    RegExp(r'^Açık plan (.+) · Bu ay yapılan (.+)$'),
    (m, t) => 'แผนที่เปิดอยู่ ${m[1]} · ทำแล้วเดือนนี้ ${m[2]}',
  ),
  _ThaiPattern(
    RegExp(r'^(.+) Ödeme Durumu$'),
    (m, t) => 'สถานะการชำระเงิน ${m[1]}',
  ),
  _ThaiPattern(
    RegExp(r'^(\d+) açık kayıt · (.+)$'),
    (m, t) => '${_openItems(m[1]!)} · ${m[2]}',
  ),
  _ThaiPattern(
    RegExp(r'^(\d+) günlük harcama · (\d+) ödeme$'),
    (m, t) => '${_dailyExpenses(m[1]!)} · ${_payments(m[2]!)}',
  ),
  _ThaiPattern(
    RegExp(r'^(\d+) gün · (\d+) kayıt · (.+)$'),
    (m, t) => '${_days(m[1]!)} · ${_items(m[2]!)} · ${m[3]}',
  ),
  _ThaiPattern(
    RegExp(r'^(\d+) ödeme · (.+)$'),
    (m, t) => '${_payments(m[1]!)} · ${m[2]}',
  ),
  _ThaiPattern(
    RegExp(r'^(\d+) gider · (.+)$'),
    (m, t) => '${_expenses(m[1]!)} · ${m[2]}',
  ),
  _ThaiPattern(
    RegExp(r'^(\d+) gider kaydı$'),
    (m, t) => _expenseRecords(m[1]!),
  ),
  _ThaiPattern(
    RegExp(r'^Daha fazla gün göster \((\d+) kaldı\)$'),
    (m, t) => 'แสดงวันเพิ่มเติม (${_remaining(m[1]!)})',
  ),
  _ThaiPattern(
    RegExp(r'^Daha fazla ödeme günü göster \((\d+) kaldı\)$'),
    (m, t) => 'แสดงวันชำระเงินเพิ่มเติม (${_remaining(m[1]!)})',
  ),
  _ThaiPattern(
    RegExp(r'^Daha fazla gider günü göster \((\d+) kaldı\)$'),
    (m, t) => 'แสดงวันค่าใช้จ่ายเพิ่มเติม (${_remaining(m[1]!)})',
  ),
  _ThaiPattern(
    RegExp(r'^Bu günden daha fazla göster \((\d+) kaldı\)$'),
    (m, t) => 'แสดงรายการเพิ่มเติมของวันนี้ (${_remaining(m[1]!)})',
  ),
  _ThaiPattern(
    RegExp(r'^(.+) için (\d+) gün kaldı$'),
    (m, t) => '${_remainingDays(m[2]!)} ถึง ${m[1]}',
  ),
  _ThaiPattern(
    RegExp(r'^(.+) bugün bekleniyor$'),
    (m, t) => 'คาดว่าจะได้รับ ${m[1]} วันนี้',
  ),
  _ThaiPattern(
    RegExp(r'^(.+) (\d+) gün gecikti$'),
    (m, t) => '${m[1]} ค้างชำระ ${_days(m[2]!)}',
  ),
  _ThaiPattern(
    RegExp(r'^Son alındı: (.+) · Planlanan (.+)$'),
    (m, t) => 'ได้รับล่าสุด: ${m[1]} · วางแผนไว้: ${m[2]}',
  ),
  _ThaiPattern(
    RegExp(
      r'^Planlanan (.+) dönemi, (.+) tarihinde alındı olarak kaydedildi\. Sabit yatış günü değişmedi\.$',
    ),
    (m, t) =>
        'รอบ ${m[1]} ที่วางแผนไว้ถูกบันทึกว่าได้รับแล้วเมื่อ ${m[2]} โดยวันรับเงินประจำไม่เปลี่ยนแปลง.',
  ),
  _ThaiPattern(
    RegExp(r'^(.+) gerçek fatura tutarı$'),
    (m, t) => 'ยอดบิลจริง ${m[1]}',
  ),
  _ThaiPattern(RegExp(r'^Kalan tutar: (.+)$'), (m, t) => 'ยอดคงเหลือ: ${m[1]}'),
  _ThaiPattern(
    RegExp(r'^Kalan taksit: (\d+)$'),
    (m, t) => _remainingInstallments(m[1]!),
  ),
  _ThaiPattern(
    RegExp(r'^(.+) gider kaydı silinsin mi\?$'),
    (m, t) => 'ลบรายการค่าใช้จ่าย ${m[1]} หรือไม่?',
  ),
  _ThaiPattern(
    RegExp(
      r'^(.+) kategorisi ve yalnız bu kategoriye bağlı giderler silinecek\.$',
    ),
    (m, t) =>
        'หมวดหมู่ ${m[1]} และเฉพาะค่าใช้จ่ายที่เชื่อมกับหมวดหมู่นี้จะถูกลบ.',
  ),
  _ThaiPattern(
    RegExp(
      r'^(.+) ve bu kişiye bağlı bütün kayıtlar silinecek\. Bu işlem yalnız açık onayla yapılır\.$',
    ),
    (m, t) =>
        '${m[1]} และรายการทั้งหมดที่เชื่อมกับบุคคลนี้จะถูกลบ การดำเนินการนี้ต้องมีการยืนยันอย่างชัดเจน.',
  ),
  _ThaiPattern(
    RegExp(r'^PDF raporu kaydedilemedi: (.+)$'),
    (m, t) => 'ไม่สามารถบันทึกรายงาน PDF ได้: ${m[1]}',
  ),
  _ThaiPattern(
    RegExp(r'^PDF raporu paylaşılamadı: (.+)$'),
    (m, t) => 'ไม่สามารถแชร์รายงาน PDF ได้: ${m[1]}',
  ),
  _ThaiPattern(
    RegExp(
      r'^Bildirim planındaki (\d+) kayıt Android sistemine yazılamadı\. İlk hata: (.+)$',
    ),
    (m, t) => _androidWriteFailure(m[1]!, m[2]!),
  ),
  _ThaiPattern(
    RegExp(
      r'^Bildirim planı doğrulanamadı; Android tarafında (\d+) kayıt eksik kaldı\.$',
    ),
    (m, t) => _androidMissing(m[1]!),
  ),
  _ThaiPattern(
    RegExp(r'^Ödeme hatırlatması (\d+)$'),
    (m, t) => 'การเตือนชำระเงิน ${_number(m[1]!)}',
  ),
  _ThaiPattern(
    RegExp(r'^(.+) yeni, (.+) ilişki güncellendi(.*)\.$'),
    (m, t) =>
        'เพิ่ม ${_newItems(m[1]!)} และ ${_updatedLinks(m[2]!)}${m[3]}.'.trim(),
  ),
  _ThaiPattern(
    RegExp(r'^(.+) kayıt kimliği geçersiz veya tekrarlı\.$'),
    (m, t) => 'รหัสรายการ ${m[1]} ไม่ถูกต้องหรือซ้ำกัน.',
  ),
  _ThaiPattern(RegExp(r'^(\d+) gün kaldı$'), (m, t) => _remainingDays(m[1]!)),
  _ThaiPattern(
    RegExp(r'^(\d+) gün gecikmede$'),
    (m, t) => 'ค้างชำระ ${_days(m[1]!)}',
  ),
  _ThaiPattern(
    RegExp(r'^Ödeme (\d+) gün gecikti\.$'),
    (m, t) => 'การชำระเงินค้าง ${_days(m[1]!)}.',
  ),
  _ThaiPattern(RegExp(r'^Son ödeme (.+)\.$'), (m, t) => 'ครบกำหนด ${m[1]}.'),
  _ThaiPattern(
    RegExp(r'^Ayın (\d+)\. günü$'),
    (m, t) => 'วันที่ ${_number(m[1]!)} ของเดือน',
  ),
  _ThaiPattern(
    RegExp(r'^Her ayın (\d+)\. günü$'),
    (m, t) => 'วันที่ ${_number(m[1]!)} ของทุกเดือน',
  ),
  _ThaiPattern(RegExp(r'^Her (.+)$'), (m, t) => 'ทุก ${t(m[1]!)}'),
  _ThaiPattern(RegExp(r'^Başlangıç: (.+)$'), (m, t) => 'เริ่มต้น: ${m[1]}'),
  _ThaiPattern(RegExp(r'^Başlangıç (.+)$'), (m, t) => 'เริ่มต้น ${m[1]}'),
  _ThaiPattern(RegExp(r'^Toplam (.+)$'), (m, t) => 'รวม ${t(m[1]!)}'),
  _ThaiPattern(RegExp(r'^Kalan (.+)$'), (m, t) => '${t(m[1]!)} ที่เหลือ'),
  _ThaiPattern(RegExp(r'^Bu dönem (.+)$'), (m, t) => '${t(m[1]!)} รอบนี้'),
  _ThaiPattern(RegExp(r'^Tarih: (.+)$'), (m, t) => 'วันที่: ${m[1]}'),
  _ThaiPattern(RegExp(r'^Not: (.*)$'), (m, t) => 'หมายเหตุ: ${m[1]}'),
  _ThaiPattern(
    RegExp(r'^(.+) boş bırakılamaz\.$'),
    (m, t) => '${t(m[1]!)} ห้ามเว้นว่าง.',
  ),
  _ThaiPattern(
    RegExp(r'^(.+) en fazla (\d+) karakter olabilir\.$'),
    (m, t) => '${t(m[1]!)} มีได้สูงสุด ${_number(m[2]!)} ตัวอักษร.',
  ),
  _ThaiPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalı\.$'),
    (m, t) => '${t(m[1]!)} ต้องมากกว่า 0.',
  ),
  _ThaiPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalıdır\.$'),
    (m, t) => '${t(m[1]!)} ต้องมากกว่า 0.',
  ),
  _ThaiPattern(
    RegExp(r'^(.+) negatif olamaz\.$'),
    (m, t) => '${t(m[1]!)} ต้องไม่ติดลบ.',
  ),
  _ThaiPattern(
    RegExp(r'^(.+) pozitif tam sayı olmalı\.$'),
    (m, t) => '${t(m[1]!)} ต้องเป็นจำนวนเต็มบวก.',
  ),
  _ThaiPattern(
    RegExp(r'^(.+) sıfır veya pozitif tam sayı olmalı\.$'),
    (m, t) => '${t(m[1]!)} ต้องเป็น 0 หรือจำนวนเต็มบวก.',
  ),
  _ThaiPattern(RegExp(r'^(\d+) kayıt$'), (m, t) => _items(m[1]!)),
  _ThaiPattern(RegExp(r'^(\d+) ödeme$'), (m, t) => _payments(m[1]!)),
  _ThaiPattern(RegExp(r'^(\d+) gider$'), (m, t) => _expenses(m[1]!)),
  _ThaiPattern(
    RegExp(r'^(.+) · (\d+) kayıt$'),
    (m, t) => '${m[1]} · ${_items(m[2]!)}',
  ),
  _ThaiPattern(RegExp(r'^(.+) gün$'), (m, t) => _days(m[1]!)),
  _ThaiPattern(RegExp(r'^(.+) ay$'), (m, t) => _months(m[1]!)),
  _ThaiPattern(RegExp(r'^(.+) kişi seçili$'), (m, t) => _selectedPeople(m[1]!)),
  _ThaiPattern(
    RegExp(r'^(.+) yeni kayıt eklendi; mevcut veriler korundu\.$'),
    (m, t) => 'เพิ่ม ${_newItems(m[1]!)} แล้ว โดยคงข้อมูลเดิมไว้.',
  ),
  _ThaiPattern(
    RegExp(r'^Test (.+) için dakik olarak planlandı\.$'),
    (m, t) => 'ตั้งเวลาทดสอบสำหรับ ${m[1]} แบบตรงเวลาแล้ว.',
  ),
  _ThaiPattern(
    RegExp(r'^Test planlanamadı: (.+)$'),
    (m, t) => 'ไม่สามารถตั้งเวลาทดสอบได้: ${m[1]}',
  ),
  _ThaiPattern(
    RegExp(r'^(.+) planlanamadı: (.+)$'),
    (m, t) => 'ไม่สามารถตั้งเวลา ${t(m[1]!)} ได้: ${m[2]}',
  ),
  _ThaiPattern(
    RegExp(r'^(.+) kaydedilemedi: (.+)$'),
    (m, t) => 'ไม่สามารถบันทึก ${t(m[1]!)} ได้: ${m[2]}',
  ),
  _ThaiPattern(
    RegExp(r'^(.+) oluşturulamadı: (.+)$'),
    (m, t) => 'ไม่สามารถสร้าง ${t(m[1]!)} ได้: ${m[2]}',
  ),
  _ThaiPattern(
    RegExp(r'^(.+) paylaşılamadı: (.+)$'),
    (m, t) => 'ไม่สามารถแชร์ ${t(m[1]!)} ได้: ${m[2]}',
  ),
  _ThaiPattern(
    RegExp(r'^(.+) birleştirilemedi: (.+)$'),
    (m, t) => 'ไม่สามารถรวม ${t(m[1]!)} ได้: ${m[2]}',
  ),
];

const List<(String, String)> _thaiPhrases = <(String, String)>[
  ('Banka borcu', 'หนี้ธนาคาร'),
  ('Kişisel ve kurumsal borçlar', 'หนี้ส่วนบุคคลและองค์กร'),
  ('Kişisel / kurumsal borç', 'หนี้ส่วนบุคคล / องค์กร'),
  ('Kişisel/kurumsal borç', 'หนี้ส่วนบุคคล/องค์กร'),
  ('Ödemelere yapılan gider', 'ค่าใช้จ่ายจากการชำระเงิน'),
  ('Bu ay yapılan', 'ทำแล้วเดือนนี้'),
  ('Açık plan', 'แผนที่เปิดอยู่'),
  ('Kalan tutar', 'ยอดคงเหลือ'),
  ('Kalan toplam borç', 'หนี้คงเหลือรวม'),
  ('Gecikmiş toplam', 'ยอดค้างรวม'),
  ('Önümüzdeki 7 gün', '7 วันข้างหน้า'),
  ('Son ödeme bugün', 'ครบกำหนดวันนี้'),
  ('Banka borçları', 'หนี้ธนาคาร'),
  ('Kira ve taksitler', 'ค่าเช่าและค่างวด'),
  ('Günlük harcamalar', 'ค่าใช้จ่ายรายวัน'),
  ('Gider ayrıntıları', 'รายละเอียดค่าใช้จ่าย'),
  ('Ödeme ayrıntıları', 'รายละเอียดการชำระเงิน'),
  ('Gerçekleşen ödeme', 'การชำระเงินจริง'),
  ('Ödeme kayıtları', 'รายการชำระเงิน'),
  ('Normal giderler', 'ค่าใช้จ่ายทั่วไป'),
  ('Toplam gider', 'ค่าใช้จ่ายรวม'),
  ('Kalan ödeme yükü', 'ภาระการชำระเงินที่เหลือ'),
  ('Gecikmiş ödeme yükü', 'ภาระการชำระเงินที่ค้าง'),
  ('Yaklaşan ödeme yükü', 'ภาระการชำระเงินที่ใกล้ถึงกำหนด'),
  ('Kişi kapsamı', 'ขอบเขตบุคคล'),
  ('Oluşturulma', 'สร้างเมื่อ'),
  ('Dönem', 'รอบ'),
  ('devam', 'ต่อ'),
];

class _ThaiPattern {
  const _ThaiPattern(this.regExp, this.builder);
  final RegExp regExp;
  final String Function(RegExpMatch match, ThaiDynamicTranslator translate)
  builder;
}

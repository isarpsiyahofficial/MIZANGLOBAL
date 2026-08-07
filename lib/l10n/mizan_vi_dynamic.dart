typedef VietnameseDynamicTranslator = String Function(String source);

String translateVietnameseReviewedDynamic(
  String source,
  VietnameseDynamicTranslator translate,
) {
  for (final pattern in _vietnamesePatterns) {
    final match = pattern.regExp.firstMatch(source);
    if (match != null) return pattern.builder(match, translate);
  }
  var value = source;
  for (final entry in _vietnamesePhrases) {
    value = value.replaceAll(entry.$1, entry.$2);
  }
  return value;
}

int _number(String value) => int.tryParse(value) ?? 0;
String _days(String value) => '${_number(value)} ngày';
String _items(String value) => '${_number(value)} bản ghi';
String _openItems(String value) => '${_number(value)} bản ghi đang mở';
String _payments(String value) => '${_number(value)} khoản thanh toán';
String _expenses(String value) => '${_number(value)} khoản chi';
String _months(String value) => '${_number(value)} tháng';
String _selectedPeople(String value) => switch (_number(value)) {
  0 => 'Chưa chọn người nào',
  1 => 'Đã chọn 1 người',
  _ => 'Đã chọn ${_number(value)} người',
};
String _remaining(String value) => 'còn ${_number(value)}';
String _remainingDays(String value) => switch (_number(value)) {
  0 => 'Đến hạn hôm nay',
  1 => 'Còn 1 ngày',
  _ => 'Còn ${_number(value)} ngày',
};
String _remainingInstallments(String value) => switch (_number(value)) {
  0 => 'Không còn kỳ trả góp',
  1 => 'Còn 1 kỳ trả góp',
  _ => 'Còn ${_number(value)} kỳ trả góp',
};
String _dailyExpenses(String value) => '${_number(value)} khoản chi hằng ngày';
String _expenseRecords(String value) => '${_number(value)} bản ghi chi tiêu';
String _newItems(String value) => '${_number(value)} bản ghi mới';
String _updatedLinks(String value) => '${_number(value)} liên kết được cập nhật';
String _androidWriteFailure(String value, String error) =>
    'Không thể ghi ${_items(value)} trong lịch thông báo vào hệ thống Android. Lỗi đầu tiên: $error';
String _androidMissing(String value) =>
    'Không thể xác minh lịch thông báo; thiếu ${_items(value)} ở phía Android.';

final List<_VietnamesePattern> _vietnamesePatterns = <_VietnamesePattern>[
  _VietnamesePattern(
    RegExp(r'^MİZAN (.+) Raporu$'),
    (m, t) => 'Báo cáo ${t(m[1]!)} MİZAN',
  ),
  _VietnamesePattern(
    RegExp(r'^(.+) finans raporu$'),
    (m, t) => 'Báo cáo tài chính ${m[1]}',
  ),
  _VietnamesePattern(
    RegExp(r'^LEFFERION PRIME - MİZAN · Sayfa (\d+)$'),
    (m, t) => 'LEFFERION PRIME - MİZAN · Trang ${_number(m[1]!)}',
  ),
  _VietnamesePattern(
    RegExp(r'^(.+) · devam$'),
    (m, t) => '${t(m[1]!)} · tiếp',
  ),
  _VietnamesePattern(RegExp(r'^Dönem: (.+)$'), (m, t) => 'Kỳ: ${m[1]}'),
  _VietnamesePattern(
    RegExp(r'^Kişi kapsamı: (.+)$'),
    (m, t) => 'Phạm vi người: ${t(m[1]!)}',
  ),
  _VietnamesePattern(
    RegExp(r'^Oluşturulma: (.+)$'),
    (m, t) => 'Được tạo: ${m[1]}',
  ),
  _VietnamesePattern(
    RegExp(r'^Açık plan (.+) · Bu ay yapılan (.+)$'),
    (m, t) => 'Kế hoạch đang mở ${m[1]} · Đã thực hiện tháng này ${m[2]}',
  ),
  _VietnamesePattern(
    RegExp(r'^(.+) Ödeme Durumu$'),
    (m, t) => 'Trạng thái thanh toán ${m[1]}',
  ),
  _VietnamesePattern(
    RegExp(r'^(\d+) açık kayıt · (.+)$'),
    (m, t) => '${_openItems(m[1]!)} · ${m[2]}',
  ),
  _VietnamesePattern(
    RegExp(r'^(\d+) günlük harcama · (\d+) ödeme$'),
    (m, t) => '${_dailyExpenses(m[1]!)} · ${_payments(m[2]!)}',
  ),
  _VietnamesePattern(
    RegExp(r'^(\d+) gün · (\d+) kayıt · (.+)$'),
    (m, t) => '${_days(m[1]!)} · ${_items(m[2]!)} · ${m[3]}',
  ),
  _VietnamesePattern(
    RegExp(r'^(\d+) ödeme · (.+)$'),
    (m, t) => '${_payments(m[1]!)} · ${m[2]}',
  ),
  _VietnamesePattern(
    RegExp(r'^(\d+) gider · (.+)$'),
    (m, t) => '${_expenses(m[1]!)} · ${m[2]}',
  ),
  _VietnamesePattern(
    RegExp(r'^(\d+) gider kaydı$'),
    (m, t) => _expenseRecords(m[1]!),
  ),
  _VietnamesePattern(
    RegExp(r'^Daha fazla gün göster \((\d+) kaldı\)$'),
    (m, t) => 'Hiển thị thêm ngày (${_remaining(m[1]!)})',
  ),
  _VietnamesePattern(
    RegExp(r'^Daha fazla ödeme günü göster \((\d+) kaldı\)$'),
    (m, t) => 'Hiển thị thêm ngày thanh toán (${_remaining(m[1]!)})',
  ),
  _VietnamesePattern(
    RegExp(r'^Daha fazla gider günü göster \((\d+) kaldı\)$'),
    (m, t) => 'Hiển thị thêm ngày có chi tiêu (${_remaining(m[1]!)})',
  ),
  _VietnamesePattern(
    RegExp(r'^Bu günden daha fazla göster \((\d+) kaldı\)$'),
    (m, t) => 'Hiển thị thêm bản ghi của ngày này (${_remaining(m[1]!)})',
  ),
  _VietnamesePattern(
    RegExp(r'^(.+) için (\d+) gün kaldı$'),
    (m, t) => '${_remainingDays(m[2]!)} đến ${m[1]}',
  ),
  _VietnamesePattern(
    RegExp(r'^(.+) bugün bekleniyor$'),
    (m, t) => '${m[1]} dự kiến nhận hôm nay',
  ),
  _VietnamesePattern(
    RegExp(r'^(.+) (\d+) gün gecikti$'),
    (m, t) => '${m[1]} đã quá hạn ${_days(m[2]!)}',
  ),
  _VietnamesePattern(
    RegExp(r'^Son alındı: (.+) · Planlanan (.+)$'),
    (m, t) => 'Lần nhận gần nhất: ${m[1]} · Dự kiến: ${m[2]}',
  ),
  _VietnamesePattern(
    RegExp(r'^Planlanan (.+) dönemi, (.+) tarihinde alındı olarak kaydedildi\. Sabit yatış günü değişmedi\.$'),
    (m, t) =>
        'Kỳ ${m[1]} theo kế hoạch đã được ghi nhận là đã nhận vào ${m[2]}. Ngày nhận cố định không thay đổi.',
  ),
  _VietnamesePattern(
    RegExp(r'^(.+) gerçek fatura tutarı$'),
    (m, t) => 'Số tiền hóa đơn thực tế ${m[1]}',
  ),
  _VietnamesePattern(
    RegExp(r'^Kalan tutar: (.+)$'),
    (m, t) => 'Số tiền còn lại: ${m[1]}',
  ),
  _VietnamesePattern(
    RegExp(r'^Kalan taksit: (\d+)$'),
    (m, t) => _remainingInstallments(m[1]!),
  ),
  _VietnamesePattern(
    RegExp(r'^(.+) gider kaydı silinsin mi\?$'),
    (m, t) => 'Xóa bản ghi chi tiêu ${m[1]}?',
  ),
  _VietnamesePattern(
    RegExp(r'^(.+) kategorisi ve yalnız bu kategoriye bağlı giderler silinecek\.$'),
    (m, t) =>
        'Danh mục ${m[1]} và chỉ các khoản chi liên kết với danh mục này sẽ bị xóa.',
  ),
  _VietnamesePattern(
    RegExp(r'^(.+) ve bu kişiye bağlı bütün kayıtlar silinecek\. Bu işlem yalnız açık onayla yapılır\.$'),
    (m, t) =>
        '${m[1]} và toàn bộ bản ghi gắn với người này sẽ bị xóa. Thao tác này cần xác nhận rõ ràng.',
  ),
  _VietnamesePattern(
    RegExp(r'^PDF raporu kaydedilemedi: (.+)$'),
    (m, t) => 'Không thể lưu báo cáo PDF: ${m[1]}',
  ),
  _VietnamesePattern(
    RegExp(r'^PDF raporu paylaşılamadı: (.+)$'),
    (m, t) => 'Không thể chia sẻ báo cáo PDF: ${m[1]}',
  ),
  _VietnamesePattern(
    RegExp(r'^Bildirim planındaki (\d+) kayıt Android sistemine yazılamadı\. İlk hata: (.+)$'),
    (m, t) => _androidWriteFailure(m[1]!, m[2]!),
  ),
  _VietnamesePattern(
    RegExp(r'^Bildirim planı doğrulanamadı; Android tarafında (\d+) kayıt eksik kaldı\.$'),
    (m, t) => _androidMissing(m[1]!),
  ),
  _VietnamesePattern(
    RegExp(r'^Ödeme hatırlatması (\d+)$'),
    (m, t) => 'Lời nhắc thanh toán ${_number(m[1]!)}',
  ),
  _VietnamesePattern(
    RegExp(r'^(.+) yeni, (.+) ilişki güncellendi(.*)\.$'),
    (m, t) => 'Đã thêm ${_newItems(m[1]!)} và ${_updatedLinks(m[2]!)}${m[3]}.',
  ),
  _VietnamesePattern(
    RegExp(r'^(.+) kayıt kimliği geçersiz veya tekrarlı\.$'),
    (m, t) => 'Mã bản ghi ${m[1]} không hợp lệ hoặc bị trùng.',
  ),
  _VietnamesePattern(RegExp(r'^(\d+) gün kaldı$'), (m, t) => _remainingDays(m[1]!)),
  _VietnamesePattern(
    RegExp(r'^(\d+) gün gecikmede$'),
    (m, t) => 'Quá hạn ${_days(m[1]!)}',
  ),
  _VietnamesePattern(
    RegExp(r'^Ödeme (\d+) gün gecikti\.$'),
    (m, t) => 'Khoản thanh toán đã quá hạn ${_days(m[1]!)}.',
  ),
  _VietnamesePattern(
    RegExp(r'^Son ödeme (.+)\.$'),
    (m, t) => 'Đến hạn ${m[1]}.',
  ),
  _VietnamesePattern(
    RegExp(r'^Ayın (\d+)\. günü$'),
    (m, t) => 'Ngày ${_number(m[1]!)} của tháng',
  ),
  _VietnamesePattern(
    RegExp(r'^Her ayın (\d+)\. günü$'),
    (m, t) => 'Ngày ${_number(m[1]!)} hằng tháng',
  ),
  _VietnamesePattern(RegExp(r'^Her (.+)$'), (m, t) => 'Mỗi ${t(m[1]!)}'),
  _VietnamesePattern(RegExp(r'^Başlangıç: (.+)$'), (m, t) => 'Bắt đầu: ${m[1]}'),
  _VietnamesePattern(RegExp(r'^Başlangıç (.+)$'), (m, t) => 'Bắt đầu ${m[1]}'),
  _VietnamesePattern(RegExp(r'^Toplam (.+)$'), (m, t) => 'Tổng ${t(m[1]!)}'),
  _VietnamesePattern(RegExp(r'^Kalan (.+)$'), (m, t) => '${t(m[1]!)} còn lại'),
  _VietnamesePattern(
    RegExp(r'^Bu dönem (.+)$'),
    (m, t) => '${t(m[1]!)} trong kỳ này',
  ),
  _VietnamesePattern(RegExp(r'^Tarih: (.+)$'), (m, t) => 'Ngày: ${m[1]}'),
  _VietnamesePattern(RegExp(r'^Not: (.*)$'), (m, t) => 'Ghi chú: ${m[1]}'),
  _VietnamesePattern(
    RegExp(r'^(.+) boş bırakılamaz\.$'),
    (m, t) => '${t(m[1]!)} không được để trống.',
  ),
  _VietnamesePattern(
    RegExp(r'^(.+) en fazla (\d+) karakter olabilir\.$'),
    (m, t) => '${t(m[1]!)} được tối đa ${_number(m[2]!)} ký tự.',
  ),
  _VietnamesePattern(
    RegExp(r'^(.+) sıfırdan büyük olmalı\.$'),
    (m, t) => '${t(m[1]!)} phải lớn hơn 0.',
  ),
  _VietnamesePattern(
    RegExp(r'^(.+) sıfırdan büyük olmalıdır\.$'),
    (m, t) => '${t(m[1]!)} phải lớn hơn 0.',
  ),
  _VietnamesePattern(
    RegExp(r'^(.+) negatif olamaz\.$'),
    (m, t) => '${t(m[1]!)} không được âm.',
  ),
  _VietnamesePattern(
    RegExp(r'^(.+) pozitif tam sayı olmalı\.$'),
    (m, t) => '${t(m[1]!)} phải là số nguyên dương.',
  ),
  _VietnamesePattern(
    RegExp(r'^(.+) sıfır veya pozitif tam sayı olmalı\.$'),
    (m, t) => '${t(m[1]!)} phải là 0 hoặc số nguyên dương.',
  ),
  _VietnamesePattern(RegExp(r'^(\d+) kayıt$'), (m, t) => _items(m[1]!)),
  _VietnamesePattern(RegExp(r'^(\d+) ödeme$'), (m, t) => _payments(m[1]!)),
  _VietnamesePattern(RegExp(r'^(\d+) gider$'), (m, t) => _expenses(m[1]!)),
  _VietnamesePattern(
    RegExp(r'^(.+) · (\d+) kayıt$'),
    (m, t) => '${m[1]} · ${_items(m[2]!)}',
  ),
  _VietnamesePattern(RegExp(r'^(.+) gün$'), (m, t) => _days(m[1]!)),
  _VietnamesePattern(RegExp(r'^(.+) ay$'), (m, t) => _months(m[1]!)),
  _VietnamesePattern(
    RegExp(r'^(.+) kişi seçili$'),
    (m, t) => _selectedPeople(m[1]!),
  ),
  _VietnamesePattern(
    RegExp(r'^(.+) yeni kayıt eklendi; mevcut veriler korundu\.$'),
    (m, t) => 'Đã thêm ${_newItems(m[1]!)}; dữ liệu hiện có vẫn được giữ nguyên.',
  ),
  _VietnamesePattern(
    RegExp(r'^Test (.+) için dakik olarak planlandı\.$'),
    (m, t) => 'Bài thử cho ${m[1]} đã được lên lịch chính xác.',
  ),
  _VietnamesePattern(
    RegExp(r'^Test planlanamadı: (.+)$'),
    (m, t) => 'Không thể lên lịch bài thử: ${m[1]}',
  ),
  _VietnamesePattern(
    RegExp(r'^(.+) planlanamadı: (.+)$'),
    (m, t) => 'Không thể lên lịch ${t(m[1]!)}: ${m[2]}',
  ),
  _VietnamesePattern(
    RegExp(r'^(.+) kaydedilemedi: (.+)$'),
    (m, t) => 'Không thể lưu ${t(m[1]!)}: ${m[2]}',
  ),
  _VietnamesePattern(
    RegExp(r'^(.+) oluşturulamadı: (.+)$'),
    (m, t) => 'Không thể tạo ${t(m[1]!)}: ${m[2]}',
  ),
  _VietnamesePattern(
    RegExp(r'^(.+) paylaşılamadı: (.+)$'),
    (m, t) => 'Không thể chia sẻ ${t(m[1]!)}: ${m[2]}',
  ),
  _VietnamesePattern(
    RegExp(r'^(.+) birleştirilemedi: (.+)$'),
    (m, t) => 'Không thể hợp nhất ${t(m[1]!)}: ${m[2]}',
  ),
];

const List<(String, String)> _vietnamesePhrases = <(String, String)>[
  ('Banka borcu', 'Nợ ngân hàng'),
  ('Kişisel ve kurumsal borçlar', 'Nợ cá nhân và doanh nghiệp'),
  ('Kişisel / kurumsal borç', 'Nợ cá nhân / doanh nghiệp'),
  ('Kişisel/kurumsal borç', 'Nợ cá nhân/doanh nghiệp'),
  ('Ödemelere yapılan gider', 'Chi cho các khoản thanh toán'),
  ('Bu ay yapılan', 'Đã thực hiện tháng này'),
  ('Açık plan', 'Kế hoạch đang mở'),
  ('Kalan tutar', 'Số tiền còn lại'),
  ('Kalan toplam borç', 'Tổng nợ còn lại'),
  ('Gecikmiş toplam', 'Tổng quá hạn'),
  ('Önümüzdeki 7 gün', '7 ngày tới'),
  ('Son ödeme bugün', 'Đến hạn hôm nay'),
  ('Banka borçları', 'Nợ ngân hàng'),
  ('Kira ve taksitler', 'Tiền thuê và trả góp'),
  ('Günlük harcamalar', 'Chi tiêu hằng ngày'),
  ('Gider ayrıntıları', 'Chi tiết chi tiêu'),
  ('Ödeme ayrıntıları', 'Chi tiết thanh toán'),
  ('Gerçekleşen ödeme', 'Thanh toán thực tế'),
  ('Ödeme kayıtları', 'Các bản ghi thanh toán'),
  ('Normal giderler', 'Chi tiêu thông thường'),
  ('Toplam gider', 'Tổng chi tiêu'),
  ('Kalan ödeme yükü', 'Nghĩa vụ thanh toán còn lại'),
  ('Gecikmiş ödeme yükü', 'Nghĩa vụ thanh toán quá hạn'),
  ('Yaklaşan ödeme yükü', 'Nghĩa vụ thanh toán sắp đến hạn'),
  ('Kişi kapsamı', 'Phạm vi người'),
  ('Oluşturulma', 'Được tạo'),
  ('Dönem', 'Kỳ'),
  ('devam', 'tiếp'),
];

class _VietnamesePattern {
  const _VietnamesePattern(this.regExp, this.builder);
  final RegExp regExp;
  final String Function(RegExpMatch match, VietnameseDynamicTranslator translate)
      builder;
}

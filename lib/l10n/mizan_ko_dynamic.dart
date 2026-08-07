typedef KoreanDynamicTranslator = String Function(String source);

String translateKoreanReviewedDynamic(String source,KoreanDynamicTranslator translate){
  for(final pattern in _patterns){final match=pattern.regExp.firstMatch(source);if(match!=null)return pattern.builder(match,translate);}var value=source;for(final entry in _phrases)value=value.replaceAll(entry.$1,entry.$2);return value;
}
int _n(String v)=>int.tryParse(v)??0;
String _days(String v)=>'${_n(v)}일';
String _items(String v)=>'${_n(v)}건';
String _open(String v)=>'미납 ${_n(v)}건';
String _payments(String v)=>'납부 ${_n(v)}건';
String _expenses(String v)=>'지출 ${_n(v)}건';
String _months(String v)=>'${_n(v)}개월';
String _selectedPeople(String v)=>_n(v)==0?'선택한 사람 없음':'${_n(v)}명 선택';
String _remaining(String v)=>'${_n(v)}건 남음';
String _remainingDays(String v)=>switch(_n(v)){0=>'오늘 납부 기한',_=>'${_n(v)}일 남음'};
String _installments(String v)=>switch(_n(v)){0=>'남은 할부 없음',_=>'할부 ${_n(v)}회 남음'};
String _daily(String v)=>'일일 지출 ${_n(v)}건';
String _expenseRecords(String v)=>'지출 기록 ${_n(v)}건';
String _newItems(String v)=>'새 기록 ${_n(v)}건';
String _updated(String v)=>'연결 관계 ${_n(v)}건 업데이트';

final List<_KoreanPattern> _patterns=< _KoreanPattern>[
  _KoreanPattern(RegExp(r'^MİZAN (.+) Raporu$'),(m,t)=>'MİZAN ${t(m[1]!)} 보고서'),
  _KoreanPattern(RegExp(r'^(.+) finans raporu$'),(m,t)=>'${m[1]} 재무 보고서'),
  _KoreanPattern(RegExp(r'^LEFFERION PRIME - MİZAN · Sayfa (\d+)$'),(m,t)=>'LEFFERION PRIME - MİZAN · ${_n(m[1]!)}페이지'),
  _KoreanPattern(RegExp(r'^(.+) · devam$'),(m,t)=>'${t(m[1]!)} · 계속'),
  _KoreanPattern(RegExp(r'^Dönem: (.+)$'),(m,t)=>'기간: ${m[1]}'),
  _KoreanPattern(RegExp(r'^Kişi kapsamı: (.+)$'),(m,t)=>'사람 범위: ${t(m[1]!)}'),
  _KoreanPattern(RegExp(r'^Oluşturulma: (.+)$'),(m,t)=>'생성: ${m[1]}'),
  _KoreanPattern(RegExp(r'^Açık plan (.+) · Bu ay yapılan (.+)$'),(m,t)=>'미납 예정 ${m[1]} · 이번 달 납부 ${m[2]}'),
  _KoreanPattern(RegExp(r'^(.+) Ödeme Durumu$'),(m,t)=>'${m[1]} 납부 상태'),
  _KoreanPattern(RegExp(r'^(\d+) açık kayıt · (.+)$'),(m,t)=>'${_open(m[1]!)} · ${m[2]}'),
  _KoreanPattern(RegExp(r'^(\d+) günlük harcama · (\d+) ödeme$'),(m,t)=>'${_daily(m[1]!)} · ${_payments(m[2]!)}'),
  _KoreanPattern(RegExp(r'^(\d+) gün · (\d+) kayıt · (.+)$'),(m,t)=>'${_days(m[1]!)} · ${_items(m[2]!)} · ${m[3]}'),
  _KoreanPattern(RegExp(r'^(\d+) ödeme · (.+)$'),(m,t)=>'${_payments(m[1]!)} · ${m[2]}'),
  _KoreanPattern(RegExp(r'^(\d+) gider · (.+)$'),(m,t)=>'${_expenses(m[1]!)} · ${m[2]}'),
  _KoreanPattern(RegExp(r'^(\d+) gider kaydı$'),(m,t)=>_expenseRecords(m[1]!)),
  _KoreanPattern(RegExp(r'^Daha fazla gün göster \((\d+) kaldı\)$'),(m,t)=>'날짜 더 보기 (${_remaining(m[1]!)})'),
  _KoreanPattern(RegExp(r'^Daha fazla ödeme günü göster \((\d+) kaldı\)$'),(m,t)=>'납부 날짜 더 보기 (${_remaining(m[1]!)})'),
  _KoreanPattern(RegExp(r'^Daha fazla gider günü göster \((\d+) kaldı\)$'),(m,t)=>'지출 날짜 더 보기 (${_remaining(m[1]!)})'),
  _KoreanPattern(RegExp(r'^Bu günden daha fazla göster \((\d+) kaldı\)$'),(m,t)=>'이 날짜의 기록 더 보기 (${_remaining(m[1]!)})'),
  _KoreanPattern(RegExp(r'^(.+) için (\d+) gün kaldı$'),(m,t)=>'${m[1]}까지 ${_remainingDays(m[2]!)}'),
  _KoreanPattern(RegExp(r'^(.+) bugün bekleniyor$'),(m,t)=>'${m[1]} 오늘 입금 예정'),
  _KoreanPattern(RegExp(r'^(.+) (\d+) gün gecikti$'),(m,t)=>'${m[1]} ${_days(m[2]!)} 연체'),
  _KoreanPattern(RegExp(r'^Son alındı: (.+) · Planlanan (.+)$'),(m,t)=>'최근 수령: ${m[1]} · 예정: ${m[2]}'),
  _KoreanPattern(RegExp(r'^Planlanan (.+) dönemi, (.+) tarihinde alındı olarak kaydedildi\. Sabit yatış günü değişmedi\.$'),(m,t)=>'예정된 ${m[1]} 기간 수입을 ${m[2]}에 수령한 것으로 기록했습니다. 고정 입금일은 변경되지 않았습니다.'),
  _KoreanPattern(RegExp(r'^(.+) gerçek fatura tutarı$'),(m,t)=>'${m[1]} 실제 청구 금액'),
  _KoreanPattern(RegExp(r'^Kalan tutar: (.+)$'),(m,t)=>'잔액: ${m[1]}'),
  _KoreanPattern(RegExp(r'^Kalan taksit: (\d+)$'),(m,t)=>_installments(m[1]!)),
  _KoreanPattern(RegExp(r'^(.+) gider kaydı silinsin mi\?$'),(m,t)=>'${m[1]} 지출 기록을 삭제할까요?'),
  _KoreanPattern(RegExp(r'^(.+) kategorisi ve yalnız bu kategoriye bağlı giderler silinecek\.$'),(m,t)=>'${m[1]} 카테고리와 이 카테고리에만 연결된 지출이 삭제됩니다.'),
  _KoreanPattern(RegExp(r'^(.+) ve bu kişiye bağlı bütün kayıtlar silinecek\. Bu işlem yalnız açık onayla yapılır\.$'),(m,t)=>'${m[1]} 및 이 사람에게 연결된 모든 기록이 삭제됩니다. 이 작업은 명시적으로 확인한 경우에만 실행됩니다.'),
  _KoreanPattern(RegExp(r'^PDF raporu kaydedilemedi: (.+)$'),(m,t)=>'PDF 보고서를 저장할 수 없습니다: ${m[1]}'),
  _KoreanPattern(RegExp(r'^PDF raporu paylaşılamadı: (.+)$'),(m,t)=>'PDF 보고서를 공유할 수 없습니다: ${m[1]}'),
  _KoreanPattern(RegExp(r'^Bildirim planındaki (\d+) kayıt Android sistemine yazılamadı\. İlk hata: (.+)$'),(m,t)=>'알림 일정의 ${_items(m[1]!)}을 Android 시스템에 기록할 수 없습니다. 첫 오류: ${m[2]}'),
  _KoreanPattern(RegExp(r'^Bildirim planı doğrulanamadı; Android tarafında (\d+) kayıt eksik kaldı\.$'),(m,t)=>'알림 일정을 검증할 수 없습니다. Android에 ${_items(m[1]!)}이 누락되었습니다.'),
  _KoreanPattern(RegExp(r'^Ödeme hatırlatması (\d+)$'),(m,t)=>'납부 알림 ${_n(m[1]!)}'),
  _KoreanPattern(RegExp(r'^(.+) yeni, (.+) ilişki güncellendi(.*)\.$'),(m,t)=>'${_newItems(m[1]!)} 추가, ${_updated(m[2]!)}${m[3]}.'),
  _KoreanPattern(RegExp(r'^(.+) kayıt kimliği geçersiz veya tekrarlı\.$'),(m,t)=>'기록 ID ${m[1]}이 올바르지 않거나 중복되었습니다.'),
  _KoreanPattern(RegExp(r'^(\d+) gün kaldı$'),(m,t)=>_remainingDays(m[1]!)),
  _KoreanPattern(RegExp(r'^(\d+) gün gecikmede$'),(m,t)=>'${_days(m[1]!)} 연체'),
  _KoreanPattern(RegExp(r'^Ödeme (\d+) gün gecikti\.$'),(m,t)=>'납부가 ${_days(m[1]!)} 연체되었습니다.'),
  _KoreanPattern(RegExp(r'^Son ödeme (.+)\.$'),(m,t)=>'납부 기한 ${m[1]}.'),
  _KoreanPattern(RegExp(r'^Ayın (\d+)\. günü$'),(m,t)=>'매월 ${_n(m[1]!)}일'),
  _KoreanPattern(RegExp(r'^Her ayın (\d+)\. günü$'),(m,t)=>'매월 ${_n(m[1]!)}일'),
  _KoreanPattern(RegExp(r'^Her (.+)$'),(m,t)=>'매 ${t(m[1]!)}'),
  _KoreanPattern(RegExp(r'^Başlangıç: (.+)$'),(m,t)=>'시작: ${m[1]}'),
  _KoreanPattern(RegExp(r'^Başlangıç (.+)$'),(m,t)=>'시작 ${m[1]}'),
  _KoreanPattern(RegExp(r'^Toplam (.+)$'),(m,t)=>'총 ${t(m[1]!)}'),
  _KoreanPattern(RegExp(r'^Kalan (.+)$'),(m,t)=>'남은 ${t(m[1]!)}'),
  _KoreanPattern(RegExp(r'^Bu dönem (.+)$'),(m,t)=>'이번 기간 ${t(m[1]!)}'),
  _KoreanPattern(RegExp(r'^Tarih: (.+)$'),(m,t)=>'날짜: ${m[1]}'),
  _KoreanPattern(RegExp(r'^Not: (.*)$'),(m,t)=>'메모: ${m[1]}'),
  _KoreanPattern(RegExp(r'^(.+) boş bırakılamaz\.$'),(m,t)=>'${t(m[1]!)}은(는) 비워 둘 수 없습니다.'),
  _KoreanPattern(RegExp(r'^(.+) en fazla (\d+) karakter olabilir\.$'),(m,t)=>'${t(m[1]!)}은(는) 최대 ${_n(m[2]!)}자까지 입력할 수 있습니다.'),
  _KoreanPattern(RegExp(r'^(.+) sıfırdan büyük olmalı\.$'),(m,t)=>'${t(m[1]!)}은(는) 0보다 커야 합니다.'),
  _KoreanPattern(RegExp(r'^(.+) sıfırdan büyük olmalıdır\.$'),(m,t)=>'${t(m[1]!)}은(는) 0보다 커야 합니다.'),
  _KoreanPattern(RegExp(r'^(.+) negatif olamaz\.$'),(m,t)=>'${t(m[1]!)}은(는) 음수일 수 없습니다.'),
  _KoreanPattern(RegExp(r'^(.+) pozitif tam sayı olmalı\.$'),(m,t)=>'${t(m[1]!)}은(는) 양의 정수여야 합니다.'),
  _KoreanPattern(RegExp(r'^(.+) sıfır veya pozitif tam sayı olmalı\.$'),(m,t)=>'${t(m[1]!)}은(는) 0 또는 양의 정수여야 합니다.'),
  _KoreanPattern(RegExp(r'^(\d+) kayıt$'),(m,t)=>_items(m[1]!)),
  _KoreanPattern(RegExp(r'^(\d+) ödeme$'),(m,t)=>_payments(m[1]!)),
  _KoreanPattern(RegExp(r'^(\d+) gider$'),(m,t)=>_expenses(m[1]!)),
  _KoreanPattern(RegExp(r'^(.+) · (\d+) kayıt$'),(m,t)=>'${m[1]} · ${_items(m[2]!)}'),
  _KoreanPattern(RegExp(r'^(.+) gün$'),(m,t)=>_days(m[1]!)),
  _KoreanPattern(RegExp(r'^(.+) ay$'),(m,t)=>_months(m[1]!)),
  _KoreanPattern(RegExp(r'^(.+) kişi seçili$'),(m,t)=>_selectedPeople(m[1]!)),
  _KoreanPattern(RegExp(r'^(.+) yeni kayıt eklendi; mevcut veriler korundu\.$'),(m,t)=>'${_newItems(m[1]!)} 추가됨. 기존 데이터는 유지되었습니다.'),
  _KoreanPattern(RegExp(r'^Test (.+) için dakik olarak planlandı\.$'),(m,t)=>'${m[1]} 테스트가 정확한 시간으로 예약되었습니다.'),
  _KoreanPattern(RegExp(r'^Test planlanamadı: (.+)$'),(m,t)=>'테스트를 예약할 수 없습니다: ${m[1]}'),
  _KoreanPattern(RegExp(r'^(.+) planlanamadı: (.+)$'),(m,t)=>'${t(m[1]!)}을(를) 예약할 수 없습니다: ${m[2]}'),
  _KoreanPattern(RegExp(r'^(.+) kaydedilemedi: (.+)$'),(m,t)=>'${t(m[1]!)}을(를) 저장할 수 없습니다: ${m[2]}'),
  _KoreanPattern(RegExp(r'^(.+) oluşturulamadı: (.+)$'),(m,t)=>'${t(m[1]!)}을(를) 생성할 수 없습니다: ${m[2]}'),
  _KoreanPattern(RegExp(r'^(.+) paylaşılamadı: (.+)$'),(m,t)=>'${t(m[1]!)}을(를) 공유할 수 없습니다: ${m[2]}'),
  _KoreanPattern(RegExp(r'^(.+) birleştirilemedi: (.+)$'),(m,t)=>'${t(m[1]!)}을(를) 병합할 수 없습니다: ${m[2]}'),
];

const List<(String,String)> _phrases=< (String,String)>[
  ('Banka borcu','은행 부채'),('Kişisel ve kurumsal borçlar','개인 및 법인 부채'),('Kişisel / kurumsal borç','개인 / 법인 부채'),('Kişisel/kurumsal borç','개인/법인 부채'),
  ('Ödemelere yapılan gider','납부한 금액'),('Bu ay yapılan','이번 달 납부'),('Açık plan','미납 예정'),('Kalan tutar','잔액'),('Kalan toplam borç','총 잔여 부채'),('Gecikmiş toplam','총 연체액'),('Önümüzdeki 7 gün','향후 7일'),('Son ödeme bugün','오늘 납부 기한'),('Banka borçları','은행 부채'),('Kira ve taksitler','임대료 및 할부'),('Günlük harcamalar','일일 지출'),('Gider ayrıntıları','지출 상세'),('Ödeme ayrıntıları','납부 상세'),('Gerçekleşen ödeme','실제 납부'),('Ödeme kayıtları','납부 기록'),('Normal giderler','일반 지출'),('Toplam gider','총지출'),('Kalan ödeme yükü','남은 납부 부담'),('Gecikmiş ödeme yükü','연체 납부 부담'),('Yaklaşan ödeme yükü','다가오는 납부 부담'),('Kişi kapsamı','사람 범위'),('Oluşturulma','생성'),('Dönem','기간'),('devam','계속'),
];
class _KoreanPattern{const _KoreanPattern(this.regExp,this.builder);final RegExp regExp;final String Function(RegExpMatch,KoreanDynamicTranslator) builder;}

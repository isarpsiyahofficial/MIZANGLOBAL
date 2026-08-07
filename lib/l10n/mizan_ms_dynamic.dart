import 'mizan_id_dynamic.dart';
import 'mizan_ms.dart';

typedef MalayDynamicTranslator = String Function(String source);

String translateMalayReviewedDynamic(
  String source,
  MalayDynamicTranslator translate,
) {
  final indonesian = translateIndonesianReviewedDynamic(
    source,
    (value) => translate(value),
  );
  return malayFromIndonesian(indonesian)
      .replaceAll(' hari lagi', ' hari lagi')
      .replaceAll('Pembayaran tertunggak', 'Pembayaran tertunggak')
      .replaceAll('Tampilkan hari lainnya', 'Tunjukkan hari lain')
      .replaceAll('Halaman ', 'Halaman ')
      .replaceAll('tersisa', 'berbaki')
      .replaceAll('Tersisa', 'Berbaki');
}

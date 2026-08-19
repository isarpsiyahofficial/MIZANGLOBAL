import 'legal_document_focus.dart';
import 'legal_documents.dart';
import 'serverless_legal_overview.dart';

abstract final class LegalLocaleSummaries {
  static Set<String> get supportedLanguageTags =>
      ServerlessLegalOverview.supportedTags;

  static String overview(LegalDocumentType type, String languageTag) {
    final focus = LegalDocumentFocus.text(type, languageTag).trim();
    final common = ServerlessLegalOverview.text(languageTag).trim();
    return '$focus\n\n$common';
  }
}

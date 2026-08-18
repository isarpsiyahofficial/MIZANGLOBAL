import 'legal_documents.dart';
import 'serverless_legal_overview.dart';

abstract final class LegalLocaleSummaries {
  static Set<String> get supportedLanguageTags =>
      ServerlessLegalOverview.supportedTags;

  static String overview(LegalDocumentType type, String languageTag) {
    return ServerlessLegalOverview.text(languageTag);
  }
}

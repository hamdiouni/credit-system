/// Stub implementation for non-web platforms
Future<void> openHtmlInNewTab(String htmlContent) async {
  throw UnsupportedError('HTML PDF generation is only supported on web platform');
}

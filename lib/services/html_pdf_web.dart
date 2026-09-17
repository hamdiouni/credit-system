import 'dart:html' as html;

/// Web implementation for opening HTML in new tab
Future<void> openHtmlInNewTab(String htmlContent) async {
  // Create a blob from the HTML content
  final blob = html.Blob([htmlContent], 'text/html', 'native');
  final url = html.Url.createObjectUrlFromBlob(blob);
  
  // Open in new tab
  html.window.open(url, '_blank');
  
  // Clean up the URL after a delay
  Future.delayed(Duration(seconds: 1), () {
    html.Url.revokeObjectUrl(url);
  });
}

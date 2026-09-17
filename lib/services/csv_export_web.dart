// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';

/// Web implementation of CSV download
Future<void> downloadCsv(String csvContent, String filename) async {
  // Create blob with UTF-8 BOM for proper Excel compatibility
  final bytes = utf8.encode('\uFEFF$csvContent'); // BOM for UTF-8
  final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);
  
  // Create download link
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..style.display = 'none';
  
  // Trigger download
  html.document.body?.append(anchor);
  anchor.click();
  
  // Cleanup
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}

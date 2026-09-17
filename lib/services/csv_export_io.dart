import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Desktop/Mobile implementation for CSV export
Future<void> downloadCsv(String csvContent, String filename) async {
  try {
    // Get the downloads directory or documents directory
    Directory? directory;
    
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // For desktop, let user choose location
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save CSV File',
        fileName: filename,
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      
      if (result != null) {
        final file = File(result);
        await file.writeAsString(csvContent);
        print('✅ [CSV Export] File saved: $result');
      } else {
        print('⚠️ [CSV Export] User cancelled');
      }
    } else {
      // For mobile, save to downloads/documents
      directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(csvContent);
      print('✅ [CSV Export] File saved: ${file.path}');
    }
  } catch (e) {
    print('❌ [CSV Export] Error: $e');
    rethrow;
  }
}

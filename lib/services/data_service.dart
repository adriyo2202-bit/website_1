import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class DataService {
  static const String _fileName = 'main_data.json';

  /// Ensure the local file exists, copying from assets if it doesn't
  static Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_fileName');
    
    if (!await file.exists()) {
      // Copy from assets on first run
      final String jsonStr = await rootBundle.loadString('assets/data/$_fileName');
      await file.writeAsString(jsonStr);
    }
    
    return file;
  }

  /// Read the full JSON map
  static Future<Map<String, dynamic>> loadData() async {
    final file = await _getLocalFile();
    final jsonStr = await file.readAsString();
    return json.decode(jsonStr) as Map<String, dynamic>;
  }

  /// Write the full JSON map back to the local file
  static Future<void> saveData(Map<String, dynamic> data) async {
    final file = await _getLocalFile();
    final jsonStr = json.encode(data);
    await file.writeAsString(jsonStr);
  }

  /// Copy an image to the category's specific images folder
  static Future<String> saveImageForCategory(String categoryKey, File sourceImage) async {
    final dir = await getApplicationDocumentsDirectory();
    // Path structure: [Documents]/[categoryKey]/images/
    final categoryDir = Directory('${dir.path}/$categoryKey/images');
    
    if (!await categoryDir.exists()) {
      await categoryDir.create(recursive: true);
    }
    
    // Generate a unique filename using timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = sourceImage.path.split('.').last;
    final newPath = '${categoryDir.path}/$timestamp.$extension';
    
    await sourceImage.copy(newPath);
    return newPath;
  }
}

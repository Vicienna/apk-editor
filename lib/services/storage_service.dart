```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  late SharedPreferences _prefs;
  final _secureStorage = const FlutterSecureStorage();

  static const _patKey = 'github_pat';
  static const _repoKey = 'github_repo';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<Directory> getAppDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  Future<String?> getFirstFileInDir(String dirPath) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final entities = dir.listSync();
    for (var e in entities) {
      if (e is File && 
          (e.path.endsWith('.dart') ||
           e.path.endsWith('.js') ||
           e.path.endsWith('.ts') ||
           e.path.endsWith('.py') ||
           e.path.endsWith('.java') ||
           e.path.endsWith('.kt') ||
           e.path.endsWith('.cpp') ||
           e.path.endsWith('.c') ||
           e.path.endsWith('.html') ||
           e.path.endsWith('.css'))) {
        return e.path;
      }
    }
    return null;
  }

  String readFileSync(String path) {
    return File(path).readAsStringSync();
  }

  Future<String> readFile(String path) async {
    return await File(path).readAsString();
  }

  Future<void> writeFile(String path, String content) async {
    await File(path).writeAsString(content);
  }

  Future<void> setPat(String pat) async {
    await _prefs.setString(_patKey, pat);
  }

  Future<String?> getPat() async {
    return _prefs.getString(_patKey);
  }

  Future<void> setGitHubRepo(String repo) async {
    await _prefs.setString(_repoKey, repo);
  }

  Future<String?> getGitHubRepo() async {
    return _prefs.getString(_repoKey);
  }
}
```
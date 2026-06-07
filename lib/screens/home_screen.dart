import 'package:flutter/material.dart';
import 'package:code_editor_android/services/storage_service.dart';
import 'package:code_editor_android/services/github_service.dart';
import 'package:code_editor_android/widgets/file_explorer.dart';
import 'package:code_editor_android/widgets/editor_tab.dart';
import 'package:code_editor_android/widgets/settings_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final StorageService _storage;
  late final GithubService _github;
  String _currentFilePath = '';
  String _editorContent = '';

  @override
  void initState() {
    super.initState();
    _storage = StorageService();
    _github = GithubService();
    _initApp();
  }

  Future<void> _initApp() async {
    await _storage.init(); // Pastikan SharedPreferences siap
    await _loadInitialFile();
  }

  Future<void> _loadInitialFile() async {
    final dir = await _storage.getAppDocumentsDirectory();
    final firstFile = await _storage.getFirstFileInDir(dir.path);
    if (firstFile != null) {
      setState(() {
        _currentFilePath = firstFile;
        _editorContent = _storage.readFileSync(firstFile);
      });
    }
  }

  Future<void> _saveCurrentFile() async {
    if (_currentFilePath.isNotEmpty) {
      await _storage.writeFile(_currentFilePath, _editorContent);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File saved')),
      );
    }
  }

  Future<void> _pushToGitHub() async {
    final pat = await _storage.getPat();
    if (pat == null) {
      showDialog(
        context: context,
        builder: (_) => const SettingsDialog(),
      );
      return;
    }
    final repo = await _storage.getGitHubRepo();
    if (repo == null) {
      showDialog(
        context: context,
        builder: (_) => const SettingsDialog(),
      );
      return;
    }
    final success = await _github.uploadFile(
      pat: pat,
      repo: repo,
      path: _currentFilePath,
      content: _editorContent,
      message: 'Update ${_currentFilePath.split('/').last}',
    );
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pushed to GitHub')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to push')),
      );
    }
  }

  void _onFileSelected(String path) {
    setState(() {
      _currentFilePath = path;
      _editorContent = _storage.readFileSync(path);
    });
  }

  void _onContentChanged(String content) {
    setState(() {
      _editorContent = content;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Code Editor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveCurrentFile,
          ),
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            onPressed: _pushToGitHub,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const SettingsDialog(),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: FileExplorer(
              onFileSelected: _onFileSelected,
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 5,
            child: EditorTab(
              filePath: _currentFilePath,
              content: _editorContent,
              onContentChanged: _onContentChanged,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:code_editor_android/services/storage_service.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  final _patController = TextEditingController();
  final _repoController = TextEditingController();
  final _storage = StorageService();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final pat = await _storage.getPat();
    final repo = await _storage.getGitHubRepo();
    if (mounted) {
      setState(() {
        _patController.text = pat ?? '';
        _repoController.text = repo ?? '';
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _loading = true);
    await _storage.setPat(_patController.text.trim());
    await _storage.setGitHubRepo(_repoController.text.trim());
    setState(() => _loading = false);
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('GitHub Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _patController,
              decoration: const InputDecoration(
                labelText: 'Personal Access Token',
                hintText: 'ghp_...',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _repoController,
              decoration: const InputDecoration(
                labelText: 'Repository (owner/repo)',
                hintText: 'username/my-android-project',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _saveSettings,
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _patController.dispose();
    _repoController.dispose();
    super.dispose();
  }
}
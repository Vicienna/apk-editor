```dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:code_editor_android/services/storage_service.dart';

class FileExplorer extends StatelessWidget {
  final Function(String) onFileSelected;

  const FileExplorer({super.key, required this.onFileSelected});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FileSystemEntity>>(
      future: _getFiles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No files found'));
        }
        final files = snapshot.data!;
        return ListView.builder(
          itemCount: files.length,
          itemBuilder: (context, index) {
            final entity = files[index];
            final isFile = entity is File;
            return ListTile(
              leading: Icon(isFile ? Icons.insert_drive_file : Icons.folder),
              title: Text(entity.path.split(Platform.pathSeparator).last),
              onTap: isFile ? () => onFileSelected(entity.path) : null,
            );
          },
        );
      },
    );
  }

  Future<List<FileSystemEntity>> _getFiles() async {
    final dir = await StorageService().getAppDocumentsDirectory();
    return dir.listSync().toList();
  }
}
```
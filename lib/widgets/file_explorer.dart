import 'dart:io';
import 'package:flutter/material.dart';
import 'package:code_editor_android/services/storage_service.dart';

class FileExplorer extends StatelessWidget {
  final Function(String) onFileSelected;

  FileExplorer({super.key, required this.onFileSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: () => _showCreateFileDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('New File'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<FileSystemEntity>>(
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
                    trailing: isFile ? IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await entity.delete();
                      },
                    ) : null,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showCreateFileDialog(BuildContext context) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New File'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'filename.dart'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final dir = await StorageService().getAppDocumentsDirectory();
                final file = File('${dir.path}/$name');
                await file.writeAsString('');
                Navigator.pop(context);
              }
            }, 
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<List<FileSystemEntity>> _getFiles() async {
    final dir = await StorageService().getAppDocumentsDirectory();
    return dir.listSync().toList();
  }
}
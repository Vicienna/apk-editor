import 'package:flutter/material.dart';
import 'package:highlight/highlight.dart';

class EditorTab extends StatefulWidget {
  final String filePath;
  final String content;
  final Function(String) onContentChanged;

  const EditorTab({
    super.key,
    required this.filePath,
    required this.content,
    required this.onContentChanged,
  });

  @override
  State<EditorTab> createState() => _EditorTabState();
}

class _EditorTabState extends State<EditorTab> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.content);
    _controller.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    widget.onContentChanged(_controller.text);
  }

  @override
  void didUpdateWidget(covariant EditorTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      _controller.text = widget.content;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      child: Row(
        children: [
          Container(
            width: 40,
            color: Colors.black,
            child: ListView.builder(
              itemCount: (_controller.text.split('\n').length),
              itemBuilder: (context, index) {
                return Text(
                  '${index + 1}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                );
              },
            ),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(10),
              ),
              onChanged: (text) {
                _handleTextChange();
              },
            ),
          ),
        ],
      ),
    );
  }
}
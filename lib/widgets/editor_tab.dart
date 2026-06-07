import 'package:flutter/material.dart';
import 'package:highlight/highlight.dart';
import 'package:highlight/languages.dart';

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
          // Line Numbers
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
          // Code Area
          Expanded(
            child: Stack(
              children: [
                // Syntax Highlighting Layer (Read-only)
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(10),
                    child: _buildHighlightedText(),
                  ),
                ),
                // Input Layer (Transparent text)
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(
                    color: Colors.transparent, // Sembunyikan teks asli
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedText() {
    final code = _controller.text;
    final extension = widget.filePath.split('.').last;
    
    // Pilih bahasa berdasarkan ekstensi
    var language = highlight.languageDart;
    if (extension == 'js') language = highlight.languageJavaScript;
    if (extension == 'py') language = highlight.languagePython;
    if (extension == 'html') language = highlight.languageHtml;
    if (extension == 'css') language = highlight.languageCss;

    final highlighted = highlight.parse(code, language);
    
    return RichText(
      text: TextSpan(
        children: highlighted.elements.map((element) {
          return TextSpan(
            text: element.text,
            style: TextStyle(
              color: _getColorForStyle(element.style),
              fontFamily: 'monospace',
              fontSize: 14,
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getColorForStyle(highlight.Style style) {
    switch (style) {
      case highlight.Style.keyword: return Colors.orangeAccent;
      case highlight.Style.string: return Colors.greenAccent;
      case highlight.Style.comment: return Colors.grey;
      case highlight.Style.number: return Colors.lightBlueAccent;
      case highlight.Style.function: return Colors.yellowAccent;
      default: return Colors.white;
    }
  }
}
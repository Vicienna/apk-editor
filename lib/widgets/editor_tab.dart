import 'package:flutter/material.dart';

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
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(10),
                    child: _buildHighlightedText(),
                  ),
                ),
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(
                    color: Colors.transparent,
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
    final text = _controller.text;
    if (text.isEmpty) return const Text('');

    final List<TextSpan> spans = [];

    // FIXED: Menggunakan triple-quotes r'''...''' agar bebas konflik tanda kutip
    final pattern = RegExp(
      r'''(\s+)|(".*?"|'.*?')|(//.*)|(\b(if|else|for|while|return|class|def|function|import|export|var|let|const|async|await|try|catch|final|static|void|int|String|bool)\b)''',
      multiLine: true,
      dotAll: true,
    );

    text.splitMapJoin(
      pattern,
      onMatch: (Match match) {
        String matchText = match.group(0)!;
        Color color = Colors.white;

        if (match.group(2) != null) color = Colors.greenAccent;      // Strings
        else if (match.group(3) != null) color = Colors.grey;        // Comments
        else if (match.group(4) != null) color = Colors.orangeAccent; // Keywords

        spans.add(TextSpan(
          text: matchText,
          style: TextStyle(color: color, fontFamily: 'monospace', fontSize: 14),
        ));
        return '';
      },
      onNonMatch: (String nonMatch) {
        spans.add(TextSpan(
          text: nonMatch,
          style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 14),
        ));
        return '';
      },
    );

    return RichText(text: TextSpan(children: spans));
  }
}

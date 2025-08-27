import 'package:flutter/material.dart';

class CardEditorView extends StatefulWidget {
  final int? deckId;
  final int? cardId;
  
  const CardEditorView({
    Key? key,
    this.deckId,
    this.cardId,
  }) : super(key: key);

  @override
  State<CardEditorView> createState() => _CardEditorViewState();
}

class _CardEditorViewState extends State<CardEditorView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cardId == null ? '创建卡片' : '编辑卡片'),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: 保存卡片
            },
            child: const Text(
              '保存',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: const Center(
        child: Text('卡片编辑器页面 - 待实现'),
      ),
    );
  }
}
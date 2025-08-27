import 'package:flutter/material.dart';

class DeckDetailView extends StatefulWidget {
  final int deckId;
  
  const DeckDetailView({
    Key? key,
    this.deckId = 0,
  }) : super(key: key);

  @override
  State<DeckDetailView> createState() => _DeckDetailViewState();
}

class _DeckDetailViewState extends State<DeckDetailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('卡组详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: 编辑卡组
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: 更多选项
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('卡组详情页面 - 待实现'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 添加卡片
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
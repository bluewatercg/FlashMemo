import 'package:flutter/material.dart';

class CardBrowserView extends StatefulWidget {
  final int? deckId;
  
  const CardBrowserView({
    Key? key,
    this.deckId,
  }) : super(key: key);

  @override
  State<CardBrowserView> createState() => _CardBrowserViewState();
}

class _CardBrowserViewState extends State<CardBrowserView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('卡片浏览器'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 搜索卡片
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: 筛选卡片
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('卡片浏览器页面 - 待实现'),
      ),
    );
  }
}
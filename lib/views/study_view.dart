import 'package:flutter/material.dart';

class StudyView extends StatefulWidget {
  final int deckId;
  
  const StudyView({
    Key? key,
    required this.deckId,
  }) : super(key: key);

  @override
  State<StudyView> createState() => _StudyViewState();
}

class _StudyViewState extends State<StudyView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学习模式'),
        actions: [
          IconButton(
            icon: const Icon(Icons.pause),
            onPressed: () {
              // TODO: 暂停学习
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: 学习设置
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('学习页面 - 待实现'),
            SizedBox(height: 20),
            Text('这里将实现间隔重复学习算法'),
          ],
        ),
      ),
    );
  }
}
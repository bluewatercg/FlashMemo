import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/deck_controller.dart';
import '../constants/app_routes.dart';
import '../models/deck.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    // 初始化时加载卡组数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeckController>().loadDecks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlashMemo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 实现搜索功能
              _showSearchDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              AppRoutes.pushNamed(context, AppRoutes.settings);
            },
          ),
        ],
      ),
      body: Consumer<DeckController>(
        builder: (context, deckController, child) {
          if (deckController.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (deckController.decks.isEmpty) {
            return _buildEmptyState(context);
          }

          return _buildDeckList(context, deckController.decks);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateOptions(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.style,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '还没有卡组',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右下角的 + 按钮创建你的第一个卡组',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showCreateDeckDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('创建卡组'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeckList(BuildContext context, List<Deck> decks) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: decks.length,
      itemBuilder: (context, index) {
        final deck = decks[index];
        return _buildDeckCard(context, deck);
      },
    );
  }

  Widget _buildDeckCard(BuildContext context, Deck deck) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: deck.isFolder 
              ? Colors.orange 
              : Theme.of(context).primaryColor,
          child: Icon(
            deck.isFolder ? Icons.folder : Icons.style,
            color: Colors.white,
          ),
        ),
        title: Text(
          deck.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: deck.description != null
            ? Text(
                deck.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: deck.isFolder
            ? const Icon(Icons.arrow_forward_ios)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '0 卡片', // TODO: 从数据库获取实际卡片数量
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '0 待学习', // TODO: 从数据库获取待学习数量
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
        onTap: () {
          if (deck.isFolder) {
            // TODO: 展开文件夹
            _expandFolder(deck);
          } else {
            // 进入卡组详情页
            AppRoutes.pushNamed(
              context,
              AppRoutes.deckDetail,
              arguments: {'deckId': deck.id},
            );
          }
        },
        onLongPress: () => _showDeckOptions(context, deck),
      ),
    );
  }

  void _showCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.style),
                title: const Text('创建卡组'),
                onTap: () {
                  Navigator.pop(context);
                  _showCreateDeckDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('创建文件夹'),
                onTap: () {
                  Navigator.pop(context);
                  _showCreateFolderDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCreateDeckDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('创建新卡组'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '卡组名称',
                  hintText: '请输入卡组名称',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: '描述（可选）',
                  hintText: '请输入卡组描述',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  final deck = Deck(
                    name: nameController.text.trim(),
                    description: descController.text.trim().isEmpty 
                        ? null 
                        : descController.text.trim(),
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  
                  context.read<DeckController>().createDeck(deck);
                  Navigator.pop(context);
                }
              },
              child: const Text('创建'),
            ),
          ],
        );
      },
    );
  }

  void _showCreateFolderDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('创建新文件夹'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: '文件夹名称',
              hintText: '请输入文件夹名称',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  final folder = Deck(
                    name: nameController.text.trim(),
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                    isFolder: true,
                  );
                  
                  context.read<DeckController>().createDeck(folder);
                  Navigator.pop(context);
                }
              },
              child: const Text('创建'),
            ),
          ],
        );
      },
    );
  }

  void _showDeckOptions(BuildContext context, Deck deck) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('重命名'),
                onTap: () {
                  Navigator.pop(context);
                  _showRenameDeckDialog(context, deck);
                },
              ),
              if (!deck.isFolder) ...[
                ListTile(
                  leading: const Icon(Icons.play_arrow),
                  title: const Text('开始学习'),
                  onTap: () {
                    Navigator.pop(context);
                    AppRoutes.pushNamed(
                      context,
                      AppRoutes.study,
                      arguments: {'deckId': deck.id},
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('添加卡片'),
                  onTap: () {
                    Navigator.pop(context);
                    AppRoutes.pushNamed(
                      context,
                      AppRoutes.cardEditor,
                      arguments: {'deckId': deck.id},
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.view_list),
                  title: const Text('浏览卡片'),
                  onTap: () {
                    Navigator.pop(context);
                    AppRoutes.pushNamed(
                      context,
                      AppRoutes.cardBrowser,
                      arguments: {'deckId': deck.id},
                    );
                  },
                ),
              ],
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('删除', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmDialog(context, deck);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRenameDeckDialog(BuildContext context, Deck deck) {
    final nameController = TextEditingController(text: deck.name);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('重命名${deck.isFolder ? '文件夹' : '卡组'}'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: '名称',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty &&
                    nameController.text.trim() != deck.name) {
                  final updatedDeck = deck.copyWith(
                    name: nameController.text.trim(),
                    updatedAt: DateTime.now(),
                  );
                  
                  context.read<DeckController>().updateDeck(updatedDeck);
                  Navigator.pop(context);
                }
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, Deck deck) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('删除${deck.isFolder ? '文件夹' : '卡组'}'),
          content: Text(
            '确定要删除"${deck.name}"吗？${deck.isFolder ? '文件夹内的所有卡组也会被删除。' : '卡组内的所有卡片也会被删除。'}此操作无法撤销。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<DeckController>().deleteDeck(deck.id!);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('搜索'),
          content: const TextField(
            decoration: InputDecoration(
              labelText: '搜索卡组或卡片',
              hintText: '输入关键词...',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: 实现搜索功能
                Navigator.pop(context);
              },
              child: const Text('搜索'),
            ),
          ],
        );
      },
    );
  }

  void _expandFolder(Deck folder) {
    // TODO: 实现文件夹展开逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('展开文件夹：${folder.name}')),
    );
  }
}
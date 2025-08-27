import 'package:flutter/material.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text('学习设置'),
            subtitle: Text('配置学习相关选项'),
            leading: Icon(Icons.school),
          ),
          const Divider(),
          const ListTile(
            title: Text('数据管理'),
            subtitle: Text('备份、导入、导出数据'),
            leading: Icon(Icons.backup),
          ),
          const Divider(),
          const ListTile(
            title: Text('主题设置'),
            subtitle: Text('选择应用主题'),
            leading: Icon(Icons.palette),
          ),
          const Divider(),
          const ListTile(
            title: Text('关于'),
            subtitle: Text('应用信息和版本'),
            leading: Icon(Icons.info),
          ),
        ],
      ),
    );
  }
}
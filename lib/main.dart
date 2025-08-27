import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/database_service.dart';
import 'controllers/deck_controller.dart';
import 'controllers/card_controller.dart';
import 'views/home_view.dart';
import 'constants/app_theme.dart';
import 'constants/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化数据库
  await DatabaseService.instance.init();
  
  runApp(const FlashMemoApp());
}

class FlashMemoApp extends StatelessWidget {
  const FlashMemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DeckController()),
        ChangeNotifierProvider(create: (_) => CardController()),
      ],
      child: MaterialApp(
        title: 'FlashMemo - 智能闪记卡',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeView(),
        routes: AppRoutes.routes,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
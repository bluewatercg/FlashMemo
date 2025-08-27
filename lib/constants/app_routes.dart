import 'package:flutter/material.dart';
import '../views/home_view.dart';
import '../views/deck_detail_view.dart';
import '../views/card_editor_view.dart';
import '../views/card_browser_view.dart';
import '../views/study_view.dart';
import '../views/settings_view.dart';

class AppRoutes {
  static const String home = '/';
  static const String deckDetail = '/deck-detail';
  static const String cardEditor = '/card-editor';
  static const String cardBrowser = '/card-browser';
  static const String study = '/study';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const HomeView(),
      deckDetail: (context) => const DeckDetailView(),
      cardEditor: (context) => const CardEditorView(),
      cardBrowser: (context) => const CardBrowserView(),
      study: (context) => const StudyView(),
      settings: (context) => const SettingsView(),
    };
  }

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (context) => const HomeView());
      
      case deckDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => DeckDetailView(
            deckId: args?['deckId'] as int? ?? 0,
          ),
        );
      
      case cardEditor:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => CardEditorView(
            deckId: args?['deckId'] as int?,
            cardId: args?['cardId'] as int?,
          ),
        );
      
      case cardBrowser:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => CardBrowserView(
            deckId: args?['deckId'] as int?,
          ),
        );
      
      case study:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => StudyView(
            deckId: args?['deckId'] as int? ?? 0,
          ),
        );
      
      case settings:
        return MaterialPageRoute(builder: (context) => const SettingsView());
      
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('页面未找到')),
            body: const Center(
              child: Text('404 - 页面不存在'),
            ),
          ),
        );
    }
  }

  // 导航辅助方法
  static Future<T?> pushNamed<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  static Future<T?> pushReplacementNamed<T, TO>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return Navigator.pushReplacementNamed<T, TO>(
      context,
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  static Future<T?> pushNamedAndClearStack<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop(context, result);
  }

  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }
}
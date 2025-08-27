import 'dart:io';
import 'dart:math';
import 'package:intl/intl.dart';

class AppUtils {
  // 日期格式化
  static String formatDate(DateTime date, {String? pattern}) {
    pattern ??= 'yyyy-MM-dd';
    return DateFormat(pattern).format(date);
  }

  static String formatDateTime(DateTime dateTime, {String? pattern}) {
    pattern ??= 'yyyy-MM-dd HH:mm';
    return DateFormat(pattern).format(dateTime);
  }

  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return formatDate(dateTime);
    }
  }

  // 文件大小格式化
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // 文件扩展名获取
  static String getFileExtension(String filePath) {
    return filePath.split('.').last.toLowerCase();
  }

  // 验证文件类型
  static bool isValidImageFile(String filePath) {
    final extension = getFileExtension(filePath);
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }

  static bool isValidAudioFile(String filePath) {
    final extension = getFileExtension(filePath);
    return ['mp3', 'wav', 'aac', 'm4a'].contains(extension);
  }

  static bool isValidVideoFile(String filePath) {
    final extension = getFileExtension(filePath);
    return ['mp4', 'mov', 'avi'].contains(extension);
  }

  // 文件大小检查
  static bool isFileSizeValid(File file, int maxSizeMB) {
    final fileSizeBytes = file.lengthSync();
    final maxSizeBytes = maxSizeMB * 1024 * 1024;
    return fileSizeBytes <= maxSizeBytes;
  }

  // 字符串处理
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  static String stripHtml(String html) {
    final RegExp htmlTagRegExp = RegExp(r'<[^>]*>');
    return html.replaceAll(htmlTagRegExp, '').trim();
  }

  static bool isNullOrEmpty(String? str) {
    return str == null || str.trim().isEmpty;
  }

  // 颜色处理
  static String generateRandomColor() {
    final random = Random();
    final colors = [
      '#F44336', '#E91E63', '#9C27B0', '#673AB7',
      '#3F51B5', '#2196F3', '#03A9F4', '#00BCD4',
      '#009688', '#4CAF50', '#8BC34A', '#CDDC39',
      '#FFEB3B', '#FFC107', '#FF9800', '#FF5722',
    ];
    return colors[random.nextInt(colors.length)];
  }

  // 数字处理
  static String formatNumber(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
  }

  // 百分比计算
  static double calculatePercentage(int part, int total) {
    if (total == 0) return 0.0;
    return (part / total) * 100;
  }

  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  // 学习统计
  static Map<String, dynamic> calculateStudyStats(List<Map<String, dynamic>> studyRecords) {
    if (studyRecords.isEmpty) {
      return {
        'totalCards': 0,
        'averageTime': 0,
        'accuracy': 0.0,
        'streak': 0,
      };
    }

    final totalCards = studyRecords.length;
    final totalTime = studyRecords.fold<int>(0, (sum, record) => sum + (record['time'] as int));
    final correctAnswers = studyRecords.where((record) => record['correct'] == true).length;
    
    final averageTime = totalTime / totalCards;
    final accuracy = (correctAnswers / totalCards) * 100;

    return {
      'totalCards': totalCards,
      'averageTime': averageTime.round(),
      'accuracy': accuracy,
      'correctAnswers': correctAnswers,
    };
  }

  // 间隔重复算法相关
  static int calculateNextInterval(int currentInterval, double easeFactor, int quality) {
    if (quality < 3) {
      return 1; // 重新开始
    }
    
    if (currentInterval == 1) {
      return quality == 3 ? 1 : 6;
    } else if (currentInterval == 6) {
      return quality == 3 ? 6 : (easeFactor * currentInterval).round();
    } else {
      return (easeFactor * currentInterval).round();
    }
  }

  static double calculateNewEaseFactor(double currentEaseFactor, int quality) {
    final newEaseFactor = currentEaseFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    return newEaseFactor.clamp(1.3, 2.5);
  }

  // 数据验证
  static bool isValidEmail(String email) {
    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegExp.hasMatch(email);
  }

  static bool isValidUrl(String url) {
    final RegExp urlRegExp = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
    );
    return urlRegExp.hasMatch(url);
  }

  // 随机生成
  static String generateRandomId() {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(16, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  // 列表处理
  static List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }

  static List<List<T>> chunk<T>(List<T> list, int chunkSize) {
    final chunks = <List<T>>[];
    for (int i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(i, i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }

  // 错误处理
  static String getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    } else if (error is Error) {
      return error.toString();
    } else {
      return error.toString();
    }
  }

  // 设备信息
  static bool get isAndroid => Platform.isAndroid;
  static bool get isIOS => Platform.isIOS;
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  // 调试相关
  static void debugPrint(String message) {
    if (kDebugMode) {
      print('[FlashMemo Debug] $message');
    }
  }

  // 常量
  static const bool kDebugMode = true; // 在发布时设置为 false
}

// 扩展方法
extension StringExtension on String {
  String get capitalizeFirst {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  bool get isValidEmail => AppUtils.isValidEmail(this);
  bool get isValidUrl => AppUtils.isValidUrl(this);
}

extension DateTimeExtension on DateTime {
  String get timeAgo => AppUtils.formatTimeAgo(this);
  
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }
}

extension ListExtension<T> on List<T> {
  List<T> get removeDuplicates => AppUtils.removeDuplicates(this);
  
  List<List<T>> chunk(int chunkSize) => AppUtils.chunk(this, chunkSize);
}
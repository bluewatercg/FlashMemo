class AppConstants {
  // 应用信息
  static const String appName = 'FlashMemo';
  static const String appVersion = '1.0.0';
  static const String appDescription = '移动端智能闪记卡应用';

  // 数据库相关
  static const String databaseName = 'flashmemo.db';
  static const int databaseVersion = 1;

  // 学习相关常量
  static const int defaultNewCardsPerDay = 20;
  static const int defaultReviewLimit = 100;
  static const double defaultEaseFactor = 2.5;
  static const int defaultInterval = 1;

  // 难度等级
  static const int difficultyAgain = 1;    // 很难
  static const int difficultyHard = 2;     // 难
  static const int difficultyGood = 3;     // 好
  static const int difficultyEasy = 4;     // 很好

  // 卡片模板类型
  static const String templateBasic = 'basic';
  static const String templateCloze = 'cloze';
  static const String templateImage = 'image';

  // 卡片面
  static const String cardSideFront = 'front';
  static const String cardSideBack = 'back';

  // 本地存储键
  static const String keyFirstLaunch = 'first_launch';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyNewCardsPerDay = 'new_cards_per_day';
  static const String keyReviewLimit = 'review_limit';
  static const String keyAutoPlayAudio = 'auto_play_audio';
  static const String keyShowAnswer = 'show_answer';

  // 媒体文件限制
  static const int maxImageSizeMB = 10;
  static const int maxAudioSizeMB = 20;
  static const int maxVideoSizeMB = 50;

  // 支持的文件格式
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> supportedAudioFormats = ['mp3', 'wav', 'aac', 'm4a'];
  static const List<String> supportedVideoFormats = ['mp4', 'mov', 'avi'];

  // API相关
  static const String baseApiUrl = 'https://api.flashmemo.com';
  static const String syncEndpoint = '/sync';
  static const String backupEndpoint = '/backup';

  // 错误消息
  static const String errorNetworkConnection = '网络连接失败，请检查网络设置';
  static const String errorDatabaseOperation = '数据库操作失败';
  static const String errorFileNotFound = '文件不存在';
  static const String errorInvalidFormat = '不支持的文件格式';
  static const String errorFileSizeExceeded = '文件大小超出限制';
  static const String errorPermissionDenied = '权限被拒绝';

  // 成功消息
  static const String successDeckCreated = '卡组创建成功';
  static const String successCardCreated = '卡片创建成功';
  static const String successDataSynced = '数据同步成功';
  static const String successDataExported = '数据导出成功';
  static const String successDataImported = '数据导入成功';

  // 确认消息
  static const String confirmDeleteDeck = '确定要删除这个卡组吗？此操作无法撤销。';
  static const String confirmDeleteCard = '确定要删除这张卡片吗？此操作无法撤销。';
  static const String confirmResetProgress = '确定要重置学习进度吗？此操作无法撤销。';

  // 动画持续时间
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationLong = Duration(milliseconds: 500);

  // 延迟时间
  static const Duration debounceDelay = Duration(milliseconds: 300);
  static const Duration autoSaveDelay = Duration(seconds: 2);

  // 分页相关
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // 搜索相关
  static const int minSearchLength = 2;
  static const int maxSearchHistory = 10;

  // 备份相关
  static const int maxBackupFiles = 5;
  static const String backupFileExtension = '.flashmemo';

  // 标签颜色
  static const List<String> tagColors = [
    '#F44336', // Red
    '#E91E63', // Pink
    '#9C27B0', // Purple
    '#673AB7', // Deep Purple
    '#3F51B5', // Indigo
    '#2196F3', // Blue
    '#03A9F4', // Light Blue
    '#00BCD4', // Cyan
    '#009688', // Teal
    '#4CAF50', // Green
    '#8BC34A', // Light Green
    '#CDDC39', // Lime
    '#FFEB3B', // Yellow
    '#FFC107', // Amber
    '#FF9800', // Orange
    '#FF5722', // Deep Orange
  ];

  // 统计相关
  static const int statsDisplayDays = 30;
  static const int streakMinimumDays = 1;

  // 同步相关
  static const Duration syncInterval = Duration(minutes: 15);
  static const int maxSyncRetries = 3;
  static const Duration syncTimeout = Duration(seconds: 30);
}
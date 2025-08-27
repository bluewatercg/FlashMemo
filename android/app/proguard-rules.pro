# Flutter相关的ProGuard规则
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# 保留SQLite相关类
-keep class net.sqlcipher.** { *; }
-keep class net.sqlcipher.database.** { *; }

# 保留Gson相关类（如果使用）
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.stream.** { *; }

# 保留所有的模型类
-keep class com.flashmemo.app.models.** { *; }

# 防止混淆导致反射失败
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# 保留枚举类
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
# Keep Flutter and plugin metadata intact while shrinking release resources.
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class * extends io.flutter.embedding.engine.plugins.FlutterPlugin { *; }
-dontwarn io.flutter.embedding.**

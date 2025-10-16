# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in android.app.proguard.txt.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Gson specific classes
-dontwarn sun.misc.**
-keep class com.google.gson.stream.** { *; }

# Application classes that will be serialized/deserialized over Gson
-keep class com.khpos.cashier.** { *; }

# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Isar Database
-keep class isar.** { *; }
-keep class com.isar.** { *; }

# Keep native libraries
-keep class ** { native <methods>; }

# Flutter secure storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Workmanager
-keep class be.tramckrijte.workmanager.** { *; }

# Google Play Store related (to fix missing classes)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Flutter embedding engine (for deferred components)
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# Don't warn about missing classes that we don't use
-dontwarn javax.annotation.**
-dontwarn kotlin.Unit
-dontwarn kotlin.coroutines.**
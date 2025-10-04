# Keep image_cropper related classes
-keep class com.yalantis.ucrop.** { *; }
-dontwarn com.yalantis.ucrop.**

# Keep OkHttp classes (required by UCrop)
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# Keep TensorFlow Lite classes
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }
-dontwarn org.tensorflow.lite.**

# Keep image picker classes
-keep class io.flutter.plugins.imagepicker.** { *; }
-dontwarn io.flutter.plugins.imagepicker.**

# Keep camera plugin classes
-keep class io.flutter.plugins.camera.** { *; }
-dontwarn io.flutter.plugins.camera.**

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Keep classes with @Keep annotation
-keep @androidx.annotation.Keep class *
-keepclassmembers class * {
    @androidx.annotation.Keep *;
}

# Keep Gson classes if used
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# Keep HTTP classes
-keep class java.net.** { *; }
-keep class javax.net.** { *; }
-keep class org.apache.http.** { *; }
-dontwarn java.net.**
-dontwarn javax.net.**
-dontwarn org.apache.http.**
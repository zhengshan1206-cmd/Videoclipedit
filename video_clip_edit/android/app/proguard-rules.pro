-optimizationpasses 1
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-dontpreverify
#-dontoptimize
#-ignorewarnings
-verbose
-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*
-keepattributes Exceptions,InnerClasses,Signature,Deprecated,SourceFile,LineNumberTable,*Annotation*,EnclosingMethod
#Flutter Wrapper
-keep class com.shockwave.**
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# 保留 Flutter 插件和用户自定义插件
-keep class beiyin.subtletypen.com.** { *; }
-keep class com.yinxiaozhi.fastscreen.** { *; }
# 字节跳动归因 SDK 混淆保护规则
-dontwarn com.bytedance.**
-keep class com.bytedance.** { *; }
-keep class com.bytedance.ads.** { *; }
-keep class com.bytedance.applog.** { *; }
-keep class com.bytedance.ads.convert.** { *; }
-keep class com.bytedance.ads.convert.broadcast.** { *; }
-keep class com.bytedance.ads.convert.broadcast.common.** { *; }
-keepclassmembers class com.bytedance.ads.convert.broadcast.common.EncryptionTools {
    public static java.lang.String bytesToHex(byte[]);
    public static byte[] hexToBytes(java.lang.String);
}
-keep class com.bytedance.applog.game.** { *; }

-dontwarn com.cmic.gen.sdk.**
-keep class com.cmic.gen.sdk.**{*;}
-dontwarn com.sdk.**
-keep class com.sdk.** { *;}
-dontwarn com.unikuwei.mianmi.account.shield.**
-keep class com.unikuwei.mianmi.account.shield.** {*;}
-keep class cn.com.chinatelecom.account.api.**{*;}




-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.app.backup.BackupAgentHelper
-keep public class * extends android.preference.Preference

-keepclasseswithmembers class * {
    public <init>(android.content.Context,android.util.AttributeSet);
}

-keepclasseswithmembers class * {
    public <init>(android.content.Context,android.util.AttributeSet,int);
}

-keepclassmembers class * extends android.app.Activity {
    public void *(android.view.View);
}

-keep class * extends android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

-keepclassmembers class * extends android.os.Parcelable$Creator {
	public <methods>;
}

# Keep names - Native method names. Keep all native class/method names.
-keepclasseswithmembers class * {
    native <methods>;
}

# Also keep - Enumerations. Keep the special static methods that are required in
# enumeration classes.
-keepclassmembers enum  * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

#support.v4/v7
-keep class android.support.** { *; }
-keep class android.support.v4.** { *; }
-keep public class * extends android.support.v4.**
-keep interface android.support.v4.app.** { *; }
-keep class android.support.v7.** { *; }
-keep public class * extends android.support.v7.**
-keep interface android.support.v7.app.** { *; }
-dontwarn android.support.**


#fastjson
-dontwarn com.alibaba.fastjson.**
-keep class com.alibaba.fastjson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*



#AndroidX混淆开始
-keep class com.google.android.material.** {*;}
-keep class androidx.** {*;}
-keep public class * extends androidx.**
-keep interface androidx.** {*;}
-dontwarn com.google.android.material.**
-dontnote com.google.android.material.**
-dontwarn androidx.**
#AndroidX混淆结束


#fresco
-keep,allowobfuscation @interface com.facebook.common.internal.DoNotStrip
-keep @com.facebook.common.internal.DoNotStrip class *
-keepclassmembers class * {
    @com.facebook.common.internal.DoNotStrip *;
}

-dontwarn okio.**
-dontwarn com.squareup.okhttp.**
-dontwarn okhttp3.**
-dontwarn javax.annotation.**
-dontwarn com.android.volley.toolbox.**
-dontwarn com.facebook.infer.**




#水印
#-keepclassmembers class * extends com.vecore.recorder.api.OSDBuilder{  * ;}



-dontwarn  org.apache.commons.**
-keep class org.apache.commons.** { *; }

##---------------Begin: proguard configuration for Gson  ----------
# Gson uses generic type information stored in a class file when working with fields. Proguard
# removes such information by default, so configure it to keep all of it.
-keepattributes Signature

# For using GSON @Expose annotation
-keepattributes *Annotation*

# Gson specific classes
-dontwarn sun.misc.**
#-keep class com.google.gson.stream.** { *; }

# Application classes that will be serialized/deserialized over Gson
-keep class com.google.gson.examples.android.model.** { <fields>; }

# Prevent proguard from stripping interface information from TypeAdapter, TypeAdapterFactory,
# JsonSerializer, JsonDeserializer instances (so they can be used in @JsonAdapter)
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Prevent R8 from leaving Data object members always null
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

##---------------End: proguard configuration for Gson  ----------


##----------------glide begin---------------
# glide混淆
-keep public class * implements com.bumptech.glide.module.GlideModule
-keep public class * extends com.bumptech.glide.module.AppGlideModule
-keep public enum com.bumptech.glide.load.ImageHeaderParser$** {
  **[] $VALUES;
  public *;
}
##-------------------------end--------------------


##---------------------apng begin--------
-dontwarn  com.github.penfeizhou.**
-keep class com.github.penfeizhou.** { *; }
#-------------------------end----------------

##---------------------gsyvideoplayer begin--------
-keep class tv.danmaku.ijk.** { *; }
-dontwarn tv.danmaku.ijk.**
-keep class com.shuyu.gsyvideoplayer.** { *; }
-dontwarn com.shuyu.gsyvideoplayer.**
#-------------------------end----------------





#keep annotation Keep
-dontwarn androidx.annotation.Keep
-keep @androidx.annotation.Keep class ** {*;}
-keep @androidx.annotation.Keep class *$* {*;}
# 核心
#-dontwarn  com.vecore.**
#-keep class com.vecore.** { *; }

#录屏核心
#-dontwarn  com.srcore.**
#-keep class com.srcore.** { *; }

#UISDK
#-dontwarn  com.multitrack.**
#-keep class com.multitrack.** { *; }


#lambda
-dontwarn java.lang.invoke.**


#loading
#-dontwarn  com.vesdk.publik.ui.loading.**
#-keep class com.vesdk.publik.ui.loading.** { *; }

#---跟踪 begin------
-dontwarn  org.**
-keep class org.** { *; }

-dontwarn  boofcv.**
-keep class boofcv.** { *; }

-dontwarn  georegression.**
-keep class georegression.** { *; }
#---end------

#-----mnn begin------
-dontwarn  com.alibaba.**
-keep class com.alibaba.** { *; }
#---end------

#-----velite.bean begin------
#-dontwarn  com.vesdk.publik.model.**
#-keep class com.vesdk.publik.model.** { *; }
#---end------





#kotlin
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}
-assumenosideeffects class kotlin.jvm.internal.Intrinsics {
    static void checkParameterIsNotNull(java.lang.Object, java.lang.String);
}

-keepclasseswithmembernames class * {
    native <methods>;
}


# ----------------- R8 Missing classes suppress rules (auto from missing_rules.txt) -----------------
# 这些类在某些依赖中是可选的，R8 在压缩时会因为找不到它们而报错。
# 按照 Gradle 生成的 missing_rules.txt 建议，增加 dontwarn 规则，避免构建失败。
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
-dontwarn com.huawei.android.os.BuildEx$VERSION
-dontwarn com.huawei.hianalytics.process.HiAnalyticsConfig$Builder
-dontwarn com.huawei.hianalytics.process.HiAnalyticsConfig
-dontwarn com.huawei.hianalytics.process.HiAnalyticsInstance$Builder
-dontwarn com.huawei.hianalytics.process.HiAnalyticsInstance
-dontwarn com.huawei.hianalytics.process.HiAnalyticsManager
-dontwarn com.huawei.hianalytics.util.HiAnalyticTools
-dontwarn com.huawei.hms.availableupdate.UpdateAdapterMgr
-dontwarn com.huawei.libcore.io.ExternalStorageFile
-dontwarn com.huawei.libcore.io.ExternalStorageFileInputStream
-dontwarn com.huawei.libcore.io.ExternalStorageFileOutputStream
-dontwarn com.huawei.libcore.io.ExternalStorageRandomAccessFile
package com.yinxiaozhi.fastscreen
import android.content.Context
import androidx.multidex.MultiDex
import io.flutter.app.FlutterApplication
import com.umeng.commonsdk.UMConfigure
import com.umeng.message.PushAgent

class MyApplication : FlutterApplication() {
    companion object {
        const val SPACE_NAME = "ve"

        /**

         * 素材服务器地址

         */
        private const val ROOT_URL = "http://vesystem.effectlib.com/api/v1/"

        /**

         * 素材资源服务器地址  （文字、贴纸、滤镜、转场、特效、AE模板、背景音乐 、mv共用此url）

         */
        const val APP_DATA = ROOT_URL + "file/list"

        /**

         * 资源分类（因部分功能需要分类，如：AE模板 、特效、云音乐-分类、音效-分类）

         */
        const val TYPE_URL = ROOT_URL + "category/list"

        /**

         * 音效、云音乐

         */
        const val SOUND_URL = ROOT_URL + "file/list"

        /**

         * 验证功能是否可用

         */
        const val FUNCTION_CHECK_URL = ROOT_URL + "service/list"

        /**
         * 解析网络文章信息
         */
        const val ARTICLE_URL = ROOT_URL + "service/article"
        private const val UGC = ROOT_URL + "ugc/"

        /**
         * 上传模板
         */
        const val UPLOAD_CONTENT = UGC + "file/create"

        /**
         * 创建分类
         */
        const val UPLOAD_TYPE = UGC + "category/create"

        /**

         * 当前应用的模板分类

         */
        const val UPLOAD_CATEGORY_LIST = UGC + "category/list"

        /**

         * 云备份

         */
        const val BACKUP_URL = ROOT_URL + "backup"

        /**

         * 上传文件

         */
        private const val OSS_ROOT = BuildConfig.OSS_ROOT
        private const val OSS_V1 = OSS_ROOT + "v1/"

        /**

         * 搜索网络素材

         */
        const val SEARCH_URL = OSS_V1 + "media/search"
        const val UPLOAD_TOKEN_URL = OSS_ROOT + "v2/pk" //获取上传文件所需公钥

        const val UPLOAD_FILE_URL = OSS_V1 + "oss/upload" //上传文件


        /**

         * 私有云-识别asr

         */
        const val PRIVATE_CLOUD_URL = BuildConfig.PRIVATE_CLOUD_URL
        const val PRIVATE_CLOUD_KEY = BuildConfig.PRIVATE_CLOUD_KEY
    }


    override fun onCreate() {
        // 延迟友盟SDK预初始化，等待用户同意隐私政策后再初始化
        // 友盟SDK将在Flutter端用户同意隐私政策后通过UmengCommonSdk.initCommon()初始化
        // UMConfigure.preInit(this, "67ea471a65c707471a351878", "Dev")
        PushAgent.getInstance(this).setResourcePackageName("com.yinxiaozhi.fastscreen")
        PushAgent.getInstance(this).setPackageListenerEnable(false)
        super.onCreate()
    }


    override fun attachBaseContext(newBase: Context?) {
        super.attachBaseContext(newBase)
        MultiDex.install(this)
    }


}
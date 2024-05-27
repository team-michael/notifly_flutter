package tech.notifly.flutter

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.webkit.WebView
import android.webkit.WebSettings
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

import tech.notifly.Notifly
import tech.notifly.sdk.NotiflySdkWrapperType
import tech.notifly.sdk.NotiflySdkControlToken
import tech.notifly.push.interfaces.INotificationClickEvent
import tech.notifly.push.interfaces.INotificationClickListener

class NotiflyControlTokenImpl : NotiflySdkControlToken

class NotiflyFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var isNativeNotificationClickListenersAdded = false

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "notifly_flutter_android")
        channel.setMethodCallHandler(this)
        context = binding.applicationContext

        // Initialize Webview
        val webView = WebView(context!!)
        webView.settings.javaScriptEnabled = true
        webView.settings.useWideViewPort = true
        webView.settings.loadWithOverviewMode = true
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = null
    }

    override fun onAttachedToActivity(@NonNull binding: ActivityPluginBinding) {
        context = binding.activity;
    }

    override fun onDetachedFromActivity() {
    }

    override fun onReattachedToActivityForConfigChanges(@NonNull binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        val methodName = call.method
        if (methodName == "getPlatformName") {
            result.success("Android")
        }

        var errorCodeOnError = ""
        var errorMessageOnError = ""

        try {
            when (methodName) {
                "initialize" -> {
                    errorCodeOnError = "INITIALIZATION_FAILED"
                    errorMessageOnError = "Failed to initialize Notifly"

                    initialize(call)
                    runOnMainThread {
                        result.success(true)
                    }
                }

                "setUserId" -> {
                    errorCodeOnError = "SET_USER_ID_FAILED"
                    errorMessageOnError = "Failed to set user id"

                    setUserId(call)
                    runOnMainThread {
                        result.success(true)
                    }
                }

                "setUserProperties" -> {
                    errorCodeOnError = "SET_USER_PROPERTIES_FAILED"
                    errorMessageOnError = "Failed to set user properties"

                    setUserProperties(call)
                    runOnMainThread {
                        result.success(true)
                    }
                }

                "trackEvent" -> {
                    errorCodeOnError = "TRACK_EVENT_FAILED"
                    errorMessageOnError = "Failed to track event"

                    trackEvent(call)
                    runOnMainThread {
                        result.success(true)
                    }
                }

                "setLogLevel" -> {
                    errorCodeOnError = "SET_LOG_LEVEL_FAILED"
                    errorMessageOnError = "Failed to set log level"

                    setLogLevel(call)
                    runOnMainThread {
                        result.success(true)
                    }
                }

                "addNotificationClickListener" -> {
                    errorCodeOnError = "ADD_NOTIFICATION_CLICK_LISTENER_FAILED"
                    errorMessageOnError = "Failed to add notification click listener"

                    addNotificationClickListener()
                    runOnMainThread {
                        result.success(true)
                    }
                }

                else -> {
                    runOnMainThread {
                        result.notImplemented()
                    }
                }
            }
        } catch (e: Exception) {
            when (e) {
                is IllegalArgumentException -> {
                    runOnMainThread {
                        result.error("INVALID_ARGUMENT", e.message, null)
                    }
                }

                else -> {
                    runOnMainThread {
                        result.error(errorCodeOnError, errorMessageOnError, e.toString())
                    }
                }
            }
        }
    }

    @Throws(IllegalArgumentException::class, Exception::class)
    private fun initialize(call: MethodCall) {
        if (context == null) {
            throw Exception("Context is null")
        }
        val projectId = call.argument<String>("projectId")
            ?: throw IllegalArgumentException("ProjectId was not provided")
        val username = call.argument<String>("username")
            ?: throw IllegalArgumentException("Username was not provided")
        val password = call.argument<String>("password")
            ?: throw IllegalArgumentException("Password was not provided")

        Notifly.setSdkType(NotiflyControlTokenImpl(), NotiflySdkWrapperType.FLUTTER)
        Notifly.setSdkVersion(NotiflyControlTokenImpl(), NOTIFLY_FLUTTER_PLUGIN_VERSION)

        Notifly.initialize(context!!, projectId, username, password)
    }

    @Throws(IllegalArgumentException::class, Exception::class)
    private fun setUserId(call: MethodCall) {
        if (context == null) {
            throw Exception("Context is null")
        }
        val userId = call.argument<String?>("userId")

        Notifly.setUserId(context!!, userId)
    }

    @Throws(IllegalArgumentException::class, Exception::class)
    private fun setUserProperties(call: MethodCall) {
        if (context == null) {
            throw Exception("Context is null")
        }
        val params = call.argument<Map<String, Any>>("params")
            ?: throw IllegalArgumentException("Params was not provided")

        Notifly.setUserProperties(context!!, params)
    }

    @Throws(IllegalArgumentException::class, Exception::class)
    private fun trackEvent(call: MethodCall) {
        if (context == null) {
            throw Exception("Context is null")
        }

        val eventName = call.argument<String>("eventName")
            ?: throw IllegalArgumentException("EventName was not provided")
        val eventParams =
            call.argument<Map<String, Any?>>("eventParams") ?: emptyMap<String, Any?>()
        val segmentationEventParamKeys =
            call.argument<List<String>>("segmentationEventParamKeys") ?: null

        Notifly.trackEvent(context!!, eventName, eventParams, segmentationEventParamKeys)
    }

    @Throws(IllegalArgumentException::class, Exception::class)
    private fun setLogLevel(call: MethodCall) {
        val logLevel = call.argument<Int>("logLevel")
            ?: throw IllegalArgumentException("logLevel was not provided")

        Notifly.setLogLevel(logLevel)
    }

    private fun addNotificationClickListener() {
        if (isNativeNotificationClickListenersAdded) {
            return
        }

        isNativeNotificationClickListenersAdded = true

        Notifly.addNotificationClickListener(object : INotificationClickListener {
            override fun onClick(event: INotificationClickEvent) {
                runOnMainThread {
                    channel.invokeMethod("onNotificationClick", NotiflySerializer.serializeNotificationClickEvent(event))
                }
            }
        })
    }

    private fun runOnMainThread(runnable: Runnable) {
        if (Looper.getMainLooper().thread == Thread.currentThread()) {
            runnable.run()
        } else {
            val handler = Handler(Looper.getMainLooper())
            handler.post(runnable)
        }
    }
}

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
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

import tech.notifly.Notifly
import tech.notifly.sdk.NotiflySdkWrapperType
import tech.notifly.sdk.NotiflySdkControlToken
import tech.notifly.push.interfaces.INotificationClickEvent
import tech.notifly.push.interfaces.INotificationClickListener
import tech.notifly.push.interfaces.IInAppMessageEventListener

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class NotiflyControlTokenImpl : NotiflySdkControlToken

class NotiflyFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, StreamHandler {
    companion object {
        // Shared across all plugin instances to prevent duplicate registrations
        @Volatile
        private var isNativeInAppMessageEventListenerAdded = false

        // Shared eventSink - last registered instance wins
        @Volatile
        private var sharedEventSink: EventSink? = null

        // Shared listener instance
        private val inAppMessageEventListener = object : IInAppMessageEventListener {
            override fun handleEvent(eventName: String, eventParams: Map<String, Any?>?) {
                runOnMainThread {
                    try {
                        android.util.Log.i("NotiflyFlutterPlugin", "📨 [Notifly] Event: $eventName")

                        if (sharedEventSink == null) {
                            android.util.Log.w("NotiflyFlutterPlugin", "⚠️ [Notifly] Event dropped (no subscription)")
                            return@runOnMainThread
                        }

                        val payload = mapOf(
                            "eventName" to eventName,
                            "eventParams" to eventParams
                        )
                        sharedEventSink?.success(payload)
                    } catch (e: Exception) {
                        android.util.Log.e("NotiflyFlutterPlugin", "❌ [Notifly] Failed to send event: ${e.message}", e)
                    }
                }
            }
        }

        private fun runOnMainThread(block: () -> Unit) {
            if (Looper.getMainLooper().thread == Thread.currentThread()) {
                block()
            } else {
                Handler(Looper.getMainLooper()).post(block)
            }
        }
    }

    private lateinit var channel: MethodChannel
    private lateinit var inAppEventChannel: EventChannel
    private var context: Context? = null
    private var isNativeNotificationClickListenersAdded = false

    private val pluginScope = CoroutineScope(Dispatchers.Default)

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        try {
            channel = MethodChannel(binding.binaryMessenger, "notifly_flutter_android")
            channel.setMethodCallHandler(this)
            context = binding.applicationContext

            // Setup EventChannel for in-app message events
            inAppEventChannel = EventChannel(binding.binaryMessenger, "notifly_flutter/in_app_events")
            inAppEventChannel.setStreamHandler(this)

            // Initialize Webview
            val webView = WebView(context!!)
            webView.settings.javaScriptEnabled = true
            webView.settings.useWideViewPort = true
            webView.settings.loadWithOverviewMode = true
        } catch (e: Exception) {
            android.util.Log.e("NotiflyFlutterPlugin", "❌ [Notifly] Plugin attach failed: ${e.message}", e)
            throw e
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        try {
            channel.setMethodCallHandler(null)
            inAppEventChannel.setStreamHandler(null)
            sharedEventSink = null
            context = null
        } catch (e: Exception) {
            android.util.Log.e("NotiflyFlutterPlugin", "❌ [Notifly] Plugin detach failed: ${e.message}", e)
        }
    }

    override fun onAttachedToActivity(@NonNull binding: ActivityPluginBinding) {
        context = binding.activity
    }

    override fun onDetachedFromActivity() {
        // No-op
    }

    override fun onReattachedToActivityForConfigChanges(@NonNull binding: ActivityPluginBinding) {
        context = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        // No-op
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        val methodName = call.method

        if (methodName == "getPlatformName") {
            result.success("Android")
            return
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

                "setEmail" -> {
                    errorCodeOnError = "SET_EMAIL_FAILED"
                    errorMessageOnError = "Failed to set email"

                    setEmail(call)
                    runOnMainThread {
                        result.success(true)
                    }
                }

                "setPhoneNumber" -> {
                    errorCodeOnError = "SET_PHONE_NUMBER_FAILED"
                    errorMessageOnError = "Failed to set phone number"

                    setPhoneNumber(call)
                    runOnMainThread {
                        result.success(true)
                    }
                }

                "setTimezone" -> {
                    errorCodeOnError = "SET_TIMEZONE_FAILED"
                    errorMessageOnError = "Failed to set timezone"

                    setTimezone(call)
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

                "getNotiflyUserId" -> {
                    errorCodeOnError = "GET_NOTIFLY_USER_ID_FAILED"
                    errorMessageOnError = "Failed to get Notifly user id"

                    pluginScope.launch {
                        try {
                            val notiflyUserId = withContext(Dispatchers.IO) {
                                getNotiflyUserId(call)
                            }
                            result.success(notiflyUserId)
                        } catch (e: Exception) {
                            result.error(errorCodeOnError, errorMessageOnError, e.toString())
                        }
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
                    android.util.Log.w("NotiflyFlutterPlugin", "⚠️ [Notifly] Unknown method: $methodName")
                    runOnMainThread {
                        result.notImplemented()
                    }
                }
            }
        } catch (e: Exception) {
            android.util.Log.e("NotiflyFlutterPlugin", "❌ [Notifly] Method call failed: $methodName", e)

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

        android.util.Log.i("NotiflyFlutterPlugin", "🚀 [Notifly] Initialized (project: $projectId)")
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
    private fun setEmail(call: MethodCall) {
        if (context == null) {
            throw Exception("Context is null")
        }
        val email = call.argument<String>("email")
            ?: throw IllegalArgumentException("Email was not provided")

        Notifly.setEmail(context!!, email)
    }

    @Throws(IllegalArgumentException::class, Exception::class)
    private fun setPhoneNumber(call: MethodCall) {
        if (context == null) {
            throw Exception("Context is null")
        }
        val phoneNumber = call.argument<String>("phoneNumber")
            ?: throw IllegalArgumentException("PhoneNumber was not provided")
        
        Notifly.setPhoneNumber(context!!, phoneNumber)
    }

    @Throws(IllegalArgumentException::class, Exception::class)
    private fun setTimezone(call: MethodCall) {
        if (context == null) {
            throw Exception("Context is null")
        }
        val timezone = call.argument<String>("timezone")
            ?: throw IllegalArgumentException("Timezone was not provided")

        Notifly.setTimezone(context!!, timezone)
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
    private suspend fun getNotiflyUserId(call: MethodCall): String? {
        if (context == null) {
            throw Exception("Context is null")
        }

        return Notifly.getNotiflyUserId(context!!)
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

    // Removed - using companion object version instead

    // EventChannel.StreamHandler implementation
    override fun onListen(arguments: Any?, events: EventSink?) {
        android.util.Log.i("NotiflyFlutterPlugin", "📡 [Notifly] InApp stream subscribed")

        try {
            sharedEventSink = events

            // Register native listener only once (singleton pattern for hot reload)
            if (!isNativeInAppMessageEventListenerAdded) {
                isNativeInAppMessageEventListenerAdded = true
                Notifly.addInAppMessageEventListener(inAppMessageEventListener)
                android.util.Log.i("NotiflyFlutterPlugin", "📡 [Notifly] InApp listener registered")
            } else {
                android.util.Log.i("NotiflyFlutterPlugin", "♻️ [Notifly] Reusing existing listener")
            }
        } catch (e: Exception) {
            android.util.Log.e("NotiflyFlutterPlugin", "❌ [Notifly] Failed to subscribe: ${e.message}", e)
        }
    }

    override fun onCancel(arguments: Any?) {
        android.util.Log.i("NotiflyFlutterPlugin", "🔌 [Notifly] InApp stream unsubscribed")

        try {
            sharedEventSink = null
            // Note: We keep the native listener for hot reload support
        } catch (e: Exception) {
            android.util.Log.e("NotiflyFlutterPlugin", "❌ [Notifly] Failed to unsubscribe: ${e.message}", e)
        }
    }
}

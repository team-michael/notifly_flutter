package tech.notifly

import android.content.Context
import android.webkit.WebView
import android.util.Log
import android.webkit.WebSettings
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import tech.notifly.Notifly
import tech.notifly.utils.NotiflySdkType
import tech.notifly.utils.NotiflyControlToken

class NotiflyControlTokenImpl : NotiflyControlToken

class NotiflyFlutterPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var context: Context? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "notifly_flutter_android")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext

        // Initialize Webview
        val webView = WebView(context!!)
        webView.settings.javaScriptEnabled = true
        webView.settings.useWideViewPort = true
        webView.settings.loadWithOverviewMode = true
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
                    result.success(true)
                }

                "setUserId" -> {
                    errorCodeOnError = "SET_USER_ID_FAILED"
                    errorMessageOnError = "Failed to set user id"

                    setUserId(call)
                    result.success(true)
                }

                "setUserProperties" -> {
                    errorCodeOnError = "SET_USER_PROPERTIES_FAILED"
                    errorMessageOnError = "Failed to set user properties"

                    setUserProperties(call)
                    result.success(true)
                }

                "trackEvent" -> {
                    errorCodeOnError = "TRACK_EVENT_FAILED"
                    errorMessageOnError = "Failed to track event"

                    trackEvent(call)
                    result.success(true)
                }

                else -> {
                    result.notImplemented()
                }
            }
        } catch (e: Exception) {
            when (e) {
                is IllegalArgumentException -> {
                    result.error("INVALID_ARGUMENT", e.message, null)
                }

                else -> {
                    result.error(
                        errorCodeOnError, errorMessageOnError, e.toString()
                    )
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

        Notifly.setSdkType(NotiflyControlTokenImpl(), NotiflySdkType.FLUTTER)
        Notifly.setSdkVersion(NotiflyControlTokenImpl(), "0.0.1") // TODO: Get version from pubspec.yaml

        Notifly.initialize(context!!, projectId, username, password)
    }

    @Throws(IllegalArgumentException::class, Exception::class)
    private fun setUserId(call: MethodCall) {
        if (context == null) {
            throw Exception("Context is null")
        }
        val userId = call.argument<String>("userId")
            ?: throw IllegalArgumentException("UserId was not provided")

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

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = null
    }
}
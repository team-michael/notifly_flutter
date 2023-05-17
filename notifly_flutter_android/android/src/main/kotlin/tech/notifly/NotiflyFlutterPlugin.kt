package tech.notifly

import android.content.Context
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import tech.notifly.Notifly

class NotiflyFlutterPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var context: Context? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "notifly_flutter_android")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "getPlatformName") {
            result.success("Android")
        } else if (call.method == "initialize") {
            try {
                val success = initialize(context, call)
                result.success(success)
            } catch (e: Exception) {
                when (e) {
                    is IllegalArgumentException -> {
                        result.error("INVALID_ARGUMENT", e.message, null)
                    }

                    else -> {
                        result.error(
                            "INITIALIZATION_FAILED",
                            "Failed to initialize Notifly",
                            e.toString()
                        )
                    }
                }
            }
        } else {
            result.notImplemented()
        }
    }

    @Throws(IllegalArgumentException::class, Exception::class)
    private fun initialize(context: Context?, call: MethodCall): Boolean {
        if (context == null) {
            throw Exception("Context is null")
        }
        val projectId = call.argument<String>("projectId")
            ?: throw IllegalArgumentException("ProjectId was not provided")
        val username = call.argument<String>("username")
            ?: throw IllegalArgumentException("Username was not provided")
        val password = call.argument<String>("password")
            ?: throw IllegalArgumentException("Password was not provided")

        Notifly.initialize(context, projectId, username, password)
        return true
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = null
    }
}
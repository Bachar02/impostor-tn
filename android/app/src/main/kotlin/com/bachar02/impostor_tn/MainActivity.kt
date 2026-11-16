package com.bachar02.impostor_tn

import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * The app's own platform channel (ADR-0003, ADR-0006). No plugin is used.
 *
 * - privateFilesDirectory: the app-private directory that is also excluded
 *   from backups, where the saved game lives.
 * - setSecure(Boolean): FLAG_SECURE on the window, which blocks screenshots
 *   and blanks the app-switcher preview on supporting devices (D-18, the
 *   whole game). Not verified on a device.
 */
class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "privateFilesDirectory" ->
                        result.success(noBackupFilesDir.absolutePath)
                    "setSecure" -> {
                        val secure = call.arguments as? Boolean
                        if (secure == null) {
                            result.error("bad_argument", null, null)
                        } else {
                            if (secure) {
                                window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                            } else {
                                window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                            }
                            result.success(null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private companion object {
        const val CHANNEL = "impostor_tn/platform"
    }
}

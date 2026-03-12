package com.example.vocab_fl

import android.os.Bundle
import android.speech.tts.TextToSpeech
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity : FlutterActivity(), TextToSpeech.OnInitListener {
    private lateinit var textToSpeech: TextToSpeech
    private var isTtsReady = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        textToSpeech = TextToSpeech(this, this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "vocab_fl/tts"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "speak" -> {
                    val text = call.argument<String>("text")?.trim().orEmpty()
                    if (text.isEmpty()) {
                        result.error("invalid_text", "Text is empty", null)
                        return@setMethodCallHandler
                    }
                    if (!isTtsReady) {
                        result.error("tts_unavailable", "Text-to-speech is not ready yet", null)
                        return@setMethodCallHandler
                    }

                    textToSpeech.stop()
                    val status = textToSpeech.speak(text, TextToSpeech.QUEUE_FLUSH, null, "quiz_word")
                    if (status == TextToSpeech.ERROR) {
                        result.error("tts_failed", "Unable to speak the requested word", null)
                    } else {
                        result.success(null)
                    }
                }
                "stop" -> {
                    if (isTtsReady) {
                        textToSpeech.stop()
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onInit(status: Int) {
        if (status != TextToSpeech.SUCCESS) {
            isTtsReady = false
            return
        }

        val localeResult = textToSpeech.setLanguage(Locale.US)
        isTtsReady = localeResult != TextToSpeech.LANG_MISSING_DATA &&
            localeResult != TextToSpeech.LANG_NOT_SUPPORTED
    }

    override fun onDestroy() {
        if (::textToSpeech.isInitialized) {
            textToSpeech.stop()
            textToSpeech.shutdown()
        }
        super.onDestroy()
    }
}

import 'package:flutter/services.dart';

class TtsService {
  static const MethodChannel _channel = MethodChannel('vocab_fl/tts');

  static Future<void> speakWord(String text) async {
    final normalized = text.trim();
    if (normalized.isEmpty) {
      throw ArgumentError('text must not be empty');
    }
    await _channel.invokeMethod<void>('speak', {'text': normalized});
  }

  static Future<void> stop() async {
    await _channel.invokeMethod<void>('stop');
  }
}

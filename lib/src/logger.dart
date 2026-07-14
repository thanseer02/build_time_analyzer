import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// A simple internal logger for the Build Time Analyzer.
/// 
/// Uses `dart:developer` log which works well with Flutter DevTools
/// and avoids polluting standard print statements in Release mode.
class AnalyzerLogger {
  static const String _name = 'BuildTimeAnalyzer';

  static void info(String message) {
    if (kReleaseMode) return;
    developer.log(message, name: _name, level: 0);
  }

  static void warning(String message) {
    if (kReleaseMode) return;
    developer.log(
      '⚠️ $message',
      name: _name,
      level: 900, // WARNING level
    );
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kReleaseMode) return;
    developer.log(
      '❌ $message',
      name: _name,
      level: 1000, // SEVERE level
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void logSlowBuild(String widgetName, Duration duration, Duration threshold) {
    warning(
      'Slow widget build detected!\n'
      'Widget: $widgetName\n'
      'Duration: ${duration.inMilliseconds}ms (Threshold: ${threshold.inMilliseconds}ms)'
    );
  }

  static void logJankyFrame(int frameNumber, Duration buildDuration, Duration rasterDuration, Duration threshold) {
    warning(
      'Janky frame detected! (Frame #$frameNumber)\n'
      'Build: ${buildDuration.inMilliseconds}ms, Raster: ${rasterDuration.inMilliseconds}ms (Threshold: ${threshold.inMilliseconds}ms)'
    );
  }
}

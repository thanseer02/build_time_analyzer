import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'performance_metrics.dart';
import 'logger.dart';

/// Singleton class for recording and aggregating performance metrics.
class AnalyzerRecorder extends ChangeNotifier {
  static final AnalyzerRecorder _instance = AnalyzerRecorder._internal();
  factory AnalyzerRecorder() => _instance;
  AnalyzerRecorder._internal();

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  AnalyzerThresholds thresholds = const AnalyzerThresholds();

  final Map<String, WidgetStats> _widgetStats = {};
  final List<FrameRecord> _frameRecords = [];
  final List<BuildRecord> _timeline = [];

  Map<String, WidgetStats> get widgetStats => Map.unmodifiable(_widgetStats);
  List<FrameRecord> get frameRecords => List.unmodifiable(_frameRecords);
  List<BuildRecord> get timeline => List.unmodifiable(_timeline);

  void startRecording() {
    _isRecording = true;
    notifyListeners();
  }

  void pauseRecording() {
    _isRecording = false;
    notifyListeners();
  }

  void stopRecording() {
    _isRecording = false;
    notifyListeners();
  }

  void clearResults() {
    _widgetStats.clear();
    _frameRecords.clear();
    _timeline.clear();
    notifyListeners();
  }

  void recordWidgetBuild(String name, Duration duration, {String? parent}) {
    if (!_isRecording) return;
    
    final timestamp = DateTime.now();
    _timeline.add(BuildRecord(
      widgetName: name,
      buildDuration: duration,
      parentWidget: parent,
      timestamp: timestamp,
    ));

    if (_widgetStats.containsKey(name)) {
      final stats = _widgetStats[name]!;
      stats.buildCount++;
      stats.totalBuildTime += duration;
      stats.maxBuildTime = _maxDuration(stats.maxBuildTime, duration);
      stats.minBuildTime = _minDuration(stats.minBuildTime, duration);
      stats.lastBuildTime = timestamp;
    } else {
      _widgetStats[name] = WidgetStats(
        widgetName: name,
        totalBuildTime: duration,
        maxBuildTime: duration,
        minBuildTime: duration,
        buildCount: 1,
        lastBuildTime: timestamp,
      );
    }
    
    if (duration > thresholds.slowBuildThreshold) {
      AnalyzerLogger.logSlowBuild(name, duration, thresholds.slowBuildThreshold);
    }
  }

  void recordFrame(int frameNumber, Duration buildDuration, Duration rasterDuration) {
    if (!_isRecording) return;
    
    final isJanky = buildDuration > thresholds.jankyFrameThreshold || 
                    rasterDuration > thresholds.jankyFrameThreshold;

    _frameRecords.add(FrameRecord(
      frameNumber: frameNumber,
      buildDuration: buildDuration,
      rasterDuration: rasterDuration,
      isJanky: isJanky,
    ));
    
    if (isJanky) {
      AnalyzerLogger.logJankyFrame(frameNumber, buildDuration, rasterDuration, thresholds.jankyFrameThreshold);
    }
    
    // Periodically notify listeners to avoid overwhelming the UI
    if (frameNumber % 60 == 0) {
      notifyListeners();
    }
  }

  Duration _maxDuration(Duration a, Duration b) => a > b ? a : b;
  Duration _minDuration(Duration a, Duration b) => a < b ? a : b;
}

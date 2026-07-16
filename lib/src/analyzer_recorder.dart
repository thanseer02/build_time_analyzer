

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

  int _framesTrackedThisSession = 0;

  void startRecording() {
    _isRecording = true;
    _framesTrackedThisSession = 0;
    notifyListeners();
  }

  void pauseRecording() {
    _isRecording = false;
    notifyListeners();
  }

  void stopRecording() {
    _isRecording = false;
    AnalyzerLogger.info('Recording stopped.');
    if (_framesTrackedThisSession > 0) {
      _printPerformanceSummary();
    }
    notifyListeners();
  }

  void clearResults() {
    _widgetStats.clear();
    _frameRecords.clear();
    _timeline.clear();
    _framesTrackedThisSession = 0;
    notifyListeners();
  }

  void recordWidgetBuild(String name, Duration duration, {String? parent, int depth = 0}) {
    if (!_isRecording) return;

    final timestamp = DateTime.now();
    _timeline.add(BuildRecord(
      widgetName: name,
      buildDuration: duration,
      parentWidget: parent,
      depth: depth,
      timestamp: timestamp,
    ));

    WidgetStats stat;
    if (_widgetStats.containsKey(name)) {
      stat = _widgetStats[name]!;
      stat.buildCount++;
      stat.totalBuildTime += duration;
      stat.maxBuildTime = _maxDuration(stat.maxBuildTime, duration);
      stat.minBuildTime = _minDuration(stat.minBuildTime, duration);
      stat.lastDuration = duration;
      stat.lastBuildTime = timestamp;
    } else {
      stat = WidgetStats(
        widgetName: name,
        parentWidget: parent,
        depth: depth,
        totalBuildTime: duration,
        maxBuildTime: duration,
        minBuildTime: duration,
        lastDuration: duration,
        buildCount: 1,
        lastBuildTime: timestamp,
      );
      _widgetStats[name] = stat;
    }

    if (duration > thresholds.slowBuildThreshold) {
      AnalyzerLogger.logSlowBuild(stat);
    }
  }

  void recordFrame(
      int frameNumber, Duration buildDuration, Duration rasterDuration) {
    if (!_isRecording) return;

    _framesTrackedThisSession++;

    final isJanky = buildDuration > thresholds.jankyFrameThreshold ||
        rasterDuration > thresholds.jankyFrameThreshold;

    final frameRecord = FrameRecord(
      frameNumber: frameNumber,
      buildDuration: buildDuration,
      rasterDuration: rasterDuration,
      isJanky: isJanky,
    );
    
    _frameRecords.add(frameRecord);

    // Logging Rules
    final isFirstFrame = _framesTrackedThisSession == 1;
    final is30thFrame = _framesTrackedThisSession % 30 == 0;
    final is100thFrame = _framesTrackedThisSession % 100 == 0;

    if (isFirstFrame || is30thFrame || frameRecord.status == FrameStatus.jank) {
      AnalyzerLogger.logFrameAnalysis(frameRecord, _widgetStats);
    }

    if (is100thFrame) {
      _printPerformanceSummary();
    }

    // Periodically notify listeners to avoid overwhelming the UI
    if (frameNumber % 60 == 0) {
      notifyListeners();
    }
  }

  void _printPerformanceSummary() {
    if (_frameRecords.isEmpty) return;

    int totalFps = 0;
    int droppedFrames = 0;
    for (final frame in _frameRecords) {
      totalFps += frame.fps;
      if (frame.status == FrameStatus.jank) {
        droppedFrames++;
      }
    }

    final avgFps = totalFps ~/ _frameRecords.length;
    
    double totalBuildTimeMs = 0;
    int totalBuilds = 0;
    int slowWidgetsCount = 0;
    WidgetStats? worstWidget;

    for (final stat in _widgetStats.values) {
      totalBuildTimeMs += stat.totalBuildTime.inMicroseconds / 1000;
      totalBuilds += stat.buildCount;
      
      if (stat.averageBuildTime > thresholds.slowBuildThreshold) {
        slowWidgetsCount++;
      }
      
      if (worstWidget == null || stat.averageBuildTime > worstWidget.averageBuildTime) {
        worstWidget = stat;
      }
    }

    final avgBuildTimeMs = totalBuilds > 0 ? (totalBuildTimeMs / totalBuilds) : 0.0;

    AnalyzerLogger.logPerformanceSummary(
      _framesTrackedThisSession,
      avgFps,
      avgBuildTimeMs,
      droppedFrames,
      _widgetStats.length,
      slowWidgetsCount,
      worstWidget?.widgetName ?? 'None',
      worstWidget != null ? (worstWidget.averageBuildTime.inMicroseconds / 1000) : 0.0,
    );
  }

  Duration _maxDuration(Duration a, Duration b) => a > b ? a : b;
  Duration _minDuration(Duration a, Duration b) => a < b ? a : b;
}

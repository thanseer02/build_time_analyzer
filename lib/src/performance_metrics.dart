/// Data models for the Build Time Analyzer.

class BuildRecord {
  final String widgetName;
  final Duration buildDuration;
  final String? parentWidget;
  final DateTime timestamp;

  BuildRecord({
    required this.widgetName,
    required this.buildDuration,
    this.parentWidget,
    required this.timestamp,
  });
}

class WidgetStats {
  final String widgetName;
  Duration totalBuildTime;
  Duration maxBuildTime;
  Duration minBuildTime;
  int buildCount;
  DateTime lastBuildTime;

  WidgetStats({
    required this.widgetName,
    required this.totalBuildTime,
    required this.maxBuildTime,
    required this.minBuildTime,
    required this.buildCount,
    required this.lastBuildTime,
  });

  Duration get averageBuildTime {
    if (buildCount == 0) return Duration.zero;
    return totalBuildTime ~/ buildCount;
  }
}

class FrameRecord {
  final int frameNumber;
  final Duration buildDuration;
  final Duration rasterDuration;
  final bool isJanky;

  FrameRecord({
    required this.frameNumber,
    required this.buildDuration,
    required this.rasterDuration,
    required this.isJanky,
  });

  Duration get totalDuration => buildDuration + rasterDuration;
}

class AnalyzerThresholds {
  final Duration slowBuildThreshold;
  final Duration jankyFrameThreshold;

  const AnalyzerThresholds({
    this.slowBuildThreshold = const Duration(milliseconds: 5),
    this.jankyFrameThreshold = const Duration(milliseconds: 16),
  });
}

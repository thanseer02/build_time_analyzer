/// Data models for the Build Time Analyzer.

class BuildRecord {
  final String widgetName;
  final Duration buildDuration;
  final String? parentWidget;
  final int depth;
  final DateTime timestamp;

  BuildRecord({
    required this.widgetName,
    required this.buildDuration,
    this.parentWidget,
    this.depth = 0,
    required this.timestamp,
  });
}

class WidgetStats {
  final String widgetName;
  final String? parentWidget;
  final int depth;
  Duration totalBuildTime;
  Duration maxBuildTime;
  Duration minBuildTime;
  Duration lastDuration;
  int buildCount;
  DateTime lastBuildTime;

  WidgetStats({
    required this.widgetName,
    this.parentWidget,
    this.depth = 0,
    required this.totalBuildTime,
    required this.maxBuildTime,
    required this.minBuildTime,
    required this.lastDuration,
    required this.buildCount,
    required this.lastBuildTime,
  });

  Duration get averageBuildTime {
    if (buildCount == 0) return Duration.zero;
    return totalBuildTime ~/ buildCount;
  }
}

enum FrameStatus { smooth, slightDelay, slow, jank }

extension FrameStatusExtension on FrameStatus {
  String get display {
    switch (this) {
      case FrameStatus.smooth:
        return '🟢 Smooth';
      case FrameStatus.slightDelay:
        return '🟡 Slight Delay';
      case FrameStatus.slow:
        return '🟠 Slow';
      case FrameStatus.jank:
        return '🔴 Jank';
    }
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

  int get fps {
    final ms = totalDuration.inMilliseconds;
    if (ms <= 0) return 60; // Max reasonable baseline if 0ms
    return 1000 ~/ ms;
  }

  FrameStatus get status {
    final ms = totalDuration.inMilliseconds;
    if (ms < 16) return FrameStatus.smooth;
    if (ms <= 20) return FrameStatus.slightDelay;
    if (ms <= 30) return FrameStatus.slow;
    return FrameStatus.jank;
  }
}

class AnalyzerThresholds {
  final Duration slowBuildThreshold;
  final Duration jankyFrameThreshold;

  const AnalyzerThresholds({
    this.slowBuildThreshold = const Duration(milliseconds: 5),
    this.jankyFrameThreshold = const Duration(milliseconds: 16),
  });
}

import 'package:flutter/scheduler.dart';

import 'analyzer_recorder.dart';

/// Initializes global frame tracking
class FrameTracker {
  static void initialize() {
    SchedulerBinding.instance.addTimingsCallback(_onReportTimings);
  }

  static void dispose() {
    SchedulerBinding.instance.removeTimingsCallback(_onReportTimings);
  }

  static void _onReportTimings(List<FrameTiming> timings) {
    if (!AnalyzerRecorder().isRecording) return;

    for (final timing in timings) {
      final buildDuration = timing.buildDuration;
      final rasterDuration = timing.rasterDuration;
      final frameNumber = timing.frameNumber;
      
      AnalyzerRecorder().recordFrame(
        frameNumber, 
        buildDuration, 
        rasterDuration
      );
    }
  }
}

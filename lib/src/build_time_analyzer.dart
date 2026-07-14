import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'analyzer_recorder.dart';
import 'performance_metrics.dart';
import 'frame_tracker.dart';
import 'dashboard_overlay.dart';

/// The main entry point and configuration for the Build Time Analyzer.
class BuildTimeAnalyzer extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final bool showOverlay;
  final Duration threshold;
  final String? exportPath;

  const BuildTimeAnalyzer({
    Key? key,
    required this.child,
    this.enabled = true,
    this.showOverlay = true,
    this.threshold = const Duration(milliseconds: 5),
    this.exportPath,
  }) : super(key: key);

  /// Initializes the analyzer globally.
  static void initialize() {
    if (kReleaseMode) return;
    AnalyzerRecorder().startRecording();
  }

  @override
  State<BuildTimeAnalyzer> createState() => _BuildTimeAnalyzerState();
}

class _BuildTimeAnalyzerState extends State<BuildTimeAnalyzer> {
  @override
  void initState() {
    super.initState();
    if (!kReleaseMode && widget.enabled) {
      AnalyzerRecorder().thresholds = AnalyzerThresholds(slowBuildThreshold: widget.threshold);
      if (!AnalyzerRecorder().isRecording) {
        AnalyzerRecorder().startRecording();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode || !widget.enabled) {
      return widget.child;
    }

    // Wrap the app with tracking mechanisms
    return _BuildTracker(
      showOverlay: widget.showOverlay,
      child: widget.child,
    );
  }
}

class _BuildTracker extends StatefulWidget {
  final Widget child;
  final bool showOverlay;

  const _BuildTracker({
    Key? key,
    required this.child,
    required this.showOverlay,
  }) : super(key: key);

  @override
  State<_BuildTracker> createState() => _BuildTrackerState();
}

class _BuildTrackerState extends State<_BuildTracker> with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FrameTracker.initialize();
  }

  @override
  void dispose() {
    FrameTracker.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardOverlay(
      showOverlay: widget.showOverlay,
      child: widget.child,
    );
  }
}
